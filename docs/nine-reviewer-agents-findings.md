# The Nine Reviewer Agents: Empirical Findings and Recommendations

*What we learned from running a full 9-persona AI spec review on a real project — which agents added unique value, where the redundancy was, and how to choose the right set for your project.*

---

## Background

This document covers the design and empirical performance of nine AI reviewer personas used to validate a technical specification before AI-assisted implementation. The spec under review was `SPEC.md` for **ai-radar** — a Python pipeline that ingests AI content from multiple sources daily, processes it through two LLM passes, and produces a structured daily digest. The spec described a multi-module architecture with external API dependencies (Gmail, GitHub Models, ArXiv), a SQLite caching layer, and multiple deployment triggers.

Two review runs were conducted against the same PR:
- **Round 1:** Five original personas (Architect, Skeptic, OSS Adoptability, Security, MVP Scope)
- **Round 2:** All nine personas, adding Domain Expert, Legal & Compliance, Operator, and Test Strategy

Total output: 104 structured review comments across 9 reviewers, scored on a standardized evaluation scorecard. All findings cited here are drawn from that scorecard.

---

## The Nine Reviewer Agents

### 🏗️ Architect

**Role:** Senior software architect reviewing for technical coherence — module boundaries, interface contracts, data flow, and whether the system as described is independently implementable without hidden dependencies.

**Primary lens:** Static correctness. Things that are wrong or missing in the spec *as written* — contradictory sections, missing data model definitions, undefined interfaces. Distinguished from Skeptic by focus on structure rather than runtime behavior.

**What it looks for:**
- Module responsibilities that overlap or leave gaps
- Interface contracts missing input/output types, error conventions, or empty-input behavior
- Data flow gaps where schema or format changes without the transformation being specified
- Architectural decisions implied but never made explicit
- Milestone sequencing where M2 secretly depends on something in M3
- Internal contradictions between spec sections describing the same component

**Round 1 performance (5-reviewer run):**
11 comments, 3/11 unique (27%), 7/7 B+A actionable, avg confidence 7.6/10

**Round 2 performance (9-reviewer run):**
11 comments, 2/11 unique (18%), 7/7 B+A actionable

**Standout findings:**
The preprocessing step ordering contradiction between Sections 3.2 and 4.2 — the only reviewer to catch that these describe structurally different pipelines with different cost implications. GitHub Actions ephemeral cache destroying SQLite deduplication was also uniquely identified. The undefined `RawItem`/`ScoredItem`/`Digest` data schemas were flagged with high confidence and correctly identified as a source of future implementer divergence.

**Observed weakness:**
Lowest unique rate of all reviewers (18% in the 9-reviewer run) due to heavy overlap with Skeptic on LLM output schema and Pass 2 context budget questions. The boundary between "static correctness" and "runtime failure modes" needs to be more explicit in the prompt. Also consistently under-escalated: flagged cache timing as a NIT when Skeptic correctly called it an AMBIGUITY.

**Boundary note:** Architect covers *what's wrong in the spec text*. Skeptic covers *what fails when the system runs*. When both flag the same issue, it's usually genuine consensus on a critical gap — weight these highly.

---

### 🔍 Skeptic

**Role:** Constructive skeptic hunting for implicit assumptions, optimistic scenarios, and the things that will cause an implementer to get stuck or make a wrong call at implementation time.

**Primary lens:** Runtime failure modes and observable behavior. Things you'd only discover by actually running the system — not things wrong in the spec text but things the spec assumes will never go wrong.

**What it looks for:**
- Unstated assumptions about library behavior, environment, or external APIs
- Happy-path-only design with no failure handling
- Vague language that defers decisions: "appropriate", "reasonable", "as needed"
- User/operator experience on first run and on failure
- Integration gaps between modules that each pass individual tests but fail combined
- Every external service assumed to be always available and well-behaved

**Round 1 performance:** 15 comments, 7/15 unique (47%), 10/10 B+A actionable, avg confidence 7.4/10

**Round 2 performance:** 15 comments, 4/15 unique (27%), 10/10 B+A actionable

