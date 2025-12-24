package store

import (
	"context"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Notification represents a queued notification.
type Notification struct {
	ID           uuid.UUID
	UserID       uuid.UUID
	Template     string
	Payload      map[string]string
	ScheduledFor *time.Time
	Status       string
	CreatedAt    time.Time
	SentAt       *time.Time
}

// Preference describes a user's channel preference.
type Preference struct {
	UserID  uuid.UUID
	Channel string
	Enabled bool
}

// Repository handles persistence.
type Repository struct {
	pool *pgxpool.Pool
}

// NewRepository returns a Repository instance.
func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

// Enqueue inserts a notification.
func (r *Repository) Enqueue(ctx context.Context, notification Notification) (uuid.UUID, error) {
	query := `INSERT INTO notifications (user_id, template, payload, scheduled_for)
			  VALUES ($1,$2,$3,$4)
			  RETURNING id`

	var payloadRaw []byte
	if notification.Payload != nil {
		var err error
		payloadRaw, err = json.Marshal(notification.Payload)
		if err != nil {
			return uuid.Nil, fmt.Errorf("marshal payload: %w", err)
		}
	}

	var id uuid.UUID
	if err := r.pool.QueryRow(ctx, query,
		notification.UserID,
		notification.Template,
		payloadRaw,
		notification.ScheduledFor,
	).Scan(&id); err != nil {
		return uuid.Nil, fmt.Errorf("insert notification: %w", err)
	}
	return id, nil
}

// UpsertPreference stores a user's preference.
func (r *Repository) UpsertPreference(ctx context.Context, pref Preference) (Preference, error) {
	query := `INSERT INTO notification_preferences (user_id, channel, enabled)
			  VALUES ($1,$2,$3)
			  ON CONFLICT (user_id, channel) DO UPDATE SET enabled = EXCLUDED.enabled
			  RETURNING user_id, channel, enabled`

	if err := r.pool.QueryRow(ctx, query, pref.UserID, pref.Channel, pref.Enabled).
		Scan(&pref.UserID, &pref.Channel, &pref.Enabled); err != nil {
		return Preference{}, fmt.Errorf("upsert preference: %w", err)
	}
	return pref, nil
}

// ListPreferences returns preferences for a user.
func (r *Repository) ListPreferences(ctx context.Context, userID uuid.UUID) ([]Preference, error) {
	rows, err := r.pool.Query(ctx, `SELECT user_id, channel, enabled FROM notification_preferences WHERE user_id = $1`, userID)
	if err != nil {
		return nil, fmt.Errorf("list preferences: %w", err)
	}
	defer rows.Close()

	var prefs []Preference
	for rows.Next() {
		var pref Preference
		if err := rows.Scan(&pref.UserID, &pref.Channel, &pref.Enabled); err != nil {
			return nil, fmt.Errorf("scan preference: %w", err)
		}
		prefs = append(prefs, pref)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate preferences: %w", err)
	}
	return prefs, nil
}

// ListNotifications returns notifications for a user ordered by recency.
func (r *Repository) ListNotifications(ctx context.Context, userID uuid.UUID, limit int32, cursor string, statusFilter string) ([]Notification, string, error) {
	offset, err := decodeCursor(cursor)
	if err != nil {
		return nil, "", fmt.Errorf("decode cursor: %w", err)
	}
	if limit <= 0 {
		limit = 20
	}

	const stmt = `SELECT id, user_id, template, payload, scheduled_for, status, created_at, sent_at
	              FROM notifications
	              WHERE user_id = $1
	                AND ($4 = '' OR status = $4)
	              ORDER BY created_at DESC
	              LIMIT $2 OFFSET $3`
	rows, err := r.pool.Query(ctx, stmt, userID, limit+1, offset, statusFilter)
	if err != nil {
		return nil, "", fmt.Errorf("list notifications: %w", err)
	}
	defer rows.Close()

	var notifications []Notification
	count := 0
	for rows.Next() {
		if count == int(limit) {
			offset += count
			return notifications, encodeCursor(offset), nil
		}
		notif, err := scanNotification(rows)
		if err != nil {
			return nil, "", err
		}
		notifications = append(notifications, notif)
		count++
	}
	if err := rows.Err(); err != nil {
		return nil, "", fmt.Errorf("iterate notifications: %w", err)
	}
	return notifications, "", nil
}

// MarkNotificationRead updates a notification's status to read.
func (r *Repository) MarkNotificationRead(ctx context.Context, notificationID uuid.UUID, userID uuid.UUID) (Notification, error) {
	const stmt = `UPDATE notifications
	              SET status = 'read'
	              WHERE id = $1 AND user_id = $2
	              RETURNING id, user_id, template, payload, scheduled_for, status, created_at, sent_at`
	row := r.pool.QueryRow(ctx, stmt, notificationID, userID)
	notif, err := scanNotification(row)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			return Notification{}, err
		}
		return Notification{}, fmt.Errorf("mark notification read: %w", err)
	}
	return notif, nil
}

func scanNotification(row interface {
	Scan(dest ...any) error
}) (Notification, error) {
	var notif Notification
	var payloadRaw []byte
	var scheduled sql.NullTime
	var sent sql.NullTime
	if err := row.Scan(
		&notif.ID,
		&notif.UserID,
		&notif.Template,
		&payloadRaw,
		&scheduled,
		&notif.Status,
		&notif.CreatedAt,
		&sent,
	); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Notification{}, ErrNotFound
		}
		return Notification{}, fmt.Errorf("scan notification: %w", err)
	}

	if scheduled.Valid {
		notif.ScheduledFor = &scheduled.Time
	}
	if sent.Valid {
		notif.SentAt = &sent.Time
	}

	if len(payloadRaw) > 0 {
		if err := json.Unmarshal(payloadRaw, &notif.Payload); err != nil {
			return Notification{}, fmt.Errorf("unmarshal payload: %w", err)
		}
	}

	return notif, nil
}

func encodeCursor(offset int) string {
	return base64.URLEncoding.EncodeToString([]byte(strconv.Itoa(offset)))
}

func decodeCursor(cursor string) (int, error) {
	if cursor == "" {
		return 0, nil
	}
	decoded, err := base64.URLEncoding.DecodeString(cursor)
	if err != nil {
		return 0, err
	}
	return strconv.Atoi(string(decoded))
}

var ErrNotFound = errors.New("not found")
