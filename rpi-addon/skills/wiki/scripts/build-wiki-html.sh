#!/usr/bin/env bash
#
# build-wiki-html.sh — render a wiki/ Markdown tree into one self-contained HTML file.
#
# The AutoWiki skill generates a tree of .md pages under a wiki directory. This
# script inlines every page into the viewer template's #wiki-data stash and writes
# a single wiki/index.html that renders entirely client-side (no server, no
# fetch()), so it opens straight off disk and travels as one file.
#
# It walks <wiki-dir> for *.md, builds a JSON payload {meta, order, pages}, and
# injects it between the build-wiki-html sentinels in the template. Page ORDER
# follows a canonical sequence (index, overview, getting-started, architecture,
# patterns, …) with any remaining pages appended sorted; the viewer groups the
# nav tree by top-level directory from that order.
#
# Idempotent: re-running replaces the stash between the sentinels, so rebuild
# freely after regenerating pages.
#
# Requires: python3 (JSON encoding), awk.
#
# Usage:
#   build-wiki-html.sh [wiki-dir] [--title NAME] [--template PATH] [-o OUTPUT]
#
#   [wiki-dir]        directory holding the .md tree (default: ./wiki)
#   --title NAME      wiki title shown in the viewer (default: wiki-dir basename)
#   --template PATH   viewer template (default: <skill>/references/viewer-template.html)
#   -o OUTPUT         output file (default: <wiki-dir>/index.html)
#
# Examples:
#   build-wiki-html.sh wiki --title "Payments Service"
#   build-wiki-html.sh ./wiki -o /tmp/wiki.html
set -euo pipefail

usage() { sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'; }

WIKI_DIR=""
TITLE=""
TEMPLATE=""
OUTPUT=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --title) TITLE="${2:?--title needs a value}"; shift 2 ;;
    --template) TEMPLATE="${2:?--template needs a value}"; shift 2 ;;
    -o|--output) OUTPUT="${2:?-o needs a value}"; shift 2 ;;
    --*) echo "build-wiki-html: unknown option $1" >&2; exit 2 ;;
    *)
      if [ -z "$WIKI_DIR" ]; then WIKI_DIR="$1"
      else echo "build-wiki-html: unexpected argument $1" >&2; exit 2; fi
      shift ;;
  esac
done

WIKI_DIR="${WIKI_DIR:-./wiki}"
[ -d "$WIKI_DIR" ] || { echo "build-wiki-html: no such wiki-dir: $WIKI_DIR" >&2; exit 2; }
command -v python3 >/dev/null || { echo "build-wiki-html: python3 is required" >&2; exit 2; }

# Default the template to this script's sibling reference.
if [ -z "$TEMPLATE" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  TEMPLATE="$SCRIPT_DIR/../references/viewer-template.html"
fi
[ -f "$TEMPLATE" ] || { echo "build-wiki-html: no such template: $TEMPLATE" >&2; exit 2; }
grep -q 'build-wiki-html:start' "$TEMPLATE" || {
  echo "build-wiki-html: template has no #wiki-data stash to fill" >&2; exit 2; }

[ -n "$TITLE" ] || TITLE="$(basename "$(cd "$WIKI_DIR" && pwd)")"
[ -n "$OUTPUT" ] || OUTPUT="$WIKI_DIR/index.html"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PAYLOAD="$TMP/payload.json"

# 1. Build the JSON payload: walk the tree, order the pages, inline each one.
python3 - "$WIKI_DIR" "$TITLE" > "$PAYLOAD" <<'PY'
import sys, os, json, datetime
wiki, title = sys.argv[1], sys.argv[2]
files = []
for root, _, names in os.walk(wiki):
    for n in names:
        if n.endswith(".md"):
            rel = os.path.relpath(os.path.join(root, n), wiki).replace(os.sep, "/")
            files.append(rel)
files = sorted(set(files))

# Order so every section's pages are contiguous (one nav header each):
# root intro → sections (known first) → root tail → leftovers.
def section_of(p):
    return p.split("/")[0] if "/" in p else ""

def section_pages(sec):
    # within a section: index.md / core.md first, then shallower paths, then sorted
    ps = [f for f in files if section_of(f) == sec]
    return sorted(ps, key=lambda p: (0 if p.rsplit("/", 1)[-1] in ("index.md", "core.md") else 1,
                                     p.count("/"), p))

root_intro = ["index.md", "overview.md", "getting-started.md"]
root_tail = ["by-the-numbers.md", "glossary.md", "reference.md"]
sections = []
for f in files:
    s = section_of(f)
    if s and s not in sections:
        sections.append(s)
known = [s for s in ("architecture", "patterns") if s in sections]
section_seq = known + sorted(s for s in sections if s not in known)

order = [p for p in root_intro if p in files]
for s in section_seq:
    order += section_pages(s)
order += [p for p in root_tail if p in files]
order += [f for f in files if f not in order]  # any leftover root/unknown page

pages = {}
for f in files:
    with open(os.path.join(wiki, f), encoding="utf-8") as fh:
        pages[f] = fh.read()
json.dump(
    {"meta": {"title": title, "generated": datetime.date.today().isoformat()},
     "order": order, "pages": pages},
    sys.stdout, ensure_ascii=False,
)
PY

PAGE_COUNT="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["pages"]))' "$PAYLOAD")"

# 2. Inject the payload between the sentinels in the template → OUTPUT.
mkdir -p "$(dirname "$OUTPUT")"
awk -v payload="$PAYLOAD" '
  /build-wiki-html:start/ {
    print
    while ((getline ln < payload) > 0) print ln
    skip = 1
    next
  }
  /build-wiki-html:end/ { skip = 0; print; next }
  skip == 1 { next }
  { print }
' "$TEMPLATE" > "$OUTPUT"

echo "build-wiki-html: rendered $PAGE_COUNT pages → $OUTPUT"
