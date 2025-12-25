package store

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Profile represents the user profile model.
type Profile struct {
	ID          uuid.UUID
	UserID      uuid.UUID
	DisplayName sql.NullString
	Bio         sql.NullString
	AvatarURL   sql.NullString
	DateOfBirth sql.NullTime
	Gender      sql.NullString
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// Measurement captures body measurement metrics.
type Measurement struct {
	ID                uuid.UUID
	UserID            uuid.UUID
	MeasurementDate   time.Time
	WeightKG          sql.NullFloat64
	BodyFatPercentage sql.NullFloat64
	MuscleMassKG      sql.NullFloat64
	MeasurementsJSON  map[string]any
	MeasurementsRaw   []byte
	CreatedAt         time.Time
}

// Repository handles persistence.
type Repository struct {
	pool *pgxpool.Pool
}

// NewRepository returns a Repository.
func NewRepository(pool *pgxpool.Pool) *Repository {
	return &Repository{pool: pool}
}

// GetProfile returns a profile by user ID, creating a shell row if needed.
func (r *Repository) GetProfile(ctx context.Context, userID uuid.UUID) (Profile, error) {
	query := `INSERT INTO user_profiles (user_id)
			  VALUES ($1)
			  ON CONFLICT (user_id) DO UPDATE SET user_id = EXCLUDED.user_id
			  RETURNING id, user_id, display_name, bio, avatar_url, date_of_birth, gender, created_at, updated_at`

	var profile Profile
	if err := r.pool.QueryRow(ctx, query, userID).Scan(
		&profile.ID,
		&profile.UserID,
		&profile.DisplayName,
		&profile.Bio,
		&profile.AvatarURL,
		&profile.DateOfBirth,
		&profile.Gender,
		&profile.CreatedAt,
		&profile.UpdatedAt,
	); err != nil {
		return Profile{}, fmt.Errorf("upsert profile: %w", err)
	}
	return profile, nil
}

// UpdateProfile updates profile fields.
func (r *Repository) UpdateProfile(ctx context.Context, profile Profile) (Profile, error) {
	query := `UPDATE user_profiles
			  SET display_name = $1,
				  bio = $2,
				  avatar_url = $3,
				  date_of_birth = $4,
				  gender = $5,
				  updated_at = NOW()
			  WHERE user_id = $6
			  RETURNING id, user_id, display_name, bio, avatar_url, date_of_birth, gender, created_at, updated_at`

	if err := r.pool.QueryRow(ctx, query,
		profile.DisplayName,
		profile.Bio,
		profile.AvatarURL,
		profile.DateOfBirth,
		profile.Gender,
		profile.UserID,
	).Scan(&profile.ID, &profile.UserID, &profile.DisplayName, &profile.Bio, &profile.AvatarURL,
		&profile.DateOfBirth, &profile.Gender, &profile.CreatedAt, &profile.UpdatedAt); err != nil {
		return Profile{}, fmt.Errorf("update profile: %w", err)
	}
	return profile, nil
}

// RecordMeasurement inserts a new measurement row.
func (r *Repository) RecordMeasurement(ctx context.Context, measurement Measurement) (Measurement, error) {
	query := `INSERT INTO body_measurements (
		user_id, measurement_date, weight_kg, body_fat_percentage,
		muscle_mass_kg, measurements)
		VALUES ($1,$2,$3,$4,$5,$6)
		RETURNING id, created_at`

	var raw []byte
	if measurement.MeasurementsJSON != nil {
		var err error
		raw, err = json.Marshal(measurement.MeasurementsJSON)
		if err != nil {
			return Measurement{}, fmt.Errorf("marshal measurements json: %w", err)
		}
	}

	if err := r.pool.QueryRow(ctx, query,
		measurement.UserID,
		measurement.MeasurementDate,
		measurement.WeightKG,
		measurement.BodyFatPercentage,
		measurement.MuscleMassKG,
		raw,
	).Scan(&measurement.ID, &measurement.CreatedAt); err != nil {
		return Measurement{}, fmt.Errorf("insert measurement: %w", err)
	}

	measurement.MeasurementsRaw = raw
	return measurement, nil
}

// ListMeasurements returns measurements for a user within optional range.
func (r *Repository) ListMeasurements(ctx context.Context, userID uuid.UUID, start, end *time.Time) ([]Measurement, error) {
	query := `SELECT id, user_id, measurement_date, weight_kg, body_fat_percentage,
		muscle_mass_kg, measurements, created_at
		FROM body_measurements
		WHERE user_id = $1`

	args := []any{userID}
	idx := 2
	if start != nil {
		query += fmt.Sprintf(" AND measurement_date >= $%d", idx)
		args = append(args, *start)
		idx++
	}
	if end != nil {
		query += fmt.Sprintf(" AND measurement_date <= $%d", idx)
		args = append(args, *end)
		idx++
	}

	query += " ORDER BY measurement_date DESC LIMIT 100"

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list measurements: %w", err)
	}
	defer rows.Close()

	var measurements []Measurement
	for rows.Next() {
		var m Measurement
		if err := rows.Scan(&m.ID, &m.UserID, &m.MeasurementDate, &m.WeightKG, &m.BodyFatPercentage,
			&m.MuscleMassKG, &m.MeasurementsRaw, &m.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan measurement: %w", err)
		}
		if len(m.MeasurementsRaw) > 0 {
			_ = json.Unmarshal(m.MeasurementsRaw, &m.MeasurementsJSON)
		}
		measurements = append(measurements, m)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate measurements: %w", err)
	}

	return measurements, nil
}

// DeleteProfile removes a user profile and measurements.
func (r *Repository) DeleteProfile(ctx context.Context, userID uuid.UUID) error {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	// Delete measurements first
	if _, err := tx.Exec(ctx, "DELETE FROM body_measurements WHERE user_id = $1", userID); err != nil {
		return fmt.Errorf("delete measurements: %w", err)
	}

	// Delete profile
	if _, err := tx.Exec(ctx, "DELETE FROM user_profiles WHERE user_id = $1", userID); err != nil {
		return fmt.Errorf("delete profile: %w", err)
	}

	return tx.Commit(ctx)
}
