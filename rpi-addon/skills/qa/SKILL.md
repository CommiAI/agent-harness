---
name: quality-assurance
description: quality assurance after implementation of a structure plan or structure outline
---

# Quality Assurance 

You are responsible for orchestrating an independent QA pass over an implementation produced by `rpi:implement-plan` or `rpi:implement-outline`. You verify the real user flows work, capture visual evidence, auto-fix defects, and hand a self-contained HTML report back for human review.

**CRITICAL**:
- This skill runs AFTER implementation. Drive the app as a user and delegate fixes to `rpi:implementer-agent` subagent via the Agent tool.
- Use the respective driver to verify real user flow works. E.g. use **agent-browser** skill for ALL browser work. use **ImageMagick**  to create gifs of the browser interactions.
- Read **`.claude/qa.md`** in the target repo for project-specific quality assurance instructions.

## Getting Started

When invoked:
1. Confirm an implementation has just completed (this is a post-implementation gate)
2. Read the structure outline or plan to understand the phases. Note the **task directory** it lives in and set `TASK_DIR=.humanlayer/tasks/{task-slug}` — everything this skill produces (the report and all its evidence) lives under `TASK_DIR`, the HumanLayer artifact system, not a stray folder at the repo root.
3. List out the real user flows needed to be verified for the scope of this quality assurance pass in phases, each flow follows: **steps**, **expected outcome**, and **where to verify** the side effect.
4. Read `.claude/qa.md` in the target project to understand project-specific quality assurance instructions
5. The artifact system is **flat** (no nested folders), so the evidence lands directly in `$TASK_DIR`: one `qa-<flow>.gif` per flow, beside the report at `$TASK_DIR/qa-report.html`. Stitch each GIF from frames in a throwaway scratch dir (`FRAMES=$(mktemp -d)`) so the per-step PNGs never clutter the task directory. `rpi-addon:add-pr-video-explainer` reuses the `qa-<flow>.gif` files from this same task directory.
6. Begin with the first phase
7. Follow the workflow below

## Workflow

For each phase in the quality assurance pass:

### 1. Drive each flow with driver

Perform the steps of the real user flow, verify the expected outcome.
**Build a GIF demo per flow** Take screenshots after each meaningful step into a scratch dir (`$FRAMES/<flow>-NN-<step>.png`), then stitch them with `magick` into `$TASK_DIR/qa-<flow>.gif` — flat in the task directory, named for the flow. That `qa-<flow>` basename is the `gif:` key the report and `embed-qa-gifs.sh` use. Each frame is a deliberate checkpoint that maps to a step and assertion.
If the outcome is not expected, diagnose the issue and launch the `rpi:implementer-agent` subagent via the Agent tool to fix it, then re-run the affected flow. Repeat up to **3 rounds** or until it passes.

### 2. Build the HTML report as an inline artifact

The report is a **self-contained inline HumanLayer artifact** written flat into the task directory (like `pr-walkthrough.html`), beside its `qa-<flow>.gif` evidence — there is no `qa-report/` folder. Because it renders in the cloud where relative paths don't resolve, the flow GIFs are **base64-embedded** by a helper script — you never hand-paste base64.

1. Copy the template into the task directory:

   ```bash
   cp "${CLAUDE_SKILL_DIR}/references/report_template.html" "$TASK_DIR/qa-report.html"
   ```

2. Read the template top comment, then fill the `FLOWS` array (one object per flow) and the `TITLE` const with the real QA pass. Each flow carries its `verdict` (`pass`/`warn`/`fail`), `name`, one-line `summary`, the ordered `steps` (each `do` / `expect` / `result`, mapping to one GIF frame), optional `notes`, and a `fix` block for any flow that failed then was auto-fixed. Set `gif: "qa-<flow>"` to the basename of `$TASK_DIR/qa-<flow>.gif`; omit `gif` for a skipped flow with no evidence. The header verdict line and stat row derive themselves from `FLOWS`. **Leave the `#gifs` stash empty** — the script fills it. Report faithfully: give skipped or failed flows their own card with the reason.

3. Embed the GIFs deterministically (keeps hundreds of KB of base64 out of your context):

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/embed-qa-gifs.sh" "$TASK_DIR/qa-report.html"
   ```

   It reads every `gif:` key from `FLOWS`, base64-encodes the matching `qa-<key>.gif` sitting beside the report, and writes the stash. Re-run it freely after editing `FLOWS`.

4. **After running the script you MUST `Read("$TASK_DIR/qa-report.html", limit=1)`.** The script edits the file on disk directly; the artifact store does not notice writes it didn't make through the tools, so this `Read` is what re-syncs the embedded GIFs to the cloud. Skip it and the cloud copy keeps the empty stash. Capture the cloud permalink from the hook response.

### 3. Hand back for human review

Surface the `qa-report.html` inline artifact (and its cloud permalink) for review rather than silently closing out; respect any approval gate in `.claude/qa.md`. Then read the final output template and respond following it exactly:

`Read(${CLAUDE_SKILL_DIR}/references/qa_final_answer.md)`

<guidance>
## Resuming
If `$TASK_DIR/qa-report.html` (and its `qa-<flow>.gif` evidence) already exists, trust passed flows and re-run only the failed or skipped ones, unless the user asks for a full re-run. After updating any flow's GIF, re-run `embed-qa-gifs.sh` and then `Read("$TASK_DIR/qa-report.html", limit=1)` to re-sync the cloud copy.
</guidance>
