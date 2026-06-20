import fs from "node:fs";
import path from "node:path";

// Root directory that holds the generated wiki Markdown tree.
export const CONTENT_DIR = path.join(process.cwd(), "content");

// Page shown when the user lands on "/wiki" with no slug.
const DEFAULT_SLUG = ["overview"];

// Re-exported for server callers; the canonical definition is client-safe.
export { WIKI_NAME } from "./config";

// Sidebar order from the wiki master template's universal page-tree manifest,
// keyed by the parent slug path ("" = root). Names are the base name of a file
// (without `.md`) or a directory. The "*" entry is a slot for repo-specific
// domain sections (packages, apps, services, …): anything not named explicitly
// lands there, alphabetically. Children of those domains have no template order,
// so they fall back to alphabetical too. `index.md` is a group's own page and is
// never a child, so it isn't listed.
const SIDEBAR_ORDER: Record<string, string[]> = {
  "": [
    "overview",
    "by-the-numbers",
    "lore",
    "fun-facts",
    "how-to-contribute",
    "*",
    "reference",
    "maintainers",
  ],
  overview: ["architecture", "getting-started", "glossary"],
  "how-to-contribute": [
    "development-workflow",
    "testing",
    "debugging",
    "patterns-and-conventions",
    "tooling",
  ],
  reference: ["configuration", "data-models", "dependencies"],
};

// Position of `name` within its parent's manifest order. Unlisted names take the
// "*" domain slot if one exists, otherwise sort to the end.
function orderIndex(parentSlug: string[], name: string): number {
  const order = SIDEBAR_ORDER[parentSlug.join("/")];
  if (!order) return Number.MAX_SAFE_INTEGER;
  const i = order.indexOf(name);
  if (i !== -1) return i;
  const slot = order.indexOf("*");
  return slot === -1 ? Number.MAX_SAFE_INTEGER : slot;
}

export interface NavNode {
  title: string; // display label
  slug: string[]; // url slug parts, e.g. ["overview", "architecture"]
  href: string; // "/wiki/overview/architecture"
  hasPage: boolean; // is there a .md to render for this node?
  children: NavNode[];
}

function titleFromName(name: string): string {
  const base = name.replace(/\.md$/, "");
  return base
    .split(/[-_]/g)
    .map((w) => (w ? w[0].toUpperCase() + w.slice(1) : w))
    .join(" ");
}

function hrefFor(slug: string[]): string {
  return "/wiki" + (slug.length ? "/" + slug.join("/") : "");
}

// Resolve a url slug to an actual .md file path. Supports both
// "<slug>.md" and "<slug>/index.md" layouts.
export function resolveFile(slug: string[]): string | null {
  const parts = slug.length ? slug : DEFAULT_SLUG;
  const asFile = path.join(CONTENT_DIR, ...parts) + ".md";
  if (fs.existsSync(asFile)) return asFile;
  const asIndex = path.join(CONTENT_DIR, ...parts, "index.md");
  if (fs.existsSync(asIndex)) return asIndex;
  return null;
}

export function readMarkdown(slug: string[]): string | null {
  const file = resolveFile(slug);
  if (!file) return null;
  return fs.readFileSync(file, "utf8");
}

// Pull the first H1 line out of the markdown so the page can render it as the
// article title (Factory style) and the body as `.wiki-prose`.
export function splitTitle(
  md: string,
  fallback: string,
): { title: string; body: string } {
  const lines = md.split("\n");
  const i = lines.findIndex((l) => /^#\s+/.test(l));
  if (i === -1) return { title: fallback, body: md };
  const title = lines[i].replace(/^#\s+/, "").trim();
  lines.splice(i, 1);
  return { title, body: lines.join("\n").replace(/^\n+/, "") };
}

export interface CrumbItem {
  title: string;
  href: string;
}

// Breadcrumb trail from the wiki root to the current page, using nav titles.
export function breadcrumbTrail(nav: NavNode[], slug: string[]): CrumbItem[] {
  const trail: CrumbItem[] = [];
  let level = nav;
  const acc: string[] = [];
  for (const part of slug) {
    acc.push(part);
    const node = level.find((n) => n.slug[n.slug.length - 1] === part);
    if (!node) break;
    trail.push({ title: node.title, href: node.href });
    level = node.children;
  }
  return trail;
}

export interface FlatPage {
  title: string;
  href: string;
}

// Depth-first flatten of the nav into the linear reading order, keeping only
// nodes that have a page. Used to compute prev/next.
export function flattenPages(nav: NavNode[]): FlatPage[] {
  const out: FlatPage[] = [];
  const visit = (nodes: NavNode[]) => {
    for (const n of nodes) {
      if (n.hasPage) out.push({ title: n.title, href: n.href });
      if (n.children.length) visit(n.children);
    }
  };
  visit(nav);
  return out;
}

// The previous/next pages relative to the current href in reading order.
export function prevNext(
  nav: NavNode[],
  href: string,
): { prev: FlatPage | null; next: FlatPage | null } {
  const pages = flattenPages(nav);
  const i = pages.findIndex((p) => p.href === href);
  if (i === -1) return { prev: null, next: null };
  return {
    prev: i > 0 ? pages[i - 1] : null,
    next: i < pages.length - 1 ? pages[i + 1] : null,
  };
}

// Walk the content directory into a nav tree for the sidebar.
export function buildNav(): NavNode[] {
  if (!fs.existsSync(CONTENT_DIR)) return [];
  return walk(CONTENT_DIR, []);
}

function walk(dir: string, slugPrefix: string[]): NavNode[] {
  const entries = fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((e) => !e.name.startsWith("."));

  // Directories become groups (their index.md is the group's own page);
  // standalone .md files become leaf links. Both share one ordered list so the
  // sidebar can interleave them per the template manifest (e.g. the `overview`
  // group, then the `by-the-numbers`/`lore`/`fun-facts` files, then more groups).
  const nodes: { name: string; node: NavNode }[] = [];

  for (const e of entries) {
    if (e.isDirectory()) {
      const slug = [...slugPrefix, e.name];
      const childDir = path.join(dir, e.name);
      const hasIndex = fs.existsSync(path.join(childDir, "index.md"));
      nodes.push({
        name: e.name,
        node: {
          title: titleFromName(e.name),
          slug,
          href: hrefFor(slug),
          hasPage: hasIndex,
          children: walk(childDir, slug),
        },
      });
    } else if (e.isFile() && e.name.endsWith(".md") && e.name !== "index.md") {
      const base = e.name.replace(/\.md$/, "");
      const slug = [...slugPrefix, base];
      nodes.push({
        name: base,
        node: {
          title: titleFromName(e.name),
          slug,
          href: hrefFor(slug),
          hasPage: true,
          children: [],
        },
      });
    }
  }

  // Order by the template manifest, then alphabetically for anything unlisted.
  nodes.sort((a, b) => {
    const oa = orderIndex(slugPrefix, a.name);
    const ob = orderIndex(slugPrefix, b.name);
    return oa - ob || a.name.localeCompare(b.name);
  });

  return nodes.map((n) => n.node);
}
