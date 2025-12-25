SHELL := /bin/bash
ROOT_DIR := $(shell pwd)
SERVICES := auth workout exercise profile analytics notification

.PHONY: proto fmt tidy dev-infra dev-down lint build-images

proto:
	./scripts/generate-protos.sh

fmt:
	@for svc in $(SERVICES); do \
		find services/$$svc-service -name '*.go' -print0 | xargs -0 gofmt -w; \
	done

lint:
	@for svc in $(SERVICES); do \
		( cd services/$$svc-service && golangci-lint run ./... ); \
	done

 tidy:
	@for svc in $(SERVICES); do \
		( cd services/$$svc-service && go mod tidy ); \
	done

 dev-infra:
	docker compose -f docker-compose.go.yml up -d

 dev-down:
	docker compose -f docker-compose.go.yml down -v

build-images:
	@echo "Building all service images..."
	docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/auth-service -t zenx/auth-service:latest .
	docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/workout-service -t zenx/workout-service:latest .
	docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/exercise-service -t zenx/exercise-service:latest .
	docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/profile-service -t zenx/profile-service:latest .
	docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/analytics-service -t zenx/analytics-service:latest .
	docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/notification-service -t zenx/notification-service:latest .
	docker build -f cmd/gateway/Dockerfile -t zenx/gateway:latest .
	@echo "All images built successfully!"
