package queue

import (
	"context"
	"encoding/json"
	"log"
	"strconv"

	"github.com/google/uuid"
	"github.com/nats-io/nats.go"
	"github.com/zenx/backend/services/notification-service/internal/store"
)

const (
	subjectWorkoutCreated = "workouts.created"
	queueGroup            = "notification-workers"
)

// Worker handles background NATS subscriptions.
type Worker struct {
	nc  *nats.Conn
	sub *nats.Subscription
}

// StartWorkoutCreatedConsumer listens for workout created events and enqueues notifications.
func StartWorkoutCreatedConsumer(ctx context.Context, url string, repo *store.Repository) (*Worker, error) {
	nc, err := nats.Connect(url)
	if err != nil {
		return nil, err
	}

	worker := &Worker{nc: nc}
	handler := func(msg *nats.Msg) {
		var payload WorkoutCreatedMessage
		if err := json.Unmarshal(msg.Data, &payload); err != nil {
			log.Printf("queue: decode workout event: %v", err)
			return
		}
		userID, err := uuid.Parse(payload.UserID)
		if err != nil {
			log.Printf("queue: invalid user id %q: %v", payload.UserID, err)
			return
		}
		templatePayload := map[string]string{
			"workout_name":   payload.Name,
			"exercise_count": strconv.Itoa(payload.ExerciseCount),
			"total_sets":     strconv.Itoa(payload.TotalSets),
		}
		if payload.Notes != "" {
			templatePayload["notes"] = payload.Notes
		}
		if _, err := repo.Enqueue(ctx, store.Notification{
			UserID:   userID,
			Template: "workout.summary",
			Payload:  templatePayload,
		}); err != nil {
			log.Printf("queue: enqueue notification: %v", err)
		}
	}

	sub, err := nc.QueueSubscribe(subjectWorkoutCreated, queueGroup, handler)
	if err != nil {
		nc.Close()
		return nil, err
	}
	worker.sub = sub

	go func() {
		<-ctx.Done()
		worker.Close()
	}()

	return worker, nil
}

// Close drains the subscription and connection.
func (w *Worker) Close() {
	if w == nil {
		return
	}
	if w.sub != nil {
		if err := w.sub.Drain(); err != nil {
			log.Printf("queue: drain subscription: %v", err)
		}
	}
	if w.nc != nil {
		w.nc.Drain()
	}
}

// WorkoutCreatedMessage mirrors the payload produced by workout service.
type WorkoutCreatedMessage struct {
	WorkoutID     string `json:"workout_id"`
	UserID        string `json:"user_id"`
	Name          string `json:"name"`
	ExerciseCount int    `json:"exercise_count"`
	TotalSets     int    `json:"total_sets"`
	Notes         string `json:"notes"`
	CreatedAtUnix int64  `json:"created_at_unix"`
}
