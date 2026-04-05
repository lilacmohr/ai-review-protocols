# Spec Quality Scorecard — ai-radar

**Spec:** `SPEC.md` (Version 0.3 MVP — Open Questions Resolved)
**Evaluated:** 2026-04-05
**Evaluator:** Spec Quality Evaluator (Claude Opus 4.6)
**Previous score:** 4.91 (v0.1, 2026-04-04)

---

## Summary

| # | Dimension | Weight | Score | Weighted |
|---|---|---|---|---|
| 1 | Unambiguity | 25% | 7.5 | 1.875 |
| 2 | Completeness | 20% | 7.0 | 1.400 |
| 3 | Consistency | 15% | 8.5 | 1.275 |
| 4 | Verifiability | 15% | 6.5 | 0.975 |
| 5 | Implementation Guidance | 10% | 7.5 | 0.750 |
| 6 | Forward Traceability | 5% | 7.5 | 0.375 |
| 7 | Singularity | 5% | 6.5 | 0.325 |
| 8 | Failure Mode Coverage | 3% | 7.5 | 0.225 |
| 9 | Interface Contracts | 2% | 7.0 | 0.140 |
| | **Weighted Total** | **100%** | | **7.34** |

**Overall Assessment:** The spec has improved dramatically from 4.91 to 7.34 — crossing the implementation-ready threshold. An AI agent could now build a working system that matches the spec's intent without major architectural divergence. The data models are fully defined, the pipeline flow is unambiguous, failure handling is specified, and cross-cutting conventions (logging, error handling, testing) are documented. The remaining gaps — prompt templates, per-module acceptance criteria, and LLM output quality verification — are real but bounded. Two agents implementing from this spec would produce structurally and behaviorally compatible code, differing mainly in prompt engineering choices and minor interface details.

---

## Dimension Details

### 1. Unambiguity — 7.5 / 10 (Weight: 25%) ↑ from 5.5

**Rationale:** The major ambiguities from v0.1 have been resolved — pre-filter algorithm, content fingerprinting, pipeline ordering, LLM output schema, and config structure are all now precisely specified. Remaining ambiguities are acknowledged in Section 10 and unlikely to cause major implementation divergence.

**Key Finding:** The pre-filter (3.2 step 6) is now fully specified: "case-insensitive substring match against the user's `interests` list. Fields searched: title + excerpt (~200 words). An article passes if ANY keyword from the `interests` list matches." This resolves the single biggest ambiguity from v0.1, which would have caused 4x variation in filter pass-through rates between implementations.

**Resolved ambiguities (previously scored):**
- Content fingerprints: now SHA-256 of normalized URL and SHA-256 of clean_text (3.2 steps 2, 5; 4.4)
- Pipeline ordering: reconciled via two-phase architecture — excerpt fetch before Pass 1, full fetch after (4.2)
- LLM Pass 1 output: JSON schema specified with `url`, `score`, `summary` fields (3.3)
- "optionally commits": replaced by `commit_digests: false` config key (3.5)
- Gmail OAuth flow: fully specified including `radar auth gmail`, token expiry handling, GCP modes (3.1)
- Config schema: `llm.backend`, `cache_ttl_days`, `max_cost_per_run` all in the config.yaml example (3.5)
- ArXiv excerpt handling: "abstract text is used directly as the excerpt... web fetch step is bypassed" (3.2 step 4)

**Remaining ambiguities:**
- **Prompt templates** — `prompts.py` is listed but no prompt text is specified for Pass 1 or Pass 2. Acknowledged as implementation gap #1 (Section 10). The task descriptions ("relevance score 1-10 against user role/interests + 2-3 sentence summary") and output schema provide constraints, but two agents would write materially different prompts. This is the single largest remaining ambiguity.
- **`max_articles_to_summarize` cap placement** — config defines this as 30, but the data flow (4.2) doesn't show where this cap applies. Presumably between PreFilter and Summarizer. If more than 30 articles pass the pre-filter, which are dropped? By recency? Randomly? Not specified.
- **Pass 2 output boundary** — Section 3.4 shows the digest format and notes "output/markdown.py renders the Pipeline Metadata section and the disclosure footer." This implies the LLM generates content sections and markdown.py adds metadata + footer, but the exact boundary isn't explicit. Does the LLM return raw markdown? Structured sections? A single string?
- **ArXiv connector mechanism** — Source table says "ArXiv API + RSS" without specifying which is used when. Config has `categories` and `max_results` suggesting an API query, but the connector's actual implementation approach isn't stated.
- **URL tracking parameter stripping** — "strip tracking parameters (`utm_*`, etc.)" — the "etc." is vague. What other parameter families? Minor in practice.
- **Keyword pre-filter noise** — Acknowledged in Section 10 gap #5: short terms like "AI" will match "detail", "maintain". Accepted for MVP with LLM scoring as cleanup.

