# CLAUDE.md — ai-radar Agent Briefing

> **Who this file is for:** Claude Code (primary), and any engineer joining this project.
> **What it is:** The encoded contract between this codebase's standards and every AI agent
> or human that contributes to it. Read this before writing a single line of code.
>
> *Part of the AI Engineering Playbook — ai-radar is the reference implementation.*

---

## 1. Project Overview

**ai-radar** is a daily briefing pipeline that ingests articles from multiple sources (RSS,
Hacker News, ArXiv, Gmail), scores them for relevance via LLM (Pass 1), synthesizes a
digest via LLM (Pass 2), and delivers it by email.

It runs headlessly as a GitHub Actions cron job. There is no UI. Logs are the only
debugging surface during CI runs. Correctness, observability, and safe failure behavior
are the highest priorities — not cleverness.

**Spec:** `SPEC.md` is the authoritative source of truth for architecture, data models,
pipeline behavior, and failure handling. When this file and the spec conflict, the spec
wins. Raise the conflict rather than silently choosing one.

**When context gets long:** Preserve the failure handling table (§5), the quality gate
checklist (§7), and the current task's spec reference. These are the highest-priority
instructions if compaction forces tradeoffs.

---

## 2. Architecture at a Glance

```
Sources → Dedup → Excerpt Fetch → Pre-Filter → Pass 1 (LLM) →
Full Fetch → Truncate → Pass 2 (LLM) → Markdown → Email
```

**Two-phase design (critical to understand before touching the pipeline):**
- Phase 1 works on excerpts (~200 words). Cheap. Filters aggressively.
- Phase 2 works on full article text. Expensive. Only survivors from Phase 1 get here.

Never fetch full article text before Pass 1 scoring. Never call the LLM on unfiltered
input. These constraints exist to control cost and latency (target: <5 min, <10 API calls).

**Data flows as typed dataclasses through each stage:**
`RawItem → ExcerptItem → ScoredItem → FullItem → Digest`

All models are defined in `radar/models.py`. The type at each stage boundary is the
interface contract between pipeline stages. Changing a model field requires updating
every stage that produces or consumes it.

---

## 3. Autonomy & Decision-Making

**Make implementation decisions autonomously.** Do not ask for permission to:
- Choose variable names, function signatures for internal helpers
- Add private utility methods within a module
- Write additional test cases beyond those specified
- Add type aliases or constants for clarity

**Stop and surface a decision when:**
- A spec requirement is ambiguous and two interpretations would produce structurally
  different code (e.g., different data model shapes, different error exit codes)
- An implementation would require deviating from the pipeline data flow in `SPEC.md §4.2`
- A new dependency is needed that isn't in `pyproject.toml`
- You're about to change a public interface (method signature, model field, CLI command)

**When you surface a decision, format it as:**
```
DECISION NEEDED: [one-line description]
Options:
  A) [option] — [consequence]
  B) [option] — [consequence]
Spec reference: [section]
Recommendation: [your recommendation and why]
```

---

## 4. Language, Runtime & Style

| Setting | Value | Rationale |
|---|---|---|
| Python | 3.12 | Slot support in dataclasses, better error messages |
| Type checking | mypy strict | Stage-boundary bugs are the #1 integration risk |
| Linting/formatting | ruff | Single tool, fast, replaces flake8 + black + isort |
| Test framework | pytest | Standard; fixtures map cleanly to pipeline stages |
| Package management | uv | Fast, deterministic lockfile |

---

**Style rules** — non-negotiable. Quality gates enforce them.

### 4.1 Types

```python
# ALWAYS: explicit return types on every function
def fetch(self, config: SourceConfig) -> list[RawItem]:
    ...

# ALWAYS: use dataclasses for data structures
@dataclass
class ScoredItem:
    url: str
    score: int
    summary: str
    ...

# NEVER: untyped dicts as data carriers between stages
def score(items: list[dict]) -> list[dict]:  # NO
    ...
```

**Why:** The pipeline's correctness depends on type compatibility at stage boundaries.
Strict mypy catches mismatches before runtime. At team scale, typed interfaces mean
agents and engineers can implement adjacent stages independently without coordination.

### 4.2 Error Handling

