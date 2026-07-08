#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT_DIR/tools/run_unit_tests.sh"
"$ROOT_DIR/tools/run_smoke_tests.sh"
