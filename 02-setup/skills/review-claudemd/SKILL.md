---
name: review-claudemd
description: >
  Audit the agent briefing document (CLAUDE.md or equivalent) for quality, size,
  overlap with hooks, and missing content. Use this skill whenever someone asks to
  "review CLAUDE.md", "check the agent briefing doc", "audit agent instructions",
  or "is CLAUDE.md good?". Also triggers on: "is my CLAUDE.md too long?", "does
  CLAUDE.md overlap with hooks?", "what's missing from CLAUDE.md?". Run before any
  PR that modifies the briefing document.
---

# CLAUDE.md Evaluator

Audit the agent briefing document against the 7-section quality framework.
Identify size issues, missing rationale, hook overlap, and structural gaps.

## Inputs

Read in order:
1. `CLAUDE.md` (or `.cursorrules`, `copilot-instructions.md`, `.windsurfrules`)
2. `.claude/settings.json` (to check hook overlap)
3. Hook scripts in `.claude/hooks/` (to understand what's already enforced)

If the briefing doc path is non-standard, ask the user to specify.

## Evaluation Criteria

### Size
- **Word count target:** Under 2,500 words
- **Instruction count:** Count lines containing ALWAYS, NEVER, MUST, DO NOT,
  "do not", "required", "must not" — target under 40
- **Warning zone:** 2,000–2,500 words
- **Over limit:** >2,500 words — flag specific sections to trim or externalize

### The 7-Section Framework
Every briefing doc should answer these questions. Check each:

| # | Question | Section name |
|---|---|---|
| 1 | What is this project and what are its priorities? | Project Overview |
| 2 | What is the architecture and data flow? | Architecture |
| 3 | When should the agent act vs. ask? | Autonomy & Decision-Making |
| 4 | What are the code standards? | Language, Runtime & Style |
| 5 | How should failures be handled? | Failure Handling Convention |
| 6 | What are the testing requirements? | Testing Standards |
| 7 | What does "done" mean? | Quality Gates |

### Rationale Coverage
Every behavioral rule (ALWAYS/NEVER/MUST/DO NOT) should have a **Why:** explanation.
Rules without rationale get ignored or cargo-culted. List any rules missing rationale.

### Hook Overlap Analysis
Compare rules in the briefing doc against what hooks already enforce:
- Rules enforced by `PostToolUse` hooks (lint, format, typecheck) → candidate for removal
- Rules enforced by `Stop` hook (tests must pass) → keep in both (rationale still needed)
- Rules enforced by `PreToolUse` hook (no bare git commit, no unapproved packages) → keep in both

**Keep in both:** Rules where the agent needs to understand *why* (not just be blocked).
**Remove from briefing doc:** Purely mechanical rules the linter catches automatically
(formatting whitespace, import ordering) — these are noise.

### Compaction Priority Note
The briefing doc should tell the agent which sections to preserve if the context
window forces compaction. Check for a note in the Project Overview section.

### Content That Belongs Elsewhere
Flag sections that are written for humans (engineering leaders, new hires) rather
than for the agent. These consume instruction budget without improving agent behavior.
They belong in `docs/` with a pointer from the briefing doc.

---

## Output Format

```
CLAUDE.MD AUDIT REPORT
════════════════════════════════════════════════════════════
File: [path]
Audited: [date]

SIZE
────────────────────────────────────────────────────────────
Word count:        XXXX / 2500 limit    [OK / WARNING / OVER]
Instruction count: XX discrete rules    [OK / HIGH]

7-SECTION COVERAGE
────────────────────────────────────────────────────────────
✓ Project Overview          — present
✓ Architecture              — present
✗ Autonomy & Decision-Making — MISSING
✓ Code Standards            — present
✓ Failure Handling          — present
✓ Testing Standards         — present
✓ Quality Gates             — present

RULES WITHOUT RATIONALE
────────────────────────────────────────────────────────────
[List each ALWAYS/NEVER/MUST with no "Why:" explanation.
Quote the rule. Suggest a rationale or flag for author input.]
— None found  (or list)

HOOK OVERLAP ANALYSIS
────────────────────────────────────────────────────────────
Enforced by PostToolUse (lint/format/type):
  Keep (rationale needed): [rules the agent should understand]
  Remove candidate (mechanical): [rules the linter catches automatically]

Enforced by Stop (tests must pass):
  Keep in both: [rules — agent needs context, hook provides guarantee]

Enforced by PreToolUse (guards):
  Keep in both: [rules — agent needs context, hook prevents violation]

OTHER FINDINGS
────────────────────────────────────────────────────────────
Compaction priority note: [present / MISSING]
Human-audience content:   [sections to externalize, or "none found"]

RECOMMENDATIONS
────────────────────────────────────────────────────────────
[Numbered, ordered by impact. Each: what to do, why, estimated word savings
or instruction slot savings.]

VERDICT: PASS ✓ / NEEDS ATTENTION ⚠ / FAIL ✗
  PASS:            All sections present, under word limit, rationale on all rules
  NEEDS ATTENTION: Minor gaps or approaching word limit
  FAIL:            Missing sections, over word limit, or rules without rationale
════════════════════════════════════════════════════════════
```
