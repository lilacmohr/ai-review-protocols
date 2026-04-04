# AI Review Protocol — Evaluation Scorecard

**Project:** ai-radar  
**PR:** #1 — Add SPEC.md  
**PR Type:** Spec  
**Date:** 2026-04-03  
**Evaluator:** lilacmohr (filled by Copilot from PR comment data)  
**Personas run:** Architect / OSS Adoptability / MVP Scope / Security / Skeptic  
**Total session time (approx):** ~90 min (5 reviewers + synthesis, run manually)  
**Note:** Architect review was posted twice by the bot (duplicated comment). Only one instance counted below.

---

## 1. Per-Comment Log

One row per comment posted by any reviewer agent. Fill in `Unique?` and `Actionable?` yourself after reading all five reviews.

| # | Reviewer | Label | Section | Confidence | Unique? | Actionable? | Addressed? | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | Architect | BLOCKING | 4.3 LLM Backend Abstraction | 9/10 | N | Y | N/A | Anthropic SDK ≠ OpenAI-compatible; abstraction broken |
| 2 | Architect | BLOCKING | 3.6/4.4 GitHub Actions + Cache | 8/10 | Y | Y | N/A | Ephemeral runners wipe SQLite cache; dedup silently broken in CI |
| 3 | OSS | BLOCKING | 3.5/6/7 Gmail OAuth setup | 9/10 | Y | Y | N/A | How to get refresh token entirely absent from spec |
| 4 | OSS | BLOCKING | 3.6/Open Q#3 Gmail token expiry in Actions | 8/10 | N | Y | N/A | Refresh tokens expire; no CI auth recovery path |
| 5 | Skeptic | BLOCKING | 3.1 Source fetch() error contract | 9/10 | N | Y | N/A | No spec for partial source failure; two impls will diverge |
| 6 | Architect | AMBIGUITY | 3.2 vs 4.2 preprocessing step ordering | 9/10 | Y | Y | N/A | Truncate→PreFilter (3.2) vs PreFilter→Truncator (4.2); contradictory |
| 7 | Architect | AMBIGUITY | 3.3 LLM Pass 1 output schema | 9/10 | N | Y | N/A | complete() returns str; no JSON schema, no parse failure spec |
| 8 | Architect | AMBIGUITY | 3.1/4.1 RawItem/ScoredItem/Digest schemas | 8/10 | Y | Y | N/A | Only NormalizedItem defined; source impls will diverge |
| 9 | Architect | AMBIGUITY | 3.3 Pass 2 input specification | 7/10 | N | Y | N/A | Full text vs. summaries? Count? Token budget? |
| 10 | Architect | AMBIGUITY | 3.6/9 Gmail OAuth in Actions | 8/10 | N | Y | N/A | Same core as col. 4 but from architecture lens |
| 11 | OSS | AMBIGUITY | 3.6/4.1 Required GitHub Secrets not listed | 8/10 | N | Y | N/A | User can't configure Actions without a secrets table |
| 12 | OSS | AMBIGUITY | 4.5/5 Install process unspecified | 8/10 | Y | Y | N/A | pyproject.toml AND requirements.txt both listed; no venv instructions |
| 13 | OSS | AMBIGUITY | 3.2/3.3 No failure behavior | 7/10 | N | Y | N/A | Silent empty file or crash on first-run errors |
| 14 | OSS | AMBIGUITY | 4.3 GitHub Models model name identity | 7/10 | Y | Y | N/A | Are "gpt-4o-mini" etc. valid identifiers for GH Models endpoint? |
| 15 | MVP Scope | AMBIGUITY | 3.1/3.3/3.6 Missing failure contract | 9/10 | N | Y | N/A | Same core as #5/#13 but framed as scope risk |
| 16 | MVP Scope | AMBIGUITY | 3.6/9 Gmail OAuth in Actions | 9/10 | N | Y | N/A | Fifth reviewer flagging same blocker |
| 17 | MVP Scope | AMBIGUITY | 4.3 Three LLM backends as MVP | 8/10 | Y | Y | N/A | Scope framing: build+test 3 backends before v0.1? |
| 18 | MVP Scope | AMBIGUITY | 4.1 AGENTS.md purpose undefined | 7/10 | N | Y | N/A | File in repo structure with no description |
| 19 | Security | AMBIGUITY | 3.6/Q#3/6 Gmail OAuth CI token lifecycle | 9/10 | N | Y | N/A | No initial token flow, no expiry handling, no CI recovery |
| 20 | Security | AMBIGUITY | 3.5/.env/4.3 .env missing LLM API keys | 8/10 | Y | Y | N/A | OPENAI_API_KEY / ANTHROPIC_API_KEY absent from .env.example |
| 21 | Security | AMBIGUITY | 3.6/4.1 GitHub Actions workflow unspec'd | 8/10 | N | Y | N/A | No secrets list, no permissions spec, write-all risk |
| 22 | Security | AMBIGUITY | 6/3.2/3.3 Logging policy / secret leakage | 7/10 | Y | Y | N/A | openai + google clients can surface auth headers in debug logs |
| 23 | Security | AMBIGUITY | 3.6/6 Digests in public repo | 7/10 | Y | Y | N/A | Paid newsletter summaries committed to public GitHub = legal/ethical risk |
| 24 | Skeptic | AMBIGUITY | 3.3 LLM output schema undefined | 9/10 | N | Y | N/A | Overlaps #7; from skeptic lens = most likely real failure mode |
| 25 | Skeptic | AMBIGUITY | 3.2 Step 5 Pre-filter algorithm | 8/10 | Y | Y | N/A | Exact/substring/case? Any keyword or all? Title only? |
| 26 | Skeptic | AMBIGUITY | 3.3 Zero-results scenario | 8/10 | N | Y | N/A | Same as #13/#15 but specifically for empty Pass 2 input |
| 27 | Skeptic | AMBIGUITY | 3.1/3.6 Gmail marks-as-read + OAuth | 8/10 | Y | Y | N/A | Marks-read angle is unique; lost emails on failure |
| 28 | Skeptic | AMBIGUITY | 4.4 Cache check timing inconsistent | 7/10 | N | Y | N/A | "Before any fetch" contradicts needing content for content-hash |
| 29 | Skeptic | AMBIGUITY | 4.3 Model name/backend mismatch | 7/10 | N | Y | N/A | gpt-4o-mini passed to Anthropic backend = confusing API error |
| 30 | Skeptic | AMBIGUITY | 3.1 trafilatura vs newsletter HTML | 7/10 | Y | Y | N/A | trafilatura is designed for article pages; newsletters degrade silently |
| 31 | Skeptic | AMBIGUITY | 3.2 Step 4 words vs. tokens inconsistency | 7/10 | Y | Y | N/A | Config says words; description says "token length"; 20-30% budget error |
| 32 | Skeptic | AMBIGUITY | 3.3 Pass 2 context budget | 7/10 | N | Y | N/A | 15 articles × 800 words = 12k+ words input; no overflow spec |
| 33 | Architect | FALSE PRECISION | 3.5 Config numeric values | 7/10 | N | Y | N/A | max_articles, batch_size etc. look decided but are placeholders |
| 34 | OSS | FALSE PRECISION | 5 Setup time "< 30 minutes" | 8/10 | Y | Y | N/A | Doesn't account for GCP project + Gmail OAuth (10-45 min extra) |
| 35 | OSS | FALSE PRECISION | 3.5 Config numeric values | 7/10 | N | Y | N/A | Same as #33 from OSS lens; min_score:100 may over-filter HN |
| 36 | OSS | FALSE PRECISION | 3.5 Hardcoded RSS feed URLs unverified | 7/10 | Y | Y | N/A | anthropic.com/blog/rss etc. not confirmed as working endpoints |
| 37 | MVP Scope | FALSE PRECISION | 3.5 Pipeline config numbers | 7/10 | N | Y | N/A | Same as #33 from scope lens |
| 38 | Security | FALSE PRECISION | 3.5 Config numeric values | 6/10 | N | Y | N/A | Context window math not validated against gpt-4o-mini |
| 39 | Skeptic | FALSE PRECISION | 3.5/5 Config numeric cluster | 7/10 | N | Y | N/A | Most thorough: covers all 6 values + NFR math |
| 40 | Skeptic | FALSE PRECISION | 5 GitHub Models free tier = $0 | 6/10 | Y | Y | N/A | Not contractually guaranteed; automated use may be rate-limited |
| 41 | Architect | SUGGESTION | 4.2 Zero-article pipeline behavior | 7/10 | N | Y | N/A | Overlaps #26; emit "no content today" digest |
| 42 | Architect | SUGGESTION | 4.1 AGENTS.md undefined | 6/10 | N | Y | N/A | Overlaps #18 |
| 43 | OSS | SUGGESTION | 7/README Sample digest | 8/10 | Y | Y | N/A | examples/sample-briefing.md — high impact for GitHub visitors |
| 44 | OSS | SUGGESTION | 3.6/7 Test/check subcommand | 7/10 | Y | Y | N/A | python -m radar check; validate creds without LLM cost |
| 45 | OSS | SUGGESTION | 4.4 Cache-clear/inspect commands | 7/10 | Y | Y | N/A | radar cache clear / stats; silent dedup issues hard to debug |
| 46 | MVP Scope | SUGGESTION | 3.1 Phase source connectors | 8/10 | Y | Y | N/A | v0.1 = RSS+ArXiv; v0.2 = Gmail+HN; arch already supports this |
| 47 | MVP Scope | SUGGESTION | 3.6 Defer GitHub Actions | 7/10 | Y | Y | N/A | Manual+cron proves value; Actions adds infra before core is validated |
| 48 | MVP Scope | SUGGESTION | 4.1 Remove podcasts.py stub | 6/10 | N | N | N/A | Also flagged as NIT by Skeptic |
| 49 | Security | SUGGESTION | 6/7 Secret scanning | 8/10 | Y | Y | N/A | git-secrets / .pre-commit-config.yaml for OSS forks |
| 50 | Security | SUGGESTION | 6 GitHub Models data residency | 7/10 | Y | Y | N/A | Content sent to MS/OpenAI infra; not disclosed in default config |
| 51 | Skeptic | SUGGESTION | 4.4 cache_ttl_days in config.yaml | 8/10 | Y | Y | N/A | Spec'd in 4.4 but missing from config example |
| 52 | Skeptic | SUGGESTION | 3.6 First-run OAuth experience | 7/10 | Y | Y | N/A | No description of auth flow, token storage, expected UX |
| 53 | Architect | NIT | 4.4 Cache check timing | 6/10 | N | N | N/A | Overlaps #28 (Skeptic flagged as AMBIGUITY with higher confidence) |
| 54 | OSS | NIT | 4.1 digests/ commit mechanism | 6/10 | Y | N | N/A | Add commit_digests: true/false to config |
| 55 | MVP Scope | NIT | 8 Post-MVP roadmap ordering | 6/10 | Y | N | N/A | Slack/email > Web UI for a personal tool |
| 56 | Security | NIT | 4.4 Cache content vs. hash | 6/10 | Y | N | N/A | Clarify seen_items stores hashes only, not plaintext |
| 57 | Skeptic | NIT | 3.1 Podcast in config.yaml | 6/10 | N | N | N/A | Overlaps #48; add "# post-MVP, not yet implemented" comment |

