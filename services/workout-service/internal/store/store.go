package store

import (
	"context"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Workout represents a workout aggregate.
type Workout struct {
	ID          uuid.UUID
	UserID      uuid.UUID
	Name        string
	Notes       sql.NullString
	StartedAt   sql.NullTime
	CompletedAt sql.NullTime
	CreatedAt   time.Time
	Exercises   []WorkoutExercise
}

// WorkoutExercise represents an exercise within a workout.
type WorkoutExercise struct {
	ID         uuid.UUID
	ExerciseID uuid.UUID
	OrderIndex int32
	Sets       []WorkoutSet
}

// WorkoutSet captures the details of a single set.
type WorkoutSet struct {
	ID        uuid.UUID
	SetNumber int32
	Reps      sql.NullInt32
	WeightKG  sql.NullFloat64
	RPE       sql.NullFloat64
	Notes     sql.NullString
	Completed bool
}

// FeedPost captures the social metadata for a workout shared in the feed.
type FeedPost struct {
	ID             uuid.UUID
	WorkoutID      uuid.UUID
	UserID         uuid.UUID
	Caption        sql.NullString
	ImageURL       sql.NullString
	CreatedAt      time.Time
	UpdatedAt      time.Time
	LikesCount     int32
	CommentsCount  int32
	LikedByViewer  bool
	SampleLikerIDs []string
}

// FeedComment represents a user comment on a feed post.
type FeedComment struct {
	ID        uuid.UUID
	PostID    uuid.UUID
	UserID    uuid.UUID
	Body      string
	CreatedAt time.Time
}

// Repository wraps persistence access.
type Repository struct {
	pool *pgxpool.Pool
}

// NewRepository returns a Repository instance.
func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

// CreateWorkout persists a workout with nested exercises and sets in a single transaction.
func (r *Repository) CreateWorkout(ctx context.Context, workout Workout) (uuid.UUID, time.Time, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return uuid.Nil, time.Time{}, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	var workoutID uuid.UUID
	var createdAt time.Time
	insertWorkout := `INSERT INTO workouts (user_id, name, notes, started_at, completed_at)
                      VALUES ($1, $2, $3, $4, $5)
                      RETURNING id, created_at;`
	if err := tx.QueryRow(ctx, insertWorkout, workout.UserID, workout.Name, workout.Notes, workout.StartedAt, workout.CompletedAt).
		Scan(&workoutID, &createdAt); err != nil {
		return uuid.Nil, time.Time{}, fmt.Errorf("insert workout: %w", err)
	}

	insertExercise := `INSERT INTO workout_exercises (workout_id, exercise_id, order_index)
                       VALUES ($1, $2, $3)
                       RETURNING id;`
	insertSet := `INSERT INTO workout_sets (workout_exercise_id, set_number, reps, weight_kg, rpe, notes, completed)
                  VALUES ($1, $2, $3, $4, $5, $6, $7);`

	for _, ex := range workout.Exercises {
		var exerciseID uuid.UUID
		if err := tx.QueryRow(ctx, insertExercise, workoutID, ex.ExerciseID, ex.OrderIndex).Scan(&exerciseID); err != nil {
			return uuid.Nil, time.Time{}, fmt.Errorf("insert workout exercise: %w", err)
		}

		for _, set := range ex.Sets {
			if _, err := tx.Exec(ctx, insertSet, exerciseID, set.SetNumber, set.Reps, set.WeightKG, set.RPE, set.Notes, set.Completed); err != nil {
				return uuid.Nil, time.Time{}, fmt.Errorf("insert workout set: %w", err)
			}
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return uuid.Nil, time.Time{}, fmt.Errorf("commit workout: %w", err)
	}

	return workoutID, createdAt, nil
}

// RecordWorkoutEvent writes an immutable event row for downstream consumers.
func (r *Repository) RecordWorkoutEvent(ctx context.Context, workoutID uuid.UUID, userID uuid.UUID, eventType string, payload map[string]any) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshal payload: %w", err)
	}
	const stmt = `INSERT INTO workout_events (workout_id, user_id, event_type, payload)
	              VALUES ($1, $2, $3, $4)`
	if _, err := r.pool.Exec(ctx, stmt, workoutID, userID, eventType, data); err != nil {
		return fmt.Errorf("insert workout event: %w", err)
	}
	return nil
}

