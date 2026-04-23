# CLAUDE.md — Playbook Notes

> **Audience:** Engineering leaders and AI enablement roles.
> **What this is:** The rationale behind decisions in `CLAUDE.md` and guidance
> on maintaining it at team scale. This file is for humans, not agents.
> It is intentionally kept separate from `CLAUDE.md` to avoid consuming
> agent instruction budget with content the agent doesn't need.

---

## Why CLAUDE.md exists as a file (not just prompt instructions)

Prompt instructions are ephemeral — they live in a session and disappear. `CLAUDE.md`
is version-controlled alongside the code it governs. When your standards evolve, the
history of *why* they changed is preserved in git. Every agent session starts from
the same baseline regardless of who initiates it.

At team scale, this matters more: ten engineers running ten agent sessions will
produce consistent behavior if they all start from the same `CLAUDE.md`. Without it,
each session inherits only whatever context the engineer happened to include in their
prompt — which varies significantly between people and across time.

---

## Why decisions and rationale are included (not just rules)

A rule without rationale gets cargo-culted or silently violated when an agent or
engineer can't see why it matters. Rationale enables judgment: "the reason for this
rule doesn't apply in this situation" is a valid, surfaceable observation. "I didn't
know why the rule existed so I ignored it" is not.

This is the key distinction between a briefing document and a style guide. A style
guide says what. A briefing document says what and why — which is what enables the
agent to handle edge cases the rules don't explicitly cover.

---

## How to maintain this file at team scale

- `CLAUDE.md` is owned by the team lead or AI enablement role, not individual engineers
- Changes require the same review process as architecture changes
- Add a section when a new cross-cutting concern is introduced (new external service,
  new failure mode, new testing pattern)
- **Remove** rules that are *only* enforced by linters (ruff, mypy) and have no
  behavioral rationale the agent needs to understand — pure formatting rules,
  import ordering, etc. These are noise the agent doesn't need in its context window.
- **Keep** rules that are also enforced by hooks (Stop gate, PreToolUse guards,
  PostToolUse lint). The agent should understand *why* a rule exists even when a hook
  guarantees it. Hook enforcement provides the guarantee; the CLAUDE.md entry provides
  the judgment context that lets the agent handle edge cases correctly.
- Keep it under ~2,500 words. Beyond that, instruction quality degrades as the agent
  prioritizes recent context over earlier content in long sessions

---

## The CLAUDE.md → onboarding pipeline

New engineer onboarding = README (what) + SPEC.md (why/what in detail) + CLAUDE.md
(how we work). An engineer who has read all three should be able to open a GitHub
Issue and implement a module without a synchronous conversation. That's the bar.

This also means `CLAUDE.md` is the right place to capture things that would otherwise
live only in onboarding conversations, PR review comments, or a senior engineer's
memory — conventions that are real but unwritten.

---

## Signals this file needs updating

- An agent makes the same "wrong" decision twice → the convention isn't clear enough
- A PR review comment appears more than once → encode it as a rule
- A new engineer asks a question that isn't answered here → add it
- A rule is being systematically ignored → either enforce it with tooling or remove it
- The file grows past ~2,500 words → audit for content that can move to tooling or
  be referenced rather than included inline

---

## The relationship between CLAUDE.md and hooks

These two artifacts enforce standards at different layers and serve different purposes.
Understanding the distinction prevents both under-engineering (relying on CLAUDE.md
alone) and over-engineering (duplicating everything in hooks).

| | CLAUDE.md | Hooks |
|---|---|---|
| **Nature** | Advisory — agent reads and generally follows | Deterministic — runs regardless of what agent decides |
| **Purpose** | Context, rationale, standards the agent internalizes | Enforcement of non-negotiable quality gates |
| **Failure mode** | Agent may deprioritize in long sessions | Hook mis-configuration can block or loop |
| **Right for** | Conventions, judgment calls, architectural context | Binary pass/fail checks, completion gates |

Overlap between the two is expected and healthy for the most critical rules — the agent
should both understand why a rule exists (CLAUDE.md) and be unable to accidentally
violate it (hooks). For purely mechanical rules (formatting, import order), prefer
tooling enforcement and remove the CLAUDE.md entry — it's noise the agent doesn't need.

---

*Part of the AI Engineering Playbook. Reference implementation: ai-radar (Python + Claude Code).*
