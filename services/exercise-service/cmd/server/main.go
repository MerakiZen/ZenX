package main

import (
	"log"

	"github.com/zenx/backend/services/exercise-service/internal/server"
)

func main() {
	if err := server.Run(); err != nil {
		log.Fatalf("failed to start exercise service: %v", err)
	}
}