// EnsureFeedPost inserts a feed post row for the given workout if it does not already exist.
func (r *Repository) EnsureFeedPost(ctx context.Context, workoutID uuid.UUID, userID uuid.UUID, caption string) error {
	const stmt = `INSERT INTO feed_posts (workout_id, user_id, caption)
	              VALUES ($1, $2, $3)
	              ON CONFLICT (workout_id) DO NOTHING`
	if _, err := r.pool.Exec(ctx, stmt, workoutID, userID, nullableString(caption)); err != nil {
		return fmt.Errorf("ensure feed post: %w", err)
	}
	return nil
}

// GetWorkout fetches a workout aggregate by ID.
func (r *Repository) GetWorkout(ctx context.Context, workoutID uuid.UUID) (Workout, error) {
	query := `SELECT id, user_id, name, notes, started_at, completed_at, created_at
              FROM workouts WHERE id = $1`
	var w Workout
	if err := r.pool.QueryRow(ctx, query, workoutID).
		Scan(&w.ID, &w.UserID, &w.Name, &w.Notes, &w.StartedAt, &w.CompletedAt, &w.CreatedAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Workout{}, ErrWorkoutNotFound
		}
		return Workout{}, fmt.Errorf("select workout: %w", err)
	}

	exercises, err := r.fetchExercises(ctx, workoutID)
	if err != nil {
		return Workout{}, err
	}
	w.Exercises = exercises
	return w, nil
}

// ListWorkouts returns workouts for a user ordered by creation date desc using a simple integer cursor.
func (r *Repository) ListWorkouts(ctx context.Context, userID uuid.UUID, limit int32, cursor string) ([]Workout, string, error) {
	offset := 0
	if cursor != "" {
		decoded, err := base64.URLEncoding.DecodeString(cursor)
		if err != nil {
			return nil, "", fmt.Errorf("decode cursor: %w", err)
		}
		parsed, err := strconv.Atoi(string(decoded))
		if err != nil {
			return nil, "", fmt.Errorf("parse cursor: %w", err)
		}
		offset = parsed
	}

	if limit <= 0 {
		limit = 20
	}

	query := `SELECT id, user_id, name, notes, started_at, completed_at, created_at
              FROM workouts
              WHERE user_id = $1
              ORDER BY created_at DESC
              LIMIT $2 OFFSET $3`

	rows, err := r.pool.Query(ctx, query, userID, limit+1, offset)
	if err != nil {
		return nil, "", fmt.Errorf("list workouts: %w", err)
	}
	defer rows.Close()

	workouts := make([]Workout, 0, limit)
	count := 0
	for rows.Next() {
		if count == int(limit) {
			// we fetched one extra row to know if there is a next page
			offset += count
			return workouts, encodeCursor(offset), nil
		}
		var w Workout
		if err := rows.Scan(&w.ID, &w.UserID, &w.Name, &w.Notes, &w.StartedAt, &w.CompletedAt, &w.CreatedAt); err != nil {
			return nil, "", fmt.Errorf("scan workout: %w", err)
		}
		exercises, err := r.fetchExercises(ctx, w.ID)
		if err != nil {
			return nil, "", err
		}
		w.Exercises = exercises
		workouts = append(workouts, w)
		count++
	}

	if err := rows.Err(); err != nil {
		return nil, "", fmt.Errorf("iterate workouts: %w", err)
	}

	return workouts, "", nil
}

