package main

import (
    "log"

    "github.com/zenx/backend/services/auth-service/internal/server"
)

func main() {
    if err := server.Run(); err != nil {
        log.Fatalf("failed to start auth service: %v", err)
    }
}
