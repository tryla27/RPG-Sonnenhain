#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${1:-sonnenhain}"
PUBKEY_FILE="${2:-}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root."
  exit 1
fi

if [ -z "$PUBKEY_FILE" ] || [ ! -s "$PUBKEY_FILE" ]; then
  echo "Usage: $0 [username] /path/to/deploy-key.pub"
  exit 1
fi

if ! id "$USER_NAME" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "$USER_NAME"
fi

HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
install -d -m 700 -o "$USER_NAME" -g "$USER_NAME" "$HOME_DIR/.ssh"
install -m 600 -o "$USER_NAME" -g "$USER_NAME" "$PUBKEY_FILE" "$HOME_DIR/.ssh/authorized_keys"
install -d -m 755 -o "$USER_NAME" -g "$USER_NAME" "$HOME_DIR/sonnenhain-server/releases/current" "$HOME_DIR/sonnenhain-server/data"
install -d -m 755 -o "$USER_NAME" -g "$USER_NAME" "$HOME_DIR/.config/systemd/user"

install -d -m 755 /var/lib/systemd/linger
touch "/var/lib/systemd/linger/$USER_NAME"

echo "Prepared deploy user: $USER_NAME"
echo "Authorized key fingerprint:"
ssh-keygen -lf "$HOME_DIR/.ssh/authorized_keys"
