#!/bin/bash
echo "=== Testing ZenX Backend ==="
echo ""

echo "1. Health Check:"
curl -s http://localhost:4000/health && echo ""
echo ""

echo "2. GraphQL Exercises Query:"
curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ exercises(limit: 5) { id name category } }"}' | jq '.data.exercises | length' || echo "Failed"
echo ""

echo "3. GraphQL Schema Introspection:"
curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { queryType { name } } }"}' | jq '.data.queryType.name' || echo "Failed"
echo ""

echo "4. Service Status:"
docker compose -f docker-compose.go.yml ps --format "{{.Service}}: {{.Status}}" | grep -E "Up|Exit"
echo ""

echo "=== Test Complete ==="
