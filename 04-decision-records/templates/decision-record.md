# Decision Record Template

Copy this template for every Level 1 and Level 2 decision. Fill it from your
narration — not from the code.

---

## [Title: Short name for the decision]

**Date:** YYYY-MM-DD  
**Author:** [name]  
**Level:** <!-- 1 = system contract | 2 = design decision with lasting consequence | 3 = implementation rationale (use PR description instead) -->  
**Status:** <!-- proposed | accepted | superseded | deprecated -->  
**Supersedes:** <!-- link to prior record if applicable -->

---

### Context

What problem were you solving? What constraints, pressures, or prior decisions shaped
the space you were working in? What would someone need to know to understand why this
decision arose?

### Options Considered

| Option | Summary | Why ruled out (or chosen) |
|--------|---------|--------------------------|
| Option A | | |
| Option B | | |
| Option C | | |

### Decision

What did you decide?

### Reasoning

Why this option? What made the alternatives insufficient? Include the trade-offs you
accepted and the ones you avoided.

### Assumptions

What must be true for this decision to hold up? List them explicitly — these are what
the revisit signals watch for.

- [ ] Assumption 1
- [ ] Assumption 2
- [ ] Assumption 3

### Consequences

What does this decision constrain or enable for others? Who else needs to know about
this?

### Revisit Signals

The observable conditions that would indicate this decision should be reconsidered:

- [ ] Signal 1 (e.g., "if read-to-write ratio on [service] changes significantly")
- [ ] Signal 2 (e.g., "if a second team needs to consume this contract")
- [ ] Signal 3

**Revisit date:** YYYY-MM-DD <!-- Put this on the team calendar. Don't leave it as TBD. -->

---

*Generated from human narration using the
[capture-decision skill](../../03-delivery-cycle/skills/capture-decision/SKILL.md).
Reviewed against narration before committing.*
