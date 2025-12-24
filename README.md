# ZenX - Complete Setup & Deployment Guide

**ZenX** is a production-grade fitness tracking platform built with Go microservices, GraphQL, and Flutter. This guide will take you from a fresh computer to a fully deployed production application.

---

## Table of Contents

1. [What is ZenX?](#what-is-zenx)
2. [Prerequisites & Installation](#prerequisites--installation)
3. [Local Development Setup](#local-development-setup)
4. [Running the Application](#running-the-application)
5. [Testing](#testing)
6. [Building for Production](#building-for-production)
7. [Kubernetes Deployment](#kubernetes-deployment)
8. [Frontend Setup](#frontend-setup)
9. [Troubleshooting](#troubleshooting)
10. [Production Deployment](#production-deployment)

---

## What is ZenX?

ZenX is a comprehensive fitness tracking application that enables users to:
- Track workouts, exercises, sets, and reps
- Monitor fitness progress over time
- View analytics and personal records
- Share workouts on a social feed
- Receive notifications

**Architecture:**
- **Backend:** 6 Go microservices (Auth, Workout, Exercise, Profile, Analytics, Notification)
- **API Gateway:** GraphQL (gRPC internally)
- **Database:** PostgreSQL
- **Message Queue:** NATS
- **Frontend:** Flutter (Web, Android, iOS)

---

## Prerequisites & Installation

### Step 1: Install Required Software

#### macOS (Recommended)

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Go
brew install go

# Install Buf (Protocol Buffer tool)
brew install bufbuild/buf/buf

# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop
# Or via Homebrew:
brew install --cask docker

# Install Make (usually pre-installed)
# Verify: make --version

# Install kubectl (for Kubernetes)
brew install kubectl

# Optional: Install Terraform (for infrastructure)
brew install terraform
```

#### Linux (Ubuntu/Debian)

```bash
# Install Go
wget https://go.dev/dl/go1.25.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.25.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install Buf
curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-Linux-x86_64" -o "/usr/local/bin/buf"
chmod +x /usr/local/bin/buf

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### Windows

1. Install Go: https://go.dev/dl/
2. Install Docker Desktop: https://www.docker.com/products/docker-desktop
3. Install Buf: Download from https://github.com/bufbuild/buf/releases
4. Install WSL2 and follow Linux instructions for kubectl

### Step 2: Verify Installations

```bash
# Check Go version (should be 1.21+)
go version

# Check Buf
buf --version

# Check Docker
docker --version
docker compose version

# Check kubectl
kubectl version --client

# Check Make
make --version
```

### Step 3: Clone the Repository

```bash
# Navigate to your workspace
cd ~/Downloads  # or wherever you prefer

# Clone the repository (or navigate if already cloned)
cd NestJS-GraphQL-TypeORM-PostgresQL

# Verify you're in the right directory
pwd
ls -la
```

---

## Local Development Setup

### Step 1: Generate Protocol Buffer Code

```bash
# From the repository root
make proto

# Or manually:
./scripts/generate-protos.sh
```

This generates gRPC code for all services.

### Step 2: Set Up Local Databases (Optional - Docker Compose handles this)

If running services individually (not using Docker Compose):

```bash
# Start PostgreSQL
docker run -d --name zenx-postgres \
  -e POSTGRES_PASSWORD=zenx \
  -e POSTGRES_USER=zenx \
  -p 5432:5432 \
  postgres:15

# Wait a few seconds, then create databases
docker exec -it zenx-postgres psql -U zenx -c "CREATE DATABASE zenx_auth;"
docker exec -it zenx-postgres psql -U zenx -c "CREATE DATABASE zenx_workout;"
docker exec -it zenx-postgres psql -U zenx -c "CREATE DATABASE zenx_exercise;"
docker exec -it zenx-postgres psql -U zenx -c "CREATE DATABASE zenx_profile;"
docker exec -it zenx-postgres psql -U zenx -c "CREATE DATABASE zenx_analytics;"
docker exec -it zenx-postgres psql -U zenx -c "CREATE DATABASE zenx_notification;"

# Start NATS
docker run -d --name zenx-nats -p 4222:4222 nats:2.10
```

---

## Running the Application

### Option 1: Docker Compose (Easiest - Recommended)

This starts everything with one command:

```bash
# From repository root
docker compose -f docker-compose.go.yml up --build

# This will:
# - Build all 6 microservices + gateway
# - Start PostgreSQL with all databases
# - Start NATS
# - Start Jaeger (tracing)
# - Start Grafana (monitoring)
# - Start all services

# Access points:
# - GraphQL Gateway: http://localhost:4000/graphql
# - GraphQL Playground: http://localhost:4000/playground
# - Grafana: http://localhost:3000 (admin/admin)
# - Jaeger: http://localhost:16686
```

**Stop everything:**
```bash
docker compose -f docker-compose.go.yml down
```

**Stop and remove volumes:**
```bash
docker compose -f docker-compose.go.yml down -v
```

### Option 2: Run Services Individually

#### Start Dependencies First

```bash
# Start PostgreSQL and NATS (if not using Docker Compose)
make dev-infra

# Or manually:
docker compose -f docker-compose.go.yml up postgres-primary nats -d
```

#### Start Each Service

**Terminal 1 - Auth Service:**
```bash
cd services/auth-service
go run ./cmd/server
# Listening on :8080
```

**Terminal 2 - Workout Service:**
```bash
cd services/workout-service
GRPC_PORT=8081 go run ./cmd/server
# Listening on :8081
```

**Terminal 3 - Exercise Service:**
```bash
cd services/exercise-service
GRPC_PORT=8083 go run ./cmd/server
# Listening on :8083
```

**Terminal 4 - Profile Service:**
```bash
cd services/profile-service
GRPC_PORT=8084 go run ./cmd/server
# Listening on :8084
```

**Terminal 5 - Analytics Service:**
```bash
cd services/analytics-service
GRPC_PORT=8085 WORKOUT_SERVICE_ADDR=localhost:8081 go run ./cmd/server
# Listening on :8085
```

**Terminal 6 - Notification Service:**
```bash
cd services/notification-service
GRPC_PORT=8086 go run ./cmd/server
# Listening on :8086
```

**Terminal 7 - GraphQL Gateway:**
```bash
cd cmd/gateway
go run main.go
# Listening on :4000
```

### Step 3: Test the Application

```bash
# Test health endpoint
curl http://localhost:4000/health
# Should return: OK

# Open GraphQL Playground
open http://localhost:4000/playground
# Or visit in browser: http://localhost:4000/playground

# Test login mutation
# In GraphQL Playground, run:
mutation {
  login(email: "test@example.com", password: "password123") {
    accessToken
    refreshToken
    expiresAt
  }
}
```

---

## Testing

### Run Unit Tests

```bash
# Test all services
go test ./services/... ./cmd/gateway/...

# Test specific service
cd services/auth-service
go test ./...

# Test with coverage
go test -cover ./services/...
```

### Test GraphQL API

```bash
# Using curl
curl -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __typename }"}'

# Using GraphQL Playground
# Visit http://localhost:4000/playground
```

### Test gRPC Services Directly

```bash
# Install grpcurl
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Test health check
grpcurl -plaintext localhost:8080 grpc.health.v1.Health/Check

# List services
grpcurl -plaintext localhost:8080 list
```

---

## Building for Production

### Step 1: Build Docker Images

```bash
# Build all images at once
make build-images

# Or build individually:
docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/auth-service -t zenx/auth-service:latest .
docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/workout-service -t zenx/workout-service:latest .
docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/exercise-service -t zenx/exercise-service:latest .
docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/profile-service -t zenx/profile-service:latest .
docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/analytics-service -t zenx/analytics-service:latest .
docker build -f Dockerfile.service --build-arg SERVICE_PATH=services/notification-service -t zenx/notification-service:latest .
docker build -f cmd/gateway/Dockerfile -t zenx/gateway:latest .

# Verify images
docker images | grep zenx
```

### Step 2: Tag for Registry

```bash
# Replace with your registry
REGISTRY=your-registry.com

docker tag zenx/auth-service:latest $REGISTRY/zenx/auth-service:v1.0.0
docker tag zenx/workout-service:latest $REGISTRY/zenx/workout-service:v1.0.0
docker tag zenx/exercise-service:latest $REGISTRY/zenx/exercise-service:v1.0.0
docker tag zenx/profile-service:latest $REGISTRY/zenx/profile-service:v1.0.0
docker tag zenx/analytics-service:latest $REGISTRY/zenx/analytics-service:v1.0.0
docker tag zenx/notification-service:latest $REGISTRY/zenx/notification-service:v1.0.0
docker tag zenx/gateway:latest $REGISTRY/zenx/gateway:v1.0.0
```

### Step 3: Push to Registry

```bash
# Login to registry
docker login $REGISTRY

# Push all images
docker push $REGISTRY/zenx/auth-service:v1.0.0
docker push $REGISTRY/zenx/workout-service:v1.0.0
docker push $REGISTRY/zenx/exercise-service:v1.0.0
docker push $REGISTRY/zenx/profile-service:v1.0.0
docker push $REGISTRY/zenx/analytics-service:v1.0.0
docker push $REGISTRY/zenx/notification-service:v1.0.0
docker push $REGISTRY/zenx/gateway:v1.0.0
```

---

## Kubernetes Deployment

### Step 1: Set Up Kubernetes Cluster

#### Option A: Docker Desktop (Easiest for Local)

1. Open **Docker Desktop**
2. Go to **Settings** → **Kubernetes**
3. Check **"Enable Kubernetes"**
4. Click **"Apply & Restart"**
5. Wait 2-3 minutes

```bash
# Verify
kubectl config use-context docker-desktop
kubectl cluster-info
```

#### Option B: Minikube

```bash
# Install minikube
brew install minikube  # macOS
# Or: https://minikube.sigs.k8s.io/docs/start/

# Start cluster
minikube start

# Verify
kubectl config use-context minikube
kubectl cluster-info
```

#### Option C: Cloud Cluster (AWS EKS, GCP GKE, Azure AKS)

```bash
# For AWS EKS
aws eks update-kubeconfig --name zenx-dev-eks --region us-east-1

# For GCP GKE
gcloud container clusters get-credentials zenx-cluster --region us-central1

# For Azure AKS
az aks get-credentials --resource-group zenx-rg --name zenx-cluster
```

### Step 2: Create Namespace

```bash
# From repository root
cd /Users/devangsonawane/Downloads/NestJS-GraphQL-TypeORM-PostgresQL

kubectl create namespace zenx
```

### Step 3: Create Secrets

```bash
# Create PostgreSQL credentials secret
# Replace connection strings with your actual database URLs
kubectl create secret generic postgres-credentials \
  --from-literal=auth-connection-string="postgres://zenx:zenx@postgres-primary:5432/zenx_auth?sslmode=disable" \
  --from-literal=workout-connection-string="postgres://zenx:zenx@postgres-primary:5432/zenx_workout?sslmode=disable" \
  --from-literal=exercise-connection-string="postgres://zenx:zenx@postgres-primary:5432/zenx_exercise?sslmode=disable" \
  --from-literal=profile-connection-string="postgres://zenx:zenx@postgres-primary:5432/zenx_profile?sslmode=disable" \
  --from-literal=analytics-connection-string="postgres://zenx:zenx@postgres-primary:5432/zenx_analytics?sslmode=disable" \
  --from-literal=notification-connection-string="postgres://zenx:zenx@postgres-primary:5432/zenx_notification?sslmode=disable" \
  --namespace=zenx

# Create JWT secrets (generate secure random strings)
kubectl create secret generic jwt-secrets \
  --from-literal=access-token-secret="$(openssl rand -base64 32)" \
  --from-literal=refresh-token-secret="$(openssl rand -base64 32)" \
  --namespace=zenx

# Verify secrets
kubectl get secrets -n zenx
```

### Step 4: Update Image Tags in Manifests (If Using Registry)

If you pushed images to a registry, update the manifests:

```bash
# Edit each service manifest
# Change: image: zenx/auth-service:latest
# To: image: your-registry.com/zenx/auth-service:v1.0.0
```

### Step 5: Deploy Services

```bash
# Make sure you're in the repo root!
pwd  # Should show: .../NestJS-GraphQL-TypeORM-PostgresQL

# Deploy everything
kubectl apply -k deploy/k8s/base/

# Or deploy individually:
kubectl apply -f deploy/k8s/base/namespace.yaml
kubectl apply -f deploy/k8s/base/configmap.yaml
kubectl apply -f deploy/k8s/base/services/
```

### Step 6: Verify Deployment

```bash
# Check pods
kubectl get pods -n zenx

# Check services
kubectl get services -n zenx

# Check deployments
kubectl get deployments -n zenx

# Watch pods (Ctrl+C to exit)
kubectl get pods -n zenx -w

# Check logs
kubectl logs -n zenx deployment/auth-service
kubectl logs -n zenx deployment/gateway -f  # Follow logs
```

### Step 7: Access the Gateway

```bash
# Port forward (for testing)
kubectl port-forward -n zenx service/gateway 4000:80

# Then access:
# http://localhost:4000/graphql
# http://localhost:4000/playground

# Or get LoadBalancer IP
kubectl get service gateway -n zenx
# Use EXTERNAL-IP from output
```

### Step 8: Deploy PostgreSQL and NATS to Kubernetes

You need PostgreSQL and NATS running in your cluster. Options:

**Option A:** Use Helm charts
```bash
# PostgreSQL
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgres bitnami/postgresql -n zenx

# NATS
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats -n zenx
```

**Option B:** Use Docker Compose for dependencies only
```bash
docker compose -f docker-compose.go.yml up postgres-primary nats -d
```

**Option C:** Use managed services (RDS, Cloud SQL, etc.)

---

## Frontend Setup

### Prerequisites

```bash
# Install Flutter
# macOS:
brew install --cask flutter

# Or download from: https://flutter.dev/docs/get-started/install

# Verify
flutter doctor
```

### Run Flutter App

```bash
# Navigate to Flutter app
cd ZenX-main

# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on iOS simulator (macOS only)
flutter run -d ios

# Run on Android emulator
flutter run -d android

# The app will connect to: http://localhost:4000/graphql
```

### Build for Production

```bash
# Web
flutter build web

# Android APK
flutter build apk --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

---

## Troubleshooting

### "Unable to connect to the server" (kubectl)

**Problem:** No Kubernetes cluster is running.

**Solution:**
```bash
# Check current context
kubectl config current-context

# List available contexts
kubectl config get-contexts

# Switch to Docker Desktop
kubectl config use-context docker-desktop

# Or start minikube
minikube start
```

### "not a valid directory" (kubectl apply)

**Problem:** Not in the repository root.

**Solution:**
```bash
cd /Users/devangsonawane/Downloads/NestJS-GraphQL-TypeORM-PostgresQL
pwd  # Verify you're in the right place
```

### Pods in CrashLoopBackOff

**Problem:** Service is crashing.

**Solution:**
```bash
# Check logs
kubectl logs -n zenx <pod-name>

# Describe pod for events
kubectl describe pod -n zenx <pod-name>

# Common issues:
# - Database connection errors → Check secrets
# - Image pull errors → Check image exists
# - Resource limits → Check pod resources
```

### Database Connection Errors

**Problem:** Services can't connect to PostgreSQL.

**Solution:**
```bash
# Verify PostgreSQL is running
kubectl get pods -n zenx | grep postgres
# Or
docker ps | grep postgres

# Check connection string in secrets
kubectl get secret postgres-credentials -n zenx -o yaml

# Test connection manually
kubectl exec -n zenx -it <postgres-pod> -- psql -U zenx -d zenx_auth
```

### Port Already in Use

**Problem:** Port 4000 (or other) is already in use.

**Solution:**
```bash
# Find process using port
lsof -i :4000  # macOS
# Or
netstat -tulpn | grep 4000  # Linux

# Kill process or change port
# In docker-compose.go.yml, change ports mapping
```

### Health Check Failures

**Problem:** Kubernetes health probes failing.

**Solution:**
```bash
# Test health check manually
kubectl exec -n zenx <pod-name> -- /bin/grpc_health_probe -addr=:8080

# Check if grpc-health-probe exists in container
kubectl exec -n zenx <pod-name> -- ls -la /bin/grpc_health_probe
```

### "go: cannot find module"

**Problem:** Go modules not downloaded.

**Solution:**
```bash
# From service directory
cd services/auth-service
go mod download
go mod tidy
```

### Docker Build Fails

**Problem:** Build context issues.

**Solution:**
```bash
# Make sure you're in repo root
cd /Users/devangsonawane/Downloads/NestJS-GraphQL-TypeORM-PostgresQL

# Clean Docker cache
docker system prune -a

# Rebuild
docker compose -f docker-compose.go.yml build --no-cache
```

---

## Production Deployment

### Step 1: Infrastructure Setup (Terraform)

```bash
# Navigate to Terraform directory
cd infra/terraform/environments/prod

# Initialize Terraform
terraform init

# Review plan
terraform plan -var-file=prod.tfvars

# Apply (creates AWS/GCP/Azure resources)
terraform apply -var-file=prod.tfvars

# This creates:
# - Kubernetes cluster
# - VPC and networking
# - PostgreSQL (RDS/Cloud SQL)
# - Monitoring stack
```

### Step 2: Configure CI/CD

Set up GitHub Actions or your CI/CD pipeline:

```bash
# .github/workflows/backend-ci.yml is already configured
# It will:
# - Run tests
# - Build Docker images
# - Push to registry
# - Deploy to Kubernetes (if configured)
```

### Step 3: Set Up Monitoring

```bash
# Prometheus and Grafana are deployed via Terraform
# Access Grafana:
kubectl port-forward -n observability svc/kube-prometheus-stack-grafana 3000:80

# Default credentials: admin / (check Terraform output)
```

### Step 4: Set Up Ingress

```bash
# Install ingress controller (nginx example)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Create ingress resource
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: zenx-ingress
  namespace: zenx
spec:
  rules:
  - host: api.zenx.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gateway
            port:
              number: 80
EOF
```

### Step 5: Set Up TLS/SSL

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create certificate
# (Configure with your DNS provider)
```

### Step 6: Database Backups

```bash
# Set up automated backups
# For RDS: Enable automated backups in Terraform
# For self-managed: Use cron jobs or backup tools
```

### Step 7: Security Hardening

- [ ] Enable TLS/mTLS between services
- [ ] Set up network policies
- [ ] Configure RBAC
- [ ] Use secrets management (AWS Secrets Manager, Vault)
- [ ] Enable pod security policies
- [ ] Set up WAF (Web Application Firewall)

---

## Make Commands Reference

```bash
# Generate Protocol Buffers
make proto

# Format code
make fmt

# Tidy dependencies
make tidy

# Lint code
make lint

# Start dev infrastructure (PostgreSQL, NATS)
make dev-infra

# Stop dev infrastructure
make dev-down

# Build all Docker images
make build-images
```

---

## Service Ports Reference

| Service | Port | Description |
|---------|------|-------------|
| auth-service | 8080 | Authentication & authorization |
| workout-service | 8081 | Workout management |
| exercise-service | 8083 | Exercise library |
| profile-service | 8084 | User profiles |
| analytics-service | 8085 | Analytics & insights |
| notification-service | 8086 | Notifications |
| gateway | 4000 | GraphQL API gateway |

---

## Architecture Overview

```
┌─────────────────┐
│  Flutter App    │
│  (Web/Mobile)   │
└────────┬─────────┘
         │ GraphQL
         ▼
┌─────────────────┐
│  GraphQL Gateway│
│   (Port 4000)   │
└────────┬─────────┘
         │ gRPC
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌────────┐
│ Auth   │ │Workout │ ... (6 services)
│ :8080  │ │ :8081  │
└───┬────┘ └───┬────┘
    │          │
    ▼          ▼
┌─────────────────┐
│   PostgreSQL    │
│   (6 databases)  │
└─────────────────┘
```

---

## Support & Resources

- **Product Requirements:** See `claude` file
- **Protocol Buffers:** `proto/` directory
- **Kubernetes Manifests:** `deploy/k8s/` directory
- **Terraform Infrastructure:** `infra/terraform/` directory

---

## License

MIT

---

**Need Help?** Check the troubleshooting section or review the service-specific README files in each service directory.
