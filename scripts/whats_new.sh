#!/bin/bash
# whats_new.sh — show outdated brew packages and their release notes BEFORE upgrade.
#
# Why: `brew upgrade` is a black box. This surfaces what changed so you can
# decide if a major-version bump is safe before applying it.
#
# How:
#   1. `brew update`              → refresh formula DB (no installs).
#   2. `brew outdated --json=v2`  → structured list with current + latest.
#   3. For each formula, derive the GitHub repo from `homepage` / `head` /
#      `stable.url` and try `gh release view <tag>` for proper release notes.
#   4. Fallback: print homepage + changelog URL guess.
#
# Requires: brew, jq, gh (all in Brewfile).
set -euo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

for cmd in brew jq gh; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ Missing dependency: $cmd (install via Brewfile)" >&2
    exit 1
  fi
done

echo -e "${CYAN}🔄 Refreshing brew formula database...${RESET}"
brew update > /dev/null

OUTDATED_JSON="$(brew outdated --json=v2)"
COUNT="$(echo "$OUTDATED_JSON" | jq '.formulae | length')"
CASK_COUNT="$(echo "$OUTDATED_JSON" | jq '.casks | length')"

if [ "$COUNT" -eq 0 ] && [ "$CASK_COUNT" -eq 0 ]; then
  echo -e "${GREEN}✅ Everything up to date — nothing to review.${RESET}"
  exit 0
fi

echo ""
echo -e "${BOLD}${YELLOW}📦 ${COUNT} formula(s) and ${CASK_COUNT} cask(s) have updates available${RESET}"
echo ""

# Extract owner/repo from a GitHub URL. Returns empty if not GitHub.
gh_repo_from_url() {
  local url="$1"
  [[ "$url" =~ github\.com[:/]+([^/]+)/([^/.]+) ]] || return 0
  echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
}

show_release_notes() {
  local name="$1"
  local current="$2"
  local latest="$3"

  echo -e "${BOLD}${MAGENTA}── ${name} ${DIM}(${current} → ${latest})${RESET}"

  local info homepage repo tag
  info="$(brew info --json=v2 "$name" 2> /dev/null || echo '{}')"
  homepage="$(echo "$info" | jq -r '.formulae[0].homepage // .casks[0].homepage // empty')"
  repo="$(gh_repo_from_url "$homepage")"

  if [ -z "$repo" ]; then
    # Try stable URL as a fallback (often points to github.com/.../archive/...).
    local stable_url
    stable_url="$(echo "$info" | jq -r '.formulae[0].urls.stable.url // empty')"
    repo="$(gh_repo_from_url "$stable_url")"
  fi

  if [ -n "$repo" ]; then
    # Try common tag formats: v1.2.3, 1.2.3.
    for tag in "v${latest}" "${latest}"; do
      if gh release view "$tag" --repo "$repo" > /dev/null 2>&1; then
        echo -e "${DIM}   github.com/${repo}  release ${tag}${RESET}"
        gh release view "$tag" --repo "$repo" \
          | sed -n '/^--$/,$p' | sed '1d' | head -40 \
          | sed "s/^/   /"
        echo ""
        return
      fi
    done
    echo -e "${DIM}   No GitHub release found for ${latest}. See: https://github.com/${repo}/releases${RESET}"
  else
    echo -e "${DIM}   Homepage: ${homepage:-unknown}${RESET}"
  fi
  echo ""
}

# Formulae
echo "$OUTDATED_JSON" | jq -r '
  .formulae[] | "\(.name)\t\(.installed_versions[0])\t\(.current_version)"
' | while IFS=$'\t' read -r name current latest; do
  show_release_notes "$name" "$current" "$latest"
done

# Casks
echo "$OUTDATED_JSON" | jq -r '
  .casks[] | "\(.name[0])\t\(.installed_versions)\t\(.current_version)"
' | while IFS=$'\t' read -r name current latest; do
  show_release_notes "$name" "$current" "$latest"
done

echo -e "${BOLD}${CYAN}─────────────────────────────────────────────${RESET}"
echo -e "${YELLOW}Review above. To apply: ${BOLD}make update${RESET}"

