#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

setup_zsh() {
  section "💻" "Oh My Zsh" "$YELLOW"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "  ${YELLOW}⬇️  Oh My Zsh not found — installing now...${RESET}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo -e "  ${GREEN}✅ Oh My Zsh installed${RESET}"
  else
    echo -e "  ${CYAN}⏭️  No changes: Oh My Zsh already installed at ~/.oh-my-zsh${RESET}"
  fi

  section "🎨" "Zsh Themes" "$CYAN"
  mkdir -p "$HOME/.oh-my-zsh/custom/themes"
  symlink_if_changed "$REPO_ROOT/src/dotfiles/zsh/themes/kaizen.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/kaizen.zsh-theme"

  section "🔗" "Zsh Config (.zshrc symlink)" "$MAGENTA"
  symlink_if_changed "$REPO_ROOT/src/dotfiles/zsh/.zshrc" "$HOME/.zshrc"

  # Real tokens live in src/dotfiles/zsh/.secrets.zsh (gitignored, chmod 600).
  # On a fresh machine, seed from the committed template; never overwrite an existing file.
  section "🔐" "Secrets (~/.secrets.zsh)" "$YELLOW"
  if [ ! -f "$REPO_ROOT/src/dotfiles/zsh/.secrets.zsh" ]; then
    cp "$REPO_ROOT/src/dotfiles/zsh/.secrets.zsh.template" "$REPO_ROOT/src/dotfiles/zsh/.secrets.zsh"
    chmod 600 "$REPO_ROOT/src/dotfiles/zsh/.secrets.zsh"
    echo -e "  ${GREEN}✅ Seeded:     ${MAGENTA}src/dotfiles/zsh/.secrets.zsh${GREEN} (from template, chmod 600)${RESET}"
    echo -e "  ${YELLOW}⚠️  Edit src/dotfiles/zsh/.secrets.zsh and replace REPLACE_ME values with real tokens${RESET}"
  else
    chmod 600 "$REPO_ROOT/src/dotfiles/zsh/.secrets.zsh"
    echo -e "  ${CYAN}⏭️  No changes: ${MAGENTA}src/dotfiles/zsh/.secrets.zsh${CYAN} already exists (perms enforced 600)${RESET}"
  fi
  symlink_if_changed "$REPO_ROOT/src/dotfiles/zsh/.secrets.zsh" "$HOME/.secrets.zsh"
}