> **Total comments: 57** (Architect 11, OSS 13, MVP Scope 9, Security 9, Skeptic 15)  
> **Note:** "Addressed?" left N/A throughout — PR open at time of evaluation; no spec updates observed.  
> Unique = not flagged by any other reviewer. Actionable = clearly worth acting on given the spec's implementation readiness goal.

---

## 2. Per-Reviewer Summary

Complete one block per persona after filling in the comment log.

### 🏗️ Architect
| Metric | Count |
|---|---|
| Total comments | 11 |
| BLOCKING | 2 |
| AMBIGUITY | 5 |
| FALSE PRECISION | 1 |
| SUGGESTION | 2 |
| NIT | 1 |
| Avg confidence | 7.6/10 |
| Unique findings | 3 / 11 |
| Actionable rate | 7 / 7 BLOCKING+AMBIGUITY |
| Format compliant | Y (bold `**[LABEL]**` / `**Section:**`) |

**Standout finding:** Preprocessing step ordering conflict between Section 3.2 and 4.2 — only reviewer to catch that these describe structurally different pipelines with real cost implications. The undefined `RawItem`/`ScoredItem`/`Digest` schemas finding was also unique and load-bearing.

**Weakness:** Relatively low unique rate (3/11 = 27%). Several comments overlap significantly with Skeptic (Pass 1 schema, Pass 2 context). The NIT on cache timing was already the Skeptic's AMBIGUITY; Architect should have escalated it.