**Improvement to gain +2 points:** Specify prompt template structure for Pass 1 and Pass 2 (system message role, user message format, expected output format, few-shot examples if any). This single change would resolve the largest remaining ambiguity and bring the score to 9+.

---

### 2. Completeness — 7.0 / 10 (Weight: 20%) ↑ from 4.5

**Rationale:** The spec now covers all major modules, data models, failure modes, and cross-cutting concerns. The completeness gaps from v0.1 — undefined data models, missing failure handling, absent logging/testing strategy — are resolved. The remaining gaps are prompt templates and per-module acceptance criteria.

**Key Finding:** All six data models are now fully defined with field names, types, and explanatory comments: `RawItem` (6 fields), `NormalizedItem` (8 fields, noted as internal), `ExcerptItem` (7 fields), `ScoredItem` (7 fields), `FullItem` (8 fields), `Digest` (7 fields). This was the #1 improvement recommendation from the v0.1 scorecard and it has been thoroughly addressed. Two agents implementing adjacent pipeline stages will produce type-compatible code.

**Completeness gaps resolved since v0.1:**
- Data models: fully defined (was "referenced but never defined")
- Gmail OAuth: complete flow including `radar auth gmail`, token expiry, GCP modes
- CLI: 6 commands specified (`run`, `check`, `auth gmail`, `cache clear`, `cache stats`, `cache remove <url>`)
- Failure handling: full Section 3.7 with 7 failure scenarios, exit code contract, and failure-digest template
- Logging: Section 4.7 with format, levels, per-stage breadcrumbs, security constraints
- Testing: Section 4.6 with test levels, required infrastructure, fixture descriptions
- Cache: two-phase dedup, TTL, safety guarantees, CI persistence pattern
- GitHub Actions: secrets, permissions, cache persistence, workflow fragments
- Web scraping: clarified as internal utility (trafilatura in excerpt/full fetchers), not a standalone source

**Remaining completeness gaps:**
- **No per-module acceptance criteria** — The spec still has no explicit "this module is correctly implemented when..." statements. Behaviors are described in enough detail that acceptance criteria could be derived, but they aren't stated. This remains the single biggest completeness gap.
- **Prompt templates not specified** — Acknowledged as gap #1 in Section 10. The task descriptions and output schemas constrain the prompts, but the actual text is absent. For a tool whose value proposition is LLM-generated content, this is a significant gap.
- **`config.py` validation rules** — "config loading and validation" is described, and `test_config.py` is listed for "confirm bad configs are caught on load," but what constitutes invalid config is not specified. Missing required fields? Wrong types? Unknown keys? Out-of-range values?
- **`pipeline.py` orchestration details** — The data flow (4.2) shows stage progression, but `pipeline.py`'s internal logic isn't described. Does it return a result object? How does it track the partial-failure exit code (1 vs 0)?
- **Pass 2 input assembly** — Section 3.3 says Pass 2 receives "full article text for the top `max_articles_in_digest` articles from Pass 1" plus "the user's full role/interest profile as system context." But how is this assembled into a prompt? Is each article a separate message? One concatenated string? A JSON structure?
- **`examples/sample-briefing.md`** — Referenced in Section 7 but content not specified. An agent would need to fabricate realistic content.

