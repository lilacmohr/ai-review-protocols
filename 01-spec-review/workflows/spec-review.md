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

Run all nine independent personas in isolated sessions (no persona should read 
another's comments before posting). Then run the Ambiguity Auditor, which 
requires reading the other reviews. Finally run Synthesis.

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

After all nine have posted, run the Auditor (reads prior comments) then Synthesis:

| # | Persona | File | Recommended Model | Effort | Primary Value |
|---|---|---|---|---|---|
| 10 | Ambiguity Auditor | `personas/ambiguity-auditor.md` | Opus | high | Exhaustive implementation fork enumeration |
| — | Synthesis | `protocol/spec-reviews-synthesis-agent.md` | Opus | high | Consolidated action list + Decision Register |

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
/review-pr $PR_NUMBER ambiguity-auditor
```
Then:
```
/review-pr $PR_NUMBER synthesis
```

## Isolation Protocol

The nine independent reviewer sessions must be **isolated**:
- Do not run reviewers in the same Claude Code session
- Start a fresh session for each persona
- Do not share or reference prior reviewer output until the Ambiguity Auditor step
- Use `gh pr diff $PR_NUMBER` (not `gh pr view`) to avoid loading prior comments

The Ambiguity Auditor is the **exception**: it must read all prior reviewer
comments. Run it in its own session after all nine independents have posted.

This isolation ensures your scorecard data is clean and persona 
differentiation is measurable.

## After Reviews Are Posted

1. Fill in the evaluation scorecard: `evaluation/scorecard-10-reviewer.md`
2. Read the Synthesis Agent's prioritized action list
3. Resolve any `[HUMAN DECISION]` items yourself
4. Update the spec to resolve all blocking issues (manually or with a new agent session)
5. You review the final diff and approve/merge

## Expected Time Per Run

| Step | Time |
|---|---|
| 9 independent reviewer sessions (sequential) | ~60–90 min |
| Ambiguity Auditor session | ~15 min |
| Synthesis session | ~10 min |
| Scorecard (manual) | ~20 min |
| Total | ~105–135 min |

This investment is front-loaded by design. Resolving ambiguity now 
saves multiples of this time during implementation.
