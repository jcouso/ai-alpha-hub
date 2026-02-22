#!/bin/bash
# fetch-rss.sh — Pull YouTube + Google News RSS feeds for AI Alpha pipeline
# Usage: bash scripts/fetch-rss.sh [--hours 48] [--watchlist path/to/watchlist.md]
# Outputs structured text ready for the research agent to consume.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOURS="${HOURS:-48}"
WATCHLIST="$REPO_DIR/config/watchlist.md"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --hours) HOURS="$2"; shift 2 ;;
    --watchlist) WATCHLIST="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# cutoff timestamp for filtering
CUTOFF=$(date -v-${HOURS}H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -d "${HOURS} hours ago" '+%Y-%m-%dT%H:%M:%S')

echo "=== AI ALPHA RSS FEEDS ==="
echo "Cutoff: last ${HOURS}h (since $CUTOFF)"
echo ""

# ─── 1. YOUTUBE RSS ────────────────────────────────────────────────────────────
echo "## YOUTUBE — Recent Uploads"
echo ""

# Extract channel IDs from watchlist
CHANNEL_BLOCK=$(python3 -c "
import re, sys
data = open('$WATCHLIST').read()
m = re.search(r'## YouTube Channel IDs.*?^(\`\`\`)(.*?)(\`\`\`)', data, re.DOTALL|re.MULTILINE)
if m:
    for line in m.group(2).strip().splitlines():
        line = line.strip()
        if line and not line.startswith('#'):
            print(line)
" 2>/dev/null)

if [[ -z "$CHANNEL_BLOCK" ]]; then
  echo "(No YouTube channels configured in watchlist)"
else
  while IFS='|' read -r CHANNEL_ID DISPLAY_NAME; do
    CHANNEL_ID=$(echo "$CHANNEL_ID" | tr -d ' ')
    DISPLAY_NAME=$(echo "$DISPLAY_NAME" | sed 's/^ *//')
    [[ -z "$CHANNEL_ID" ]] && continue

    RSS_URL="https://www.youtube.com/feeds/videos.xml?channel_id=${CHANNEL_ID}"
    XML=$(curl -sf --max-time 8 "$RSS_URL" 2>/dev/null || echo "")

    if [[ -z "$XML" ]]; then
      echo "  [$DISPLAY_NAME] (fetch failed)"
      continue
    fi

    # Parse entries via python3
    FOUND=0
    RESULTS=$(echo "$XML" | python3 -c "
import sys, re
from datetime import datetime, timezone, timedelta

data = sys.stdin.read()
cutoff = datetime.fromisoformat('$CUTOFF').replace(tzinfo=timezone.utc) if '+' not in '$CUTOFF' else datetime.fromisoformat('$CUTOFF')
entries = re.split(r'<entry>', data)[1:]
found = []
for e in entries[:10]:
    title = re.search(r'<title>(.*?)</title>', e)
    pub   = re.search(r'<published>(.*?)</published>', e)
    link  = re.search(r'<link rel=[\"'\'']alternate[\"'\''] href=[\"'\''](.*?)[\"'\'']', e)
    if not (title and pub): continue
    try:
        dt = datetime.fromisoformat(pub.group(1).rstrip('Z')).replace(tzinfo=timezone.utc)
        if dt < cutoff: continue
    except: continue
    t = title.group(1).strip()
    u = link.group(1) if link else ''
    p = pub.group(1)
    found.append(f'TITLE:{t}')
    found.append(f'PUB:{p}')
    found.append(f'URL:{u}')
    found.append('---')
print('\n'.join(found))
" 2>/dev/null)

    if [[ -n "$RESULTS" ]]; then
      while IFS= read -r LINE; do
        case "$LINE" in
          TITLE:*) echo "  [$DISPLAY_NAME] ${LINE#TITLE:}" ;;
          PUB:*)   echo "  Published: ${LINE#PUB:}" ;;
          URL:*)   echo "  URL: ${LINE#URL:}"; echo "" ;;
        esac
      done <<< "$RESULTS"
      FOUND=1
    fi

    [[ $FOUND -eq 0 ]] && echo "  [$DISPLAY_NAME] No new videos in last ${HOURS}h"
  done <<< "$CHANNEL_BLOCK"
fi

echo ""
echo "## GOOGLE NEWS — AI & Dev Tooling"
echo ""

# Extract queries from watchlist (inside the ``` block under Google News RSS Queries)
QUERIES=$(python3 -c "
import re
data = open('$WATCHLIST').read()
m = re.search(r'## Google News RSS Queries.*?^(\`\`\`)(.*?)(\`\`\`)', data, re.DOTALL|re.MULTILINE)
if m:
    for line in m.group(2).strip().splitlines():
        line = line.strip()
        if line and not line.startswith('#'):
            print(line)
" 2>/dev/null)

if [[ -z "$QUERIES" ]]; then
  echo "(No queries configured in watchlist)"
else
  while IFS= read -r QUERY; do
    [[ -z "$QUERY" ]] && continue
    ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))" 2>/dev/null || echo "$QUERY" | sed 's/ /+/g')
    RSS_URL="https://news.google.com/rss/search?q=${ENCODED}&hl=en-US&gl=US&ceid=US:en"

    XML=$(curl -sf --max-time 8 "$RSS_URL" 2>/dev/null || echo "")
    if [[ -z "$XML" ]]; then
      continue
    fi

    # Extract items from Google News RSS
    ITEMS=$(echo "$XML" | python3 -c "
import sys, re
from datetime import datetime, timezone, timedelta
import email.utils

data = sys.stdin.read()
items = re.split(r'<item>', data)[1:]
cutoff = datetime.now(timezone.utc) - timedelta(hours=$HOURS)
found = []
for item in items[:10]:
    title_m = re.search(r'<title><!\[CDATA\[(.*?)\]\]></title>', item) or re.search(r'<title>(.*?)</title>', item)
    link_m = re.search(r'<link>(.*?)</link>', item)
    pub_m = re.search(r'<pubDate>(.*?)</pubDate>', item)
    src_m = re.search(r'<source[^>]*>(.*?)</source>', item)

    if not (title_m and pub_m): continue
    try:
        pub = email.utils.parsedate_to_datetime(pub_m.group(1).strip())
        if pub.tzinfo is None:
            pub = pub.replace(tzinfo=timezone.utc)
        if pub < cutoff: continue
    except: continue

    title = title_m.group(1).strip()
    link = link_m.group(1).strip() if link_m else ''
    src = src_m.group(1).strip() if src_m else ''
    pub_str = pub.strftime('%Y-%m-%d %H:%M UTC')
    found.append(f'  - {title}')
    if src: found.append(f'    Source: {src} | {pub_str}')
    if link: found.append(f'    URL: {link}')
print('\n'.join(found))
" 2>/dev/null)

    if [[ -n "$ITEMS" ]]; then
      echo "### Query: \"$QUERY\""
      echo "$ITEMS"
      echo ""
    fi
  done <<< "$QUERIES"
fi

echo "=== END RSS FEEDS ==="
