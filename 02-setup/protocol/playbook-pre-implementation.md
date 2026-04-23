# AI Engineering Playbook
## Chapter: Pre-Implementation

> **Audience:** Engineering leaders, team leads, and senior engineers adopting AI coding
> agents across the software development lifecycle.
>
> **What this chapter covers:** The work that happens between "the spec is approved" and
> "the first feature ticket is assigned to an agent." This phase looks like overhead. It
> is actually the highest-leverage investment in the entire AI-assisted development cycle.

---

## Why Pre-Implementation Exists

Traditional software development has a well-understood ramp: write a spec, break it into
tickets, assign tickets, ship. The assumption baked into that workflow is that developers
read requirements, ask questions, and exercise judgment. When something is ambiguous, a
human notices and raises a flag.

AI coding agents don't work that way. An agent given an ambiguous requirement will produce
an answer — confidently, completely, and possibly wrong in ways that don't surface until
integration. An agent without a quality contract will write code that passes in the moment
and drifts over time. An agent without an established project context will make
architectural decisions that a second agent will contradict two tickets later.

The goal of pre-implementation is to give agents the conditions they need to produce
consistent, high-quality, architecturally coherent code — from the first ticket to the
last. The upfront investment is real. The rework it prevents is larger.

---

## The Agile Framing

Pre-implementation is not a waterfall gate. It is a sprint zero — a focused, time-boxed
phase with defined deliverables and a clear definition of done.

The outputs of this phase are living artifacts. `CLAUDE.md` (or its equivalent) evolves
as the codebase evolves. Issue templates get refined after the first few tickets reveal
what information agents actually need. Hooks get tuned as quality patterns emerge.

The right posture is: **do enough upfront to prevent the most expensive classes of
rework, then iterate.** Not: "don't start until everything is perfect."

A useful heuristic for scoping each artifact: if you find yourself re-explaining the same
thing to an agent in more than two sessions, it belongs in a permanent artifact.

---

## The Pre-Implementation Checklist

This checklist is the definition of done for the pre-implementation phase. Every item has
a corresponding section below that explains what it is, why it matters, and how to make
the build-once / reuse-many decision for your organization.

```
PRE-IMPLEMENTATION CHECKLIST

Spec Readiness
  [ ] Spec has been evaluated for agent-readiness (quality score ≥ 7/10)
  [ ] Top ambiguities are resolved or explicitly deferred with documented rationale
  [ ] Data models and interface contracts are fully defined
  [ ] Failure modes are specified

Agent Infrastructure
  [ ] Agent briefing document exists and has been reviewed by team lead
  [ ] Development workflow (TDD, BDD, or otherwise) is encoded in the briefing doc
  [ ] Enforcement layer is configured (hooks, CI checks, or equivalent)
  [ ] Briefing doc and enforcement layer are consistent with each other

Task Structure
  [ ] Issue/ticket taxonomy is defined (minimum: test, implementation, decision types)
  [ ] Issue templates exist for each type
  [ ] Templates encode enough context that an agent can begin without a follow-up conversation
  [ ] Definition of done is explicit in every template

Scaffolding
  [ ] Scaffolding tickets are written and sequenced before any feature tickets
  [ ] Toolchain is selected and documented with rationale
  [ ] "Single command quality gate" exists and is referenced in the briefing doc
  [ ] CI pipeline reflects the same quality gates as the local enforcement layer

If the project uses LLMs
  [ ] Prompt templates are drafted before LLM-dependent feature tickets are written
  [ ] Prompts are treated as code (version-controlled, reviewed, testable)
```

---

## Section 1: Spec Readiness

### What it is

Before a single ticket is written, the specification must be evaluated for
*agent-readiness* — not just human-readiness. A spec that a senior engineer can interpret
with experience and context may still be deeply ambiguous to an agent that will implement
it literally.

Evaluate your spec across these dimensions:

| Dimension | Weight | Score (1–10) | Weighted | The question it answers |
|---|---|---|---|---|
| **Unambiguity** | 0.15 | — | — | Could two agents read this and make the same implementation decision? |
| **Completeness** | 0.15 | — | — | Are all modules, models, and failure modes described? |
| **Consistency** | 0.15 | — | — | Do all sections agree with each other? |
| **Verifiability** | 0.15 | — | — | Can each requirement be turned into a test? |
| **Implementation Guidance** | 0.10 | — | — | Does the spec tell agents *how* to work, not just *what* to build? |
| **Interface Contracts** | 0.10 | — | — | Are inputs, outputs, and types defined at every boundary? |
| **Failure Mode Coverage** | 0.10 | — | — | Is the unhappy path as specified as the happy path? |
| **Forward Traceability** | 0.05 | — | — | Can a ticket be written that references a specific spec section? |
| **Singularity** | 0.05 | — | — | Does each requirement describe one thing? |

