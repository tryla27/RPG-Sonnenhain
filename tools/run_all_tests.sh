#!/usr/bin/env bash
# Führt alle Regressionstests so aus wie die CI (.github/workflows/ci.yml).
#
# Aufruf:  tools/run_all_tests.sh
# Godot:   GODOT_BIN=/pfad/zu/godot tools/run_all_tests.sh   (Standard: "godot")
# Parallel: JOBS=4 tools/run_all_tests.sh                     (Standard: 1)
#
# Endet mit Code 0, wenn alle Tests bestehen; sonst werden die fehlgeschlagenen
# Tests aufgelistet und ihr Log liegt unter build/test-logs/.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
GODOT_BIN="${GODOT_BIN:-godot}"
JOBS="${JOBS:-1}"
LOG_DIR="build/test-logs"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
	echo "Godot nicht gefunden. GODOT_BIN auf die Godot-4.7.2-Datei setzen." >&2
	exit 2
fi

rm -rf "$LOG_DIR"
mkdir -p "$LOG_DIR"

echo "Inhaltsprüfung (tools/check_content.py) ..."
if ! python3 tools/check_content.py > "$LOG_DIR/check_content.log" 2>&1; then
	echo "FEHLER tools/check_content.py (siehe $LOG_DIR/check_content.log)"
	exit 1
fi

echo "Projekt importieren ..."
if ! "$GODOT_BIN" --headless --path . --editor --import --quit > "$LOG_DIR/import.log" 2>&1; then
	echo "FEHLER beim Import (siehe $LOG_DIR/import.log)"
	exit 1
fi

run_one() {
	local test_script="$1"
	local log="$LOG_DIR/$(echo "$test_script" | tr '/' '_').log"
	timeout 180 "$GODOT_BIN" --headless --path . --script "$test_script" > "$log" 2>&1
	local rc=$?
	if [ $rc -ne 0 ] || grep -q "SCRIPT ERROR:" "$log"; then
		echo "FAIL $test_script"
	else
		echo "OK   $test_script"
	fi
}
export -f run_one
export GODOT_BIN LOG_DIR

# Gleiche Auswahl wie die CI. Netzwerktests mit festen Ports laufen zum Schluss einzeln.
results="$(
	{
		find tools -maxdepth 1 -name 'check_*.gd' \
			! -name 'check_party_xp_network.gd' \
			! -name 'check_boss_head_save_network.gd' \
			! -name 'check_server_save_network.gd'
		find tests -type f -name 'check_*.gd'
	} | sort | xargs -P "$JOBS" -I{} bash -c 'run_one "$1"' _ {}
	run_one tools/check_party_xp_network.gd
)"

echo "$results" | sort -k2
passed=$(echo "$results" | grep -c '^OK' || true)
failed=$(echo "$results" | grep -c '^FAIL' || true)
echo
echo "$passed bestanden, $failed fehlgeschlagen. Logs: $LOG_DIR/"
[ "$failed" -eq 0 ]
