---
name: review-tdd-green
description: >
  Review a GitHub PR that implements a module against a pre-existing test suite.
  Use when asked to "review this impl PR", "review this green PR", "is this the
  best implementation?", or "did the tests catch everything?". Also triggers when
  an [IMPL] PR link is shared. The core questions: is this the simplest correct
  implementation, does it actually match the spec (not just the tests), and what
  did the tests fail to catch?
argument-hint: 'GitHub PR URL (e.g. https://github.com/owner/repo/pull/123)'
---

# Review a TDD Green-Phase PR

An [IMPL] PR makes a pre-existing failing test suite pass. The review job goes beyond
"tests pass" to ask three questions:

1. **Is this the best implementation?** Simplest correct code that satisfies the spec —
   no over-engineering, no under-engineering.
2. **Is it spec-correct?** Tests are necessary but not sufficient. An implementation
   can pass every test and still miss a spec requirement.
3. **What did the tests not catch?** Tests were written before implementation. Now that
   the implementation exists, gaps are visible that weren't before.

## When to Use

- When an `[IMPL]` PR (or any green-phase PR) is opened for review
- When asked "is this the right implementation?" on a code PR with existing tests
- As a pre-merge gate before the retro

---

## Process

### Step 1 — Gather inputs

Collect in parallel:

1. **PR diff** — `GET /pull/{n}/files` for the full implementation diff
2. **Test file** — the existing test file this PR makes green (from the paired [TEST] PR
   or the repo directly)
3. **Linked issue** — the `[IMPL]` issue, for key behaviors, out-of-scope list, and
   pipeline context
4. **Spec section** — the SPEC.md section(s) cited in the issue
5. **CLAUDE.md** — for code standards, failure handling conventions, and logging requirements

### Step 2 — Verify the baseline

Confirm:
- All tests in the paired test file pass
- `make check` passes (lint + typecheck + full suite)
- No tests were modified (the test file is the contract — modifications require
  explicit justification)

### Step 3 — Apply the checklist

Work through the five categories below. Flag every gap found.

### Step 4 — Post a comment

If gaps exist, post a `gh pr comment <n>` with:
- A numbered list of gaps
- For each gap: a one-sentence description of what's wrong and why it matters,
  plus a concrete suggestion (code snippet or spec reference)
- Do NOT write "looks good" if even one gap was found

If no gaps exist, say so explicitly and state why you're confident (which spec
requirements you verified and how).

---

## Checklist

### 1. Simplicity and over-engineering

The implementation should be the simplest code that correctly satisfies the spec.

- [ ] No abstraction layers introduced that aren't required by the spec or tested
- [ ] No configuration options or extensibility hooks not specified in the issue
- [ ] Private helpers extract real complexity — they don't split simple functions
      arbitrarily
- [ ] No premature optimization (caching, lazy loading, batching) not in spec
- [ ] If the implementation is significantly more complex than expected: is that
      complexity justified by the spec, or is it the agent solving a harder problem
      than was asked?

### 2. Spec correctness — beyond the tests

Tests were written before implementation. They can't test what wasn't anticipated.

- [ ] Every requirement in the linked spec section has a corresponding behavior
      in the implementation — not just the requirements that have tests
- [ ] Failure handling: every failure mode in the spec's failure handling table is
      handled explicitly in code (not just in tests)
- [ ] Exit codes: if the spec defines exit code behavior, verify it's implemented
      (not just in the Done When checklist)
- [ ] Logging: every required log breadcrumb from CLAUDE.md is present at the
      correct level with the correct fields — tests rarely assert on log calls
- [ ] Side-effects in failure paths: if the spec says "do NOT do X on failure",
      verify the code actually skips X (not just that a test asserts it)

### 3. Code standards compliance

Standards the agent should follow from CLAUDE.md — tests don't enforce these.

- [ ] All public functions have explicit return type annotations
- [ ] All log calls use structured key=value format (no f-strings in log messages)
- [ ] No bare `except` clauses or `except Exception: pass` patterns
- [ ] No untyped dicts used as data carriers between stages (typed dataclasses only)
- [ ] Module docstring present: what stage, input type, output type, key constraint
- [ ] Private helpers follow `_underscore_prefix` convention
- [ ] No new dependencies introduced without a corresponding `[DECISION]` issue

### 4. What the tests didn't catch

Now that the implementation exists, look for coverage gaps that are visible in hindsight.

- [ ] **Log assertions:** required log breadcrumbs (from CLAUDE.md) have no tests —
      verify the implementation logs them anyway
- [ ] **Fatal paths:** exit code behavior (0/1/2) — tests may not exercise the
      orchestration layer that reads the return value
- [ ] **Side-effect ordering:** if the spec requires X to happen only after Y succeeds,
      look at failure paths in the implementation to confirm X is skipped
- [ ] **Edge cases in transformation logic:** off-by-one errors, empty-string handling,
      None coercion — these are often visible only after seeing the implementation
- [ ] **Mock fidelity:** do the mocks in the test file accurately represent the
      behavior of the real dependency? (e.g., a mock that always returns a valid
      response when the real API can return 429 or empty lists)

### 5. Test file integrity

The test file is the contract — verify it wasn't touched.

- [ ] No test was deleted or commented out
- [ ] No test assertion was weakened (e.g., `assert_called_once_with` → `assert_called`)
- [ ] No fixture was changed in a way that makes tests less strict
- [ ] If any test was modified, it must be explicitly justified in the PR description
      and confirmed as a mechanical change (import paths, mock target strings) — not
      a behavioral change

---

## Posting the Review

Use this shell invocation to post a comment (avoids glob expansion issues):

```sh
gh pr comment <number> --body $'## Review\n\n...'
```

Use `$'...'` quoting. Avoid bare `**` or `*` patterns at the shell level —
they will glob-expand and cause the command to fail with "no matches found".

Each gap should follow this format:

```
### N. <Gap title>

<One sentence: what's wrong, which spec requirement or standard it violates.>

**Fix:**
[code snippet or specific change needed]
```

---

## Severity Levels

Not all gaps are equal. Categorize each finding:

| Severity | Meaning | Example |
|---|---|---|
| `[BLOCKING]` | Must fix before merge | Missing failure handling, weakened test assertion |
| `[CONCERN]` | Should fix — will cause problems | Missing required log fields, no type annotation |
| `[SUGGESTION]` | Consider fixing | Unnecessary abstraction, minor style issue |

Post blocking findings prominently. Don't bury them in a list of suggestions.

---

## Project Overlays

Load a project-specific overlay when reviewing PRs for a known codebase.
The overlay adds module-specific invariants and known recurring failure classes.

| Project | Overlay |
|---|---|
| ai-radar | [references/ai-radar-checklist.md](./references/ai-radar-checklist.md) |
