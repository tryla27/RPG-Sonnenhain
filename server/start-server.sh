#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$ROOT/sonnenhain-server.x86_64"
LOG="${SONNENHAIN_LOG:-$ROOT/server.log}"

if [ ! -x "$BIN" ]; then
  echo "Server-Binary fehlt oder ist nicht ausführbar: $BIN" >&2
  exit 1
fi

cd "$ROOT"
exec "$BIN" --headless -- --dedicated-server >>"$LOG" 2>&1