**Standout findings:**
Pre-filter matching algorithm entirely unspecified — the only reviewer to ask "how does this actually work?" rather than "does it scale?" The words-vs-tokens inconsistency in the truncation spec (20-30% token budget error). The Gmail marks-as-read behavior during failure (lost emails). The GitHub Models free tier not being contractually stable for automated use.

**Observed weakness:**
Unique rate dropped from 47% to 27% when the four new personas joined, suggesting the Skeptic's "runtime gaps" lens overlaps more with Domain Expert and Operator than expected in a larger panel. Also prone to bundling two distinct issues into one comment — the Gmail marks-as-read and CI token expiry were filed together but warranted separate confidence scores and section citations.

**Unique value that no other persona provides:** "What does this do when X?" questions. Skeptic is the only persona systematically asking about observable behavior rather than structural correctness or legal exposure.

---

### 📦 OSS Adoptability

**Role:** A developer who just discovered the project on GitHub and wants to run their own instance — technically capable but with no prior context, and no patience for undocumented gaps.

**Primary lens:** First-install and first-run experience. Can a new user fork this repo, follow the setup steps, and have a working pipeline within 30 minutes?

**What it looks for:**
- Setup steps that are implied but not stated (especially OAuth flows requiring external service creation)
- Config values that can't be set correctly without reading source code
- Missing secrets documentation
- False precision on setup time estimates
- Dependencies without install instructions
- GitHub Actions workflows that require undocumented secrets
- First-run error experience — helpful error or confusing stack trace?

**Round 1 performance:** 13 comments, 9/13 unique (69%), 6/6 B+A actionable, avg confidence 7.5/10

**Round 2 performance:** 13 comments, 5/13 unique (38%)

**Standout findings:**
Gmail OAuth setup documentation entirely absent from the spec — the only reviewer to treat "how does a new user actually get a refresh token?" as a BLOCKING gap distinct from the CI token lifecycle question. Install process ambiguity (pyproject.toml AND requirements.txt both listed with no venv instructions). The 30-minute setup time false precision not accounting for GCP project creation. Sample digest suggestion (examples/sample-briefing.md) — the highest-ROI single suggestion in the run for converting GitHub visitors to active users.

**Observed weakness:**
Filed three FALSE PRECISION comments on related config values when one consolidated comment would have served better. The RSS URL verification concern substantially overlapped with Domain Expert's finding. Suggestions for new CLI subcommands (check, cache-clear) crossed into feature request territory and duplicated Operator suggestions.

**Unique value:** The "would someone who isn't the author actually use this?" question. This lens surfaces implicit knowledge the author carries that isn't in the document — the most common reason OSS projects have good code but poor adoption.

---

### 🔒 Security

**Role:** Security-focused engineer reviewing for secrets management, credential hygiene, data handling, and access scope — specifically the accidental exposure failure modes common in personal pipeline tools.

**Primary lens:** Secrets, credentials, and data flowing to unintended destinations. For a personal tool, this is less about attack surface and more about credential leakage, committed secrets, and data sent to third-party APIs without user awareness.

**What it looks for:**
- Secrets in committed files or at risk of appearing in logs
- OAuth scope minimality (gmail.readonly, not broader)
- Token refresh lifecycle and CI recovery paths
- Data sent to external LLM backends without user disclosure
- GitHub Actions secrets management and log masking
- SQLite cache and digest directories at risk of accidental commit
- Third-party data exposure through API debug logging

**Round 1 performance:** 9 comments, 6/9 unique (67%), 5/5 B+A actionable, avg confidence 7.3/10

**Round 2 performance:** 9 comments, 5/9 unique (56%)

**Standout findings:**
Logging policy as credential leakage vector — openai and google API clients can surface auth headers in debug logs. GitHub Models data residency not disclosed in default config (content sent to Microsoft/OpenAI infrastructure). Secret scanning recommendation (git-secrets / pre-commit) for OSS forks. The incomplete .env.example missing OPENAI_API_KEY and ANTHROPIC_API_KEY for non-default backends.

**Observed weakness:**
Filed zero BLOCKING labels despite flagging issues other reviewers correctly escalated to BLOCKING (Gmail OAuth in CI causes system failure; public repo commit of newsletter summaries is a legal risk). The security lens defaults to AMBIGUITY ("this needs a decision") when some findings should be BLOCKING ("this cannot work as written"). Severity calibration needs explicit guidance in the prompt.

