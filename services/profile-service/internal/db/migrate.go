package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// EnsureSchema creates profile-related tables if needed.
func EnsureSchema(ctx context.Context, pool *pgxpool.Pool) error {
	stmts := []string{
		`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
		`CREATE TABLE IF NOT EXISTS user_profiles (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID UNIQUE NOT NULL,
			display_name TEXT,
			bio TEXT,
			avatar_url TEXT,
			date_of_birth DATE,
			gender TEXT,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE TABLE IF NOT EXISTS body_measurements (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
			measurement_date DATE NOT NULL,
			weight_kg NUMERIC(6,2),
			body_fat_percentage NUMERIC(5,2),
			muscle_mass_kg NUMERIC(6,2),
			measurements JSONB,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE TABLE IF NOT EXISTS user_settings (
			user_id UUID PRIMARY KEY REFERENCES user_profiles(user_id) ON DELETE CASCADE,
			locale TEXT,
			units TEXT,
			timezone TEXT,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		);`,
		`CREATE INDEX IF NOT EXISTS idx_measurements_user_date ON body_measurements (user_id, measurement_date DESC);`,
	}

	for _, stmt := range stmts {
		if _, err := pool.Exec(ctx, stmt); err != nil {
			return fmt.Errorf("apply schema statement: %w", err)
		}
	}

	return nil
}

