package service

import (
	"context"
	"errors"

	"github.com/google/uuid"
	exercisev1 "github.com/zenx/backend/proto/exercise/v1"
	"github.com/zenx/backend/services/exercise-service/internal/store"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// ExerciseService implements the exercise.v1 API.
type ExerciseService struct {
	exercisev1.UnimplementedExerciseServiceServer
	repo *store.Repository
}

// New creates a new ExerciseService.
func New(repo *store.Repository) *ExerciseService {
	return &ExerciseService{repo: repo}
}

// CreateExercise inserts a new exercise.
func (s *ExerciseService) CreateExercise(ctx context.Context, req *exercisev1.CreateExerciseRequest) (*exercisev1.Exercise, error) {
	if req.GetExercise() == nil {
		return nil, status.Error(codes.InvalidArgument, "exercise payload required")
	}

	payload := req.GetExercise()
	if payload.GetName() == "" {
		return nil, status.Error(codes.InvalidArgument, "name is required")
	}

	var categoryID *uuid.UUID
	if payload.GetCategory() != "" {
		id, err := uuid.Parse(payload.GetCategory())
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "invalid category id: %v", err)
		}
		categoryID = &id
	}

	var createdBy *uuid.UUID
	if payload.GetCreatedBy() != "" {
		id, err := uuid.Parse(payload.GetCreatedBy())
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "invalid created_by: %v", err)
		}
		createdBy = &id
	}

	ex, err := s.repo.CreateExercise(ctx, store.Exercise{
		Name:                 payload.GetName(),
		Description:          payload.GetDescription(),
		CategoryID:           categoryID,
		PrimaryMuscleGroup:   payload.GetPrimaryMuscleGroup(),
		SecondaryMuscleGroup: payload.GetSecondaryMuscleGroups(),
		EquipmentRequired:    payload.GetEquipmentRequired(),
		DifficultyLevel:      payload.GetDifficultyLevel(),
		IsCustom:             payload.GetIsCustom(),
		CreatedBy:            createdBy,
	})
	if err != nil {
		return nil, status.Errorf(codes.Internal, "create exercise: %v", err)
	}

	return s.toProto(ctx, ex), nil
}

// GetExercise returns a single exercise.
func (s *ExerciseService) GetExercise(ctx context.Context, req *exercisev1.GetExerciseRequest) (*exercisev1.Exercise, error) {
	id, err := uuid.Parse(req.GetExerciseId())
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid exercise id")
	}

	ex, err := s.repo.GetExercise(ctx, id)
	if err != nil {
		if errors.Is(err, store.ErrExerciseNotFound) {
			return nil, status.Error(codes.NotFound, "exercise not found")
		}
		return nil, status.Errorf(codes.Internal, "get exercise: %v", err)
	}

	return s.toProto(ctx, ex), nil
}

// ListExercises searches exercises by text/category.
func (s *ExerciseService) ListExercises(ctx context.Context, req *exercisev1.ListExercisesRequest) (*exercisev1.ListExercisesResponse, error) {
	var categoryIDs []uuid.UUID
	for _, cat := range req.GetCategories() {
		id, err := uuid.Parse(cat)
		if err != nil {
			return nil, status.Errorf(codes.InvalidArgument, "invalid category id %q", cat)
		}
		categoryIDs = append(categoryIDs, id)
	}

	exercises, err := s.repo.ListExercises(ctx, req.GetQuery(), categoryIDs, 500)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "list exercises: %v", err)
	}

	resp := &exercisev1.ListExercisesResponse{}
	for _, ex := range exercises {
		resp.Exercises = append(resp.Exercises, s.toProto(ctx, ex))
	}
	return resp, nil
}

func (s *ExerciseService) toProto(ctx context.Context, ex store.Exercise) *exercisev1.Exercise {
	var category string
	if ex.CategoryID != nil {
		// Look up category name from ID
		if catName, err := s.repo.GetCategoryName(ctx, *ex.CategoryID); err == nil {
			category = catName
		} else {
			// Fallback to ID if lookup fails
			category = ex.CategoryID.String()
		}
	}

	var createdBy string
	if ex.CreatedBy != nil {
		createdBy = ex.CreatedBy.String()
	}

	return &exercisev1.Exercise{
		Id:                    ex.ID.String(),
		Name:                  ex.Name,
		Description:           ex.Description,
		Category:              category,
		PrimaryMuscleGroup:    ex.PrimaryMuscleGroup,
		SecondaryMuscleGroups: ex.SecondaryMuscleGroup,
		EquipmentRequired:     ex.EquipmentRequired,
		DifficultyLevel:       ex.DifficultyLevel,
		IsCustom:              ex.IsCustom,
		CreatedBy:             createdBy,
	}
}
