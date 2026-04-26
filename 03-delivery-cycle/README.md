# 03 — Delivery Cycle

The repeating loop: **red → green → retro**. One iteration per feature or module.

```
[TEST] ticket  →  test PR review  →  [IMPL] ticket  →  impl PR review  →  retro
  (write         (what's missing?)    (make it         (best impl?        (update
 failing tests)                       green)          spec correct?)     artifacts)
```

The loop is not optional. Skipping the test phase produces implementations you can't
refactor safely. Skipping the retro means the same friction recurs on every subsequent
ticket.

---

## The Three Phases

### Red — Write Failing Tests

Open a `[TEST]` issue. The agent writes a test file. Every test must FAIL — not ERROR.

**FAIL vs ERROR matters:** A test that ERRORs means pytest couldn't even collect it —
the module doesn't exist yet. Create a minimal stub (empty functions/classes with correct
signatures, no logic) so that tests collect as FAIL. Stubs are infrastructure, not
implementation.

**Before closing the [TEST] issue:**
- Confirm all tests show FAILED in `pytest -v` output
- Open any spec ambiguities as `[DECISION]` issues rather than silently resolving them
  in test code (the test file is the executable spec — decisions baked in without review
  are invisible to future agents and engineers)
- Link the paired `[IMPL]` issue

**Test PR review — the second set of eyes:**

Before the IMPL ticket opens, run the `review-tdd-red` skill on the test PR. This
asks: *will this test suite catch every bug the spec protects against?*

A common failure mode: tests that would pass despite a buggy implementation — vague
assertions (`assert result is not None`), mocks that don't verify args, missing
edge cases. Finding these before implementation is much cheaper than finding them after.

See `skills/review-tdd-red/SKILL.md` for the full checklist.

---

### Green — Make Tests Pass

Open the `[IMPL]` issue only after the `[TEST]` issue is closed and tests are confirmed
failing. The agent implements until all tests are green. **The agent does not modify
the test file.**

If a test seems wrong, the agent raises a `DECISION NEEDED` comment on the issue rather
than bypassing the test. The test file is the contract.

**Implementation PR review — beyond "tests pass":**

Tests passing is a necessary condition, not a sufficient one. Run the `review-tdd-green`
skill on the IMPL PR. It asks three questions:
1. Is this the simplest correct implementation (or did the agent over-engineer)?
2. Does the implementation actually match the spec, or does it just satisfy the tests?
3. What did the tests not catch?

The third question is the most valuable. A test suite that was complete before
implementation may still leave gaps — particularly around logging, exit codes, and
side-effects on failure paths.

See `skills/review-tdd-green/SKILL.md` for the full checklist.

---

### Retro — Update Setup Artifacts

This is the highest-leverage practice in the workflow.

After each IMPL PR merges, run a 20-minute retro. Review what friction occurred in
this iteration and update the setup artifacts that encode the lessons.

**Probing questions:**

- Did the agent make a decision you had to correct? → Add it to CLAUDE.md as an
  explicit rule, or to the `[IMPL]` template's "Explicitly Out of Scope" guidance.
- Did the agent miss a failure mode? → Add it to the failure handling table in CLAUDE.md.
- Did a hook fail or fire unnecessarily? → Tune the hook.
- Did an ambiguity force a `[DECISION]` issue mid-ticket? → Patch the spec and add
  the decision to the Decision Register.
- Did the test file miss edge cases found by the impl review? → Add to CLAUDE.md
  testing requirements or the `[TEST]` template's Done When checklist.
- Was there structural debt (mock chains too deep, logic coupled to SDK shape)? → Open
  a `[REFACTOR]` issue.

**Retro outputs — direct to artifacts:**

| Observation | Artifact to update |
|---|---|
| Agent made a bad autonomous decision | CLAUDE.md — Autonomy Boundary |
| Agent missed a failure mode | CLAUDE.md — Failure Handling table |
| Test file had systematic gaps | CLAUDE.md — Testing Requirements OR `[TEST]` Done When |
| Spec ambiguity recurred across tickets | SPEC.md + Decision Register |
| Hook fired incorrectly | `.claude/hooks/` |
| Structural debt pattern | `[REFACTOR]` issue |

The retro is where the system learns. Without it, every ticket starts from the same
baseline. With it, each iteration makes the next one cheaper.

---

## DECISION Issues

When an agent encounters a spec ambiguity that forces a structural choice — different
data model shapes, different error exit codes, different public interface signatures —
it should open a `[DECISION]` issue rather than silently resolving it.

This is not a failure. It's a signal of spec quality.

A decision issue contains:
```
DECISION NEEDED: [one-line description]
Options:
  A) [option] — [consequence]
  B) [option] — [consequence]
Spec reference: [section]
Recommendation: [agent's recommendation and why]
```

The human resolves it, updates the spec, and the agent continues. The decision is
recorded in the PR description under "Interface decisions made."

For decisions that will constrain future options beyond this ticket — a service
boundary choice, a consistency model, a data contract — run the
[`capture-decision`](skills/capture-decision/SKILL.md) skill before closing the
session to generate a formal Decision Record. Add a row to the project's
[Decision Register](../04-decision-records/templates/decision-register.md).

---

## Issue Taxonomy

| Issue type | Opens when | Closes when |
|---|---|---|
| `[TEST]` | Starting a module | Test file is red + paired `[IMPL]` is linked |
| `[IMPL]` | `[TEST]` is closed | All tests green + `make check` passes |
| `[DECISION]` | Spec ambiguity blocks progress | Human resolves + spec is updated |
| `[REFACTOR]` | Structural debt identified (in retro or review) | `make check` passes before AND after |
| `[SCAFFOLD]` | Infrastructure needed (config, models, CI) | Scaffolding merged |

---

## Skills

| Skill | Use when |
|---|---|
| [`review-tdd-red`](skills/review-tdd-red/SKILL.md) | Test PR is open — find missing tests before IMPL |
| [`review-tdd-green`](skills/review-tdd-green/SKILL.md) | IMPL PR is open — verify correctness and implementation quality |
| [`retro`](skills/retro/SKILL.md) | IMPL PR is merged — surface what should be encoded before the next ticket |
| [`verify-tdd-pairs`](skills/verify-tdd-pairs/SKILL.md) | Audit that every TEST ticket has a paired IMPL ticket (repo health check) |
| [`capture-decision`](skills/capture-decision/SKILL.md) | End of session — narrate a Level 1 or 2 decision into a Decision Record before closing |

---

## Connecting Back to Setup

The delivery cycle creates feedback for the setup chapter. Each retro is an opportunity
to improve the CLAUDE.md, hooks, and issue templates for the next iteration.

Over time, this means:
- Fewer `[DECISION]` issues (clearer spec and autonomy boundary)
- Fewer retro findings (fewer recurring patterns — they've been encoded)
- Faster IMPL tickets (agent makes better decisions from the start)

The system is designed to get cheaper to run over time, not more expensive.
