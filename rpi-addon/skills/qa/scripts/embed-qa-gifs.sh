#!/usr/bin/env bash
#
# embed-qa-gifs.sh — fill a QA report's #gifs stash with base64-embedded GIFs.
#
# The QA report (qa-report.html) is a self-contained inline HumanLayer artifact
# written FLAT to the task directory, where the qa-<flow>.gif files sit beside it
# (the artifact system has no nested folders). It renders in the cloud, where a
# relative <img src="qa-<flow>.gif"> would not resolve — so every flow GIF is
# base64-EMBEDDED instead of linked.
#
# The model writes the report with a `gif: "<flow-key>"` on each flow and an
# EMPTY stash:
#
#     <div id="gifs" hidden>
#     </div>
#
# This script reads every `gif:` key out of the FLOWS array, base64-encodes the
# matching <gif-dir>/<key>.gif, and rewrites the stash so each key gets a
# <script type="text/plain" data-gif="<key>">…base64…</script> block. The
# renderer reads it back and sets the <img> to a data: URI.
#
# Why a script: the base64 (hundreds of KB per GIF) never has to pass through the
# model's context just to land in a file. The model decides WHICH GIFs to embed
# (via the `gif:` keys); the bytes are injected here.
#
# Idempotent: it replaces the contents of <div id="gifs" hidden>…</div> between
# sentinel comments each run, so re-running after editing FLOWS just refreshes it.
#
# Usage:
#   embed-qa-gifs.sh <report.html> [gif-dir]
#
#   <report.html>   the QA report to rewrite (edited in place)
#   [gif-dir]       directory holding the <key>.gif files (default: the report's
#                   own directory, i.e. the task dir where they sit flat beside it)
#
# After running, Read(<report.html>, limit=1) so the artifact store re-syncs the
# on-disk edit to the cloud (same rule as inject-walkthrough-diffs.sh).
#
# Examples:
#   embed-qa-gifs.sh .humanlayer/tasks/my-task/qa-report.html
#   embed-qa-gifs.sh ../task/qa-report.html /tmp/built-gifs
set -euo pipefail

usage() { sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'; }

TARGET=""
GIF_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --*) echo "embed-qa-gifs: unknown option $1" >&2; exit 2 ;;
    *)
      if [ -z "$TARGET" ]; then TARGET="$1"
      elif [ -z "$GIF_DIR" ]; then GIF_DIR="$1"
      else echo "embed-qa-gifs: unexpected argument $1" >&2; exit 2; fi
      shift ;;
  esac
done

[ -n "$TARGET" ] || { echo "embed-qa-gifs: missing <report.html>" >&2; usage; exit 2; }
[ -f "$TARGET" ] || { echo "embed-qa-gifs: no such file: $TARGET" >&2; exit 2; }
grep -q '<div id="gifs"' "$TARGET" || {
  echo "embed-qa-gifs: target has no <div id=\"gifs\" …> stash to fill" >&2; exit 2; }

# Resolve the GIF directory: explicit arg, else the report's own directory — the
# task dir, where the qa-<flow>.gif files sit flat beside the report.
if [ -z "$GIF_DIR" ]; then GIF_DIR="$(dirname "$TARGET")"; fi
[ -d "$GIF_DIR" ] || { echo "embed-qa-gifs: no such gif-dir: $GIF_DIR" >&2; exit 2; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
WANTED="$TMP/wanted"
STASH="$TMP/stash"
OUT="$TMP/out.html"
: > "$STASH"
: > "$TMP/missing"

# 1. Collect the flow keys the model asked to embed (gif: "…" in FLOWS).
grep -oE 'gif:[[:space:]]*"[^"]+"' "$TARGET" \
  | sed -E 's/^gif:[[:space:]]*"([^"]+)".*/\1/' \
  | grep -v '[{}]' \
  | sort -u > "$WANTED" || true
if [ ! -s "$WANTED" ]; then
  echo "embed-qa-gifs: no gif: entries found in $TARGET — nothing to embed" >&2
  exit 0
fi

# 2. base64-encode each GIF into a stash <script> block. base64 is emitted on a
#    single line (no wrapping) so the renderer's whitespace-strip is trivial.
INJECTED=0
while IFS= read -r key; do
  [ -n "$key" ] || continue
  gif="$GIF_DIR/$key.gif"
  if [ ! -f "$gif" ]; then
    printf '%s\n' "$key" >> "$TMP/missing"
    continue
  fi
  printf '<script type="text/plain" data-gif="%s">\n' "$key" >> "$STASH"
  base64 < "$gif" | tr -d '\n' >> "$STASH"
  printf '\n</script>\n' >> "$STASH"
  INJECTED=$((INJECTED + 1))
done < "$WANTED"

# 3. Rewrite the target: replace everything inside <div id="gifs" …> … </div>
#    with the freshly generated blocks, wrapped in sentinel comments so re-runs
#    are idempotent. On a first run (no markers) the stash is empty, so the first
#    standalone </div> after the opening tag is the real close.
HAS_MARKERS=0
grep -q 'embed-qa-gifs:start' "$TARGET" && HAS_MARKERS=1
awk -v stashfile="$STASH" -v hasmarkers="$HAS_MARKERS" '
  BEGIN {
    STARTM = "<!-- embed-qa-gifs:start (auto-generated — re-run the script to refresh) -->"
    ENDM   = "<!-- embed-qa-gifs:end -->"
  }
  state == 0 && /<div id="gifs"/ {
    print
    print STARTM
    while ((getline ln < stashfile) > 0) print ln
    print ENDM
    state = 1; awaitclose = 0
    next
  }
  state == 1 {
    if (hasmarkers == "1") {
      if (index($0, "embed-qa-gifs:end") > 0) { awaitclose = 1; next }
      if (awaitclose == 1 && $0 ~ /^[[:space:]]*<\/div>[[:space:]]*$/) { print; state = 0 }
      next
    }
    if ($0 ~ /^[[:space:]]*<\/div>[[:space:]]*$/) { print; state = 0 }
    next
  }
  { print }
' "$TARGET" > "$OUT"

cp "$OUT" "$TARGET"

# 4. Report.
WANT_N="$(wc -l < "$WANTED" | tr -d ' ')"
echo "embed-qa-gifs: embedded $INJECTED/$WANT_N GIFs into $TARGET"
if [ -s "$TMP/missing" ]; then
  echo "  warning: no GIF found for these keys (typo, or not captured in $GIF_DIR):" >&2
  sed 's/^/    - /' "$TMP/missing" >&2
fi
