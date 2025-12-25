package server

import (
	"context"
	"fmt"
	"net"
	"os"
	"os/signal"
	"syscall"

	profilev1 "github.com/zenx/backend/proto/profile/v1"
	"github.com/zenx/backend/services/profile-service/internal/config"
	"github.com/zenx/backend/services/profile-service/internal/db"
	"github.com/zenx/backend/services/profile-service/internal/health"
	"github.com/zenx/backend/services/profile-service/internal/service"
	"github.com/zenx/backend/services/profile-service/internal/store"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health/grpc_health_v1"
)

// Run boots the profile-service gRPC server.
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
	profileSvc := service.New(repo)

	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", cfg.GRPCPort))
	if err != nil {
		return fmt.Errorf("listen: %w", err)
	}
	defer lis.Close()

	grpcServer := grpc.NewServer()
	profilev1.RegisterProfileServiceServer(grpcServer, profileSvc)
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
