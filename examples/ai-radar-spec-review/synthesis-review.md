## 🎯 Synthesis Review

### How to use this comment
This is the consolidated action list from 5 independent reviewer agents (Architect, OSS Adoptability, MVP Scope, Security, Skeptic).
Work through items in order. Items marked **[HUMAN DECISION]** require your judgment — no agent recommendation was clear enough to act on without you.

---

### 🔴 Act First: Consensus Issues

These were flagged independently by 2 or more reviewers. Highest confidence, highest priority.

---

**[CONSENSUS — 5/5 reviewers] Gmail OAuth in GitHub Actions is architecturally unresolved**
Sections 3.6, 9 (Open Question #3)

Every reviewer flagged this in some form. The current spec defers it with "may need token refresh flow." OAuth requires an interactive browser for initial token acquisition; refresh tokens expire; GitHub Actions runners are ephemeral and have no browser. This isn't a detail — it's a structural blocker for one of the three stated trigger modes.

**Required action — pick one and document it in the spec:**
- (a) Declare Gmail source as local/cron-only. Document the constraint explicitly. Remove Gmail from the GitHub Actions path.
- (b) Specify the full token flow for CI: one-time local auth, refresh token stored as GitHub Secret, automatic refresh on each run, graceful degradation when token expires.

Until this is resolved, GitHub Actions + Gmail is not implementable from this spec.

---

**[CONSENSUS — 5/5 reviewers] Config numeric values are presented as decisions but are placeholders**
Sections 3.5, 5

All five reviewers flagged `max_articles_to_summarize: 30`, `max_articles_in_digest: 15`, `batch_size: 10`, `relevance_threshold: 6`, `max_words_per_article: 800`. The NFR of `< 10 LLM calls per run` is also unvalidated. The arithmetic (30 articles / batch_size 10 = 3 Pass 1 calls + 1 Pass 2 call = 4 total) checks out, but context window math does not appear: `batch_size: 10` × `800 words` ≈ 10,000 input tokens per Pass 1 call, which should be validated against the configured model.

**Required action:** For each value, either (a) confirm it's a real decision and add a one-line rationale, or (b) mark as `# TBD — tune after first runs` in `config.example.yaml`. Annotate `min_score: 100` for HN specifically — many quality posts score 50–80, and this default may over-filter.

---

**[CONSENSUS — 4/5 reviewers] No failure handling contract anywhere in the pipeline**
Sections 3.1, 3.2, 3.3 (MVP Scope, OSS, Skeptic, Architect)

With 5+ independent sources and 2 LLM passes, partial failures are routine (source down, rate-limited, malformed response, all articles below threshold). The spec defines no error behavior for any stage. Two implementers will make structurally different choices.

**Required action:** Add a failure contract section. Minimum viable version:
- Source fetch failures: log and skip (pipeline continues with remaining sources, never aborts)
- LLM parse failures: log, skip the item or retry once, never silently produce empty output
- Zero qualifying articles after filtering: write a minimal digest with "no notable content today" message, exit 0
- Fatal conditions (all sources failed, synthesis model unreachable): exit with non-zero code and clear error message

---

**[CONSENSUS — 4/5 reviewers] Zero-article pipeline behavior undefined**
Section 4.2 (Architect, OSS, MVP Scope, Skeptic)

Closely related to the above but distinct: what happens specifically when the pre-filter or relevance threshold produces zero items? This is a realistic daily occurrence (quiet news day, threshold too strict, all sources rate-limited). A silent empty file or crash is equally bad.

**Required action:** Specify explicitly: emit a short digest with a "no qualifying articles found today" notice. Exit 0. Do not crash or write an empty file.

---

**[CONSENSUS — 2/5 reviewers] LLM Pass 1 structured output contract undefined**
Section 3.3 (Architect, Skeptic)

`LLMClient.complete()` returns `str`. Pass 1 must produce a structured result per article (score + summary). No JSON schema is defined, no parsing responsibility is assigned, and no failure behavior is specified for malformed output. LLM structured output is the most common source of implementation divergence.

**Required action:** Define the Pass 1 response schema (e.g., `list[{"url": str, "score": int, "summary": str}]`). Assign parsing to `Summarizer`. Specify retry/fallback for unparseable responses (e.g., retry once with explicit JSON instruction; on second failure, skip the batch and log).

---

**[CONSENSUS — 2/5 reviewers] Pass 2 input structure and context budget unspecified**
Section 3.3 (Architect, Skeptic)

Pass 2 receives "top-ranked articles from Pass 1" — but it's not stated (a) how many (presumably `max_articles_in_digest: 15`), (b) whether it receives full article text or only Pass 1 summaries, or (c) what happens if 15 articles × 800 words exceeds the synthesis model's context window (12,000+ words of input).

**Required action:** Explicitly state: Pass 2 receives Pass 1 summaries only (not full text), capped at `max_articles_in_digest`. Add a context budget note: if estimated input tokens exceed a threshold (e.g., 50k), trim to top 10. This is a load-bearing design decision that cannot be left to implementer judgment.

---

**[CONSENSUS — 2/5 reviewers] Anthropic backend is not OpenAI-compatible**
Section 4.3 (Architect BLOCKING, Skeptic AMBIGUITY)

The spec states the `openai` Python package is used for all backends because they are "OpenAI-compatible." Anthropic is not — it uses the `anthropic` SDK, different auth, and different request/response shapes. Additionally, model name strings are backend-specific (`gpt-4o-mini` vs `claude-haiku-4-5-20251001`), so the "swap backends with one config line" promise in Section 7 is broken unless model names are also updated.

**Required action — pick one:**
- (a) Use `litellm` as the unifying abstraction (genuinely handles all three backends)
- (b) Define per-backend adapter classes, each wrapping the appropriate SDK
- (c) Exclude Anthropic from MVP scope and add it post-MVP

Also: add per-backend model name defaults to config (e.g., `github_models_model`, `openai_model`, `anthropic_model`) and add startup validation that catches backend/model mismatches.

---

**[CONSENSUS — 2/5 reviewers] GitHub Actions workflow has no security or operational specification**
Sections 3.6, 4.1 (OSS, Security)

The `daily-briefing.yml` workflow is listed in the repo structure but never specified: no required secrets enumerated, no workflow permissions defined, no mention of `contents: write` requirement for digest commit, no guidance on preventing secrets from appearing in logs.

**Required action:** Add a "GitHub Actions Setup" subsection to Section 3.6 listing: (a) required secrets and whether each is auto-injected or manually configured, (b) minimum required workflow permissions using principle of least privilege, (c) note that `contents: write` is only needed when `commit_digests: true`.

---

**[CONSENSUS — 2/5 reviewers] Cache check timing is internally inconsistent**
Section 4.4 (Architect NIT, Skeptic AMBIGUITY)

Section 4.4 states "cache is checked before any fetch or LLM call" but content hashing requires content — which requires fetching first. The data flow also shows deduplication after `fetch()`. These statements contradict each other.

**Required action:** Clarify the two-phase intent: URL hash is checked before content fetch; content hash is checked after fetch but before LLM processing.

---

**[CONSENSUS — 2/5 reviewers] `AGENTS.md` listed in repo structure but never described**
Section 4.1 (Architect, MVP Scope)

The file appears in the repo structure with no description of its purpose. For a P0 goal of "demonstrating agentic workflow patterns," this is likely load-bearing.

**Required action:** Add a one-line description in the repo structure table, or remove it from MVP scope.

---

### 🟠 Act Next: Single-Reviewer Blocking

---

**[BLOCKING — Architect] GitHub Actions SQLite cache won't survive between runs**
Section 3.6 / 4.4

GitHub Actions runners are ephemeral. The `cache/radar.db` file is wiped between runs, silently breaking deduplication in CI mode. Every run would re-process all articles from the last 30 days.

**Required action:** Specify a cache persistence strategy for GitHub Actions. Options: commit `radar.db` to repo, use `actions/cache`, or explicitly document that deduplication relies on `published_at` recency filtering (not hash-based cache) when running in CI.

---

**[BLOCKING — OSS] Gmail OAuth setup is entirely absent from the spec**
Sections 3.5, 5, 7

Getting a Gmail refresh token requires creating a Google Cloud project, enabling the Gmail API, configuring OAuth 2.0 credentials, and running an interactive auth flow. None of this appears anywhere. The stated "< 30 minutes setup" NFR does not account for this (GCP project creation alone takes 10–15 minutes for someone new).

**Required action:** Either (a) specify a `python -m radar auth gmail` command that runs the OAuth flow and writes credentials to `.env`, or (b) commit to step-by-step Gmail OAuth documentation in the README before implementation begins. Update the setup time NFR to distinguish Gmail vs. non-Gmail paths (e.g., "< 15 minutes without Gmail, < 45 minutes with Gmail").

---

**[AMBIGUITY — Architect] Pipeline step ordering conflict between Section 3.2 and 4.2**
Sections 3.2, 4.2

Section 3.2 orders steps as: Truncate → Pre-filter. Section 4.2 data flow shows: PreFilter → Truncator. These are different pipelines. Pre-filtering before truncation is more efficient (discard irrelevant articles before paying extraction cost). The `Normalize` step in 3.2 is also absent from the 4.2 diagram.

**Required action:** Designate one section as canonical. Recommend 4.2 ordering (PreFilter before Truncator) as it's more cost-efficient. Add Normalize explicitly to the 4.2 diagram.

---

**[AMBIGUITY — Architect] `RawItem`, `ScoredItem`, and `Digest` schemas are undefined**
Sections 3.1, 4.1

`models.py` is listed as the home of shared data models, but only `NormalizedItem` has a defined schema. Each source implementer will independently invent `RawItem` fields; incompatible implementations will silently break the deduplicator and extractor.

**Required action:** Add a Data Models section specifying required fields and types for `RawItem`, `NormalizedItem`, `ScoredItem`, and `Digest`.

---

**[AMBIGUITY — OSS] Install process is unspecified; both `pyproject.toml` and `requirements.txt` listed**
Sections 4.5, 5

Two implementers would make different choices. Missing: virtual environment setup instructions, authoritative install command.

**Required action:** Pick one authoritative dependency source (recommend `pyproject.toml` with `pip install -e .` or `uv sync`). Specify exact install commands. Remove or demote the other.

---

**[AMBIGUITY — Skeptic] Pre-filter algorithm completely unspecified**
Section 3.2, Step 5

"Keyword/topic filter against user's interest profile" gives no implementation guidance: exact match, substring, case-insensitive? Any keyword from interests list, or all? Match against title only, or body? An overly strict filter silently degrades digest quality before any LLM call.

**Required action:** Specify the matching strategy. Recommended: case-insensitive substring match against title + first 200 words; pass if any single keyword from interests list matches.

---

**[AMBIGUITY — Skeptic] `trafilatura` is not well-suited for newsletter HTML**
Section 3.1

Trafilatura is designed for web article pages. Newsletter emails use multi-column layouts, image-heavy formatting, and embedded article previews — it regularly produces noisy output on these. This is the highest-value source for many users, and a silent extraction failure would degrade digest quality with no visible error.

**Required action:** Specify a fallback: if trafilatura confidence is low or output is below a minimum length, fall back to the email's plain-text MIME part. Add this to the failure mode table.

---

**[AMBIGUITY — Skeptic] LLM backend model name / backend mismatch causes silent failures**
Section 4.3

`LLMClient.complete()` accepts `model: str`. The config has `summarization_model: "gpt-4o-mini"` — this string would be passed verbatim to the Anthropic backend, which would fail with a confusing API error. The "swap backends with one config line" promise is broken.

**Required action:** Add per-backend model name defaults in config OR add startup validation that catches backend/model mismatches and prints a helpful error message.

---

**[AMBIGUITY — Security] Logging policy absent; secrets could appear in exception output**
Sections 6, 3.2, 3.3

No logging policy is defined. The `openai` and `google-api-python-client` libraries can both surface auth headers in debug output.

**Required action:** Add a one-line logging policy to Section 6: structured logger at INFO by default; DEBUG must never be enabled in CI; exception handlers must not log raw exception objects that may contain HTTP request context.

---

**[AMBIGUITY — Security] Digests committed to public repo may expose restricted newsletter content**
Sections 3.6, 6

The "optionally commits digest to `digests/` folder" feature on a public repo means LLM-summarized content from private/paid newsletters could be published. The current disclaimer is buried in Section 6.

**Required action:** Make `digests/` gitignored by default with explicit opt-in to commit (`commit_digests: false` as default). Surface this decision prominently in README and `config.example.yaml` comments.

---

**[AMBIGUITY — Skeptic] Words vs. tokens used inconsistently for truncation**
Section 3.2, Step 4

Step 4 calls `max_words_per_article: 800` a "max token length" — but words and tokens are different units (~750 words ≈ 1000 tokens). Batch cost estimates built on token counts will be ~20–30% off if truncation is actually word-based.

**Required action:** Pick one unit. "800 words" is implementer-friendly. Update the description in 3.2 to say "word count" not "token length."

---

### 🟡 Resolve: Conflicts Requiring Decision

---

**Conflict — OSS Adoptability vs. MVP Scope on LLM backend count:**

> **OSS reviewer** says keep all 3 backends (GitHub Models, OpenAI, Anthropic) for MVP — an OSS adopter without GitHub Models access needs OpenAI as an alternative. [implicit in BLOCKING flag on backend abstraction]
>
> **MVP Scope reviewer** says ship 1 backend (GitHub Models) for v0.1. The `LLMClient` abstraction can stay; just don't implement or test the other two until there's demand. [AMBIGUITY, confidence 8/10]

**Recommendation:** Ship GitHub Models + OpenAI for MVP (OpenAI is a low-marginal-cost addition given OpenAI-compatible wiring). Defer Anthropic to post-MVP, since it requires a separate SDK and breaks the current abstraction. Note the Anthropic deferral prominently in README. This satisfies the OSS fallback need without the architectural complexity of a broken Anthropic adapter.

---

**Conflict — OSS Adoptability + (implicitly) Architect vs. MVP Scope on GitHub Actions trigger mode:**

> **OSS and Architect reviewers** treat GitHub Actions as a first-class MVP trigger mode that should be made to work.
>
> **MVP Scope reviewer** says move GitHub Actions to post-MVP. Manual + cron are sufficient to prove value; GitHub Actions adds infrastructure surface area before the core pipeline is validated, and the Gmail OAuth-in-CI problem makes it risky.

**Recommendation:** Defer GitHub Actions to post-MVP. The Gmail OAuth blocker is real, and the workflow YAML + secrets management adds complexity before the pipeline is proven. Ship manual + cron for v0.1 with a note that GitHub Actions support is planned. This sidesteps the biggest unresolved open question in the spec.

---

**Conflict — MVP Scope (phase source connectors) vs. spec's all-in approach:**

> **MVP Scope reviewer** says phase: v0.1 = RSS + ArXiv (proves pipeline with zero auth friction); v0.2 = Gmail + HN. The `Source` ABC makes this easy to defer. [SUGGESTION, confidence 8/10]
>
> **Implicit spec position** includes all 5 active connectors in MVP, including Gmail (OAuth) and HN (third API surface).

**Recommendation:** [HUMAN DECISION REQUIRED] This is a judgment call about what "MVP" means for your use case. If your primary value is a personal daily briefing from Gmail newsletters, deferring Gmail defeats the purpose. If the goal is to prove the pipeline architecture, RSS + ArXiv is sufficient for v0.1. Decide which persona drives MVP scope.

---

### 🔵 Consider: Suggestions Worth Acting On

- **Sample digest in `examples/`** (OSS): Add `examples/sample-briefing.md` to the repo structure. Low effort, high impact for GitHub visitors evaluating the tool before committing to setup.

- **`python -m radar check` subcommand** (OSS): A credential/source validation command that tests connectivity without running LLM passes would dramatically reduce first-run abandonment. Add to CLI spec.

- **Cache management commands** (OSS, Skeptic): Add `python -m radar cache clear` and `python -m radar cache stats` to CLI definition. Silent dedup cache issues are hard to debug without tooling.

- **`cache_ttl_days: 30` in `config.yaml` example** (Skeptic): Currently specified in Section 4.4 but absent from the config example. Operators can't tune it without reading source.

- **Secret scanning recommendation** (Security): Recommend `git-secrets` or GitHub secret scanning in setup docs. Consider including an optional `.pre-commit-config.yaml`.

- **Data residency disclosure for GitHub Models** (Security): Add a note in Section 6 and README: when using GitHub Models, article content is processed by Microsoft/OpenAI infrastructure. Use Anthropic or a local backend if data residency matters.

- **AGENTS.md** (Architect, MVP Scope): Since this is a P0 goal to demonstrate agentic workflow patterns, define this file's purpose explicitly. It is likely the most interesting documentation in the repo for the target audience.

---

### ⚪ Optional: Nits

- **`podcasts.py` stub**: Remove from MVP repo structure and `config.yaml`. Add a `# post-MVP, not yet implemented` comment if kept in config.
- **`digests/` commit mechanism**: Add `commit_digests: true/false` to the `output:` config block rather than leaving it as a narrative note.
- **Cache stores hashes only**: Confirm explicitly in Section 4.4 that `seen_items` stores only hashes, not plaintext, so implementers don't accidentally add a raw content column.
- **Post-MVP roadmap ordering**: Consider a priority column or reorder by implementation effort + user value (Slack/email delivery is likely higher value than Web UI for a personal tool).

---

### Summary Assessment

The spec has solid bones: the module decomposition, two-pass LLM design, pluggable source/backend architecture, and configuration model are coherent and well-motivated. The primary gap is that **the happy path is well-specified but the spec is silent on every failure mode** — in a pipeline with 5+ sources and 2 LLM passes, partial failures are routine and will produce inconsistent behavior across implementations without a defined error contract. The **Gmail OAuth in GitHub Actions open question must be resolved** (or GitHub Actions must be explicitly deferred) before any implementation begins, as it determines the architecture of both the Gmail connector and the CI workflow. The **Anthropic backend claim** is factually incorrect and will break the abstraction if left as-is. Resolve the failure contract and the Gmail/CI decision first — the spec is otherwise ready for implementation.
