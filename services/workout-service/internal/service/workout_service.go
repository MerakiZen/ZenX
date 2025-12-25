package service

import (
	"context"
	"database/sql"
	"errors"
	"log"
	"strings"
	"time"

	commonv1 "github.com/zenx/backend/proto/common/v1"
	workoutv1 "github.com/zenx/backend/proto/workout/v1"
	"github.com/zenx/backend/services/workout-service/internal/events"
	"github.com/zenx/backend/services/workout-service/internal/store"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// WorkoutService implements the workout.v1 gRPC API.
type WorkoutService struct {
	workoutv1.UnimplementedWorkoutServiceServer
	repo      *store.Repository
	publisher *events.Publisher
}

// New returns a WorkoutService.
func New(repo *store.Repository, publisher *events.Publisher) *WorkoutService {
	return &WorkoutService{repo: repo, publisher: publisher}
}

// CreateWorkout records a new workout.
func (s *WorkoutService) CreateWorkout(ctx context.Context, req *workoutv1.CreateWorkoutRequest) (*workoutv1.CreateWorkoutResponse, error) {
	userID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	if req.GetName() == "" {
		return nil, status.Error(codes.InvalidArgument, "name is required")
	}

	exercises := make([]store.WorkoutExerciseInput, 0, len(req.GetExercises()))
	totalSets := 0
	for _, ex := range req.GetExercises() {
		exerciseID, err := store.ParseUUID(ex.GetExerciseId())
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "exercise id invalid: %v", err)
		}
		sets := make([]store.WorkoutSetInput, 0, len(ex.GetSets()))
		for _, set := range ex.GetSets() {
			sets = append(sets, store.WorkoutSetInput{
				Reps:      wrapInt32(set.Reps),
				WeightKG:  wrapFloat64(set.WeightKg),
				RPE:       wrapFloat64(set.Rpe),
				Notes:     set.GetNotes(),
				Completed: set.GetCompleted(),
			})
			totalSets++
		}
		exercises = append(exercises, store.WorkoutExerciseInput{
			ExerciseID: exerciseID,
			Sets:       sets,
		})
	}

	workoutModel := store.BuildWorkoutFromRequest(userID, req.GetName(), req.GetNotes(), exercises)
	workoutID, createdAt, err := s.repo.CreateWorkout(ctx, workoutModel)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "create workout: %v", err)
	}

	eventPayload := map[string]any{
		"workout_id":     workoutID.String(),
		"user_id":        userID.String(),
		"name":           req.GetName(),
		"exercise_count": len(req.GetExercises()),
		"total_sets":     totalSets,
		"notes":          req.GetNotes(),
		"created_at":     createdAt,
	}
	if err := s.repo.RecordWorkoutEvent(ctx, workoutID, userID, store.EventTypeWorkoutCreated, eventPayload); err != nil {
		log.Printf("record workout event: %v", err)
	}

	if s.publisher != nil {
		payload := events.WorkoutCreatedPayload{
			WorkoutID:     workoutID.String(),
			UserID:        userID.String(),
			Name:          req.GetName(),
			ExerciseCount: len(req.GetExercises()),
			TotalSets:     totalSets,
			Notes:         req.GetNotes(),
			CreatedAtUnix: createdAt.Unix(),
		}
		if err := s.publisher.Publish(events.SubjectWorkoutCreated, payload); err != nil {
			log.Printf("publish workout event: %v", err)
		}
	}

	caption := req.GetNotes()
	if strings.TrimSpace(caption) == "" {
		caption = req.GetName()
	}
	if err := s.repo.EnsureFeedPost(ctx, workoutID, userID, caption); err != nil {
		log.Printf("ensure feed post: %v", err)
	}

	return &workoutv1.CreateWorkoutResponse{
		WorkoutId: workoutID.String(),
		CreatedAt: createdAt.Unix(),
	}, nil
}