**Improvement to gain +2 points:** Add acceptance criteria for each module — even one testable assertion per module. Example: "Gmail source is correctly implemented when: (1) it returns a `list[RawItem]` containing one item per unread email in the configured labels, filtered by configured senders if specified, (2) it marks processed emails as read, (3) it exits with a descriptive error on token expiry." This would also improve Verifiability.

---

### 3. Consistency — 8.5 / 10 (Weight: 15%) ↑ from 5.0

**Rationale:** The structural contradictions from v0.1 have been resolved. The pipeline ordering, config schema, dependency list, and env vars are now internally consistent. The remaining inconsistencies are minor and non-load-bearing.

**Key Finding:** The pipeline architecture has been fundamentally redesigned into a coherent two-phase model: excerpt fetch → Pass 1 scoring → full article fetch → Pass 2 synthesis. This eliminates the previous contradiction between Sections 3.2 and 4.2 and introduces a clean architectural concept (score cheaply on excerpts, then invest in full fetches only for survivors). The data flow diagram (4.2) and prose descriptions (3.2, 3.3) now describe the same pipeline.

**Contradictions resolved since v0.1:**
- Pipeline ordering: fully reconciled via the two-phase architecture
- Config schema: `llm.backend` now in config.yaml example (3.5), matches Section 4.3
- Env vars: `GITHUB_MODELS_TOKEN` in `.env` example, post-MVP keys commented out, consistent with 4.3
- Gmail senders: `senders` config now present in config.yaml (3.5), matching source table (3.1)
- Anthropic dependency: resolved — only GitHub Models in v0.1, Anthropic is post-MVP (4.3, 4.5)
- Cache timing: reconciled — cache is checked before fetch (skip known URLs) but items are written only after successful digest generation (3.7, 4.4)
- Normalize step: eliminated as a separate step; normalization is internal to the fetchers. `NormalizedItem` is documented as "not passed between pipeline stages directly" (3.1 data models)

**Minor remaining inconsistencies:**
- **Terminology drift** — "article" vs "item" persists in prose vs code. Data models use "Item" suffix consistently; prose says "articles." This is acceptable — the mapping is obvious and the types are unambiguous.
- **`models.py` description in 4.1** — Lists "RawItem, ExcerptItem, ScoredItem, FullItem, Digest" but omits `NormalizedItem`. Consistent with the note that NormalizedItem is internal, but the file listing could include it for completeness.
- **Source interface method style** — Section 3.1 shows `name(self) -> str` as a method. In practice this would likely be a property or class attribute. Not specified which. Very minor.
- **`max_articles_to_summarize` vs pipeline flow** — The config defines this cap (30) but the data flow diagram (4.2) doesn't show where it's applied. Not a contradiction per se — just an omission in the flow diagram.

**Score justification:** No structural contradictions remain. The config schema, data models, pipeline flow, and dependency list are internally consistent. The minor terminology drift and omissions are cosmetic.

---

### 4. Verifiability — 6.5 / 10 (Weight: 15%) ↑ from 4.0

**Rationale:** The spec's behavioral descriptions are now concrete enough to write meaningful tests for most modules. Pass 1 has a JSON schema, exit codes are defined, failure behaviors are specified, and the testing strategy names specific test categories. However, no explicit acceptance criteria exist, and LLM output quality — the core value proposition — remains unverifiable beyond structural checks.

**Key Finding:** The LLM pipeline (Pass 1 + Pass 2) is the core value proposition, but verification stops at structural compliance. Pass 1's JSON schema (url, score, summary) can be validated structurally. But there is no strategy for verifying that a relevance score of 7 is correct, that summaries are accurate, that "contrarian insights" are actually contrarian, or that "trending themes" reflect real patterns. Section 4.6 specifies "LLM contract tests: schema validation, parse failure handling" — this tests the plumbing, not the output quality. Without even a small golden-set test (3-5 known articles with expected score ranges), the LLM pipeline is structurally verifiable but semantically unverifiable.

