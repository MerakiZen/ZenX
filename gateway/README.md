# ZenX GraphQL Gateway

The gateway exposes a unified GraphQL endpoint for every Flutter client. It uses Apollo Router in federation mode and delegates field-level resolution to the domain microservices over gRPC via dedicated subgraph adapters.

## Structure
- `config/router.yaml` – Apollo Router configuration (telemetry, headers, auth hooks)
- `supergraph/schema.graphql` – Composed GraphQL schema stitched from microservice subgraphs
- `cmd/gateway` – Go gateway service that implements subgraph resolvers and gRPC clients for each backend service

## Running locally

```bash
# start the Go gateway (listens on :4000) and enable live reload of the schema
cd cmd/gateway
go run main.go

# optional: run Apollo Router for query planning/telemetry (if desired)
cd gateway
apollo-router --config config/router.yaml --supergraph supergraph/schema.graphql
```

The Go gateway exposes `POST /graphql` for all GraphQL operations and `GET /playground` for in-browser testing. Authenticated operations expect an `Authorization: Bearer <access_token>` header; unauthenticated calls (e.g., `login`) omit it.

## Authentication flow
1. Clients authenticate via `mutation login`.
2. The Go gateway calls the Auth Service gRPC API to validate JWTs and obtain user context.
3. User context is injected into every downstream gRPC call (workout/exercise/profile/analytics/notification).

See `claude` PRD §4 for the detailed sequence diagram.
