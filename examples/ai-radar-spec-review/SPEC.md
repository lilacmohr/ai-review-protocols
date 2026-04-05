# ai-radar — Product & Technical Specification

**Version:** 0.1 (MVP)  
**Status:** Draft  
**Last Updated:** 2026-04-01

---

## 1. Overview

### 1.1 Problem Statement

AI professionals need to stay current on a rapidly evolving landscape spanning research papers, company announcements, tooling releases, and community discourse. Manually reading newsletters, blogs, and social feeds is time-consuming and produces inconsistent signal quality. Most summaries reflect mainstream interpretations, missing non-obvious insights or contrarian perspectives that are often more valuable.

### 1.2 Solution

`ai-radar` is a configurable Python pipeline that ingests AI content from multiple sources daily, filters and ranks it for relevance to the user's role and interests, and produces a richly structured digest. The digest includes not just summaries but contrarian takes, suggested follow-up questions, and cross-source trend detection — designed to surface signal that other tools miss.

### 1.3 Goals

| Goal | Priority |
|---|---|
| Personal daily AI briefing with minimal manual effort | P0 |
| Open-source tool reusable by others via fork + config | P0 |
| Demonstrate agentic development workflow patterns | P0 |
| Pluggable architecture for sources and LLM backends | P1 |
| Blog auto-publish from digest content | Post-MVP |

### 1.4 Non-Goals (MVP)

- Real-time or sub-daily ingestion
- Multi-user SaaS platform
- Blog auto-publish / content syndication
- Fine-tuned models or custom embeddings
- Mobile app or browser extension

---

## 2. User Personas

### Primary: The AI Practitioner
An engineer, researcher, or technical leader building on or with AI systems. Reads across roles: researcher (papers, benchmarks), engineer (tooling, APIs, frameworks), architect (patterns, tradeoffs), and product builder (capabilities, releases). Wants depth, not just headlines. Values non-obvious insights over mainstream takes. Has limited time but high standards for signal quality.

### Secondary: Open-Source Adopter
A developer who discovers `ai-radar` on GitHub and wants to run their own instance. Has some technical ability (can set up API keys, run Python), but needs good documentation. May have different role/interests than the primary user — expects easy configuration without code changes.

---

## 3. Functional Requirements

### 3.1 Source Ingestion

The pipeline must support the following source types. Each source type is a pluggable connector module.

| Source Type | Connector | Notes |
|---|---|---|
| Gmail newsletters | Gmail API (OAuth) | Reads unread emails from configured labels/senders |
| RSS/Atom feeds | `feedparser` | Company blogs, ArXiv, HN, research labs |
| Web scraping | `trafilatura` + `requests` | For URLs extracted from emails or feeds |
| ArXiv | ArXiv API + RSS | Filter by category (cs.AI, cs.LG, cs.CL, etc.) |
| Hacker News | HN Algolia API | Filter by keyword, score threshold |
| Podcast transcripts | RSS + transcript fetch | Where transcripts are available in feed |

All connectors must implement a common `Source` interface:
```python
class Source:
    def fetch(self) -> list[RawItem]
    def name(self) -> str
    def is_enabled(self) -> bool
```

### 3.2 Preprocessing Pipeline (Python, Deterministic)

All steps before LLM calls must be deterministic Python with no API cost:

1. **Fetch** — pull raw content from each enabled source
2. **Deduplicate** — hash URLs and content fingerprints; skip already-processed items (persisted cache)
3. **Extract** — strip boilerplate, extract clean article text using `trafilatura`
4. **Truncate** — cap each article at a configurable max token length (default: 800 words) to control LLM input cost
5. **Pre-filter** — keyword/topic filter against user's interest profile before any LLM call
6. **Normalize** — standardize schema: `{title, url, source, published_at, clean_text, word_count}`

### 3.3 LLM Processing Pipeline

Two sequential LLM passes, each independently configurable:

**Pass 1: Summarization**
- Input: batch of normalized articles (up to N per call, configurable)
- Task: relevance score (1–10 against user role/interests) + 2–3 sentence summary per article
- Output: ranked, summarized article list
- Model recommendation: fast/cheap model (e.g. `gpt-4o-mini`)
- Articles below relevance threshold (configurable, default: 6) are dropped

**Pass 2: Synthesis & Insight**
- Input: top-ranked articles from Pass 1
- Task: generate all digest sections (see 3.4)
- Output: structured markdown digest
- Model recommendation: stronger model (e.g. `gpt-4o`)
- This pass receives the user's full role/interest profile as system context

### 3.4 Digest Output Format