---

### 🔍 Skeptic
| Metric | Count |
|---|---|
| Total comments | 15 |
| BLOCKING | 1 |
| AMBIGUITY | 9 |
| FALSE PRECISION | 2 |
| SUGGESTION | 2 |
| NIT | 1 |
| Avg confidence | 7.4/10 |
| Unique findings | 7 / 15 |
| Actionable rate | 10 / 10 BLOCKING+AMBIGUITY |
| Format compliant | Partial (structure correct; no bold `**` on labels/fields) |

**Standout finding:** Pre-filter matching algorithm completely unspecified (row 25) — the only reviewer to ask "how does this actually work?" rather than "does it scale?". Also uniquely caught: trafilatura's unsuitability for newsletter HTML (row 30) — a silent quality failure mode with high practical impact.

**Weakness:** Highest comment count (15) with some overlap diluting signal — the Gmail OAuth / Actions comment (row 27) bundles two distinct issues (marks-as-read and CI token expiry), and the zero-results scenario (row 26) duplicates findings already at Architect/OSS level.

---

### 📦 OSS Adoptability
| Metric | Count |
|---|---|
| Total comments | 13 |
| BLOCKING | 2 |
| AMBIGUITY | 4 |
| FALSE PRECISION | 3 |
| SUGGESTION | 3 |
| NIT | 1 |
| Avg confidence | 7.5/10 |
| Unique findings | 9 / 13 |
| Actionable rate | 6 / 6 BLOCKING+AMBIGUITY |
| Format compliant | Y (bold `**[LABEL]**` / `**Section:**`) |