**Scoring:** Multiply each dimension score by its weight and sum. Maximum = 10.
Example: Unambiguity 8 × 0.15 = 1.2; ... Total = weighted sum.

Score each dimension 1–10. Weight and sum. A weighted score below 7 means the spec will
produce divergent implementations. Do not begin pre-implementation work until the spec
reaches 7. If the score is below 7, return to Chapter 1 (Spec Review) before continuing:
addressing spec gaps at this stage is significantly cheaper than fixing divergent
implementations after the fact.

### The one gap that affects everything else

In LLM-powered systems, prompt templates are almost always the most underspecified element
of a spec. They are also the primary driver of output quality. If your spec describes what
the LLM should produce but not how it should be prompted, that gap will produce the most
variation between implementations and the most rework. Identify this gap early and address
it before the LLM-dependent tickets are written — not after.

### Org-level reusability

The spec evaluation framework (dimensions, weights, scoring rubric) can be standardized
across your organization. Every team evaluates specs the same way. Over time you accumulate
data on which spec gaps most commonly cause implementation problems in your domain, and you
can adjust weights accordingly. A shared spec evaluation template is one of the highest-
leverage org-level investments in this phase.

---

## Section 2: The Agent Briefing Document

### What it is

Every AI coding agent has a mechanism for persistent project context — a file or
configuration that the agent reads at the start of every session. This file is the
encoded contract between your engineering standards and every agent session that
touches the codebase.

It goes by different names depending on your tooling:

| Tool | File |
|---|---|
| Claude Code | `CLAUDE.md` |
| Cursor | `.cursorrules` or `.cursor/rules/*.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Windsurf | `.windsurfrules` |
| Custom / API | System prompt or injected context |

The name doesn't matter. The content does.

### What belongs in it

A well-structured briefing document answers seven questions:

**1. What is this project?**
One paragraph. What does it do, how does it run, what are the highest priorities
(correctness, observability, performance, etc.). Agents that understand the *purpose*
of a system make better implementation decisions.

**2. What is the architecture?**
The data flow, the key components, the dependencies between them. Enough that an agent
implementing one module understands where it sits in the larger system.

**3. When should the agent ask vs. act?**
Define the autonomy boundary explicitly. What decisions can the agent make independently?
What decisions require surfacing to a human? This is the single most important behavioral
instruction in the document. Under-specified autonomy produces either excessive check-ins
or silent architectural choices — both are costly.

**4. What are the code standards?**
Language version, type system requirements, formatting rules, naming conventions, logging
patterns, error handling conventions. Be specific. "Write clean code" is not a standard.
"All functions must have explicit return type annotations and all exceptions must be caught
by specific type, never bare" is a standard.

**5. What are the failure handling conventions?**
For every category of failure the system encounters, what is the required behavior? This
section should read like a lookup table: failure type → required action. Consistent failure
handling across a codebase is one of the hardest things to achieve without explicit
instruction, and one of the most important for operational reliability.

**6. What are the testing requirements?**
What test types exist, what must each module have, what mocking strategy is required, how
are tests run. If you're using TDD, the test-before-implementation protocol belongs here.

**7. What does "done" mean?**
The quality gates that must pass before any task is considered complete. This is not a
checklist an agent optionally consults — it is the stopping condition. Make it explicit,
make it checkable, make it automated wherever possible.

### The most common mistake

Teams write briefing documents that are documentation. An agent reads documentation and
extracts guidance probabilistically — it may or may not follow it depending on context.
Write briefing documents as *instructions with rationale*. The rationale is what enables
the agent to exercise judgment when edge cases arise that the instructions don't cover.

A rule without rationale gets ignored when the agent can't see why it matters.
A rule with rationale enables the agent to extrapolate correctly to novel situations.

### Org-level reusability

The briefing document structure is org-level infrastructure. Define the seven sections
once as an org template. Each project fills in the template with project-specific content.
New projects start from the template rather than from a blank file.

Over time the template accumulates hard-won lessons: error handling conventions that
prevented a class of production incidents, logging patterns that made a type of debugging
possible, testing requirements that caught a category of integration bugs. The template
compounds in value with each project.

---

## Section 3: The Enforcement Layer

### What it is

The briefing document is *advisory* — agents read it and generally follow it, but
adherence depends on context, prompt length, and how far into a session the agent is.
The enforcement layer is *deterministic* — it runs regardless of what the agent decided
to do, every time, with no exceptions.

Think of the relationship this way: the briefing document sets expectations, the
enforcement layer guarantees them.

Most AI coding agent tools support hooks — scripts or commands that fire at specific
points in the agent's lifecycle. The key lifecycle points to enforce:

| Lifecycle point | What to enforce | Blocking? |
|---|---|---|
| **Session start** | Inject current project state (branch, recent changes, test status) | No — context only |
| **Before tool execution** | Block hard-to-undo violations (destructive commands, unapproved dependencies) | Yes — prevent |
| **After file edit** | Run linting, formatting, and type checking on modified files | Soft — warn and correct |
| **When agent signals done** | Run full test suite; force continuation if tests fail | Yes — gate |

### The four-layer model

```
Prevention   →  Before the action: block violations before they happen
                (unapproved dependencies, destructive operations, process breaks)

