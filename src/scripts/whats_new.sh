#!/bin/bash
# Show outdated brew packages and their GitHub release notes (no installs).
# Requires: brew, jq, gh (all in Brewfile).
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/colors.sh
source "$SCRIPT_DIR/lib/colors.sh"

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

gh_repo_from_url() {
  local url="$1"
  # Regex captures owner/repo from any github.com URL or SSH remote.
  [[ "$url" =~ github\.com[:/]+([^/]+)/([^/.]+) ]] || return 0
  echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
}

show_release_notes() {
  local name="$1" current="$2" latest="$3"
  echo -e "${BOLD}${MAGENTA}── ${name} ${DIM}(${current} → ${latest})${RESET}"

  local info homepage repo tag stable_url
  # Fallback to `{}` so downstream jq calls don't fail on a bad formula name.
  info="$(brew info --json=v2 "$name" 2> /dev/null || echo '{}')"
  homepage="$(echo "$info" | jq -r '.formulas[0].homepage // .casks[0].homepage // empty')"
  repo="$(gh_repo_from_url "$homepage")"

  if [ -z "$repo" ]; then
    stable_url="$(echo "$info" | jq -r '.formulae[0].urls.stable.url // empty')"
    repo="$(gh_repo_from_url "$stable_url")"
  fi

  if [ -n "$repo" ]; then
    for tag in "v${latest}" "${latest}"; do
      if gh release view "$tag" --repo "$repo" > /dev/null 2>&1; then
        echo -e "${DIM}   github.com/${repo}  release ${tag}${RESET}"
        gh release view "$tag" --repo "$repo" |
          sed -n '/^--$/,$p' | sed '1d' | head -40 |
          sed "s/^/   /"
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

echo "$OUTDATED_JSON" | jq -r '
  .formulae[] | "\(.name)\t\(.installed_versions[0])\t\(.current_version)"
' | while IFS=$'\t' read -r name current latest; do
  show_release_notes "$name" "$current" "$latest"
done

echo "$OUTDATED_JSON" | jq -r '
  .casks[] | "\(.name[0])\t\(.installed_versions)\t\(.current_version)"
' | while IFS=$'\t' read -r name current latest; do
  show_release_notes "$name" "$current" "$latest"
done

echo -e "${BOLD}${CYAN}─────────────────────────────────────────────${RESET}"
echo -e "${YELLOW}Review above. To apply: ${BOLD}${GREEN}make update${RESET}"