**Unique value:** Credential leakage paths and data residency — things the author considers "implementation details" that are actually security decisions that should be in the spec. No other persona has the mandate to ask "where is this credential going to end up?"

---

### ✂️ MVP Scope

**Role:** Pragmatic product engineer protecting the MVP from scope creep — asking what is the minimum implementation that proves the core value, and whether anything labeled MVP is secretly post-MVP complexity.

**Primary lens:** Scope discipline. Not making the project smaller for its own sake, but ensuring v0.1 ships and works rather than becoming perpetually unfinished.

**What it looks for:**
- Features described as MVP that would meaningfully delay a working v0.1
- Abstractions adding complexity without being needed for first version
- Items in the spec that could be hardcoded, stubbed, or deferred without losing core value
- The inverse: underscoped areas where the MVP won't actually work end-to-end
- Post-MVP roadmap items that are actually post-MVP rather than "we'll get to it"

**Round 1 performance:** 9 comments, 4/9 unique (44%), 4/4 B+A actionable, avg confidence 7.4/10

**Round 2 performance:** 9 comments, **1 net-new B+A** (weakest addition in the 9-reviewer run)

**Standout findings:**
The three-LLM-backend framing (ship 1 backend for v0.1, not 3 — different SDK, auth, and error handling for each). The connector phasing proposal (v0.1 = RSS + ArXiv with zero auth friction; v0.2 = Gmail + HN) — concrete and immediately actionable. The GitHub Actions deferral recommendation — uniquely framed the case that deferring Actions sidesteps four BLOCKING issues simultaneously.

**Observed weakness:**
In a 9-reviewer context, MVP Scope contributed only 1 net-new B+A finding. Its primary value is scope SUGGESTIONs — the phasing and deferral recommendations — not identifying new technical gaps. Filed AMBIGUITY labels for issues that were already well-covered by other reviewers, adding noise rather than signal. Also consistently declined to escalate to BLOCKING when appropriate.

**Verdict:** Optional in a 9-reviewer run where scope is reasonably well-defined. Essential in a 5-reviewer run or when the author has a known tendency to over-engineer. The phasing and deferral recommendations are high-quality when they appear, but they only appear 2-3 times per run.

---

### 🔬 Domain Expert

**Role:** Senior engineer who has built systems in this exact technical domain — email processing pipelines, web scraping, LLM API integration, RSS ingestion, Python pipeline architecture. Reviews for domain-specific gotchas that look reasonable on paper but fail in practice.

**Primary lens:** "I've built this before and here's what you don't know you don't know." Library behavioral assumptions, API quirks, data quality realities, and performance characteristics that only surface with hands-on experience.

**What it looks for:**
- Library misuse for the wrong content type or use case
- API behavioral quirks not reflected in the spec (rate limits, identifier instability, auth edge cases)
- Real-world data messiness that the spec assumes away
- Performance characteristics that make NFR targets unrealistic
- Domain-specific anti-patterns the author may have learned from documentation but not experience

**Round 2 performance (first run):** 12 comments, 8/12 unique (67%), 6/6 B+A actionable, avg confidence 7.8/10 (highest of all reviewers)

**Standout findings:**
The two-format newsletter problem — full-content newsletters (Substack) and link-list newsletters (TLDR, The Batch) require completely different processing strategies; the spec treats all Gmail content identically. Tracking redirect URL bypass of URL-hash deduplication (newsletter.service.com/click?url=... is unique per-send, breaking dedup entirely). GitHub Models model IDs are unstable and ≠ OpenAI model IDs — the default configuration would fail on first run. HN score time-sensitivity (running at 7AM with min_score:100 means most good posts are still accumulating votes). The GCP 7-day testing-mode OAuth token expiry — no other reviewer identified this specific operational detail.

**Observed weakness:**
Relatively weaker on the LLM output schema issues (batching brittleness overlaps rows already covered by Architect and Skeptic). The Anthropic SDK suggestion was fully subsumed by Architect's finding. Minor overlap with OSS on RSS URL validation.

