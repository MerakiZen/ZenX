package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

// EnsureSchema creates notification tables if needed.
func EnsureSchema(ctx context.Context, pool *pgxpool.Pool) error {
	stmts := []string{
		`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
		`CREATE TABLE IF NOT EXISTS notification_preferences (
			user_id UUID NOT NULL,
			channel TEXT NOT NULL,
			enabled BOOLEAN NOT NULL DEFAULT TRUE,
			PRIMARY KEY (user_id, channel)
		);`,
		`CREATE TABLE IF NOT EXISTS notifications (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID NOT NULL,
			template TEXT NOT NULL,
			payload JSONB,
			scheduled_for TIMESTAMPTZ,
			status TEXT NOT NULL DEFAULT 'pending',
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			sent_at TIMESTAMPTZ
		);`,
		`CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications (status, scheduled_for);`,
	}

	for _, stmt := range stmts {
		if _, err := pool.Exec(ctx, stmt); err != nil {
			return fmt.Errorf("apply schema statement: %w", err)
		}
	}

	return nil
}

