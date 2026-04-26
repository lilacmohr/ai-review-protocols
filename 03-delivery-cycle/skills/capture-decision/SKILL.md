---
name: capture-decision
description: >
  Run the decision narration workflow to capture a design or architectural decision
  made during an AI coding session. Use when asked to "capture this decision",
  "generate a decision record", "narrate this decision", "let's do a session
  mini-retro", or "before I close this window." Goal: move reasoning from the
  engineer's head into a Decision Record while session context is still live.
  The record goes into the PR alongside the code change.
argument-hint: 'optional: brief description of the decision to capture'
---

# Capture a Decision

The session is about to close. The goal is to capture the decision made during this
session into a Decision Record — based on human narration, not on reading the code.

**Direction of flow matters:** knowledge capture only works when reasoning moves from
human understanding into an artifact. AI-generated summaries from code capture what
was built. This workflow captures *why*, including the alternatives ruled out and
the assumptions the decision depends on.

---

## When to Use

- At the end of an AI coding session, before closing the window
- Any time a design or architectural decision was made that will constrain future options
- When a `[DECISION]` issue was resolved and the outcome needs to be recorded

**Granularity rule:** if this decision will constrain someone else's options six months
from now, it's Level 1 or 2 and needs a Decision Record.

| Level | What it is | Where it lives |
|-------|-----------|----------------|
| **1 — System contracts** | Interfaces, data contracts, integration patterns | Formal versioned record |
| **2 — Design decisions** | Choices that constrain future options (consistency model, service boundary) | Decision Record |
| **3 — Implementation rationale** | Why this pattern, this library, this error handling | PR description / inline comments |

---

## Step 1 — Narrate the Decision

Send one of these:

**If you can narrate cold** (you know what you decided and why):

> "I'm going to narrate the decision we just made. Listen without generating a record
> yet. I'll tell you: the problem I was solving, the options I considered, what I ruled
> out and why, and why I landed where I did."

**If narrating cold is hard** (start here instead):

> "Ask me about this decision one question at a time — start with: what problem were
> we solving? Don't move to the next question until I've answered the current one."

---

## Step 2 — Probe the Reasoning

After narrating:

> "Ask me clarifying questions about this decision — specifically:
> - What assumptions does it depend on?
> - What would have to be true for a different choice to have been better?
> - What's the failure mode if one of those assumptions turns out to be wrong?
>
> Ask one question at a time. Don't generate the record yet."

---

## Step 3 — Surface Gaps

After answering the probe questions:

> "Based on my answers and our full session context, are there any decisions we made
> that I didn't narrate? Anything I seemed uncertain about? Anything in the code that
> implies a choice we didn't explicitly discuss?"

---

## Step 4 — Generate the Decision Record

Once the narration is complete:

> "Now generate a Decision Record using the template below. Base it entirely on my
> narration and my answers to your questions — not on the code itself.
>
> - **Title:** [short name for the decision]
> - **Date:** [today]
> - **Level:** [1 = system contract / 2 = design decision / 3 = implementation rationale]
> - **Context:** What problem were we solving? What constraints shaped the space?
> - **Options considered:** What alternatives did we evaluate?
> - **Decision:** What did we choose?
> - **Reasoning:** Why this option over the others? What did we rule out and why?
> - **Assumptions:** What must be true for this to hold up?
> - **Revisit signals:** What observable conditions would indicate this should be reconsidered?
> - **Revisit date:** [specific date, not 'TBD']"

For a complete template with all fields, see
[`04-decision-records/templates/decision-record.md`](../../../04-decision-records/templates/decision-record.md).

---

## Step 5 — Sanity Check

Before opening the PR:

> "Compare the Decision Record you generated against my narration. Flag anything in
> the record that:
> - Wasn't in my narration (i.e., you inferred it from code or invented it)
> - Contradicts what I said
> - Is vague where my narration was specific"

---

## Quick Reference

| When | Prompt to use |
|------|--------------|
| You know what you decided | Step 1 (narrate cold) |
| You're not sure where to start | Step 1 (guided questions) |
| After narrating | Step 2 (probe assumptions) |
| After answering probe questions | Step 3 (surface gaps) |
| Ready to generate the record | Step 4 (generate) |
| Before opening the PR | Step 5 (sanity check) |

---

## Output

A completed Decision Record ready to commit alongside the code change. Open the PR
with the record in the same commit or as a companion PR. Add a row to the project's
[Decision Register](../../../04-decision-records/templates/decision-register.md).
