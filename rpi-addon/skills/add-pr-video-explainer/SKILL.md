---
name: add-pr-video-explainer
description: Extension of rpi:describe-pr that renders a short user-story video explainer of a PR with hyperframes — from the same PR facts and artifacts (diff, pr-walkthrough.html, pr-description.md) plus the rpi-addon:qa GIFs. Invoked alongside describe-pr.
---

# Create PR Video Explainer

You build a short, narrated **video explainer** for a pull request, told as a user story — the problem a user faced, the change that fixed it, the fix working in a real flow, and the outcome. This skill runs as an **extension of `rpi:describe-pr`**: it consumes the PR facts and artifacts describe-pr produced (the diff, `pr-walkthrough.html`, and `pr-description.md`), reuses the `rpi-addon:qa` GIFs for the demo beat, and renders the result with **hyperframes**.

**CRITICAL:**
- This skill runs alongside / after `rpi:describe-pr`. Do not re-derive PR facts — reuse describe-pr's artifacts in the task directory.
- Renderer is **hyperframes** (use the `hyperframes` skill family directly). Do NOT use the generic `pr-to-video` baseline — see "What the generic baseline gets wrong" below.

## What the generic baseline gets wrong (design constraints)

The generic PR-to-video baseline is the wrong shape for this skill. Build against these constraints:

- **No music.** Do not generate or attach BGM.
- **It must feel like a STORY, not a fact dump.** This is the central rule. A reel of disconnected facts (file lists, diff highlights, stat cards) is worse than reading the PR — if it isn't a narrative with an arc, the viewer should just read the description. Every section must advance one continuous user story.
- **Must actually explain.** It is an *explainer*, not a sizzle reel — narration teaches what changed and why, grounded in the real diff.
- **Must show a real UAT flow — when one exists.** The UAT payoff reuses the GIFs the `rpi-addon:qa` skill captured at the repo root: `qa-report/<flow>.gif` (frames in `qa-report/<flow>/NN-<step>.png`). Do not re-drive the app or fabricate behavior with abstract graphics. **If there are no QA GIFs, omit the UAT beat entirely** — never invent one.

## The narrative arc (the spine of the video)

The video is told as a **user story** with a setup → resolution → payoff arc. Do NOT reuse describe-pr's NODES order (problem → principles → steps → kept → ship) — that is a reviewer's *fact tree*, great to read, wrong to watch. Map the same PR facts onto this arc instead:

1. **The problem / use case** — who the user is, what they were trying to do, and what was in their way. Establish the stakes. This is the hook.
2. **The turn** — what we changed to solve it, told as "so we…". Grounded in the real diff, but delivered as plot, not a file list.
3. **See it work (UAT payoff)** — the real user flow, shown via the `rpi-addon:qa` GIFs, proving the problem from beat 1 is resolved. **Skip this beat if no QA GIFs exist.**
4. **The outcome** — what is now possible / the impact.

## Steps to follow:

1. **Locate the describe-pr and QA artifacts:**
   - Find the task directory: `.humanlayer/tasks/{task-slug}/` (or `.humanlayer/tasks/pr-{number}/`)
   - Read `pr-walkthrough.html`, `pr-description.md`, and any plan/ticket files for narrative context
   - Check for QA GIFs at the repo root: `qa-report/<flow>.gif` — these feed the UAT payoff beat. If none exist, the UAT beat is omitted.

2. **Gather PR metadata:**
   - Reuse describe-pr's `gh pr view` data — title, number, url, commits, files

3. **Build the storyboard / section plan:**
   - Map the PR facts onto the narrative arc above (problem/use case → the turn → UAT payoff → outcome). One continuous story, not a section per file.
   - Pull the "problem / use case" beat from the ticket + describe-pr's `why` nodes; the "turn" from the diff; the "UAT payoff" from the QA GIFs (omit the beat if there are none).

4. **Generate narration:**
   - Explainer-grade narration; no music track. Use a **local TTS provider**.

5. **Render the video with hyperframes:**
   - TODO (which hyperframes workflow, resolution/length) — do NOT wrap the `pr-to-video` skill for now; build directly on the `hyperframes` skill family.

6. **Write outputs to the task directory:**
   - `.humanlayer/tasks/{task-slug}/pr-video-explainer.mp4` (and any intermediate artifacts)
   - Capture the cloud permalink from the hook response
