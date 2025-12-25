package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// EnsureSchema creates the tables required by the workout service if they do not already exist.
func EnsureSchema(ctx context.Context, pool *pgxpool.Pool) error {
	stmts := []string{
		`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
		`CREATE TABLE IF NOT EXISTS workouts (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID NOT NULL,
			name VARCHAR(200) NOT NULL,
			notes TEXT,
			started_at TIMESTAMPTZ,
			completed_at TIMESTAMPTZ,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE INDEX IF NOT EXISTS idx_workouts_user_created ON workouts (user_id, created_at DESC);`,
		`CREATE TABLE IF NOT EXISTS workout_exercises (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
			exercise_id UUID NOT NULL,
			order_index INT NOT NULL,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE TABLE IF NOT EXISTS workout_sets (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
			set_number INT NOT NULL,
			reps INT,
			weight_kg NUMERIC(10,2),
			rpe NUMERIC(4,2),
			notes TEXT,
			completed BOOLEAN NOT NULL DEFAULT FALSE,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE TABLE IF NOT EXISTS workout_events (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
			user_id UUID NOT NULL,
			event_type TEXT NOT NULL,
			payload JSONB,
			occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE TABLE IF NOT EXISTS feed_posts (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
			user_id UUID NOT NULL,
			caption TEXT,
			image_url TEXT,
			visibility TEXT NOT NULL DEFAULT 'public',
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			UNIQUE (workout_id)
		);`,
		`CREATE TABLE IF NOT EXISTS feed_likes (
			post_id UUID NOT NULL REFERENCES feed_posts(id) ON DELETE CASCADE,
			user_id UUID NOT NULL,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			PRIMARY KEY (post_id, user_id)
		);`,
		`CREATE TABLE IF NOT EXISTS feed_comments (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			post_id UUID NOT NULL REFERENCES feed_posts(id) ON DELETE CASCADE,
			user_id UUID NOT NULL,
			body TEXT NOT NULL,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
	}

	for _, stmt := range stmts {
		if _, err := pool.Exec(ctx, stmt); err != nil {
			return fmt.Errorf("apply schema statement: %w", err)
		}
	}

	return nil
}
