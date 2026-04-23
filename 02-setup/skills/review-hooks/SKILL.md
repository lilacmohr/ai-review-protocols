---
name: review-hooks
description: >
  Audit the Claude Code hook configuration (or equivalent enforcement layer) for
  completeness, correctness, handler type appropriateness, and performance risks.
  Use when someone asks to "review hooks", "audit the enforcement layer", "check
  hook config", "are my hooks set up correctly?", or "is my settings.json right?".
  Also triggers on: editing .claude/settings.json, adding a new hook script, or
  asking whether a hook should use command vs prompt vs agent type.
---

# Hook Configuration Auditor

Evaluate the enforcement layer for completeness, correctness, and handler type fit.
Catch configuration mistakes before they cause silent failures or agent loops.

## Inputs

Read in order:
1. `.claude/settings.json` — the hook wiring
2. All scripts in `.claude/hooks/` — the hook implementations
3. `CLAUDE.md` — to cross-reference rules that should be enforced

## The Four-Layer Check

Every project's enforcement layer should cover all four lifecycle layers:

| Layer | Event | Purpose | Blocking? |
|---|---|---|---|
| Context | SessionStart | Inject current project state | No |
| Prevention | PreToolUse | Block hard-to-undo violations | Yes |
| Correction | PostToolUse | Lint/format/typecheck per file edit | Soft |
| Completion gate | Stop | Full test suite must pass | Yes |

Flag any missing layer. A project with no Stop hook has no completion gate —
the agent can declare "done" while tests are failing.

## Per-Hook Checks

### SessionStart
- [ ] Injects useful context (branch, test status, task type, recent changes)
- [ ] Does not block (exit 0 always)
- [ ] Output uses `additionalContext` JSON field, not raw stdout text

### PreToolUse
- [ ] Matcher covers `Bash` AND file-write tools (`Write|Edit|MultiEdit`)
- [ ] Blocks hard-to-undo operations (destructive commands, unapproved packages)
- [ ] Uses `hookSpecificOutput.permissionDecision` (not deprecated top-level `decision`)
- [ ] Deny responses include a clear reason explaining what to do instead
- [ ] Not over-blocking — style issues belong in PostToolUse, not here

### PostToolUse
- [ ] Matcher targets file-write tools (`Write|Edit|MultiEdit`)
- [ ] Runs linter on modified file only (not whole codebase — too slow)
- [ ] Exits 1 (non-blocking) on failure, not 2 (blocking)
  - **Note:** In Claude Code, PostToolUse exit 1 is non-blocking by design — Claude
    sees the output and self-corrects. Exit 2 is blocking (same as Stop hook). Use
    exit 1 here to surface feedback without forcing continuation.
- [ ] Filters to relevant file types only (no-op on non-code files)
- [ ] Fast enough to not create friction (target: <5 seconds per file)

### Stop
- [ ] `stop_hook_active` guard is present — CRITICAL
- [ ] Guard exits 0 (allows stop) when `stop_hook_active` is true
- [ ] Runs test suite on failure exit 2 (blocking), not exit 1
- [ ] Only runs if test files exist (graceful no-op on empty codebase)
- [ ] Checks for `pyproject.toml` or equivalent before running tests

## Handler Type Appropriateness

For each hook, evaluate whether the handler type matches the check complexity:

| Check type | Correct handler | Wrong handler |
|---|---|---|
| Run linter, check exit code | command (shell) | prompt or agent |
| Block specific string pattern | command (shell) | prompt or agent |
| "Does this look like a production command?" | prompt | command |
| "Do tests exist for this module?" | agent | command or prompt |
| Org-wide policy, audit log | http | command |

Flag any hook using a more complex handler than needed (adds latency) or
a simpler handler than needed (produces unreliable results).

## Performance Audit

Synchronous hooks add latency to every agent action. Estimate:
- SessionStart: acceptable up to ~3 seconds (fires once)
- PreToolUse: must be <1 second (fires before every tool call)
- PostToolUse: should be <5 seconds (fires after every file edit)
- Stop: acceptable up to ~60 seconds (fires at task completion)

Flag any hook that runs full test suite in PreToolUse or PostToolUse — that
belongs in Stop only.

Flag any hook that makes network calls in PreToolUse without a fast timeout.

## Security Check

- [ ] No hook reads or logs credentials or environment secrets to stdout
- [ ] PreToolUse denial messages don't expose internal policy details to untrusted input
- [ ] Hook scripts don't `eval` or `source` user-provided content
- [ ] `settings.local.json` is in `.gitignore` (personal overrides not committed)
- [ ] `settings.local.json.example` exists in `.claude/` to document available overrides
  *(WARN if absent — recommended, not blocking)*

---

## Output Format

```
HOOK CONFIGURATION AUDIT REPORT
════════════════════════════════════════════════════════════
Config: .claude/settings.json
Audited: [date]

FOUR-LAYER COVERAGE
────────────────────────────────────────────────────────────
✓ Context layer    — SessionStart: [script name]
✓ Prevention layer — PreToolUse:   [script name]
✓ Correction layer — PostToolUse:  [script name]
✗ Completion gate  — Stop: MISSING

PER-HOOK FINDINGS
────────────────────────────────────────────────────────────
SessionStart ([script]):
  ✓ Injects context
  ✓ Non-blocking
  ✗ Output format — using raw stdout, should use additionalContext JSON

PreToolUse ([script]):
  ✓ Covers Bash and file-write tools
  ✗ Using deprecated top-level `decision` field — use hookSpecificOutput
  ✓ Deny reasons are actionable
  ...

PostToolUse ([script]):
  ...

Stop ([script]):
  ✗ stop_hook_active guard MISSING — infinite loop risk
  ✓ Exits 2 on test failure
  ...

HANDLER TYPE ASSESSMENT
────────────────────────────────────────────────────────────
[For each hook: current type → assessment]
  PostToolUse: command ✓ — correct for deterministic lint check
  PreToolUse:  command ✓ — correct for pattern-match guards

PERFORMANCE ASSESSMENT
────────────────────────────────────────────────────────────
  SessionStart: ~Xs estimated  [OK / SLOW]
  PreToolUse:   ~Xs estimated  [OK / SLOW]
  PostToolUse:  ~Xs estimated  [OK / SLOW]
  Stop:         ~Xs estimated  [OK / acceptable]

SECURITY FINDINGS
────────────────────────────────────────────────────────────
  [Findings or "No issues found"]

CRITICAL ISSUES (fix before using hooks)
────────────────────────────────────────────────────────────
[Issues that will cause silent failures, infinite loops, or security problems]

RECOMMENDATIONS
────────────────────────────────────────────────────────────
[Non-critical improvements, ordered by impact]

VERDICT: PASS ✓ / NEEDS ATTENTION ⚠ / FAIL ✗
════════════════════════════════════════════════════════════
```

## Critical Failure Patterns

These will cause real problems — always flag as CRITICAL:

1. **Missing `stop_hook_active` guard** — causes infinite loop when tests fail
2. **Stop hook exits 1 instead of 2** — non-blocking, agent stops anyway, gate is ineffective
3. **PreToolUse using deprecated `decision` field** — may silently fail in newer versions
4. **PostToolUse running full test suite** — extreme latency on every file save
5. **Missing Stop hook entirely** — no completion gate, agent can finish with failing tests
