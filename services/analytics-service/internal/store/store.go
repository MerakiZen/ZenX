package store

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Snapshot represents aggregated progress data.
type Snapshot struct {
	UserID        uuid.UUID
	CapturedAt    time.Time
	TotalVolumeKg float64
	AverageRPE    float64
	WorkoutCount  int32
	Records       []PersonalRecord
}

// PersonalRecord describes a user PR.
type PersonalRecord struct {
	ExerciseID uuid.UUID
	RecordType string
	Value      float64
	AchievedAt time.Time
}

// Repository provides DB helpers.
type Repository struct {
	pool *pgxpool.Pool
}

// NewRepository creates a Repository.
func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

// GetLatestSnapshot fetches the most recent snapshot for a user.
func (r *Repository) GetLatestSnapshot(ctx context.Context, userID uuid.UUID) (Snapshot, error) {
	query := `SELECT user_id, captured_at, COALESCE(total_volume_kg,0), COALESCE(average_rpe,0), COALESCE(workout_count,0)
			  FROM progress_snapshots
			  WHERE user_id = $1
			  ORDER BY captured_at DESC
			  LIMIT 1`

	var snap Snapshot
	if err := r.pool.QueryRow(ctx, query, userID).Scan(&snap.UserID, &snap.CapturedAt, &snap.TotalVolumeKg, &snap.AverageRPE, &snap.WorkoutCount); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Snapshot{}, ErrNotFound
		}
		return Snapshot{}, fmt.Errorf("select snapshot: %w", err)
	}

	records, err := r.ListPersonalRecords(ctx, userID)
	if err != nil {
		return Snapshot{}, err
	}
	snap.Records = records
	return snap, nil
}

// ListPersonalRecords returns PRs for a user.
func (r *Repository) ListPersonalRecords(ctx context.Context, userID uuid.UUID) ([]PersonalRecord, error) {
	query := `SELECT exercise_id, record_type, value, achieved_at
			  FROM personal_records
			  WHERE user_id = $1
			  ORDER BY achieved_at DESC
			  LIMIT 200`

	rows, err := r.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("list personal records: %w", err)
	}
	defer rows.Close()

	var records []PersonalRecord
	for rows.Next() {
		var rec PersonalRecord
		if err := rows.Scan(&rec.ExerciseID, &rec.RecordType, &rec.Value, &rec.AchievedAt); err != nil {
			return nil, fmt.Errorf("scan personal record: %w", err)
		}
		records = append(records, rec)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate personal records: %w", err)
	}

	return records, nil
}

// MuscleGroupStat represents aggregated muscle data.
type MuscleGroupStat struct {
	MuscleGroup string
	SetCount    int
	Volume      float64
}

// GetMuscleGroupStats returns set count and volume per muscle group.
func (r *Repository) GetMuscleGroupStats(ctx context.Context, userID uuid.UUID, start, end time.Time) ([]MuscleGroupStat, error) {
	query := `SELECT e.primary_muscle_group, COUNT(we.id) as set_count, COALESCE(SUM(s.weight_kg * s.reps), 0) as volume
			  FROM workout_exercises we
			  JOIN exercises e ON we.exercise_id = e.id
			  JOIN sets s ON s.workout_exercise_id = we.id
			  JOIN workouts w ON we.workout_id = w.id
			  WHERE w.user_id = $1 AND w.created_at >= $2 AND w.created_at <= $3
			  GROUP BY e.primary_muscle_group`

	rows, err := r.pool.Query(ctx, query, userID, start, end)
	if err != nil {
		return nil, fmt.Errorf("get muscle stats: %w", err)
	}
	defer rows.Close()

	var stats []MuscleGroupStat
	for rows.Next() {
		var s MuscleGroupStat
		if err := rows.Scan(&s.MuscleGroup, &s.SetCount, &s.Volume); err != nil {
			return nil, fmt.Errorf("scan muscle stat: %w", err)
		}
		stats = append(stats, s)
	}
	return stats, nil
}