**Critical note for implementation:** This persona requires customization per project. The "Your Domain Context" section of the prompt should be rewritten to match the actual technical domain of the spec under review. The ai-radar version covers email/LLM/RSS pipeline specifics — a different project would need different domain knowledge. This is the most powerful persona in the set for domain-specific tools but the most effort to configure correctly.

---

### ⚖️ Legal & Compliance

**Role:** Compliance-aware engineer who has shipped products handling third-party content, user data, and automated publishing — someone who has learned where the legal and ethical landmines are the hard way.

**Primary lens:** Legal and ethical risk. Not providing legal advice, but identifying areas where the described behavior could create legal exposure, violate terms of service, or require disclosure — particularly things that wouldn't be visible to anyone without compliance experience.

**What it looks for:**
- Third-party content rights (ToS, copyright, subscription agreements)
- Public repository commits of content that may constitute republication
- Automated access to services that prohibit scraping
- Data privacy and GDPR implications of sending content to external LLMs
- robots.txt compliance for web scraping
- AI-generated content disclosure requirements
- Responsible use documentation for open-source tools

**Round 2 performance:** 10 comments, 7/10 unique (70%), 5/5 B+A actionable, avg confidence 7.7/10

**Standout findings:**
Newsletter content rights — paid newsletter subscriptions often prohibit automated extraction and summarization even for personal use; the spec had no ToS discussion despite newsletter processing being the primary use case. LLM data privacy and GDPR implications (email content sent to external APIs, potential training data use). robots.txt compliance for web scraping (potential CFAA exposure — no other reviewer raised this). Paywalled content accessed via Gmail body not addressed by the existing "skip paywalled web URLs" note. AI-generated content disclosure requirement for digests.

**Observed weakness:**
The public repo commit risk (row 71) substantially overlapped Security's finding (row 38) — that concern was already covered. The FALSE PRECISION comment added little given all 9 reviewers had already flagged config numbers; the legal angle (volume = fair use implication) was too weak to justify inclusion.

**Critical note for open-source projects:** The newsletter content rights BLOCKING finding (row 70) is the single finding in the entire 104-comment run with existential implications for the project. A tool that becomes popular could face DMCA takedowns or subscriber agreement violations that weren't considered during development. This persona is non-optional for any tool that processes third-party content — newsletter ingestion, web scraping, social media aggregation, or document summarization.

---

### 🔧 Operator

**Role:** Platform or SRE engineer responsible for keeping the system running after it ships. Doesn't care how elegant the code is — cares about what happens at 7am when the pipeline fails silently, and whether there's enough visibility to diagnose and fix it in under 10 minutes.

**Primary lens:** Day-two operability. What happens after the system is built and running? This is deliberately distinct from OSS Adoptability (first-install) and Skeptic (runtime correctness) — Operator is about the ongoing operational experience: logging, failure notification, recovery procedures, and cache maintenance.

**What it looks for:**
- Failure notification strategy — how does the operator find out the pipeline failed?
- Logging strategy — levels, format, destination, enough to reconstruct a failed run
- Mid-run failure state — if Pass 1 succeeds but Pass 2 fails, what state is the system in?
- Recovery procedures — can the pipeline be safely re-run without duplicating work?
- LLM API error handling — retry strategy, backoff, timeout per call
- Cache maintenance — vacuum, size limits, corruption recovery
- Cost tracking — token counts and estimated cost per run

**Round 2 performance:** 13 comments, 8/13 unique (62%), 7/7 B+A actionable, avg confidence 7.6/10

**Standout findings:**
No failure notification strategy — the synthesis called this "the single most important operational gap." The operator only discovers a silent pipeline failure by noticing the absence of a digest hours later. No logging strategy (no log levels, format, or destination specified — diagnosing failures requires re-running or reading source). Mid-run cache state corruption risk (if Pass 1 marks items as seen but Pass 2 fails, are those items permanently skipped?). LLM API retry/backoff policy entirely unspecified. SQLite cache vacuum and corruption recovery. Cost tracking and max_cost_per_run threshold.

**Observed weakness:**
Two AMBIGUITY comments (rows 83, 84) substantially overlap Skeptic's fetch() contract and the many Gmail OAuth flags. The dry-run and cache-inspect suggestions overlap OSS Adoptability — these should have been flagged as "already raised by another reviewer" per the base instructions update.

