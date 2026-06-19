---
name: wiki
description: Generate a Factory-AutoWiki-style codebase wiki — a tree of single Markdown files (overview, architecture, getting started, glossary, by the numbers, lore, fun facts, how to contribute, per-domain sections, reference, maintainers). Use when asked to "generate a wiki", "document this repo", "build a codebase wiki", or produce AutoWiki-style docs for a repository.
---

# Wiki

Generate a complete, navigable codebase wiki modeled on Factory's AutoWiki
(`factory.ai/open-source-wikis/<repo>`): **one Markdown file per page**, organized
into sections, every claim grounded in a real path / number / commit.

## Getting Started

When invoked:

1. Identify the target repository (the current repo unless told otherwise).
2. Read **`references/wiki-generation-template.md`** — the master template. It
   defines the page tree, the global conventions, and which section template to
   use for each page.
3. Explore the repo to gather facts before writing anything (see Workflow).

## Workflow

1. **Survey the repo.** Map the top-level directory split, entry points, build
   system, languages, and license. This determines the repo-specific `<domain>`
   sections (Backend/Frontend, Compiler/Library, Packages/Compiler, …).
2. **Gather the numbers.** Run the git/SLOC commands in
   `references/sections/by-the-numbers.md` and record the snapshot date + commit.
3. **Build the page tree.** Use the manifest in the master template. Create the
   universal pages plus one `<domain>/` section per major area.
4. **Generate each page from its section template.** Open the matching file in
   `references/sections/`, follow its skeleton + notes, and fill it with facts
   from step 1–2. Honor the global conventions (GFM tables, Shiki-tagged code
   fences, ```mermaid diagrams, repo-root-relative paths, cross-links).
5. **Cross-link and review.** Ensure pages reference each other by title and that
   every diagram node / table row maps to a real path.

## References

- **`references/wiki-generation-template.md`** — master template: page tree,
  conventions, and the section-template index.
- **`references/sections/*.md`** — one template per page type:
  `landing-overview`, `architecture`, `getting-started`, `glossary`,
  `by-the-numbers`, `lore`, `fun-facts`, `how-to-contribute`, `domain-section`,
  `reference`, `maintainers`. Each has a skeleton, notes, and a real excerpt.
