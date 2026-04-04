# Multi-Agent Spec Review: A Framework for Catching Ambiguity Before It Becomes a Bug

*A practical framework for using multiple AI reviewer personas to validate technical specifications before implementation — with findings from a real project.*

---

## The Problem

AI-assisted development has a well-known failure mode: agents implement what they're told, not what you meant. When a spec is ambiguous, an agent makes a plausible assumption and proceeds — often silently, often wrongly. By the time the mismatch surfaces, you've got code to unwind, not just words to fix.

The standard response is "write better specs." That's correct but incomplete. The harder problem is that spec authors have blind spots. You can't see your own implicit assumptions. You can't read your own work through the eyes of someone unfamiliar with the domain, responsible for deploying it at 7am, or worried about what happens when it gets open-sourced.

This is the problem multi-agent spec review addresses.

---

## The Framework

### Core Idea

Instead of a single AI agent reading a PR and producing generic feedback, you run multiple specialized reviewer personas — each with a distinct lens, looking for a different class of problem — and then synthesize their independent findings into a prioritized action list.

The key design principles:

**Independent sessions, not collaborative.** Each reviewer runs in its own Claude Code session and reads only the PR diff — not other reviewers' comments. This isolation ensures each lens produces uncontaminated signal. Reviewers that see each other's comments anchor to prior findings, reducing the independence that makes multi-agent review valuable.

**Issues, not prescriptions.** Reviewers identify problems, not solutions. This keeps them in their lane, prevents them from arguing with each other, and ensures all resolution decisions flow through a human. The only conflicts that surface are genuine tradeoffs — not agent disagreements about implementation details.

**Structured output.** Every comment follows the same format: label, confidence score, section reference, issue, consequence, and suggested direction. This makes the output machine-readable by the synthesis agent and human-scannable on GitHub.

**A synthesis pass.** After all reviewers post, a synthesis agent reads everything and produces one prioritized action list. Without this step, multi-agent review produces five reading tasks instead of one.

**Measure it.** A scorecard tracks signal density, persona uniqueness, conflict rate, and actionability. Without measurement, you can't improve the protocol or make evidence-based recommendations to others.

---

### The Label Taxonomy

Every reviewer comment is labeled with exactly one of:

| Label | Meaning | Author should... |
|---|---|---|
| `[BLOCKING]` | Something is wrong or missing | Fix before merge |
| `[AMBIGUITY]` | Something is undefined or underspecified | Make a decision, document it |
| `[FALSE PRECISION]` | Looks decided but actually isn't | Confirm or mark TBD |
| `[SUGGESTION]` | Worth improving, not required | Consider and decide |
| `[NIT]` | Minor polish only | Fix if easy |

`[AMBIGUITY]` and `[FALSE PRECISION]` are treated as merge-blocking. The insight behind this: ambiguity at spec time is a guaranteed bug at implementation time. An agent implementing an underspecified interface will make a plausible assumption and proceed. That assumption may be wrong, and you won't find out until the code is written.

---

### The Ambiguity Scan

Regardless of their primary lens, all reviewers run a dedicated ambiguity scan using four sub-lenses:

- **Undefined behavior** — what happens in edge cases the spec doesn't address?
- **Implicit assumptions** — what must be true for this to work that isn't stated?
- **Underspecified interfaces** — where would two implementers make different reasonable choices?
- **Missing failure modes** — what can go wrong with no specified handling?

This scan is the highest-leverage part of the protocol. It directly addresses the "agents have zero tolerance for ambiguity" problem. Every `[AMBIGUITY]` finding is a place where, without intervention, an agent would silently make a wrong assumption.

---

### The Reviewer Personas

The framework currently defines nine reviewer personas, each with a distinct lens:

**Original five — general spec review:**

| Persona | Lens | Best at catching |
|---|---|---|
| 🏗️ Architect | Module boundaries, interfaces, data flow | Contradictory spec sections, missing data models, hidden coupling |
| 🔍 Skeptic | Assumptions, gaps, runtime failure modes | Optimistic scenarios, implicit library assumptions, undefined "done" criteria |
| 📦 OSS Adoptability | Setup realism, config clarity, docs | Missing setup steps, undocumented secrets, false precision on setup time |
| 🔒 Security | Secrets, OAuth scope, data handling | Credential leakage paths, minimal OAuth scope violations, third-party data exposure |
| ✂️ MVP Scope | Scope creep, over-engineering | Hidden post-MVP complexity, abstractions that block shipping |