**Unique value:** The Operator persona covers a temporal dimension none of the other reviewers address — not "will this work on day 1?" but "will this still work on day 30, and when it doesn't, will you know?" Failure notification and logging are genuinely invisible to architects and skeptics who are thinking about code correctness rather than operational experience.

---

### 🧪 Test Strategy

**Role:** Senior QA engineer or test-focused developer reviewing whether the spec produces a system that can be reliably verified to work correctly — and whether there's a coherent strategy for doing so.

**Primary lens:** Testability and verification coverage. This is especially critical for specs that will be implemented by AI agents, which produce code that compiles and runs but may not behave correctly at integration level. Agents write tests that pass without validating the behavior the spec actually requires.

**What it looks for:**
- Whether acceptance criteria are concrete and testable
- Mocking strategy for external APIs (Gmail, LLM backends, ArXiv)
- LLM output testing approach — non-deterministic outputs require schema validation, not content assertion
- Pipeline integration test coverage — not just unit tests per module
- CI workflow configuration
- Content fingerprinting algorithm (affects dedup test design)
- Cache TTL testability
- Distinction between hard constraints and tunable defaults (tests can't assert on TBD numbers)

**Round 2 performance:** 12 comments, **11/12 unique (92% — highest unique rate of all reviewers)**, 6/6 B+A actionable, avg confidence 7.7/10

**Standout findings:**
No test strategy defined anywhere in the spec — three test files are listed in the repo structure but no strategy, levels, fixtures, CI, or mocking approach is specified. No LLM output testing approach — non-deterministic outputs will produce tests that pass while the pipeline silently produces wrong results. No mocking/fixture strategy — tests will require real API keys, making CI impossible without actual credentials. Cache TTL testability — the TTL mechanics aren't specified precisely enough to write TTL tests. Content fingerprinting algorithm completely unspecified — SHA-256 of full text? First N chars? Simhash? The choice fundamentally affects dedup test design. TestLLMClient mock backend as a first-class component of the implementation. CI test workflow (.github/workflows/tests.yml) entirely absent from the spec.

**Observed weakness:**
The AMBIGUITY on LLM malformed output (row 96) overlapped rows 4 and 44 — the underlying gap was already well-identified, and adding a "from a testing lens" framing added modest incremental value. The one finding in 12 that wasn't essentially unique.

**Critical recommendation:** Run Test Strategy first, not last. Its three BLOCKING findings shape how every other reviewer should reason about LLM output contracts and acceptance criteria. Running it last (as happened in both rounds) means other reviewers discussed implementation without the constraint that the implementation must be testable. The test strategy is a design constraint, not an afterthought.

---

## Quantitative Results: Both Runs

### Run 1: Five Personas

| Metric | Result | Target | Pass? |
|---|---|---|---|
| Total comments | 57 | — | — |
| Signal density (B+A / total) | 56.1% | > 50% | ✅ |
| Persona uniqueness (avg) | 50.8% | > 40% | ✅ |
| Format compliance | 2/5 | 5/5 | ❌ |
| Conflict rate | 5.3% | 10–30% | ❌ |
| Confidence calibration | All 8/10+ actionable | Higher = better | ✅ |

### Run 2: Nine Personas

| Metric | Result | Target | Pass? |
|---|---|---|---|
| Total comments | 104 | — | — |
| Signal density (B+A / total) | 53.8% | > 50% | ✅ |
| Persona uniqueness (avg) | 52.6% | > 40% | ✅ |
| Format compliance | 9/9 | 9/9 | ✅ |
| Conflict rate | 3.8% | 10–30% | ❌ |
| Confidence calibration | All 9/10 B+A were high-signal | Higher = better | ✅ |

### Unique B+A Findings by Reviewer

| Reviewer | B+A Comments | Net-new B+A (unique) | Cumulative |
|---|---|---|---|
| 🏗️ Architect | 7 | 7 | 7 |
| 📦 OSS Adoptability | 6 | 2 | 9 |
| ✂️ MVP Scope | 4 | 1 | 10 |
| 🔒 Security | 5 | 2 | 12 |
| 🔍 Skeptic | 10 | 2 | 14 |
| 🔬 Domain Expert | 6 | 4 | 18 |
| ⚖️ Legal & Compliance | 5 | 4 | 22 |
| 🔧 Operator | 7 | 5 | 27 |
| 🧪 Test Strategy | 6 | 5 | 32 |
| **Total** | **56** | **32** | **32** |

### The Diminishing Returns Curve

The curve tells the most important story in the data:

```
After reviewer 1 (Architect):        7 unique B+A  ████████████████████████████
After reviewer 2 (OSS):              9             ████████████████████████████████████
After reviewer 3 (MVP Scope):       10             ████████████████████████████████████████
After reviewer 4 (Security):        12             ████████████████████████████████████████████████
After reviewer 5 (Skeptic):         14             ████████████████████████████████████████████████████████
                                    ↑ curve flattens — traditional "stop here"
After reviewer 6 (Domain Expert):   18             ████████████████████████████████████████████████████████████████████████
After reviewer 7 (Legal):           22             ████████████████████████████████████████████████████████████████████████████████████
After reviewer 8 (Operator):        27             ██████████████████████████████████████████████████████████████████████████████████████████████████████████
After reviewer 9 (Test Strategy):   32             ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
                                    ↑ curve renewed — each new reviewer added 4-5 net-new
```

The conventional wisdom — "diminishing returns after 3-4 reviewers" — is only true if you keep adding more of the same *type* of reviewer. When you add genuinely orthogonal lenses, the curve renews. **Reviewer selection matters more than reviewer count.**

---

## Key Findings and Learnings

### Finding 1: The four new personas were more valuable than the original five — combined

The four new personas (Domain Expert, Legal, Operator, Test Strategy) contributed 18 of 32 unique B+A findings. Each found at least 4 B+A issues no prior reviewer had raised. The most important gaps in the spec — newsletter ToS compliance, no test strategy, no failure notification, the two-format newsletter problem — were entirely invisible to the original five personas.

**Implication:** The original five personas cover "will this be built correctly?" The four new personas cover "will this work legally, operationally, and verifiably?" Both questions matter, and only one was being asked before the second run.

### Finding 2: Test Strategy should run first

Test Strategy had the highest unique rate (92%) and its three BLOCKING findings are design constraints, not implementation details. Knowing that the spec needs a mock LLM backend, an integration test, and a CI workflow affects how *every other reviewer* should reason about interface contracts and acceptance criteria. Running it last (as happened here) means the other reviewers missed an architectural constraint that was hiding in plain sight.

**Implication:** For specs involving LLM components or external APIs, Test Strategy belongs in position 1 or 2. Its output sets the context for everything that follows.

### Finding 3: Domain Expert's value is proportional to how domain-specific the tool is

Domain Expert had the highest average confidence (7.8/10) and found issues that required genuine practitioner knowledge: the two-format newsletter problem, tracking redirect URL bypass, GitHub Models model ID instability, HN score time-sensitivity, GCP 7-day testing-mode expiry. None of these would have surfaced from a generalist reviewer no matter how thorough.

**Implication:** For greenfield tools in well-understood domains (standard CRUD apps, familiar architectures), Domain Expert may add modest value. For tools in novel domains — LLM pipelines, content ingestion, unusual data sources — Domain Expert is arguably the highest-ROI reviewer in the set. The persona requires customization per project; the investment is worth it.

### Finding 4: Legal & Compliance is non-optional for content-processing tools

The newsletter content rights finding (Legal, row 70) is the only finding in 104 comments with existential implications for the project. A tool that processes paid newsletter content at scale could face DMCA claims, subscriber agreement violations, or platform bans — and this risk was completely invisible to all other reviewers. The spec's Section 6 had a single line ("user responsible for not committing proprietary content") that would have provided no real protection.

**Implication:** Any tool that processes third-party content — newsletter ingestion, web scraping, document summarization, social media aggregation — requires Legal review before open-sourcing. The legal risk is asymmetric: the cost of missing it is much higher than the cost of addressing it at spec time.

### Finding 5: MVP Scope is a situational reviewer, not a core one

MVP Scope contributed only 1 net-new B+A finding in the 9-reviewer run. Its primary value is scope SUGGESTIONs — the connector phasing proposal and GitHub Actions deferral recommendation were high-quality and actionable. But in a 9-reviewer run where scope is reasonably well-defined, it doesn't earn a core slot.

**Implication:** Include MVP Scope when: the author has a known tendency to over-engineer, the MVP definition is genuinely uncertain, or when you're doing a 5-reviewer fast-track and need to surface scope tradeoffs. Skip it when scope is well-defined and you have constrained session time — a Performance Engineer or a second Domain Expert pass would add more unique value.

### Finding 6: The Open Questions echo problem is systematic and fixable

7/9 reviewers flagged Gmail OAuth in GitHub Actions despite it being an explicit Open Question in the spec. This generated 7 near-duplicate paragraphs across review comments and added noise to the synthesis. The fix is a single sentence in the base instructions: "Before posting any finding, check whether it appears in the spec's own Open Questions. Only include it if you have a concrete resolution the spec lacks."

**Implication:** This is the single highest-ROI prompt improvement available. Applied before the next run, it would reduce total comment count by ~7 and improve synthesis readability significantly. It also sets a better norm: reviewers should add resolution, not just confirm the author's known unknowns.

### Finding 7: FALSE PRECISION fires too broadly when all 9 reviewers can see the same config numbers

All 9 reviewers flagged the same set of config placeholder numbers (max_articles: 30, batch_size: 10, etc.), each from a slightly different angle. This generated 7 near-identical FALSE PRECISION comments. The label is most valuable for non-obvious precision (NFR targets, setup time estimates, performance claims) — not for visible placeholder numbers in config examples.

**Implication:** Add to base instructions: "FALSE PRECISION is most valuable for non-obvious precision — NFR targets, setup time estimates, timeout values, or performance claims stated as facts. If you're flagging a config number that's clearly a placeholder example, consolidate all instances into a single comment rather than filing them separately."

### Finding 8: Format compliance improved dramatically with explicit instructions

Round 1: 2/5 reviewers used proper bold `**[LABEL]**` markdown. Round 2: 9/9 did. The only change was making the format requirement explicit ("this is required for GitHub rendering — plain text is a format compliance failure") with correct/incorrect examples. 

**Implication:** Agents follow explicit format requirements reliably when the requirement is stated unambiguously. "Follow this exact structure" is insufficient — the structure needs examples of correct and incorrect usage.

### Finding 9: The conflict rate being low is a feature, not a bug

Conflict rate was 3.8% (4 conflicts / 104 comments) — below the 10-30% healthy range. This is appropriate for a 9-reviewer run where the new personas (Legal, Operator, Test Strategy) covered territory no one else was covering. Conflicts arise when reviewers cover the same territory with different recommendations. When reviewers are genuinely orthogonal, consensus is the expected outcome. The four conflicts that did surface were all genuine tradeoffs (LLM backend count, GitHub Actions scope, connector phasing, newsletter content rights) — high-quality and worth the synthesis effort.

**Implication:** Conflict rate target ranges need to be adjusted by reviewer composition. A set of 5 overlapping personas should produce 10-30% conflict rate. A set of 9 orthogonal personas should produce 3-8%. Low conflict rate with high unique findings per reviewer indicates a well-differentiated set — not a poorly scoped one.

---

## Recommended Persona Sets by Project Type

Based on empirical findings across both runs:

### Fast-track (4 reviewers, ~45-60 min)
**Best overall ROI per hour for most technical specs.**

Architect + Domain Expert + Operator + Test Strategy

Captures ~66% of unique B+A findings (21/32 in the ai-radar run). Covers the four dimensions most likely to be missed: technical correctness, domain anti-patterns, operational reality, and testing infrastructure. Add Legal if the project processes any third-party content.

### Standard (6 reviewers, ~90 min)
**Recommended for most specs with external dependencies.**

Architect + Skeptic + Security + Domain Expert + Operator + Test Strategy

Adds runtime failure mode coverage (Skeptic) and credential/secrets handling (Security). Would have captured ~81% of unique B+A (26/32). Recommended whenever the spec introduces new external APIs, auth flows, or data handling.

### Full (9 reviewers, ~3 hrs)
**For complex, novel, OSS-targeted, or LLM-based specs.**

All nine. The data shows clear ROI at this scale — the marginal value per reviewer actually increased in the second batch. The curve renews when you add orthogonal lenses.

### Scope-based guidance

| Project size / type | Recommended set | Key addition vs. smaller set |
|---|---|---|
| Small bug fix or enhancement (<1 week) | Skeptic + Domain Expert | Runtime gaps + domain-specific assumptions |
| Medium feature (1-2 weeks) | Architect + Skeptic + Domain Expert | Architecture + failure modes + domain gaps |
| New system, familiar domain (2-4 weeks) | Standard 6 | + Security and Operator |
| New system, novel domain or LLM (2-4 weeks) | Full 9 | + Legal + Test Strategy |
| OSS project of any size | Always add Legal | Content rights and responsible-use docs |
| Legacy modernization | Architect + Domain Expert + Test Strategy | Architecture debt + domain knowledge + test coverage |
| AI/LLM pipeline specifically | Always add Test Strategy | Mock strategy shapes every other implementation decision |

---

## Protocol Improvements for Future Runs

These changes are directly supported by scorecard evidence:

**1. Add Open Questions check to base instructions (highest priority)**
Add: "Before posting any finding, check whether it appears in the spec's own Open Questions section. If it does, only include it if you have a concrete resolution the spec lacks. Echoing a known open question without adding resolution is noise, not value."

**2. Run Test Strategy first for LLM/API-dependent specs**
Test strategy constraints are design constraints. Running Test Strategy in position 1 or 2 ensures the other reviewers know what testability requirements they need to respect.

**3. Tighten FALSE PRECISION guidance**
Add: "Reserve FALSE PRECISION for non-obvious precision — NFR targets, setup time claims, performance guarantees. For config placeholder numbers that are clearly examples, consolidate all instances into one comment."

**4. Sharpen Architect/Skeptic boundary**
Architect = things wrong in the spec text (contradictions, missing definitions, structural gaps). Skeptic = things that fail at runtime (behavior when things go wrong, optimistic assumptions). Both should explicitly note this boundary in their prompts.

**5. Add BLOCKING escalation criteria to Security and MVP Scope**
Both personas default to AMBIGUITY when some findings should be BLOCKING. Add explicit examples: headless CI auth requirements = BLOCKING. Public commit of proprietary content = BLOCKING. System-failure-causing failure = BLOCKING.

**6. Require counter-proposals from MVP Scope**
A scope critique without a concrete alternative has limited value. Every scope-risk AMBIGUITY should include an explicit "reduced MVP" counterproposal.

**7. Consider replacing MVP Scope with Performance Engineer for pipeline-heavy specs**
The Domain Expert's NFR combination analysis (30 web fetches + 4 LLM calls easily exceeds 5-minute target) hints at a gap in how current personas reason about system performance under load. A Performance Engineer persona would cover this more systematically.

---

## The Meta-Insight

The most important finding from two full runs of this protocol isn't about any specific reviewer. It's about the relationship between reviewer diversity and review quality.

**The original five reviewers covered the obvious.** They found the structural contradictions, the missing data models, the OAuth documentation gaps, the config placeholder values. These are the issues a careful human engineering review would also find — things that are visibly missing when you look for them.

**The four new reviewers found what you didn't know you didn't know.** Newsletter ToS compliance. No test strategy for non-deterministic outputs. Silent pipeline failures with no notification mechanism. Tracking redirect URL bypass of deduplication. These are the issues that would have been discovered weeks into implementation — at the worst possible time.

The difference between "good spec" and "implementation-ready spec" is largely in that second category. A spec can be architecturally coherent, internally consistent, and well-documented and still produce an implementation that violates its publisher's terms of service, fails silently every morning, and ships with a test suite that passes while the pipeline produces wrong outputs.

The reviewers that prevented that outcome weren't the ones reviewing the spec's internal structure. They were the ones asking: "Will this be legal?" "Will I know when it breaks?" "Can I actually verify it works?"

---

*This document covers findings from ai-radar PR #1 — a spec for a personal AI newsletter digest pipeline reviewed across two rounds using 9 AI reviewer personas. Framework version: 0.2. Both scorecards available in the evaluation/ directory.*
