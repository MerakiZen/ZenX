#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
PROTO_DIR="$ROOT_DIR/proto"

if ! command -v buf &>/dev/null; then
  echo "[warn] buf CLI not found in PATH. Install via https://buf.build/docs/installation" >&2
  exit 1
fi

cd "$PROTO_DIR"
echo "Generating shared protobuf stubs"
buf generate --template "$PROTO_DIR/buf.gen.yaml"
echo "Done (output under proto/{service}/v1)"
