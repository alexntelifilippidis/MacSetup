#!/bin/bash
# ==============================================================================
# whats_new.sh — show outdated brew packages and their release notes
# ==============================================================================
# A Bash tutorial disguised as a useful script. Every non-trivial line is
# annotated. Read top-to-bottom.
#
# What it does:
#   1. `brew update`              → refresh formula DB (no installs).
#   2. `brew outdated --json=v2`  → structured list with current + latest.
#   3. For each formula, derive the GitHub repo from `brew info` JSON and
#      try `gh release view <tag>` for the release notes.
#   4. Fallback: print homepage / releases URL.
#
# Requires: brew, jq, gh (all in the repo's Brewfile).
# ==============================================================================

# ── Shebang ───────────────────────────────────────────────────────────────────
# `#!/bin/bash` tells the kernel which interpreter to run when this file is
# executed directly (`./whats_new.sh`). We pick bash specifically (not `sh`)
# because we use bashisms: `[[ ]]`, `BASH_REMATCH`, `local`. On macOS
# `/bin/bash` is bash 3.2 — old, but enough for what we do here.

# ── Strict mode ───────────────────────────────────────────────────────────────
# Three flags that turn Bash from "best-effort" into "fail loud":
#   -e            exit immediately if any command returns non-zero.
#   -u            treat unset variables as an error (catches typos like $FOOO).
#   -o pipefail   in `a | b | c`, exit non-zero if ANY stage fails, not just
#                 the last. Without it, `false | true` returns 0 — dangerous.
set -euo pipefail

# IFS = "Internal Field Separator". Default is space+tab+newline, which splits
# `for x in $foo` on spaces — usually wrong for filenames with spaces. Setting
# it to newline+tab makes word-splitting safer. `$'\n\t'` is ANSI-C quoting:
# it interprets escapes like \n, \t, \xNN.
IFS=$'\n\t'

# ── ANSI color codes ──────────────────────────────────────────────────────────
# `\033` (octal) = `\x1b` = ESC. Terminals interpret `ESC[...m` as a style.
# `\033[0;32m` = green, `\033[1;33m` = bold yellow, `\033[0m` = reset.
# Storing them in vars keeps the actual `echo` lines readable.
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Dependency check ──────────────────────────────────────────────────────────
# `for VAR in WORD1 WORD2 ...; do ... done` — basic loop.
# `command -v <name>` prints the path of an executable; returns 0 if found.
# `&> /dev/null` redirects BOTH stdout and stderr to /dev/null:
#   `>`     redirects stdout only.
#   `2>&1`  sends stderr to wherever stdout currently goes.
#   `&>`    bash shorthand for `> ... 2>&1`.
# `!` negates the exit status: "if command-v fails…".
for cmd in brew jq gh; do
  if ! command -v "$cmd" &> /dev/null; then
    # `>&2` redirects this echo's stdout to stderr (proper place for errors).
    echo "❌ Missing dependency: $cmd (install via Brewfile)" >&2
    # Non-zero exit code = failure. Convention: 1 = generic error.
    exit 1
  fi
done

# `echo -e` enables backslash-escape interpretation, so `\033` actually emits
# ESC instead of literal `\033`. Variable expansion `${VAR}` happens inside
# DOUBLE quotes; it would NOT happen inside single quotes.
echo -e "${CYAN}🔄 Refreshing brew formula database...${RESET}"

# `> /dev/null` discards stdout — we only want the side-effect (refreshed DB),
# not the chatty "Already up-to-date." line.
brew update > /dev/null

# ── Capture command output into variables ─────────────────────────────────────
# `$(...)` is "command substitution": run the command, capture its stdout.
# Older syntax `\`...\`` works but doesn't nest — always prefer $().
OUTDATED_JSON="$(brew outdated --json=v2)"

# Pipe `|` connects stdout of left to stdin of right.
# `jq '.formulae | length'` reads JSON, returns the array length.
COUNT="$(echo "$OUTDATED_JSON" | jq '.formulae | length')"
CASK_COUNT="$(echo "$OUTDATED_JSON" | jq '.casks | length')"

