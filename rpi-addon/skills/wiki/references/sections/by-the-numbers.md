# Template — `by-the-numbers.md`

**Purpose:** a **quantitative snapshot** of the repo. Everything here is a measured
number, pinned to a date + commit so it's honestly reproducible.

## Skeleton

```markdown
# By the numbers

<1 line: "A quantitative snapshot of the <repo> repository.">

Data collected on <YYYY-MM-DD> against commit <hash> on <branch>.

## Size

<Optional: a bar-chart description of SLOC by language.>

| Metric | Count |
|--------|-------|
| <lang> source files (non-test) | ~<n> |
| <lang> test files | <n> |
| Lines of <lang> code (non-test) | <n> |
| Top-level workspaces / crates / modules | <n> |

<1 line of interpretation — e.g. "roughly balanced between X and Y; a large share
of lines under `gen/` is generated.">

## Activity

| Metric | Value |
|--------|-------|
| Total commits on <branch> | <n> |
| First commit date | <date> |
| Latest commit date (snapshot) | <date> |
| Unique committers across history | ~<n> |

**Hot directories (last 90 days)**

| Directory | Files touched |
|-----------|---------------|

**Most-changed individual files (last 90 days)**

| File | Touches |
|------|---------|

<1 line explaining any churn outlier — usually auto-generated files.>

## Bot-attributed commits

<% of commits with a bot signature; name the bots; note it's a lower bound.>

## Complexity hotspots

**Largest non-generated <lang> files**

| File | Lines |
|------|-------|

<1 line: note that the absolute largest files are usually generated.>

## Dependencies

<Direct dependency counts per ecosystem + where ownership is annotated.>
See **Reference / Dependencies** for ownership detail.
```

## Notes

- **Pin the snapshot**: "Data collected on `<date>` against commit `<hash>`." This
  is the page's credibility — never give bare numbers.
- Get numbers from real commands, e.g.:
  ```bash
  git rev-parse --short HEAD
  git log --oneline | wc -l                       # total commits
  git log --since="90 days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn   # hot files
  git shortlog -sne | wc -l                        # unique committers
  # SLOC: tokei / cloc / scc, or find + wc -l with test-file excludes
  ```
- Separate **non-test vs test** counts — the test/source ratio is itself a fact.
- Call out **generated code** explicitly (it distorts "largest file" and churn).
- Tables are the unit here. Charts (bar/SLOC) are optional prose-described visuals.

## Real excerpt (grafana)

> Data collected on 2026-04-30 against commit 837f0fcd393 on `main`.
>
> | Metric | Count |
> |--------|-------|
> | Go source files (non-test) | ~4,200 |
> | Lines of Go code (non-test) | 270,475 |
> | Lines of TS/TSX code (non-test) | ~291,000 |
>
> **Activity** — Total commits on `main`: 68,721. First commit: 2013-01-25.
> Unique committers: ~3,225.
>
> **Bot-attributed commits** — about 4.9% of historical commits have a bot
> signature (`dependabot[bot]`, `renovate[bot]`, …). This is a lower bound —
> inline AI-assisted human edits are indistinguishable from regular commits.