// ListFeedPosts returns social feed entries ordered by recency. When discover is true it excludes the viewer's posts.
func (r *Repository) ListFeedPosts(ctx context.Context, viewerID uuid.UUID, limit int32, cursor string, discover bool) ([]FeedPost, string, error) {
	offset := 0
	if cursor != "" {
		decoded, err := base64.URLEncoding.DecodeString(cursor)
		if err != nil {
			return nil, "", fmt.Errorf("decode cursor: %w", err)
		}
		parsed, err := strconv.Atoi(string(decoded))
		if err != nil {
			return nil, "", fmt.Errorf("parse cursor: %w", err)
		}
		offset = parsed
	}

	if limit <= 0 {
		limit = 10
	}

	const query = `
SELECT fp.id,
       fp.workout_id,
       fp.user_id,
       fp.caption,
       fp.image_url,
       fp.created_at,
       fp.updated_at,
       COALESCE(l.likes_count, 0) AS likes_count,
       COALESCE(c.comments_count, 0) AS comments_count,
       COALESCE(l.sample_likers, '') AS sample_likers,
       CASE
         WHEN EXISTS (
           SELECT 1 FROM feed_likes fl
           WHERE fl.post_id = fp.id AND fl.user_id = $1
         ) THEN TRUE
         ELSE FALSE
       END AS liked_by_viewer
FROM feed_posts fp
LEFT JOIN LATERAL (
  SELECT COUNT(*)::INT AS likes_count,
         COALESCE(string_agg(user_id::text, ',' ORDER BY created_at DESC LIMIT 3), '') AS sample_likers
  FROM feed_likes
  WHERE post_id = fp.id
) l ON TRUE
LEFT JOIN LATERAL (
  SELECT COUNT(*)::INT AS comments_count
  FROM feed_comments
  WHERE post_id = fp.id
) c ON TRUE
WHERE ($2 = FALSE) OR ($2 = TRUE AND fp.user_id <> $1)
ORDER BY fp.created_at DESC
LIMIT $3 OFFSET $4;
`

	rows, err := r.pool.Query(ctx, query, viewerID, discover, limit+1, offset)
	if err != nil {
		return nil, "", fmt.Errorf("list feed posts: %w", err)
	}
	defer rows.Close()

	posts := make([]FeedPost, 0, limit)
	count := 0
	for rows.Next() {
		if count == int(limit) {
			offset += count
			return posts, encodeCursor(offset), nil
		}
		var post FeedPost
		var sampleLikers sql.NullString
		if err := rows.Scan(
			&post.ID,
			&post.WorkoutID,
			&post.UserID,
			&post.Caption,
			&post.ImageURL,
			&post.CreatedAt,
			&post.UpdatedAt,
			&post.LikesCount,
			&post.CommentsCount,
			&sampleLikers,
			&post.LikedByViewer,
		); err != nil {
			return nil, "", fmt.Errorf("scan feed post: %w", err)
		}
		if sampleLikers.Valid && sampleLikers.String != "" {
			post.SampleLikerIDs = strings.Split(sampleLikers.String, ",")
		}
		posts = append(posts, post)
		count++
	}

	if err := rows.Err(); err != nil {
		return nil, "", fmt.Errorf("iterate feed posts: %w", err)
	}

	return posts, "", nil
}

// GetFeedPost fetches a single feed post for the viewer.
func (r *Repository) GetFeedPost(ctx context.Context, postID uuid.UUID, viewerID uuid.UUID) (FeedPost, error) {
	const query = `
SELECT fp.id,
       fp.workout_id,
       fp.user_id,
       fp.caption,
       fp.image_url,
       fp.created_at,
       fp.updated_at,
       COALESCE(l.likes_count, 0) AS likes_count,
       COALESCE(c.comments_count, 0) AS comments_count,
       COALESCE(l.sample_likers, '') AS sample_likers,
       CASE
         WHEN EXISTS (
           SELECT 1 FROM feed_likes fl
           WHERE fl.post_id = fp.id AND fl.user_id = $2
         ) THEN TRUE
         ELSE FALSE
       END AS liked_by_viewer
FROM feed_posts fp
LEFT JOIN LATERAL (
  SELECT COUNT(*)::INT AS likes_count,
         COALESCE(string_agg(user_id::text, ',' ORDER BY created_at DESC LIMIT 3), '') AS sample_likers
  FROM feed_likes
  WHERE post_id = fp.id
) l ON TRUE
LEFT JOIN LATERAL (
  SELECT COUNT(*)::INT AS comments_count
  FROM feed_comments
  WHERE post_id = fp.id
) c ON TRUE
WHERE fp.id = $1
LIMIT 1;`

	var post FeedPost
	var sampleLikers sql.NullString
	if err := r.pool.QueryRow(ctx, query, postID, viewerID).Scan(
		&post.ID,
		&post.WorkoutID,
		&post.UserID,
		&post.Caption,
		&post.ImageURL,
		&post.CreatedAt,
		&post.UpdatedAt,
		&post.LikesCount,
		&post.CommentsCount,
		&sampleLikers,
		&post.LikedByViewer,
	); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return FeedPost{}, ErrFeedPostNotFound
		}
		return FeedPost{}, fmt.Errorf("get feed post: %w", err)
	}
	if sampleLikers.Valid && sampleLikers.String != "" {
		post.SampleLikerIDs = strings.Split(sampleLikers.String, ",")
	}
	return post, nil
}

