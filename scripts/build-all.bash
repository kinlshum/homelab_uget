#!/bin/bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
rm -rf "$ROOT/dist"; mkdir -p "$ROOT/dist"
"$ROOT/scripts/build-btop.bash"
"$ROOT/scripts/build-nmon.bash"
"$ROOT/scripts/build-ffmpeg-btbn.bash"
"$ROOT/scripts/generate-index.bash"
"$ROOT/scripts/test.bash"
"$ROOT/scripts/test-runtime.bash"
