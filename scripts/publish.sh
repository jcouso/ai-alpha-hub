#!/bin/bash
# Publish AI Alpha Hub to GitHub Pages
# Usage: bash scripts/publish.sh [date] [commit-message]
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

DATE="${1:-$(date +%Y-%m-%d)}"
MSG="${2:-chore: AI alpha report $DATE}"

git pull origin main --rebase 2>/dev/null || true
git add docs/
git diff --cached --quiet && echo "Nothing to commit." && exit 0
git commit -m "$MSG"
git push origin main
echo "✅ Published: https://jcouso.github.io/ai-alpha-hub/?date=$DATE"
