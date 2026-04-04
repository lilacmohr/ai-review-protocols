# Spec Scorer — Workflow Guide

---

## What the Spec Scorer Does

The Spec Scorer generates an **AI-Readiness Score (ARS)** — a weighted 
composite score (0-10) measuring how well a technical spec is prepared 
for implementation by AI agents. It is grounded in the IEEE/ISO 29148 
requirements quality framework, adapted specifically for AI implementation.

It answers one question: **"If an agent started implementing from this 
spec today, how often would it make a wrong assumption or ask a clarifying 
question that blocks progress?"**

ARS is not a quality score in the general software sense. A spec can be 
beautifully written and still score low on ARS if it leaves interface 
contracts undefined or failure modes unspecified. The scorer is calibrated 
to AI agent behavior specifically.

---

## When to Run It

Run the scorer **twice**:

**Run 1 — Before the review protocol**
Establishes a baseline. Reveals which dimensions are weakest before 
reviewers see the spec. If you share the before-score with reviewer agents, 
they can focus their attention on the lowest-scoring dimensions.

**Run 2 — After spec agent revisions**
Measures improvement. The before/after delta is your quantitative ROI 
for the review protocol. It's also the primary evidence for any write-up 
or team recommendation about whether this process is worth the time.

Optionally: run a third time after implementing one milestone to validate 
that the spec was actually accurate — did the implementation match the spec, 
or did the agent have to deviate?

---

## How to Run It

**Step 1:** Open a fresh Claude Code session.

**Step 2:** Set model and effort:
```
/model opus
/effort high
```

**Step 3:** Paste the contents of `protocol/spec-scorer-agent.md`.

**Step 4:** Replace `$SPEC_FILE` with the path to your spec, e.g.:
```
cat SPEC.md
```

**Step 5:** The agent will read the spec and produce scores. Direct it 
to fill in `evaluation/spec-scorer-scorecard.md`.

**Step 6:** Review the Priority Improvement List — this is the most 
actionable output. Use it to brief the Spec Agent on what to fix.

---

## How It Connects to the Review Protocol

The scorer and the review protocol are complementary tools measuring 
different things:

| Tool | What it measures | Output |
|---|---|---|
| Multi-agent review protocol | Which specific issues exist and where | Prioritized issue list for revision |
| Spec Scorer | Overall spec quality across 9 dimensions | Before/after ARS delta |

They work best in sequence:

```
Spec Scorer (Run 1 — baseline)
         ↓
Multi-agent review protocol (9 reviewers + synthesis)
         ↓
Spec Agent (addresses synthesis action list)
         ↓
Spec Scorer (Run 2 — measure improvement)
         ↓
Human review (approve if ARS ≥ 8.5)
         ↓
Architect Agent (create GitHub Issues)
         ↓
Implementation
```

The scorer's Priority Improvement List and the synthesis agent's 
action list should be compared before briefing the Spec Agent. 
Items that appear on both lists are highest-confidence changes. 
Items on the priority list but not the synthesis may be systemic 
issues the reviewers missed. Items on the synthesis but not the 
priority list are specific findings the scorer's dimension-level 
view didn't surface.

---

## Interpreting the Score

### The threshold that matters

**ARS ≥ 8.5 = implementation-ready.** Below this, agent implementation 
will produce code that requires significant human correction. Above it, 
agents will implement correctly with minimal clarification needed.

This threshold is calibrated against the dimensions — an 8.5 means:
- Unambiguity ≥ 8 (no statements with multiple interpretations)
- Completeness ≥ 8 (all modules and behaviors defined)
- Consistency ≥ 8 (no internal contradictions)
- Verifiability ≥ 8 (testable acceptance criteria throughout)

You can have a perfect 10 on lower-weighted dimensions and still fail 
the threshold if the top four dimensions are weak.

### Score calibration expectations

For a first-draft spec written by a human without AI review, 
expect an ARS of 4.0-6.0. This is normal — first drafts are 
conceptual and leave gaps that feel obvious to the author but 
aren't in the document.

After one round of multi-agent review and revision, expect 6.5-8.0. 
After a second focused revision pass, 8.0-9.0 is achievable.

A score of 9.5+ is rare and may indicate over-specification — 
the spec is so detailed it's constraining the agent unnecessarily.

### What the weights mean

The weights reflect AI-specific priorities, not general software quality:

- **Unambiguity (25%)** is weighted highest because it's the primary 
  failure mode for AI agents — they implement the wrong thing silently
- **Completeness (20%)** because agents don't ask "what about X?" — 
  they just skip X or make up a behavior
- **Consistency (15%)** because agents read sections independently and 
  may implement contradictory behaviors in different modules
- **Verifiability (15%)** because AI-generated code needs objective 
  acceptance criteria more than human-written code does
- Lower-weighted dimensions matter but rarely cause catastrophic failures

---

## Limitations

**The scorer is an LLM evaluating an LLM-targeting document.** 
It will have blind spots, particularly on domain-specific technical 
assumptions it isn't aware of. The Domain Expert reviewer in the 
multi-agent protocol covers territory the scorer cannot.

**Scores are not objective.** Two runs of the scorer on the same spec 
may produce slightly different scores. Use the Priority Improvement List 
and the directional trend (before vs. after) more than the absolute number.

**ARS does not measure correctness of the spec itself.** A spec can 
score 9.5 and still describe a technically wrong architecture. The scorer 
measures implementation-readiness, not technical soundness. The Architect 
and Skeptic reviewers cover technical correctness.

**The implementation-ready threshold (8.5) is an estimate.** It is 
not validated against a large empirical dataset. It is calibrated 
against the dimension definitions and represents a reasonable bar — 
not a guaranteed predictor of implementation success.

---

## Using the Score in a Write-up

The before/after delta is the most compelling single metric for 
communicating the value of the review protocol. Frame it as:

> "Before review, SPEC.md scored 5.2/10 on the AI-Readiness Scale — 
> implementable with significant guesswork. After one round of 
> 9-persona review and revision, it scored 8.1/10 — 
> implementation-ready. The primary improvements were in 
> Unambiguity (+2.8) and Consistency (+3.0), reflecting resolution 
> of the pipeline ordering contradiction and undefined data schemas."

This is specific, quantified, and tied to concrete spec changes — 
exactly the kind of evidence that makes a team recommendation credible.

---

*Workflow version: 0.1*
