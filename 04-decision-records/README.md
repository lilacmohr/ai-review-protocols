# 04 — Decision Records

Capture the *why* behind engineering decisions made during AI-assisted development
sessions — before the session closes and the reasoning evaporates.

The framework is described in full in
[What Just Happened? Capturing Engineering Decisions in the Age of AI](https://lilacmohr.com/articles/what-just-happened.html).

---

## The Core Principle

AI-generated summaries capture *what* was built. Human narration — with AI as
structured interviewer rather than ghostwriter — captures *why*, including the
alternatives ruled out and the assumptions the decision depends on.

**Direction of flow matters:** knowledge capture only works when reasoning moves from
human understanding into artifacts. Not when AI generates artifacts from code.

---

## Three Levels of Decision

| Level | What it is | Where it lives |
|-------|-----------|----------------|
| **1 — System contracts** | Interfaces, data contracts, integration patterns between services | Formal versioned record |
| **2 — Design decisions with lasting consequence** | Choices that constrain future options (consistency model, service boundary, storage pattern) | Decision Record |
| **3 — Implementation rationale** | Why this pattern, this library, this error handling approach | PR description / inline comments |

**The rule for Staff+ engineers:** if you're making a decision that will constrain
someone else's options six months from now, it's Level 1 or 2 and needs a record.

---

## What's in This Chapter

```
04-decision-records/
├── README.md                              ← you are here
├── skills/
│   ├── cross-system-probe/SKILL.md        ← before touching systems you don't own
│   └── architecture-quiz/SKILL.md         ← self-testing comprehension of a system
└── templates/
    ├── decision-record.md                 ← the record template
    └── decision-register.md               ← project-level index of all decisions
```

The end-of-session narration workflow lives in the delivery cycle chapter, where
it belongs alongside the other session-closing practices:

→ [`03-delivery-cycle/skills/capture-decision/SKILL.md`](../03-delivery-cycle/skills/capture-decision/SKILL.md)

---

## Quick Start

**At the end of an AI coding session**, before closing the window:

→ Run the [`capture-decision`](../03-delivery-cycle/skills/capture-decision/SKILL.md)
skill (5-step workflow: narrate → probe → surface gaps → generate record → sanity check).
Open a PR with the record alongside the code change. Add a row to the
[Decision Register](templates/decision-register.md).

**Before touching a system you don't primarily own:**

→ Run the [`cross-system-probe`](skills/cross-system-probe/SKILL.md) skill.
~15 minutes. Surfaces knowledge gaps before the PR, not after the incident.

**To test your own understanding of a system:**

→ Run the [`architecture-quiz`](skills/architecture-quiz/SKILL.md) skill.
Variants for: what we built this session, system architecture, decision rationale,
PR review readiness, onboarding.

---

## What Good Looks Like

You're reviewing a PR that crosses a service boundary. You open the description and
the engineer has already answered the question you were about to ask — they've named
the alternatives they considered, stated what ruled them out, and flagged the
assumption the decision depends on. You close the PR without leaving a comment about
missing context.

That's the narration workflow working. The absence of that — an AI summary where the
reasoning should be — is the signal it isn't.

---

## Connection to ADRs

If your team already uses Architecture Decision Records, this framework extends rather
than replaces that practice. The key additions are:

- A **granularity model** (what gets a formal record vs. what lives in the PR)
- A **capture workflow** (narration-first, not summary-from-code)
- A **revisit signals field** that most ADR templates omit — the observable conditions
  that would indicate the decision should be reconsidered, paired with a concrete
  revisit date
- A **Decision Register** — a project-level index linking all records and their
  current status

---

## Connection to the Delivery Cycle

The retro skill (`03-delivery-cycle/skills/retro/`) already flags "Spec patches needed"
when a `[DECISION]` issue resolves an ambiguity. The output of that retro step is
input to this chapter: the resolved decision becomes a Decision Record, and a row
gets added to the Decision Register.

The capture-decision skill can also run independently — not every decision surfaces
through a `[DECISION]` issue. Any session where a Level 1 or Level 2 decision was
made is a candidate.
