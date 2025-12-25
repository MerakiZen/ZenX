package service

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	profilev1 "github.com/zenx/backend/proto/profile/v1"
	"github.com/zenx/backend/services/profile-service/internal/store"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ProfileService implements profile.v1 APIs.
type ProfileService struct {
	profilev1.UnimplementedProfileServiceServer
	repo *store.Repository
}

// New creates a new ProfileService.
func New(repo *store.Repository) *ProfileService {
	return &ProfileService{repo: repo}
}

// GetProfile fetches or creates a profile for a user.
func (s *ProfileService) GetProfile(ctx context.Context, req *profilev1.GetProfileRequest) (*profilev1.GetProfileResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	profile, err := s.repo.GetProfile(ctx, userID)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "get profile: %v", err)
	}

	return &profilev1.GetProfileResponse{Profile: toProtoProfile(profile)}, nil
}

// UpdateProfile updates profile fields.
func (s *ProfileService) UpdateProfile(ctx context.Context, req *profilev1.UpdateProfileRequest) (*profilev1.Profile, error) {
	if req.GetProfile() == nil {
		return nil, status.Error(codes.InvalidArgument, "profile payload required")
	}

	profile := req.GetProfile()
	userID, err := parseUUID(profile.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	updated, err := s.repo.UpdateProfile(ctx, store.Profile{
		UserID:      userID,
		DisplayName: nullableString(profile.GetDisplayName()),
		Bio:         nullableString(profile.GetBio()),
		AvatarURL:   nullableString(profile.GetAvatarUrl()),
		DateOfBirth: nullableDate(profile.GetDateOfBirth()),
		Gender:      nullableString(profile.GetGender()),
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "update profile: %v", err)
	}

	return toProtoProfile(updated), nil
}

// RecordMeasurement stores a measurement for a user.
func (s *ProfileService) RecordMeasurement(ctx context.Context, req *profilev1.RecordMeasurementRequest) (*profilev1.Measurement, error) {
	if req.GetMeasurement() == nil {
		return nil, status.Error(codes.InvalidArgument, "measurement payload required")
	}
	payload := req.GetMeasurement()

	userID, err := parseUUID(payload.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	measurementDate, err := parseDate(payload.GetMeasurementDate())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid measurement_date")
	}

	measurement, err := s.repo.RecordMeasurement(ctx, store.Measurement{
		UserID:            userID,
		MeasurementDate:   measurementDate,
		WeightKG:          nullableFloat(payload.GetWeightKg()),
		BodyFatPercentage: nullableFloat(payload.GetBodyFatPercentage()),
		MuscleMassKG:      nullableFloat(payload.GetMuscleMassKg()),
		MeasurementsJSON:  parseMeasurementsJSON(payload.GetMeasurementsJson()),
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "record measurement: %v", err)
	}

	return toProtoMeasurement(measurement), nil
}

// ListMeasurements returns measurements in an optional date range.
func (s *ProfileService) ListMeasurements(ctx context.Context, req *profilev1.ListMeasurementsRequest) (*profilev1.ListMeasurementsResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	var start, end *time.Time
	if req.GetRange() != nil {
		if req.GetRange().GetStart() > 0 {
			t := time.Unix(req.GetRange().GetStart(), 0).UTC()
			start = &t
		}
		if req.GetRange().GetEnd() > 0 {
			t := time.Unix(req.GetRange().GetEnd(), 0).UTC()
			end = &t
		}
	}

	measurements, err := s.repo.ListMeasurements(ctx, userID, start, end)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list measurements: %v", err)
	}

	resp := &profilev1.ListMeasurementsResponse{}
	for _, m := range measurements {
		resp.Measurements = append(resp.Measurements, toProtoMeasurement(m))
	}
	return resp, nil
}

func toProtoProfile(p store.Profile) *profilev1.Profile {
	profile := &profilev1.Profile{
		Id:          p.ID.String(),
		UserId:      p.UserID.String(),
		Bio:         p.Bio.String,
		AvatarUrl:   p.AvatarURL.String,
		Gender:      p.Gender.String,
		DisplayName: p.DisplayName.String,
	}
	if p.DateOfBirth.Valid {
		profile.DateOfBirth = p.DateOfBirth.Time.Format("2006-01-02")
	}
	return profile
}

func toProtoMeasurement(m store.Measurement) *profilev1.Measurement {
	measurement := &profilev1.Measurement{
		Id:                m.ID.String(),
		UserId:            m.UserID.String(),
		MeasurementDate:   m.MeasurementDate.Format("2006-01-02"),
		WeightKg:          m.WeightKG.Float64,
		BodyFatPercentage: m.BodyFatPercentage.Float64,
		MuscleMassKg:      m.MuscleMassKG.Float64,
		MeasurementsJson:  string(m.MeasurementsRaw),
	}
	return measurement
}

func parseUUID(val string) (uuid.UUID, error) {
	id, err := uuid.Parse(val)
	if err != nil {
		return uuid.Nil, err
	}
	return id, nil
}

func nullableString(val string) sql.NullString {
	return sql.NullString{String: val, Valid: val != ""}
}

func nullableDate(val string) sql.NullTime {
	if val == "" {
		return sql.NullTime{}
	}
	t, err := time.Parse("2006-01-02", val)
	if err != nil {
		return sql.NullTime{}
	}
	return sql.NullTime{Time: t, Valid: true}
}

func nullableFloat(val float64) sql.NullFloat64 {
	if val == 0 {
		return sql.NullFloat64{}
	}
	return sql.NullFloat64{Float64: val, Valid: true}
}

func parseMeasurementsJSON(raw string) map[string]any {
	if raw == "" {
		return nil
	}
	var data map[string]any
	if err := json.Unmarshal([]byte(raw), &data); err != nil {
		return nil
	}
	return data
}

func parseDate(val string) (time.Time, error) {
	return time.Parse("2006-01-02", val)
}
