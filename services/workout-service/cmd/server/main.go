package main

import (
	"log"

	"github.com/zenx/backend/services/workout-service/internal/server"
)

func main() {
	if err := server.Run(); err != nil {
		log.Fatalf("failed to start workout service: %v", err)
	}
}
