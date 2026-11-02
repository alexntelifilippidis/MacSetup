#!/usr/bin/env bash
# check-dependency.sh — search the de-platform-new-tenant repo (Team Bristol's
# Databricks platform code) for references to one or more table names, and report
# which jobs/pipelines/files depend on them.
#
# Team Bristol owns this repo (databricks_asset_bundles_variables.yml sets
# team_name: "Bristol", databricks.yml bundle name: bristol_dabs) — any hit here
# means changing that table can break a Bristol job.
#
# Usage:
#   check-dependency.sh <table_name_or_fqn> [more_tables...]
#   BRISTOL_REPO_PATH=/path/to/de-platform-new-tenant check-dependency.sh <table>
#
# A table arg can be a bare name (currency_history), schema.table
# (silver.currency_history), or a full FQN (catalog.schema.currency_history).
set -euo pipefail

REPO_NAME="de-platform-new-tenant"
REPO_URL="https://gitlab.com/kaizengaming/projects/dna/data-platform/de-platform-new-tenant"

if [ -t 1 ]; then
  BOLD=$'\033[1m' DIM=$'\033[2m' RED=$'\033[31m' GREEN=$'\033[32m'
  YELLOW=$'\033[33m' CYAN=$'\033[36m' MAGENTA=$'\033[35m' RESET=$'\033[0m'
else
  BOLD="" DIM="" RED="" GREEN="" YELLOW="" CYAN="" MAGENTA="" RESET=""
fi

usage() {
  echo "Usage: $(basename "$0") <table_name_or_fqn> [more_tables...]" >&2
  exit 1
}
[ "$#" -ge 1 ] || usage

# Directories that hold Bristol's actual pipeline/job code — search scope.
# disaster_recovery_dab is excluded: it's a DR-tagging inventory (dr_critical_assets.py
# lists table names for backup/DR purposes), not evidence a job actually consumes them —
# including it produced false "dependency found" noise.
SEARCH_DIRS=(bronze silver dataPlatform streams uow databricks misc
  staging_only_dab config utils)
# Job/pipeline definition files — used to map a hit file back to a job name.
JOB_DEF_GLOBS=(databricks/jobs databricks/pipelines staging_only_dab/resources)
EXCLUDE_DIRS=(.git .venv .databricks __pycache__ .pytest_cache .ruff_cache .idea artifacts dr_tagging)

# ---------------------------------------------------------------------------
# 1. Locate the repo locally (never clones — this script is read-only).
# ---------------------------------------------------------------------------
find_repo() {
  if [ -n "${BRISTOL_REPO_PATH:-}" ]; then
    [ -d "${BRISTOL_REPO_PATH}/.git" ] && {
      echo "$BRISTOL_REPO_PATH"
      return 0
    }
    return 1
  fi
  local candidates=(
    "$HOME/Projects/Work/$REPO_NAME"
    "$HOME/Projects/Personal/$REPO_NAME"
    "$HOME/Projects/$REPO_NAME"
    "$HOME/repos/$REPO_NAME"
    "$HOME/git/$REPO_NAME"
    "$HOME/gitlab/$REPO_NAME"
    "$HOME/workspace/$REPO_NAME"
    "$HOME/dev/$REPO_NAME"
  )
  local c
  for c in "${candidates[@]}"; do
    [ -d "$c/.git" ] && {
      echo "$c"
      return 0
    }
  done
  local found
  found=$(find "$HOME/Projects" "$HOME/repos" "$HOME/git" "$HOME/gitlab" \
    "$HOME/workspace" "$HOME/dev" -maxdepth 5 -type d -iname "$REPO_NAME" \
    2> /dev/null | head -1)
  [ -n "$found" ] && {
    echo "$found"
    return 0
  }
  return 1
}

if ! REPO_PATH="$(find_repo)"; then
  echo -e "${RED}✗ ${REPO_NAME} not found locally.${RESET}"
  echo "  Clone it, then re-run:"
  echo "    git clone <url> \"\$HOME/Projects/Work/${REPO_NAME}\""
  echo "    (${REPO_URL})"
  echo "  Or point at an existing checkout:"
  echo "    BRISTOL_REPO_PATH=/path/to/repo $(basename "$0") <table>"
  exit 2
fi

# ---------------------------------------------------------------------------
# 2. Grep helper — ripgrep if present, plain grep fallback.
# ---------------------------------------------------------------------------
grep_repo() {
  local pattern="$1"
  local exclude_args=()
  local d
  if command -v rg &> /dev/null; then
    for d in "${EXCLUDE_DIRS[@]}"; do exclude_args+=(-g "!$d"); done
    (cd "$REPO_PATH" && rg -n -i -w --fixed-strings "$pattern" "${exclude_args[@]}" \
      "${SEARCH_DIRS[@]}" 2> /dev/null) || true
  else
    for d in "${EXCLUDE_DIRS[@]}"; do exclude_args+=(--exclude-dir="$d"); done
    (cd "$REPO_PATH" && grep -rn -i -w -F "${exclude_args[@]}" "$pattern" \
      "${SEARCH_DIRS[@]}" 2> /dev/null) || true
  fi
}

