#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot binary not found or not executable: $GODOT_BIN" >&2
  echo "Set GODOT_BIN=/path/to/Godot" >&2
  exit 1
fi

cd "$ROOT_DIR"
"$GODOT_BIN" --headless --path . --import >/tmp/hotel_godot_import.log 2>&1 || {
  cat /tmp/hotel_godot_import.log
  exit 1
}

for script in tests/smoke/*.gd; do
  echo "--- smoke: $script ---"
  log="/tmp/$(basename "$script" .gd).log"
  "$GODOT_BIN" --headless --path . --script "$script" 2>&1 | tee "$log"
  if grep -E "ERROR|SCRIPT ERROR|Parse Error|Invalid" "$log" >/dev/null; then
    exit 1
  fi
done
