---
name: review-issue
description: >
  Evaluate a drafted GitHub Issue for completeness before assigning it to an agent.
  Use when someone asks to "review this issue", "is this issue ready for an agent?",
  "check if this ticket is complete", or "review before I open this". Also triggers
  when someone pastes an issue draft and asks for feedback, or when a [TEST], [IMPL],
  [SCAFFOLD], or [DECISION] issue is being finalized. The core question: could an
  agent open this issue, read only its contents and the referenced spec section,
  and begin work without a follow-up conversation?
---

# Issue Template Completeness Checker

Evaluate a drafted issue for agent-readiness. Catch gaps before the issue is
assigned — not after an agent session produces incomplete or misdirected work.

## When to Use

- Before opening any [TEST], [IMPL], [SCAFFOLD], or [DECISION] issue
- When reviewing a teammate's draft issue
- As a Stop hook prompt to check issues drafted during a session

## The Core Test

**Could an agent open this issue, read only its contents and the referenced
spec sections, and begin work without a follow-up conversation?**

If yes: the issue is agent-ready.
If no: find what's missing and flag it.

## Evaluation by Issue Type

Determine the issue type from the title prefix ([TEST], [IMPL], [SCAFFOLD], [DECISION])
or from context. Apply the appropriate checklist.

---

### [TEST] Issue Checklist

| Field | Required? | Quality bar |
|---|---|---|
| Module path | Required | Exact file path, not a module name |
| Test file path | Required | Where the test file will be created |
| Spec reference | Required | Specific section (§3.2), not "the spec" |
| Pipeline context | Required | Stage, input type, output type stated |
| Happy path tests | Required | ≥2 specific cases with inputs and expected outputs |
| Failure mode tests | Required | One test per failure mode from spec §3.7 or N/A with explanation |
| Empty input test | Required | Explicitly listed (all filter stages must return [], never raise) |
| Fixtures required | Required | Named specifically or "none needed" |
| Mocking strategy | Required | What's mocked and how, or "pure logic, no mocking" |
| Done when | Required | Tests confirmed failing (not just written) |
| Paired [IMPL] issue | Optional at creation | Should be added before [TEST] is closed |

**[TEST]-specific red flags:**
- Happy path tests described without stating expected output
- "Failure modes: see spec" without listing them explicitly
- No mention of empty input behavior
- Done when says "tests written" rather than "tests confirmed failing"

---

### [IMPL] Issue Checklist

| Field | Required? | Quality bar |
|---|---|---|
| Module to implement | Required | Exact file path |
| Paired [TEST] issue | Required | Issue number, confirmed CLOSED |
| Test file | Required | Path to the test file to make green |
| Spec reference | Required | Specific section |
| Pipeline context | Required | Stage, input type, output type, what calls it, what it calls |
| Public interface | Required | Method signature(s) with typed parameters |
| Key behaviors | Required | Behavioral requirements (not implementation details) |
| Failure handling | Required | How this module handles each applicable failure type |
| Dependencies | Required | Internal imports listed, no unapproved packages |
| Done when | Required | make check passing + specific test file green |
| Explicitly out of scope | Required | At least 2–3 items |

**[IMPL]-specific red flags:**
- Paired [TEST] issue is still OPEN (TDD violation — do not open)
- Public interface not typed (agents will invent their own signatures)
- No "explicitly out of scope" section (scope creep will happen)
- Done when doesn't reference the paired test file specifically
- Failure handling is "see CLAUDE.md" without module-specific behavior

---

### [SCAFFOLD] Issue Checklist

| Field | Required? | Quality bar |
|---|---|---|
| Category | Required | One of: repo structure, tooling, CI/CD, agent infra, test infra, config, docs |
| Deliverables | Required | Exact file paths to create or modify |
| Constraints | Required | Hard requirements (Python version, tool choices) |
| Done when | Required | Checkable conditions (command runs, file exists, exit code) |

**[SCAFFOLD]-specific red flags:**
- Deliverables list bundles multiple unrelated files (split into separate issues)
- Done when says "set up the environment" — not checkable
- No constraints stated (agent will make arbitrary choices)

---

### [DECISION] Issue Checklist

| Field | Required? | Quality bar |
|---|---|---|
| Blocking issue | Required | Issue number of blocked [TEST] or [IMPL] |
| Spec reference | Required | Where the spec is silent or ambiguous |
| Decision statement | Required | One sentence, specific enough to have a binary answer |
| Options | Required | ≥2 options with concrete consequences each |
| Recommendation | Required | Agent or author recommendation with reasoning |
| Resolution | Optional at creation | Filled in by owner when decided |

**[DECISION]-specific red flags:**
- Decision statement is too broad ("how should we handle errors?")
- Options don't state consequences — they just list approaches
- No recommendation (forces owner to do all the work)

---

## Output Format

```
ISSUE REVIEW
════════════════════════════════════════════════════════════
Issue: [title]
Type:  [TEST / IMPL / SCAFFOLD / DECISION]

FIELD COMPLETENESS
────────────────────────────────────────────────────────────
✓ [Field name]     — [brief finding]
✗ [Field name]     — MISSING: [what's needed]
⚠ [Field name]     — PRESENT but weak: [specific problem]

AGENT-READINESS ASSESSMENT
────────────────────────────────────────────────────────────
The core test: could an agent begin work from this issue alone?

[Specific answer: yes/no and why. If no, what would the agent
get wrong or have to guess?]

REQUIRED CHANGES (must fix before opening)
────────────────────────────────────────────────────────────
[Numbered list. Each: what's missing, what to add, example if helpful]

SUGGESTED IMPROVEMENTS (optional)
────────────────────────────────────────────────────────────
[Items that would improve clarity but aren't blocking]

VERDICT: AGENT-READY ✓ / NOT READY ✗ / NEARLY READY ⚠
════════════════════════════════════════════════════════════
```

## The Most Impactful Gaps (in order)

Across all issue types, these gaps cause the most agent session failures:

1. **No "explicitly out of scope"** — agents implement adjacent functionality
2. **Vague done when** — agents stop when they feel done, not when gates pass
3. **No typed public interface** — agents invent incompatible method signatures
4. **Missing failure mode tests** ([TEST] issues) — failure handling never gets tested
5. **Paired [TEST] still open** ([IMPL] issues) — TDD protocol violated at the start