Correction   →  After the action: catch and surface issues for self-correction
                (lint, format, type errors on each modified file)

Completion   →  When the agent stops: enforce the definition of done
                (full test suite must pass; agent continues if it doesn't)

Context      →  Session start: ensure every session begins from the same baseline
                (current state, active task, reminders of key constraints)
```

The most important design principle: **use prevention sparingly.** Only block operations
that are genuinely hard to undo or represent fundamental process violations. Over-blocking
creates friction that engineers work around, undermining the enforcement layer entirely.
Style issues belong in the correction layer. The prevention layer is for integrity violations.

### If your tooling doesn't support hooks

The enforcement layer can be implemented in CI even without local hooks. The tradeoff is
feedback latency: local hooks give the agent immediate feedback and allow self-correction
within the same session; CI-only enforcement catches problems after the work is done. Local
+ CI is the recommended pattern — local for fast feedback, CI as the final gate.

### Org-level reusability

Hook configurations are among the highest-leverage org-level investments. A shared hook
library — version-controlled, documented, and standardized across teams — means every new
project starts with battle-tested enforcement rather than building from scratch.

Separate the org-wide hooks (run tests, enforce formatting, block destructive commands)
from project-specific hooks (enforce project-specific naming conventions, validate
domain-specific data shapes). Org-wide hooks live in a shared repository. Project-specific
hooks live in the project.

---

## Section 4: Task Structure and Issue Templates

### What it is

The way work is broken down and described to agents has as much impact on output quality
as the spec itself. A vague ticket produces vague code. A ticket that specifies inputs,
outputs, failure behaviors, and a definition of done produces code that matches the spec.

### The minimum viable taxonomy

Every AI-assisted project needs at minimum four types of work items:

**Test tasks** — "Write the tests for this module."
In a TDD workflow, test tasks precede implementation tasks. The test file is the executable
specification — the most precise possible statement of what the implementation must do. A
test task must specify: happy path cases, failure mode cases, edge cases (especially empty
input), and mocking strategy. Tests must be confirmed *failing* before the implementation
task is opened. This is the TDD discipline: red before green.

**Implementation tasks** — "Build this module."
Must specify: what module, what it receives, what it produces, what failure behaviors are
required, what the definition of done is, and what is explicitly out of scope. The out-of-
scope field is as important as the requirements — it prevents scope creep before the
session begins.

**Scaffolding tasks** — "Set up the conditions for implementation to begin."
Tooling, project structure, CI configuration, test infrastructure, agent configuration.
These tasks have no paired test tasks — their acceptance criteria are stated explicitly
in the ticket. Scaffolding tasks are almost always on the critical path and almost always
underestimated. Run them as a dedicated phase before feature development begins.

**Decision tasks** — "A question has arisen that requires human input before work continues."
When an agent encounters a genuine ambiguity — one where two interpretations would produce
structurally different code — the correct response is to surface it, not resolve it silently.
Decision tasks are the mechanism. They block the dependent implementation task until a human
makes the call. Track them: the ratio of decision tasks to implementation tasks is a direct
measurement of spec quality. A high ratio means the spec needs work before the next project.

### What makes a good ticket

The test: could an agent open this ticket, read only its contents and the spec sections
referenced, and begin work without a follow-up conversation?

If yes: the ticket is good.
If no: find what's missing and add it to the template.

The most common missing elements, in order of frequency:

1. **Explicit out-of-scope** — what this task must not do
2. **Failure mode requirements** — what happens when things go wrong
3. **Empty input behavior** — what happens when the input is empty or zero
4. **Interface specification** — exact input and output types
5. **Definition of done** — the checkable conditions that close the task
6. **Paired [TEST] issue closed** ([IMPL] tasks) — TDD discipline: implementation must not begin before the test file is written and confirmed failing

### Org-level reusability

Issue templates are pure org-level infrastructure. The taxonomy (implementation, test,
scaffolding, decision) applies to every project. The template structure applies to every
project. The only project-specific content is the filled-in fields.

Build the templates once at the org level. Distribute them via a shared GitHub organization
template repository, a Linear template library, or equivalent. Every new project inherits
them automatically. Refinements based on what agents actually need propagate to all
future projects.

---

## Section 5: Scaffolding Phase

### What it is

Scaffolding is the work that creates the conditions for feature development — not the
features themselves. It runs as a dedicated phase before any feature ticket is opened.

The output of scaffolding is a repository where:
- The directory structure matches the spec
- The toolchain is installed and configured
- A single command runs all quality gates and passes on an empty codebase
- The test infrastructure exists (test directories, fixtures, mocks, CI pipeline)
- The agent briefing document is in place
- The enforcement layer is active

When scaffolding is done, the first feature ticket can be opened with confidence that
quality enforcement is already running.

### Why it's a dedicated phase

Scaffolding done as an afterthought — "we'll add CI later," "we'll set up linting once
the code starts taking shape" — produces a window of entropy between the first commit
and the first quality gate. Agents operating in that window produce code without feedback,
and the code they produce sets the patterns other agents follow. Patterns established
without quality enforcement are the hardest to change later.

A rule of thumb: the quality gates you put in place on day one are the quality gates you
will have at launch. The cost of retrofitting enforcement is always higher than the cost
of establishing it first.

### Sequencing scaffolding tickets

Scaffolding tasks have their own dependency graph. A representative sequence:

```
1. Directory structure           → creates the skeleton
2. Package management + config   → enables dependency installation
3. Linting + type checking       → enables static analysis
4. Test framework config         → enables test execution
5. Quality gate command          → combines 3 and 4 into a single command
6. Test infrastructure           → mocks, fixtures, helpers for feature tests
7. Agent briefing document       → project-specific content
8. Enforcement layer             → hooks or CI checks
9. CI pipeline                   → mirrors local quality gates
```

Each of these is a separate ticket with its own definition of done. Do not bundle them.
Bundled scaffolding tickets produce partial completion and unclear status.

---

## Section 6: The Build-Once / Reuse-Many Decision

### The organization as a platform

The pre-implementation phase is where the difference between "an organization that uses AI
tools" and "an organization with AI infrastructure" becomes visible.

An organization that uses AI tools runs pre-implementation work from scratch for each
project. An organization with AI infrastructure reuses the following across every project:

| Artifact | Build once at org level | Customize per project |
|---|---|---|
| Spec evaluation framework | Dimensions, weights, scoring rubric | Domain-specific concerns |
| Agent briefing template | Structure, required sections, org standards | Project architecture, conventions |
| Enforcement layer (hooks) | Org-wide quality gates, security policies | Project-specific validations |
| Issue taxonomy + templates | Task types, template structure | Project-specific fields |
| Prompt libraries | Common patterns, system message templates | Domain/product-specific prompts |
| Shared agent skills/commands | Reusable agent capabilities | Project-specific commands |
| CI quality gate pipeline | Test + lint + type check workflow | Project-specific thresholds |
| Onboarding protocol | "Read these three documents" pattern | Which documents per project |

### The compounding effect

Each project run through this process produces two things: the software, and a refinement
to the org's AI infrastructure. A hook that catches a new class of problem gets added to
the shared library. A spec gap that caused rework gets added to the evaluation rubric. An
issue template field that turned out to be essential gets standardized.

The first project run through this process is the most expensive. The tenth is
significantly cheaper, and produces higher-quality output, than the first project would
have produced without the infrastructure.

### How to sequence the org-level investment

Don't try to build everything upfront. The recommended sequence:

**First project:** Build everything project-specific. Accept higher setup cost.
Explicitly capture what was built and why (as you go, not afterward).

**After first project:** Extract the org-generic pieces. Create the templates and shared
library. Document the decisions made.

**Second project:** Use the templates. Identify what's missing. Add it.

**Ongoing:** Treat the shared library as a product with an owner. It needs the same care
as any shared internal tool.

---

## Section 7: Connecting Pre-Implementation to the Agile Cycle

### Sprint zero, not sprint never

Pre-implementation is sprint zero. It has a backlog (the checklist), a definition of done
(all items checked), and a timebox. For a small team starting a new project, two to three
days is a reasonable target for the first time through. For teams reusing org-level
infrastructure, half a day to a day.

Once pre-implementation is complete, the project enters normal sprint cadence. The
difference from a non-AI-assisted team is that quality enforcement is automated, agent
context is persistent, and many of the "remember to..." reminders that live in a human
team's collective memory are encoded in the briefing document and enforcement layer.

### How this integrates with your existing process

Pre-implementation sits between spec sign-off and sprint 1 planning. It does not replace
planning — it informs it. The scaffolding phase produces a working repository. Sprint 1
planning produces the first feature tickets, written against the issue templates
established in pre-implementation.

The `[DECISION]` task type integrates directly with your normal sprint cadence. Decision
tasks that surface during implementation are triaged in the next sprint planning or async,
same as any other blocker. The difference is that they are captured as permanent artifacts
rather than resolved in a Slack thread and forgotten.

**Inline comments vs. [DECISION] issues:** Within a session, agents surface ambiguity
using an inline `DECISION NEEDED:` comment on the active GitHub Issue (quick, low-friction,
no context switch). When that ambiguity is resolved, it is captured in the issue comments.
Open a separate `[DECISION]` issue only when the ambiguity is significant enough to warrant
its own tracking artifact — typically when the decision affects multiple issues, changes a
public interface, or needs to be referenced by future issues. The inline comment is the
default; the [DECISION] issue is for decisions with broader scope.

### The feedback loop

The pre-implementation artifacts are the primary feedback mechanism for AI-assisted
development quality. At the end of each project (or major milestone):

- How many `[DECISION]` tasks were opened? (Spec quality signal)
- Which quality gates blocked most frequently? (Enforcement calibration signal)
- Which sections of the briefing document were most referenced? (Priority signal for future templates)
- Which issue template fields were most often incomplete? (Template refinement signal)

These metrics don't require new tooling. They're inherent in the artifacts you've already
built. The organization that collects and acts on them compounds faster than the one that
ships projects and moves on.

---

## Quick Reference: Roles and Responsibilities

| Role | Pre-implementation responsibilities |
|---|---|
| **Engineering leader / VP** | Own the org-level infrastructure (templates, shared hooks, evaluation rubric). Set the standard for what "implementation-ready" means. |
| **Team lead** | Own the project-specific briefing document. Review and approve spec quality score. Write the first set of issue templates filled in with project context. |
| **Senior engineer** | Own the scaffolding phase. Configure the enforcement layer. Validate that quality gates run correctly before the first feature ticket. |
| **All engineers** | Understand the briefing document and issue taxonomy before the first session. Open `[DECISION]` tasks rather than resolving ambiguity silently. |
| **AI agent** | Execute scaffolding and feature tickets. Raise `[DECISION]` tasks when encountering genuine ambiguity. Respect the enforcement layer. |

---

## Summary

Pre-implementation is the phase that determines whether your AI-assisted development
produces consistent, high-quality, maintainable software — or whether it produces fast
first drafts that require extensive human correction.

The investment is front-loaded. The return compounds across every ticket, every session,
and every project that follows. For an organization building AI engineering as a
capability, the pre-implementation artifacts — the spec evaluation framework, the briefing
document template, the enforcement layer, the issue taxonomy — are not project overhead.
They are the infrastructure.

The checklist is not a gate to clear and forget. It is a baseline to establish and improve.
Start with enough to prevent the most expensive classes of rework. Iterate from there.
That is the agile way to build infrastructure — incrementally, with feedback, compounding
over time.

---

*This chapter is part of the AI Engineering Playbook.*
*Reference implementation: ai-radar (Python + Claude Code).*
