#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
OUTPUT_DIR="$ROOT_DIR/build/web"
OUTPUT_HTML="$OUTPUT_DIR/index.html"

if [[ ! -x "$GODOT_BIN" ]] && ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "Godot binary not found or not executable: $GODOT_BIN" >&2
  echo "Set GODOT_BIN=/path/to/Godot" >&2
  exit 1
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

cd "$ROOT_DIR"
"$GODOT_BIN" --headless --path . --import
"$GODOT_BIN" --headless --path . --export-release Web "$OUTPUT_HTML"
touch "$OUTPUT_DIR/.nojekyll"

required_files=(
  "$OUTPUT_DIR/index.html"
  "$OUTPUT_DIR/index.js"
  "$OUTPUT_DIR/index.pck"
  "$OUTPUT_DIR/index.wasm"
)

for required_file in "${required_files[@]}"; do
  if [[ ! -s "$required_file" ]]; then
    echo "Web export is missing required file: $required_file" >&2
    exit 1
  fi
done

oversized_file="$(find "$OUTPUT_DIR" -type f -size +95000k -print -quit)"
if [[ -n "$oversized_file" ]]; then
  echo "GitHub Pages build contains a file larger than the 95 MB safety limit: $oversized_file" >&2
  exit 1
fi

echo "Web export ready: $OUTPUT_HTML"
