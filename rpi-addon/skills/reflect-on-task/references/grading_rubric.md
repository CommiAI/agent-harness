# Design-artifact grading rubric

You grade the design artifacts (**PRD**, **TDD**, **Structure Outline / Plan**) of a
*completed* task against what was **actually built**. Grading is retrospective: the
implementation and QA already happened, so the honest measure is **drift** — how far
reality diverged from the doc.

Grounded in two recognized practices:
- **ISO/IEC/IEEE 29148** requirements characteristics (complete, correct, consistent,
  verifiable, traceable) — the lens for the PRD.
- **Requirements/design volatility** (a.k.a. Requirements Stability Index) — drift as a
  measurable retrospective signal — the lens for all three artifacts.

## The three dimensions

Score each artifact on these, 0–100, and cite evidence for every score.

| Dimension | Question | How to score |
|---|---|---|
| **Completeness** | Did the doc anticipate the scope that got built? | `anticipated / (anticipated + added-later)`. Penalize every capability/requirement/decision that had to be **added** during implementation or QA that the doc never mentioned. |
| **Accuracy** | Did the doc's decisions survive contact with the code? | `unchanged / total decisions`. Penalize every decision/requirement that was **changed, reversed, or abandoned** during implementation. |
| **Foresight** | Did it flag the hard parts that later bit us? | Start at 100, subtract for each post-implementation iteration/bug whose root cause was something the doc **should have anticipated** but didn't. |

## What to read per artifact

| Artifact | Grade it on | Compare against |
|---|---|---|
| **PRD** (or design-discussion if no PRD) | product scope & requirements drift — what features/edge-cases were added or cut after the fact | `pr-description.md`, the implementation/QA iterations |
| **TDD** (or design-discussion) | technical-decision drift + risk foresight — which architecture/approach choices held, which broke | the diff, debugging/QA sessions, root causes |
| **Outline / Plan** | sequence accuracy — did phases/steps match what was actually done; were steps missing | the implementation sessions, what got reordered or improvised |

If an artifact doesn't exist for the task (e.g. no PRD was created), mark it **N/A** with a
one-line note — don't invent one.

## Rolling up to a grade

Per artifact, take a simple blend (Completeness + Accuracy + Foresight) / 3 → headline %,
then a letter. Lead each card with the single most useful number: **"% of the
implementation this doc correctly anticipated."**

| % | Letter | Reading |
|---|---|---|
| 95–100 | A | Near-perfect; doc predicted reality |
| 85–94 | B | Solid; minor drift |
| 70–84 | C | Real gaps — worth more thought next time |
| 50–69 | D | Major drift; the doc misled the build |
| <50 | F | Doc was largely overtaken by reality |

## Gaps — "watch for next time" (required per artifact)

A score alone doesn't tell the user what to *do* differently. So every artifact card also
carries a short **gaps list**: the concrete things this doc missed, phrased as what to look
out for during that phase on the next feature. Rules:

- One bullet per distinct gap, ordered by impact. 2–4 is typical; an A-grade doc may have one.
- Each gap is **specific and tied to evidence** — name the missing requirement / unhandled
  case / skipped step, and point to the iteration or root cause that exposed it
  (e.g. "no idempotency/retry model for webhooks → iter 1").
- Phrase it as a forward-looking checklist item, not a complaint:
  *"Pin the proration anchor date in the PRD"*, not *"the PRD was vague"*.
- If an artifact has no real gaps, say so in one bullet rather than padding.

These bullets are the part the user actually carries into the next task — make them sharp.

## The point

The grades are a mirror, not a scorecard. The takeaway is **which dimension is weakest, on
which doc, and the specific gaps to pre-empt** — that's exactly what the user should invest
more thought in on the next feature (e.g. "TDD foresight is the recurring weak spot — budget
a risk/unknowns pass"). Every grade and every gap must cite evidence: a drifted requirement,
a reversed decision, a root cause.
