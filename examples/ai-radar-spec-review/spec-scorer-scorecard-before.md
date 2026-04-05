# Spec Scorer — AI-Readiness Scorecard

**Project:**  
**Spec file:**  
**Run:** <!-- Before review / After review / Other -->  
**Date:**  
**Model used:**  
**Scorer notes:**

---

## Scores

| # | Dimension | Weight | Score (0-10) | Weighted Score | Rationale |
|---|---|---|---|---|---|
| 1 | Unambiguity | 25% | | | |
| 2 | Completeness | 20% | | | |
| 3 | Consistency | 15% | | | |
| 4 | Verifiability | 15% | | | |
| 5 | Implementation Guidance | 10% | | | |
| 6 | Forward Traceability | 5% | | | |
| 7 | Singularity | 5% | | | |
| 8 | Failure Mode Coverage | 3% | | | |
| 9 | Interface Contracts | 2% | | | |
| | **TOTAL** | **100%** | | **[sum of weighted scores]** | |

> **Weighted score calculation:** multiply each Score × Weight, then sum.
> Example: Score 7 × Weight 25% = 7 × 0.25 = 1.75. Sum all nine = ARS.
> Maximum possible ARS = 10.0

**AI-Readiness Score (ARS): ______ / 10**

---

## Score Interpretation

| ARS Range | Interpretation | Recommended action |
|---|---|---|
| 8.5 – 10.0 | **Implementation-ready** | Proceed to issue creation and agent implementation |
| 7.0 – 8.4 | **Nearly ready** | Address highest-weighted dimension gaps, then proceed |
| 5.5 – 6.9 | **Needs work** | Significant revision required before agent implementation |
| 4.0 – 5.4 | **Not ready** | Major spec revision needed. Do not start implementation. |
| 0 – 3.9 | **Concept only** | This is not a spec. Requires fundamental rewrite. |

---

## Per-Dimension Detail

### Dimension 1: Unambiguity (25%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Specific examples from spec:**
<!-- Quote or cite spec sections that drove this score -->

---

### Dimension 2: Completeness (20%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Specific examples from spec:**

---

### Dimension 3: Consistency (15%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Contradictions found:**
<!-- List any internal contradictions with section references -->
| # | Section A | Section B | Nature of contradiction |
|---|---|---|---|
| 1 | | | |
| 2 | | | |

---

### Dimension 4: Verifiability (15%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Unverifiable criteria found:**
<!-- List acceptance criteria or requirements that can't be tested -->
| Module / Section | Criterion | Why unverifiable |
|---|---|---|
| | | |
| | | |

---

### Dimension 5: Implementation Guidance (10%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Undocumented architectural decisions:**
<!-- List key decisions that agents would have to make themselves -->

---

### Dimension 6: Forward Traceability (5%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Traceability gaps:**
| Type | Item | Missing trace |
|---|---|---|
| Orphaned requirement | | No module maps to this |
| Orphaned module | | No requirement covers this |

---

### Dimension 7: Singularity (5%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Compound requirements found:**
<!-- List requirements that should be split -->

---

### Dimension 8: Failure Mode Coverage (3%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**External dependencies without failure behavior:**
| Dependency | Failure mode | Specified? |
|---|---|---|
| | API failure | Y/N |
| | Rate limit | Y/N |
| | Auth expiry | Y/N |
| | Empty response | Y/N |

---

### Dimension 9: Interface Contracts (2%)
**Score:** ___ / 10

**Most important finding:**

**Top improvement (if score < 7):**

**Interface contract completeness:**
| Interface | Input spec? | Output spec? | Error convention? | Empty behavior? |
|---|---|---|---|---|
| | Y/N | Y/N | Y/N | Y/N |
| | Y/N | Y/N | Y/N | Y/N |
| | Y/N | Y/N | Y/N | Y/N |

---

## Priority Improvement List

Ranked by weighted impact — the improvements that will raise ARS the most.

| Priority | Dimension | Current score | Target score | Score delta | Weighted impact | Specific action |
|---|---|---|---|---|---|---|
| 1 | | | | | | |
| 2 | | | | | | |
| 3 | | | | | | |
| 4 | | | | | | |
| 5 | | | | | | |

> **Weighted impact calculation:** (Target - Current) × Weight
> Example: Unambiguity from 5→8 = +3 × 0.25 = +0.75 ARS points

**If only the top 3 items above are addressed, estimated ARS improvement: +____**

---

## Before / After Comparison

*Complete this section when running the scorer a second time after revisions.*

| Dimension | Before score | After score | Delta | Notes on what changed |
|---|---|---|---|---|
| 1. Unambiguity (25%) | | | | |
| 2. Completeness (20%) | | | | |
| 3. Consistency (15%) | | | | |
| 4. Verifiability (15%) | | | | |
| 5. Implementation Guidance (10%) | | | | |
| 6. Forward Traceability (5%) | | | | |
| 7. Singularity (5%) | | | | |
| 8. Failure Mode Coverage (3%) | | | | |
| 9. Interface Contracts (2%) | | | | |
| **ARS Total** | | | | |

**ARS improvement from review + revision: +____**

**Largest single dimension improvement:**

**Did ARS reach the implementation-ready threshold (≥ 8.5)?** Y/N

**If not, what remains before implementation should begin?**

---

*Scorecard version: 0.1*
