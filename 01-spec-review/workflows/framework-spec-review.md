# Workflow: Framework & Content Spec Review

<!-- 
Use this workflow when reviewing a spec for a framework, playbook, 
curriculum, or other non-code artifact intended for human use.

For software/code specs reviewed via GitHub PR, use workflows/spec-review.md instead.
For implementation (code) PRs, use workflows/implementation-review.md instead.
-->

## Is This the Right Workflow?

This protocol has real overhead — five reviewer sessions plus synthesis. 
It earns that cost in specific situations. Use this checklist before deciding.

**Run this workflow if all of these are true:**

- [ ] A spec exists (or you are writing one) *before* production of deliverables begins
- [ ] The output is a body of work — multiple interconnected artifacts (chapters, templates, assessments, reference cards) that need to cohere
- [ ] AI will generate content from this spec — agents will fill any gaps with plausible assumptions
- [ ] The spec serves more than one goal or audience that could pull against each other

**Do not run this workflow if:**

- You are writing a single document (a README, a design doc, a process note) — just write it
- The spec is for software or a code system — use `workflows/spec-review.md` instead
- There is no spec — you're generating content directly, not from a structured plan

**The clearest signal:** if you are writing a spec *so that an agent can produce a series of artifacts from it*, this workflow applies. If you are writing a document, you don't need a spec review — you need an editor.

**Examples of projects where this applies:**
- AI enablement frameworks or operating handbooks being rolled out to a team
- Engineering onboarding programs with multiple structured components
- Consulting deliverable packages (before producing the deliverables)
- Curriculum or training programs with multiple modules

---

## When to Use This Workflow

- Reviewing a spec before producing a framework, guidebook, or playbook
- Reviewing a curriculum or course design before developing content
- Reviewing an AI-generated content strategy before execution
- Any spec where the primary deliverable is something a human reads and 
  acts on — not code that a machine executes

## Why Framework Spec Review Matters

The same principle applies here as in code: ambiguity at spec time becomes 
an inconsistency at production time. AI agents generating content from an 
underspecified framework spec will fill gaps with plausible defaults — 
producing content that is internally plausible but misaligned with intent. 
Multi-persona review forces those gaps into the open before production begins.

Framework specs have distinct failure modes from software specs:
- **Resonance failures** — the framework is correct but doesn't land with 
  its audience
- **Executability failures** — the framework is aspirational but leaves 
  practitioners without enough to act on
- **Consistency failures** — terminology and decisions drift across sections
- **Goal alignment failures** — the spec optimizes for one purpose and 
  under-serves others
- **Build failures** — AI agents given this spec to generate artifacts 
  will make assumptions the author didn't intend

This protocol has a persona for each failure mode.

## Personas to Run

Run personas 1–4 in isolated sessions (no persona should read another's 
output before posting). Persona 5 (Stakeholder Alignment) is independent 
and can also run in isolation. Then run Synthesis.

| # | Persona | File | Recommended Model | Effort | Primary Value |
|---|---|---|---|---|---|
| 1 | Target Audience Skeptic | `personas/framework-spec/target-audience-skeptic.md` | Opus | high | Resonance, specificity, trust |
| 2 | Practitioner Executor | `personas/framework-spec/practitioner-executor.md` | Opus | high | Actionability, implementation gaps |
| 3 | Consistency Auditor | `personas/framework-spec/consistency-auditor.md` | Sonnet | medium | Terminology drift, cross-section contradictions |
| 4 | Build Agent | `personas/framework-spec/build-agent.md` | Opus | high | Execution gaps, forced assumption audit |
| 5 | Stakeholder Alignment | `personas/framework-spec/stakeholder-alignment.md` | Sonnet | medium | Goal balance, audience allocation |

After all five have posted, run Synthesis:

| # | Persona | File | Recommended Model | Effort | Primary Value |
|---|---|---|---|---|---|
| — | Synthesis | `protocol/spec-reviews-synthesis-agent.md` | Opus | high | Consolidated action list |

> **Note on Synthesis:** The existing Synthesis Agent was written for 
> GitHub PR workflows (`gh pr view`). When using it for framework spec 
> review, replace the GitHub PR setup step with: read all reviewer 
> outputs from your shared session or compile them into a single document 
> for the Synthesis agent to read.

## How to Build Each Reviewer Prompt

Combine files by hand:

1. Open `protocol/framework-spec-reviewer-base-instructions.md` — copy 
   the full contents
2. Open your chosen persona file — copy the full contents
3. Paste both together (base first, then persona) into a new Claude session
4. Fill in any **CUSTOMIZE** sections in the persona with specifics 
   from the spec under review
5. Set your model: `/model opus` or `/model sonnet` per the table above
6. Set effort: `/effort high` or `/effort medium`
7. Provide the spec: either paste it inline or instruct the agent to `cat` 
   the file path
8. Send

### Personas that require customization

Three personas require you to fill in spec-specific details before running:

**Target Audience Skeptic** — fill in the reader profile:
- Role, organizational context, prior exposure, and specific frustration

**Build Agent** — specify the target artifact:
- Which deliverable to generate, target audience for that artifact, 
  format constraints

**Stakeholder Alignment** — list the spec's goals and audiences:
- All stated goals (1–N), all intended audiences (primary/secondary/tertiary)

The Consistency Auditor and Practitioner Executor are fully generic and 
require no customization.

## Isolation Protocol

Run each persona in a separate Claude session. Do not share reviewer 
output across sessions until all five have completed.

- Start a fresh session for each persona
- Do not reference prior reviewer output during any of the five independent reviews
- Compile all five outputs before running Synthesis

This isolation ensures findings are independent and the Synthesis agent 
is working from clean, uncontaminated input.

## After Reviews Are Posted

1. Read the Synthesis output for the prioritized action list
2. Address `[BLOCKING]` findings before starting content production
3. Resolve `[AMBIGUITY]` findings by making explicit decisions and 
   documenting them in the spec's decisions log
4. For `[FALSE PRECISION]` findings: either confirm the stated value 
   as a real decision or mark it as TBD
5. Optionally: re-run the Build Agent after spec revisions to verify 
   that generation gaps have closed

## Relationship to the Code Spec Review Workflow

This workflow is a **parallel pattern**, not an extension of 
`workflows/spec-review.md`. The two workflows share:
- The same structured comment format (`**[LABEL]**` with five label types)
- The same isolation protocol
- The same Synthesis Agent

They differ in:
- **Base instructions** — framework review uses `protocol/framework-spec-reviewer-base-instructions.md`; code review uses `protocol/spec-reviewer-base-instructions.md`
- **Personas** — framework review uses `personas/framework-spec/`; code review uses `personas/code-spec/`
- **Setup** — framework review reads a file directly; code review uses `gh pr diff`
- **Persona count** — framework review uses 5 personas; code review uses 9 + ambiguity auditor
