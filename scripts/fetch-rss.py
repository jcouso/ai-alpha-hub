#!/usr/bin/env python3
"""
fetch-rss.py — Pull YouTube + Google News RSS feeds for AI Alpha pipeline.
Usage: python3 fetch-rss.py [--hours N] [--watchlist path]
"""
import re, sys, argparse, urllib.request, urllib.parse, email.utils
from datetime import datetime, timezone, timedelta

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--hours', type=int, default=48)
    p.add_argument('--watchlist', default='config/watchlist.md')
    return p.parse_args()

def fetch(url, timeout=10):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 AI-Alpha-Scout/1.0'})
        return urllib.request.urlopen(req, timeout=timeout).read().decode('utf-8', errors='replace')
    except Exception as e:
        return None

def parse_watchlist(path):
    data = open(path).read()

    # YouTube channel IDs
    yt_channels = []
    m = re.search(r'## YouTube Channel IDs.*?```(.*?)```', data, re.DOTALL)
    if m:
        for line in m.group(1).strip().splitlines():
            line = line.strip()
            if line and not line.startswith('#') and '|' in line:
                ch_id, name = line.split('|', 1)
                yt_channels.append((ch_id.strip(), name.strip()))

    # Google News queries
    queries = []
    m2 = re.search(r'## Google News RSS Queries.*?```(.*?)```', data, re.DOTALL)
    if m2:
        for line in m2.group(1).strip().splitlines():
            line = line.strip()
            if line and not line.startswith('#'):
                queries.append(line)

    return yt_channels, queries

def fetch_youtube(channels, cutoff):
    results = []
    for ch_id, name in channels:
        url = f'https://www.youtube.com/feeds/videos.xml?channel_id={ch_id}'
        xml = fetch(url)
        if not xml:
            continue
        entries = re.split(r'<entry>', xml)[1:]
        for e in entries[:15]:
            t = re.search(r'<title>(.*?)</title>', e)
            p = re.search(r'<published>(.*?)</published>', e)
            lk = re.search(r'href="(https://www\.youtube\.com/watch[^"]+)"', e)
            if not (t and p): continue
            try:
                dt = datetime.fromisoformat(p.group(1).rstrip('Z')).replace(tzinfo=timezone.utc)
                if dt < cutoff: continue
            except: continue
            url = lk.group(1) if lk else ''
            # Skip YouTube Shorts
            if '/shorts/' in url:
                continue
            results.append({
                'channel': name,
                'title': t.group(1).strip(),
                'url': url,
                'published': p.group(1),
            })
    return results

def fetch_google_news(queries, cutoff):
    results = []
    seen_titles = set()
    for query in queries:
        encoded = urllib.parse.quote(query)
        url = f'https://news.google.com/rss/search?q={encoded}&hl=en-US&gl=US&ceid=US:en'
        xml = fetch(url)
        if not xml: continue
        items = re.split(r'<item>', xml)[1:]
        for item in items[:8]:
            t = re.search(r'<title><!\[CDATA\[(.*?)\]\]></title>', item) or re.search(r'<title>(.*?)</title>', item)
            lk = re.search(r'<link>(.*?)</link>', item)
            p = re.search(r'<pubDate>(.*?)</pubDate>', item)
            src = re.search(r'<source[^>]*>(.*?)</source>', item)
            if not (t and p): continue
            try:
                dt = email.utils.parsedate_to_datetime(p.group(1).strip())
                if dt.tzinfo is None: dt = dt.replace(tzinfo=timezone.utc)
                if dt < cutoff: continue
            except: continue
            title = t.group(1).strip()
            if title in seen_titles: continue
            seen_titles.add(title)
            results.append({
                'query': query,
                'title': title,
                'url': lk.group(1).strip() if lk else '',
                'source': src.group(1).strip() if src else '',
                'published': p.group(1).strip(),
            })
    return results

def main():
    args = parse_args()
    cutoff = datetime.now(timezone.utc) - timedelta(hours=args.hours)
    yt_channels, queries = parse_watchlist(args.watchlist)

    print(f"=== AI ALPHA RSS FEEDS ===")
    print(f"Window: last {args.hours}h (since {cutoff.strftime('%Y-%m-%d %H:%M UTC')})")
    print()

    # ── YouTube ──────────────────────────────────────────────────────────────
    print("## YOUTUBE — Recent Uploads from Tracked Channels")
    print()
    yt_results = fetch_youtube(yt_channels, cutoff)
    if yt_results:
        for r in yt_results:
            print(f"[{r['channel']}] {r['title']}")
            print(f"  Published: {r['published']}")
            if r['url']: print(f"  URL: {r['url']}")
            print()
    else:
        print("  (No new videos from tracked channels in this window)")
        print()

    # ── Google News ───────────────────────────────────────────────────────────
    print("## GOOGLE NEWS — AI & Dev Tooling")
    print()
    news_results = fetch_google_news(queries, cutoff)
    if news_results:
        current_query = None
        for r in news_results:
            if r['query'] != current_query:
                print(f"### Query: \"{r['query']}\"")
                current_query = r['query']
            src = f" [{r['source']}]" if r['source'] else ""
            print(f"  - {r['title']}{src}")
            if r['url']: print(f"    {r['url']}")
        print()
    else:
        print("  (No results in this window)")
        print()

    print("=== END RSS FEEDS ===")

if __name__ == '__main__':
    main()
