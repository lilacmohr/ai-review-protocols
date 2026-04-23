# 02 — Setup

Infrastructure that makes AI-assisted development reliable. Do this once per project
before the first ticket is opened.

The core insight: a well-written agent briefing document (CLAUDE.md) is the difference
between an agent that needs constant supervision and one that can be trusted to take a
ticket to completion. The other setup artifacts — hooks, issue templates, bot governance
— are multipliers on top of that foundation.

---

## What's in this chapter

```
02-setup/
├── protocol/
│   └── playbook-pre-implementation.md  ← full setup protocol (start here)
├── examples/
│   └── ai-radar/
│       ├── CLAUDE.md                   ← reference implementation briefing doc
│       └── playbook-notes.md           ← rationale behind the CLAUDE.md decisions
├── hooks/                              ← example Claude Code hooks
│   ├── session_start.sh
│   ├── pre_tool_guard.sh
│   ├── post_edit_lint.sh
│   └── stop_run_tests.sh
├── issue_templates/                    ← GitHub issue templates for the delivery cycle
│   ├── config.yml
│   ├── 1_test.yml
│   ├── 2_impl.yml
│   ├── 3_scaffold.yml
│   ├── 4_decision.yml
│   └── 5_refactor.yml
└── skills/                             ← Claude Code skills for setup review tasks
```

---

## Level 1 Quickstart

**Step 1 — Write the agent briefing document**

Start with the seven questions in `protocol/playbook-pre-implementation.md §2`:

1. What is this project and what are its highest-priority constraints?
2. What is the architecture? (Data flow, stage boundaries, key types)
3. Where is the autonomy boundary? (What decisions can the agent make vs. surface?)
4. What are the code standards? (Types, error handling, logging, structure)
5. What are the failure handling conventions?
6. What are the testing requirements?
7. What is the definition of done?

Use `examples/ai-radar/CLAUDE.md` as a reference implementation. Don't copy it
literally — answer the seven questions for your own project.

**Step 2 — Install enforcement hooks**

Copy the hooks from `hooks/` into your project's `.claude/hooks/` directory.
Hooks are deterministic enforcements; the briefing doc is probabilistic guidance.
Together they form a reliable quality gate.

See `protocol/playbook-pre-implementation.md §3` for hook types and configuration.

**Step 3 — Install issue templates**

Copy the templates from `issue_templates/` into your project's `.github/ISSUE_TEMPLATE/`
directory. They encode the TDD protocol — TEST before IMPL, DECISION for spec gaps,
REFACTOR for structural debt.

Edit the `config.yml` links to point to your project's SPEC.md and CLAUDE.md.

**Step 4 — Set up bot account governance**

Create a dedicated bot GitHub account for agent commits. Configure branch protection
rules on your main branch: require PR review from a human account, prevent the bot
from approving its own PRs.

This is structural enforcement, not policy. See the governance section below.

---

## Bot Account Governance

This is a prerequisite, not a preference.

Without it, an agent can open a PR and merge it in the same session. With branch
protection and a bot account, that's structurally impossible — every agent-authored
change must be reviewed by a human before it lands.

**Setup (GitHub):**

1. Create a new GitHub account for agent work (e.g. `yourproject-bot`)
2. Add it as a collaborator on your repo with Write access
3. In repo Settings → Branches → Add rule for `main`:
   - Require pull request before merging
   - Require approvals: 1
   - Dismiss stale reviews: enabled
   - Restrict who can push to matching branches: exclude the bot account

4. Run Claude Code as the bot account (set `GH_TOKEN` to the bot's token)
5. Review and merge as your personal account

**What this gives you:**

- Every agent change is a PR — reviewable, diffable, revertable
- No agent can self-merge — structural guarantee, not a prompt instruction
- Git history is clean: bot commits are clearly attributed, human approvals are recorded
- The retro has a concrete artifact to review: the PR diff

**The key point:** telling an agent "always open a PR and wait for review" is a prompt
instruction. Branch protection rules are architecture. Architecture wins.

---

## The Agent Briefing Document (CLAUDE.md)

The briefing doc is the most important artifact in this chapter.

Seven questions, in priority order:

| # | Question | Why it matters |
|---|---|---|
| 1 | Project overview | Sets the frame — what is being built, what constraints are non-negotiable |
| 2 | Architecture | Agents need to understand data flow and stage boundaries to avoid integration bugs |
| 3 | Autonomy boundary | Makes explicit where the agent decides vs. surfaces for human input |
| 4 | Code standards | Encodes style rules that the agent would otherwise improvise |
| 5 | Failure handling | The most important behavioral contract — must be explicit, not implied |
| 6 | Testing requirements | Defines what "tested" means before the agent writes a single test |
| 7 | Definition of done | The quality gate the agent checks before closing a ticket |

See `examples/ai-radar/playbook-notes.md` for rationale on each decision and guidance
on maintaining the briefing doc as the project evolves.

---

## Hooks vs. CLAUDE.md

These two artifacts work differently:

| Artifact | Mechanism | Reliability |
|---|---|---|
| CLAUDE.md | Agent reads and follows | Probabilistic — the agent might miss or misinterpret |
| Hooks | Shell commands that run automatically | Deterministic — the hook always runs |

Use CLAUDE.md for guidance, conventions, and context. Use hooks for enforcement:
things that must happen every time, regardless of what the agent was thinking.

See `protocol/playbook-pre-implementation.md §3` for the four hook types and when
to use each.

---

## Issue Templates

The templates encode the TDD protocol as structured GitHub forms. Key issue types:

| Template | Use when |
|---|---|
| `[TEST]` | Starting a new module — write failing tests first |
| `[IMPL]` | Tests exist and are red — implement until green |
| `[SCAFFOLD]` | Infrastructure work (config, models, CI) — no behavior to test yet |
| `[DECISION]` | Agent or human needs a spec question resolved before continuing |
| `[REFACTOR]` | Structural improvement needed — behavior must not change |

The `config.yml` disables blank issues and links to SPEC.md and CLAUDE.md directly
from the "new issue" page. That one file enforces read-the-spec-first as a default.

---

## Full Protocol

`protocol/playbook-pre-implementation.md` covers the complete setup protocol in detail,
including how to evaluate spec readiness, what each hook does, the scaffolding workflow,
and how setup artifacts feed back into each other over time.
