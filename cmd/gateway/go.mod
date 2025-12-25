module github.com/zenx/backend/cmd/gateway

go 1.25

replace github.com/zenx/backend/proto => ../../proto

require (
	github.com/99designs/gqlgen v0.17.84
	github.com/go-chi/chi/v5 v5.2.3
	github.com/google/uuid v1.6.0
	github.com/vektah/gqlparser/v2 v2.5.31
	github.com/zenx/backend/proto v0.0.0-00010101000000-000000000000
	google.golang.org/grpc v1.78.0
)

require (
	github.com/agnivade/levenshtein v1.2.1 // indirect
	github.com/go-viper/mapstructure/v2 v2.4.0 // indirect
	github.com/gorilla/websocket v1.5.0 // indirect
	github.com/hashicorp/golang-lru/v2 v2.0.7 // indirect
	github.com/sosodev/duration v1.3.1 // indirect
	golang.org/x/net v0.47.0 // indirect
	golang.org/x/sys v0.38.0 // indirect
	golang.org/x/text v0.31.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20251029180050-ab9386a59fda // indirect
	google.golang.org/protobuf v1.36.11 // indirect
)
