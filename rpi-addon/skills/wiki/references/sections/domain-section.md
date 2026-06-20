# Template — `<domain>/index.md` + topic sub-pages (repo-specific sections)

**Purpose:** the **repeatable template for each major area** of the repo — Backend,
Frontend, Packages, Apps, Plugins (grafana); Compiler, Library, Tools (rust);
Packages, React Compiler, Features (react). One `<domain>/` directory per area,
with an `index.md` landing page and one `.md` per topic.

Use this template **once per domain**, choosing domains from the repo's real
top-level directory split (see the master template's "How to decide `<domain>`").

## Skeleton (domain `index.md`)

```markdown
# <Domain name>

<1–2 lines: what this area is responsible for and where it lives (`path/`).>

## What's in <path>/

<Fenced directory tree of the domain's top-level subdirs, each with a # comment.>

```
<dir>/
├── <subdir>/        # role
├── <subdir>/        # role
└── <subdir>/        # role
```

<1 paragraph: the dominant pattern in this tree (e.g. "most services follow
interface + impl + store"), and the biggest/most-central subtree.>

## Sub-pages
- **<Topic>** — <one-line scope, `path/`>
- **<Topic>** — <one-line scope, `path/`>

## Key entry points

| File | Role |
|------|------|
| `path/file` | <what it is — binary entry / route registration / DI graph> |
```

## Topic sub-page skeleton (`<domain>/<topic>.md`)

```markdown
# <Topic>

<1 line scope.>

## <How it works>
<Prose + the central files. Diagram if there's a pipeline.>

## <Key files / API surface>
| File | Role |

## <Gotchas / patterns>
```

## Notes

- The **directory-tree block** with per-line `# comments` is the signature of a
  domain index — it's the map. Keep comments to a few words.
- **Always** end the index with a **"Key entry points" table** (file → role) and a
  **"Sub-pages" list** that the topic `.md` files fulfill.
- Pick the domain's vocabulary from the repo: grafana's backend index leads with
  "What's in `pkg/`"; rust's compiler index would lead with the stage pipeline.
- The number/names of topic sub-pages come from the domain's real sub-areas — let
  the directory structure drive them, don't pad.

## Real excerpt (grafana — `backend/index.md`)

> The Go backend lives under `pkg/` and a complementary `apps/` tree … responsible
> for HTTP/gRPC API serving, persistence, alert evaluation, plugin hosting,
> datasource query execution, and live streaming.
>
> **What's in `pkg/`**
> ```
> pkg/
> ├── api/          # Legacy REST/HTTP handlers (one file per resource)
> ├── apis/         # New k8s-style group/version/kind manifests
> ├── plugins/      # Plugin host (loader, registry, sandbox)
> ├── server/       # Wire DI graph + Server/HTTPServer init
> ├── services/     # Domain services (the bulk of business logic)
> └── tsdb/         # Backend datasource implementations
> ```
>
> **Key entry points**
> | File | Role |
> |------|------|
> | `pkg/cmd/grafana/main.go` | Binary entry point |
> | `pkg/server/wire.go` | Wire DI graph (regenerate with `make gen-go`) |
> | `pkg/api/api.go` | Legacy REST route registration |
