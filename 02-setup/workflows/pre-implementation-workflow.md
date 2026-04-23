# ai-radar — Pre-Implementation Roadmap

> **Project:** ai-radar (daily briefing pipeline)
> **Meta-goal:** AI Engineering Playbook — ai-radar is the reference implementation.
> **Agent:** Claude Code | **Issues:** GitHub Issues | **Priority:** Process first, then ship.
> **Last updated:** 2026-04-05

---

## Status Legend

| Symbol | Meaning |
|---|---|
| ✅ | Complete |
| 🔄 | In progress |
| ⬜ | Not started |
| 🔒 | Blocked by dependency |

---

## Spec Quality

| Version | Score | Date | Status |
|---|---|---|---|
| v0.1 | 4.91 / 10 | 2026-04-04 | Too ambiguous to implement |
| v0.3 | 7.34 / 10 | 2026-04-05 | ✅ Implementation-ready |

**Remaining spec gaps (deferred, not blocking):**
- Prompt templates for Pass 1 + Pass 2 (spec gap #1 — highest impact, address before Phase 3)
- Per-module acceptance criteria (will emerge from TDD test files)
- Processing module method signatures (agents will raise DECISION NEEDED as needed)

---

## Pre-Implementation Phases

### Phase P0 — Agent Infrastructure
*What the agent needs to be effective from the very first session.*
*Produces config and tooling files, not application code.*

| # | Artifact | Status | Notes |
|---|---|---|---|
| P0.1 | `CLAUDE.md` | ✅ | Agent briefing + engineering standards. 12 sections covering autonomy, conventions, TDD protocol, failure handling, quality gates, and playbook rationale. |
| P0.2 | GitHub Issue Templates | ✅ | 4 templates: `[TEST]`, `[IMPL]`, `[SCAFFOLD]`, `[DECISION]`. TDD pairing enforced by template structure. `[DECISION]` issues track spec gaps as they surface. |
| P0.3 | Claude Hooks | ✅ | 4 hooks wired in `.claude/settings.json`: SessionStart (context injection), PreToolUse (prevention gate), PostToolUse (lint + mypy per file), Stop (test suite completion gate). |
| P0.4 | Phase 0 Ticket Set | ⬜ | GitHub Issues for all scaffolding work, written in `[SCAFFOLD]` template format, ready to hand to Claude Code. |
| P0.5 | Prompt Templates | ⬜ | Pass 1 + Pass 2 prompts in `radar/llm/prompts.py`. Must exist before Phase 3 tickets are written. Closes spec gap #1. |

---

### Phase P1 — Repo Scaffolding
*Executed via `[SCAFFOLD]` GitHub Issues. No application code.*
*All work is configuration, tooling, and project structure.*

| # | Deliverable | Status | Blocks |
|---|---|---|---|
| P1.1 | Repo structure | ⬜ | Everything |
| P1.2 | `pyproject.toml` + `uv` | ⬜ | All Python work |
| P1.3 | `ruff` + `mypy` config | ⬜ | Hooks (post_edit_lint.sh) |
| P1.4 | `Makefile` | ⬜ | Hooks (stop_run_tests.sh), CI |
| P1.5 | `.env.example` + `config.example.yaml` | ⬜ | Source connectors |
| P1.6 | `tests/conftest.py` + `TestLLMClient` mock | ⬜ | All LLM-dependent tests |
| P1.7 | Test fixture directory + sample fixtures | ⬜ | Source connector tests |
| P1.8 | `AGENTS.md` | ⬜ | Documentation |
| P1.9 | GitHub Actions workflow skeleton | ⬜ | CI/CD |

*Done when: `make check` runs clean on an empty `radar/__init__.py`.*

---

### Phase P2 — Foundation (TDD)
*First `[TEST]` / `[IMPL]` pairs. Pure logic, no external I/O.*
*Everything downstream depends on these types and interfaces.*

| # | Test Issue | Impl Issue | Module | Status | Spec Ref |
|---|---|---|---|---|---|
| P2.1 | `[TEST]` | `[IMPL]` | `radar/models.py` | ⬜ | §3.1, §4.2 |
| P2.2 | `[TEST]` | `[IMPL]` | `radar/config.py` | ⬜ | §3.5 |
| P2.3 | `[TEST]` | `[IMPL]` | `radar/cache.py` | ⬜ | §4.4 |

*Done when: all dataclasses defined, config loads and validates, cache reads/writes correctly.*

---

### Phase P3 — Sources & Processing (TDD)
*Deterministic modules. No LLM cost. Full TDD possible.*
*Build one source end-to-end before building the rest.*

| # | Test Issue | Impl Issue | Module | Status | Spec Ref |
|---|---|---|---|---|---|
| P3.1 | `[TEST]` | `[IMPL]` | `Source` ABC | ⬜ | §3.1 |
| P3.2 | `[TEST]` | `[IMPL]` | RSS connector | ⬜ | §3.1 |
| P3.3 | `[TEST]` | `[IMPL]` | HN connector | ⬜ | §3.1 |
| P3.4 | `[TEST]` | `[IMPL]` | ArXiv connector | ⬜ | §3.1 |
| P3.5 | `[TEST]` | `[IMPL]` | Gmail connector | ⬜ | §3.1 (OAuth) |
| P3.6 | `[TEST]` | `[IMPL]` | `deduplicator.py` (Phase 1 + 2) | ⬜ | §3.2 steps 2, 5 |
| P3.7 | `[TEST]` | `[IMPL]` | `excerpt_fetcher.py` | ⬜ | §3.2 step 4 |
| P3.8 | `[TEST]` | `[IMPL]` | `pre_filter.py` | ⬜ | §3.2 step 6 |

*Done when: pipeline runs from source fetch through pre-filter with no LLM calls, producing a `list[ExcerptItem]`.*

---

### Phase P4 — LLM Pipeline (TDD)
*Depends on real preprocessing output from Phase P3.*
*Prompt templates (P0.5) must exist before these tickets are written.*

| # | Test Issue | Impl Issue | Module | Status | Spec Ref |
|---|---|---|---|---|---|
| P4.1 | `[TEST]` | `[IMPL]` | `LLMClient` (GitHub Models) | ⬜ | §4.3 |
| P4.2 | `[TEST]` | `[IMPL]` | `summarizer.py` (Pass 1) | ⬜ | §3.3 |
| P4.3 | `[TEST]` | `[IMPL]` | `full_fetcher.py` | ⬜ | §3.2 step 7 |
| P4.4 | `[TEST]` | `[IMPL]` | `truncator.py` | ⬜ | §3.3 |
| P4.5 | `[TEST]` | `[IMPL]` | `synthesizer.py` (Pass 2) | ⬜ | §3.3 |

*Done when: pipeline runs end-to-end from `ExcerptItem` list through `Digest`, using `TestLLMClient` mock for unit tests.*

---

### Phase P5 — Output & Wiring (TDD)
*Connects everything. CLI + pipeline orchestration + email delivery.*

| # | Test Issue | Impl Issue | Module | Status | Spec Ref |
|---|---|---|---|---|---|
| P5.1 | `[TEST]` | `[IMPL]` | `markdown.py` | ⬜ | §3.4 |
| P5.2 | `[TEST]` | `[IMPL]` | `pipeline.py` | ⬜ | §4.2 |
| P5.3 | `[TEST]` | `[IMPL]` | `__main__.py` (CLI) | ⬜ | §3.6 |
| P5.4 | `[SCAFFOLD]` | — | GitHub Actions workflow (full) | ⬜ | §3.6 |
| P5.5 | `[SCAFFOLD]` | — | `examples/sample-briefing.md` | ⬜ | §7 |

*Done when: `python -m radar run` produces a digest file end-to-end. `radar check` validates config and credentials.*

---

## Dependency Graph

```
Spec v0.3 (✅)
    │
    ├── P0: Agent Infrastructure
    │       ├── CLAUDE.md (✅)
    │       ├── Issue Templates (✅)
    │       ├── Claude Hooks (✅)
    │       ├── Phase 0 Ticket Set (⬜)  ← next
    │       └── Prompt Templates (⬜)    ← before P4 tickets
    │
    └── P1: Repo Scaffolding (⬜)
            │
            └── P2: Foundation — models, config, cache (⬜)
                    │
                    └── P3: Sources & Processing (⬜)
                            │
                            ├── [Prompt Templates required here]
                            │
                            └── P4: LLM Pipeline (⬜)
                                    │
                                    └── P5: Output & Wiring (⬜)
                                                │
                                                └── 🚀 First end-to-end run
```

---

## Playbook Artifacts Produced So Far

These are the reusable assets being built for the AI Engineering Playbook,
using ai-radar as the reference implementation.

| Artifact | Purpose in Playbook | Status |
|---|---|---|
| Spec quality scorecard (v0.1 → v0.3) | How to evaluate and improve a spec before handing to agents | ✅ |
| `CLAUDE.md` | Template for briefing AI agents on a codebase; scales to team standard | ✅ |
| GitHub Issue templates (`[TEST]`, `[IMPL]`, `[SCAFFOLD]`, `[DECISION]`) | Standardized agent task format enforcing TDD pairing | ✅ |
| Claude hooks suite | Enforcement layer separating advisory (CLAUDE.md) from deterministic (hooks) | ✅ |
| This roadmap | Pre-implementation phase structure for AI-first projects | ✅ |
| Phase 0 ticket set | Example `[SCAFFOLD]` issues, fully filled out | ⬜ |
| Prompt template pattern | How to treat prompts as code (versionable, reviewable) | ⬜ |
| TDD workflow with AI agents | `[TEST]` → `[IMPL]` pairing in practice, with hook enforcement | ⬜ |
| ADR / decision log | How `[DECISION]` issues capture architectural decisions as permanent record | ⬜ |

---

## Key Decisions Made

| Decision | Rationale | Where documented |
|---|---|---|
| Process-first (playbook over ship speed) | ai-radar is a case study; the process artifacts are the primary output | This doc |
| Claude Code as agent | Best CLAUDE.md + hooks integration; terminal-native | `CLAUDE.md` |
| GitHub Issues for tickets | Native `gh` CLI integration with Claude Code; issues are permanent record | Issue templates |
| TDD: `[TEST]` before `[IMPL]` | Test file = executable acceptance criteria; prevents spec drift | `CLAUDE.md §7`, issue templates |
| `[DECISION]` issues for ambiguity | Surfaces spec gaps as trackable artifacts, not silent agent choices | Issue template |
| Python 3.12 + strict mypy | Stage-boundary type safety; dataclasses for all pipeline models | `CLAUDE.md §4-5` |
| Hooks = enforcement, CLAUDE.md = advisory | Separates "must happen" from "should happen"; hooks are deterministic | `CLAUDE.md`, hooks |
| `settings.local.json` as escape valve | Hooks must be sustainable; engineers need a bypass for spikes | Hook docs |
| Prompt templates as constants in `prompts.py` | Prompts are code — versionable, reviewable, independently testable | `CLAUDE.md §9` |

---

## Next Actions

1. **⬜ Phase 0 ticket set** — Write `[SCAFFOLD]` GitHub Issues for P1.1–P1.9, ready to hand to Claude Code
2. **⬜ Prompt templates** — Draft Pass 1 + Pass 2 prompts before Phase 4 tickets are written
3. **⬜ Begin P1** — Execute scaffolding issues with Claude Code; capture decisions as `[DECISION]` issues
