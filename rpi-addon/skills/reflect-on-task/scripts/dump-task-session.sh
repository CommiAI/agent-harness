#!/usr/bin/env bash
# dump-task-session.sh — pipe a HumanLayer task's full session history into a
# readable directory for retrospective analysis.
#
# Usage:
#   dump-task-session.sh [TASK_ID_OR_SLUG] [OUTDIR]
#     (no arg)  auto-detect the task from the current git branch (branch == slug)
#     OUTDIR    default: <task working dir>/.humanlayer/tasks/<slug>/reflect-on-task
#
# Requires: humanlayer CLI (authenticated) and jq.
# Note: the HumanLayer API needs the --beta environment for org context.
set -euo pipefail

HL() { humanlayer --beta api "$@"; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

arg="${1:-}"
outdir_arg="${2:-}"

# --- resolve the task ---------------------------------------------------------
# All large API responses go through files — big JSON gets corrupted when held
# in a shell variable (command substitution strips embedded NULs).
tf="$(mktemp)"; sf="$(mktemp)"; trap 'rm -f "$tf" "$sf"' EXIT
HL tasks list --limit 100 > "$tf" 2>/dev/null
jq empty "$tf" >/dev/null 2>&1 || { echo "tasks list returned no valid JSON (is the CLI authenticated?)" >&2; exit 1; }
[ -z "$arg" ] && arg="$(git branch --show-current 2>/dev/null || true)"

TASK_ID="$(jq -r --arg k "$arg" '(.rows // .)[] | select(.id==$k or .slug==$k) | .id' "$tf" | head -1)"
if [ -z "$TASK_ID" ]; then
  echo "Could not resolve a task from '$arg'. Available tasks:" >&2
  jq -r '(.rows // .)[] | "  \(.slug)  (\(.id))"' "$tf" >&2
  exit 1
fi
SLUG="$(jq -r --arg k "$TASK_ID" '(.rows // .)[] | select(.id==$k) | .slug' "$tf")"
WORKDIR="$(jq -r --arg k "$TASK_ID" '(.rows // .)[] | select(.id==$k) | .default_working_directory // ""' "$tf")"

# Default: write into the task's own artifacts directory. Prefer the task's
# working dir if known, else fall back to the current tree.
if   [ -n "$outdir_arg" ];                          then OUTDIR="$outdir_arg"
elif [ -n "$WORKDIR" ] && [ -d "$WORKDIR/.humanlayer/tasks/$SLUG" ]; then OUTDIR="$WORKDIR/.humanlayer/tasks/$SLUG/reflect-on-task"
elif [ -d ".humanlayer/tasks/$SLUG" ];              then OUTDIR=".humanlayer/tasks/$SLUG/reflect-on-task"
else OUTDIR="${WORKDIR:-.}/.humanlayer/tasks/$SLUG/reflect-on-task"
fi
mkdir -p "$OUTDIR"
: > "$OUTDIR/.rows.tsv"
echo "Task: $SLUG ($TASK_ID)" >&2
echo "Out:  $OUTDIR" >&2

# --- shared jq fragments ------------------------------------------------------
# Active minutes: sum of inter-event gaps, capping gaps >3min as idle (so paused
# sessions don't inflate "time spent").
ACTIVE_JQ='[(.rows // .)[] | (.created_at|tonumber)] | sort as $t
  | (reduce range(1;($t|length)) as $i (0; ($t[$i]-$t[$i-1]) as $g | . + (if $g<180000 then $g else 0 end)))/60000 | floor'
# Genuine human turns: role=user messages that are not skill/system injections.
HUMAN_JQ='[(.rows // .)[] | select(.role=="user" and .event_type=="message"
  and ((.content|length)<2000)
  and ((.content|test("Base directory for this skill|example_subagent|<guidance>|SKILLBASE|discovery stub|<system|^```"))|not))]'

phase_of() { case "$1" in
  "Research questions"*|research:*)            echo "1-research" ;;
  design-prd:*|"Define User Flows"*)           echo "2-product-design" ;;
  design-tdd:*|structure:*)                    echo "3-tech-design" ;;
  *"UI Rendering Pattern"*|*"Permission Gate"*) echo "4-ui-design" ;;
  worktree-setup:*)                            echo "5-setup" ;;
  implementation:*)                            echo "6-implementation" ;;
  QA*)                                         echo "7-qa" ;;
  describe-pr:*)                               echo "8-pr" ;;
  *)                                           echo "0-discussion" ;;
esac }

# --- per-session dump ---------------------------------------------------------
HL sessions list --task-id "$TASK_ID" --limit 100 > "$sf" 2>/dev/null
jq empty "$sf" >/dev/null 2>&1 || { echo "sessions list returned no valid JSON" >&2; exit 1; }
cp "$sf" "$OUTDIR/sessions.json"

