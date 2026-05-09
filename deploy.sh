#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUGO_BIN="/home/ddxd/.local/hugo/usr/bin/hugo"
HUGO_LIB="/home/ddxd/.local/hugo/usr/lib/x86_64-linux-gnu"

cd "$ROOT"
LD_LIBRARY_PATH="$HUGO_LIB" "$HUGO_BIN" --minify

echo "Built site into $ROOT/public"
