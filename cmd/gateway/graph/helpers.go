package graph

import (
	"context"
	"sort"
	"time"

	"github.com/zenx/backend/cmd/gateway/graph/model"
	analyticsv1 "github.com/zenx/backend/proto/analytics/v1"
	commonv1 "github.com/zenx/backend/proto/common/v1"
	exercisev1 "github.com/zenx/backend/proto/exercise/v1"
	notificationv1 "github.com/zenx/backend/proto/notification/v1"
	profilev1 "github.com/zenx/backend/proto/profile/v1"
	workoutv1 "github.com/zenx/backend/proto/workout/v1"
)

func convertWorkout(w *workoutv1.Workout) *model.Workout {
	if w == nil {
		return nil
	}
	workout := &model.Workout{
		ID:     w.GetId(),
		UserID: w.GetUserId(),
		Name:   w.GetName(),
		Notes:  nullableString(w.GetNotes()),
	}
	if ts := formatUnix(w.GetStartedAt()); ts != "" {
		workout.StartedAt = nullableString(ts)
	}
	if ts := formatUnix(w.GetCompletedAt()); ts != "" {
		workout.CompletedAt = nullableString(ts)
	}
	for _, ex := range w.GetExercises() {
		workoutExercise := &model.WorkoutExercise{
			ExerciseID: ex.GetExerciseId(),
			Order:      int(ex.GetOrder()),
		}
		for _, set := range ex.GetSets() {
			workoutExercise.Sets = append(workoutExercise.Sets, &model.WorkoutSet{
				SetNumber: int(set.GetSetNumber()),
				Reps:      nullableInt(set.GetReps()),
				WeightKg:  nullableFloat(set.GetWeightKg()),
				Rpe:       nullableFloat(set.GetRpe()),
				Completed: nullableBool(set.GetCompleted()),
			})
		}
		workout.Exercises = append(workout.Exercises, workoutExercise)
	}
	return workout
}

func convertProfile(p *profilev1.Profile) *model.Profile {
	if p == nil {
		return nil
	}
	return &model.Profile{
		ID:          p.GetId(),
		DisplayName: nullableString(p.GetDisplayName()),
		Bio:         nullableString(p.GetBio()),
		AvatarURL:   nullableString(p.GetAvatarUrl()),
		DateOfBirth: nullableString(p.GetDateOfBirth()),
		Gender:      nullableString(p.GetGender()),
	}
}

func convertMeasurement(m *profilev1.Measurement) *model.Measurement {
	if m == nil {
		return nil
	}
	return &model.Measurement{
		ID:                m.GetId(),
		UserID:            m.GetUserId(),
		MeasurementDate:   m.GetMeasurementDate(),
		WeightKg:          nullableFloat(m.GetWeightKg()),
		BodyFatPercentage: nullableFloat(m.GetBodyFatPercentage()),
		MuscleMassKg:      nullableFloat(m.GetMuscleMassKg()),
		MeasurementsJSON:  nullableString(m.GetMeasurementsJson()),
	}
}

func extractDisplayName(p *model.Profile) *string {
	if p == nil {
		return nil
	}
	return p.DisplayName
}

func nullableString(value string) *string {
	if value == "" {
		return nil
	}
	v := value
	return &v
}

func nullableFloat(value float64) *float64 {
	if value == 0 {
		return nil
	}
	v := value
	return &v
}

func nullableInt(value int32) *int {
	if value == 0 {
		return nil
	}
	v := int(value)
	return &v
}

func nullableBool(value bool) *bool {
	return &value
}

func getStringValue(ptr *string) string {
	if ptr == nil {
		return ""
	}
	return *ptr
}

func getFloatValue(ptr *float64) float64 {
	if ptr == nil {
		return 0
	}
	return *ptr
}

func getIntValue(ptr *int) int {
	if ptr == nil {
		return 0
	}
	return *ptr
}

func getBoolValue(ptr *bool) bool {
	if ptr == nil {
		return false
	}
	return *ptr
}

func parseDate(value string) (time.Time, error) {
	return time.Parse("2006-01-02", value)
}

func formatUnix(ts int64) string {
	if ts == 0 {
		return ""
	}
	return time.Unix(ts, 0).UTC().Format(time.RFC3339)
}

func buildTimestampRange(input *model.MeasurementRangeInput) (*commonv1.TimestampRange, error) {
	if input == nil {
		return nil, nil
	}

	var startUnix, endUnix int64
	if input.Start != nil && *input.Start != "" {
		start, err := time.Parse(time.RFC3339, *input.Start)
		if err != nil {
			return nil, err
		}
		startUnix = start.Unix()
	}
	if input.End != nil && *input.End != "" {
		end, err := time.Parse(time.RFC3339, *input.End)
		if err != nil {
			return nil, err
		}
		endUnix = end.Unix()
	}
	if startUnix == 0 && endUnix == 0 {
		return nil, nil
	}
	return &commonv1.TimestampRange{Start: startUnix, End: endUnix}, nil
}