evf="$(mktemp)"; trap 'rm -f "$tf" "$sf" "$evf"' EXIT
i=0
while IFS=$'\t' read -r sid title status cost events; do
  i=$((i+1))
  # Write events to a file (large sessions break inside shell variables) and
  # fall back to an empty set if the response isn't valid JSON.
  HL sessions events list --session-id "$sid" --limit 1000 > "$evf" 2>/dev/null || true
  jq empty "$evf" >/dev/null 2>&1 || echo '{"rows":[]}' > "$evf"
  active="$(jq -r "$ACTIVE_JQ" "$evf" 2>/dev/null || echo 0)"
  human="$(jq -r "$HUMAN_JQ | length" "$evf" 2>/dev/null || echo 0)"
  errors="$(jq -r '[(.rows // .)[] | select(.event_type=="tool_result")
            | select((.tool_result_content // "")|test("(?i)exit code [1-9]|\\bFAIL\\b|Traceback|is not a function|undefined is not"))] | length' "$evf" 2>/dev/null || echo 0)"
  phase="$(phase_of "$title")"
  safe="$(printf '%s' "$title" | tr -c 'A-Za-z0-9' '-' | cut -c1-48)"
  f="$OUTDIR/$(printf '%02d' "$i")-$phase-$safe.md"

  {
    echo "# $title"
    echo
    echo "- session: \`$sid\`  ·  phase: **$phase**  ·  status: $status"
    echo "- active: **${active} min**  ·  your turns: **${human}**  ·  error results: ${errors}  ·  events: ${events}  ·  cost: \$${cost}"
    echo
    echo "## Your turns (re-steering)"
    jq -r "$HUMAN_JQ"'[] | "- " + (.content | gsub("\n";" ") | .[0:300])' "$evf" 2>/dev/null || true
    echo
    echo "## Condensed transcript"
    jq -r '(.rows // .) | sort_by(.created_at) | .[] |
      if   .event_type=="message" and .role=="user"      then "\n**👤 You:** "       + ((.content//"")|gsub("\n";" ")|.[0:600])
      elif .event_type=="message" and .role=="assistant" then "\n**🤖 Assistant:** " + ((.content//"")|gsub("\n";" ")|.[0:600])
      elif .event_type=="tool_call"                      then "  - 🔧 " + (.tool_name//"tool")
      elif .event_type=="tool_result" and ((.tool_result_content//"")|test("(?i)exit code [1-9]|\\bFAIL\\b|Traceback")) then "    ⚠️ error"
      else empty end' "$evf" 2>/dev/null || true
  } > "$f"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$phase" "$active" "$human" "$errors" "$cost" "$title" >> "$OUTDIR/.rows.tsv"
  echo "  [$i] $phase  active=${active}min turns=${human} err=${errors}  → $f" >&2
done < <(jq -r '(.rows // .) | sort_by(.created_at) | .[]
  | [.id, (.title // .summary // "untitled"), .status, (.total_cost_usd // 0), (.num_events // 0)] | @tsv' "$sf")

# --- overview -----------------------------------------------------------------
{
  echo "# Task retro — $SLUG"
  echo
  echo "_Task \`$TASK_ID\` · $(date -u '+%Y-%m-%d %H:%M UTC') · $i sessions_"
  echo
  echo "## Time you spent, by phase (sorted)"
  echo
  echo "| phase | active min | your turns | error results |"
  echo "|---|--:|--:|--:|"
  awk -F'\t' '{a[$1]+=$2; h[$1]+=$3; e[$1]+=$4}
    END{for(p in a) printf "| %s | %d | %d | %d |\n", p, a[p], h[p], e[p]}' "$OUTDIR/.rows.tsv" | sort -t'|' -k3 -rn
  echo
  echo "## Top time sinks (sessions, by active time)"
  echo
  echo "| active min | your turns | err | session |"
  echo "|--:|--:|--:|---|"
  awk -F'\t' '{printf "| %d | %d | %d | %s |\n", $2, $3, $4, $6}' "$OUTDIR/.rows.tsv" | sort -t'|' -k2 -rn | head -8
  echo
  echo "## Totals"
  awk -F'\t' '{ta+=$2; th+=$3; te+=$4}
    END{printf "- active: **%d min** · your turns: **%d** · error results: **%d**\n", ta, th, te}' "$OUTDIR/.rows.tsv"
  echo
  echo "_Note: active time per session is capped at the most recent 1000 events; very long sessions (QA, implementation) underestimate, but turn counts are exact._"
} > "$OUTDIR/_overview.md"

echo "DONE → $OUTDIR/_overview.md" >&2
echo "$OUTDIR"
