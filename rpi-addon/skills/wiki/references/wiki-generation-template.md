# Wiki Generation — Master Template

This is the **master template** for generating a Factory-AutoWiki-style codebase wiki.

A wiki is **a tree of single Markdown files**, one file per page, organized into
sections. This master file defines:

1. The **page tree / sidebar manifest** (which files to generate).
2. The **global conventions** every page must follow.
3. An **index of per-page templates** in `./sections/` — generate each page by
   following its matching section template.

> Modeled on Factory AutoWiki (`factory.ai/open-source-wikis/<repo>`). Each page
> there is one Markdown file loaded as `?page=<path>.md`. Renderer stack:
> **Next.js + Markdown (GFM) + Shiki** (dual `factory-dark`/`factory-light`
> code themes) **+ Mermaid** for diagrams, with auto-slugged heading anchors.

---

## 1. Page tree (sidebar manifest)

Generate these files. Paths are relative to the wiki root. `index.md` is the
landing page of a section. **Bold = universal** (every repo gets one);
_italic = repo-specific_, named after the repo's real top-level areas.

```
overview/
  index.md              # Landing page — what the repo is, what's in it, where to start   → sections/landing-overview.md
  architecture.md       # How it fits together, with Mermaid diagrams                      → sections/architecture.md
  getting-started.md    # Local dev loop: clone → install → build → run → test             → sections/getting-started.md
  glossary.md           # Project-specific terms, acronyms, codenames                      → sections/glossary.md
by-the-numbers.md       # Quantitative snapshot (size, activity, hotspots, deps)           → sections/by-the-numbers.md
lore.md                 # History told through git: eras, rewrites, deprecations           → sections/lore.md
fun-facts.md            # Trivia a code reader would find surprising                       → sections/fun-facts.md
how-to-contribute/
  index.md              # Repo-oriented contributing index (+ sub-pages below)             → sections/how-to-contribute.md
  development-workflow.md
  testing.md
  debugging.md
  patterns-and-conventions.md
  tooling.md
<domain>/               # ← REPO-SPECIFIC. One per major top-level area. Examples:         → sections/domain-section.md
  index.md              #    grafana: backend, frontend, packages, apps, plugins, api, background
                        #    rust:    compiler, library, tools
                        #    react:   packages, react-compiler, features
  <topic>.md            #    Topic sub-pages under the domain (one .md each)
reference/
  index.md              # Slow-changing reference hub (+ sub-pages below)                   → sections/reference.md
  configuration.md
  data-models.md
  dependencies.md
maintainers.md          # Who owns what (from CODEOWNERS / governance)                      → sections/maintainers.md
```

**How to decide the `<domain>` sections:** look at the repo's real top-level
directory split and group by major area. Each box in the Architecture diagram
should map to a directory, and each directory cluster usually earns a domain
section. Don't invent areas the repo doesn't have.

---

## 2. Global conventions (apply to every page)

| Rule | Detail |
|------|--------|
| One file = one page | Plain GitHub-Flavored Markdown (`.md`). No frontmatter needed. |
| Heading levels | `#` = page title (once, top). In-body sections use `##` / `###`. Headings get auto-slug anchors, so keep them short and stable. |
| Ground every claim | Tie statements to a real **repo-root-relative path** (`pkg/api/api.go`), a **number**, a **commit hash**, or a **date**. No vague prose. |
| Link to source | Reference files as inline code; where the renderer supports it, link to the GitHub blob URL (`https://github.com/<org>/<repo>/blob/main/<path>`). |
| Cross-link pages | Refer to other wiki pages by their human title (e.g. "see **Architecture**", "see **By the numbers**"). End most pages with a "See also" line. |
| Tables for structure | Use GFM pipe tables for any audience→action, term→meaning, file→role, or metric→value mapping. They are the backbone of these wikis. |
| Code blocks | Fence with a language tag (`go`, `ts`, `bash`, …) so Shiki highlights them. Use real, copy-pasteable commands. |
| Diagrams | Use ```mermaid fenced blocks. Every node should correspond to a real directory or component. |
| Directory maps | Use a fenced tree block (`├──`, `└──`) with a `# comment` after each entry explaining its role. |
| Tone | Dense, factual, oriented to a developer reading the code for the first time. Second person is fine ("you'll hit the Go server first"). Surface the *non-obvious*. |
| Snapshot honesty | When you cite counts/commits, state the date + commit they were measured at (see **By the numbers**). |

---

## 3. Section template index

Generate each page using its template in `./sections/`:

| Page | Template |
|------|----------|
| `overview/index.md` | [`sections/landing-overview.md`](sections/landing-overview.md) |
| `overview/architecture.md` | [`sections/architecture.md`](sections/architecture.md) |
| `overview/getting-started.md` | [`sections/getting-started.md`](sections/getting-started.md) |
| `overview/glossary.md` | [`sections/glossary.md`](sections/glossary.md) |
| `by-the-numbers.md` | [`sections/by-the-numbers.md`](sections/by-the-numbers.md) |
| `lore.md` | [`sections/lore.md`](sections/lore.md) |
| `fun-facts.md` | [`sections/fun-facts.md`](sections/fun-facts.md) |
| `how-to-contribute/index.md` | [`sections/how-to-contribute.md`](sections/how-to-contribute.md) |
| `<domain>/index.md` + topics | [`sections/domain-section.md`](sections/domain-section.md) |
| `reference/index.md` | [`sections/reference.md`](sections/reference.md) |
| `maintainers.md` | [`sections/maintainers.md`](sections/maintainers.md) |