// UpdateWorkout updates an existing workout.
func (s *WorkoutService) UpdateWorkout(ctx context.Context, req *workoutv1.UpdateWorkoutRequest) (*workoutv1.Workout, error) {
	workoutID, err := store.ParseUUID(req.GetWorkoutId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	userID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	exercises := make([]store.WorkoutExerciseInput, 0, len(req.GetExercises()))
	for _, ex := range req.GetExercises() {
		exerciseID, err := store.ParseUUID(ex.GetExerciseId())
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "exercise id invalid: %v", err)
		}
		sets := make([]store.WorkoutSetInput, 0, len(ex.GetSets()))
		for _, set := range ex.GetSets() {
			sets = append(sets, store.WorkoutSetInput{
				Reps:      wrapInt32(set.Reps),
				WeightKG:  wrapFloat64(set.WeightKg),
				RPE:       wrapFloat64(set.Rpe),
				Notes:     set.GetNotes(),
				Completed: set.GetCompleted(),
			})
		}
		exercises = append(exercises, store.WorkoutExerciseInput{
			ExerciseID: exerciseID,
			Sets:       sets,
		})
	}

	workoutModel := store.BuildWorkoutFromRequest(userID, req.GetName(), req.GetNotes(), exercises)
	if req.GetStartedAt() > 0 {
		workoutModel.StartedAt = store.NullableTime(time.Unix(req.GetStartedAt(), 0))
	}
	if req.GetCompletedAt() > 0 {
		workoutModel.CompletedAt = store.NullableTime(time.Unix(req.GetCompletedAt(), 0))
	}

	if err := s.repo.UpdateWorkout(ctx, workoutID, userID, workoutModel); err != nil {
		if errors.Is(err, store.ErrWorkoutNotFound) {
			return nil, status.Error(codes.NotFound, "workout not found")
		}
		return nil, status.Errorf(codes.Internal, "update workout: %v", err)
	}

	// Fetch the updated workout to return
	updated, err := s.repo.GetWorkout(ctx, workoutID)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "fetch updated workout: %v", err)
	}

	return toProtoWorkout(updated), nil
}

// DeleteWorkout removes a workout.
func (s *WorkoutService) DeleteWorkout(ctx context.Context, req *workoutv1.DeleteWorkoutRequest) (*commonv1.Empty, error) {
	workoutID, err := store.ParseUUID(req.GetWorkoutId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	userID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	if err := s.repo.DeleteWorkout(ctx, workoutID, userID); err != nil {
		if errors.Is(err, store.ErrWorkoutNotFound) {
			return nil, status.Error(codes.NotFound, "workout not found")
		}
		return nil, status.Errorf(codes.Internal, "delete workout: %v", err)
	}

	return &commonv1.Empty{}, nil
}

// GetWorkout returns detailed workout information.
func (s *WorkoutService) GetWorkout(ctx context.Context, req *workoutv1.GetWorkoutRequest) (*workoutv1.GetWorkoutResponse, error) {
	workoutID, err := store.ParseUUID(req.GetWorkoutId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	w, err := s.repo.GetWorkout(ctx, workoutID)
	if err != nil {
		if errors.Is(err, store.ErrWorkoutNotFound) {
			return nil, status.Error(codes.NotFound, "workout not found")
		}
		return nil, status.Errorf(codes.Internal, "get workout: %v", err)
	}

	return &workoutv1.GetWorkoutResponse{Workout: toProtoWorkout(w)}, nil
}

// ListWorkouts returns workouts for a user with opaque cursor pagination.
func (s *WorkoutService) ListWorkouts(ctx context.Context, req *workoutv1.ListWorkoutsRequest) (*workoutv1.ListWorkoutsResponse, error) {
	userID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	cursor := ""
	limit := int32(20)
	if req.GetPagination() != nil {
		cursor = req.GetPagination().GetCursor()
		if req.GetPagination().GetLimit() > 0 {
			limit = req.GetPagination().GetLimit()
		}
	}

	workouts, nextCursor, err := s.repo.ListWorkouts(ctx, userID, limit, cursor)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list workouts: %v", err)
	}

	resp := &workoutv1.ListWorkoutsResponse{}
	for _, w := range workouts {
		resp.Workouts = append(resp.Workouts, toProtoWorkout(w))
	}
	resp.NextCursor = nextCursor
	return resp, nil
}

// ListFeedPosts returns social feed entries with pagination support.
func (s *WorkoutService) ListFeedPosts(ctx context.Context, req *workoutv1.ListFeedPostsRequest) (*workoutv1.ListFeedPostsResponse, error) {
	viewerID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	cursor := ""
	limit := int32(10)
	if req.GetPagination() != nil {
		cursor = req.GetPagination().GetCursor()
		if req.GetPagination().GetLimit() > 0 {
			limit = req.GetPagination().GetLimit()
		}
	}

	posts, nextCursor, err := s.repo.ListFeedPosts(ctx, viewerID, limit, cursor, req.GetDiscover())
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list feed posts: %v", err)
	}

	resp := &workoutv1.ListFeedPostsResponse{NextCursor: nextCursor}
	for _, post := range posts {
		workout, err := s.repo.GetWorkout(ctx, post.WorkoutID)
		if err != nil {
			if errors.Is(err, store.ErrWorkoutNotFound) {
				continue
			}
			return nil, status.Errorf(codes.Internal, "load workout for feed: %v", err)
		}
		resp.Posts = append(resp.Posts, toProtoFeedPost(post, workout))
	}
	return resp, nil
}

