---
name: cross-system-probe
description: >
  Interrogate the engineer's mental model of a system they don't primarily own,
  before they propose a change to it. Use when asked to "run the cross-system probe",
  "probe my understanding of [system]", "quiz me before I touch [system]", or when
  a PR crosses a service boundary or shared contract. The goal: surface knowledge
  gaps before the PR, not after the incident.
argument-hint: 'system or service name (e.g. "the payments service")'
---

# Cross-System Understanding Probe

Use this before proposing a change to a system you don't primarily own. Run it for
~15 minutes. The gaps it surfaces are worth finding before the PR, not after the incident.

---

## The Core Probe

> "I'm about to make a change to [system name]. Before I do, I want you to interrogate
> my mental model of it. Ask me questions one at a time about:
>
> 1. What this system does and why it exists
> 2. What guarantees it makes to callers (and what it explicitly does NOT guarantee)
> 3. What the main failure modes are and how they surface
> 4. What other systems depend on it and how
> 5. Why it's designed the way it is — what constraints or history shaped it
>
> Be adversarial. If my answer is vague, push back. If I say 'I think' or 'probably,'
> ask me to be specific or admit I don't know."

---

## After the Probe — Gap Summary

> "Based on my answers, summarize:
> - Where my understanding was solid
> - Where my understanding was uncertain or vague
> - What I didn't know at all
> - Which gaps are most likely to cause a problem given the change I'm about to make"

---

## Contract-Specific Probe

If you're touching a service boundary or shared contract:

> "Ask me to explain the contract for [service/API/interface] as if I were explaining
> it to a new engineer joining the team. Then tell me what I got wrong, what I left
> out, and what I seemed uncertain about."

---

## Architecture Reasoning Probe

If you're unsure about why the system is structured a certain way:

> "I'm going to describe [system's] architecture as I understand it. After I'm done,
> ask me why — why each major structural choice was made. Push on anything where my
> 'why' is weak or missing."

---

## When to Use Each

| Situation | Use |
|-----------|-----|
| Cross-team PR or service boundary change | Core Probe |
| Touching an API or shared contract | Contract-Specific Probe |
| Inherited codebase or post-reorg ownership | Core Probe + Gap Summary |
| Debugging an unfamiliar service | Architecture Reasoning Probe |
| Onboarding to a new system | All three, in sequence |
