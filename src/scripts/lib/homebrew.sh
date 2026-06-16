#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

setup_homebrew() {
  section "🍺" "Homebrew" "$YELLOW"
  if ! command -v brew &> /dev/null; then
    echo -e "  ${YELLOW}⬇️  Homebrew not found — installing now...${RESET}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Guard with grep to stay idempotent — re-running must not append duplicate blocks.
    # Single-quoted so `eval` expands at shell-startup time, not at write time.
    if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2> /dev/null; then
      {
        echo ''
        # shellcheck disable=SC2016
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
      } >> "$HOME/.zprofile"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo -e "  ${GREEN}✅ Homebrew installed and added to PATH${RESET}"
  else
    echo -e "  ${CYAN}⏭️  No changes: Homebrew already installed ($(brew --version | head -1))${RESET}"
  fi

  # Symlink into ~/.config/homebrew/ so bare `brew bundle` (no --file) picks it up
  # anywhere, matching the HOMEBREW_BUNDLE_FILE export in .zshrc.
  section "📦" "Brewfile" "$CYAN"
  mkdir -p "$HOME/.config/homebrew"
  symlink_if_changed "$REPO_ROOT/src/dotfiles/homebrew/Brewfile" "$HOME/.config/homebrew/Brewfile"

  # Atlassian tap requires explicit trust before brew bundle will install it
  brew trust atlassian/acli &> /dev/null || true

  if brew bundle check --file="$REPO_ROOT/src/dotfiles/homebrew/Brewfile" &> /dev/null; then
    echo -e "  ${CYAN}⏭️  No changes: All packages from Brewfile already installed${RESET}"
  else
    echo -e "  ${YELLOW}⬇️  Installing missing packages...${RESET}"
    brew bundle --file="$REPO_ROOT/src/dotfiles/homebrew/Brewfile" | while IFS= read -r line; do
      printf "%b\n" "  ${line//Using /${GREEN}➜${RESET} ${MAGENTA}Using${RESET} }"
    done
    echo -e "  ${GREEN}✅ Brew packages up to date${RESET}"
  fi
}
