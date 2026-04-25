---
name: score-spec
description: >
  Evaluate a software specification for AI agent readiness using the 9-dimension
  quality scorecard. Use this skill whenever someone asks to score, evaluate, grade,
  or audit a spec before implementation begins — or asks "is this spec ready?",
  "can agents implement this?", or "what's missing from our spec?". Also triggers
  on requests to improve a spec, find ambiguities, or prepare a spec for AI-assisted
  development. This is the gate that must pass before pre-implementation begins.
---

# Spec Quality Scorer

Evaluate a specification for AI agent readiness. Produce a weighted score across
9 dimensions and a prioritized improvement plan.

## When to Use

- Before pre-implementation begins (the primary gate)
- After major spec revisions (to track improvement)
- When an implementation produces unexpected results (to diagnose root cause)
- When asked: "is this spec ready?", "score this spec", "what's ambiguous?"

## Inputs

The spec file to evaluate. If not provided, look for: `SPEC.md`, `spec.md`,
`README.md` (if it contains requirements), or ask the user to specify.

Read the full spec before scoring. For large specs (>500 lines), read in sections.

## The Scoring Rubric

Score each dimension 1–10. See `rubric.md` for detailed criteria per score.

| # | Dimension | Weight | Core question |
|---|---|---|---|
| 1 | Unambiguity | 25% | Could two agents read this and make the same implementation decision? |
| 2 | Completeness | 20% | Are all modules, models, failure modes, and cross-cutting concerns described? |
| 3 | Consistency | 15% | Do all sections agree with each other? |
| 4 | Verifiability | 15% | Can each requirement be turned into a passing/failing test? |
| 5 | Implementation Guidance | 10% | Does the spec say *how* to work, not just *what* to build? |
| 6 | Forward Traceability | 5% | Can a ticket reference a specific spec section? |
| 7 | Singularity | 5% | Does each requirement describe exactly one thing? |
| 8 | Failure Mode Coverage | 3% | Is the unhappy path as specified as the happy path? |
| 9 | Interface Contracts | 2% | Are inputs, outputs, and types defined at every stage boundary? |

**Threshold:** Weighted score ≥ 7.0 = implementation-ready.
Below 7.0 = do not begin implementation. Improve the spec first.

## Scoring Process

1. Read the full spec.
2. For each dimension, identify 2–5 specific findings (evidence from the spec text).
3. Score the dimension based on the findings. Do not round generously — a 7 means
   "an agent could implement this without major divergence." A 5 means "significant
   gaps that would cause two agents to produce structurally different code."
4. Calculate weighted total.
5. Identify the top 3 improvements by weighted impact.

## Output Format

```
SPEC QUALITY SCORECARD
═══════════════════════════════════════════════════════
Spec: [filename]
Evaluated: [date]

DIMENSION SCORES
────────────────────────────────────────────────────────
 #  Dimension                Weight  Score  Weighted
 1  Unambiguity               25%     X.X    X.XX
 2  Completeness              20%     X.X    X.XX
 3  Consistency               15%     X.X    X.XX
 4  Verifiability             15%     X.X    X.XX
 5  Implementation Guidance   10%     X.X    X.XX
 6  Forward Traceability       5%     X.X    X.XX
 7  Singularity                5%     X.X    X.XX
 8  Failure Mode Coverage      3%     X.X    X.XX
 9  Interface Contracts        2%     X.X    X.XX
────────────────────────────────────────────────────────
    WEIGHTED TOTAL           100%           X.XX

VERDICT: [IMPLEMENTATION-READY ✓ / NOT READY ✗]
(Threshold: 7.0)

DIMENSION FINDINGS
────────────────────────────────────────────────────────
[For each dimension, 2–5 bullet points of specific evidence.
Quote or reference the spec section. Explain what's present
and what's missing. Be precise — vague findings are not actionable.]

TOP 3 IMPROVEMENTS BY IMPACT
────────────────────────────────────────────────────────
1. [Title] (+X.XX–X.XX weighted points)
   What: [specific gap]
   How to fix: [concrete action]
   Affects: [which dimensions improve]

2. [Title] (+X.XX–X.XX weighted points)
   ...

3. [Title] (+X.XX–X.XX weighted points)
   ...

OVERALL ASSESSMENT
────────────────────────────────────────────────────────
[2–4 sentences. Would two independent agents produce compatible
implementations? What is the highest-risk gap? What should
happen before implementation begins?]
═══════════════════════════════════════════════════════
```

## Calibration Notes

- **Score 9–10:** Exhaustive. Two agents produce nearly identical implementations.
- **Score 7–8:** Implementation-ready. Agents may differ in minor details only.
- **Score 5–6:** Significant gaps. Agents produce compatible-but-divergent code.
- **Score 3–4:** Major gaps. Agents will make conflicting architectural decisions.
- **Score 1–2:** Insufficient. Cannot be implemented without substantial clarification.

The most commonly overscored dimension is **Verifiability** — specs often describe
behavior clearly but without stating what a passing test would assert. If you can't
write a failing test directly from the spec text, score it lower.

The most commonly underweighted gap is **prompt templates** in LLM-powered systems.
If the system calls an LLM but the spec doesn't specify prompt structure, flag this
as the highest-impact gap regardless of which dimension it falls under.

## Reference Files

- `rubric.md` — Detailed scoring criteria with examples for each score level