**Standout finding:** The Gmail OAuth setup documentation blocker (row 3) — the only reviewer to ask "how does a new user actually get a refresh token?" as distinct from the CI token-expiry question. Also uniquely caught: install process ambiguity (row 12), unverified RSS URLs (row 36), and the 30-minute setup time false precision (row 34).

**Weakness:** Three False Precision comments on similar config values when one thorough one would have covered it. The `check` subcommand suggestion (row 44) is genuinely useful but verges on feature request territory.

**Weakness:** Relatively low unique rate (9/13 = 69% — actually the highest absolute unique count). Mostly strong; the one weakness is the suggestions nudge feature scope (test command, cache clear) which may not strictly belong in a spec review.

---

### 🔒 Security
| Metric | Count |
|---|---|
| Total comments | 9 |
| BLOCKING | 0 |
| AMBIGUITY | 5 |
| FALSE PRECISION | 1 |
| SUGGESTION | 2 |
| NIT | 1 |
| Avg confidence | 7.3/10 |
| Unique findings | 6 / 9 |
| Actionable rate | 5 / 5 AMBIGUITY |
| Format compliant | Partial (structure correct; no bold `**` on labels/fields) |

**Standout finding:** Digests committed to public repo exposes restricted newsletter content (row 23) — only reviewer to flag the legal/ethical dimension. Also unique: logging policy as a secret-leakage vector (row 22), and the incomplete `.env.example` for non-default LLM backends (row 20).

**Weakness:** No BLOCKING labels despite flagging issues that other reviewers called BLOCKING (Gmail OAuth in CI, workflow security). The security lens was appropriately thorough but slightly deferential in label severity.

---

### ✂️ MVP Scope
| Metric | Count |
|---|---|
| Total comments | 9 |
| BLOCKING | 0 |
| AMBIGUITY | 4 |
| FALSE PRECISION | 1 |
| SUGGESTION | 3 |
| NIT | 1 |
| Avg confidence | 7.4/10 | 
| Unique findings | 4 / 9 |
| Actionable rate | 4 / 4 AMBIGUITY |
| Format compliant | Partial (structure correct; no bold `**` on labels/fields) |

**Standout finding:** Three LLM backends as MVP scope (row 17) — the only reviewer to frame backend complexity as a scope risk rather than a technical correctness problem. Also uniquely flagged: "phase source connectors to v0.1=RSS/ArXiv, v0.2=Gmail/HN" (row 46) — a concrete MVP reduction no other reviewer made.

**Weakness:** No BLOCKING labels; called the Gmail/CI OAuth issue an AMBIGUITY when it should arguably be BLOCKING. The connector phasing SUGGESTION is the strongest unique contribution but was underconfidenced at 8/10 given how clear the argument is.

---

## 3. Conflict Log

