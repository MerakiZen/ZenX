package db

import (
    "context"
    "fmt"

    "github.com/jackc/pgx/v5/pgxpool"
)

// EnsureSchema creates the minimal tables required by the auth service if they do not exist.
func EnsureSchema(ctx context.Context, pool *pgxpool.Pool) error {
    stmts := []string{
        `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
        `CREATE TABLE IF NOT EXISTS users (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            email VARCHAR(255) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            display_name VARCHAR(100),
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );`,
        `CREATE TABLE IF NOT EXISTS refresh_tokens (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            token_hash CHAR(64) NOT NULL UNIQUE,
            expires_at TIMESTAMPTZ NOT NULL,
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
