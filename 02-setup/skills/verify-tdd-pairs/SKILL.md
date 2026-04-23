---
name: verify-tdd-pairs
description: >
  Verify that every [IMPL] issue has a corresponding closed [TEST] issue and a
  matching test file in the repository. Use when someone asks to "verify TDD pairs",
  "check test coverage for issues", "are all impl tickets paired with tests?",
  "run the TDD audit", or "which impl issues are missing tests?". Also useful at
  sprint planning to confirm the board is correctly structured before assigning
  work to agents. Requires gh CLI access to query GitHub Issues.
---

# TDD Pairing Verifier

Verify the [TEST] → [IMPL] pairing discipline is intact across all open and
recent issues. Catch implementation work that began without a test file.

## When to Use

- At the start of each sprint (before assigning [IMPL] issues to agents)
- When a module is complete (verify test file matches implementation)
- When reviewing a PR (verify the paired [TEST] issue was closed first)
- Periodically as a project health check

## Required Tools

Uses `gh` CLI to query GitHub Issues. Verify it's available:
```bash
gh auth status
```

If not authenticated or gh is unavailable, perform a manual audit using the
issue list from the project board and file system inspection only.

## Audit Process

### Step 1: Gather all [IMPL] issues

```bash
gh issue list --label "implementation" --state all --limit 100 \
  --json number,title,state,body,closedAt
```

Also check for issues with `[IMPL]` in the title regardless of label:
```bash
gh issue list --state all --limit 100 --json number,title,state,body \
  | jq '[.[] | select(.title | startswith("[IMPL]"))]'
```

### Step 2: For each [IMPL] issue, find its paired [TEST] issue

Look for the paired issue number in:
- The `[IMPL]` issue body (field: "Paired [TEST] Issue")
- Issue comments referencing a test issue
- The issue title (e.g., `[IMPL] pre_filter` → look for `[TEST] pre_filter`)

```bash
gh issue view [ISSUE_NUMBER] --json body,comments
```

### Step 3: Verify the paired [TEST] issue is CLOSED

A [TEST] issue must be closed (tests written and confirmed failing) before
the [IMPL] issue should have been opened. An open [TEST] paired with an open
or closed [IMPL] is a TDD violation.

```bash
gh issue view [TEST_ISSUE_NUMBER] --json state,closedAt
```

### Step 4: Verify the test file exists in the repository

The [TEST] issue body should specify the test file path. Check it exists:
```bash
ls [test_file_path]
```

If the [IMPL] issue is closed (implementation done), also verify:
- The test file has tests (not just placeholder)
- `make test-unit` (or equivalent) passes for this module

### Step 5: Spot-check implementation files for tests

For each module in the project source directory, verify a corresponding test file
exists in `tests/`. **Customize `[src_dir]` to match your project's source directory**
(e.g., `radar/`, `src/`, `mypackage/`):

```bash
# CUSTOMIZE: replace [src_dir] with your project's source directory
find [src_dir]/ -name "*.py" -not -name "__init__.py" | sort
find tests/ -name "test_*.py" | sort
```

Flag source files with no corresponding test file.

---

## Output Format

```
TDD PAIRING AUDIT REPORT
════════════════════════════════════════════════════════════
Project: [name]
Audited: [date]
Issues checked: XX [IMPL] issues

PAIRING STATUS
────────────────────────────────────────────────────────────
Issue  Title                        [TEST]  TEST State  File    Status
─────────────────────────────────────────────────────────────────────
#42    [IMPL] pre_filter            #41     CLOSED ✓    ✓       PAIRED ✓
#44    [IMPL] deduplicator          #43     OPEN   ✗    ✓       VIOLATION ✗
#46    [IMPL] excerpt_fetcher       —       —           ✗       NO TEST ✗
#48    [IMPL] summarizer            #47     CLOSED ✓    ✓       PAIRED ✓

SOURCE FILES WITHOUT TEST FILES
────────────────────────────────────────────────────────────
radar/processing/truncator.py     → no tests/unit/test_truncator.py
radar/llm/prompts.py              → no tests/unit/test_prompts.py
[or "All source files have corresponding test files ✓"]

VIOLATIONS (TDD protocol broken)
────────────────────────────────────────────────────────────
Issue #44 [IMPL] deduplicator:
  Paired [TEST] #43 is still OPEN — [IMPL] should not have been opened yet.
  Action: Close [IMPL] #44, complete [TEST] #43 first.

Issue #46 [IMPL] excerpt_fetcher:
  No paired [TEST] issue found.
  Action: Create [TEST] issue, write failing tests, then reopen [IMPL].

SUMMARY
────────────────────────────────────────────────────────────
Total [IMPL] issues:     XX
  Correctly paired:      XX ✓
  TDD violations:        XX ✗
  No test issue:         XX ✗

Source files without tests: XX

TDD HEALTH: GOOD ✓ / AT RISK ⚠ / BROKEN ✗
  GOOD:    Zero violations
  AT RISK: 1–2 violations, being addressed
  BROKEN:  3+ violations, or pattern of skipping [TEST] step
════════════════════════════════════════════════════════════
```

## Violation Severity

Not all violations are equal:

**Critical — stop work:**
- [IMPL] open with [TEST] also open (implementation running without red tests)
- [IMPL] closed with no test file (code shipped without tests)

**High — fix this sprint:**
- [IMPL] issue has no paired [TEST] issue at all
- Source file exists with no corresponding test file

**Medium — track:**
- [TEST] issue closed but test file is empty/placeholder
- Test file exists but no tests cover failure modes

## Remediation Guidance

For each violation type, suggest the specific action:

| Violation | Remediation |
|---|---|
| [IMPL] open, [TEST] open | Pause [IMPL] work. Complete [TEST] first. Confirm tests fail. |
| [IMPL] open, no [TEST] | Create [TEST] issue using template. Write tests. Confirm red. |
| [IMPL] closed, no tests | Create retroactive test file. Do not close gap with [SCAFFOLD] issue. `[SCAFFOLD]` is for Phase 0 infrastructure (before feature development). Retroactive test coverage is a feature-phase concern and should use a `[TEST]` issue. |
| Source file, no test file | Create [TEST] issue even if module is "done" — add tests before next change. |