One entry per pair of reviewers that gave conflicting guidance on the same issue.

```
Conflict #1
  Reviewer A: OSS Adoptability [implicit BLOCKING] — keep all 3 LLM backends for MVP;
              OSS adopters without GitHub Models access need OpenAI fallback
  Reviewer B: MVP Scope [AMBIGUITY] — ship GitHub Models only for v0.1; LLMClient
              abstraction stays but don't implement/test OpenAI or Anthropic yet
  Section: 4.3
  Resolution: Human decision / Compromise — Synthesis recommends GitHub Models + OpenAI
              (low marginal cost given OpenAI-compatible wiring); defer Anthropic (needs
              separate SDK, breaks current abstraction)
  Notes: Synthesis verdict seems right — Anthropic deferral buys the most without 
         sacrificing OSS accessibility.

Conflict #2
  Reviewer A: OSS Adoptability + Architect [treat GitHub Actions as first-class MVP trigger]
  Reviewer B: MVP Scope [SUGGESTION] — defer GitHub Actions to post-MVP; manual + cron 
              prove value; Gmail OAuth-in-CI is risky infra before core pipeline validated
  Section: 3.6
  Resolution: Synthesis recommends deferring GitHub Actions to post-MVP; the Gmail OAuth
              blocker is real, workflow YAML adds scope before pipeline is proven
  Notes: MVP Scope reviewer had the right call here; the Gmail/CI issue adds real 
         implementation risk that doesn't exist with cron.

Conflict #3
  Reviewer A: (Implicit spec position) — all 5 active source connectors in MVP
  Reviewer B: MVP Scope [SUGGESTION] — phase v0.1 = RSS+ArXiv; v0.2 = Gmail+HN
  Section: 3.1
  Resolution: [HUMAN DECISION REQUIRED] — depends on whether MVP goal is "prove architecture"
              or "deliver personal briefing from Gmail". Synthesis correctly flags this.
  Notes: If author's primary use case is Gmail newsletters, deferring Gmail
         defeats the personal-use purpose. If goal is engineering demo, RSS+ArXiv suffices.
```

---

## 4. Ambiguity Detection Quality

Assess whether the dedicated ambiguity scan instruction did its job independently of each reviewer's primary lens.

| Question | Answer |
|---|---|
| Total [AMBIGUITY] comments across all reviewers | 27 |
| Did different reviewers flag *different* ambiguities? | Y — each reviewer found at least 3-4 issues no other reviewer caught |
| Did any reviewer's ambiguity findings look identical to another's? | Y — Gmail OAuth in GitHub Actions flagged by all 5 in essentially the same form; config numeric values flagged by all 5 |
| Were any ambiguities flagged that you genuinely hadn't considered? | Y — preprocessing step ordering conflict (Architect), trafilatura newsletter suitability (Skeptic), digests in public repo (Security), RSS URL verification (OSS) |
| Did the ambiguity pass feel like a separate scan or just part of the primary lens? | Mixed — some reviewers (Skeptic, OSS) produced clearly lens-differentiated ambiguities; others (all 5 on Gmail OAuth) converged on the same issue regardless of lens |

**Most valuable ambiguity finding:** Preprocessing step ordering conflict (Architect, row 6) — two canonical spec sections describing materially different pipelines. High implementation divergence potential, zero overlap with other reviewers.

**Assessment:** The ambiguity instruction pulled its weight — 27 AMBIGUITY comments with ~50% persona-unique findings shows it surfaced genuinely varied issues. However, the 5/5 convergence on Gmail OAuth suggests the instruction didn't fully prevent reviewers from landing on the most obvious issue; each still flagged it despite it being clearly not unique to their lens. The instruction could be strengthened with: "Check whether the most obvious issue has already appeared in the spec's own Open Questions before flagging it as a primary finding."

---

## 5. Protocol Effectiveness Score (PES)

Calculate after completing sections 1–4.

