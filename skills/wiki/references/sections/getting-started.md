# Template — `overview/getting-started.md`

**Purpose:** the **local developer loop only** — clone, install, build, run, test.
Not end-user installation (link that out in the first line).

## Skeleton

```markdown
# Getting started

<1 line scoping the page to the dev loop. Link end-user install elsewhere.>

## Prerequisites

| Tool | Version | Used for |
|------|---------|----------|
| <lang> | <ver — cite the source-of-truth file, e.g. go.mod / .nvmrc> | <what> |

<1 line: where the canonical/long setup guide lives in-repo.>

## First-time setup

```bash
# Install dependencies (frozen lockfile)
<install command>
```

<Note any "no external DB required" / embedded-store facts.>

## Running <project> locally

```bash
# Backend, hot reload
<run command>            # localhost:<port>, login <creds>

# Frontend dev server (separate terminal)
<run command>
```

<1–2 lines on how the two processes talk / proxy / hot-reload.>

## Building artifacts

```bash
<build-backend command>
<build-frontend command>
```

## Running tests

<1 line: "N independent test suites — match the suite to what you changed.">

```bash
# Unit / integration / e2e — one targeted + full-run command for each
```

## Code generation   <!-- include only if the repo has committed generated code -->

```bash
<make gen-* / codegen commands, one per generator, with a # comment>
```

## Common gotchas

- <surprising default, slow path, build-tag trap, version pin, etc.>
```

## Notes

- Lead with a **Prerequisites table** (Tool / Version / Used for). Cite the
  version source-of-truth file (`go.mod`, `.nvmrc`, `.yarn/releases/`) so it
  doesn't go stale.
- Every command block should be **real and copy-pasteable**, with `# comments`
  noting timing ("first build ~3 min"), ports, and default credentials.
- The **Common gotchas** list is high-value — capture the things that bite a
  newcomer (e.g. "`yarn test` defaults to `--watch`"; "build tags gate enterprise
  files"; "run `corepack enable` if yarn isn't found").
- Include **Code generation** only when generated code is committed and must be
  regenerated (grafana/rust: yes; many small repos: no).

## Real excerpt (grafana)

> | Tool | Version | Used for |
> |------|---------|----------|
> | Go | 1.26.x (track `go.mod`) | Backend, plugins, CLI |
> | Node.js | v24.x (see `.nvmrc`) | Frontend tooling |
>
> Grafana runs as two independent dev processes … `make run` (backend, hot reload,
> `localhost:3000`, login `admin/admin`) and `yarn start` (webpack watch). The Go
> server proxies asset requests to the webpack dev server.
>
> **Common gotchas:** Frontend `yarn test` defaults to `--watch` — use
> `yarn jest --no-watch`. Build tags `oss`, `enterprise`, `pro` gate
> enterprise-only files.
