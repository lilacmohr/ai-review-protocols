---
name: retro
description: >
  Run a post-IMPL retro to identify what should be encoded into setup artifacts
  before the next ticket. Use when asked to "run the retro", "do the retro",
  "what should we encode from this ticket?", "post-impl retro", or "retro on PR #N".
  Also triggers after a review-tdd-green run finds gaps. The goal: surface 3–5
  specific candidate additions to CLAUDE.md, issue templates, or hooks — not a
  comprehensive audit, just what's worth making permanent.
argument-hint: 'GitHub PR number or URL (e.g. 42 or https://github.com/owner/repo/pull/42)'
---

# Post-IMPL Retro

Surface what this ticket revealed that should be encoded before the next one.
The retro is not a review — the PR is already merged. The question is: what did
we learn that the next agent session should inherit?

Output is a short candidate list. The human decides what gets encoded.

---

## Inputs

Gather in parallel:

1. **IMPL PR** — `GET /pull/{n}` for description, comments, and review thread
2. **DECISION issues** — any `[DECISION]` issues opened during this ticket
   (look for links in the PR description or issues mentioning the PR number)
3. **CLAUDE.md** — current agent briefing document
4. **review-tdd-green output** — if the green-phase review ran, read its comment
   on the PR (look for a review comment with the "## Review" header)

If the PR number is not provided, ask for it before proceeding.

---

## What to Look For

Work through five categories. For each, look for evidence in the inputs above.

### 1. Autonomous decisions the agent made that should be explicit rules

Look in:
- PR description: "Interface decisions made" section
- PR comments: any correction the human left, any `DECISION NEEDED` thread
- DECISION issues: what was the structural choice and how was it resolved?

Ask: is the resolved decision now encoded in CLAUDE.md? If not, it will be
re-litigated next ticket.

**Flag:** Decisions that were resolved by human correction and are not in CLAUDE.md.

### 2. Failure modes that appeared but aren't in the failure handling table

Look in:
- PR diff: any new `except`, `if error`, `raise`, or exit-code-handling code
- review-tdd-green output: gaps flagged in "Spec correctness" or "What tests didn't catch"
- CLAUDE.md failure handling section: does it cover what the implementation handles?

**Flag:** Failure modes handled in code that aren't documented in CLAUDE.md's
failure handling section.

### 3. Test gaps that would recur on the next module

Look in:
- review-tdd-green output: section 4 ("What the tests didn't catch")
- PR comments: any assertions added or strengthened post-review

Ask: is the gap structural (e.g., "we never test log calls") or one-off? Structural
gaps belong in CLAUDE.md testing requirements or the `[TEST]` template's Done When
checklist. One-off gaps don't.

**Flag:** Recurring patterns only — not one-time edge cases specific to this module.

### 4. Hook friction — fired incorrectly, didn't fire when it should have, or needed bypass

Look in:
- PR comments or description: any mention of hooks, `--no-verify`, or hook failures
- PR diff: any changes to `.claude/` or hook scripts

**Flag:** Any hook that needed manual intervention. Note whether it fired too
aggressively (tune condition) or didn't fire when it should have (add check).

### 5. Spec ambiguity that forced a mid-ticket decision

Look in:
- DECISION issues: the ambiguity that was resolved
- PR description: "Spec section referenced" field

Ask: has the spec been updated with the resolution? Has the decision been added to
the Decision Register? If not, the next agent will hit the same fork.

**Flag:** Spec gaps that were resolved in DECISION issues but not yet patched in SPEC.md.

If the decision was Level 1 or 2 (it will constrain someone else's options) and no
Decision Record exists, prompt the engineer to run the
[`capture-decision`](../capture-decision/SKILL.md) skill now. Note that the session
window is closed — the record will be narrated from memory rather than from live
context. Flag this in the record's header:

```
**Note:** Generated post-session from memory. Session context was not available
at time of capture. Treat assumptions and ruled-out options with extra scrutiny.
```

---

## Output Format

```
RETRO CANDIDATES — PR #N: [title]
════════════════════════════════════════════════════════════

1. AUTONOMOUS DECISIONS TO ENCODE
────────────────────────────────────────────────────────────
[Candidate or "Nothing to encode — no unresolved decisions found."]

Each candidate:
  → Destination: CLAUDE.md — Autonomy Boundary
  → What to add: [specific rule, with Why: explanation]

2. FAILURE MODES TO DOCUMENT
────────────────────────────────────────────────────────────
[Candidate or "Nothing to encode — failure handling table appears complete."]

  → Destination: CLAUDE.md — Failure Handling table
  → What to add: [failure mode, expected behavior, exit code if applicable]

3. TEST REQUIREMENTS TO ENCODE
────────────────────────────────────────────────────────────
[Candidate or "Nothing to encode — no recurring test gaps found."]

  → Destination: CLAUDE.md — Testing Requirements  OR  [TEST] template Done When
  → What to add: [specific requirement]

4. HOOK ADJUSTMENTS
────────────────────────────────────────────────────────────
[Candidate or "Nothing to encode — hooks fired correctly."]

  → Destination: .claude/hooks/[script]
  → What to change: [specific condition or check]

5. SPEC PATCHES NEEDED
────────────────────────────────────────────────────────────
[Candidate or "Nothing to encode — no open spec gaps found."]

  → Destination: SPEC.md + Decision Register
  → What to add: [the decision that was made and why]
  → If no Decision Record exists: prompt capture-decision (post-session fallback)

────────────────────────────────────────────────────────────
TOTAL CANDIDATES: N
(Human reviews and decides what gets encoded. Discard anything that was
one-off or already covered elsewhere.)
════════════════════════════════════════════════════════════
```

---

## What Not to Flag

- Implementation details that are specific to this module and won't recur
- Style fixes that a linter already catches
- Issues the review-tdd-green skill already flagged and the agent fixed in this PR
- Anything already present in CLAUDE.md (verify before flagging)

The goal is a short list a human can act on in 15 minutes, not a comprehensive
audit. Three high-signal candidates are better than ten marginal ones.

---

## After the Retro

For each candidate the human decides to encode:

| Destination | Action |
|---|---|
| CLAUDE.md | Open PR or edit directly — team decides based on governance model |
| `[TEST]` template Done When | Edit `.github/ISSUE_TEMPLATE/1_test.yml` |
| `[IMPL]` template | Edit `.github/ISSUE_TEMPLATE/2_impl.yml` |
| Hook script | Edit `.claude/hooks/[script]` — run `review-hooks` skill after |
| SPEC.md + Decision Register | Update spec section + append to Decision Register table |

The retro is complete when the candidates list has been worked through and
dispositioned (encoded or explicitly discarded with reason).
