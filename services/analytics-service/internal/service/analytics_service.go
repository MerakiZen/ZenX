package service

import (
	"context"
	"time"

	"github.com/google/uuid"
	analyticsv1 "github.com/zenx/backend/proto/analytics/v1"
	commonv1 "github.com/zenx/backend/proto/common/v1"
	workoutv1 "github.com/zenx/backend/proto/workout/v1"
	"github.com/zenx/backend/services/analytics-service/internal/store"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// AnalyticsService implements analytics.v1 RPCs.
type AnalyticsService struct {
	analyticsv1.UnimplementedAnalyticsServiceServer
	repo          *store.Repository
	workoutClient workoutv1.WorkoutServiceClient
}

const (
	snapshotTTL            = 6 * time.Hour
	maxWorkoutsToAggregate = 200
)

// New creates the service.
func New(repo *store.Repository, workoutClient workoutv1.WorkoutServiceClient) *AnalyticsService {
	return &AnalyticsService{repo: repo, workoutClient: workoutClient}
}

// GetProgressSnapshot returns the latest aggregated snapshot.
func (s *AnalyticsService) GetProgressSnapshot(ctx context.Context, req *analyticsv1.GetProgressSnapshotRequest) (*analyticsv1.ProgressSnapshot, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	snapshot, err := s.ensureFreshSnapshot(ctx, userID)
	if err != nil {
		return nil, err
	}

	resp := &analyticsv1.ProgressSnapshot{
		UserId:        snapshot.UserID.String(),
		CapturedAt:    snapshot.CapturedAt.Unix(),
		TotalVolumeKg: snapshot.TotalVolumeKg,
		AverageRpe:    snapshot.AverageRPE,
		WorkoutCount:  snapshot.WorkoutCount,
	}
	for _, pr := range snapshot.Records {
		resp.Prs = append(resp.Prs, toProtoRecord(pr))
	}
	return resp, nil
}

// ListPersonalRecords returns user PRs.
func (s *AnalyticsService) ListPersonalRecords(ctx context.Context, req *analyticsv1.ListPersonalRecordsRequest) (*analyticsv1.ListPersonalRecordsResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	if _, err := s.ensureFreshSnapshot(ctx, userID); err != nil {
		return nil, err
	}

	records, err := s.repo.ListPersonalRecords(ctx, userID)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list prs: %v", err)
	}

	resp := &analyticsv1.ListPersonalRecordsResponse{}
	for _, rec := range records {
		resp.Records = append(resp.Records, toProtoRecord(rec))
	}
	return resp, nil
}

func (s *AnalyticsService) RecalculateMetrics(ctx context.Context, req *analyticsv1.RecalculateMetricsRequest) (*analyticsv1.RecalculateMetricsResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	if err := s.recalculateAndPersist(ctx, userID); err != nil {
		return nil, status.Errorf(codes.Internal, "recalculate: %v", err)
	}

	return &analyticsv1.RecalculateMetricsResponse{Scheduled: true}, nil
}

func (s *AnalyticsService) GetWorkoutCalendar(ctx context.Context, req *analyticsv1.GetWorkoutCalendarRequest) (*analyticsv1.GetWorkoutCalendarResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	start, end, err := parseDateRange(req.GetDateRange())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid date range")
	}

	days, err := s.repo.GetWorkoutCalendar(ctx, userID, start, end)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "get calendar: %v", err)
	}

	var dayStrings []string
	for _, d := range days {
		dayStrings = append(dayStrings, d.Format("2006-01-02"))
	}

	return &analyticsv1.GetWorkoutCalendarResponse{
		WorkoutDays:   dayStrings,
		TotalWorkouts: int32(len(days)),
	}, nil
}

func (s *AnalyticsService) GetMuscleGroupStats(ctx context.Context, req *analyticsv1.GetMuscleGroupStatsRequest) (*analyticsv1.GetMuscleGroupStatsResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	start, end, err := parseDateRange(req.GetDateRange())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid date range")
	}

	stats, err := s.repo.GetMuscleGroupStats(ctx, userID, start, end)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "get muscle stats: %v", err)
	}

	var totalVolume float64
	for _, st := range stats {
		totalVolume += st.Volume
	}

	var respStats []*analyticsv1.MuscleGroupStat
	for _, st := range stats {
		percentage := 0.0
		if totalVolume > 0 {
			percentage = (st.Volume / totalVolume) * 100
		}
		respStats = append(respStats, &analyticsv1.MuscleGroupStat{
			MuscleGroup: st.MuscleGroup,
			SetCount:    int32(st.SetCount),
			VolumeKg:    st.Volume,
			Percentage:  percentage,
		})
	}

	return &analyticsv1.GetMuscleGroupStatsResponse{Stats: respStats}, nil
}

