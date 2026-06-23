#!/usr/bin/env bash
# dump-task-session.sh — pull the two things you can ONLY get from HumanLayer for a
# completed task: per-phase timing, and every message that happened AFTER
# implementation began (the iteration trail). The design artifacts themselves are
# read straight from the task dir by the skill, so we don't dump transcripts.
#
# Usage:
#   dump-task-session.sh [TASK_ID_OR_SLUG] [OUTDIR]
#     (no arg)  auto-detect the task from the current git branch (branch == slug)
#     OUTDIR    default: <task working dir>/.humanlayer/tasks/<slug>/reflect-on-task
#
# Writes:
#   phases.md               — per-phase timing (active min, share, your turns, errors, window)
#   post-implementation.md  — chronological messages after implementation started
#
# Requires: humanlayer CLI (authenticated, --beta env) and jq.
set -euo pipefail

HL() { humanlayer --beta api "$@"; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

arg="${1:-}"
outdir_arg="${2:-}"

# --- resolve the task ---------------------------------------------------------
tf="$(mktemp)"; sf="$(mktemp)"; evf="$(mktemp)"; msg="$(mktemp)"
trap 'rm -f "$tf" "$sf" "$evf" "$msg"' EXIT
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

if   [ -n "$outdir_arg" ];                          then OUTDIR="$outdir_arg"
elif [ -n "$WORKDIR" ] && [ -d "$WORKDIR/.humanlayer/tasks/$SLUG" ]; then OUTDIR="$WORKDIR/.humanlayer/tasks/$SLUG/reflect-on-task"
elif [ -d ".humanlayer/tasks/$SLUG" ];              then OUTDIR=".humanlayer/tasks/$SLUG/reflect-on-task"
else OUTDIR="${WORKDIR:-.}/.humanlayer/tasks/$SLUG/reflect-on-task"
fi
mkdir -p "$OUTDIR"
: > "$OUTDIR/.phases.tsv"
: > "$msg"
echo "Task: $SLUG ($TASK_ID)" >&2
echo "Out:  $OUTDIR" >&2

# --- shared jq fragments ------------------------------------------------------
# Active minutes: sum inter-event gaps, capping gaps >3min as idle.
ACTIVE_JQ='[(.rows // .)[] | (.created_at|tonumber)] | sort as $t
  | (reduce range(1;($t|length)) as $i (0; ($t[$i]-$t[$i-1]) as $g | . + (if $g<180000 then $g else 0 end)))/60000 | floor'
# Genuine human turns (not skill/system injections).
HUMAN_SEL='.role=="user" and .event_type=="message" and ((.content|length)<2000)
  and ((.content|test("Base directory for this skill|example_subagent|<guidance>|SKILLBASE|discovery stub|<system|^```"))|not)'
ERR_RE='(?i)exit code [1-9]|\\bFAIL\\b|Traceback|is not a function|undefined is not'

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

# --- per-session pass ---------------------------------------------------------
HL sessions list --task-id "$TASK_ID" --limit 100 > "$sf" 2>/dev/null
jq empty "$sf" >/dev/null 2>&1 || { echo "sessions list returned no valid JSON" >&2; exit 1; }

i=0
while IFS=$'\t' read -r sid title status events; do
  i=$((i+1))
  HL sessions events list --session-id "$sid" --limit 1000 > "$evf" 2>/dev/null || true
  jq empty "$evf" >/dev/null 2>&1 || echo '{"rows":[]}' > "$evf"
  phase="$(phase_of "$title")"

  active="$(jq -r "$ACTIVE_JQ" "$evf" 2>/dev/null || echo 0)"
  turns="$(jq -r "[(.rows // .)[] | select($HUMAN_SEL)] | length" "$evf" 2>/dev/null || echo 0)"
  errors="$(jq -r "[(.rows // .)[] | select(.event_type==\"tool_result\") | select((.tool_result_content // \"\")|test(\"$ERR_RE\"))] | length" "$evf" 2>/dev/null || echo 0)"
  first="$(jq -r '[(.rows // .)[].created_at|tonumber] | min // 0' "$evf" 2>/dev/null || echo 0)"
  last="$(jq -r  '[(.rows // .)[].created_at|tonumber] | max // 0' "$evf" 2>/dev/null || echo 0)"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$phase" "$active" "$turns" "$errors" "$first" "$last" >> "$OUTDIR/.phases.tsv"

  # Candidate iteration messages (filtered by time after the loop): human turns,
  # assistant root-cause lines, and error results — each with epoch ts + phase.
  jq -r --arg ph "$phase" "
    (.rows // .) | sort_by(.created_at) | .[] |
    if   ($HUMAN_SEL) then [(.created_at), \$ph, \"human\", ((.content//\"\")|gsub(\"\\n\";\" \")|.[0:400])]
    elif (.role==\"assistant\" and .event_type==\"message\"
          and ((.content//\"\")|test(\"(?i)root cause|the issue is|turns out|because |the bug|we missed|wasn.t accounted|not handled|edge case\")))
         then [(.created_at), \$ph, \"diag\", ((.content//\"\")|gsub(\"\\n\";\" \")|.[0:400])]
    elif (.event_type==\"tool_result\" and ((.tool_result_content//\"\")|test(\"$ERR_RE\")))
         then [(.created_at), \$ph, \"error\", ((.tool_result_content//\"\")|gsub(\"\\n\";\" \")|.[0:160])]
    else empty end | @tsv" "$evf" 2>/dev/null >> "$msg" || true

  echo "  [$i] $phase  active=${active}min turns=${turns} err=${errors}" >&2
done < <(jq -r '(.rows // .) | sort_by(.created_at) | .[]
  | [.id, (.title // .summary // "untitled"), .status, (.num_events // 0)] | @tsv' "$sf")

# --- when did implementation start? -------------------------------------------
# Earliest first-event timestamp among implementation-phase sessions.
IMPL_START="$(awk -F'\t' '$1=="6-implementation" && $5+0>0 {print $5}' "$OUTDIR/.phases.tsv" | sort -n | head -1)"

# --- phases.md ----------------------------------------------------------------
{
  echo "# Phase timing — $SLUG"
  echo
  echo "_Task \`$TASK_ID\` · $(date -u '+%Y-%m-%d %H:%M UTC') · $i sessions_"
  echo
  echo "| phase | active min | share | your turns | errors | window (UTC) |"
  echo "|---|--:|--:|--:|--:|---|"
  awk -F'\t' '
    { a[$1]+=$2; t[$1]+=$3; e[$1]+=$4;
      if (f[$1]==0 || $5<f[$1]) f[$1]=$5; if ($6>l[$1]) l[$1]=$6; tot+=$2 }
    END {
      for (p in a) {
        sh = tot>0 ? a[p]*100/tot : 0
        cmd="date -u -r " int(f[p]/1000) " +%H:%M 2>/dev/null"; cmd|getline fs; close(cmd)
        cmd="date -u -r " int(l[p]/1000) " +%H:%M 2>/dev/null"; cmd|getline ls; close(cmd)
        printf "%s\t%d\t%.0f\t%d\t%d\t%s-%s\n", p, a[p], sh, t[p], e[p], fs, ls
      }
    }' "$OUTDIR/.phases.tsv" | sort | awk -F'\t' '{printf "| %s | %d | %d%% | %d | %d | %s |\n",$1,$2,$3,$4,$5,$6}'
  echo
  if [ -n "$IMPL_START" ]; then
    echo "_Implementation started at $(date -u -r "$((IMPL_START/1000))" '+%Y-%m-%d %H:%M UTC' 2>/dev/null). Everything after that is in post-implementation.md._"
  else
    echo "_No implementation-phase session detected; post-implementation.md may be empty._"
  fi
  echo
  echo "_active min = inter-event time with idle gaps >3min removed; share = % of total active time; turns are exact._"
} > "$OUTDIR/phases.md"

# --- post-implementation.md ---------------------------------------------------
{
  echo "# After implementation — $SLUG"
  echo
  echo "_Human turns (iteration asks), assistant root-cause lines, and errors that"
  echo "occurred once implementation began. Cross-reference each against the design"
  echo "artifacts: what should the PRD/TDD/outline have caught?_"
  echo
  start="${IMPL_START:-0}"
  sort -n "$msg" | awk -F'\t' -v s="$start" '($1+0)>=s {
      cmd="date -u -r " int($1/1000) " +%H:%M 2>/dev/null"; cmd|getline ts; close(cmd)
      kind=$3; mark=(kind=="human"?"[you]":(kind=="diag"?"[diag]":"[err]"))
      printf "- `%s` %s **%s** _(%s)_ — %s\n", ts, mark, kind, $2, $4
    }'
} > "$OUTDIR/post-implementation.md"

echo "DONE → $OUTDIR/phases.md , $OUTDIR/post-implementation.md" >&2
echo "$OUTDIR"