**Extended four — domain-specific depth:**

| Persona | Lens | Best at catching |
|---|---|---|
| 🔬 Domain Expert | Library behavior, API quirks, data quality | Library misuse, API behavioral assumptions, real-world data messiness |
| ⚖️ Legal & Compliance | Content rights, ToS, data retention | Third-party content republication, automated access policy violations |
| 🔧 Operator | Day-two operability, failure visibility | Silent failures, missing recovery procedures, unobservable pipeline state |
| 🧪 Test Strategy | Testability, verification coverage | Untestable acceptance criteria, missing mock strategies, LLM output verification gaps |

Each persona is a markdown file. Every session is built by combining `base-instructions.md` (shared protocol) with a persona file. This composability means the base instructions — including the ambiguity scan and format requirements — are updated once and propagate to all personas automatically.

---

### The Maturity Model

The framework is designed to grow with team adoption:

**Level 1 — Manual copy-paste.** Engineers open `base-instructions.md` and a persona file, combine them manually, paste into a Claude Code session. Works immediately. No tooling required.

**Level 2 — Slash commands.** `.claude/commands/review-pr.md` defines a `/review-pr <PR_NUMBER> <PERSONA>` command that automates prompt construction. Reduces friction to a single command per reviewer.

**Level 3 — GitHub Actions.** A workflow triggers on a PR label, invokes the LLM API directly (headless, not Claude Code), and posts reviewer comments automatically. Engineers add a label and come back to structured feedback.

Start at Level 1. Validate the prompts produce useful output. Then automate.

---

### Conflict Detection

Conflicts between reviewers are rare and meaningful. They arise almost exclusively at the recommendation level — where two reviewers' implied resolutions for the same spec gap point in opposite directions. This is by design: reviewers identify issues, not prescribe solutions, so they rarely conflict on the substance of a finding. When a conflict does appear in the synthesis output, it is almost always a genuine product tradeoff requiring a human decision.

The synthesis agent surfaces conflicts explicitly, frames each position, and either makes a recommendation or flags it as `[HUMAN DECISION]`. The human resolves these before the spec agent makes changes.

---

## Case Study: ai-radar Spec Review

### Project Context

