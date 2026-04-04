# Workflow: Spec / Architecture Review

<!-- 
Use this workflow when reviewing a PR that adds or modifies a spec, 
architecture document, or technical design document.

For implementation (code) PRs, use workflows/implementation-review.md instead.
-->

## When to Use This Workflow

- Adding or updating SPEC.md, ARCHITECTURE.md, or similar
- Reviewing a technical design before implementation begins
- Reviewing an ADR (Architecture Decision Record)
- Any PR where the primary artifact is a decision or design, not code

## Why Spec Review Matters

Ambiguity at spec time becomes a bug at implementation time. AI agents 
have zero tolerance for underspecification — they will make a plausible 
assumption and proceed, often silently. Resolving ambiguity before coding 
starts is the highest-leverage use of this review protocol.

## Personas to Run

Run all nine personas in independent sessions (no persona should read 
another's comments before posting):

| # | Persona | File | Recommended Model | Effort | Primary Value |
|---|---|---|---|---|---|
| 1 | Architect | `personas/architect.md` | Opus | high | Module boundaries, interfaces, data flow |
| 2 | Skeptic | `personas/skeptic.md` | Opus | high | Unstated assumptions, optimistic scenarios |
| 3 | Security | `personas/security.md` | Sonnet | medium | Secrets, OAuth scope, data handling |
| 4 | OSS Adoptability | `personas/oss-adoptability.md` | Sonnet | medium | Setup realism, config clarity, docs gaps |
| 5 | MVP Scope | `personas/scope.md` | Sonnet | medium | Scope creep, over-engineering, MVP integrity |
| 6 | Domain Expert | `personas/domain-expert.md` | Opus | high | Library/API gotchas, real-world data quality |
| 7 | Legal & Compliance | `personas/legal-compliance.md` | Sonnet | medium | Content rights, ToS, data retention |
| 8 | Operator | `personas/operator.md` | Sonnet | medium | Day-two ops, failure visibility, recovery |
| 9 | Test Strategy | `personas/test-strategy.md` | Sonnet | medium | Testability, verification coverage |

After all nine have posted:

| # | Persona | File | Recommended Model | Effort |
|---|---|---|---|---|
| 6 | Synthesis | `protocol/synthesis-agent.md` | Opus | high |

## How to Build Each Reviewer Prompt

At **Level 1** (manual), combine files by hand:

1. Open `protocol/base-instructions.md` — copy the full contents
2. Open your chosen persona file — copy the full contents
3. Paste both together (base first, then persona) into a new Claude Code session
4. Replace `$PR_NUMBER` with your actual PR number
5. Set your model: `/model opus` or `/model sonnet` per the table above
6. Set effort: `/effort high` or `/effort medium`
7. Send

At **Level 2** (slash command), run:
```
/review-pr $PR_NUMBER architect
/review-pr $PR_NUMBER skeptic
/review-pr $PR_NUMBER security
/review-pr $PR_NUMBER oss-adoptability
/review-pr $PR_NUMBER scope
/review-pr $PR_NUMBER domain-expert
/review-pr $PR_NUMBER legal-compliance
/review-pr $PR_NUMBER operator
/review-pr $PR_NUMBER test-strategy
```
Then after all nine have posted:
```
/review-pr $PR_NUMBER synthesis
```

## Isolation Protocol

Each reviewer session must be **independent**:
- Do not run reviewers in the same Claude Code session
- Start a fresh session for each persona
- Do not share or reference prior reviewer output until the Synthesis step
- Use `gh pr diff $PR_NUMBER` (not `gh pr view`) to avoid loading prior comments

This isolation ensures your scorecard data is clean and persona 
differentiation is measurable.

## After Reviews Are Posted

1. Fill in the evaluation scorecard: `evaluation/review-protocol-scorecard.md`
2. Read the Synthesis Agent's prioritized action list
3. Resolve any `[HUMAN DECISION]` items yourself
4. Update the spec to resolve all blocking issues (manually or with a new agent session)
5. You review the final diff and approve/merge

## Expected Time Per Run

| Step | Time |
|---|---|
| 9 reviewer sessions (sequential) | ~60–90 min |
| Synthesis session | ~10 min |
| Scorecard (manual) | ~20 min |
| Total | ~90–120 min |

This investment is front-loaded by design. Resolving ambiguity now 
saves multiples of this time during implementation.