func convertFeedPost(post *workoutv1.FeedPost, profile *profilev1.Profile) *model.FeedPost {
	if post == nil {
		return nil
	}
	return &model.FeedPost{
		ID:             post.GetId(),
		WorkoutID:      post.GetWorkoutId(),
		UserID:         post.GetUserId(),
		Caption:        nullableString(post.GetCaption()),
		ImageURL:       nullableString(post.GetImageUrl()),
		CreatedAt:      formatUnix(post.GetCreatedAt()),
		UpdatedAt:      formatUnix(post.GetUpdatedAt()),
		LikesCount:     int(post.GetLikesCount()),
		CommentsCount:  int(post.GetCommentsCount()),
		IsLiked:        post.GetLikedByViewer(),
		LikedByUserIds: post.GetSampleLikerIds(),
		Workout:        convertWorkout(post.GetWorkout()),
		AuthorProfile:  convertProfile(profile),
	}
}

func convertFeedComment(comment *workoutv1.FeedComment, profile *profilev1.Profile) *model.PostComment {
	if comment == nil {
		return nil
	}
	return &model.PostComment{
		ID:            comment.GetId(),
		PostID:        comment.GetPostId(),
		UserID:        comment.GetUserId(),
		Body:          comment.GetBody(),
		CreatedAt:     formatUnix(comment.GetCreatedAt()),
		AuthorProfile: convertProfile(profile),
	}
}

func convertNotification(n *notificationv1.Notification) *model.Notification {
	if n == nil {
		return nil
	}
	notif := &model.Notification{
		ID:        n.GetId(),
		Template:  nullableString(n.GetTemplate()),
		Data:      convertNotificationData(n.GetData()),
		Status:    nullableString(n.GetStatus()),
		CreatedAt: formatUnix(n.GetCreatedAt()),
	}
	if n.GetScheduledFor() > 0 {
		notif.ScheduledFor = nullableString(formatUnix(n.GetScheduledFor()))
	}
	if n.GetSentAt() > 0 {
		notif.SentAt = nullableString(formatUnix(n.GetSentAt()))
	}
	return notif
}

func convertNotificationData(entries map[string]string) []*model.NotificationDatum {
	if len(entries) == 0 {
		return nil
	}
	keys := make([]string, 0, len(entries))
	for k := range entries {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	var result []*model.NotificationDatum
	for _, key := range keys {
		result = append(result, &model.NotificationDatum{
			Key:   key,
			Value: entries[key],
		})
	}
	return result
}

func buildPagination(limit *int, cursor *string) *commonv1.Pagination {
	if limit == nil && cursor == nil {
		return nil
	}
	pagination := &commonv1.Pagination{}
	if limit != nil {
		pagination.Limit = int32(*limit)
	}
	if cursor != nil {
		pagination.Cursor = *cursor
	}
	return pagination
}

func (r *Resolver) fetchProfiles(ctx context.Context, ids []string) (map[string]*profilev1.Profile, error) {
	unique := make(map[string]struct{})
	for _, id := range ids {
		if id == "" {
			continue
		}
		unique[id] = struct{}{}
	}

	result := make(map[string]*profilev1.Profile, len(unique))
	for id := range unique {
		resp, err := r.ProfileClient.GetProfile(ctx, &profilev1.GetProfileRequest{UserId: id})
		if err != nil {
			return nil, err
		}
		result[id] = resp.GetProfile()
	}
	return result, nil
}

func (r *Resolver) fetchExercises(ctx context.Context, ids []string) (map[string]*exercisev1.Exercise, error) {
	unique := make(map[string]struct{})
	for _, id := range ids {
		if id == "" {
			continue
		}
		unique[id] = struct{}{}
	}
	result := make(map[string]*exercisev1.Exercise, len(unique))
	for id := range unique {
		resp, err := r.ExerciseClient.GetExercise(ctx, &exercisev1.GetExerciseRequest{ExerciseId: id})
		if err != nil {
			return nil, err
		}
		result[id] = resp
	}
	return result, nil
}

func convertPersonalRecord(pr *analyticsv1.PersonalRecord, exercise *model.Exercise) *model.PersonalRecord {
	if pr == nil {
		return nil
	}
	return &model.PersonalRecord{
		ExerciseID: pr.GetExerciseId(),
		RecordType: pr.GetRecordType(),
		Value:      pr.GetValue(),
		AchievedAt: formatUnix(pr.GetAchievedAt()),
		Exercise:   exercise,
	}
}

func convertExerciseProto(ex *exercisev1.Exercise) *model.Exercise {
	if ex == nil {
		return nil
	}
	return &model.Exercise{
		ID:          ex.GetId(),
		Name:        ex.GetName(),
		Description: nullableString(ex.GetDescription()),
		Category:    nullableString(ex.GetCategory()),
	}
}

func collectRecordExerciseIDs(records []*analyticsv1.PersonalRecord) []string {
	ids := make([]string, 0, len(records))
	for _, rec := range records {
		if rec == nil || rec.GetExerciseId() == "" {
			continue
		}
		ids = append(ids, rec.GetExerciseId())
	}
	return ids
}
