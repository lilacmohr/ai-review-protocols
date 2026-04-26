# AI Engineering Playbook

A structured framework for building software with AI agents. Three chapters, each
covering a distinct phase of the development lifecycle — from spec to setup to the
repeating delivery loop.

Built and validated on [ai-radar](https://github.com/lilacmohr/ai-radar), a personal
AI news briefing pipeline developed entirely with this workflow.

---

## The Four Chapters

### [01 — Spec Review](01-spec-review/)

Review a spec before implementation begins. Send multiple independent specialized
reviewers, each through a different lens, then synthesize into a prioritized action
list with a Decision Register.

Most AI code failures trace to a spec that was ambiguous or incomplete. This is the
cheapest place to find and fix those gaps.

→ **Start here if** you have a spec (PR, doc, or design) and want to find holes before
you write code.

---

### [02 — Setup](02-setup/)

Infrastructure that makes the delivery cycle reliable: an agent briefing document
(CLAUDE.md), enforcement hooks, issue templates, and bot account governance.

The agent briefing document is the most underrated artifact in AI-assisted development.
A well-written CLAUDE.md is the difference between an agent that needs constant
supervision and one that can be trusted with a ticket.

→ **Start here if** you're beginning a new project or onboarding a project to
AI-assisted development for the first time.

---

### [03 — Delivery Cycle](03-delivery-cycle/)

The red-green-retro loop: TEST ticket (write failing tests) → IMPL ticket (make them
pass) → retro (update setup artifacts). Repeat.

Includes the test PR review skill (asking "what tests are missing?" before the IMPL
ticket opens) and the implementation review skill (asking "is this the best
implementation?" after the IMPL ticket closes).

→ **Start here if** you're already set up and want to run a repeatable delivery loop
with AI agents.

---

### [04 — Decision Records](04-decision-records/)

Capture the *why* behind engineering decisions made during AI-assisted sessions —
before the session closes and the reasoning evaporates. Includes a three-level
decision granularity model, a narration-first capture workflow, a Decision Record
template, and a Decision Register for tracking decisions across the project.

Also includes the cross-system probe (interrogate your mental model before touching
a system you don't own) and architecture quiz (test your understanding of any system).

→ **Use this** when a Level 1 or Level 2 decision was made during a session, before
touching a service boundary, or when onboarding to an unfamiliar system.

---

## Where to Start

If you're new to the playbook: **start with 02-Setup**. The spec review and delivery
cycle both depend on having a good CLAUDE.md and governance structure.

If you're mid-project and something feels off: **run a spec review** on your current
design doc or a recent PR. The Ambiguity Auditor often surfaces the root cause.

If you're running issues and want structure: **read the delivery cycle**. The
red-green-retro framing makes the loop explicit and gives the retro a concrete output.

---

## Reference Implementation

`02-setup/examples/ai-radar/` contains the full CLAUDE.md and playbook notes from the
ai-radar project — a real project built with this framework. Use it as a template and
adapt to your stack.

---

## Maturity Levels

This framework is designed to grow with your team:

| Level | What it looks like |
|---|---|
| **Level 1** | Manual copy-paste. Validated prompts, consistent structure. |
| **Level 2** | Slash commands: `/review-pr 42 architect`. Prompt construction automated. |
| **Level 3** | GitHub Actions trigger on PR label. Fully headless. |

The framework is currently at Level 1 with stubs for Level 2 slash commands.
