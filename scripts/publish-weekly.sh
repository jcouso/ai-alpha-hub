#!/bin/bash
# Publish Weekly AI Alpha Report to GitHub Pages
# Usage: bash scripts/publish-weekly.sh YYYY-MM-DD
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

DATE="${1:-$(date +%Y-%m-%d)}"
REPORT_FILE="docs/weekly/${DATE}.md"
HISTORY_FILE="docs/weekly-history.json"

if [ ! -f "$REPORT_FILE" ]; then
  echo "❌ Weekly report not found: $REPORT_FILE"
  exit 1
fi

git pull origin main --rebase 2>/dev/null || true

# Auto-update weekly-history.json
python3 - <<PYEOF
import json, os

date = "${DATE}"
report_file = "${REPORT_FILE}"
history_file = "${HISTORY_FILE}"

# Extract title: first ### heading
title = ""
with open(report_file) as f:
    for line in f:
        line = line.strip()
        if line.startswith("### ") or line.startswith("## "):
            title = line.lstrip("# ").strip()
            break

if not title:
    title = f"Weekly AI Alpha — {date}"

# Prefix with week label
from datetime import datetime
try:
    dt = datetime.strptime(date, "%Y-%m-%d")
    label = f"Week of {dt.strftime('%b %d, %Y')}: {title}"
except:
    label = title

if os.path.exists(history_file):
    with open(history_file) as f:
        history = json.load(f)
else:
    history = []

history = [e for e in history if e.get("date") != date]
history.insert(0, {
    "date": date,
    "title": label,
    "path": f"./weekly/{date}.md"
})

with open(history_file, "w") as f:
    json.dump(history, f, indent=2)

print(f"✅ weekly-history.json updated: {date}")
PYEOF

git add docs/weekly/ docs/weekly-history.json
git diff --cached --quiet && echo "Nothing to commit." && exit 0
git commit -m "chore: weekly AI alpha report ${DATE}"
git push origin main
echo "✅ Published: https://jcouso.github.io/ai-alpha-hub/weekly/?date=${DATE}"
