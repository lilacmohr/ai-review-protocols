---
name: audit-pre-impl
description: >
  Audit a repository to verify all pre-implementation checklist items are complete
  before sprint 1 begins. Use this skill when someone asks "are we ready to start
  implementation?", "run the pre-implementation audit", "check if pre-impl is done",
  or "verify sprint zero is complete". This is the formal gate between pre-implementation
  and feature development. It checks: spec readiness, agent briefing doc, enforcement
  layer, issue templates, scaffolding, and prompt templates (if LLM project).
---

# Pre-Implementation Checklist Auditor

Verify that all pre-implementation conditions are met before sprint 1 begins.
Produces a structured audit report with PASS/FAIL per item and a go/no-go verdict.

## When to Use

- At the end of sprint zero, before any feature ticket is assigned
- When asked "are we ready to start implementation?"
- When onboarding a new team member who needs to verify the project setup
- As a periodic health check during long projects

## Audit Process

Work through each section systematically. For each item:
1. Look for the artifact (file, config entry, command output)
2. Verify it meets the quality bar — existence alone is not enough
3. Record PASS, FAIL, or WARN with a specific finding

Do not skip items. A checklist with gaps is worse than no checklist — it creates
false confidence. If you cannot verify an item, mark it UNKNOWN and explain why.

Read these files at minimum before starting:
- `CLAUDE.md` (or equivalent agent briefing doc)
- `.claude/settings.json` (or equivalent hooks config)
- `pyproject.toml` / `package.json` / equivalent
- `Makefile` / `justfile` / equivalent task runner config
- `.github/ISSUE_TEMPLATE/` or equivalent
- `SPEC.md` (to check if it has been scored)

Run these commands to verify scaffolding:
- Check quality gate command exists and runs (e.g., `make check --dry-run`)
- Check test directory structure exists
- Check CI config exists (`.github/workflows/` or equivalent)

---

## The Checklist

### Section 1: Spec Readiness

| Item | How to verify | Pass bar |
|---|---|---|
| Spec score ≥ 7.0 | Look for a scorecard file or score comment in SPEC.md | Score documented and ≥ 7.0 |
| Top ambiguities resolved or deferred | Look for open questions section in spec | Each gap has resolution or explicit deferral with rationale |
| Data models fully defined | Read spec data model section | All fields named and typed |
| Failure modes specified | Read spec failure handling section | At least the major external dependency failures are covered |

### Section 2: Agent Briefing Document

| Item | How to verify | Pass bar |
|---|---|---|
| Briefing doc exists | Look for CLAUDE.md, .cursorrules, copilot-instructions.md | File exists and is non-trivial (>200 words) |
| Word count acceptable | Count words | Under 2,500 words |
| Seven sections present | Check against framework | Project overview, architecture, autonomy, standards, failure handling, testing, quality gates |
| All rules have rationale | Scan for ALWAYS/NEVER without "Why:" | Zero rules without explanation |
| Quality gate command documented | Search for make check or equivalent | Command named and described |
| Compaction priority note present | Search for compaction guidance | Present |

### Section 3: Enforcement Layer

| Item | How to verify | Pass bar |
|---|---|---|
| SessionStart hook exists | Read hooks config | Present and non-trivial |
| PreToolUse hook exists | Read hooks config | Present with at least one blocking guard |
| PostToolUse hook exists | Read hooks config | Present, fires on file edits |
| Stop hook exists | Read hooks config | Present, blocks on test failure |
| stop_hook_active guard present | Read Stop hook script | Guard present to prevent infinite loop |
| Hook scripts are executable | Check file permissions | +x on all .sh files |
| settings.local.json.example exists | Check .claude/ directory | *(WARN if absent — recommended but not blocking)* |

### Section 4: Task Structure

| Item | How to verify | Pass bar |
|---|---|---|
| Implementation issue template exists | Check issue template directory | [IMPL] template with all required fields |
| Test issue template exists | Check issue template directory | [TEST] template with all required fields |
| Scaffolding issue template exists | Check issue template directory | [SCAFFOLD] template present |
| Decision issue template exists | Check issue template directory | [DECISION] template present |
| All templates have "done when" field | Read each template | Explicit acceptance criteria in every template |
| All templates have out-of-scope field | Read IMPL template | Prevents scope creep |

