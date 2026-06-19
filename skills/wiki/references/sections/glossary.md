# Template — `overview/glossary.md`

**Purpose:** project-specific vocabulary — terms, acronyms, and codenames a reader
will hit *in this codebase*. **Exclude** general industry terms (REST, gRPC,
Redux) unless the project uses them in a non-standard way.

## Skeleton

```markdown
# Glossary

<1 line: scope — project-specific terms only; general software terms omitted.>

## <Group A — e.g. Product concepts>

**<Term>** — <definition in one or two sentences>. <Where it lives: `path/`.>
**<Term>** — <definition>. <Optional: historical note / why it's named that>.

## <Group B — e.g. Architectural terms>

**<Term>** — <definition + path>.

## <Group C — e.g. Auth and access control>
## <Group D — e.g. Frontend specifics>
## <Group E — e.g. Build and CI>
```

## Notes

- **Group the terms** by area (Product concepts · Architectural terms · Auth ·
  Frontend · Build/CI in grafana; rust groups by HIR/MIR/query compiler vocab).
  Groups are `##` headings; each term is a **bold lead-in** followed by ` — def`.
- Always **anchor a term to code** (`pkg/services/folder/`) so the reader can jump.
- Capture **codenames and "wrong" names** — these are the highest-value entries
  (e.g. grafana's `ngalert` = "next-gen alerting" that's no longer next-gen).
- Cross-reference within the glossary when one term builds on another
  ("Scenes — see above").

## Real excerpt (grafana)

> **Product concepts**
> **Dashboard** — a JSON document holding a layout of panels, template variables,
> and time range. Stored in `dashboard` table, schema in `kinds/dashboard/`.
> **DataFrame** — Grafana's columnar data interchange format. Defined in
> `packages/grafana-data/` (TS) and `pkg/dataframe` (Go).
>
> **Architectural terms**
> **Wire** — Google's compile-time dependency injection generator. Service graph
> declared in `pkg/server/wire.go`, generated to `wire_gen.go`.
> **ngalert** — the unified alerting backend, named from when it was the
> "next-generation" engine; the legacy engine is long gone but the name stays.
