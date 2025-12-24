# Quick Start Guide

## ✅ Current Status

All services are now running!

### Backend Services (Docker)
- **GraphQL Gateway**: http://localhost:4000/graphql
- **PostgreSQL**: localhost:5432
- **NATS**: localhost:4222
- **Grafana**: http://localhost:3000
- **Jaeger**: http://localhost:16686

### Microservices
- ✅ Auth Service
- ✅ Workout Service
- ✅ Exercise Service
- ✅ Profile Service
- ✅ Analytics Service
- ✅ Notification Service

### Frontend
- **Flutter App**: Starting on http://localhost:8080 (Chrome)

## 🚀 Starting Everything

### Stop All Services
```bash
cd /Users/devangsonawane/Downloads/NestJS-GraphQL-TypeORM-PostgresQL
docker compose -f docker-compose.go.yml down
```

### Start Backend Services
```bash
cd /Users/devangsonawane/Downloads/NestJS-GraphQL-TypeORM-PostgresQL
docker compose -f docker-compose.go.yml up -d
```

### Start Flutter App
```bash
cd /Users/devangsonawane/Downloads/NestJS-GraphQL-TypeORM-PostgresQL/ZenX-main
flutter run -d chrome --web-port=8080
```

Or for macOS desktop:
```bash
flutter run -d macos
```

## 🔍 Verify Services

### Check Docker Containers
```bash
docker compose -f docker-compose.go.yml ps
```

### Test GraphQL Gateway
```bash
curl -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __typename }"}'
```

### View Logs
```bash
# All services
docker compose -f docker-compose.go.yml logs -f

# Specific service
docker compose -f docker-compose.go.yml logs -f gateway
docker compose -f docker-compose.go.yml logs -f auth-service
```

## 📱 Access Points

- **Flutter App**: http://localhost:8080
- **GraphQL Playground**: http://localhost:4000/graphql (if enabled)
- **Grafana Dashboard**: http://localhost:3000
- **Jaeger Tracing**: http://localhost:16686

## 🛠️ Troubleshooting

### Services not starting?
```bash
# Check logs
docker compose -f docker-compose.go.yml logs

# Restart specific service
docker compose -f docker-compose.go.yml restart gateway
```

### Port already in use?
```bash
# Find what's using the port
lsof -i :4000
lsof -i :8080

# Kill the process or change port in docker-compose.go.yml
```

### Flutter app not connecting?
- Verify GraphQL gateway is running: `curl http://localhost:4000/graphql`
- Check `ZenX-main/lib/core/config/app_config.dart` has correct API URL
- Clear Flutter cache: `flutter clean && flutter pub get`


