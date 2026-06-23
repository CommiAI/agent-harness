---
name: add-pr-video-explainer
description: Extension of rpi:describe-pr that renders a short technical walkthrough video explainer of a PR with hyperframes — a deep-dive on the architecture and how the change actually works, grounded in the real diff and before/after code, from the same PR facts and artifacts (diff, pr-walkthrough.html, pr-description.md) plus the rpi-addon:qa GIFs as the UAT payoff. Invoked alongside describe-pr.
---

# Create PR Video Explainer

You build a short, narrated **technical walkthrough video** for a pull request — the same depth a senior reviewer gets from reading `pr-walkthrough.html`, but watchable. It teaches the architecture: the problem and its context, the operating principles behind the design, how the change actually works under the hood (data flow, key components, real before/after code), what was deliberately left alone, and then a real flow proving it works. This skill runs as an **extension of `rpi:describe-pr`**: it consumes the PR facts and artifacts describe-pr produced (the diff, `pr-walkthrough.html`, and `pr-description.md`), reuses the `rpi-addon:qa` GIFs for the UAT payoff beat, and renders the result with **hyperframes**.

**CRITICAL:**
- This skill runs alongside / after `rpi:describe-pr`. Do not re-derive PR facts — reuse describe-pr's artifacts in the task directory. In particular, the `pr-walkthrough.html` NODES are your primary source: the video is the watchable form of that walkthrough.
- Renderer is **hyperframes** (use the `hyperframes` skill family directly). Do NOT use the generic `pr-to-video` baseline — see "What the generic baseline gets wrong" below.

## What the generic baseline gets wrong (design constraints)

The generic PR-to-video baseline is the wrong shape for this skill. Build against these constraints:

- **No music.** Do not generate or attach BGM.
- **It is a TECHNICAL deep-dive, not a user-story sizzle reel.** This is the central rule. The audience is a technical reviewer who could read the PR — earn their attention by going *deeper* than the description, not by dramatizing a user's day. The spine is the architecture and the mechanism of the change, not a persona's journey. A high-level "user wanted X, so we shipped X, here it is working" arc is a failure mode: it tells them nothing they couldn't get from the title.
- **Go as deep as `pr-walkthrough.html`.** Match the technical altitude of the walkthrough HTML: how the pieces fit together, what data flows where, why the design is shaped this way, and the real before/after code for the most important changes. Use actual snippets from the diff, not paraphrase.
- **Still a coherent walkthrough, not a disconnected fact dump.** Depth does not mean a random reel of file lists and stat cards. Order the technical beats so each one builds on the last into one continuous explanation — the same logical progression a good code review follows.
- **Must show a real flow — when one exists.** The payoff reuses the GIFs the `rpi-addon:qa` skill captured flat in the task directory: `.humanlayer/tasks/{task-slug}/qa-<flow>.gif`. This is verification that the architecture works end-to-end, not the centerpiece. Do not re-drive the app or fabricate behavior with abstract graphics. **If there are no QA GIFs, omit the UAT beat entirely** — never invent one.

## The walkthrough arc (the spine of the video)

The video is the watchable form of `pr-walkthrough.html`, so **reuse the walkthrough's NODES order** rather than rejecting it. Map the walkthrough's `why` / `principle` / `step` / `kept` / `verify` nodes onto these beats, in order:

1. **Problem & context** — what was broken or missing and the technical constraints around it. Pull from the walkthrough's `why`/problem nodes. Keep it tight; this sets up *why the design is shaped the way it is*.
2. **Architecture & operating principles** — the design at a system level: the key components, how they fit together, the data/control flow, and the principles that drove the decisions. This is the heart of the video — spend the most time here. Pull from the walkthrough's `principle` nodes and intro card.
3. **How it works — the key changes** — walk the most important changes with **real before/after code** from the diff (the walkthrough's `.ba` pairs), explaining the mechanism, not just naming files. Order by the `step` nodes. Show the actual code on screen.
4. **Deliberately NOT changed** — the restraint a reviewer would otherwise question, from the walkthrough's `kept` nodes. Brief, but it signals technical judgment.
5. **See it work (UAT payoff)** — the real flow via the `rpi-addon:qa` GIFs, proving the architecture holds end-to-end. **Skip this beat if no QA GIFs exist.**
6. **Outcome & impact** — what the change unlocks technically and what's now possible.

## Steps to follow:

1. **Locate the describe-pr and QA artifacts:**
   - Find the task directory: `.humanlayer/tasks/{task-slug}/` (or `.humanlayer/tasks/pr-{number}/`)
   - Read `pr-walkthrough.html` **in full** — its NODES (intro card, `why`/`principle`/`step`/`kept`/`verify`, before/after `.ba` pairs, inlined diffs) are the primary script source. Also read `pr-description.md` and any plan/ticket files for context.
   - Check for QA GIFs flat in the task directory: `.humanlayer/tasks/{task-slug}/qa-<flow>.gif` — these feed the UAT payoff beat. If none exist, the UAT beat is omitted.

2. **Gather PR metadata:**
   - Reuse describe-pr's `gh pr view` data — title, number, url, commits, files. Skim the diff itself for the real before/after snippets you'll show on screen.

3. **Build the storyboard / section plan:**
   - Map the walkthrough NODES onto the technical arc above (problem & context → architecture & principles → how it works / before-after code → deliberately not changed → UAT payoff → outcome). One continuous walkthrough, weighted toward the architecture and mechanism beats.
   - For the "how it works" beat, pick the 2–4 most load-bearing changes and lift the actual before/after snippets from the walkthrough's `.ba` pairs / the diff — show code on screen, narrate the mechanism. Omit the UAT beat if there are no QA GIFs.
   - Consider a simple architecture/data-flow diagram (e.g. a hyperframes diagram beat) for the principles section when the change spans multiple components.

4. **Generate narration:**
   - Explainer-grade, technical narration that teaches the mechanism — no music track. Use a **local TTS provider**. Narrate the code and architecture; don't narrate a persona's feelings.

5. **Render the video with hyperframes:**
   - TODO (which hyperframes workflow, resolution/length) — do NOT wrap the `pr-to-video` skill for now; build directly on the `hyperframes` skill family.

6. **Write outputs to the task directory:**
   - `.humanlayer/tasks/{task-slug}/pr-video-explainer.mp4` (and any intermediate artifacts)
   - Capture the cloud permalink from the hook response
