#!/bin/bash
# Publish AI Alpha Hub to GitHub Pages
# Usage: bash scripts/publish.sh YYYY-MM-DD
# Handles: git pull, history.json update, git add/commit/push
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

DATE="${1:-$(date +%Y-%m-%d)}"
REPORT_FILE="docs/reports/${DATE}.md"
HISTORY_FILE="docs/history.json"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ Report not found: $REPORT_FILE"
  exit 1
fi

git pull origin main --rebase 2>/dev/null || true

# Auto-update history.json if date is missing
python3 - <<PYEOF
import json, re, os, sys

date = "${DATE}"
report_file = "${REPORT_FILE}"
history_file = "${HISTORY_FILE}"

# Extract title from report (first ### heading or first # heading)
title = ""
with open(report_file) as f:
    for line in f:
        line = line.strip()
        if line.startswith("### "):
            title = line.lstrip("# ").strip()
            break
        elif line.startswith("## ") or line.startswith("# "):
            continue  # skip top-level headings

if not title:
    title = f"AI Alpha Report — {date}"

with open(history_file) as f:
    history = json.load(f)

# Remove existing entry for this date
history = [e for e in history if e.get("date") != date]

# Prepend new entry
history.insert(0, {
    "date": date,
    "title": title,
    "path": f"./reports/{date}.md"
})

with open(history_file, "w") as f:
    json.dump(history, f, indent=2)

print(f"✅ history.json updated: {date} → {title[:60]}")
PYEOF

git add docs/
git diff --cached --quiet && echo "Nothing to commit." && exit 0
git commit -m "chore: AI alpha report ${DATE}"
git push origin main
echo "✅ Published: https://jcouso.github.io/ai-alpha-hub/?date=${DATE}"