**What is now verifiable (improvements since v0.1):**
- Pass 1 output schema: JSON with `url` (string), `score` (integer 1-10), `summary` (string, 2-3 sentences) — structurally testable
- Pass 1 retry contract: malformed output → retry once → skip batch on second failure — testable
- Pass 1 URL validation: "every input URL appears in the output; missing URLs treated as score 0" — testable
- Exit codes: 0 = success, 1 = partial failure, 2 = fatal — testable
- Source failures: "log and skip, never abort, all-fail → exit 2" — testable
- Paywalled articles: "< 50 words after extraction → skip and flag" — testable with threshold
- LLM API errors: "exponential backoff, max 3 retries, fail loudly" — testable
- Zero articles: "write minimal digest, exit 0" — testable
- Cache idempotency: "safe to re-run after any failure" — testable
- Dedup: "duplicate if URL hash OR content hash matches" — testable
- Pre-filter: "case-insensitive substring match, ANY keyword" — testable by definition
- Digest structure: section headings and content counts ("3-5 bullet points", "2-3 sentences") — countable
- NFRs: "< 5 minutes", "< 10 API calls" — measurable
- Logging breadcrumbs: per-stage INFO messages with specific metrics — testable

**What is still not verifiable:**
- No per-module "done when..." acceptance criteria
- LLM output quality: no golden-set tests, no minimum quality bar, no assertion strategy beyond schema
- Config validation rules: what constitutes invalid config is unspecified
- Digest content quality: "contrarian insights", "trending themes", "follow-up questions" — subjective without a rubric
- Pre-filter precision/recall: no targets (but deterministic, so testable by example)

**Improvement to gain +2 points:** Add a small golden-set test specification: 3-5 known articles with expected Pass 1 score ranges (e.g., "an article about LLM inference optimization should score 8-10; an article about agricultural policy should score 1-3 for the default profile"). Add structural validation rules for Pass 2 output (e.g., "executive summary must contain 3-5 bullet points; contrarian section must contain 3-5 numbered observations"). These would make the LLM pipeline meaningfully verifiable.

---

### 5. Implementation Guidance — 7.5 / 10 (Weight: 10%) ↑ from 5.5

**Rationale:** The spec now provides explicit conventions for error handling, logging, testing, and caching — the major gaps from v0.1. Technology choices are clear and the file structure is detailed. The main remaining gap is prompt engineering guidance.

**Key Finding:** Section 3.7 (Failure Handling) establishes a clear, consistent error handling convention: source failures → log and skip; LLM parse failures → retry once then skip batch; LLM API errors → exponential backoff, max 3 retries, fail loudly; partial pipeline failure → continue and generate digest; all sources failed → exit 2, write failure-digest. This single addition resolves the biggest implementation guidance gap from v0.1. Two agents implementing different source connectors will now handle errors the same way.

**Guidance now provided (improvements since v0.1):**
- **Error handling:** Full convention in Section 3.7 — log-and-skip for sources, retry-then-skip for LLM, exponential backoff for API errors, exit codes for pipeline outcomes
- **Logging:** Section 4.7 — INFO default, structured format, per-stage breadcrumbs with specific metrics, security constraints (no raw HTTP details, no content above DEBUG)
- **Testing:** Section 4.6 — unit/contract/integration test levels, `TestLLMClient` mock, per-source-type fixtures, CI workflow
- **LLM output parsing:** Pass 1 uses JSON mode/structured output; parsing responsibility assigned to `Summarizer`, not `LLMClient` (3.3)
- **Cache architecture:** SQLite with specific table schema, two-phase dedup, TTL purge on each run, items marked seen only after successful digest (4.4)
- **GitHub Actions:** Detailed cache persistence pattern with `actions/cache`, secret configuration, workflow permissions (3.6)
- **Technology choices:** SQLite, trafilatura, click, feedparser, openai SDK for GitHub Models — all clear
- **File structure:** 30+ files listed with descriptive comments

**Remaining guidance gaps:**
- **Prompt templates** — No prompt text, no system message structure, no few-shot examples, no guidance on prompt engineering approach. Section 10 says "design iteratively" which is reasonable but leaves the agent without a starting point. This is the largest gap.
- **Async vs sync** — Never stated. The absence of async mentions implies synchronous. For a daily pipeline this is fine, but an explicit "synchronous pipeline, no async" statement would remove ambiguity.
- **Processing module method signatures** — Deduplicator, PreFilter, Truncator, ExcerptFetcher, FullFetcher — input/output types are known from the data flow but method names, constructor parameters, and configuration injection patterns are not specified.
- **Retry backoff parameters** — "Exponential backoff, max 3 retries" — base delay? Jitter? Minor.
- **Custom exception hierarchy** — Failure handling describes behavior but no custom exception types. An agent might use built-in exceptions or create custom ones.