The final digest is a structured markdown file with the following sections, in order:

```markdown
# ai-radar Daily Briefing — {DATE}

## 📡 Executive Summary
3–5 bullet points covering the most important developments of the day.

## 📰 Article Summaries
For each top article:
- **Title** — [Source](url)
- Summary (2–3 sentences)
- Relevance score and why it matters to your role

## 🔍 Contrarian & Non-Obvious Insights
What is the mainstream narrative on today's top stories — and what might people be missing, underweighting, or misinterpreting? 3–5 observations.

## ❓ Follow-Up Questions & Rabbit Holes
5–10 questions or threads worth investigating further, ranked by potential insight value.

## 📈 Trending Themes
Patterns detected across today's sources: emerging topics, recurring themes, trajectory shifts. Distinct from individual article summaries.
```

### 3.5 Configuration

**`config.yaml`** — checked into repo (no secrets):
```yaml
profile:
  role: "AI engineer and technical architect"
  interests:
    - "LLM inference and serving"
    - "agent frameworks and multi-agent systems"
    - "AI safety and alignment research"
    - "open-source models"
    - "developer tooling for AI"
  relevance_threshold: 6  # 1–10, articles below this are dropped

sources:
  gmail:
    enabled: true
    labels: ["newsletters", "AI"]
    max_age_days: 1
  arxiv:
    enabled: true
    categories: ["cs.AI", "cs.LG", "cs.CL", "cs.MA"]
    max_results: 20
  rss_feeds:
    enabled: true
    feeds:
      - name: "Anthropic Blog"
        url: "https://www.anthropic.com/blog/rss"
      - name: "OpenAI Blog"
        url: "https://openai.com/blog/rss"
      - name: "Google DeepMind"
        url: "https://deepmind.google/blog/rss"
  hackernews:
    enabled: true
    min_score: 100
    keywords: ["LLM", "AI", "machine learning", "agent"]
  podcasts:
    enabled: false  # post-MVP

pipeline:
  max_words_per_article: 800
  max_articles_to_summarize: 30
  max_articles_in_digest: 15
  summarization_model: "gpt-4o-mini"
  synthesis_model: "gpt-4o"
  batch_size: 10  # articles per summarization API call

output:
  format: "markdown"
  output_dir: "./digests"
  filename_pattern: "briefing_{date}.md"
```

**`.env`** — secrets only, never committed:
```
GITHUB_TOKEN=...
GMAIL_CLIENT_ID=...
GMAIL_CLIENT_SECRET=...
GMAIL_REFRESH_TOKEN=...
```

### 3.6 Trigger Modes

The pipeline must support all three trigger modes without code changes:

| Mode | Mechanism |
|---|---|
| Manual | `python -m radar run` |
| Scheduled local | cron: `0 7 * * * python -m radar run` |
| GitHub Actions | `.github/workflows/daily-briefing.yml` on schedule |

GitHub Actions mode writes the digest as a workflow artifact and optionally commits it to a `digests/` folder in the repo.

---

## 4. Technical Architecture

### 4.1 Repository Structure

```
ai-radar/
├── README.md
├── SPEC.md
├── AGENTS.md
├── config.yaml              # user configuration (committed)
├── config.example.yaml      # template for new users
├── .env.example             # secrets template
├── pyproject.toml
├── requirements.txt
├── .github/
│   └── workflows/
│       └── daily-briefing.yml
├── radar/
│   ├── __init__.py
│   ├── __main__.py          # entry point: python -m radar run
│   ├── config.py            # config loading and validation
│   ├── models.py            # shared data models (RawItem, NormalizedItem, Digest)
│   ├── cache.py             # URL/content deduplication (SQLite)
│   ├── pipeline.py          # orchestrates all stages
│   ├── sources/
│   │   ├── __init__.py
│   │   ├── base.py          # Source ABC
│   │   ├── gmail.py
│   │   ├── arxiv.py
│   │   ├── rss.py
│   │   ├── hackernews.py
│   │   └── podcasts.py      # stub, post-MVP
│   ├── processing/
│   │   ├── __init__.py
│   │   ├── extractor.py     # trafilatura wrapper
│   │   ├── deduplicator.py
│   │   ├── prefilter.py     # keyword pre-filter
│   │   └── truncator.py
│   ├── llm/
│   │   ├── __init__.py
│   │   ├── client.py        # LLM backend abstraction
│   │   ├── summarizer.py    # Pass 1
│   │   ├── synthesizer.py   # Pass 2
│   │   └── prompts.py       # all prompt templates
│   └── output/
│       ├── __init__.py
│       └── markdown.py      # digest renderer
├── digests/                 # generated output (gitignored or committed)
├── cache/                   # SQLite dedup cache (gitignored)
└── tests/
    ├── test_sources.py
    ├── test_processing.py
    └── test_llm.py
```

