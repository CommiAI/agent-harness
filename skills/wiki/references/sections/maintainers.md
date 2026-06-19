# Template — `maintainers.md`

**Purpose:** **who owns what** — the mapping from subsystem/directory to the team
or people responsible, derived from `CODEOWNERS` and the project's governance.

## Skeleton

```markdown
# Maintainers

<1 line: ownership is encoded in <.github/CODEOWNERS / governance file>; this
page summarizes it. Note the source-of-truth file + its size.>

<1 line: how to actually reach an owner (Slack channel pattern, @team mention).>

## <Teams / Squads> and their domains

| <Team / Squad> | Owns (representative paths) |
|----------------|-----------------------------|
| `@org/team` | `path/`, `path/`, … |

## How to find owners for a specific path

```bash
grep -n '<your/path>' .github/CODEOWNERS
```

<Note the matching rule — e.g. "the last matching pattern wins; check the bottom
of the file for fine-grained overrides.">

## Per-directory <AGENTS.md / OWNERS> files   <!-- include if the repo has them -->

- `AGENTS.md` — <repo-wide guide>
- `path/AGENTS.md` — <local conventions>

## See also
- `.github/CODEOWNERS` — the canonical owner mapping.
- **How to contribute** — contributing process.
```

## Notes

- The **team → paths table** is the page. Pull rows straight from `CODEOWNERS`,
  collapsing patterns into representative paths per team.
- State the **matching rule** for the owners file (last-match-wins for CODEOWNERS)
  — it's a common footgun.
- For repos governed by formal teams (rust's `T-compiler`, `T-libs`, …), describe
  the **governance model** instead of/alongside a CODEOWNERS table.
- Call out **per-directory onboarding docs** (`AGENTS.md`, `OWNERS`) — readers
  should look for these first in an unfamiliar directory.

## Real excerpt (grafana)

> Subsystem ownership is encoded in `.github/CODEOWNERS` (1,384 lines) — the single
> source of truth. The easiest way to reach a squad is via Grafana Community Slack
> (`#grafana-<squad>`) or a GitHub `@grafana/<squad-name>` mention.
>
> | Squad | Owns (representative paths) |
> |-------|-----------------------------|
> | `@grafana/grafana-app-platform-squad` | `apps/`, `pkg/storage/unified/`, `pkg/services/apiserver/` |
> | `@grafana/dashboards-squad` | `public/app/features/dashboard-scene/`, `apps/dashboard/` |
>
> The **last matching pattern in CODEOWNERS wins**, so check the bottom of the file
> for fine-grained overrides before assuming the broad pattern applies.