**Improvement to gain +2 points:** Add prompt template structure for Pass 1 and Pass 2 — at minimum, the system message role description, user message format (how articles are presented), and output parsing expectations. Also specify processing module method signatures (e.g., `Deduplicator.deduplicate(items: list[RawItem], cache: Cache) -> list[RawItem]`).

---

### 6. Forward Traceability — 7.5 / 10 (Weight: 5%) ↑ from 6.5

**Rationale:** The spec maintains strong implicit traceability between requirements and files. Every file in the repo structure has a descriptive comment, and the section organization maps cleanly to the directory structure. The CLI reference (3.6) and test file descriptions (4.6) add traceability that was previously absent.

**Key Finding:** The spec's organization enables direct issue creation at the module level. A GitHub Issue for "Implement Gmail source connector" can reference Section 3.1 (source interface + Gmail OAuth), the `RawItem` model, the failure handling convention (3.7), and the test expectation (4.6: "one fixture file per source type: sample Gmail email HTML"). This is sufficient for an AI agent to scope and implement the module. The gap is at the sub-module level — individual requirements within each section are not numbered, so an issue like "Implement pre-filter" must reference all of Section 3.2 step 6 rather than a specific requirement ID.

**Traceability mapping:**
| Spec Section | File(s) | Status |
|---|---|---|
| 3.1 Source Ingestion | `radar/sources/*.py` | Strong — each source has a file, interface defined |
| 3.1 Data Models | `radar/models.py` | Strong — all 6 dataclasses fully specified |
| 3.2 Preprocessing | `radar/processing/*.py` | Strong — each step maps to a file |
| 3.3 LLM Pipeline | `radar/llm/*.py` | Good — Pass 1 → summarizer.py, Pass 2 → synthesizer.py |
| 3.4 Digest Format | `radar/output/markdown.py` | Good — format specified, rendering responsibility clear |
| 3.5 Configuration | `radar/config.py`, `config.yaml` | Good — full config example provided |
| 3.6 Triggers | `.github/workflows/`, `__main__.py` | Good — CLI commands listed, workflow fragments shown |
| 3.7 Failure Handling | Cross-cutting | Good — behaviors specified per failure type |
| 4.6 Testing | `tests/*.py` | Good — test file purposes described |
| 4.7 Logging | Cross-cutting | Good — convention established |

**Remaining traceability gaps:**
- No requirement IDs (FR-X.Y.Z) for granular issue writing
- `AGENTS.md` is described in a repo structure comment but has no functional requirement driving it
- `examples/sample-briefing.md` is referenced but has no content specification
- `config.example.yaml` vs `config.yaml` relationship is implied (presumably identical structure, placeholder values) but not explicit

---

### 7. Singularity — 6.5 / 10 (Weight: 5%) ↑ from 5.0

**Rationale:** Data models are now well-decomposed into 6 distinct types with individual fields. Failure handling is decomposed into 7 distinct scenarios. The main singularity issues — compound requirements in the LLM and preprocessing sections — persist but are less likely to cause partial compliance because the individual elements are now better described.

**Key Finding:** LLM Pass 1 still combines scoring and summarization in one call ("relevance score 1-10 + 2-3 sentence summary per article"), but the output schema now separates them into distinct JSON fields (`score`, `summary`). An agent cannot easily implement one without the other when both appear in the same JSON schema. Similarly, Pass 2 generates all digest sections in one call, but the digest format (3.4) enumerates each section with distinct content descriptions. The risk of partial compliance is reduced because the output structure makes completeness checkable.