func (r *Repository) fetchExercises(ctx context.Context, workoutID uuid.UUID) ([]WorkoutExercise, error) {
	query := `SELECT id, exercise_id, order_index
              FROM workout_exercises
              WHERE workout_id = $1
              ORDER BY order_index ASC`
	rows, err := r.pool.Query(ctx, query, workoutID)
	if err != nil {
		return nil, fmt.Errorf("list exercises: %w", err)
	}
	defer rows.Close()

	var exercises []WorkoutExercise
	for rows.Next() {
		var ex WorkoutExercise
		if err := rows.Scan(&ex.ID, &ex.ExerciseID, &ex.OrderIndex); err != nil {
			return nil, fmt.Errorf("scan exercise: %w", err)
		}
		sets, err := r.fetchSets(ctx, ex.ID)
		if err != nil {
			return nil, err
		}
		ex.Sets = sets
		exercises = append(exercises, ex)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate exercises: %w", err)
	}
	return exercises, nil
}

// ToggleFeedLike adds or removes a like for the viewer and returns the new aggregate state.
func (r *Repository) ToggleFeedLike(ctx context.Context, postID uuid.UUID, userID uuid.UUID) (bool, int32, error) {
	if err := r.ensureFeedPostExists(ctx, postID); err != nil {
		return false, 0, err
	}

	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return false, 0, fmt.Errorf("begin like tx: %w", err)
	}
	defer tx.Rollback(ctx)

	const insert = `INSERT INTO feed_likes (post_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`
	tag, err := tx.Exec(ctx, insert, postID, userID)
	if err != nil {
		return false, 0, fmt.Errorf("insert feed like: %w", err)
	}

	liked := tag.RowsAffected() > 0
	if !liked {
		if _, err := tx.Exec(ctx, `DELETE FROM feed_likes WHERE post_id = $1 AND user_id = $2`, postID, userID); err != nil {
			return false, 0, fmt.Errorf("delete feed like: %w", err)
		}
	}

	var likeCount int32
	if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM feed_likes WHERE post_id = $1`, postID).Scan(&likeCount); err != nil {
		return false, 0, fmt.Errorf("count feed likes: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return false, 0, fmt.Errorf("commit like tx: %w", err)
	}

	return liked, likeCount, nil
}

// AddFeedComment records a comment on the specified post.
func (r *Repository) AddFeedComment(ctx context.Context, postID uuid.UUID, userID uuid.UUID, body string) (FeedComment, error) {
	if err := r.ensureFeedPostExists(ctx, postID); err != nil {
		return FeedComment{}, err
	}

	const stmt = `INSERT INTO feed_comments (post_id, user_id, body)
	              VALUES ($1, $2, $3)
	              RETURNING id, created_at`
	var comment FeedComment
	comment.PostID = postID
	comment.UserID = userID
	comment.Body = body
	if err := r.pool.QueryRow(ctx, stmt, postID, userID, body).
		Scan(&comment.ID, &comment.CreatedAt); err != nil {
		return FeedComment{}, fmt.Errorf("insert feed comment: %w", err)
	}
	return comment, nil
}

// ListFeedComments retrieves comments for a post ordered by recency.
func (r *Repository) ListFeedComments(ctx context.Context, postID uuid.UUID, limit int32, cursor string) ([]FeedComment, string, error) {
	offset := 0
	if cursor != "" {
		decoded, err := base64.URLEncoding.DecodeString(cursor)
		if err != nil {
			return nil, "", fmt.Errorf("decode cursor: %w", err)
		}
		parsed, err := strconv.Atoi(string(decoded))
		if err != nil {
			return nil, "", fmt.Errorf("parse cursor: %w", err)
		}
		offset = parsed
	}

	if limit <= 0 {
		limit = 20
	}

	const stmt = `SELECT id, post_id, user_id, body, created_at
	              FROM feed_comments
	              WHERE post_id = $1
	              ORDER BY created_at DESC
	              LIMIT $2 OFFSET $3`
	rows, err := r.pool.Query(ctx, stmt, postID, limit+1, offset)
	if err != nil {
		return nil, "", fmt.Errorf("list feed comments: %w", err)
	}
	defer rows.Close()

	var comments []FeedComment
	count := 0
	for rows.Next() {
		if count == int(limit) {
			offset += count
			return comments, encodeCursor(offset), nil
		}
		var comment FeedComment
		if err := rows.Scan(&comment.ID, &comment.PostID, &comment.UserID, &comment.Body, &comment.CreatedAt); err != nil {
			return nil, "", fmt.Errorf("scan feed comment: %w", err)
		}
		comments = append(comments, comment)
		count++
	}
	if err := rows.Err(); err != nil {
		return nil, "", fmt.Errorf("iterate feed comments: %w", err)
	}
	return comments, "", nil
}

func (r *Repository) ensureFeedPostExists(ctx context.Context, postID uuid.UUID) error {
	const stmt = `SELECT 1 FROM feed_posts WHERE id = $1`
	var exists int
	if err := r.pool.QueryRow(ctx, stmt, postID).Scan(&exists); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return ErrFeedPostNotFound
		}
		return fmt.Errorf("check feed post: %w", err)
	}
	return nil
}

func (r *Repository) fetchSets(ctx context.Context, workoutExerciseID uuid.UUID) ([]WorkoutSet, error) {
	query := `SELECT id, set_number, reps, weight_kg, rpe, notes, completed
              FROM workout_sets
              WHERE workout_exercise_id = $1
              ORDER BY set_number ASC`
	rows, err := r.pool.Query(ctx, query, workoutExerciseID)
	if err != nil {
		return nil, fmt.Errorf("list sets: %w", err)
	}
	defer rows.Close()

	var sets []WorkoutSet
	for rows.Next() {
		var set WorkoutSet
		if err := rows.Scan(&set.ID, &set.SetNumber, &set.Reps, &set.WeightKG, &set.RPE, &set.Notes, &set.Completed); err != nil {
			return nil, fmt.Errorf("scan set: %w", err)
		}
		sets = append(sets, set)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate sets: %w", err)
	}
	return sets, nil
}

// ErrWorkoutNotFound is returned when a workout cannot be located.
var ErrWorkoutNotFound = errors.New("workout not found")

// ErrFeedPostNotFound is returned when a feed post is missing.
var ErrFeedPostNotFound = errors.New("feed post not found")

// Domain event types persisted in workout_events.
const (
	EventTypeWorkoutCreated = "workout.created"
)

func encodeCursor(offset int) string {
	return base64.URLEncoding.EncodeToString([]byte(strconv.Itoa(offset)))
}

// DecodeCursor exposes cursor decoding for service layer validation.
func DecodeCursor(cursor string) (int, error) {
	if cursor == "" {
		return 0, nil
	}
	decoded, err := base64.URLEncoding.DecodeString(cursor)
	if err != nil {
		return 0, err
	}
	return strconv.Atoi(string(decoded))
}

// WorkoutExerciseInput is a helper struct used to translate from protobuf -> repository models.
type WorkoutExerciseInput struct {
	ExerciseID uuid.UUID
	Sets       []WorkoutSetInput
}

// WorkoutSetInput helper for nested conversion.
type WorkoutSetInput struct {
	Reps      *int32
	WeightKG  *float64
	RPE       *float64
	Notes     string
	Completed bool
}

// BuildWorkoutFromRequest converts wire types to repository models.
func BuildWorkoutFromRequest(userID uuid.UUID, name string, notes string, exercises []WorkoutExerciseInput) Workout {
	w := Workout{
		UserID: userID,
		Name:   name,
		Notes:  nullableString(notes),
	}

	for idx, ex := range exercises {
		workoutExercise := WorkoutExercise{
			ExerciseID: ex.ExerciseID,
			OrderIndex: int32(idx + 1),
		}

		for setIdx, set := range ex.Sets {
			workoutExercise.Sets = append(workoutExercise.Sets, WorkoutSet{
				SetNumber: int32(setIdx + 1),
				Reps:      nullableInt(set.Reps),
				WeightKG:  nullableFloat(set.WeightKG),
				RPE:       nullableFloat(set.RPE),
				Notes:     nullableString(set.Notes),
				Completed: set.Completed,
			})
		}

		w.Exercises = append(w.Exercises, workoutExercise)
	}

	return w
}

func nullableString(val string) sql.NullString {
	return sql.NullString{String: val, Valid: val != ""}
}

func nullableInt(val *int32) sql.NullInt32 {
	if val == nil {
		return sql.NullInt32{}
	}
	return sql.NullInt32{Int32: *val, Valid: true}
}

func nullableFloat(val *float64) sql.NullFloat64 {
	if val == nil {
		return sql.NullFloat64{}
	}
	return sql.NullFloat64{Float64: *val, Valid: true}
}

// ParseUUID validates UUID strings with clearer errors.
func ParseUUID(value string) (uuid.UUID, error) {
	id, err := uuid.Parse(strings.TrimSpace(value))
	if err != nil {
		return uuid.Nil, fmt.Errorf("invalid UUID %q: %w", value, err)
	}
	return id, nil
}
