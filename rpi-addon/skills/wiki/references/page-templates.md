# Page templates

Skeletons for each page in the AutoWiki scheme. Fill every bracketed slot from the real source; drop a section entirely if the codebase has nothing real for it (don't pad). Apply the page conventions from `SKILL.md` (backtick file refs, Mermaid diagrams, footer + disclaimer).

---

## `index.md` — home

```markdown
# <Repo name> — Wiki

> <One-sentence definition of what this repo is.>

| | |
|---|---|
| Source commit | `<hash>` |
| Generated | <YYYY-MM-DD> |
| Primary language(s) | <…> |
| License | <…> |

## Contents
- [Overview](overview.md)
- [Getting Started](getting-started.md)
- [Core Architecture](architecture/core.md)
- [Subsystems](architecture/subsystems/index.md)
- [Patterns](patterns/index.md)
- [By the Numbers](by-the-numbers.md)
- [Glossary](glossary.md)
- [Reference](reference.md)

---
*Generated preview for codebase exploration — not source-maintained documentation.*
```

---

## `overview.md`

```markdown
# Overview

## What this is
<1–2 sentence definition, then what the repo ships and the problem it solves.>

## Who uses it
<User personas: end users / app developers / operators / tooling.>

## Tech stack
| Layer | Technology | Role |
|---|---|---|
| … | … | … |

## Repository layout
| Path | Description |
|---|---|
| `…/` | … |

## Where to start
| If you want to… | Read |
|---|---|
| Understand the design | [Core Architecture](architecture/core.md) |
| Build and run it | [Getting Started](getting-started.md) |
| Follow the conventions | [Patterns](patterns/index.md) |

---
*Related: [Core Architecture](architecture/core.md) · [Getting Started](getting-started.md)*
*Generated preview for codebase exploration — not source-maintained documentation.*
```

---

## `getting-started.md`

```markdown
# Getting Started

For contributors getting the project building locally.

## Prerequisites
<Toolchain, versions, platform notes.>

## Clone & bootstrap
```
<commands>
```

## Build / Run / Test / Lint
| Task | Command | Notes |
|---|---|---|
| Build | `…` | |
| Run | `…` | |
| Test | `…` | |
| Lint | `…` | |

## Common pitfalls
- <Real, specific gotchas from the repo.>

---
*Related: [Overview](overview.md) · [Core Architecture](architecture/core.md)*
*Generated preview for codebase exploration — not source-maintained documentation.*
```

---

## `architecture/core.md` — core system architecture

The densest page. A high-level map of the *whole* system — not a deep dive into any one part (that is the subsystem pages).

```markdown
# Core Architecture

## System shape
<The top-level design in 1–2 sentences: e.g. "a multi-process gRPC system", "a layered engine", "a single binary that wears different hats".>

## Component map
| Component | Source | Responsibility |
|---|---|---|
| … | `…/` | … |

```mermaid
flowchart TD
  <major components and how they compose>
```

## End-to-end flow
<Walk one representative request/operation from entry to response.>

```mermaid
sequenceDiagram
  <entry → … → response>
```

## Cross-cutting concerns
- **Concurrency / threading model** — …
- **State management** — …
- **Configuration** — …
- **Security / identity** — …

## Learning path
<"Start at X, then trace Y." Point at the subsystem and pattern pages.>

---
*Related: [Subsystems](subsystems/index.md) · [Patterns](../patterns/index.md)*
*Generated preview for codebase exploration — not source-maintained documentation.*
```

---

## `architecture/subsystems/index.md`

```markdown
# Subsystems

| Subsystem | Source | What it does |
|---|---|---|
| [<Name>](<name>.md) | `…/` | … |

---
*Related: [Core Architecture](../core.md)*
*Generated preview for codebase exploration — not source-maintained documentation.*
```

## `architecture/subsystems/<subsystem>.md`

```markdown
# <Subsystem>

## Purpose
<What it does and who calls it.>

## Directory layout
| File | Lines | Purpose |
|---|---|---|
| `…` | … | … |

## Key abstractions
| Symbol | Description |
|---|---|
| `…` | … |

## How it works
```mermaid
sequenceDiagram
  <data/control flow through this subsystem>
```

## Integration points
<Other subsystems it depends on or is called by.>

## Entry points for modification
<2–4 pointers for someone extending this subsystem.>

---
*Related: [Subsystems index](index.md) · [Core Architecture](../core.md)*
*Generated preview for codebase exploration — not source-maintained documentation.*
```

---

## `patterns/index.md`

The differentiator. Catalog every recurring convention the codebase relies on.

```markdown
# Patterns

Recurring engineering conventions used across the codebase. Follow these when contributing.

| Pattern | Page | Where it's used |
|---|---|---|
| <Discovered pattern> | [<slug>.md](<slug>.md) | … |

---
*Related: [Core Architecture](../architecture/core.md)*
*Generated preview for codebase exploration — not source-maintained documentation.*
```

## `patterns/<pattern>.md` — per-pattern page

Use this skeleton for every pattern page. Create a page only for a pattern Survey actually found in the code — see the examples below for the kind of content each pattern page should carry.

```markdown
# <Pattern name>

## Problem it solves
<Why this convention exists in this codebase.>

## Where it's used
<Representative call sites with file refs: `path/file.ext:line`.>

## Canonical implementation
<The reference example. Show a real, annotated excerpt and cite its location.>

```<lang>
// from `path/file.ext:line`
<excerpt>
```

## How to follow it
<Step-by-step for applying the pattern in new code.>

## Anti-patterns
<What NOT to do; mistakes the convention exists to prevent.>

```mermaid
%% include a flow/sequence diagram when the pattern is flow-based (e.g. streaming)
```

---
*Related: [Patterns index](index.md)*
*Generated preview for codebase exploration — not source-maintained documentation.*
```

**Example — `patterns/error-handling.md` (only if the repo has a real error-handling convention):** how errors are created, wrapped, propagated, and surfaced: error types/enums, wrapping helpers, the boundary where errors become user-facing (HTTP status / exit code / log), retry vs. fail-fast policy, and the canonical "do it this way" example.

**Example — `patterns/realtime-data-flow.md` (only if the repo has real-time/streaming flow):** the real-time / unidirectional data-flow mechanism (SSE, websockets, streaming responses, event bus, pub/sub). Cover the producer, the transport, the consumer, backpressure/cancellation, and reconnection. Include a `sequenceDiagram` of one stream from source to sink.

---

## `by-the-numbers.md` — trimmed stats

Keep this lean; only metrics that are cheap to derive and genuinely useful.

```markdown
# By the Numbers

*Snapshot as of `<hash>`, <YYYY-MM-DD>.*

## Size
- Lines of code by language: …
- Source vs. test file counts: …

## Activity
- Total commits / last 90 days / last week: …
- Unique authors (all-time / last 90 days): …
- Releases/tags: …

## Quality signals
- Test-to-source ratio: …
- Files with TODO/FIXME/HACK: …

## Churn hotspots
- Most-changed directories (last 90 days): …

---
*Generated preview for codebase exploration — not source-maintained documentation.*
```

---

## `glossary.md`

```markdown
# Glossary

Domain and code terms, grouped by theme. Cite a source file where a term maps to a concrete symbol.

### <Theme>
- **<Term>** — <definition>. (`path/file.ext`)

---
*Generated preview for codebase exploration — not source-maintained documentation.*
```

---

## `reference.md`

```markdown
# Reference

## Quick lookup
| What you're seeking | Code location |
|---|---|
| … | `…` |

## Configuration
| Key / flag / env | Default | Effect |
|---|---|---|
| … | … | … |

## Dependencies
<Notable external dependencies and their role.>

---
*Generated preview for codebase exploration — not source-maintained documentation.*
```
