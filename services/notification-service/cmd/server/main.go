package main

import (
	"log"

	"github.com/zenx/backend/services/notification-service/internal/server"
)

func main() {
	if err := server.Run(); err != nil {
		log.Fatalf("failed to start notification service: %v", err)
	}
}
