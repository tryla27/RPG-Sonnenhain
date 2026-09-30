#!/usr/bin/env bash
set -eu

ROOT="$HOME/sonnenhain-server"
BIN="$ROOT/releases/current/sonnenhain-server.x86_64"
LOG="$ROOT/server.log"
LOCKDIR="$ROOT/.watchdog-lock"
FORCE_RESTART="${1:-}"

mkdir -p "$ROOT/data"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT

server_process_alive() {
  pgrep -f "[s]onnenhain-server.x86_64 --headless -- --dedicated-server" >/dev/null 2>&1
}

server_port_alive() {
  if command -v ss >/dev/null 2>&1; then
    ss -ltn 2>/dev/null | grep -Eq '[:.]27845([[:space:]]|$)'
    return
  fi
  if command -v timeout >/dev/null 2>&1; then
    timeout 2 bash -c '</dev/tcp/127.0.0.1/27845' >/dev/null 2>&1
    return
  fi
  return 0
}

if [ "$FORCE_RESTART" != "--restart" ] && server_process_alive && server_port_alive; then
  exit 0
fi

if [ "$FORCE_RESTART" = "--restart" ]; then
  echo "$(date -Is) deploy: forcing dedicated server restart" >> "$LOG"
fi

pkill -f "[s]onnenhain-server.x86_64 --headless -- --dedicated-server" >/dev/null 2>&1 || true
sleep 1

if [ ! -x "$BIN" ]; then
  echo "$(date -Is) watchdog: server binary missing: $BIN" >> "$LOG"
  exit 1
fi

cd "$ROOT/releases/current"
if command -v setsid >/dev/null 2>&1; then
  nohup setsid "$BIN" --headless -- --dedicated-server >> "$LOG" 2>&1 </dev/null &
else
  nohup "$BIN" --headless -- --dedicated-server >> "$LOG" 2>&1 </dev/null &
fi

sleep 4
if ! server_process_alive || ! server_port_alive; then
  echo "$(date -Is) watchdog: restart failed" >> "$LOG"
  tail -n 80 "$LOG" >&2 || true
  exit 1
fi

echo "$(date -Is) watchdog: Sonnenhain server restarted successfully" >> "$LOG"
