# Template — `how-to-contribute/index.md` (+ sub-pages)

**Purpose:** a **repository-oriented** index of how to work in the codebase. Not a
copy of CONTRIBUTING.md — a summary that links it and adds the "where do I put
this change" map a code reader actually needs.

## Skeleton (index page)

```markdown
# How to contribute

<1 line: "this section summarizes the parts a code reader most often needs; the
canonical handbook lives in CONTRIBUTING.md / contribute/.">

## Picking up work

- <how to find issues, labels, good-first-issue tags, CLA/DCO requirement>

## PR mechanics

- <branch/merge strategy (squash/rebase), commit-title convention, how public
  APIs change, frontend/backend PR split if any>

## Definition of done

A change is ready to merge when:
- <CI green / required reviewers / tests added / changelog entry / regenerated codegen>

## Where things live

| If you want to … | Look here |
|------------------|-----------|
| Add an HTTP route | `path/` (handler) + `path/` (registration) |
| Add a <component> | `path/` + <wire-up step> |

## Sub-pages
- **Development workflow**
- **Testing**
- **Debugging**
- **Patterns and conventions**
- **Tooling**
```

## Sub-pages (one `.md` each, under `how-to-contribute/`)

| File | Contents |
|------|----------|
| `development-workflow.md` | branch → PR → review → merge loop in detail |
| `testing.md` | the test suites, how to run/target each, where fixtures live |
| `debugging.md` | attaching a debugger, logging/trace flags, common failure modes |
| `patterns-and-conventions.md` | the idioms a reviewer expects (DI, error handling, file layout) |
| `tooling.md` | linters, hooks, codegen, CI orchestrators |

## Notes

- The **"Where things live" table** (task → directory) is the highest-value block
  — it's the bridge from "I want to do X" to a real path.
- Make **Definition of done** a concrete checklist tied to this repo's gates
  (CODEOWNERS approval, `make gen-*` outputs committed, changelog entry).
- Keep the index short; push depth into the sub-pages.

## Real excerpt (grafana)

> **Where things live**
> | If you want to … | Look here |
> |------------------|-----------|
> | Add an HTTP route | `pkg/api/` (handler) + `pkg/api/api.go` (registration) |
> | Add a feature flag | `pkg/services/featuremgmt/registry.go` + `make gen-feature-toggles` |
> | Add a frontend feature | New folder under `public/app/features/<name>/` |
>
> **Definition of done** — CI green (frontend + backend + e2e + lint);
> CODEOWNERS-required reviewers approved; new tests added; user-facing changes
> include a changelog entry; schema/feature-flag changes have their `make gen-*`
> outputs committed.
