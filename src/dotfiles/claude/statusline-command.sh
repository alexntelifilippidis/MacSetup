#!/usr/bin/env bash
# Claude Code status line — two-row display
#
# Receives JSON session data on stdin on every assistant message, /compact,
# permission-mode change, or vim-mode toggle. Prints two rows to stdout.
#
# Row 1:  [Model]  📁 dir  🌿 branch  +staged  ~modified  PR #N
# Row 2:  [████░░░░░░] 40%  💰 $0.0042  ⏱️ 3m 12s

input=$(cat)

# ── Parse session data ────────────────────────────────────────────────────────
# model.display_name: short label shown in the Claude UI (e.g. "Sonnet 4.6")
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# workspace.current_dir: CWD as seen by Claude (preferred over legacy .cwd)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')

# cost fields accumulate from session start; total_cost_usd is a client-side estimate
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
dur_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# used_percentage: fraction of context window consumed by input tokens.
# null before the first API response — fall back to 0 so bar renders cleanly.
pct_raw=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
pct_int=$(printf '%.0f' "${pct_raw:-0}")

# session_id is stable for the lifetime of a session and unique across sessions —
# use it as the cache key so concurrent sessions don't share git state.
session_id=$(echo "$input" | jq -r '.session_id // "default"')

# pr.number present when an open PR exists for the current branch
pr_num=$(echo "$input" | jq -r '.pr.number // empty')

# ── Colors — orange/blue palette (256-color) ──────────────────────────────────
# 208=orange (primary), 033=blue (accent), 110=light-blue (accent light), 255=white
ORANGE='\033[38;5;208m'     # primary — model label, branch, cost
BLUE='\033[38;5;33m'        # accent — dir path
LIGHT_BLUE='\033[38;5;110m' # accent light — PR, time
WHITE='\033[38;5;255m'      # text — duration
GREEN='\033[32m'            # semantic — staged (ready to commit)
YELLOW='\033[33m'           # semantic — modified (unstaged)
RED='\033[31m'              # semantic — high context usage
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Git info (cached per session, refreshed every 5 s to avoid lag in large repos) ──
CACHE="/tmp/cc-statusline-${session_id}"
stale=1
if [ -f "$CACHE" ]; then
  # stat -f %m = macOS mtime epoch; stat -c %Y = Linux equivalent
  mtime=$(stat -f %m "$CACHE" 2> /dev/null || stat -c %Y "$CACHE" 2> /dev/null || echo 0)
  [ $(($(date +%s) - mtime)) -le 5 ] && stale=0
fi

if [ "$stale" -eq 1 ]; then
  # Run git in the session's CWD, not the script process's CWD
  if git -C "${cwd:-.}" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "${cwd:-.}" branch --show-current 2> /dev/null)
    staged=$(git -C "${cwd:-.}" diff --cached --numstat 2> /dev/null | wc -l | tr -d ' ')
    modified=$(git -C "${cwd:-.}" diff --numstat 2> /dev/null | wc -l | tr -d ' ')
  else
    branch=""
    staged=0
    modified=0
  fi
  printf '%s|%s|%s' "$branch" "$staged" "$modified" > "$CACHE"
fi
IFS='|' read -r branch staged modified < "$CACHE"

# ── Row 1: [Model]  📁 dir  🌿 branch  +N  ~N  PR #N ─────────────────────────
dir="${cwd##*/}"
row1="${ORANGE}${BOLD}[${model}]${RESET}  📁 ${BLUE}${dir}${RESET}"

if [ -n "$branch" ]; then
  row1="${row1}  🌿 ${ORANGE}${branch}${RESET}"
  # staged = index changes ready to commit; modified = unstaged working-tree changes
  [ "${staged:-0}" -gt 0 ] && row1="${row1} ${GREEN}+${staged}${RESET}"
  [ "${modified:-0}" -gt 0 ] && row1="${row1} ${YELLOW}~${modified}${RESET}"
fi

# Show PR number when Claude has found an open PR for the current branch
[ -n "$pr_num" ] && row1="${row1}  ${DIM}${LIGHT_BLUE}PR #${pr_num}${RESET}"

# ── Context progress bar ──────────────────────────────────────────────────────
# Color threshold: green < 70 %, yellow 70–89 %, red ≥ 90 %
if [ "$pct_int" -ge 90 ]; then
  bar_color="$RED"
elif [ "$pct_int" -ge 70 ]; then
  bar_color="$YELLOW"
else
  bar_color="$GREEN"
fi

# Build 10-block bar using printf -v to create runs of spaces, then replace chars
filled=$((pct_int * 10 / 100))
empty=$((10 - filled))
bar=""
[ "$filled" -gt 0 ] && {
  printf -v f "%${filled}s"
  bar="${f// /█}"
}
[ "$empty" -gt 0 ] && {
  printf -v e "%${empty}s"
  bar="${bar}${e// /░}"
}

# ── Duration and cost ─────────────────────────────────────────────────────────
# total_duration_ms = wall-clock time since session start (ms)
dur_sec=$((dur_ms / 1000))
mins=$((dur_sec / 60))
secs=$((dur_sec % 60))
# 4 decimal places keeps small costs (e.g. $0.0012) readable
cost_fmt=$(LANG=C /usr/bin/printf '$%.4f' "$cost")

# ── Row 2: [bar] pct%  💰 cost  ⏱️ Xm Ys ─────────────────────────────────────
row2="${bar_color}${bar}${RESET} ${pct_int}%  💰 ${ORANGE}${cost_fmt}${RESET}  ⏱️ ${WHITE}${mins}m ${secs}s${RESET}"

# printf '%b' interprets ANSI escapes more reliably than echo -e across shells
printf '%b\n' "$row1"
printf '%b' "$row2"
