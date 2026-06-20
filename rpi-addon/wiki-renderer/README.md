# wiki-renderer

A minimal Next.js (App Router) viewer for the Markdown wikis produced by the
`wiki` skill. Mirrors the factory.ai AutoWiki render stack:

**react-markdown + remark-gfm + react-shiki (Shiki) + Mermaid + Tailwind Typography**

## Run it

```bash
cd wiki-renderer
npm install
npm run dev          # http://localhost:3000  → redirects to /wiki
```

## Use your own content

Drop the generated wiki tree into `content/`. The router maps URLs to files:

| URL | File |
|-----|------|
| `/wiki` | `content/overview/index.md` (default) |
| `/wiki/overview/architecture` | `content/overview/architecture.md` |
| `/wiki/fun-facts` | `content/fun-facts.md` |

Folders become sidebar groups (their `index.md` is the group page); other `.md`
files become links. Tables, fenced code (Shiki, dual light/dark), and ```mermaid
diagrams all render automatically.

## How it maps to the stack

| Concern | Where |
|---------|-------|
| Markdown → React | `components/Markdown.tsx` (`react-markdown`) |
| GFM tables/etc. | `remark-gfm` |
| Heading anchors | `rehype-slug` + `rehype-autolink-headings` |
| Code highlighting | `react-shiki` (`theme={{ light, dark }}`) + `app/globals.css` |
| Diagrams | `components/Mermaid.tsx` (`mermaid`) |
| Prose styling | Tailwind Typography `prose` |
| Content loading / nav | `lib/content.ts` |
