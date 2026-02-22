#!/bin/bash
# fetch-rss.sh — Pull YouTube + Google News RSS for AI Alpha pipeline
# Usage: bash scripts/fetch-rss.sh [--hours N]
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOURS=48
while [[ $# -gt 0 ]]; do
  case "$1" in --hours) HOURS="$2"; shift 2 ;; *) shift ;; esac
done

python3 "$REPO_DIR/scripts/fetch-rss.py" --hours "$HOURS" --watchlist "$REPO_DIR/config/watchlist.md"
