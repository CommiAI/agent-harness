---
name: quality-assurance
description: quality assurance after implementation of a structure plan or structure outline
---

# Quality Assurance

You are the **orchestrator** of an independent QA pass over an implementation produced by `rpi:implement-plan` or `rpi:implement-outline`. You never drive the app yourself: every flow is verified by a **driver subagent**, every fix is made by `rpi:implementer-agent`. You hold only the flow list, the verdicts, and the report — the browser noise and screenshots stay in the subagents' contexts, not yours.

**CRITICAL**:
- This skill runs AFTER implementation — it is a post-implementation gate.
- Read **`.claude/qa.md`** in the target repo for project-specific quality assurance instructions, and pass the relevant rules into every driver prompt.
- Everything this skill produces lives in the **task directory**: set `TASK_DIR=.humanlayer/tasks/{task-slug}` from where the outline/plan lives — the HumanLayer artifact system, not a stray folder at the repo root. The artifact system is **flat** (no nested folders): evidence is one `$TASK_DIR/qa-<flow>.gif` per flow, beside the report at `$TASK_DIR/qa-report.html`. `rpi-addon:add-pr-video-explainer` reuses those GIFs from this same directory.

## Getting Started

When invoked:
1. Confirm an implementation has just completed (this is a post-implementation gate)
2. Read the structure outline or plan to understand the phases; note its task directory and set `TASK_DIR`
3. Read `.claude/qa.md` in the target project
4. Enumerate the real user flows to be verified for the scope of this pass, each as: **steps**, **expected outcome**, and **where to verify** the side effect. This list is the contract for the whole pass — every flow ends the run as passed, auto-fixed, or explicitly skipped with a reason.
5. Follow the workflow below

## Workflow

### 1. Dispatch one driver subagent per flow

Launch a `general-purpose` subagent via the Agent tool for each flow — in parallel when flows are independent, serially when one flow's side effects feed the next. Each driver prompt must carry:

- the flow's **steps**, **expected outcome**, and **where to verify**, plus the relevant `.claude/qa.md` rules
- **how to drive**: use the **agent-browser** skill for ALL browser work
- **how to capture evidence**: screenshot each meaningful step into a scratch dir (`FRAMES=$(mktemp -d)`, files `$FRAMES/<flow>-NN-<step>.png`) — each frame a deliberate checkpoint mapping to one step and assertion — then stitch them with **ImageMagick** (`magick`) into `$TASK_DIR/qa-<flow>.gif`, flat in the task directory, named for the flow. That `qa-<flow>` basename is the `gif:` key the report and `embed-qa-gifs.sh` use. The per-step PNGs never land in the task directory.
- **what to return**: a verdict (`pass`/`fail`), the ordered steps each as `do` / `expect` / `result`, notes, the GIF path, and — on failure — a diagnosis of the defect (symptom, suspected files/lines)

The driver observes and reports; it never fixes.

### 2. Fix loop

For each failed flow: hand the driver's diagnosis to an `rpi:implementer-agent` subagent via the Agent tool to fix, then re-dispatch a driver for the affected flow. Repeat up to **3 rounds** per flow or until it passes; after 3, record it as failed with the last diagnosis.

### 3. Build the HTML report as an inline artifact

The report is a **self-contained inline HumanLayer artifact** written flat into the task directory (like `pr-walkthrough.html`), beside its `qa-<flow>.gif` evidence — there is no `qa-report/` folder. Because it renders in the cloud where relative paths don't resolve, the flow GIFs are **base64-embedded** by a helper script — you never hand-paste base64.

1. Copy the template into the task directory:

   ```bash
   cp "${CLAUDE_SKILL_DIR}/references/report_template.html" "$TASK_DIR/qa-report.html"
   ```

2. Read the template top comment, then fill the `FLOWS` array (one object per flow) and the `TITLE` const from the driver reports. Each flow carries its `verdict` (`pass`/`warn`/`fail`), `name`, one-line `summary`, the ordered `steps` (each `do` / `expect` / `result`, mapping to one GIF frame), optional `notes`, and a `fix` block for any flow that failed then was auto-fixed. Set `gif: "qa-<flow>"` to the basename of `$TASK_DIR/qa-<flow>.gif`; omit `gif` for a skipped flow with no evidence. The header verdict line and stat row derive themselves from `FLOWS`. **Leave the `#gifs` stash empty** — the script fills it. Report faithfully: give skipped or failed flows their own card with the reason.

3. Embed the GIFs deterministically (keeps hundreds of KB of base64 out of your context):

   ```bash
   "${CLAUDE_SKILL_DIR}/scripts/embed-qa-gifs.sh" "$TASK_DIR/qa-report.html"
   ```

   It reads every `gif:` key from `FLOWS`, base64-encodes the matching `qa-<key>.gif` sitting beside the report, and writes the stash. Re-run it freely after editing `FLOWS`.

4. **After running the script you MUST `Read("$TASK_DIR/qa-report.html", limit=1)`.** The script edits the file on disk directly; the artifact store does not notice writes it didn't make through the tools, so this `Read` is what re-syncs the embedded GIFs to the cloud. Skip it and the cloud copy keeps the empty stash. Capture the cloud permalink from the hook response.

### 4. Hand back for human review

Surface the `qa-report.html` inline artifact (and its cloud permalink) for review rather than silently closing out; respect any approval gate in `.claude/qa.md`. Then read the final output template and respond following it exactly:

`Read(${CLAUDE_SKILL_DIR}/references/qa_final_answer.md)`

<guidance>
## Resuming
If `$TASK_DIR/qa-report.html` (and its `qa-<flow>.gif` evidence) already exists, trust passed flows and re-dispatch drivers only for the failed or skipped ones, unless the user asks for a full re-run. After updating any flow's GIF, re-run `embed-qa-gifs.sh` and then `Read("$TASK_DIR/qa-report.html", limit=1)` to re-sync the cloud copy.
</guidance>
