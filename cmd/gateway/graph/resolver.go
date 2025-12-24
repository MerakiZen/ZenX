package graph

import (
	analyticsv1 "github.com/zenx/backend/proto/analytics/v1"
	authv1 "github.com/zenx/backend/proto/auth/v1"
	exercisev1 "github.com/zenx/backend/proto/exercise/v1"
	notificationv1 "github.com/zenx/backend/proto/notification/v1"
	profilev1 "github.com/zenx/backend/proto/profile/v1"
	workoutv1 "github.com/zenx/backend/proto/workout/v1"
)

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require
// here.
type Resolver struct {
	AuthClient         authv1.AuthServiceClient
	WorkoutClient      workoutv1.WorkoutServiceClient
	ExerciseClient     exercisev1.ExerciseServiceClient
	ProfileClient      profilev1.ProfileServiceClient
	AnalyticsClient    analyticsv1.AnalyticsServiceClient
	NotificationClient notificationv1.NotificationServiceClient
}

// Services groups the downstream clients for easy wiring.
type Services struct {
	Auth         authv1.AuthServiceClient
	Workout      workoutv1.WorkoutServiceClient
	Exercise     exercisev1.ExerciseServiceClient
	Profile      profilev1.ProfileServiceClient
	Analytics    analyticsv1.AnalyticsServiceClient
	Notification notificationv1.NotificationServiceClient
}

func NewResolver(s Services) *Resolver {
	return &Resolver{
		AuthClient:         s.Auth,
		WorkoutClient:      s.Workout,
		ExerciseClient:     s.Exercise,
		ProfileClient:      s.Profile,
		AnalyticsClient:    s.Analytics,
		NotificationClient: s.Notification,
	}
}
