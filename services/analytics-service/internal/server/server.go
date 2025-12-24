package server

import (
	"context"
	"fmt"
	"net"
	"os"
	"os/signal"
	"syscall"

	analyticsv1 "github.com/zenx/backend/proto/analytics/v1"
	workoutv1 "github.com/zenx/backend/proto/workout/v1"
	"github.com/zenx/backend/services/analytics-service/internal/config"
	"github.com/zenx/backend/services/analytics-service/internal/db"
	"github.com/zenx/backend/services/analytics-service/internal/health"
	"github.com/zenx/backend/services/analytics-service/internal/service"
	"github.com/zenx/backend/services/analytics-service/internal/store"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/health/grpc_health_v1"
)

// Run starts the analytics-service gRPC server.
func Run() error {
	cfg := config.Load()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	pool, err := db.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		return fmt.Errorf("connect database: %w", err)
	}
	defer pool.Close()

	if err := db.EnsureSchema(ctx, pool); err != nil {
		return fmt.Errorf("ensure schema: %w", err)
	}

	repo := store.NewRepository(pool)

	workoutConn, err := grpc.DialContext(ctx, cfg.WorkoutAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return fmt.Errorf("connect workout service: %w", err)
	}
	defer workoutConn.Close()

	analyticsSvc := service.New(repo, workoutv1.NewWorkoutServiceClient(workoutConn))

	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", cfg.GRPCPort))
	if err != nil {
		return fmt.Errorf("listen: %w", err)
	}
	defer lis.Close()

	grpcServer := grpc.NewServer()
	analyticsv1.RegisterAnalyticsServiceServer(grpcServer, analyticsSvc)
	grpc_health_v1.RegisterHealthServer(grpcServer, health.New(pool))

	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		grpcServer.GracefulStop()
		cancel()
	}()

	fmt.Printf("%s listening on %s\n", cfg.ServiceName, cfg.GRPCPort)
	if err := grpcServer.Serve(lis); err != nil {
		return fmt.Errorf("serve gRPC: %w", err)
	}
	return nil
}