// GetWorkoutCalendar returns days with workouts.
func (r *Repository) GetWorkoutCalendar(ctx context.Context, userID uuid.UUID, start, end time.Time) ([]time.Time, error) {
	query := `SELECT DISTINCT DATE(created_at)
			  FROM workouts
			  WHERE user_id = $1 AND created_at >= $2 AND created_at <= $3
			  ORDER BY DATE(created_at)`

	rows, err := r.pool.Query(ctx, query, userID, start, end)
	if err != nil {
		return nil, fmt.Errorf("get workout calendar: %w", err)
	}
	defer rows.Close()

	var days []time.Time
	for rows.Next() {
		var d time.Time
		if err := rows.Scan(&d); err != nil {
			return nil, fmt.Errorf("scan calendar day: %w", err)
		}
		days = append(days, d)
	}
	return days, nil
}

// ExerciseRecord represents a top exercise.
type ExerciseRecord struct {
	ExerciseID    uuid.UUID
	ExerciseName  string
	WorkoutCount  int
	LastPerformed time.Time
}

// GetTopExercises returns most frequent exercises.
func (r *Repository) GetTopExercises(ctx context.Context, userID uuid.UUID, limit int, start, end time.Time) ([]ExerciseRecord, error) {
	query := `SELECT e.id, e.name, COUNT(DISTINCT we.workout_id) as workout_count, MAX(w.created_at) as last_performed
			  FROM workout_exercises we
			  JOIN exercises e ON we.exercise_id = e.id
			  JOIN workouts w ON we.workout_id = w.id
			  WHERE w.user_id = $1 AND w.created_at >= $2 AND w.created_at <= $3
			  GROUP BY e.id, e.name
			  ORDER BY workout_count DESC
			  LIMIT $4`

	rows, err := r.pool.Query(ctx, query, userID, start, end, limit)
	if err != nil {
		return nil, fmt.Errorf("get top exercises: %w", err)
	}
	defer rows.Close()

	var exercises []ExerciseRecord
	for rows.Next() {
		var e ExerciseRecord
		if err := rows.Scan(&e.ExerciseID, &e.ExerciseName, &e.WorkoutCount, &e.LastPerformed); err != nil {
			return nil, fmt.Errorf("scan top exercise: %w", err)
		}
		exercises = append(exercises, e)
	}
	return exercises, nil
}

// ExercisePerformanceStats holds aggregated stats for an exercise.
type ExercisePerformanceStats struct {
	HeaviestWeight    float64
	ProjectedOneRM    float64
	BestSetVolume     float64
	BestSessionVolume float64
	MostReps          int
}

// WorkoutExerciseEntry represents a single workout's performance for an exercise.
type WorkoutExerciseEntry struct {
	WorkoutID uuid.UUID
	Date      time.Time
	Weight    float64
	Reps      int
	OneRM     float64
	Volume    float64
}

