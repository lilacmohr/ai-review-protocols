# ai-review-protocols

A structured multi-agent PR review framework using Claude Code. Designed 
to surface ambiguity, unstated assumptions, and non-obvious issues in 
specs and code before implementation begins.

Built and validated on the [ai-radar](https://github.com/your-org/ai-radar) project.

---

## The Core Idea

Most AI code review tools send a single agent to read a PR. This framework 
sends **nine independent specialized reviewers**, each looking through a 
different lens, then synthesizes their feedback into a prioritized action list.

The result: higher signal, fewer blind spots, and explicit surfacing of 
tradeoffs that a single reviewer would silently resolve.

The framework is also **evaluable** — a structured scorecard lets you 
measure whether the protocol is actually working, which personas add unique 
value, and what to improve.

---

## Repo Structure

```
ai-review-protocols/
├── README.md                        ← you are here
├── protocol/
│   ├── base-instructions.md         ← shared instructions for all reviewers
│   └── synthesis-agent.md           ← synthesizes all reviews into action list
├── personas/
│   ├── architect.md                 ← module boundaries, interfaces, data flow
│   ├── skeptic.md                   ← assumptions, gaps, optimistic scenarios
│   ├── security.md                  ← secrets, OAuth, data handling
│   ├── oss-adoptability.md          ← setup realism, config clarity, docs
│   ├── scope.md                     ← MVP discipline, scope creep
│   ├── domain-expert.md             ← library/API gotchas, real-world data quality
│   ├── legal-compliance.md          ← content rights, ToS, data retention
│   ├── operator.md                  ← day-two ops, failure visibility, recovery
│   └── test-strategy.md             ← testability, verification coverage
│   ├── domain-expert.md             ← library/API gotchas, real-world data quality
│   ├── legal-compliance.md          ← content rights, ToS, data retention
│   ├── operator.md                  ← day-two ops, failure visibility, recovery
│   └── test-strategy.md             ← testability, verification coverage
├── workflows/
│   ├── spec-review.md               ← which personas + order for spec PRs
│   └── implementation-review.md     ← for code PRs (coming soon)
├── evaluation/
    └── review-protocol-scorecard.md ← measure and improve the protocol
└── .claude/
    └── commands/
        └── review-pr.md             ← Level 2 slash command (stub)
```

---

## Quickstart (Level 1 — Manual)

### Prerequisites
- Claude Code CLI installed and authenticated
- GitHub CLI (`gh`) installed and authenticated
- A PR open on GitHub that you want to review

### Run a spec review

**Step 1:** Start a fresh Claude Code session for each reviewer persona.

**Step 2:** Build the prompt by combining two files:
```
protocol/base-instructions.md  +  personas/architect.md
```
Copy both, paste base first then persona, into your Claude Code session.

**Step 3:** Replace `$PR_NUMBER` with your actual PR number.

**Step 4:** Set the recommended model and effort:
```
/model opus
/effort high
```

**Step 5:** Send. The agent will read the diff and post a structured 
review comment to your PR.

**Step 6:** Repeat for each persona (fresh session each time):
- `personas/skeptic.md` — Opus, high effort
- `personas/security.md` — Sonnet, medium effort  
- `personas/oss-adoptability.md` — Sonnet, medium effort
- `personas/scope.md` — Sonnet, medium effort
- `personas/domain-expert.md` — Opus, high effort
- `personas/legal-compliance.md` — Sonnet, medium effort
- `personas/operator.md` — Sonnet, medium effort
- `personas/test-strategy.md` — Sonnet, medium effort

**Step 7:** After all nine have posted, run the Synthesis Agent:
```
protocol/synthesis-agent.md
```
Use Opus, high effort. It will read all nine reviews and post a 
prioritized action list.

**Step 8:** Work from the Synthesis Agent's output. Resolve 
`[HUMAN DECISION]` items yourself. Update the spec. Merge.

### Isolation is important

Each reviewer session must be independent — start a fresh Claude Code 
session for each persona and use `gh pr diff $PR_NUMBER` to avoid 
loading prior reviewer comments. See `workflows/spec-review.md` for details.

---

## Comment Labels

Reviewers use a structured label taxonomy:

| Label | Meaning | Author should... |
|---|---|---|
| `[BLOCKING]` | Something is wrong | Fix before merge |
| `[AMBIGUITY]` | Something is undefined | Make a decision, document it |
| `[FALSE PRECISION]` | Looks decided but isn't | Confirm or mark TBD |
| `[SUGGESTION]` | Worth improving | Consider and decide |
| `[NIT]` | Minor polish | Fix if easy |

`[AMBIGUITY]` and `[FALSE PRECISION]` are treated as merge-blocking. 
Ambiguity at spec time becomes a bug at implementation time.

---

## Evaluating the Protocol

After running a review, fill in `evaluation/review-protocol-scorecard.md`. It tracks:

- Per-comment signal quality (label distribution, confidence, actionability)
- Persona differentiation (did each reviewer find unique issues?)
- Conflict rate (healthy range: 10–30%)
- Protocol Effectiveness Score (PES)
- Retro: what to improve next run

The scorecard is what turns this from a tool into a **learnable workflow**. 
Don't skip it for the first few runs.

---

## Model Recommendations

| Persona | Model | Effort | Rationale |
|---|---|---|---|
| Architect | Opus | high | Deep reasoning about system design |
| Skeptic | Opus | high | Surfaces non-obvious gaps |
| Security | Sonnet | medium | Pattern matching against known concerns |
| OSS Adoptability | Sonnet | medium | Checklist-style usability review |
| MVP Scope | Sonnet | medium | Judgment against clear criteria |
| Domain Expert | Opus | high | Domain reasoning benefits from deeper thinking |
| Legal & Compliance | Sonnet | medium | Pattern recognition against known compliance concerns |
| Operator | Sonnet | medium | Checklist-style operability review |
| Test Strategy | Sonnet | medium | Checklist-style testability review |
| Synthesis | Opus | high | Reasoning across conflicting inputs |

Budget-conscious option: run all personas on Sonnet first. Upgrade 
Architect and Skeptic to Opus if output feels shallow. The difference 
is most pronounced for ambiguity detection and architectural reasoning.

---

## Maturity Levels

This framework is designed to grow with your team:

| Level | What it looks like |
|---|---|
| **Level 1** | Manual copy-paste from this repo. Validated prompts, consistent structure. |
| **Level 2** | Slash commands: `/review-pr 42 architect`. Prompt construction automated. |
| **Level 3** | GitHub Actions trigger on PR label. Fully headless, results posted automatically. |

The repo is currently at **Level 1**. The `.claude/commands/review-pr.md` 
stub documents the Level 2 upgrade path.

---

## Contributing

This framework was designed to be extended. Contributions welcome:

- **New personas** — add a file to `personas/` following the existing format
- **New workflows** — add a file to `workflows/` for different PR types
- **Prompt improvements** — open a PR with before/after scorecard data showing the improvement
- **Scorecard refinements** — the evaluation framework is v0.1 and will improve with use

---

## Background

This framework was developed while building [ai-radar](https://github.com/your-org/ai-radar), 
a personal AI news briefing pipeline. The agentic development workflow — 
spec first, multi-agent review, issue-driven implementation — is documented 
in that project's `AGENTS.md`.

The core insight: **GitHub as agent memory and coordination layer**. 
Issues, PRs, and structured comments are the interface between stateless 
agent sessions and a stateful project. That pattern scales from a personal 
tool to an engineering org.

---

## Relationship to everything-claude-code and oh-my-claudecode

This framework focuses on **spec and design review** — the phase before 
implementation begins. For implementation (code) PRs, we recommend 
combining this framework with the battle-tested agents from 
[everything-claude-code](https://github.com/affaan-m/everything-claude-code),
particularly their code-reviewer, security-reviewer, and language-specific 
reviewer agents.

The two frameworks cover different phases of the development lifecycle:
- ai-review-protocols → spec review → resolve ambiguity early
- everything-claude-code → code review → catch bugs and security issues

[oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) is a 
full multi-agent orchestration platform for Claude Code. If you want 
automated pipeline execution (Autopilot, Team mode, parallel agents), 
it's the right tool. ai-review-protocols is intentionally narrower — 
a focused spec-review protocol with evaluation built in. The two are 
complementary: use oh-my-claudecode to orchestrate your implementation 
workflow, use ai-review-protocols to validate your spec before that 
workflow begins.
