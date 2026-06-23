---
name: reflect-on-task
description: Reflect on a completed task. Pulls per-phase timing and the post-implementation message trail from HumanLayer, reads the task's own design artifacts off disk, and grades how well the PRD, TDD, and outline predicted what was actually built. Use after a task/PR is merged, or when asked to reflect on a task, analyze a task session, run a retro, or grade the design docs.
---

# Reflect on Task

You analyze a **completed task** (one merged PR == one HumanLayer task == a chain of
sessions) and produce **one report** that answers: *did the design hold up, and what should
I think harder about next time?*

The report has three sections:
1. **Time by phase** — share of active time per phase.
2. **Iterations after implementation** — each fix/change made once coding began: problem, what changed, why it wasn't caught in design.
3. **Design-artifact report card** — a grade for the PRD, TDD, and Outline against what was actually built.

The skill runs on the same task, so the **design artifacts are read directly from disk**. The
only things the dump pulls from HumanLayer are what you *can't* get from disk: **per-phase
timing** and **the messages after implementation began**.

## Getting Started

When invoked:
1. Determine the task. Use the argument if given (task-id or slug); otherwise auto-detect from the current git branch (branch name == task slug).
2. Run the dump script:
   ```bash
   bash "${CLAUDE_SKILL_DIR}/scripts/dump-task-session.sh" [TASK_ID_OR_SLUG]
   ```
   It writes just two files into `.humanlayer/tasks/<slug>/reflect-on-task/`:
   - `phases.md` — per-phase timing (active min, share %, your turns, errors, time window) plus the implementation-start timestamp.
   - `post-implementation.md` — chronological human turns, assistant root-cause lines, and errors that happened **after** implementation started.

   It prints the output path on its last line.
3. Read both files, then read the design artifacts straight from the **parent** task dir (`.humanlayer/tasks/<slug>/`): the PRD, TDD, structure-outline/plan, and `pr-description.md` if present.

## Workflow

### 1. Time by phase
From `phases.md`, take each phase's **share of active time** for the bars in section 1. Call out the heaviest phase — that's where the effort concentrated.

### 2. Iterations after implementation
Work through `post-implementation.md`. Group the human turns / errors / diagnoses into distinct iterations and write each as: **problem → what changed → why it wasn't caught in design**. For the "why", cross-reference the artifacts: which doc *should* have anticipated it — a missing requirement in the PRD, an unhandled case in the TDD, a skipped step in the outline? That linkage is the point: it directly feeds the grades in step 3.

### 3. Grade the design artifacts
Read the rubric and grade the PRD, TDD, and Outline against the implementation:

`Read(${CLAUDE_SKILL_DIR}/references/grading_rubric.md)`

Each gets a Completeness / Accuracy / Foresight score, a blended %, a letter, **cited evidence** (a drifted requirement, a reversed decision, a root cause), and — most important — a **gaps list**: the concrete things that doc missed, phrased as what to look out for in that phase next time. Mark an artifact **N/A** if the task didn't produce one.

### 4. Build the report
Copy the template and fill its markers:
```bash
cp "${CLAUDE_SKILL_DIR}/references/report_template.html" .humanlayer/tasks/<slug>/reflect-on-task/report.html
```
Replace `{{TITLE}}`, `{{HEADLINE}}`, `{{PHASE_BARS}}`, `{{ITERATIONS}}`, `{{GRADES}}` per the snippets in the template comment. This is the **only** artifact — don't write a separate markdown retro.

### 5. Hand back
Read the final-answer template and respond following it exactly:

`Read(${CLAUDE_SKILL_DIR}/references/final_answer.md)`

Lead with the weakest grade dimension — that's the thing to think harder about next time.

<guidance>
## Notes
- The CLI requires the `--beta` environment — the script passes it. If `tasks list` returns no JSON, the user needs `humanlayer login`.
- Don't re-fetch events — `phases.md` and `post-implementation.md` already hold everything you need from HumanLayer; analyze those plus the on-disk artifacts.
- If `post-implementation.md` is empty (no implementation phase detected, e.g. an exploration task), say so and grade only what the artifacts support.
- Every claim — a phase %, an iteration's "why", a grade — must cite a number or quote from the dump or an artifact. No invented grades.
</guidance>