[ai-radar](https://github.com/your-org/ai-radar) is a Python pipeline that ingests AI content from multiple sources daily — Gmail newsletters, ArXiv, RSS feeds, Hacker News — filters for relevance using LLMs, and produces a structured daily digest. The spec describes a multi-stage pipeline with pluggable source connectors, a two-pass LLM processing layer, SQLite-based caching, and multiple deployment triggers.

The spec review ran against PR #1, which added `SPEC.md` — the full technical specification before any implementation had begun.

---

### Round 1: Five-Persona Review

**Setup:** Five reviewer personas ran in independent Claude Code sessions against the spec diff. Each session used Sonnet (cost-conscious choice for a personal project; Opus recommended for Architect and Skeptic when budget allows). All five posted a single structured comment to the PR, then the synthesis agent produced a prioritized action list.

**Results summary:**

| Metric | Result | Target | Pass? |
|---|---|---|---|
| Total comments | 57 | — | — |
| Signal density (BLOCKING + AMBIGUITY) | 56.1% | > 50% | ✅ |
| Persona uniqueness (avg unique/total) | 50.8% | > 40% | ✅ |
| Format compliance | 2/5 | 5/5 | ❌ |
| Conflict rate | 5.3% | 10–30% | ❌ |
| Confidence calibration | All 8/10+ actionable | Higher = better | ✅ |

**Persona performance:**

| Persona | Total | Unique | Standout find |
|---|---|---|---|
| Skeptic | 15 | 7 (47%) | Pre-filter algorithm completely unspecified; trafilatura unsuitable for newsletter HTML |
| OSS Adoptability | 13 | 9 (69%) | Gmail OAuth setup docs entirely missing; RSS URLs unverified |
| Architect | 11 | 3 (27%) | Preprocessing step ordering contradiction between sections 3.2 and 4.2 |
| Security | 9 | 6 (67%) | Digests committed to public repo = newsletter content republication risk |
| MVP Scope | 9 | 4 (44%) | Three LLM backends as MVP scope; connector phasing to RSS+ArXiv first |

**Most valuable finds — things that would have caused implementation bugs:**

1. **Sections 3.2 and 4.2 describe contradictory pipeline step orderings** — Truncate→PreFilter in one section, PreFilter→Truncator in another. Two agents implementing from the same spec would build different pipelines.
2. **`RawItem`, `ScoredItem`, `Digest` data models undefined** — only `NormalizedItem` specified. Source connectors would diverge immediately.
3. **Anthropic SDK is not OpenAI-compatible** — the LLM backend abstraction as written is broken for the Anthropic case.
4. **Gmail OAuth setup entirely absent from docs** — a new user cannot configure the primary data source.
5. **trafilatura is designed for article pages, not newsletter HTML** — extraction quality degrades silently for the primary content type.
6. **Pre-filter matching algorithm unspecified** — exact match? substring? case-sensitive? Any keyword or all? Only the config key is named, not the behavior.

**Three conflicts detected:**

- OSS vs. Scope on LLM backend count: keep 3 for OSS accessibility vs. ship 1 for MVP discipline. Resolution: keep GitHub Models + OpenAI (low incremental cost), defer Anthropic (separate SDK breaks the abstraction).
- OSS/Architect vs. Scope on GitHub Actions: treat as first-class MVP trigger vs. defer until pipeline is proven locally. Resolution: defer — Gmail OAuth in CI is a real blocker before core pipeline is validated.
- Implied spec vs. Scope on source connector phasing: all 5 connectors in MVP vs. v0.1 = RSS+ArXiv, v0.2 = Gmail+HN. Resolution: `[HUMAN DECISION]` — depends on whether MVP goal is "prove architecture" or "deliver personal briefing from Gmail."

**What didn't work:**

- All 5 reviewers flagged Gmail OAuth in GitHub Actions despite it being an explicit Open Question in the spec. The protocol had no mechanism to prevent echoing known open questions back without adding resolution.
- 3/5 reviewers used plain `[LABEL]` instead of bold `**[LABEL]**` — format instruction wasn't strong enough.
- Architect review was accidentally posted twice.

---

### Full Nine-Persona Review

*[This section will be updated after the nine-persona session completes.]*

**Extended personas:** Domain Expert (pre-configured for email/LLM pipeline domain), Legal & Compliance, Operator, Test Strategy — run in the same single cohort as the original five.

**Expected findings from new lenses:**
- Domain Expert: library behavioral assumptions, API quirk identification, real data quality gaps
- Legal & Compliance: newsletter content rights at scale, GitHub Models data residency, automated access ToS
- Operator: failure visibility, recovery procedures, first-run experience
- Test Strategy: LLM output verification strategy, mock/fixture approach for external APIs, pipeline integration test coverage

**Diminishing returns data:** *[To be filled in — at what reviewer did the curve of net-new BLOCKING/AMBIGUITY findings flatten?]*

**Updated PES across all 9 reviewers:** *[To be filled in]*

**Revised recommendation on minimum viable persona set:** *[To be filled in based on data]*

---

### Protocol Improvements Identified from the Five-Persona Run

**Changes to `base-instructions.md`:**

1. Add open questions check: "Before posting any finding, check whether the spec has an explicit Open Questions section. If your finding is already listed there, only post it if you have a concrete resolution the spec lacks."
2. Strengthen format enforcement: make bold markdown explicitly mandatory with correct/incorrect examples.
3. Add split vs. consolidate rule: split when issues have different labels or confidence scores; consolidate when multiple instances of the same pattern appear.
4. Update FALSE PRECISION guidance: most valuable for non-obvious precision (NFR targets, estimates, timeout values), not config placeholder numbers.
5. Add duplicate-post check: verify your review hasn't already been posted before posting.

**Changes to persona files:**

- Architect + Skeptic: add explicit boundary statements to reduce overlap. Architect = static correctness (contradictory spec sections, missing definitions). Skeptic = runtime failure modes (what fails when the system runs).
- Security: add BLOCKING escalation criteria — headless auth requirements, unrevocable public exposure.
- MVP Scope: require counter-proposals — every deferral must state what v0.1 should be instead.
- OSS Adoptability: add feature-request guard — flag new feature ideas as [SUGGESTION] at low confidence, not as spec gaps.

---

## Recommendations for Teams

### When to use this protocol

Use multi-agent spec review for any spec that:
- Introduces new external dependencies (APIs, OAuth flows, third-party services)
- Defines new module interfaces that will be implemented independently
- Involves a system that will be built primarily by AI agents
- Will be open-sourced or adopted by engineers other than the author

Skip it for small, well-understood changes — simple refactors, obvious implementation tasks, specs for things you've built before.

### Which personas to run

**Minimum viable set (3 personas, ~45 min):** Skeptic + OSS Adoptability + Security. These three cover the highest-yield lenses — runtime failure modes, adoptability gaps, and accidental exposure — and have the lowest overlap with each other.

**Full general review (5 personas, ~75 min):** Add Architect and MVP Scope. Architect is most valuable for complex system design specs with multiple modules. MVP Scope is most valuable when you suspect over-engineering.

**Extended review (9 personas, ~2.5 hrs):** Add Domain Expert, Legal & Compliance, Operator, Test Strategy. Domain Expert requires customization per project domain. Legal & Compliance is important for any tool handling third-party content. Operator matters for any automated pipeline. Test Strategy matters when implementation will be heavily AI-assisted.

### Model selection

Reviewer sessions are "plan mode" work — reasoning about what's missing, not generating code. This is where model quality has the most impact.

| Persona | Recommended | Rationale |
|---|---|---|
| Architect | Opus, high effort | Deep reasoning about system structure |
| Skeptic | Opus, high effort | Non-obvious gap detection benefits from extended thinking |
| All others | Sonnet, medium effort | Pattern matching against well-defined criteria |
| Synthesis | Opus, high effort | Reasoning across conflicting inputs |

For budget-constrained runs, Sonnet across all personas still captures the majority of value. The quality gap is most pronounced for Architect and Skeptic on complex specs.

### The most important thing

**Nailing down requirements using AI is the highest-leverage activity in AI-assisted development.** Engineers who report the best results with AI coding tools consistently say they spent more time on requirements than they expected — and it paid off. The reason is fundamental: AI agents implement what they're told, not what you meant. A precise spec is not overhead; it is the primary artifact that determines whether AI-generated code is correct.

Multi-agent spec review is a structured way to get the spec precise. The 90 minutes invested before a 2-4 week implementation project is not a cost — it's the cheapest testing you will ever do.

---

## The Relationship to Existing Tools

**everything-claude-code** (affaan-m) provides battle-tested implementation reviewers — code-reviewer, security-reviewer, python-reviewer, typescript-reviewer and more. These cover the implementation phase well. This framework covers the spec phase that comes before. They are complementary: use ai-review-protocols before implementation, everything-claude-code during and after.

**oh-my-claudecode** (Yeachan-Heo) is a full multi-agent orchestration platform. Its Team and Pipeline modes are the natural automation layer for running multiple reviewer sessions without manual prompt composition — the Level 2/3 upgrade path for this framework. Its deep-interview skill is philosophically aligned with this framework's ambiguity focus.

---

## The Meta-Insight

The most valuable framing for explaining this workflow to engineering leaders:

**GitHub becomes the agent's memory and coordination layer.** Issues, PRs, and structured comments are the interface between stateless agent sessions and a stateful project. Each agent session starts fresh — no memory of previous sessions — but the PR comments persist. This means the multi-agent review isn't just a quality gate; it's the persistent record of what was decided and why, which is exactly what future implementer agents need to work from.

This pattern scales from a personal tool to an engineering org. The personas become a shared library. The scorecard becomes a measurement system. The slash commands become org-wide tooling. The conversation about "did we think about X?" moves from an informal code review to a structured, repeatable, measurable process.

---

## Resources

- **ai-review-protocols repo:** `[link]` — personas, base instructions, synthesis agent, scorecard template, workflows
- **ai-radar repo:** `[link]` — the project this framework was validated against
- **everything-claude-code:** https://github.com/affaan-m/everything-claude-code — implementation review agents
- **oh-my-claudecode:** https://github.com/Yeachan-Heo/oh-my-claudecode — multi-agent orchestration

---

*First published: April 2026. Nine-persona run data pending — document will be updated.*
*Framework version: 0.2 (9 personas, unified scorecard)*