| Metric | Formula | Target | Actual | Pass? |
|---|---|---|---|---|
| **Signal density** | (BLOCKING + AMBIGUITY) / total comments | > 50% | 56.1% (32/57) | Y |
| **Persona uniqueness** | avg(unique/total per reviewer) | > 40% | 50.8% avg across 5 reviewers | Y |
| **Actionability** | addressed / (BLOCKING + AMBIGUITY) | > 70% | N/A — PR not yet updated | — |
| **Format compliance** | reviewers on-format / 5 | 5/5 | 2/5 (Architect + OSS used bold `**`; MVP/Security/Skeptic used plain text) | N |
| **Conflict rate** | conflict pairs / total comments | 10–30% | 5.3% (3/57) | N |
| **Confidence calibration** | high-conf comments that were actionable vs low-conf | higher = better | All 8/10+ comments were actionable; all 6/10 were NITs or overlapping SUGGESTIONs | PASS |

> **Conflict rate interpretation:**  
> < 10% — personas may be too similar or too deferential to each other  
> 10–30% — healthy independent perspectives  
> > 30% — persona scopes overlap too much or are poorly bounded

**Overall PES assessment:** ADEQUATE — signal density and persona uniqueness pass; format compliance failure is a prompt enforceability issue (not a reviewer reasoning failure); low conflict rate reflects genuine spec clarity in some areas but hints at persona boundary blur (all 5 flagging the same Gmail/Actions issue).

---

## 6. Retro — What to Improve

### What worked well
- **Persona differentiation produced genuinely non-overlapping finds.** OSS caught the initial Gmail OAuth setup gap (how to get the token) while Security caught the CI token lifecycle gap — same surface area, completely different angles. Neither would have found the other's issue.
- **Skeptic as "adversarial pass" was the highest-yield reviewer.** 15 comments, 7 unique, 100% actionable on BLOCKING+AMBIGUITY. The trafilatura finding and pre-filter algorithm gap were both real spec holes.
- **Synthesis comment was well-structured and usable.** The three-tier format (consensus → single-reviewer → conflicts) made a clear reading order. The conflict section surfacing the GitHub Actions / LLM backend decisions was actionable without being prescriptive.

### What didn't work
- **All 5 reviewers flagged Gmail OAuth in GitHub Actions** — already an explicit Open Question in the spec. The protocol has no mechanism that says "don't echo Open Questions back unless you have a resolution." This created ~5 near-duplicate paragraphs.
- **Format compliance inconsistent across reviewers** — Architect and OSS used `**[BLOCKING]**` / `**Section:**` bold markdown. MVP Scope, Security, and Skeptic used plain `[BLOCKING]` / `Section:` — visually similar but not rendering-identical on GitHub.
- **Architect review was posted twice** — a prompt execution error, not a protocol issue, but worth noting as operational friction.

### Prompt improvements identified

| Reviewer | Improvement |
|---|---|
| Architect | Add: "Before flagging an Open Question, check whether it appears explicitly in the spec's own Open Questions section. If it does, note it but don't spend your primary findings on it unless you have a concrete resolution suggestion the spec lacks." |
| Skeptic | Add: "Consolidate related issues into a single comment rather than splitting them across multiple rows — e.g. the Gmail/OAuth comment bundled two distinct issues (marks-as-read and CI token expiry) that each deserved their own confidence and section citation." |
| OSS Adoptability | Light suggestion to avoid duplicate False Precision comments when the same set of numbers appears multiple times in the spec (cite once, note all instances). |
| Security | Upgrade severity guidance: specify that an issue requiring interactive browser auth in a headless CI environment should be labeled BLOCKING, not AMBIGUITY. |
| MVP Scope | Add: "For each item you flag as post-MVP or as scope risk, explicitly state what v0.1 should be instead. A scope review without a counter-proposal is just a complaint." |

### Persona changes
No personas should be dropped. The Security and OSS personas have the most differentiated lenses. Consider whether Architect and Skeptic are sufficiently distinguished — they converged heavily on LLM output schema and Pass 2 context questions. A potential refinement: Architect focuses on module/interface boundaries and data models; Skeptic focuses on runtime failure modes and observable behavior. Currently the boundary is fuzzy.

### Label/format changes
The `[FALSE PRECISION]` label is underused relative to its value — all 5 reviewers used it but often for the same config values. Consider adding a prompt note: "FALSE PRECISION is most valuable when applied to non-obvious precision (estimates, NFR targets, timeout values) rather than placeholder numbers in config examples."

### Threshold changes
The 6/10 confidence floor is right. All 6/10 comments were NITs or near-duplicates — exactly the category to optionally include. No 7/10+ comment seemed like a false positive.

---

## 7. Net Value Assessment

Answer these honestly — this is the section most useful for recommending this protocol to others.