### 4.2 Data Flow

```
[Sources] → fetch() → [RawItem list]
    ↓
[Deduplicator] → skip seen URLs/content → [filtered RawItem list]
    ↓
[Extractor] → clean text extraction → [NormalizedItem list]
    ↓
[PreFilter] → keyword match against interests → [candidate list]
    ↓
[Truncator] → cap at max_words → [ready for LLM]
    ↓
[Summarizer - LLM Pass 1] → relevance score + summary → [ScoredItem list]
    ↓
[Relevance Filter] → drop below threshold → [top N items]
    ↓
[Synthesizer - LLM Pass 2] → full digest sections → [Digest object]
    ↓
[MarkdownRenderer] → write to file → [briefing_{date}.md]
```

### 4.3 LLM Backend Abstraction

The `llm/client.py` module abstracts the LLM backend so users can swap providers via config:

```python
class LLMClient:
    def complete(self, system: str, user: str, model: str) -> str
```

Supported backends (MVP):
- **GitHub Models** (default) — OpenAI-compatible, uses `GITHUB_TOKEN`
- **OpenAI** — direct API, uses `OPENAI_API_KEY`
- **Anthropic** — Claude API, uses `ANTHROPIC_API_KEY`

Backend is selected via `config.yaml`:
```yaml
llm:
  backend: "github_models"  # or "openai" or "anthropic"
```

### 4.4 Caching & Deduplication

SQLite-based cache stored in `cache/radar.db`:
- Table: `seen_items(url_hash, content_hash, seen_at)`
- Items are considered duplicate if URL hash OR content hash matches
- Cache TTL: configurable (default: 30 days)
- Cache is checked before any fetch or LLM call

### 4.5 Dependencies

```
# Core
requests
feedparser
trafilatura
openai          # used for all backends (OpenAI-compatible)
pyyaml
python-dotenv
click           # CLI

# Gmail
google-auth
google-auth-oauthlib
google-api-python-client

# Dev
pytest
ruff
```

---

## 5. Non-Functional Requirements

| Requirement | Target |
|---|---|
| Total pipeline runtime | < 5 minutes for a typical daily run |
| LLM API calls per run | < 10 (batching enforced) |
| Cost per run (GitHub Models) | $0 (rate-limited free tier) |
| Cost per run (OpenAI fallback) | < $0.10 |
| Setup time for new user | < 30 minutes with documented steps |
| Python version | 3.11+ |
| Platform | macOS, Linux, GitHub Actions (Ubuntu) |

---

## 6. Security & Privacy

- All secrets in `.env`, never committed
- `.env` and `cache/` in `.gitignore`
- Gmail OAuth uses read-only scope (`gmail.readonly`)
- No user data sent to third parties beyond the configured LLM backend
- Digests may contain article content — user responsible for not committing proprietary content

---

## 7. Open-Source Considerations

- `config.example.yaml` ships with sensible defaults and comments explaining every field
- `.env.example` documents every required secret with setup instructions
- README includes: quickstart, full config reference, adding a custom source, swapping LLM backends
- Source connectors are self-contained — adding a new source requires only implementing the `Source` ABC and registering it in config
- LLM backend is swappable via one config line — no code changes needed

---

## 8. Post-MVP Roadmap

| Feature | Notes |
|---|---|
| Blog auto-publish | AI writes article from digest, publishes to GitHub Pages or dev.to |
| Podcast transcript ingestion | RSS + whisper transcription |
| Web UI | Simple read-only digest viewer |
| Embedding-based relevance filtering | Replace keyword pre-filter with semantic similarity |
| Weekly synthesis digest | Cross-day trend analysis |
| X/Twitter ingestion | Requires API access |
| Slack/email delivery | Send digest to inbox or channel |

---

## 9. Open Questions

| # | Question | Notes |
|---|---|---|
| 1 | How to handle paywalled articles linked from newsletters? | Graceful skip + flag in digest |
| 2 | Should ArXiv abstracts only, or attempt full paper? | Abstracts for MVP |
| 3 | GitHub Actions secrets management for Gmail OAuth? | May need token refresh flow |
| 4 | Should digests be committed to repo or artifacts only? | Configurable |
| 5 | Rate limit handling strategy for GitHub Models? | Exponential backoff + daily run timing |
