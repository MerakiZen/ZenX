package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// EnsureSchema sets up the database objects required by the exercise service.
func EnsureSchema(ctx context.Context, pool *pgxpool.Pool) error {
	stmts := []string{
		`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
		`CREATE TABLE IF NOT EXISTS exercise_categories (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			slug TEXT UNIQUE NOT NULL,
			name TEXT NOT NULL
		);`,
		`CREATE TABLE IF NOT EXISTS exercises (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			name TEXT NOT NULL,
			description TEXT,
			category_id UUID REFERENCES exercise_categories(id),
			primary_muscle_group TEXT,
			secondary_muscle_groups TEXT[],
			equipment_required TEXT,
			difficulty_level TEXT,
			is_custom BOOLEAN NOT NULL DEFAULT FALSE,
			created_by UUID,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE INDEX IF NOT EXISTS idx_exercises_name ON exercises USING GIN (to_tsvector('english', name));`,
		`CREATE INDEX IF NOT EXISTS idx_exercises_category ON exercises (category_id);`,
	}

	for _, stmt := range stmts {
		if _, err := pool.Exec(ctx, stmt); err != nil {
			return fmt.Errorf("apply schema statement: %w", err)
		}
	}

	return nil
}

