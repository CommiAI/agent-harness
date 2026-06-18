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
2. Read the structure outline or plan to understand the phases
3. List out the real user flows needed to be verified for the scope of this quality assurance pass in phases, each flow follows: **steps**, **expected outcome**, and **where to verify** the side effect.
4. Read `.claude/qa.md` in the target project to understand project-specific quality assurance instructions
5. Create the artifact dir `qa-report/`
6. Begin with the first phase
7. Follow the workflow below

## Workflow

For each phase in the quality assurance pass:

### 1. Drive each flow with driver

Perform the steps of the real user flow, verify the expected outcome.
**Build a GIF demo per flow** Take screenshots after each meaningful step into `qa-report/<flow>/NN-<step>.png` stitch them into a GIF with `magick`. Each frame is a deliberate checkpoint that maps to a step and assertion.
If the outcome is not expected, diagnose the issue and launch the `rpi:implementer-agent` subagent via the Agent tool to fix it, then re-run the affected flow. Repeat up to **3 rounds** or until it passes.

### 2. Build the HTML report

Copy the template and fill its markers:

```bash
cp "${CLAUDE_SKILL_DIR}/references/report_template.html" qa-report/index.html
```

Replace `{{TITLE}}`, `{{VERDICT}}` (e.g. "3 passed · 1 failed"), `{{SUMMARY}}`, and one `{{FLOWS}}` card per flow — a verdict badge (✅/⚠️/❌), the flow's `<flow>.gif`, and the verification result. Report faithfully: give skipped or failed flows a card with the reason.

### 3. Hand back for human review

Surface `qa-report/index.html` for review rather than silently closing out; respect any approval gate in `.claude/qa.md`. Then read the final output template and respond following it exactly:

`Read(${CLAUDE_SKILL_DIR}/references/qa_final_answer.md)`

<guidance>
## Resuming
If `qa-report/` already exists, trust passed flows and re-run only the failed or skipped ones, unless the user asks for a full re-run.
</guidance>