// GetExerciseStats returns performance stats and history for an exercise.
func (r *Repository) GetExerciseStats(ctx context.Context, userID uuid.UUID, exerciseID uuid.UUID) (ExercisePerformanceStats, []WorkoutExerciseEntry, error) {
	// 1. Get History
	historyQuery := `
		SELECT w.id, w.created_at, s.weight_kg, s.reps
		FROM sets s
		JOIN workout_exercises we ON s.workout_exercise_id = we.id
		JOIN workouts w ON we.workout_id = w.id
		WHERE w.user_id = $1 AND we.exercise_id = $2
		ORDER BY w.created_at ASC
	`
	rows, err := r.pool.Query(ctx, historyQuery, userID, exerciseID)
	if err != nil {
		return ExercisePerformanceStats{}, nil, fmt.Errorf("get exercise history: %w", err)
	}
	defer rows.Close()

	var history []WorkoutExerciseEntry
	var stats ExercisePerformanceStats

	// Helper to calculate 1RM (Brzycki)
	calcOneRM := func(weight float64, reps int) float64 {
		if reps == 0 {
			return 0
		}
		if reps == 1 {
			return weight
		}
		return weight / (1.0278 - 0.0278*float64(reps))
	}

	// We need to aggregate by workout for session volume
	sessionVolumes := make(map[uuid.UUID]float64)

	for rows.Next() {
		var wID uuid.UUID
		var date time.Time
		var weight float64
		var reps int
		if err := rows.Scan(&wID, &date, &weight, &reps); err != nil {
			return ExercisePerformanceStats{}, nil, fmt.Errorf("scan history: %w", err)
		}

		vol := weight * float64(reps)
		oneRM := calcOneRM(weight, reps)

		// Update stats
		if weight > stats.HeaviestWeight {
			stats.HeaviestWeight = weight
		}
		if oneRM > stats.ProjectedOneRM {
			stats.ProjectedOneRM = oneRM
		}
		if vol > stats.BestSetVolume {
			stats.BestSetVolume = vol
		}
		if reps > stats.MostReps {
			stats.MostReps = reps
		}

		sessionVolumes[wID] += vol

		history = append(history, WorkoutExerciseEntry{
			WorkoutID: wID,
			Date:      date,
			Weight:    weight,
			Reps:      reps,
			OneRM:     oneRM,
			Volume:    vol,
		})
	}

	for _, vol := range sessionVolumes {
		if vol > stats.BestSessionVolume {
			stats.BestSessionVolume = vol
		}
	}

	return stats, history, nil
}

// EnqueueJob records a recalculation job (currently a stub for workers).
func (r *Repository) EnqueueJob(ctx context.Context, userID uuid.UUID, workoutID *uuid.UUID) (uuid.UUID, error) {
	query := `INSERT INTO analytics_jobs (user_id, workout_id)
			  VALUES ($1, $2)
			  RETURNING id`

	var jobID uuid.UUID
	if err := r.pool.QueryRow(ctx, query, userID, workoutID).Scan(&jobID); err != nil {
		return uuid.Nil, fmt.Errorf("insert analytics job: %w", err)
	}
	return jobID, nil
}

// ErrNotFound indicates missing data.
var ErrNotFound = errors.New("not found")

// InsertSnapshot persists a new snapshot row.
func (r *Repository) InsertSnapshot(ctx context.Context, snap Snapshot) error {
	const stmt = `INSERT INTO progress_snapshots (user_id, captured_at, total_volume_kg, average_rpe, workout_count)
				  VALUES ($1, $2, $3, $4, $5)`
	if _, err := r.pool.Exec(ctx, stmt, snap.UserID, snap.CapturedAt, snap.TotalVolumeKg, snap.AverageRPE, snap.WorkoutCount); err != nil {
		return fmt.Errorf("insert snapshot: %w", err)
	}
	return nil
}

// ReplacePersonalRecords updates the stored PRs for a user in a transaction.
func (r *Repository) ReplacePersonalRecords(ctx context.Context, userID uuid.UUID, records []PersonalRecord) error {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin replace prs: %w", err)
	}
	defer tx.Rollback(ctx)

	if _, err := tx.Exec(ctx, `DELETE FROM personal_records WHERE user_id = $1`, userID); err != nil {
		return fmt.Errorf("delete prs: %w", err)
	}

	const insert = `INSERT INTO personal_records (user_id, exercise_id, record_type, value, achieved_at)
					VALUES ($1, $2, $3, $4, $5)`
	for _, rec := range records {
		if _, err := tx.Exec(ctx, insert, userID, rec.ExerciseID, rec.RecordType, rec.Value, rec.AchievedAt); err != nil {
			return fmt.Errorf("insert pr: %w", err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit prs: %w", err)
	}
	return nil
}
