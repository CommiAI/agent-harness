# Template — `lore.md`

**Purpose:** the codebase's **history as visible in git** — how it got to its
current shape. Eras, big rewrites, what was deprecated and replaced.

## Skeleton

```markdown
# Lore

<1–2 lines: origin story in one breath + "this page sketches the major eras as
visible in git history.">

## Eras

### <Era name> (<start> – <end>)

<What the codebase looked like in this era, what was added, which directories
date from here and still exist. Anchor to real paths and the founding commit/release.>

### <Era name> (<start> – <end>)
...

## Longest-standing features

- **<feature / dir>** — present since <when>, still maintained in `<path>`.

## Deprecated / replaced features

| Removed | Replaced by | Notes |
|---------|-------------|-------|
| <old> | <new> (`path/`) | <when / how> |

## Major rewrites

- **<area> (<years>)** — <from> → <to>. Trace through commits in `<path>`.

## Growth trajectory

<1 paragraph: from N lines at the start to M lines today; what kind of new
directories dominate recent history.>
```

## Notes

- Structure history as **named eras with date ranges**, each tied to a major
  version/release and the directories born in it (grafana: "The Kibana fork",
  "The Go server", "The React migration", "Unified Alerting", …).
- The **Deprecated/replaced table** and **Major rewrites** list are the most
  useful parts for a code reader — they explain why two parallel systems coexist.
- Pull this from `git log`, release tags, and directory birth dates
  (`git log --diff-filter=A --follow -- <path> | tail`).
- Keep it grounded: every era should name a commit, date, or release and a path.

## Real excerpt (grafana)

> Grafana started as a Kibana 3 fork in early 2013 …
>
> **The Go server (Sep 2014 – 2016)** — Grafana 2 introduced a Go backend. The
> early `pkg/cmd/grafana-server/`, `pkg/api/`, and `pkg/services/sqlstore/`
> directories date from this era. Many foundational patterns — interface-per-domain,
> sqlstore as a single SQL gateway, route registration in `pkg/api/api.go` — were
> established here and are still in use.
>
> **Deprecated / replaced**
> | Removed | Replaced by | Notes |
> |---------|-------------|-------|
> | Legacy alerting | Unified alerting (`pkg/services/ngalert/`) | Removed across Grafana 9 → 10. |
> | API keys | Service account tokens | API keys still resolve; new tokens are service-account tokens. |