grep_filenames() {
  local pattern="$1"
  local prune_expr=() d first=1
  for d in "${EXCLUDE_DIRS[@]}"; do
    [ "$first" -eq 1 ] || prune_expr+=(-o)
    prune_expr+=(-path "*/$d/*")
    first=0
  done
  (cd "$REPO_PATH" && find "${SEARCH_DIRS[@]}" \( "${prune_expr[@]}" \) -prune -o \
    -type f -iname "*${pattern}*" -print 2> /dev/null) || true
}

# Nearest enclosing job/task name for a line hit inside a job-definition yml.
# Heuristic: last 4-space-indented "key:" line above = job name; last
# "task_key:" line above = task name. Matches this repo's DAB yaml convention.
job_context_for_hit() {
  local file="$1" line="$2"
  awk -v target="$line" '
    NR > target { exit }
    /^    [A-Za-z0-9_.-]+:[[:space:]]*$/ { job = $0; sub(/^    /, "", job); sub(/:.*/, "", job) }
    /task_key:/ { task = $0; sub(/.*task_key:[[:space:]]*/, "", task) }
    END { printf "%s\t%s", job, task }
  ' "$REPO_PATH/$file"
}

# For a hit inside notebook/script code, find job ymls whose notebook_path
# references that file — best-effort ownership mapping.
owning_jobs_for_file() {
  local hit_file="$1" base
  base="$(basename "$hit_file")"
  local def_dir
  for def_dir in "${JOB_DEF_GLOBS[@]}"; do
    [ -d "$REPO_PATH/$def_dir" ] || continue
    { grep -rl -F "$base" "$REPO_PATH/$def_dir" 2> /dev/null || true; } | while read -r def_file; do
      local rel="${def_file#"$REPO_PATH"/}"
      local ln
      ln=$(grep -n -F "$base" "$def_file" 2> /dev/null | head -1 | cut -d: -f1 || true)
      [ -n "$ln" ] || continue
      local ctx
      ctx=$(job_context_for_hit "$rel" "$ln")
      local job="${ctx%%$'\t'*}" task="${ctx##*$'\t'}"
      echo "${job:-$(basename "$def_file" .yml)}${task:+ (task: $task)} [$rel]"
    done
  done
  return 0
}

# ---------------------------------------------------------------------------
# 3. Run the check for each requested table.
# ---------------------------------------------------------------------------
echo -e "${BOLD}${CYAN}🦇 Bristol Dependency Check${RESET}"
echo -e "${DIM}Repo: ${REPO_NAME} (${REPO_PATH})${RESET}"
echo -e "${DIM}Owner: Team Bristol — bundle 'bristol_dabs'${RESET}"

for table in "$@"; do
  bare="${table##*.}"
  echo ""
  echo -e "${BOLD}── ${table} ──${RESET}"

  strong_hits="$(grep_repo "$table")"
  if [ "$bare" != "$table" ]; then
    strong_hits="${strong_hits}
$(grep_repo "$bare")"
  fi
  strong_hits="$(echo "$strong_hits" | sed '/^$/d' | sort -u)"

  loose_hits=""
  if [ ${#bare} -ge 5 ]; then
    loose_hits="$(grep_filenames "$bare" | sed '/^$/d' | sort -u)"
  fi

  if [ -z "$strong_hits" ] && [ -z "$loose_hits" ]; then
    echo -e "  ${GREEN}✅ No dependency found${RESET} — no reference to '${table}' in Bristol's repo."
    continue
  fi

  if [ -n "$strong_hits" ]; then
    n=$(echo "$strong_hits" | grep -c .)
    echo -e "  ${YELLOW}⚠️  DEPENDENCY FOUND${RESET} — ${n} content reference(s):"
    echo "$strong_hits" | while IFS=: read -r file line rest; do
      echo -e "    ${MAGENTA}${file}:${line}${RESET}  ${DIM}${rest# }${RESET}"
      owners="$(owning_jobs_for_file "$file")"
      if [ -n "$owners" ]; then
        echo "$owners" | sed '/^$/d' | sort -u | while read -r o; do
          echo -e "      ${CYAN}↳ job:${RESET} $o"
        done
      elif [[ "$file" == databricks/jobs/* || "$file" == databricks/pipelines/* ]]; then
        echo -e "      ${CYAN}↳ job:${RESET} $(basename "$file" .yml) [$file]"
      fi
    done
  fi

  if [ -n "$loose_hits" ]; then
    echo -e "  ${DIM}Loose filename matches (verify manually):${RESET}"
    echo "$loose_hits" | while read -r f; do
      echo -e "    ${DIM}${f}${RESET}"
    done
  fi
done

echo ""
echo -e "${BOLD}Recommendation:${RESET} for every ⚠️ table above, notify Team Bristol before merging."
