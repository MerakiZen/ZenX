package store

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Exercise represents a row in the exercises table.
type Exercise struct {
	ID                   uuid.UUID
	Name                 string
	Description          string
	CategoryID           *uuid.UUID
	PrimaryMuscleGroup   string
	SecondaryMuscleGroup []string
	EquipmentRequired    string
	DifficultyLevel      string
	IsCustom             bool
	CreatedBy            *uuid.UUID
	CreatedAt            time.Time
	UpdatedAt            time.Time
}

// Repository provides DB access helpers.
type Repository struct {
	pool *pgxpool.Pool
}

// NewRepository returns a Repository.
func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

// CreateExercise persists a new exercise.
func (r *Repository) CreateExercise(ctx context.Context, input Exercise) (Exercise, error) {
	query := `INSERT INTO exercises (
		name, description, category_id, primary_muscle_group,
		secondary_muscle_groups, equipment_required, difficulty_level,
		is_custom, created_by)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		RETURNING id, created_at, updated_at;`

	var ex Exercise
	if err := r.pool.QueryRow(ctx, query,
		input.Name,
		input.Description,
		input.CategoryID,
		input.PrimaryMuscleGroup,
		input.SecondaryMuscleGroup,
		input.EquipmentRequired,
		input.DifficultyLevel,
		input.IsCustom,
		input.CreatedBy,
	).Scan(&ex.ID, &ex.CreatedAt, &ex.UpdatedAt); err != nil {
		return Exercise{}, fmt.Errorf("insert exercise: %w", err)
	}

	ex.Name = input.Name
	ex.Description = input.Description
	ex.CategoryID = input.CategoryID
	ex.PrimaryMuscleGroup = input.PrimaryMuscleGroup
	ex.SecondaryMuscleGroup = input.SecondaryMuscleGroup
	ex.EquipmentRequired = input.EquipmentRequired
	ex.DifficultyLevel = input.DifficultyLevel
	ex.IsCustom = input.IsCustom
	ex.CreatedBy = input.CreatedBy
	return ex, nil
}

// UpdateExercise updates an existing exercise.
func (r *Repository) UpdateExercise(ctx context.Context, id uuid.UUID, input Exercise) (Exercise, error) {
	query := `UPDATE exercises SET
		name = $1, description = $2, category_id = $3, primary_muscle_group = $4,
		secondary_muscle_groups = $5, equipment_required = $6, difficulty_level = $7,
		is_custom = $8, updated_at = NOW()
		WHERE id = $9
		RETURNING created_at, updated_at;`

	var ex Exercise = input
	ex.ID = id
	if err := r.pool.QueryRow(ctx, query,
		input.Name,
		input.Description,
		input.CategoryID,
		input.PrimaryMuscleGroup,
		input.SecondaryMuscleGroup,
		input.EquipmentRequired,
		input.DifficultyLevel,
		input.IsCustom,
		id,
	).Scan(&ex.CreatedAt, &ex.UpdatedAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Exercise{}, ErrExerciseNotFound
		}
		return Exercise{}, fmt.Errorf("update exercise: %w", err)
	}

	return ex, nil
}

// DeleteExercise removes an exercise.
func (r *Repository) DeleteExercise(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM exercises WHERE id = $1`
	tag, err := r.pool.Exec(ctx, query, id)
	if err != nil {
		return fmt.Errorf("delete exercise: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrExerciseNotFound
	}
	return nil
}

// GetExercise fetches an exercise by ID.
func (r *Repository) GetExercise(ctx context.Context, id uuid.UUID) (Exercise, error) {
	query := `SELECT id, name, COALESCE(description,''), category_id, COALESCE(primary_muscle_group,''), 
                     COALESCE(secondary_muscle_groups, ARRAY[]::text[]), COALESCE(equipment_required,''), 
                     COALESCE(difficulty_level,''), is_custom, created_by, created_at, updated_at
              FROM exercises WHERE id = $1`

	var ex Exercise
	if err := r.pool.QueryRow(ctx, query, id).
		Scan(&ex.ID, &ex.Name, &ex.Description, &ex.CategoryID,
			&ex.PrimaryMuscleGroup, &ex.SecondaryMuscleGroup,
			&ex.EquipmentRequired, &ex.DifficultyLevel,
			&ex.IsCustom, &ex.CreatedBy, &ex.CreatedAt, &ex.UpdatedAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Exercise{}, ErrExerciseNotFound
		}
		return Exercise{}, fmt.Errorf("select exercise: %w", err)
	}

	return ex, nil
}

// ListExercises returns exercises filtered by query/category.
func (r *Repository) ListExercises(ctx context.Context, queryText string, categories []uuid.UUID, limit int32) ([]Exercise, error) {
	if limit <= 0 || limit > 1000 {
		limit = 500
	}

	var conditions []string
	var args []any
	argPos := 1

	if queryText != "" {
		conditions = append(conditions, fmt.Sprintf("to_tsvector('english', name) @@ plainto_tsquery('english', $%d)", argPos))
		args = append(args, queryText)
		argPos++
	}

	if len(categories) > 0 {
		conditions = append(conditions, fmt.Sprintf("category_id = ANY($%d)", argPos))
		args = append(args, categories)
		argPos++
	}

	where := ""
	if len(conditions) > 0 {
		where = "WHERE " + strings.Join(conditions, " AND ")
	}

	query := fmt.Sprintf(`SELECT id, name, COALESCE(description,''), category_id, COALESCE(primary_muscle_group,''), 
			COALESCE(secondary_muscle_groups, ARRAY[]::text[]), COALESCE(equipment_required,''), 
			COALESCE(difficulty_level,''), is_custom, created_by, created_at, updated_at
			FROM exercises %s
			ORDER BY created_at DESC
			LIMIT $%d`, where, argPos)
	args = append(args, limit)

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list exercises: %w", err)
	}
	defer rows.Close()

	var exercises []Exercise
	for rows.Next() {
		var ex Exercise
		if err := rows.Scan(&ex.ID, &ex.Name, &ex.Description, &ex.CategoryID, &ex.PrimaryMuscleGroup,
			&ex.SecondaryMuscleGroup, &ex.EquipmentRequired, &ex.DifficultyLevel, &ex.IsCustom,
			&ex.CreatedBy, &ex.CreatedAt, &ex.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan exercise: %w", err)
		}
		exercises = append(exercises, ex)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate exercises: %w", err)
	}

	return exercises, nil
}

// GetCategoryName returns the category name for a given category ID.
func (r *Repository) GetCategoryName(ctx context.Context, categoryID uuid.UUID) (string, error) {
	var name string
	err := r.pool.QueryRow(ctx, "SELECT name FROM exercise_categories WHERE id = $1", categoryID).Scan(&name)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return "", fmt.Errorf("category not found")
		}
		return "", fmt.Errorf("get category name: %w", err)
	}
	return name, nil
}

// ErrExerciseNotFound is returned when an exercise cannot be located.
var ErrExerciseNotFound = errors.New("exercise not found")
