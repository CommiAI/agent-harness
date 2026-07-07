---
name: wiki
description: Generate an AutoWiki — an architecture-first codebase wiki. Use when asked to generate a wiki or document a repo.
---

# AutoWiki

Generate a **living wiki** for a repository: a browsable tree of single Markdown files that explains how the codebase actually works. Treat the wiki as a regenerable build artifact, not hand-maintained prose — every page is derived from the source and rebuilt when the code changes.

This scheme is **architecture-first**. It leads with the three things a developer needs to become productive in an unfamiliar codebase:

1. **Core architecture** — the top-level design and how data and control flow through it.
2. **Subsystem architecture** — each major subsystem, on its own page.
3. **Patterns** — the recurring conventions the code relies on, each with its canonical implementation and how to follow it.

**CRITICAL:**
- Ground every claim in the real source. Reference concrete files, with line numbers where precise. Never invent a component, endpoint, or pattern that isn't in the code.
- When something is inferred rather than stated, hedge it ("based on the call graph", "appears to") — never present inference as fact.
- Read **`.claude/wiki.md`** in the target repo (if present) for project-specific instructions: output location, sections to add/skip, glossary seeds, house conventions.

## What it produces

One output directory (default `wiki/` at the target repo root; override via `.claude/wiki.md`) holding one Markdown file per page:

```
wiki/
  index.html                # self-contained viewer (built by the Render phase)
  index.md                  # home: identity, metadata, table of contents
  overview.md
  getting-started.md
  architecture/
    core.md                 # core architecture
    subsystems/
      index.md              # list of all subsystems
      <subsystem>.md        # one page per subsystem
  patterns/
    index.md                # catalog of recurring patterns
    <pattern>.md            # one page per discovered pattern
                            #   e.g. error-handling.md, realtime-data-flow.md
  by-the-numbers.md
  glossary.md
  reference.md
```

The `architecture/` group is the spine and gets the most depth. `patterns/` is the differentiator — a first-class catalog, not a buried subsection.

## Page conventions

Apply to every page:
- **File references** — repo-relative paths in backticks: `` `pkg/engine/server.go` ``. Add a line number when pointing at a specific definition: `` `server/routes.go:412` ``.
- **Diagrams** — Mermaid only (`flowchart`, `sequenceDiagram`, dependency graphs). Use a sequence diagram for any end-to-end or stream flow. No custom colors/styles, so it themes correctly.
- **Tables** — for structured data: tech stack, directory layout, key abstractions, routes, navigation.
- **Footer** — end every page with a "Related pages" line and the disclaimer: *"Generated preview for codebase exploration — not source-maintained documentation."*

Per-page skeletons live in `references/page-templates.md` — read it before writing pages.

## Generating the wiki

Four phases, in order. On a rerun, take the **Incremental refresh** branch instead of a full regeneration (then still Render).

### 1. Survey
Two passes over the repo; fan out reads to `Explore` / `rpi:codebase-locator` subagents.
- **Structural** — README, manifests, CI config, entry points, directory layout, languages, build/run/test commands.
- **Semantic** — subsystem boundaries and the control/data flow between them; routes, endpoints, service classes, schemas; and the *pattern signals*: how errors are raised/wrapped/handled, where real-time/streaming/SSE flow lives, concurrency primitives, state stores, retry/backoff.

Set the output dir. Record `git rev-parse HEAD` and the date for `index.md`.

**Done when:** structural and semantic facts are captured, the candidate subsystem list and pattern-signal list are written down, and the commit hash is recorded.

### 2. Plan
From what Survey found, decide the concrete page set: which subsystems warrant their own page (group thin ones) and which patterns are genuinely recurring — only create a pattern page when Survey found that pattern in use. Drop any page that would have no real content rather than padding it.

**Done when:** `index.md` exists with a table of contents naming every page that will be generated.

### 3. Generate
Write pages in dependency order so later pages can link to earlier ones: `overview → getting-started → architecture/core → architecture/subsystems/* → patterns/* → by-the-numbers → glossary → reference`. Each page follows its skeleton in `references/page-templates.md`. Generate the many subsystem and pattern pages concurrently with subagents.

**Done when:** every page named in the `index.md` table of contents exists, follows its template, and its file references resolve to real paths.

### 4. Render
Inline the whole `.md` tree into one self-contained, browsable viewer — `wiki/index.html` — with the build script:

```bash
"${CLAUDE_SKILL_DIR}/scripts/build-wiki-html.sh" <wiki-dir> --title "<Repo name>"
```

The script walks the tree, inlines every page as JSON into `references/viewer-template.html`, and writes `wiki/index.html` (three-pane nav + content + on-this-page TOC, Mermaid, syntax highlighting, search, inter-page links). It needs no server — `index.html` opens straight off disk — and is idempotent, so rerun it after any regeneration. `index.html` is a build artifact, never hand-edited; the `.md` files stay the source of truth (and render natively on GitHub too).

**Done when:** `build-wiki-html.sh` reports the page count and `wiki/index.html` exists. Then report the output path and page tree to the user, and surface anything Survey could not resolve.

### Incremental refresh (rerun)
Read the stored commit hash from `index.md`, diff against the current commit, regenerate only the pages whose underlying files changed, and carry unchanged pages forward verbatim. Update the metadata hash and date.

**Done when:** every page touched by a changed file is regenerated, the metadata reflects the new commit, and the **Render** phase has rebuilt `wiki/index.html`.