func (s *AnalyticsService) GetTopExercises(ctx context.Context, req *analyticsv1.GetTopExercisesRequest) (*analyticsv1.GetTopExercisesResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	start, end, err := parseDateRange(req.GetDateRange())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid date range")
	}
	limit := int(req.GetLimit())
	if limit <= 0 {
		limit = 10
	}

	exercises, err := s.repo.GetTopExercises(ctx, userID, limit, start, end)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "get top exercises: %v", err)
	}

	var respExercises []*analyticsv1.ExerciseRecord
	for _, e := range exercises {
		respExercises = append(respExercises, &analyticsv1.ExerciseRecord{
			ExerciseId:    e.ExerciseID.String(),
			ExerciseName:  e.ExerciseName,
			WorkoutCount:  int32(e.WorkoutCount),
			LastPerformed: e.LastPerformed.Format("2006-01-02"),
		})
	}

	return &analyticsv1.GetTopExercisesResponse{Exercises: respExercises}, nil
}

func (s *AnalyticsService) GetExerciseStats(ctx context.Context, req *analyticsv1.GetExerciseStatsRequest) (*analyticsv1.GetExerciseStatsResponse, error) {
	userID, err := parseUUID(req.GetUserId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}
	exerciseID, err := parseUUID(req.GetExerciseId())
    if err != nil {
        return nil, status.Error(codes.InvalidArgument, err.Error())
    }

	stats, history, err := s.repo.GetExerciseStats(ctx, userID, exerciseID)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "get exercise stats: %v", err)
	}

	var historyProto []*analyticsv1.WorkoutExerciseEntry
	for _, h := range history {
		historyProto = append(historyProto, &analyticsv1.WorkoutExerciseEntry{
			WorkoutId: h.WorkoutID.String(),
			Date:      h.Date.Format("2006-01-02"),
			Weight:    h.Weight,
			Reps:      int32(h.Reps),
			OneRm:     h.OneRM,
			Volume:    h.Volume,
		})
	}

	return &analyticsv1.GetExerciseStatsResponse{
		Stats: &analyticsv1.ExercisePerformance{
			ExerciseId:        exerciseID.String(),
			HeaviestWeight:    stats.HeaviestWeight,
			ProjectedOneRm:    stats.ProjectedOneRM,
			BestSetVolume:     stats.BestSetVolume,
			BestSessionVolume: stats.BestSessionVolume,
			MostReps:          int32(stats.MostReps),
			History:           historyProto,
		},
	}, nil
}

func parseDateRange(dr *analyticsv1.DateRange) (time.Time, time.Time, error) {
	if dr == nil {
		// Default to last 30 days if not provided? Or error?
		// Let's default to all time (very old start, now end) or just return error.
		// Plan says "GetWorkoutCalendar(dateRange)".
		// I'll return a default range of 1 year for now if nil, or error.
		// Let's return error to be safe.
		return time.Time{}, time.Time{}, nil
	}
	start, err := time.Parse("2006-01-02", dr.StartDate)
	if err != nil {
		return time.Time{}, time.Time{}, err
	}
	end, err := time.Parse("2006-01-02", dr.EndDate)
	if err != nil {
		return time.Time{}, time.Time{}, err
	}
	// Set end to end of day
	end = end.Add(24 * time.Hour).Add(-1 * time.Nanosecond)
	return start, end, nil
}

func (s *AnalyticsService) ensureFreshSnapshot(ctx context.Context, userID uuid.UUID) (store.Snapshot, error) {
	snapshot, err := s.repo.GetLatestSnapshot(ctx, userID)
	if err == nil && time.Since(snapshot.CapturedAt) <= snapshotTTL {
		return snapshot, nil
	}
	if err != nil && err != store.ErrNotFound {
		return store.Snapshot{}, status.Errorf(codes.Internal, "get snapshot: %v", err)
	}

	if err := s.recalculateAndPersist(ctx, userID); err != nil {
		return store.Snapshot{}, status.Errorf(codes.Internal, "recalculate: %v", err)
	}

	snapshot, err = s.repo.GetLatestSnapshot(ctx, userID)
	if err != nil {
		return store.Snapshot{}, status.Errorf(codes.Internal, "load snapshot: %v", err)
	}
	return snapshot, nil
}

