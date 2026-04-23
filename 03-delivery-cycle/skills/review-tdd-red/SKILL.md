---
name: review-tdd-red
description: >
  Review a GitHub PR that adds a suite of failing (red) unit or integration tests.
  Use when asked to "review this test PR", "review this red PR", "check test coverage
  for this PR", or "is this test suite complete?". Also triggers when a [TEST] PR link
  is shared and the request is to find missing tests or suggest revisions. The core
  question: will this test suite catch every bug the spec protects against — before the
  implementation is written?
argument-hint: 'GitHub PR URL (e.g. https://github.com/owner/repo/pull/123)'
---

# Review a TDD Red-Phase PR

A [TEST] PR adds a failing test suite for a module before any implementation exists.
The review job is to find what's missing — tests that would pass despite a buggy
implementation, tests that assert the right thing but with insufficient precision,
and edge cases that spec requires but aren't covered.

## When to Use

- When a `[TEST]` PR (or any red-phase PR) is opened for review
- When asked "are there any missing tests?" on a test-only PR
- As a pre-merge gate before the paired `[IMPL]` issue is opened

---

## Process

### Step 1 — Gather inputs

Collect in parallel:

1. **PR diff** — `GET /pull/{n}/files` to see every test added
2. **Linked issue** — the `[TEST]` issue referenced in the PR description; read the
   full test plan (happy paths, failure modes, interface/contract tests, mocking strategy)
3. **Spec section** — load the spec section(s) cited in the issue (`SPEC.md §X.Y`)

If no issue is linked, the PR description and any referenced spec sections substitute.

### Step 2 — List every test in the PR

Extract all `def test_*` names. Map each one back to the test plan and spec.

### Step 3 — Apply the checklist

Work through the five categories below. Flag every gap found.

### Step 4 — Post a comment

If gaps exist, post a `gh pr comment <n>` with:
- A numbered list of gaps
- For each gap: a one-sentence description of what's missing and why it matters,
  plus a minimal code skeleton that shows the shape of the test needed
- Do NOT write "looks good" if even one gap was found

If no gaps exist, say so explicitly and state why you're confident.

---

## Checklist

### 1. Test plan coverage

- [ ] Every item under **Happy Path Tests** in the linked issue has a corresponding test
- [ ] Every item under **Failure Mode Tests** has a corresponding test
- [ ] Every item under **Interface / Contract Tests** has a corresponding test
- [ ] All subcommands/variants are covered (e.g. if there are 5 cache operations,
      there are tests for all 5 — not just the first two)

### 2. Empty and boundary inputs

Any stage that filters or transforms a list must be tested with an empty input:

- [ ] `[]` in → `[]` out (no raise, no crash)
- [ ] Single-item list (not just multi-item) where the stage has logic that reads
      "all items" or aggregates
- [ ] All-fail case: every item fails → system produces valid (possibly empty) output

### 3. Per-item failure isolation

If a stage processes a list of items, a failure in one item must not stop the others.

- [ ] Test passes a list where one item raises/fails and asserts the rest are returned
- [ ] Log assertion: the failed item is logged at WARN or ERROR (not silently dropped)

### 4. Assertion precision

Tests that pass despite wrong behavior are useless.

- [ ] `mock.called` → upgrade to `mock.assert_called_once_with(exact_args)`
- [ ] `timeout=ANY` or `headers=ANY` → assert the spec-required value explicitly
- [ ] Return value checks: assert a specific field/value, not just `assert result is not None`
- [ ] Side-effects that must NOT happen in failure paths: `mock.assert_not_called()`
      must be present (not just absent from the test)

### 5. State invariants and fatal paths

For any module that has a spec-described invariant around ordering or atomicity:

- [ ] The invariant is tested explicitly, not just implied by the happy path
- [ ] Fatal paths: every fatal condition produces the required artifact
      (digest file, log entry, exit code) — not just the right return value
- [ ] Side-effects that should only happen after a successful outcome are tested
      on both the success path AND the failure path (success: called; failure: not called)

### 6. Fixture and mock correctness

- [ ] Canned responses for parser modules use the exact strings the parser expects
      (heading text, field names, delimiters) — not an approximation
- [ ] Mocks are patched at the import site the module under test uses
      (`module.__main__.Foo`, not `module.Foo` if the test imports from `__main__`)
- [ ] `tmp_path`-based config files contain enough fields to pass validation

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

<One sentence: what's missing and which spec requirement it covers.>

**Add:**
```python
def test_<descriptive_name>(...) -> None:
    """<what it verifies>"""
    ...  # minimal skeleton
```
```

---

## Project Overlays

Load a project-specific overlay when reviewing PRs for a known codebase.
The overlay adds module-specific invariants and known recurring failure classes.

| Project | Overlay |
|---|---|
| ai-radar | [references/ai-radar-checklist.md](./references/ai-radar-checklist.md) |
