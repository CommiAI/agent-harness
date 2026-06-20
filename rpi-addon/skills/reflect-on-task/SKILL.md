---
name: reflect-on-task
description: Reflect on a completed task's HumanLayer session history. Pipes the full task session (all sessions + events) into a readable directory, then identifies the top time-consuming phases you spent the most in-loop time on and why — re-steering, fork-restarts, and debugging root causes. Use after a task/PR is merged, or when asked to reflect on a task, analyze a task session, run a retro, or find where time went.
---

# Reflect on Task

You analyze a **completed task** (one merged PR == one HumanLayer task == a chain of sessions) to surface where the human's *in-loop time* went and why. The goal is actionable: the top time-consuming sections and the reason each one was expensive.

**What counts as expensive is HUMAN time, not cost.** Implementation and QA run autonomously (≈1 human turn); design phases are where the human re-steers. Optimize for fewer human turns and less re-steering, not fewer dollars.

## Getting Started

When invoked:
1. Determine the task. Use the argument if given (task-id or slug); otherwise auto-detect from the current git branch (branch name == task slug).
2. Run the dump script to pipe the session into a readable directory:
   ```bash
   bash "${CLAUDE_SKILL_DIR}/scripts/dump-task-session.sh" [TASK_ID_OR_SLUG]
   ```
   This writes into the task's own artifacts directory — `.humanlayer/tasks/<slug>/reflect-on-task/` — containing `_overview.md` (per-phase + per-session metrics), one `NN-<phase>-<title>.md` per session (your turns + condensed transcript), and `sessions.json`. The script prints the resolved output path on its last line. It can take a few minutes for large tasks — that's expected.
3. Read the `_overview.md` in that directory fully. It already ranks phases and sessions by active time and turn count.

## Workflow

### 1. Read the macro view
From `_overview.md`, identify the **top 3 time-consuming phases** (by active minutes and your turns) and the **top time-sink sessions**. Note any phase that appears as multiple sessions of the same title — that's a **fork/restart**, which usually means re-paid grounding work.

### 2. Read the heavy sessions for the "why"
Open the per-session files for the top 3–5 sinks. For each, classify *why* it was expensive using the transcript and "Your turns" section:
- **Re-steering** — many short human turns redirecting the agent mid-flight.
- **Fork-restart waste** — a base session interrupted early, then a fork that re-does the same grounding (identical opening messages). Quantify the duplicated minutes.
- **Design churn** — the agent repeatedly reframing the user's idea because codebase reality wasn't established first (a missing *grounding spike*).
- **Debugging** — clusters of error results. For these, extract the **actual root cause** from the assistant's diagnosis (look for "root cause", "the issue is", "turns out"), and whether the human was even in the loop (QA/impl usually handle it autonomously).

### 3. Find the complex-bug root causes
For sessions with high error counts (typically QA/implementation), pull the root-cause statements and look for a **common theme** across bugs (e.g. silent missing-context at integration boundaries). State how to prevent the class, not just the instance (fail-loud invariants, one thin integration test per mutating flow).

### 4. Write the retro
Write `retro.md` into the same `reflect-on-task/` output directory, with:
- **Time by phase** — the table from `_overview.md`, design vs build vs QA, with the headline (e.g. "X% of your in-loop time was design").
- **Top 3 time sinks + why** — one classified reason each, with the minutes/turns evidence.
- **Fork/restart waste** — sessions that re-paid grounding, with the wasted minutes.
- **Complex bugs** — root causes + the shared class + prevention.
- **2–3 recommendations** — concrete and specific to this task's pattern (e.g. "continue design sessions instead of forking-from-start"; "run a grounding spike before opinion-heavy UI design"; "bake fail-loud invariants into the implement step").

Keep it evidence-backed: every claim cites a number from the dump (active min, turns, error count) or a quote from a transcript.

### 5. Hand back
Surface the `retro.md` for review. Lead with the single biggest lever to reduce in-loop time on the next task.

<guidance>
## Notes
- The CLI requires the `--beta` environment for org context — the script already passes it. If `tasks list` returns no JSON, the user needs `humanlayer login`.
- Active time per session is capped at the most recent 1000 events, so very long sessions (QA, implementation) underestimate minutes — but **turn counts are exact**, so lean on turns as the in-loop signal.
- Don't re-fetch events you already have in the dump directory; analyze the written files.
</guidance>