**Compound requirements (reduced risk vs v0.1):**
- **Pass 1:** scoring + summarization — mitigated by JSON schema requiring both fields
- **Pass 2:** all digest sections in one call — mitigated by explicit section list in 3.4
- **Section 3.2 preprocessing:** 6 steps as one list — mitigated by each step having its own file in the repo structure and its own description
- **Section 3.6 triggers:** "support all three trigger modes" — mitigated by the fact that the code is the same (`python -m radar run`); the modes differ only in invocation context
- **Section 4.7 logging:** multiple requirements (format, levels, breadcrumbs, security) under one heading — still bundled

**Remaining singularity concerns:**
- Section 3.1 Gmail connector bundles: source interface implementation + OAuth flow + email parsing + URL extraction + read-marking. These are all aspects of one connector, but an issue for "implement Gmail source" covers a lot of distinct behaviors.
- Section 7 README: "quickstart, full config reference, adding a custom source, swapping LLM backends" — four documentation requirements in one bullet.
- `radar check` command: "validate config, test credentials for each enabled source, fetch one item per source" — three distinct checks in one command description.

**Improvement to gain +2 points:** Decompose the Gmail connector into sub-requirements: (1) implement Source ABC interface, (2) OAuth token management, (3) email fetching from configured labels/senders, (4) URL extraction from email body, (5) mark-as-read behavior. Number preprocessing steps as individual requirements.

---

### 8. Failure Mode Coverage — 7.5 / 10 (Weight: 3%) ↑ from 2.5

**Rationale:** Section 3.7 is a comprehensive failure handling specification that addresses the most critical failure modes for a daily pipeline calling multiple external APIs. The spec has gone from "designed entirely for the happy path" to having explicit behaviors for source failures, LLM errors, empty pipelines, and partial failures.

**Key Finding:** The cache safety guarantee — "Items are marked 'seen' only AFTER successful digest generation, not at fetch time" (3.7) — is the most architecturally important failure mode decision in the spec. It ensures idempotent re-runs after any failure without duplicating work or corrupting state. Combined with the exit code contract (0/1/2) and the failure-digest file template, the pipeline's failure behavior is well-defined for operational use.

**Failure modes now covered:**
- Source fetch failures: log and skip, never abort, all-fail → exit 2 + failure-digest (3.7)
- Paywalled/unextractable articles: < 50 words → skip, flag in metadata (3.7)
- LLM parse failures (Pass 1): validate schema → retry once → skip batch (3.3, 3.7)
- LLM API errors (429, 5xx, timeout): exponential backoff, max 3 retries, fail loudly (3.7)
- Zero qualifying articles: minimal digest "no notable content found today", exit 0 (3.7)
- Fatal conditions (all sources failed OR synthesis unreachable): exit 2, failure-digest (3.7)
- Cache on partial failure: items marked seen only after success, re-run safe (3.7, 4.4)
- Gmail token expiry: detect and exit with descriptive re-auth instructions (3.1)
- Cache miss in CI: pipeline runs without dedup, safe, populates cache normally (3.6)
- Cache deletion: "always safe — causes full reprocess, no data loss" (4.4)
- Context window overflow (Pass 2): truncate article list, remove lowest-scored first, log warning (3.3)

**Remaining uncovered failure modes:**
- **Empty LLM response** — What if the LLM returns a valid but empty JSON array `[]` for Pass 1? Not explicitly addressed. Likely handled by "missing URLs treated as score 0" but could be stated.
- **Malformed external data** — What if an RSS feed returns invalid XML? What if the HN Algolia API returns missing fields? The "log and skip source" behavior provides an implicit default, but no explicit handling for parse errors in source data.
- **Cache corruption** — What if `radar.db` is corrupted (disk error, partial write)? The "deleting cache/radar.db is always safe" note provides a recovery path but no detection.
- **Disk full** — What if the output directory can't be written to? Not addressed. Minor for MVP.
- **Concurrent runs** — What if two pipeline instances run simultaneously? No locking mechanism. SQLite handles concurrent reads but not concurrent writes gracefully. Minor for a daily cron job.

**Improvement to gain +2 points:** Add explicit handling for: (1) empty LLM response (treat as batch failure, apply retry logic), (2) source data parse errors (log and skip individual items, not entire source), (3) SQLite corruption detection (catch `sqlite3.DatabaseError`, log, delete and recreate cache).