### Section 5: Scaffolding

| Item | How to verify | Pass bar |
|---|---|---|
| Directory structure matches spec | Compare spec file list to actual dirs | All spec-specified directories exist |
| Package manager configured | Check pyproject.toml / package.json | Dependencies installable |
| Linter configured | Check ruff.toml / .eslintrc / equivalent | Config file exists |
| Type checker configured | Check mypy.ini / tsconfig.json / equivalent | Strict mode enabled |
| Quality gate command works | Run or dry-run make check | Exits 0 on empty/stub codebase |
| Test framework configured | Check pytest.ini / jest.config / equivalent | Config exists |
| Test directory structure exists | Check tests/ or __tests__/ | unit/, contract/, integration/ (or equivalent) |
| Test infrastructure exists | Check conftest.py / test helpers | Mocks and fixtures for external dependencies |
| CI pipeline exists | Check .github/workflows/ or equivalent | Mirrors local quality gates |
| AGENTS.md exists | Check repo root or docs/ | Present for projects with multiple agent roles |

### Section 6: Prompt Templates (LLM projects only)

| Item | How to verify | Pass bar |
|---|---|---|
| Prompt template file exists | Look for prompts.py or equivalent | File exists in LLM module directory |
| Pass 1 prompt defined | Read prompt file | System + user template present as constants |
| Pass 2 prompt defined | Read prompt file | Synthesis prompt present as constant |
| Prompts are constants, not inline | Search for prompt construction in business logic | No f-string prompt construction in non-prompt files |

*Skip Section 6 if the project does not use LLMs.*

---

## Output Format

```
PRE-IMPLEMENTATION AUDIT REPORT
════════════════════════════════════════════════════════════
Project: [name]
Audited: [date]
Auditor: audit-pre-impl skill

RESULTS BY SECTION
────────────────────────────────────────────────────────────

Section 1: Spec Readiness              [PASS / FAIL / PARTIAL]
  ✓ Spec score ≥ 7.0          — [score if found, or "not documented"]
  ✓ Ambiguities resolved       — [finding]
  ✗ Data models defined        — [what's missing]
  ✓ Failure modes specified    — [finding]

Section 2: Agent Briefing Document     [PASS / FAIL / PARTIAL]
  ✓ Briefing doc exists        — CLAUDE.md, [word count] words
  ✓ Word count acceptable      — [count] / 2500 limit
  ✗ Seven sections present     — Missing: [which sections]
  ...

Section 3: Enforcement Layer           [PASS / FAIL / PARTIAL]
  ...

Section 4: Task Structure              [PASS / FAIL / PARTIAL]
  ...

Section 5: Scaffolding                 [PASS / FAIL / PARTIAL]
  ...

Section 6: Prompt Templates            [PASS / FAIL / PARTIAL / N/A]
  ...

SUMMARY
────────────────────────────────────────────────────────────
Total items checked: XX
  PASS:    XX
  FAIL:    XX
  WARN:    XX
  UNKNOWN: XX

VERDICT: GO ✓ / NO-GO ✗ / CONDITIONAL GO ⚠
(No-go if any Section 1–5 item is FAIL. Conditional go if only WARNs remain.)

REQUIRED ACTIONS BEFORE SPRINT 1
────────────────────────────────────────────────────────────
[Numbered list of FAIL items only, ordered by section.
Each item: what's missing, what file/command to create/run to fix it.]

RECOMMENDED ACTIONS (non-blocking)
────────────────────────────────────────────────────────────
[Numbered list of WARN items. Can be addressed in sprint 1 or later.]
════════════════════════════════════════════════════════════
```

## Verdict Rules

- **GO:** All items in Sections 1–5 are PASS or WARN. Section 6 complete if LLM project.
- **CONDITIONAL GO:** Only WARNs remain in Sections 1–5 (no hard FAILs). All FAILs are
  in Section 6 only. Document which WARNs you are carrying into sprint 1 and why.
- **NO-GO:** Any FAIL in Sections 1–5. Do not begin feature development until resolved.

The most common NO-GO causes, in order:
1. Spec not scored (cannot verify readiness)
2. Quality gate command not working on empty codebase
3. Stop hook missing or missing stop_hook_active guard
4. Issue templates missing "done when" field
5. Test infrastructure (mocks/fixtures) not created before feature tickets
