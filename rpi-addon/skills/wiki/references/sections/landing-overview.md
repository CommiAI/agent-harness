# Template — `overview/index.md` (Landing page)

**Purpose:** the first page a reader lands on. In ~1 screen it answers: *what is
this, what's in this repo, and where do I go next?*

## Skeleton

```markdown
# <Repo / Project Name>

<1 paragraph: what the project IS (one sentence), then what THIS repository is
(monorepo? single binary? compiler + stdlib?). Name the major moving parts.>

## What this codebase contains   <!-- or "What lives here" / "What this repository contains" -->

<Bulleted breakdown of the top-level areas. One bullet per major directory/area.
Each bullet: what it is + where it lives (`path/`) + the entry-point file.>

- A <thing> (`<dir>/`) that <does X>. Entry point: `<dir>/<entry-file>`.
- ...

## Where to start   <!-- table form; or "Audience" / "Quick links" -->

| Audience | Start with |
|----------|-----------|
| Newcomer to the codebase | **Architecture** and **Getting started** |
| Reading <subsystem> code | **<Domain overview>** and **<Topic>** |
| Building/extending <X> | **<Section>** and **<Section>** |

## Project facts   <!-- or "Project size at a glance" / "Map of the codebase" -->

- **Language mix:** <langs + what each is used for>
- **Build system:** <package manager, task runner, codegen>
- **License:** <SPDX id + notes>
- **First commit:** <date>. <activity note>.

See **By the numbers** for a quantitative snapshot and **Lore** for history.
```

## Notes & variations (observed across grafana / rust / react)

- The "what's in here" heading varies — **grafana**: "What this codebase
  contains"; **rust**: "What lives here"; **react**: "What this repository
  contains". Pick what fits; keep the intent.
- "Map of the codebase" can replace the bullet list with a **fenced directory
  tree** (react does this — 40+ packages as a `├──` tree with `# comments`).
- "Where to start" is a table for big repos (grafana, rust) or a plain link list
  ("Quick links" in react). Both are fine.
- Add a short **scope/audience note** when the repo also has public end-user docs
  (react → "for engineers in the monorepo … end-users see react.dev").

## Real excerpt (grafana)

> Grafana is an open-source observability platform for querying, visualizing, and
> alerting on time-series data … The repository is a large monorepo combining a Go
> backend, a TypeScript/React frontend, a set of shared `@grafana/*` npm packages,
> and dozens of built-in datasource and panel plugins.
>
> **What this codebase contains**
> - A Go HTTP server (`pkg/`) that exposes the REST/gRPC API … Entry point: `pkg/cmd/grafana/main.go`.
> - A TypeScript single-page application (`public/app/`) … Entry point: `public/app/index.ts`.
>
> **Project facts** — Language mix: Go + TypeScript/React + CUE. Build: Yarn 4 +
> Nx + Go workspaces + Webpack. License: AGPL-3.0-only. First commit: January 2013.
