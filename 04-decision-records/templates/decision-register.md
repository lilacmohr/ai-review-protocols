# Decision Register

A running index of all Level 1 and Level 2 decisions made on this project. Each row
links to the full Decision Record. Add a row each time a record is committed.

The register is append-only. To supersede a decision, add a new row and update the
Status column of the old row — do not delete or edit past entries.

---

| ID | Date | Level | Title | Status | Record |
|----|------|-------|-------|--------|--------|
| DR-001 | YYYY-MM-DD | 1 or 2 | Short decision name | accepted | [link](../decisions/DR-001-title.md) |

---

## Status values

| Status | Meaning |
|--------|---------|
| `proposed` | Decision is under discussion |
| `accepted` | Decision is in effect |
| `superseded` | Replaced by a later decision (link the newer row) |
| `deprecated` | No longer relevant; context it addressed is gone |

---

## Revisit schedule

Pull this register up at each quarterly planning cycle. For each `accepted` row, check:

1. Has the revisit date passed?
2. Have any of the revisit signals in the linked record fired?

If yes to either: schedule a 30-minute review of the decision before the next planning
increment.

---

## Where records live

Individual Decision Records live alongside the code they govern — either in the PR
that introduced the decision or in a `docs/decisions/` directory at the repo root.
The register is the index; the record is the source of truth.
