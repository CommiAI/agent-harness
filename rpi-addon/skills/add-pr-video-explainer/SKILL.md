---
name: add-pr-video-explainer
description: Extension of rpi:describe-pr that renders a short technical walkthrough video explainer of a PR with hyperframes — a deep-dive on the architecture and how the change actually works, grounded in the real diff and before/after code, from the same PR facts and artifacts (diff, pr-walkthrough.html, pr-description.md) plus the rpi-addon:qa GIFs as the UAT payoff. Invoked alongside describe-pr.
---

# Create PR Video Explainer

You build a short, narrated **technical walkthrough video** for a pull request — the same depth a senior reviewer gets from reading `pr-walkthrough.html`, but watchable. It teaches the architecture and the mechanism of the change: how the pieces fit, where data flows, why it is shaped this way, the real before/after code, and a real flow proving it works. This skill is an **extension of `rpi:describe-pr`** and renders with **hyperframes**.

**CRITICAL:**
- Run alongside / after `rpi:describe-pr`. **Reuse its artifacts in the task directory — do not re-derive PR facts.** The `pr-walkthrough.html` NODES (intro card, `why`/`principle`/`step`/`kept`/`verify`, before/after `.ba` pairs, inlined diffs) are your primary script source; `pr-description.md` and any plan/outline/ticket files are supporting context.
- Renderer is **hyperframes** (use the `hyperframes` skill family directly). Do **not** wrap the generic `pr-to-video` baseline.
- **No music.** Local TTS. The narration teaches the code and architecture — it does not dramatize a persona's day.
- It is a **technical deep-dive, not a user-story sizzle reel.** Earn a reviewer's attention by going *deeper* than the description, at the altitude of `pr-walkthrough.html`. Use real snippets from the diff, not paraphrase. A "user wanted X, we shipped X, here it works" arc is a failure.

## The two diagram beats (hard contracts)

These are the spine of the technical section. Both are derived from the diff and the walkthrough NODES — specify them precisely; let the model storyboard everything else.

### 1. System architecture + deviation from the outline

The component-level topology: the services/modules the change touches and how they connect (e.g. `Portal/WhatsApp → Gateway → Agents → store → Model`). Pair it with the **deviation analysis reused from `pr-description.md`'s "Deviations from the plan" section** — implemented-as-planned vs. deviations/surprises vs. additions not in plan vs. planned-but-not-built. Do **not** re-run `rpi:implementation-reviewer`; describe-pr already produced this. This beat answers *what got built and how it differs from what we said we'd build*.

### 2. Call graph from the entry point

The fine-grained execution view, in the top-down format a reviewer follows when reading code. Rules:
- **Rooted at the entry point(s) the diff actually touches** — one graph per entry point if there are several. Not the whole system.
- **Function/method granularity** with the **real symbol names from the diff** (`handleUpload()`, `presignPut()`), not service boxes.
- **Every branch drawn**, with edges **labeled by their condition** — including the failure/error paths (`If error`, `if presign fails`). The error branches are the point, not an afterthought.
- **Data flow on the edges**: what is passed between nodes (`artifacts[]`, `threadId`).
- **Changed nodes visually distinguished** from existing ones, so a reviewer sees the delta.
- **Routing rule:** emit this graph only for **flow-shaped** changes (handler / pipeline / job / event / agent turn). For cross-cutting changes (rename, dep bump, config/schema migration), a call graph is trivial or misleading — skip it and lean on Beat 1 plus before/after code instead.

## The rest of the video

One continuous walkthrough, **ordered by the `pr-walkthrough.html` NODES**, weighted toward the two diagram beats and the mechanism. Around them, the model decides the storyboard: a tight problem/context setup, the most load-bearing before/after code changes (real snippets from the `.ba` pairs), the brief "deliberately NOT changed" restraint, and the outcome. The UAT payoff reuses the `rpi-addon:qa` GIFs captured flat in the task dir (`.humanlayer/tasks/{task-slug}/qa-<flow>.gif`) as proof the architecture holds end-to-end — **omit this beat entirely if no QA GIFs exist; never fabricate one.**

## Workflow

1. **Locate artifacts.** Find the task dir (`.humanlayer/tasks/{task-slug}/` or `.../pr-{number}/`). Read `pr-walkthrough.html` in full, plus `pr-description.md` (the deviation section) and the outline/plan. Skim the diff for the real before/after snippets and the symbol names the call graph needs. Check for `qa-<flow>.gif` files.
2. **Build the two diagrams + storyboard.** Construct the architecture+deviation beat and the entry-point call graph per the contracts above, then order the surrounding beats by the walkthrough NODES.
3. **Narrate.** Explainer-grade technical narration via a **local TTS provider**. No music.
4. **Render with hyperframes.** Build directly on the `hyperframes` skill family.
5. **Write outputs.** `.humanlayer/tasks/{task-slug}/pr-video-explainer.mp4` (plus intermediate artifacts); capture the cloud permalink from the hook response.
