package config

import "os"

// Config captures runtime configuration loaded from the environment.
type Config struct {
	ServiceName string
	GRPCPort    string
	MetricsPort string
	DatabaseURL string
	NATSURL     string
}

// Load returns Config populated from environment variables with sane defaults.
func Load() Config {
	return Config{
		ServiceName: getEnv("SERVICE_NAME", "Workout Service"),
		GRPCPort:    getEnv("GRPC_PORT", "8080"),
		MetricsPort: getEnv("METRICS_PORT", "9090"),
		DatabaseURL: getEnv("DATABASE_URL", "postgres://zenx:zenx@localhost:5432/zenx_workout?sslmode=disable"),
		NATSURL:     getEnv("NATS_URL", "nats://localhost:4222"),
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
