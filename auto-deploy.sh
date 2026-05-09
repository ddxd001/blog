#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT/logs"
LOG_FILE="$LOG_DIR/auto-deploy.log"
LOCK_DIR="/tmp/blog-auto-deploy.lock"

mkdir -p "$LOG_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "Another deployment is running; skipped."
  exit 0
fi
trap 'rmdir "$LOCK_DIR"' EXIT

cd "$ROOT"

if [[ -n "$("./git-blog.sh" status --porcelain)" ]]; then
  log "Working tree has local changes; skipped."
  "./git-blog.sh" status --short >> "$LOG_FILE"
  exit 1
fi

current="$("./git-blog.sh" rev-parse HEAD)"
"./git-blog.sh" fetch origin main >> "$LOG_FILE" 2>&1
remote="$("./git-blog.sh" rev-parse origin/main)"

if [[ "$current" == "$remote" ]]; then
  log "Already up to date."
  exit 0
fi

log "Deploying $current -> $remote"
"./git-blog.sh" pull --ff-only origin main >> "$LOG_FILE" 2>&1
"$ROOT/deploy.sh" >> "$LOG_FILE" 2>&1
log "Deploy complete."
