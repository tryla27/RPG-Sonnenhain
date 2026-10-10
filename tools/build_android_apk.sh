#!/usr/bin/env bash
# Android-APK bauen (CI: GitHub-Runner mit Android-SDK und Java 17).
# Erwartet: GODOT_BIN, ANDROID_HOME, JAVA_HOME. Optional ANDROID_KEYSTORE_BASE64
# + ANDROID_KEYSTORE_PASSWORD (+ ANDROID_KEY_ALIAS) für eine feste Signatur;
# ohne sie wird eine Wegwerf-Signatur erzeugt (Updates dann nur nach
# Deinstallation). Ausgabe: build/android/sonnenhain-rpg.apk
set -euo pipefail
out="${1:-build/android/sonnenhain-rpg.apk}"
mkdir -p "$(dirname "$out")" "$HOME/.config/godot"
: "${GODOT_BIN:?GODOT_BIN fehlt}"
: "${ANDROID_HOME:?ANDROID_HOME fehlt}"
: "${JAVA_HOME:?JAVA_HOME fehlt}"

# Editor-Einstellungen: Android-SDK und Java.
for name in editor_settings-4.tres editor_settings-4.7.tres; do
  cat > "$HOME/.config/godot/$name" <<SETTINGS
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$ANDROID_HOME"
export/android/java_sdk_path = "$JAVA_HOME"
SETTINGS
done

keystore="$(mktemp -d)/release.keystore"
alias="${ANDROID_KEY_ALIAS:-sonnenhain}"
if [ -n "${ANDROID_KEYSTORE_BASE64:-}" ] && [ -n "${ANDROID_KEYSTORE_PASSWORD:-}" ]; then
  echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > "$keystore"
  password="$ANDROID_KEYSTORE_PASSWORD"
  echo "Signatur: feste Schlüsseldatei aus den Secrets"
else
  password="sonnenhain-$(date +%s)-$RANDOM"
  "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$keystore" -alias "$alias" -keyalg RSA -keysize 2048 \
    -validity 10000 -storepass "$password" -keypass "$password" -dname "CN=Sonnenhain RPG, O=Sonnenhain" >/dev/null
  echo "::warning::Keine feste Android-Signatur hinterlegt (ANDROID_KEYSTORE_BASE64). Wegwerf-Signatur verwendet."
fi
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$keystore"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$alias"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$password"

# Versionsnummer je Build (Android verlangt steigende Codes für Updates).
code="${ANDROID_VERSION_CODE:-${GITHUB_RUN_NUMBER:-1}}"
name="${ANDROID_VERSION_NAME:-1.0.$code}"
sed -i "s/^version\/code=.*/version\/code=$code/; s/^version\/name=.*/version\/name=\"$name\"/" export_presets.cfg

"$GODOT_BIN" --headless --path . --editor --import --quit >/dev/null 2>&1 || true
"$GODOT_BIN" --headless --path . --export-release "Android" "$out" 2>&1 | tee /tmp/android-export.log
test -s "$out"
ls -la "$out"
tools_dir="$(ls -d "$ANDROID_HOME"/build-tools/* | sort -V | tail -1)"
"$tools_dir/aapt2" dump badging "$out" | grep -E "^package|sdkVersion|uses-permission|application-label" || true
"$tools_dir/apksigner" verify --print-certs "$out" | head -3 || true
