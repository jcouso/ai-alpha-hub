# AI Alpha Watchlist

Curated accounts and sources to check every run. The research agent MUST check these for the last 24h.

## Official Company Accounts (ALWAYS check)
- @OpenAI — GPT, Codex, Sora
- @OpenAIDevs — Developer announcements
- @AnthropicAI — Claude
- @GoogleAI — Gemini
- @GoogleDeepMind — Research
- @xaboratory — xAI/Grok
- @Alibaba_Qwen — Qwen models
- @DeepSeek_AI — DeepSeek
- @MistralAI — Mistral
- @Meta — Llama
- @StabilityAI — Stable Diffusion
- @midaborney — Midjourney
- @runwayml — Runway video AI
- @paboratory_ai — Pika
- @kaboratory_ai — Kling (Kuaishou)

## DevTool Accounts (ALWAYS check)
- @cursor_ai — Cursor IDE
- @windsurf_ai — Windsurf
- @GitHubCopilot — Copilot
- @github — GitHub (Agentic Workflows, etc.)
- @vercel — v0, Next.js
- @reaboratorium — Replit
- @claboratory — Cline
- @aider_ai — Aider

## Key Builders/Researchers (high signal)
- @karpathy — Andrej Karpathy
- @sama — Sam Altman
- @daboratory — Dario Amodei
- @iaboratory — Ilya Sutskever
- @jimfan — Jim Fan (Nvidia)
- @DrJimFan — Jim Fan alt
- @simonw — Simon Willison
- @swyx — swyx
- @steipete — Peter Steinberger (OpenClaw)
- @mattshumer_ — Matt Shumer
- @emaboratory — Emily Zhang
- @kaboratory — Kevin Weil (OpenAI CPO)
- @GaborosFarhood — Farhood (product)

## From @igthebird follows (Juan's curated)
<!-- Add accounts from Juan's follow list here -->
- TBD — pull from Juan's X follows

## Official Blogs/Changelogs (web sources)
- https://openai.com/blog
- https://www.anthropic.com/news
- https://blog.google/technology/ai/
- https://ai.meta.com/blog/
- https://mistral.ai/news/
- https://qwenlm.github.io/
- https://github.blog/changelog/
- https://cursor.com/blog
- https://www.windsurf.com/blog

## YouTube Channels (check for recent uploads — last 7 days)
These are high-signal channels for tutorials, coding demos, and practitioner insights.
Only flag a video if it's genuinely educational/practical — not just news/commentary.

### Top Practitioner Channels
- https://www.youtube.com/@georgehotz — George Hotz (live coding, agentic workflows)
- https://www.youtube.com/@AndrejKarpathy — Karpathy (deep learning, agents)
- https://www.youtube.com/@ThePrimeagen — ThePrimeagen (dev tooling, vim, productivity)
- https://www.youtube.com/@t3dotgg — Theo (SaaS dev, AI tooling)
- https://www.youtube.com/@fireship — Fireship (fast practical overviews)
- https://www.youtube.com/@developersdigest — Developers Digest (agentic demos)
- https://www.youtube.com/@aiexplained-official — AI Explained (research breakdowns)
- https://www.youtube.com/@BorisCherny — Boris Cherny (Claude Code creator)

### Show HN / Community
- https://www.youtube.com/@ycombinator — YC (startup + AI)
- https://www.youtube.com/@lexfridman — Lex (long-form, researchers)
- https://www.youtube.com/@LennysPodcast — Lenny (product + AI)

### Criteria for including a video:
- Must be uploaded in the last 7 days
- Must have a clear practical/technical angle (tutorial, demo, workflow, code walkthrough)
- Prefer: live coding sessions, "how I use X" from practitioners, tool demos
- Avoid: AI news roundups, hype videos, generic explainers anyone would find on their own

## Google News RSS Queries
The fetch-rss.sh script auto-derives queries from tool/company names above,
PLUS these explicit queries below. Add anything here that the auto-derive misses.

```
# Models & Labs
Claude Code
Anthropic Claude
OpenAI Codex
GPT-5
Gemini AI
Qwen model
DeepSeek AI
Mistral AI
xAI Grok

# Dev Tools & Agents
Cursor IDE
Windsurf AI
GitHub Copilot
Claude Code agent
agentic coding
AI coding agent
MCP protocol
OpenClaw agent
LLM benchmark

# Practitioner topics
vibe coding
AI SaaS developer
autonomous agent
multi-agent framework
AI workflow automation
LLM prompt engineering
```

To add a query: just add a line above. Blank lines and `#` comments are ignored.

## YouTube Channel IDs (for RSS feed fetching)
Format: ChannelID | Display Name

```
UCXUPKJO5MZQN11PqgIvyuvQ | Andrej Karpathy
UCwgKmJM4ZJQRJ-U5NjvR2dg | George Hotz (geohotarchive)
UC8ENHE5xdFSwx71u3fDH5Xw | ThePrimeagen
UCbRP3c757lWg9M-U7TyEkXA | Theo (t3.gg)
UCsBjURrPoezykLs9EqgamOA | Fireship
UCuE6iwZKgGz8s6kznBRI9LQ | Developers Digest
UCNJ1Ymd5yFuUPtn21xtRbbw | AI Explained
UCcefcZRL2oaA_uBNeo5UOWg | Y Combinator
UCSHZKyawb77ixDdsGog4iWA | Lex Fridman
UC6t1O76G0jYXOAoYCm153dA | Lenny's Podcast
```

## How to update
Just edit this file. The AI Alpha job reads it every run.
