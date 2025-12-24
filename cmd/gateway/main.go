package main

import (
	"context"
	"crypto/tls"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/zenx/backend/cmd/gateway/graph"
	analyticsv1 "github.com/zenx/backend/proto/analytics/v1"
	authv1 "github.com/zenx/backend/proto/auth/v1"
	exercisev1 "github.com/zenx/backend/proto/exercise/v1"
	notificationv1 "github.com/zenx/backend/proto/notification/v1"
	profilev1 "github.com/zenx/backend/proto/profile/v1"
	workoutv1 "github.com/zenx/backend/proto/workout/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type Config struct {
	ListenAddr       string
	AuthAddr         string
	WorkoutAddr      string
	ExerciseAddr     string
	ProfileAddr      string
	AnalyticsAddr    string
	NotificationAddr string
}

func loadConfig() Config {
	return Config{
		ListenAddr:       getEnv("GATEWAY_LISTEN", ":4000"),
		AuthAddr:         getEnv("AUTH_ADDR", "localhost:8080"),
		WorkoutAddr:      getEnv("WORKOUT_ADDR", "localhost:8081"),
		ExerciseAddr:     getEnv("EXERCISE_ADDR", "localhost:8083"),
		ProfileAddr:      getEnv("PROFILE_ADDR", "localhost:8084"),
		AnalyticsAddr:    getEnv("ANALYTICS_ADDR", "localhost:8085"),
		NotificationAddr: getEnv("NOTIFICATION_ADDR", "localhost:8086"),
	}
}

func main() {
	cfg := loadConfig()
	ctx := context.Background()

	dial := func(target string) *grpc.ClientConn {
		conn, err := grpc.DialContext(ctx, target, grpc.WithTransportCredentials(insecure.NewCredentials()))
		if err != nil {
			log.Fatalf("failed to connect to %s: %v", target, err)
		}
		return conn
	}

	authClient := authv1.NewAuthServiceClient(dial(cfg.AuthAddr))
	workoutClient := workoutv1.NewWorkoutServiceClient(dial(cfg.WorkoutAddr))
	exerciseClient := exercisev1.NewExerciseServiceClient(dial(cfg.ExerciseAddr))
	profileClient := profilev1.NewProfileServiceClient(dial(cfg.ProfileAddr))
	analyticsClient := analyticsv1.NewAnalyticsServiceClient(dial(cfg.AnalyticsAddr))
	notificationClient := notificationv1.NewNotificationServiceClient(dial(cfg.NotificationAddr))

	resolver := graph.NewResolver(graph.Services{
		Auth:         authClient,
		Workout:      workoutClient,
		Exercise:     exerciseClient,
		Profile:      profileClient,
		Analytics:    analyticsClient,
		Notification: notificationClient,
	})

	gqlServer := handler.NewDefaultServer(graph.NewExecutableSchema(graph.Config{Resolvers: resolver}))

	router := chi.NewRouter()
	router.Use(corsMiddleware)
	router.Use(requestLogger)
	router.Use(authMiddleware(authClient))
	router.Handle("/health", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}))
	router.Handle("/playground", playground.Handler("ZenX GraphQL", "/graphql"))
	router.Handle("/graphql", gqlServer)

	server := &http.Server{
		Addr:      cfg.ListenAddr,
		Handler:   router,
		TLSConfig: &tls.Config{MinVersion: tls.VersionTLS12},
	}

	log.Printf("GraphQL gateway listening on %s", cfg.ListenAddr)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("gateway failed: %v", err)
	}
}

func authMiddleware(authClient authv1.AuthServiceClient) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()
			token := extractBearerToken(r.Header.Get("Authorization"))
			if token != "" {
				resp, err := authClient.ValidateToken(ctx, &authv1.ValidateTokenRequest{AccessToken: token})
				if err == nil && resp.GetValid() && resp.GetContext() != nil {
					ctx = graph.WithUserContext(ctx, graph.UserContext{
						UserID: resp.GetContext().GetUserId(),
					})
				}
			}
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func extractBearerToken(header string) string {
	if header == "" {
		return ""
	}
	parts := strings.SplitN(header, " ", 2)
	if len(parts) != 2 {
		return ""
	}
	if !strings.EqualFold(parts[0], "Bearer") {
		return ""
	}
	return strings.TrimSpace(parts[1])
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		w.Header().Set("Access-Control-Max-Age", "3600")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func requestLogger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		requestID := uuid.NewString()
		log.Printf("%s %s %s", requestID, r.Method, r.URL.Path)
		next.ServeHTTP(w, r)
		log.Printf("%s completed in %s", requestID, time.Since(start))
	})
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