**Did the agents catch anything you genuinely wouldn't have caught in self-review?**
Likely yes: preprocessing step ordering conflict between 3.2 and 4.2, trafilatura's unsuitability for newsletter HTML, the incomplete `.env.example` for non-default LLM backends, RSS URL verification. These are the kind of cross-cutting checks that slip in self-review when you're focused on the big picture.

**Did running 5 reviewers find meaningfully more than 1–2 reviewers would have?**
Yes — but with diminishing returns after ~3. Architect + Skeptic would have covered the core architecture and failure mode issues. OSS added the most unique value (9/13 unique, 2 BLOCKINGs). Security added the public-repo/legal angle no one else caught. MVP Scope added mostly scope advisories that could have been combined with another persona. If forced to pick 3: Skeptic + OSS + Security.

**Estimated spec quality improvement from doing this (qualitative):**
Significant. At least 8-10 issues that would have caused implementation bugs or rework: Anthropic backend incompatibility, preprocessing step ordering, undefined data model schemas, pre-filter algorithm, trafilatura fallback, GitHub Actions cache persistence, `.env.example` completeness, digests-in-public-repo default. The spec could reasonably go from "implementable with guesswork" to "implementable with confidence" by resolving the ~10 consensus BLOCKING/AMBIGUITY items.

**Time cost vs. value assessment:**
~90 minutes of session time for a spec that would take 2-4 weeks to implement. That ratio seems clearly worth it. The main cost is the manual prompt composition + paste workflow. A single automated command would make this < 15 minutes of active work.

**Would you recommend this protocol to another engineer on your team?**
Yes, for specs of medium+ complexity (3+ modules, external APIs, new system design). The protocol is most valuable when the spec describes something no one has implemented before — it surfaces assumptions that aren't visible until you put on each lens. For small refactors or obvious implementation tasks, it's overkill.

---

## 8. One-Page Summary

*Complete this last. This is what you share with others.*

## 8. One-Page Summary

*Complete this last. This is what you share with others.*

**What we did:**
Ran 5 AI reviewer agents (Architect, Skeptic, OSS Adoptability, Security, MVP Scope) plus a Synthesis agent against a SPEC.md PR for ai-radar, a personal AI newsletter digest tool. Each reviewer used the base-instructions + persona file, posted a single structured comment to the PR, then the Synthesis agent condensed findings into a prioritized action list.

**Scorecard highlights:**
- Signal density: 56.1% (32/57 comments were BLOCKING or AMBIGUITY) — PASS
- Persona uniqueness: 50.8% avg unique findings per reviewer — PASS
- Actionability: N/A (PR not yet updated at evaluation time)
- Conflicts detected: 3 (LLM backend count, GitHub Actions scope, connector phasing)
- Most valuable reviewer: OSS Adoptability (9/13 unique finds, 2 genuine BLOCKINGs others didn't escalate)
- Least differentiated reviewer: Architect (converged with Skeptic on LLM output schema and Pass 2 issues; low unique rate at 27%)

**What worked:**
Persona differentiation produced meaningfully non-overlapping findings — the OSS/Security lens split on Gmail OAuth (initial setup vs. CI token lifecycle) is a clean example. The Synthesis comment was immediately usable as a prioritized action list. Confidence floor of 6/10 kept the noise low.

**What didn't:**
All 5 reviewers flagged Gmail OAuth in GitHub Actions despite it being an explicit Open Question in the spec. Format compliance was inconsistent — only 2/5 reviewers used bold `**` markdown on labels/fields. Architect review was accidentally posted twice.

**What we'd change:**
Add a base-instructions note: "Before including a finding, check whether it appears in the spec's own Open Questions — if so, only include it if you have a concrete resolution the spec lacks." Strengthen the output format instruction to make bold `**[LABEL]**` markup harder to skip. Consider a 3-persona fast-track (Skeptic + OSS + Security) for specs under time pressure.

**Recommendation for teams:**
Use for any spec that introduces new external dependencies, new module interfaces, or a new system design. It's most valuable when you are the author — the protocol simulates the review your spec would get from a skeptical senior engineering team. Skip it for small, well-understood changes. The manual workflow (paste prompt → run → copy output → post) is the main adoption friction; tooling would make this significantly more accessible.

---

*Template version: 0.1 — update based on retro findings and re-version.*
