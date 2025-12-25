package events

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/nats-io/nats.go"
)

const (
	SubjectWorkoutCreated = "workouts.created"
)

// Publisher wraps a NATS connection for emitting domain events.
type Publisher struct {
	nc *nats.Conn
}

// NewPublisher connects to NATS and ties the lifetime to ctx.
func NewPublisher(ctx context.Context, url string) (*Publisher, error) {
	conn, err := nats.Connect(url)
	if err != nil {
		return nil, fmt.Errorf("connect to NATS: %w", err)
	}
	go func() {
		<-ctx.Done()
		conn.Drain()
	}()
	return &Publisher{nc: conn}, nil
}

// Close drains the underlying connection.
func (p *Publisher) Close() {
	if p == nil || p.nc == nil {
		return
	}
	_ = p.nc.Drain()
}

// Publish emits the provided payload on subject after JSON encoding.
func (p *Publisher) Publish(subject string, data interface{}) error {
	payload, err := json.Marshal(data)
	if err != nil {
		return fmt.Errorf("marshal event: %w", err)
	}
	return p.nc.Publish(subject, payload)
}
