#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POSTS_DIR="$ROOT/content/posts"

usage() {
  cat <<'EOF'
Usage:
  ./new-post.sh "文章标题" ["文章摘要"]

Examples:
  ./new-post.sh "我的新文章"
  ./new-post.sh "我的新文章" "这是一段显示在列表页的摘要。"
EOF
}

slugify() {
  local input="$1"
  local slug

  slug="$(printf '%s' "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"

  if [[ -z "$slug" ]]; then
    slug="$(date +%Y%m%d-%H%M%S)"
  fi

  printf '%s' "$slug"
}

escape_yaml() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

title="$1"
summary="${2:-}"
slug="$(slugify "$title")"
path="$POSTS_DIR/$slug.md"

if [[ -e "$path" ]]; then
  echo "Error: $path already exists." >&2
  exit 1
fi

mkdir -p "$POSTS_DIR"

cat > "$path" <<EOF
---
title: "$(escape_yaml "$title")"
date: $(date -Iseconds)
draft: false
summary: "$(escape_yaml "$summary")"
---

在这里开始写正文。
EOF

echo "Created $path"
echo "Edit it, then publish with: ./deploy.sh"
