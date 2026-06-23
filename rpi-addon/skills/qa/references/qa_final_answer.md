### QA Summary

<one-line verdict, e.g. "4 flows · 3 passed · 1 failed then auto-fixed">

<one bullet per flow, with a verdict marker and the outcome (note any fix inline):>
- ✅ <flow name> — <what passed>
- ❌ <flow name> — <what failed> (fixed in `file:line`, re-verified ✅)

### Report

The QA report is an inline artifact in the task directory — open it from the **Artifacts tab** of the sidebar (or the cloud permalink below):

```text
.humanlayer/tasks/{task-slug}/qa-report.html
```

<paste the cloud permalink captured from the hook response after writing/embedding>

<if an approval gate is declared in .claude/qa.md, append: "Awaiting your review before this is closed out.">