# `[ ... ]` (also called `test`) is a builtin for conditions. SPACES around
# the brackets are required — `[1 -eq 1]` is a syntax error.
#   -eq  numeric equal     (use ==/= for strings)
#   &&   short-circuit AND (right side runs only if left succeeded)
if [ "$COUNT" -eq 0 ] && [ "$CASK_COUNT" -eq 0 ]; then
  echo -e "${GREEN}✅ Everything up to date — nothing to review.${RESET}"
  exit 0
fi

echo ""
echo -e "${BOLD}${YELLOW}📦 ${COUNT} formula(s) and ${CASK_COUNT} cask(s) have updates available${RESET}"
echo ""

# ── Function definition ───────────────────────────────────────────────────────
# Bash functions: `name() { ... }`. No parameter list — args come in as
# positional vars `$1`, `$2`, ... inside the body. To "return a value" you
# echo to stdout and the caller captures with `$( ... )`. `return N` only
# sets the exit status (0–255).
gh_repo_from_url() {
  # `local` makes the variable function-scoped. Without it, all bash variables
  # are GLOBAL and you'll leak state between calls. Always `local` in funcs.
  local url="$1"

  # `[[ ... ]]` is bash's enhanced test — supports regex with `=~`, safer
  # string comparison, no word-splitting. Prefer over `[ ... ]` in bash.
  # Regex captures land in `BASH_REMATCH[1..n]` (index 0 = full match).
  # `||` short-circuit OR: if regex doesn't match, run the right side.
  # `return 0` = exit function with success but produce no output.
  [[ "$url" =~ github\.com[:/]+([^/]+)/([^/.]+) ]] || return 0

  echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
}

show_release_notes() {
  # Three positional args. Naming them locally documents intent and prevents
  # accidental shadowing of globals.
  local name="$1"
  local current="$2"
  local latest="$3"

  echo -e "${BOLD}${MAGENTA}── ${name} ${DIM}(${current} → ${latest})${RESET}"

  # Multiple `local` declarations on one line — purely a style choice.
  local info homepage repo tag

  # `2> /dev/null` discards stderr only — we still capture stdout.
  # `||` provides a fallback: if `brew info` fails, use empty JSON `{}` so
  # later `jq` calls don't blow up. Defensive scripting pattern.
  info="$(brew info --json=v2 "$name" 2> /dev/null || echo '{}')"

  # jq -r = "raw output": strips surrounding quotes from JSON strings.
  # `//` in jq is "alternative": use the right side if the left is null/empty.
  # Chained: try formula homepage, then cask homepage, then literal empty.
  homepage="$(echo "$info" | jq -r '.formulas[0].homepage // .casks[0].homepage // empty')"
  repo="$(gh_repo_from_url "$homepage")"

  # `-z` tests "string is empty". Counterpart `-n` tests "non-empty".
  if [ -z "$repo" ]; then
    local stable_url
    stable_url="$(echo "$info" | jq -r '.formulae[0].urls.stable.url // empty')"
    repo="$(gh_repo_from_url "$stable_url")"
  fi

  if [ -n "$repo" ]; then
    # Loop over candidate tag formats. Items are space-separated; double-
    # quoting each one preserves it as a single word.
    for tag in "v${latest}" "${latest}"; do
      # `> /dev/null 2>&1` — silence everything; we only care about exit code.
      # `if some-command; then ...` — the `then` block runs when CMD succeeds.
      if gh release view "$tag" --repo "$repo" > /dev/null 2>&1; then
        echo -e "${DIM}   github.com/${repo}  release ${tag}${RESET}"

        # Multi-stage pipe. Each stage runs as its own process:
        #   1. gh release view       → prints metadata + `--` + body.
        #   2. sed -n '/^--$/,$p'    → from `--` line to EOF, print.
        #   3. sed '1d'              → drop the leading `--` line.
        #   4. head -40              → cap at 40 lines (notes can be huge).
        #   5. sed "s/^/   /"        → indent each line with 3 spaces.
        # The `\` at end of a line continues the command on the next line.
        gh release view "$tag" --repo "$repo" |
          sed -n '/^--$/,$p' | sed '1d' | head -40 |
          sed "s/^/   /"
        echo ""

        # `return` exits the function only, not the whole script.
        return
      fi
    done
    echo -e "${DIM}   No GitHub release found for ${latest}. See: https://github.com/${repo}/releases${RESET}"
  else
    # `${homepage:-unknown}` = use $homepage if set & non-empty, else literal
    # "unknown". Other modifiers worth knowing:
    #   ${var:=default}  also assigns the default into var
    #   ${var:?error}    bail with error if unset
    #   ${var:+other}    use 'other' only if var IS set
    echo -e "${DIM}   Homepage: ${homepage:-unknown}${RESET}"
  fi
  echo ""
}

