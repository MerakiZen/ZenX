package main

import (
	"log"

	"github.com/zenx/backend/services/analytics-service/internal/server"
)

func main() {
	if err := server.Run(); err != nil {
		log.Fatalf("failed to start analytics service: %v", err)
	}
}
