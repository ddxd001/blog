#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec git --git-dir="$ROOT/.git-store" --work-tree="$ROOT" "$@"