# ── Process formulae ──────────────────────────────────────────────────────────
# `jq` prints tab-separated columns; we read each line into three vars.
# IMPORTANT: a `while read` after a pipe runs in a SUBSHELL — variables set
# inside the loop will NOT survive after `done`. To avoid the subshell, use
# process substitution: `while ...; done < <(echo "$JSON" | jq ...)`. Here
# we don't mutate outer state, so the simple pipe is fine.
#   IFS=$'\t'   split on tabs only (values with spaces stay intact).
#   read -r     don't interpret backslashes in the input.
#   name current latest → columns 1..3 (extras concatenate into the last var).
echo "$OUTDATED_JSON" | jq -r '
  .formulae[] | "\(.name)\t\(.installed_versions[0])\t\(.current_version)"
' | while IFS=$'\t' read -r name current latest; do
  show_release_notes "$name" "$current" "$latest"
done

# ── Process casks ─────────────────────────────────────────────────────────────
# Same pattern; cask schema differs slightly (`name` is an array in the JSON,
# hence `.name[0]`).
echo "$OUTDATED_JSON" | jq -r '
  .casks[] | "\(.name[0])\t\(.installed_versions)\t\(.current_version)"
' | while IFS=$'\t' read -r name current latest; do
  show_release_notes "$name" "$current" "$latest"
done

echo -e "${BOLD}${CYAN}─────────────────────────────────────────────${RESET}"
echo -e "${YELLOW}Review above. To apply: ${BOLD}${GREEN}make update${RESET}"

# ──────────────────────────────────────────────────────────────────────────────
# 📚 Bash cheat-sheet recap
# ──────────────────────────────────────────────────────────────────────────────
# Quoting:
#   "$var"   expands variables, allows escapes — use for almost everything.
#   '$var'   literal — no expansion at all.
#   $'...'   ANSI-C — interprets \n, \t, \xNN.
#   "$(cmd)" run cmd, substitute stdout (always quote!).
#
# Tests:
#   [ -f path ]   regular file exists      [ -d path ]   directory exists
#   [ -z str ]    string empty             [ -n str ]    string non-empty
#   [ a = b ]     string equal             [ a -eq b ]   numeric equal
#   [[ a =~ rx ]] regex match (bash only)
#
# Redirection:
#   >  stdout (truncate)    >>  stdout (append)
#   2> stderr               &>  both (bash)        2>&1  stderr→stdout
#   <  stdin from file      <<<  here-string       <(cmd) process substitution
#
# Parameter expansion:
#   ${var}            value
#   ${var:-x}         value or "x" if empty       ${var:=x}  also assigns
#   ${var:+x}         "x" if set, else empty      ${var:?msg} error if unset
#   ${var#pre}        strip shortest prefix       ${var##pre} longest
#   ${var%suf}        strip shortest suffix       ${var%%suf} longest
#   ${var/old/new}    replace first               ${var//old/new} replace all
#   ${#var}           length
#
# Always:
#   set -euo pipefail at the top
#   quote "$variables"
#   use `local` inside functions
#   prefer `[[ ]]` over `[ ]` in bash, and `$()` over backticks
#   run `shellcheck script.sh` before committing — catches 90% of bugs
# ──────────────────────────────────────────────────────────────────────────────
