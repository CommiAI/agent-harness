---
name: qa
description: Auto-QA pass for the human-layer RPI workflow. You must use this skill when asked to QA an implementation, or after the rpi:implement-plan or rpi:implement-outline skill finishes. Enumerates the user flows in scope, drives them in a real browser via the agent-browser skill, verifies side effects (e.g. emails in Mailpit), records each flow as a GIF, writes a self-contained HTML report under qa-report/, then spawns an implementer agent to auto-fix defects and re-verifies. Reads per-project specifics from .claude/qa.md.
---

# QA — Auto-QA Orchestrator for the human-layer RPI workflow

You are responsible for orchestrating an independent QA pass over an implementation produced by `rpi:implement-plan` or `rpi:implement-outline`. You verify the real user flows work in a browser, capture visual evidence, auto-fix defects, and hand a self-contained HTML report back for human review.

**CRITICAL**:
- This skill runs AFTER implementation. Do NOT re-implement features yourself — drive the app as a user and delegate fixes to an implementer agent.
- Use the **agent-browser** skill for ALL browser work. Do NOT build your own browser automation.
- Everything project-specific lives in **`.claude/qa.md`** in the target repo. The skill itself stays generic. **Never echo credentials into the report or commit them** — `.claude/qa.md` must be gitignored.

## Getting Started

When invoked:
1. Confirm an implementation has just completed (this is a post-implementation gate).
2. Load the project conditions (step 0) — without them you cannot start the app or know which flows matter.
3. Work through the workflow below in order. Present the flow checklist to the human before driving anything.

## Workflow

### 0. Load project conditions

Read `.claude/qa.md` in the target project. It supplies:
- how to start the app + the base URL + a readiness check
- test credentials (login)
- verification services (e.g. Mailpit web UI + API)
- flows to always test
- capture mode (`screenshots` default, or `video`) and any special setup (seed data, feature flags, approval gate)

If `.claude/qa.md` is missing, create it from the template:

`Read(${CLAUDE_SKILL_DIR}/references/qa_conditions_template.md)`

Ask the user for the essentials (or infer from the repo and state your assumptions), write `.claude/qa.md`, ensure it is gitignored, then continue.

### 1. Preflight

- Load the **agent-browser** skill — it drives the browser and takes screenshots.
- Ensure **ImageMagick** is installed: `magick -version` (older installs: `convert -version`). If missing: `brew install imagemagick`. For `capture: video`, also ensure `ffmpeg`.
- Create the artifact dir `qa-report/` (per-flow subdirs created as you go). Make sure `qa-report/` is gitignored.
- Start the app per the conditions file and wait until the readiness check passes.

### 2. Enumerate the user flows in scope

Before driving anything, write out the explicit flow list. Derive it from:
- the plan/outline the implementation was based on,
- the actual change (`git diff` — what user-facing behavior moved),
- the "flows to always test" in `.claude/qa.md`.

For each flow record: **steps**, **expected outcome**, and **where to verify** the side effect (UI assertion, an email in Mailpit, a DB row, a redirect, a toast). **Present this checklist to the user before running.**

### 3. Drive each flow with agent-browser

For each flow, using the agent-browser skill:
- navigate / fill / click step by step; authenticate with the test creds from the conditions file;
- **capture evidence** (see step 4);
- verify the side effect at its verification point — e.g. poll the Mailpit API (`/api/v1/messages`) for the expected email and assert its contents/links;
- capture any console or network errors.

### 4. Build a GIF per flow

**Default — `capture: screenshots` (recommended).** Take a screenshot after each meaningful step into `qa-report/<flow>/NN-<step>.png` (zero-padded `NN` so frame order is correct). Each frame is a deliberate checkpoint that maps to a step and assertion. Stitch:

```bash
magick -delay 120 -loop 0 qa-report/<flow>/*.png qa-report/<flow>.gif
# add -resize 800x if frames are large
```

**Opt-in — `capture: video`.** Use only when motion itself is under test (animations, drag, canvas). Record the flow to `qa-report/<flow>.webm` with agent-browser's video recording, then convert with ffmpeg:

```bash
ffmpeg -i qa-report/<flow>.webm -vf "fps=10,scale=800:-1:flags=lanczos" qa-report/<flow>.gif
```

Note: video→GIF is larger and includes dead waiting time; prefer screenshots unless you need the motion.

### 5. Build the HTML report

Build a self-contained report that renders the GIFs. Copy the bundled template and fill its markers:

```bash
cp "${CLAUDE_SKILL_DIR}/references/report_template.html" qa-report/index.html
```

Replace `{{TITLE}}`, `{{VERDICT}}` (e.g. "3 passed · 1 failed"), `{{SUMMARY}}`, and `{{FLOWS}}` with one card per flow (the template comment shows the card markup). Each card has a verdict badge (✅ pass / ⚠️ warn / ❌ fail), the flow's `<flow>.gif`, the verification result (e.g. Mailpit hit/miss), and any errors with `file:line` where known. GIFs sit beside `index.html`, so relative `src` works when opened in a browser.

Report faithfully: if a flow could not run or was skipped, give it a card with the reason.

### 6. Auto-fix loop — spawn an implementer agent

If there are defects, spawn an **implementer agent** (the Agent tool; in the rpi/humanlayer workflow this is your implement agent) with: the defect, expected vs actual, the evidence path, and the suspected files. Let it fix autonomously.

After fixes, re-run only the affected flows (steps 3–5). Repeat up to **3 rounds** or until green / no further progress, then hand back.

### 7. Hand back for human review

Respect any approval gate declared in `.claude/qa.md` — this is a human-layer workflow, so surface `qa-report/index.html` for human review at the end rather than silently closing out.

Read the final output template and respond following it exactly:

`Read(${CLAUDE_SKILL_DIR}/references/qa_final_answer.md)`

## Special Instructions

### Resuming Work
If `qa-report/` already exists from a prior run, trust completed flows that passed and re-run only the flows that failed or were skipped, unless the user asks for a full re-run.

### Handling Defects
- Keep the implementer agent's prompt short — give it the defect, evidence path, and suspected files; it reads the code itself.
- Re-verify only the affected flows after each fix round; don't re-run green flows.
- Stop after 3 rounds or when a round makes no progress, and report the remaining failures faithfully rather than looping.

### Approval Gate
If `.claude/qa.md` declares an approval gate, do NOT commit or close out — surface the report and wait for the human.

### Capture Mode
Default to `screenshots`. Only use `video` when motion itself is under test, per the conditions file.

Workflow checklist:

- [ ] load `.claude/qa.md` (create from template if missing, ensure gitignored)
- [ ] preflight: agent-browser loaded, ImageMagick present, `qa-report/` created + gitignored, app started
- [ ] enumerate flows in scope and present the checklist to the user
- [ ] drive each flow with agent-browser, capturing evidence + verifying side effects
- [ ] build a GIF per flow
- [ ] build `qa-report/index.html` from the template
- [ ] auto-fix defects via an implementer agent and re-verify (≤ 3 rounds)
- [ ] hand back per the final answer template, respecting any approval gate

<guidance>
## Artifacts

Everything lands in `qa-report/` (gitignored): per-flow screenshots (or `.webm`), `<flow>.gif`, and **`index.html`** — open it in a browser to view the run.

## Security

- `.claude/qa.md` may hold a test login — it must be gitignored.
- Never echo credentials into the report, the console summary, or any commit.

## Markdown Formatting

When writing markdown that contains code blocks showing other markdown, use 4 backticks (````) for the outer fence so inner 3-backtick code blocks don't prematurely close it.
</guidance>
