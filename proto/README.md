# ZenX Protobuf Definitions

This directory stores the canonical Protocol Buffer contracts for every ZenX microservice. Contracts are organized by bounded context (e.g. `auth/v1`, `workout/v1`). All gRPC services import the shared messages defined here, and code generation is handled through `buf`.

## Usage

```bash
cd proto
buf lint
buf generate
```

`buf.gen.yaml` now emits `*.pb.go`, `*_grpc.pb.go`, and Connect stubs directly into each module folder (e.g. `auth/v1`). The Go services import from `github.com/zenx/backend/proto/...`, keeping every contract versioned in one location.
