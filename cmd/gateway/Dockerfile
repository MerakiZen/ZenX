# syntax=docker/dockerfile:1

FROM golang:1.25-alpine AS builder
WORKDIR /workspace
ENV GOWORK=off

COPY go.work go.work.sum ./
COPY proto proto
COPY cmd/gateway cmd/gateway

RUN cd cmd/gateway && go mod tidy && go mod download
RUN cd cmd/gateway && CGO_ENABLED=0 GOOS=linux go build -o /gateway .

FROM alpine:3.19
WORKDIR /app
RUN apk --no-cache add ca-certificates
COPY --from=builder /gateway /app/gateway
EXPOSE 4000
ENTRYPOINT ["/app/gateway"]