---

### 9. Interface Contracts — 7.0 / 10 (Weight: 2%) ↑ from 4.0

**Rationale:** All six data model types are fully defined with field names, types, and constraints. The `Source` ABC and `LLMClient` interfaces have method signatures. The data flow diagram (4.2) shows the type progression at each stage boundary. Two agents implementing adjacent pipeline stages would produce type-compatible code because the shared types are well-specified.

**Key Finding:** The type progression through the pipeline is now explicit and complete: `RawItem` → `ExcerptItem` → `ScoredItem` → `FullItem` → `Digest`. Each type is a distinct dataclass with typed fields. An agent implementing the Summarizer knows it receives `ExcerptItem` objects and must produce `ScoredItem` objects — both fully defined. This eliminates the v0.1 problem where agents would independently invent incompatible data structures.

**Interface analysis (updated):**

| Interface | Input Spec | Output Spec | Error Convention | Empty Behavior |
|---|---|---|---|---|
| `Source.fetch()` | self + config | `list[RawItem]` ✅ defined | Log and skip (3.7) | Not specified |
| `Source.is_enabled()` | none | `bool` | N/A | N/A |
| `Deduplicator (Phase 1)` | `list[RawItem]` | `list[RawItem]` (filtered) | Implicit (pass-through) | Not specified |
| `URL Extractor` | Gmail `RawItem` | URL list | Not specified | Not specified |
| `Excerpt Fetcher` | URL list | `list[ExcerptItem]` ✅ defined | < 50 words → skip (3.7) | Not specified |
| `Deduplicator (Phase 2)` | `list[ExcerptItem]` | `list[ExcerptItem]` (filtered) | Implicit (pass-through) | Not specified |
| `PreFilter` | `list[ExcerptItem]` | `list[ExcerptItem]` (filtered) | Implicit (pass-through) | Not specified |
| `LLMClient.complete()` | `system: str, user: str, model: str` | `str` | Backoff + retry (3.7) | Not specified |
| `Summarizer (Pass 1)` | `list[ExcerptItem]` | `list[ScoredItem]` ✅ defined | Retry once → skip batch (3.3) | Not specified |
| `Full Article Fetcher` | `list[ScoredItem]` | `list[FullItem]` ✅ defined | < 50 words → skip (3.7) | Not specified |
| `Truncator` | `list[FullItem]` | `list[FullItem]` (truncated) | N/A | Not specified |
| `Synthesizer (Pass 2)` | `list[FullItem]` + profile | `Digest` ✅ defined | Fatal if unreachable (3.7) | Zero articles → minimal digest (3.7) |
| `MarkdownRenderer` | `Digest` | file on disk | Not specified | Not specified |

**Remaining gaps:**
- **Empty input behavior** — Most interfaces don't specify behavior for empty input. What does PreFilter return for an empty list? What does Deduplicator do with zero items? The pipeline-level "zero qualifying articles" behavior (3.7) handles the aggregate case but not individual stage boundaries.
- **Processing module method signatures** — Deduplicator, PreFilter, Truncator, ExcerptFetcher, FullFetcher — their method names and constructor parameters are not specified. We know input/output types from the data flow but not the API shape.
- **Error types** — No custom exception hierarchy. The failure handling section describes behavioral responses but not the exception types that trigger them. Is a source failure a `ConnectionError`? A custom `SourceFetchError`? Not specified.
- **URL Extractor interface** — This module (3.2 step 3) has no type annotation. Input is a Gmail `RawItem`, output is presumably a list of URL strings, but this isn't typed.

**Improvement to gain +2 points:** Specify empty-input behavior as a convention: "All filtering/processing stages return an empty list when given empty input — they never raise exceptions on empty input." Add method signatures for processing modules.

---

## Weighted Score Calculation

