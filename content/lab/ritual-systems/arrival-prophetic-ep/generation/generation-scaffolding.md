---
title: "Generation Scaffolding"
status: active
layer: lab
---

This document instantiates the **generation scaffolding** for the frozen ritual system **Arrival / Prophetic EP (v1.0)**.

## Directory Structure

```
generation/
├─ prompt-pairs/
│  ├─ track-01.md
│  ├─ track-02.md
│  ├─ track-03.md
│  ├─ track-04.md
│  ├─ track-05.md
│  ├─ track-06.md
│  ├─ track-07.md
│  └─ track-08.md
└─ iteration-log.md
```

> Note: Track numbering aligns strictly with the frozen schema (Tracks 1–8). No additional tracks are permitted.

---

## prompt-pairs/ — Template (Applied Per Track)

Each `track-0X.md` MUST follow this exact structure.

```
# Track 0X — Prompt Pair

## Style Prompt (Frozen)
[Insert the approved style prompt derived verbatim from the track schema.]

## Lyric Prompt (Generation Target)
[Insert the generation prompt referencing ritual function, constraints, and exclusions.]

## Constraints Checklist (Pre-Generation)
- [ ] Track belief unchanged
- [ ] Function preserved
- [ ] Sequence position intact
- [ ] Anchor relationship respected
- [ ] No narrative reframing
- [ ] No affective uplift

## Generation Notes
(Empty prior to generation. Used only to note mechanical observations.)
```

---

## iteration-log.md — Log Definition

This file records **every generation attempt**, including rejected outputs.

Entries are append-only.
No retroactive edits.

---

## iteration-log.md — Entry Template

```
### Track 0X — Iteration N

Date:
Mode: First-pass | Refinement | Compression | Extension

Input Reference:
- prompt-pairs/track-0X.md

Outcome:
- Accepted | Rejected | Needs Revision

Drift Check:
- Stylistic drift: Yes / No
- Ritual function drift: Yes / No
- Constraint violation: Yes / No

Notes:
(Brief, mechanical. No interpretation.)

Freeze Status:
- Frozen v1.0.X | Not Frozen
```

---

## Governance Reminder

- Canon is frozen
- Schemas are immutable
- Rejection is enforcement, not failure
- Generation exists to _instantiate_, not explore
