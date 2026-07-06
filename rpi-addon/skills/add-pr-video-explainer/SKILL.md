---
name: add-pr-video-explainer
description: Extension of rpi:describe-pr — builds a narrated technical walkthrough video of a PR with hyperframes, from describe-pr's artifacts (diff, pr-walkthrough.html, pr-description.md) and the rpi-addon:qa GIFs. Invoked alongside describe-pr.
---

# Create PR Video Explainer

You add a short, narrated **technical walkthrough video** to a pull request — the depth a senior reviewer gets from `pr-walkthrough.html`, but watchable. You orchestrate; a **builder subagent** does all the storyboarding, narration, and hyperframes rendering, so none of that work bloats the describe-pr context. Do not re-derive PR facts: `rpi:describe-pr` already produced everything the video needs.

## Workflow

1. **Locate artifacts.** Find the task dir (`.humanlayer/tasks/{task-slug}/` or `.../pr-{number}/`). Confirm `pr-walkthrough.html` and `pr-description.md` exist; note the outline/plan/ticket files and any `qa-<flow>.gif` evidence. Collect absolute paths — the builder starts with an empty context and only sees what you hand it.

2. **Dispatch the builder subagent.** Launch one `general-purpose` subagent via the Agent tool. Its prompt must carry:
   - an instruction to first read the builder contract at `${CLAUDE_SKILL_DIR}/references/video-contract.md` (resolve the variable to the real path before dispatch) — it holds everything else: the two diagram beats, the storyboard rules, the narration and rendering constraints;
   - the absolute artifact paths from step 1, and which QA GIFs exist (or that none do);
   - the output path: `.humanlayer/tasks/{task-slug}/pr-video-explainer.mp4`.

3. **Verify and hand back.** Confirm the `.mp4` exists and the builder's report covers both diagram beats (or justifies skipping the call graph per the contract's routing rule). Capture the cloud permalink from the hook response and surface it alongside the PR description.
