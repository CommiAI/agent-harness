# Template — `reference/index.md` (+ sub-pages)

**Purpose:** the **slow-changing reference hub** — material that other pages link
to and that doesn't need re-reading often (config, data models, dependencies).

## Skeleton (index page)

```markdown
# Reference

Reference material that doesn't change often and that other pages link to.

## Sub-pages
- **Configuration** — <config format + where parsed>
- **Data models** — <core schemas / types>
- **Dependencies** — <ecosystems + ownership>
```

The index is intentionally **tiny** — a 1-line intro and a sub-page list. All the
content lives in the sub-pages.

## Sub-pages (one `.md` each, under `reference/`)

| File | Contents |
|------|----------|
| `configuration.md` | every config knob: source file(s), format (INI/YAML/env), defaults, how it's parsed, notable options. Use a settings table. |
| `data-models.md` | the core persisted/serialized schemas (DB tables, JSON shapes, CRDs/kinds), where defined, version/migration notes. |
| `dependencies.md` | direct dependencies per ecosystem, how many, where pinned (`go.mod`/`yarn.lock`), and ownership annotations if the repo tags them. |

## Notes

- Keep the index page to ~4 lines — it's a hub, not content.
- Reference sub-pages lean on **tables** (knob → default → meaning;
  table/type → fields; dependency → owner).
- Add reference sub-pages only when the repo actually has that surface — a small
  library may only have `dependencies.md`.

## Real excerpt (grafana — `reference/index.md`)

> Reference material that doesn't change often and that other pages link to.
>
> **Sub-pages**
> - Configuration
> - Data models
> - Dependencies
