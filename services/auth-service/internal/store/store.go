package store

import (
    "context"
    "crypto/sha256"
    "encoding/hex"
    "errors"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"
)

var (
    // ErrUserExists indicates there is already a user with the same email.
    ErrUserExists = errors.New("user already exists")
    // ErrInvalidCredentials is returned when the email/password combo is invalid.
    ErrInvalidCredentials = errors.New("invalid credentials")
    // ErrRefreshTokenNotFound indicates refresh token lookup failure.
    ErrRefreshTokenNotFound = errors.New("refresh token not found")
)

// User represents a user row.
type User struct {
    ID           uuid.UUID
    Email        string
    PasswordHash string
    DisplayName  *string
    CreatedAt    time.Time
}

// RefreshToken represents a stored refresh token.
type RefreshToken struct {
    ID        uuid.UUID
    UserID    uuid.UUID
    TokenHash string
    ExpiresAt time.Time
}

// Repository wraps persistence access.
type Repository struct {
    pool *pgxpool.Pool
}

// NewRepository returns a Repository instance.
func NewRepository(pool *pgxpool.Pool) *Repository {
    return &Repository{pool: pool}
}

// CreateUser inserts a new user ensuring the email is unique.
func (r *Repository) CreateUser(ctx context.Context, email, passwordHash string, displayName *string) (User, error) {
    query := `INSERT INTO users (email, password_hash, display_name)
              VALUES ($1, $2, $3)
              ON CONFLICT (email) DO NOTHING
              RETURNING id, created_at;`

    var user User
    if err := r.pool.QueryRow(ctx, query, email, passwordHash, displayName).
        Scan(&user.ID, &user.CreatedAt); err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return User{}, ErrUserExists
        }
        return User{}, fmt.Errorf("insert user: %w", err)
    }

    user.Email = email
    user.PasswordHash = passwordHash
    user.DisplayName = displayName
    return user, nil
}

// GetUserByEmail fetches a user.
func (r *Repository) GetUserByEmail(ctx context.Context, email string) (User, error) {
    query := `SELECT id, email, password_hash, display_name, created_at
              FROM users WHERE email = $1`
    var user User
    if err := r.pool.QueryRow(ctx, query, email).
        Scan(&user.ID, &user.Email, &user.PasswordHash, &user.DisplayName, &user.CreatedAt); err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return User{}, ErrInvalidCredentials
        }
        return User{}, fmt.Errorf("select user: %w", err)
    }
    return user, nil
}

// StoreRefreshToken saves a hashed refresh token.
func (r *Repository) StoreRefreshToken(ctx context.Context, userID uuid.UUID, token string, expiresAt time.Time) (RefreshToken, error) {
    hashed := hashToken(token)
    query := `INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
              VALUES ($1, $2, $3)
              RETURNING id;`
    var rt RefreshToken
    if err := r.pool.QueryRow(ctx, query, userID, hashed, expiresAt).
        Scan(&rt.ID); err != nil {
        return RefreshToken{}, fmt.Errorf("insert refresh token: %w", err)
    }

    rt.UserID = userID
    rt.TokenHash = hashed
    rt.ExpiresAt = expiresAt
    return rt, nil
}

// GetRefreshToken retrieves a refresh token by plaintext token value.
func (r *Repository) GetRefreshToken(ctx context.Context, token string) (RefreshToken, error) {
    hashed := hashToken(token)
    query := `SELECT id, user_id, token_hash, expires_at
              FROM refresh_tokens WHERE token_hash = $1`
    var rt RefreshToken
    if err := r.pool.QueryRow(ctx, query, hashed).
        Scan(&rt.ID, &rt.UserID, &rt.TokenHash, &rt.ExpiresAt); err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return RefreshToken{}, ErrRefreshTokenNotFound
        }
        return RefreshToken{}, fmt.Errorf("select refresh token: %w", err)
    }
    return rt, nil
}

// DeleteRefreshToken removes a refresh token by identifier.
func (r *Repository) DeleteRefreshToken(ctx context.Context, tokenID uuid.UUID) error {
    if _, err := r.pool.Exec(ctx, `DELETE FROM refresh_tokens WHERE id = $1`, tokenID); err != nil {
        return fmt.Errorf("delete refresh token: %w", err)
    }
    return nil
}

// DeleteUserRefreshTokens removes all refresh tokens for a user.
func (r *Repository) DeleteUserRefreshTokens(ctx context.Context, userID uuid.UUID) error {
    if _, err := r.pool.Exec(ctx, `DELETE FROM refresh_tokens WHERE user_id = $1`, userID); err != nil {
        return fmt.Errorf("delete user refresh tokens: %w", err)
    }
    return nil
}

func hashToken(token string) string {
    sum := sha256.Sum256([]byte(token))
    return hex.EncodeToString(sum[:])
}
