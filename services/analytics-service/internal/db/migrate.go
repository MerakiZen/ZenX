package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// EnsureSchema creates analytics tables if they don't exist.
func EnsureSchema(ctx context.Context, pool *pgxpool.Pool) error {
	stmts := []string{
		`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
		`CREATE TABLE IF NOT EXISTS progress_snapshots (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID NOT NULL,
			captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			total_volume_kg NUMERIC(12,2),
			average_rpe NUMERIC(5,2),
			workout_count INT,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`ALTER TABLE progress_snapshots ADD COLUMN IF NOT EXISTS workout_count INT DEFAULT 0;`,
		`CREATE INDEX IF NOT EXISTS idx_progress_snapshots_user ON progress_snapshots (user_id, captured_at DESC);`,
		`CREATE TABLE IF NOT EXISTS personal_records (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID NOT NULL,
			exercise_id UUID NOT NULL,
			record_type TEXT NOT NULL,
			value NUMERIC(12,2) NOT NULL,
			achieved_at TIMESTAMPTZ NOT NULL,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE INDEX IF NOT EXISTS idx_personal_records_user_exercise ON personal_records (user_id, exercise_id, record_type);`,
		`CREATE TABLE IF NOT EXISTS analytics_jobs (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID NOT NULL,
			workout_id UUID,
			status TEXT NOT NULL DEFAULT 'queued',
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			processed_at TIMESTAMPTZ
		);`,
	}

	for _, stmt := range stmts {
		if _, err := pool.Exec(ctx, stmt); err != nil {
			return fmt.Errorf("apply schema statement: %w", err)
		}
	}

	return nil
}