```python
# ALWAYS: catch specific exceptions
try:
    response = httpx.get(url, timeout=10)
except httpx.TimeoutException:
    logger.warning("fetch_timeout", url=url)
    return None
except httpx.ConnectError:
    logger.warning("fetch_connection_error", url=url)
    return None

# NEVER: bare except or Exception catch-all without re-raise
try:
    ...
except Exception:  # NO — hides what actually failed
    pass
```

**Why (from SPEC.md §3.7):** The pipeline's failure handling model requires knowing
*what* failed to decide whether to skip, retry, or abort. Bare excepts make this
impossible. A hidden failure in a source connector looks identical to success.

### 4.3 Logging

```python
import structlog
logger = structlog.get_logger(__name__)

# ALWAYS: structured key=value pairs, never f-strings in log calls
logger.info("pre_filter_complete", input=45, output=12, elapsed_ms=230)

# NEVER: f-string interpolation in log messages
logger.info(f"Pre-filter: {45} → {12} items")  # NO

# NEVER: log raw HTTP responses, article content, or credentials (any level)
logger.debug("api_response", body=response.text)  # NO
```

**Required breadcrumbs — log these at INFO at the end of each stage:**

| Stage | Required fields |
|---|---|
| Source fetch | `source`, `item_count`, `elapsed_ms` |
| Dedup | `input`, `output`, `duplicates_removed` |
| Excerpt fetch | `input`, `fetched`, `skipped_paywall`, `elapsed_ms` |
| Pre-filter | `input`, `output`, `elapsed_ms` |
| Pass 1 (LLM) | `input`, `scored`, `skipped_parse_error`, `elapsed_ms` |
| Full fetch | `input`, `fetched`, `skipped_paywall`, `elapsed_ms` |
| Pass 2 (LLM) | `articles_in_digest`, `tokens_used`, `elapsed_ms` |
| Digest write | `output_path`, `email_sent` |

**Why:** The pipeline runs headlessly in CI. Logs are the only debugging surface.
Structured logs are machine-parseable — at team scale they feed into observability
dashboards (Datadog, Grafana) without log parsing gymnastics.

### 4.4 Module Structure

Every module follows this layout, in order:

```python
"""One-line description of what this module does.

Longer description if needed. Include: what stage of the pipeline this is,
what it receives, what it produces, and any key behavioral constraints.
"""

# 1. Standard library imports
# 2. Third-party imports
# 3. Internal imports

# 4. Module-level logger
logger = structlog.get_logger(__name__)

# 5. Constants (ALL_CAPS)

# 6. Public classes/functions (the stage's interface)

# 7. Private helpers (_underscore prefix)
```

---

## 5. Failure Handling Convention

This is the most important behavioral contract in the codebase. All agents and
engineers must implement it consistently. (Source: SPEC.md §3.7)

| Failure type | Required behavior |
|---|---|
| Single source fetch fails | Log WARNING, skip source, continue pipeline |
| All sources fail | Log ERROR, write failure-digest, exit code 2 |
| Paywall / <50 words extracted | Log INFO, skip article, flag in digest metadata |
| LLM parse failure (Pass 1) | Validate schema → retry once → skip batch on second failure |
| LLM API error (429/5xx/timeout) | Exponential backoff, max 3 retries, then fail loudly |
| Pass 2 unreachable after retries | Log ERROR, exit code 2 |
| Zero articles pass pre-filter | Write minimal digest ("no notable content today"), exit 0 |
| Context window overflow (Pass 2) | Truncate lowest-scored articles first, log WARNING |

**Exit code contract:**
- `0` — success (including zero-article digest)
- `1` — partial failure (some sources failed, digest still generated)
- `2` — fatal failure (no digest generated)

**Cache safety rule (critical):** Mark items as "seen" in the cache ONLY AFTER
successful digest generation — never at fetch time. This makes every run safely
re-runnable after any failure without data loss or duplication.

---

## 6. Testing Standards

### 6.1 TDD Workflow

Tests are written BEFORE implementation. Every GitHub Issue comes in a pair:
- `[TEST] module-name` — write the test file, all tests should fail (red)
- `[IMPL] module-name` — implement until all tests pass (green)

**Do not write implementation code until the test file exists and is failing.**

### 6.2 Test Structure