// GetFeedPost loads a single feed entry with workout details.
func (s *WorkoutService) GetFeedPost(ctx context.Context, req *workoutv1.GetFeedPostRequest) (*workoutv1.FeedPost, error) {
	postID, err := store.ParseUUID(req.GetPostId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	viewerID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	post, err := s.repo.GetFeedPost(ctx, postID, viewerID)
	if err != nil {
		if errors.Is(err, store.ErrFeedPostNotFound) {
			return nil, status.Error(codes.NotFound, "feed post not found")
		}
		return nil, status.Errorf(codes.Internal, "get feed post: %v", err)
	}

	workout, err := s.repo.GetWorkout(ctx, post.WorkoutID)
	if err != nil {
		if errors.Is(err, store.ErrWorkoutNotFound) {
			return nil, status.Error(codes.NotFound, "workout not found")
		}
		return nil, status.Errorf(codes.Internal, "load workout for feed: %v", err)
	}

	return toProtoFeedPost(post, workout), nil
}

// ToggleFeedLike switches the like state for the viewer.
func (s *WorkoutService) ToggleFeedLike(ctx context.Context, req *workoutv1.ToggleFeedLikeRequest) (*workoutv1.ToggleFeedLikeResponse, error) {
	postID, err := store.ParseUUID(req.GetPostId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	userID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	liked, likesCount, err := s.repo.ToggleFeedLike(ctx, postID, userID)
	if err != nil {
		if errors.Is(err, store.ErrFeedPostNotFound) {
			return nil, status.Error(codes.NotFound, "feed post not found")
		}
		return nil, status.Errorf(codes.Internal, "toggle feed like: %v", err)
	}

	return &workoutv1.ToggleFeedLikeResponse{
		Liked:      liked,
		LikesCount: likesCount,
	}, nil
}

// AddFeedComment persists a new comment and returns it.
func (s *WorkoutService) AddFeedComment(ctx context.Context, req *workoutv1.AddFeedCommentRequest) (*workoutv1.FeedComment, error) {
	postID, err := store.ParseUUID(req.GetPostId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	userID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	body := strings.TrimSpace(req.GetBody())
	if body == "" {
		return nil, status.Error(codes.InvalidArgument, "comment body required")
	}

	comment, err := s.repo.AddFeedComment(ctx, postID, userID, body)
	if err != nil {
		if errors.Is(err, store.ErrFeedPostNotFound) {
			return nil, status.Error(codes.NotFound, "feed post not found")
		}
		return nil, status.Errorf(codes.Internal, "add feed comment: %v", err)
	}
	return toProtoFeedComment(comment), nil
}

// ListFeedComments returns paginated comments for a post.
func (s *WorkoutService) ListFeedComments(ctx context.Context, req *workoutv1.ListFeedCommentsRequest) (*workoutv1.ListFeedCommentsResponse, error) {
	postID, err := store.ParseUUID(req.GetPostId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	cursor := ""
	limit := int32(20)
	if req.GetPagination() != nil {
		cursor = req.GetPagination().GetCursor()
		if req.GetPagination().GetLimit() > 0 {
			limit = req.GetPagination().GetLimit()
		}
	}

	comments, nextCursor, err := s.repo.ListFeedComments(ctx, postID, limit, cursor)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list feed comments: %v", err)
	}

	resp := &workoutv1.ListFeedCommentsResponse{NextCursor: nextCursor}
	for _, comment := range comments {
		resp.Comments = append(resp.Comments, toProtoFeedComment(comment))
	}
	return resp, nil
}

// DeleteFeedComment removes a comment.
func (s *WorkoutService) DeleteFeedComment(ctx context.Context, req *workoutv1.DeleteFeedCommentRequest) (*commonv1.Empty, error) {
	commentID, err := store.ParseUUID(req.GetCommentId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	userID, err := store.ParseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	if err := s.repo.DeleteFeedComment(ctx, commentID, userID); err != nil {
		return nil, status.Errorf(codes.Internal, "delete feed comment: %v", err)
	}

	return &commonv1.Empty{}, nil
}

// StreamWorkout is not yet implemented; this will eventually forward real-time updates from NATS.
func (s *WorkoutService) StreamWorkout(*workoutv1.StreamWorkoutRequest, workoutv1.WorkoutService_StreamWorkoutServer) error {
	return status.Error(codes.Unimplemented, "stream workout not yet available")
}

func toProtoWorkout(w store.Workout) *workoutv1.Workout {
	out := &workoutv1.Workout{
		Id:     w.ID.String(),
		UserId: w.UserID.String(),
		Name:   w.Name,
		Notes:  w.Notes.String,
	}
	if w.StartedAt.Valid {
		out.StartedAt = w.StartedAt.Time.Unix()
	}
	if w.CompletedAt.Valid {
		out.CompletedAt = w.CompletedAt.Time.Unix()
	}

	for _, ex := range w.Exercises {
		protoExercise := &workoutv1.WorkoutExercise{
			ExerciseId: ex.ExerciseID.String(),
			Order:      ex.OrderIndex,
		}
		for _, set := range ex.Sets {
			protoExercise.Sets = append(protoExercise.Sets, &workoutv1.WorkoutSet{
				SetNumber: set.SetNumber,
				Reps:      set.Reps.Int32,
				WeightKg:  set.WeightKG.Float64,
				Rpe:       set.RPE.Float64,
				Notes:     set.Notes.String,
				Completed: set.Completed,
			})
		}
		out.Exercises = append(out.Exercises, protoExercise)
	}
	return out
}

func toProtoFeedPost(post store.FeedPost, workout store.Workout) *workoutv1.FeedPost {
	out := &workoutv1.FeedPost{
		Id:             post.ID.String(),
		WorkoutId:      post.WorkoutID.String(),
		UserId:         post.UserID.String(),
		Caption:        post.Caption.String,
		ImageUrl:       post.ImageURL.String,
		CreatedAt:      post.CreatedAt.Unix(),
		UpdatedAt:      post.UpdatedAt.Unix(),
		LikesCount:     post.LikesCount,
		CommentsCount:  post.CommentsCount,
		LikedByViewer:  post.LikedByViewer,
		SampleLikerIds: post.SampleLikerIDs,
		Workout:        toProtoWorkout(workout),
	}
	return out
}

func toProtoFeedComment(comment store.FeedComment) *workoutv1.FeedComment {
	return &workoutv1.FeedComment{
		Id:        comment.ID.String(),
		PostId:    comment.PostID.String(),
		UserId:    comment.UserID.String(),
		Body:      comment.Body,
		CreatedAt: comment.CreatedAt.Unix(),
	}
}

func wrapInt32(v int32) *int32 {
	if v == 0 {
		return nil
	}
	value := v
	return &value
}

func wrapFloat64(v float64) *float64 {
	if v == 0 {
		return nil
	}
	value := v
	return &value
}

func NullableTime(t time.Time) sql.NullTime {
	return sql.NullTime{Time: t, Valid: !t.IsZero()}
}
