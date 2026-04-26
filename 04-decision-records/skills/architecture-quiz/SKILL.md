---
name: architecture-quiz
description: >
  Actively test the engineer's understanding of a system — whether they built it,
  inherited it, or are reviewing it. Use when asked to "quiz me on [system]",
  "test my understanding of what we built", "quiz me before this PR", or "help me
  onboard to [system]". The narration technique applied to comprehension: the act
  of explaining forces the engineer to find where their understanding breaks down.
argument-hint: 'system or feature name (e.g. "what we built this session")'
---

# Architecture Quiz

Use these to actively test your understanding of a system. The act of explaining
forces you to find where your understanding breaks down — before someone else does.

---

## Quiz: What Was Built This Session

Run after a significant coding session to check your own understanding before closing
the window.

> "Quiz me on what we built this session. Ask me questions one at a time — don't give
> me multiple choice, make me come up with the answers. Cover:
> - The overall structure of what was built and how the pieces connect
> - The key decisions we made (not just what we chose, but why)
> - What we explicitly decided NOT to do and why
> - Where the main risks or open questions are
>
> After I answer each question, tell me if I got it right, what I missed, and whether
> there's anything in our session context that contradicts what I said."

---

## Quiz: System Architecture (General)

Use when studying or reviewing a system you need to understand deeply.

> "Quiz me on [system name]. I'll explain the context: [brief description]. Ask me
> questions one at a time that test whether I actually understand:
> - How it works end-to-end
> - What the data flow looks like
> - What the failure modes are
> - What the design trade-offs were
> - What I'd need to know to safely change it
>
> Start easy and get harder. Don't give me hints in the question phrasing."

---

## Quiz: Decision Rationale

Use to test whether you can reconstruct the *why* behind past decisions — your own
or someone else's.

> "Quiz me on the decisions behind [feature/system/PR]. Ask me one question at a time.
> For each answer I give, tell me:
> - Whether I correctly identified the reasoning (not just the outcome)
> - Whether my answer reveals any gaps or assumptions I'm carrying
> - What the actual reasoning was if I got it wrong or incomplete
>
> Focus on decisions that constrain future options — things that would be expensive
> to undo."

---

## Quiz: PR Review Readiness

Before submitting a PR that crosses a service boundary or makes a consequential change:

> "I'm about to submit a PR for [description]. Quiz me on it — ask me the questions
> a skeptical senior reviewer would ask. I should be able to answer:
> - What problem does this solve and why now?
> - What did I consider and rule out?
> - What does this change break or constrain for others?
> - What assumption is this PR betting on?
> - What's the rollback plan if it's wrong?
>
> Ask one at a time. If my answer is thin, push harder."

---

## Quiz: Onboarding to an Unfamiliar System

Use as a structured 30-minute onboarding exercise before touching an unfamiliar codebase.

> "I'm about to work in [system name] for the first time. I've read [what I've read
> so far]. Quiz me on what I should know before making any changes. Start with the
> fundamentals — what this system does and who depends on it — then move to the more
> dangerous territory: the failure modes, the implicit contracts, the 'don't touch
> this' parts.
>
> After each answer, flag anything I seem uncertain or wrong about, and tell me if
> it's a risk given what I'm about to do."

---

## Scoring Your Answers

At the end of any quiz session:

> "Give me a 1-sentence summary of where my understanding is solid, where it's shaky,
> and what's the most important gap to close before I make changes to this system."
