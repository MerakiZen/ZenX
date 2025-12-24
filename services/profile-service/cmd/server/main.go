package main

import (
	"log"

	"github.com/zenx/backend/services/profile-service/internal/server"
)

func main() {
	if err := server.Run(); err != nil {
		log.Fatalf("failed to start profile service: %v", err)
	}
}
