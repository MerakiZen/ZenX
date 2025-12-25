package config

import (
    "os"
    "time"
)

// Config captures runtime configuration loaded from the environment.
type Config struct {
    ServiceName        string
    GRPCPort           string
    MetricsPort        string
    DatabaseURL        string
    NATSURL            string
    AccessTokenSecret  string
    RefreshTokenSecret string
    AccessTokenTTL     time.Duration
    RefreshTokenTTL    time.Duration
}

// Load returns Config populated from environment variables with sane defaults.
func Load() Config {
    return Config{
        ServiceName:        getEnv("SERVICE_NAME", "Auth Service"),
        GRPCPort:           getEnv("GRPC_PORT", "8080"),
        MetricsPort:        getEnv("METRICS_PORT", "9090"),
        DatabaseURL:        getEnv("DATABASE_URL", "postgres://zenx:zenx@localhost:5432/zenx_auth?sslmode=disable"),
        NATSURL:            getEnv("NATS_URL", "nats://localhost:4222"),
        AccessTokenSecret:  getEnv("ACCESS_TOKEN_SECRET", "dev-secret-access"),
        RefreshTokenSecret: getEnv("REFRESH_TOKEN_SECRET", "dev-secret-refresh"),
        AccessTokenTTL:     getDuration("ACCESS_TOKEN_TTL", 15*time.Minute),
        RefreshTokenTTL:    getDuration("REFRESH_TOKEN_TTL", 7*24*time.Hour),
    }
}

func getEnv(key, fallback string) string {
    if val := os.Getenv(key); val != "" {
        return val
    }
    return fallback
}

func getDuration(key string, fallback time.Duration) time.Duration {
    if val := os.Getenv(key); val != "" {
        if d, err := time.ParseDuration(val); err == nil {
            return d
        }
    }
    return fallback
}
