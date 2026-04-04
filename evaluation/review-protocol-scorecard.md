# AI Review Protocol — Evaluation Scorecard

**Project:** <!-- e.g. ai-radar -->  
**PR:** <!-- e.g. #3 — Add SPEC.md -->  
**PR Type:** <!-- Spec / Architecture / Implementation / Docs -->  
**Date:**  
**Evaluator:**  
**Personas run:** <!-- Architect / Skeptic / Security / OSS / Scope / Domain Expert / Legal & Compliance / Operator / Test Strategy -->  
**Total session time (approx):**

---

## 1. Per-Comment Log

One row per comment posted by any reviewer agent. Fill in `Unique?` and `Actionable?` yourself after reading all reviews.

| # | Reviewer | Label | Section | Confidence | Unique? | Actionable? | Addressed? | Notes |
|---|---|---|---|---|---|---|---|---|
| 1 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 2 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 3 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 4 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 5 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 6 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 7 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 8 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 9 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 10 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 11 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 12 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 13 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 14 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |
| 15 | | | | /10 | Y/N | Y/N | Y/N/Partial/N-A | |

> Add rows as needed. Label values: `BLOCKING` `AMBIGUITY` `FALSE PRECISION` `SUGGESTION` `NIT`  
> Unique = not flagged by any other reviewer. Actionable = you did or seriously considered acting on it.  
> Addressed = only fill in for BLOCKING and AMBIGUITY comments.

---

## 2. Per-Reviewer Summary

Complete one block per persona after filling in the comment log.

### 🏗️ Architect
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding** (best catch this reviewer made):

**Weakness** (where this reviewer underperformed or went off-script):

---

### 🔍 Skeptic
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

### 📦 OSS Adoptability
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

### 🔒 Security
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

### ✂️ MVP Scope
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 | 
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

### 🔬 Domain Expert
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

### ⚖️ Legal & Compliance
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

### 🔧 Operator
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

### 🧪 Test Strategy
| Metric | Count |
|---|---|
| Total comments | |
| BLOCKING | |
| AMBIGUITY | |
| FALSE PRECISION | |
| SUGGESTION | |
| NIT | |
| Avg confidence | /10 |
| Unique findings | / total |
| Actionable rate | / BLOCKING+AMBIGUITY |
| Format compliant | Y/N |

**Standout finding:**

**Weakness:**

---

## 3. Conflict Log

One entry per pair of reviewers that gave conflicting guidance on the same issue.
If none, write "No conflicts detected."

```
Conflict #1
  Reviewer A: [persona] [label] — summary of their position
  Reviewer B: [persona] [label] — summary of their position
  Section: 
  Resolution: Human decision / Compromise / Deferred / Rejected both
  Notes:

Conflict #2
  Reviewer A:
  Reviewer B:
  Section:
  Resolution:
  Notes:
```

---

## 4. Ambiguity Detection Quality

Assess whether the dedicated ambiguity scan instruction did its job independently of each reviewer's primary lens.

| Question | Answer |
|---|---|
| Total [AMBIGUITY] comments across all reviewers | |
| Did different reviewers flag *different* ambiguities? | Y/N |
| Did any reviewer's ambiguity findings look identical to another's? | Y/N — which ones? |
| Were any ambiguities flagged that you genuinely hadn't considered? | Y/N — list them |
| Did the ambiguity pass feel like a separate scan or just part of the primary lens? | |

**Most valuable ambiguity finding:**

**Assessment:** Was the ambiguity instruction pulling its weight, or was it redundant with the persona's natural focus?

---

## 5. Protocol Effectiveness Score (PES)

Calculate after completing sections 1–4.

| Metric | Formula | Target | Actual | Pass? |
|---|---|---|---|---|
| **Signal density** | (BLOCKING + AMBIGUITY) / total comments | > 50% | % | |
| **Persona uniqueness** | avg(unique per reviewer) / total comments | > 40% | % | |
| **Actionability** | addressed / (BLOCKING + AMBIGUITY) | > 70% | % | |
| **Format compliance** | reviewers on-format / 9 | 9/9 | /9 | |
| **Conflict rate** | conflict pairs / total comments | 10–30% | % | |
| **Confidence calibration** | high-conf comments that were actionable vs low-conf | higher = better | | |

> **Conflict rate interpretation:**  
> < 10% — personas may be too similar or too deferential to each other  
> 10–30% — healthy independent perspectives  
> > 30% — persona scopes overlap too much or are poorly bounded

**Overall PES assessment:** STRONG / ADEQUATE / NEEDS IMPROVEMENT

---

## 6. Retro — What to Improve

### What worked well
<!-- 2–3 specific things with examples from the comment log -->

### What didn't work
<!-- Be honest. Noisy reviewers, off-format output, missed obvious issues, etc. -->

### Prompt improvements identified
<!-- Per reviewer — what would you change in the prompt for next time? -->

| Reviewer | Improvement |
|---|---|
| Architect | |
| Skeptic | |
| OSS Adoptability | |
| Security | |
| MVP Scope | |
| Domain Expert | |
| Legal & Compliance | |
| Operator | |
| Test Strategy | |

### Persona changes
<!-- Should any persona be dropped, merged, or replaced? Any new persona worth adding? -->

### Label/format changes
<!-- Did the BLOCKING/AMBIGUITY/FALSE PRECISION/SUGGESTION/NIT taxonomy work? -->

### Threshold changes
<!-- Was the 6/10 confidence floor right? Too high, too low? -->

---

## 7. Net Value Assessment

Answer these honestly — this is the section most useful for recommending this protocol to others.

**Did the agents catch anything you genuinely wouldn't have caught in self-review?**

**Did running 9 reviewers find meaningfully more than 5 would have?**
<!-- Which of the four extended personas (Domain Expert, Legal, Operator, Test Strategy) added net-new BLOCKING/AMBIGUITY findings? Which were redundant? -->

**Estimated spec quality improvement from doing this (qualitative):**
<!-- e.g. "Resolved 3 real ambiguities that would have caused implementation bugs" -->

**Time cost vs. value assessment:**
<!-- Was the session time worth it relative to what was caught? -->

**Would you recommend this protocol to another engineer on your team?**
<!-- Y/N and why — this becomes your talking point -->

---

## 8. One-Page Summary

*Complete this last. This is what you share with others.*

**What we did:**

**Scorecard highlights:**
- Signal density:
- Persona uniqueness:
- Actionability:
- Conflicts detected:
- Most valuable reviewer:
- Least differentiated reviewer:

**What worked:**

**What didn't:**

**What we'd change:**

**Recommendation for teams:**
<!-- What should they adopt, what should they skip, what should they tune first? -->

---

*Template version: 0.1 — update based on retro findings and re-version.*
