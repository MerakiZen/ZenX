package events

// WorkoutCreatedPayload describes the message for workouts.created subject.
type WorkoutCreatedPayload struct {
	WorkoutID     string `json:"workout_id"`
	UserID        string `json:"user_id"`
	Name          string `json:"name"`
	ExerciseCount int    `json:"exercise_count"`
	TotalSets     int    `json:"total_sets"`
	Notes         string `json:"notes,omitempty"`
	CreatedAtUnix int64  `json:"created_at_unix"`
}