```
tests/
  unit/          # Pure logic, no I/O, no network
  contract/      # Interface compliance (Source ABC, LLMClient schema)
  integration/   # Multi-stage pipeline with mocked external services
  fixtures/      # Sample data files (one per source type)
```

### 6.3 Test Requirements Per Module

Every module must have:
- [ ] At least one test for the happy path
- [ ] At least one test for each failure mode defined in §5 above
- [ ] At least one test for empty input (all filtering stages must return `[]`, never raise)
- [ ] A contract test if the module implements a public interface (Source ABC, LLMClient)

### 6.4 Mocking

```python
# ALWAYS: use TestLLMClient (defined in tests/conftest.py) for LLM calls
# NEVER: make real API calls in unit or contract tests

# ALWAYS: use fixture files for source data (tests/fixtures/)
# NEVER: make real HTTP requests in unit tests

# Integration tests may use real HTTP to fixture URLs (recorded with pytest-recording)
```

### 6.5 Running Tests

```bash
make test          # full suite
make test-unit     # unit only (fast, no network)
make test-contract # interface compliance
make lint          # ruff check + format check
make typecheck     # mypy --strict
make check         # lint + typecheck + test (required before PR)
```

**All of these must pass before a task is considered complete.**

---

## 7. Quality Gates

A task is **done** when:
- [ ] `make check` passes with zero errors (lint + typecheck + tests)
- [ ] All tests specified in the paired `[TEST]` issue pass
- [ ] All failure modes for this module are covered by tests
- [ ] All new functions have explicit return type annotations
- [ ] All new log calls use structured key=value format
- [ ] No new bare `except` clauses introduced
- [ ] No new untyped dicts used as data carriers

**These gates are not negotiable for merging.** They exist because at team scale,
exceptions to quality standards compound — one bare except becomes the pattern
junior engineers follow; one untyped dict spreads to adjacent modules.

---

## 8. LLM Prompt Conventions

Prompts live in `radar/llm/prompts.py` as module-level string constants.
They are NOT generated dynamically or constructed inline in business logic.

```python
# CORRECT: prompts as constants, imported where needed
PASS_1_SYSTEM = """..."""
PASS_1_USER_TEMPLATE = """..."""  # Use .format() or Template for variable substitution

# WRONG: prompt strings constructed in summarizer.py business logic
prompt = f"Score this article: {article.title}..."  # NO
```

**Why:** Prompts are the primary driver of output quality. Treating them as constants
makes them reviewable, versionable, and independently testable. At team scale,
prompt changes go through the same review process as code changes — not buried in
business logic where they're invisible to reviewers.

---

## 9. Dependencies

**Approved dependencies (from SPEC.md §4.5):**

| Package | Purpose |
|---|---|
| `feedparser` | RSS/Atom parsing |
| `trafilatura` | Web content extraction |
| `openai` | GitHub Models API client |
| `structlog` | Structured logging |
| `click` | CLI framework |
| `httpx` | HTTP client (prefer over requests) |
| `google-auth-oauthlib` | Gmail OAuth |
| `google-api-python-client` | Gmail API |
| `pydantic` | Config validation |

**To add a new dependency:** Stop. Add it to `pyproject.toml` and surface as a
DECISION NEEDED (see §3). Don't import packages not in this list.

**Post-MVP only (do not use):** `anthropic` SDK, async frameworks.

---

## 10. File Naming & Location

| What | Where | Convention |
|---|---|---|
| Source connectors | `radar/sources/` | `{source_name}.py` (e.g. `gmail.py`) |
| Processing stages | `radar/processing/` | `{stage_name}.py` (e.g. `pre_filter.py`) |
| LLM stages | `radar/llm/` | `summarizer.py`, `synthesizer.py`, `client.py`, `prompts.py` |
| Data models | `radar/models.py` | All dataclasses in one file |
| Config | `radar/config.py` | Loading + validation only, no business logic |
| Tests | `tests/{unit,contract,integration}/test_{module}.py` | Mirror source structure |
| Fixtures | `tests/fixtures/` | `{source}_{scenario}.{ext}` (e.g. `rss_standard.xml`) |

---

## 11. Playbook Notes

See `docs/playbook-notes.md` for the rationale behind decisions in this file
and guidance on maintaining it at team scale.