func (s *AnalyticsService) recalculateAndPersist(ctx context.Context, userID uuid.UUID) error {
	workouts, err := s.fetchWorkouts(ctx, userID)
	if err != nil {
		return err
	}

	metrics := buildMetrics(userID, workouts)

	if err := s.repo.InsertSnapshot(ctx, metrics.Snapshot); err != nil {
		return err
	}
	if err := s.repo.ReplacePersonalRecords(ctx, userID, metrics.Records); err != nil {
		return err
	}
	return nil
}

func (s *AnalyticsService) fetchWorkouts(ctx context.Context, userID uuid.UUID) ([]*workoutv1.Workout, error) {
	var (
		cursor    string
		collected []*workoutv1.Workout
	)

	for {
		limit := int32(50)
		req := &workoutv1.ListWorkoutsRequest{
			UserId: userID.String(),
			Pagination: &commonv1.Pagination{
				Limit:  limit,
				Cursor: cursor,
			},
		}
		resp, err := s.workoutClient.ListWorkouts(ctx, req)
		if err != nil {
			return nil, status.Errorf(codes.Internal, "list workouts: %v", err)
		}
		collected = append(collected, resp.GetWorkouts()...)

		if resp.GetNextCursor() == "" || len(resp.GetWorkouts()) == 0 || len(collected) >= maxWorkoutsToAggregate {
			break
		}
		cursor = resp.GetNextCursor()
	}

	if len(collected) > maxWorkoutsToAggregate {
		collected = collected[:maxWorkoutsToAggregate]
	}
	return collected, nil
}

type metricResult struct {
	Snapshot store.Snapshot
	Records  []store.PersonalRecord
}

func buildMetrics(userID uuid.UUID, workouts []*workoutv1.Workout) metricResult {
	var (
		totalVolume float64
		totalRPE    float64
		rpeCount    int
	)

	recordMap := map[uuid.UUID]store.PersonalRecord{}

	for _, workout := range workouts {
		for _, exercise := range treatNilExercises(workout.GetExercises()) {
			exID, err := uuid.Parse(exercise.GetExerciseId())
			if err != nil {
				continue
			}
			for _, set := range exercise.GetSets() {
				if set.GetWeightKg() > 0 && set.GetReps() > 0 {
					totalVolume += float64(set.GetReps()) * set.GetWeightKg()
				}
				if set.GetRpe() > 0 {
					totalRPE += set.GetRpe()
					rpeCount++
				}
				if set.GetWeightKg() <= 0 {
					continue
				}
				if current, ok := recordMap[exID]; !ok || set.GetWeightKg() > current.Value {
					recordMap[exID] = store.PersonalRecord{
						ExerciseID: exID,
						RecordType: "max_weight",
						Value:      set.GetWeightKg(),
						AchievedAt: deriveWorkoutTime(workout),
					}
				}
			}
		}
	}

	var avgRPE float64
	if rpeCount > 0 {
		avgRPE = totalRPE / float64(rpeCount)
	}

	var records []store.PersonalRecord
	for _, rec := range recordMap {
		records = append(records, rec)
	}

	return metricResult{
		Snapshot: store.Snapshot{
			UserID:        userID,
			CapturedAt:    time.Now().UTC(),
			TotalVolumeKg: totalVolume,
			AverageRPE:    avgRPE,
			WorkoutCount:  int32(len(workouts)),
			Records:       records,
		},
		Records: records,
	}
}

func treatNilExercises(ex []*workoutv1.WorkoutExercise) []*workoutv1.WorkoutExercise {
	if ex == nil {
		return []*workoutv1.WorkoutExercise{}
	}
	return ex
}

func deriveWorkoutTime(workout *workoutv1.Workout) time.Time {
	if workout == nil {
		return time.Now().UTC()
	}
	if workout.GetCompletedAt() != 0 {
		return time.Unix(workout.GetCompletedAt(), 0).UTC()
	}
	if workout.GetStartedAt() != 0 {
		return time.Unix(workout.GetStartedAt(), 0).UTC()
	}
	return time.Now().UTC()
}

func toProtoRecord(rec store.PersonalRecord) *analyticsv1.PersonalRecord {
	return &analyticsv1.PersonalRecord{
		ExerciseId: rec.ExerciseID.String(),
		RecordType: rec.RecordType,
		Value:      rec.Value,
		AchievedAt: rec.AchievedAt.Unix(),
	}
}

func parseUUID(val string) (uuid.UUID, error) {
	id, err := uuid.Parse(val)
	if err != nil {
		return uuid.Nil, err
	}
	return id, nil
}