| Dimension | Weight | Score | Calculation | Weighted Score |
|---|---|---|---|---|
| Unambiguity | 0.25 | 7.5 | 0.25 × 7.5 | 1.875 |
| Completeness | 0.20 | 7.0 | 0.20 × 7.0 | 1.400 |
| Consistency | 0.15 | 8.5 | 0.15 × 8.5 | 1.275 |
| Verifiability | 0.15 | 6.5 | 0.15 × 6.5 | 0.975 |
| Implementation Guidance | 0.10 | 7.5 | 0.10 × 7.5 | 0.750 |
| Forward Traceability | 0.05 | 7.5 | 0.05 × 7.5 | 0.375 |
| Singularity | 0.05 | 6.5 | 0.05 × 6.5 | 0.325 |
| Failure Mode Coverage | 0.03 | 7.5 | 0.03 × 7.5 | 0.225 |
| Interface Contracts | 0.02 | 7.0 | 0.02 × 7.0 | 0.140 |
| **Total** | **1.00** | | | **7.340** |

---

## Score Change Summary

| Dimension | v0.1 Score | v0.3 Score | Change | Primary Driver |
|---|---|---|---|---|
| Unambiguity | 5.5 | 7.5 | +2.0 | Pre-filter algorithm, fingerprint method, Pass 1 schema specified |
| Completeness | 4.5 | 7.0 | +2.5 | All data models defined, failure handling, logging, testing added |
| Consistency | 5.0 | 8.5 | +3.5 | Pipeline redesigned as two-phase, config schema reconciled |
| Verifiability | 4.0 | 6.5 | +2.5 | Pass 1 schema, exit codes, failure behaviors all testable |
| Implementation Guidance | 5.5 | 7.5 | +2.0 | Error handling convention, logging convention, testing strategy |
| Forward Traceability | 6.5 | 7.5 | +1.0 | CLI reference, test file descriptions added |
| Singularity | 5.0 | 6.5 | +1.5 | Data models decomposed, failure scenarios separated |
| Failure Mode Coverage | 2.5 | 7.5 | +5.0 | Full Section 3.7 added with 7 failure scenarios + exit codes |
| Interface Contracts | 4.0 | 7.0 | +3.0 | All data models fully typed, type progression explicit |
| **Weighted Total** | **4.91** | **7.34** | **+2.43** | |

---

## Top 3 Improvements by Impact

These are the changes that would most improve the weighted score, ordered by impact:

1. **Specify prompt template structure for Pass 1 and Pass 2 (+0.8–1.2 weighted points).** The prompts are the single largest remaining ambiguity and the core driver of output quality. At minimum: system message role, user message format (how articles are presented), output format instructions, and any few-shot examples. This improves Unambiguity (the largest-weighted dimension), Completeness, and Implementation Guidance simultaneously.

2. **Add per-module acceptance criteria (+0.6–1.0 weighted points).** One testable "done when..." assertion per module would dramatically improve Verifiability (currently the lowest-scoring high-weight dimension) and Completeness. For LLM outputs, add a golden-set test: 3-5 known articles with expected score ranges. For deterministic modules, state the exact input→output contract. This is the single most impactful structural change.

3. **Specify processing module method signatures and empty-input convention (+0.3–0.5 weighted points).** Define method names for Deduplicator, PreFilter, Truncator, ExcerptFetcher, FullFetcher. Establish a convention: "all filtering/processing stages return empty list on empty input." This improves Interface Contracts, Singularity, and Unambiguity for the processing layer.

---

## Verdict

**Implementation-ready with targeted gaps.** The spec has crossed the implementation-ready threshold (7.0+), improving from 4.91 to 7.34. An AI agent given this spec would produce a system that matches the architectural intent, uses the correct data models, handles failures consistently, and generates a structurally correct digest. The two-phase pipeline design (excerpt → score → full fetch) is clean and well-specified.

The remaining gaps are concentrated in two areas: (1) prompt engineering (no templates, no quality verification strategy) and (2) formal acceptance criteria (behaviors are described but not stated as testable assertions). These gaps mean the agent will produce working code with correct structure and consistent conventions, but the LLM output quality will depend entirely on the agent's prompt engineering judgment — which may or may not align with the spec author's intent.

**Recommended next step:** Address improvement #1 (prompt templates) before implementation begins, as prompt quality is the primary driver of the tool's value and is the one area where divergent agent choices have the highest impact on user experience. Improvement #2 (acceptance criteria) can be deferred to a post-implementation verification pass.
