### QA Summary

<one-line verdict, e.g. "4 flows tested · 3 passed · 1 failed then auto-fixed · all green after 2 rounds">

<one bullet per flow, with a verdict marker and outcome + verification result:>
- ✅ <flow name> — <what passed and where it was verified, e.g. "signup email arrived in Mailpit">
- ❌ <flow name> — <what failed> (auto-fixed: <one-line fix>)

### Defects & Fixes

<omit this whole section if no defects were found. otherwise, for each defect:>
- **<flow name>** — expected <X>, got <Y>. Fixed in `file:line`. Re-verified ✅ / still failing ❌.

### Report

Open the full report with rendered GIFs:

```text
qa-report/index.html
```

<if an approval gate is declared in .claude/qa.md, append:>
Awaiting your review before this is considered closed out.
