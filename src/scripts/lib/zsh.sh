#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

# Ask which prompt theme to run, then write the answer where both .zshrc and
# the Claude Code statusline read it — so the two stay in lockstep.
# Real selection lives in src/dotfiles/zsh/.theme (gitignored, one word);
# only the .theme.template default ("batman") is committed.
_setup_theme_selection() {
  local theme_file="$REPO_ROOT/src/dotfiles/zsh/.theme"
  local template_file="$REPO_ROOT/src/dotfiles/zsh/.theme.template"
  local valid=(batman kaizen amuse)
  local current="batman"

  [ -f "$template_file" ] && current="$(cat "$template_file")"
  [ -f "$theme_file" ] && current="$(cat "$theme_file")"

  local choice="$current"
  if [ -t 0 ]; then
    # Subshell-scoped IFS so the join can't leak into the rest of the function —
    # `${valid[*]}` joins on the *first char of $IFS*, and setup.sh sets
    # IFS=$'\n\t', so an unscoped join here would print themes one-per-line.
    echo -e "  ${CYAN}Available themes: $(
      IFS=', '
      echo "${valid[*]}"
    )${RESET}"
    read -r -p "$(echo -e "  ${YELLOW}Which theme? [${current}]: ${RESET}")" choice
    choice="${choice:-$current}"
  else
    echo -e "  ${CYAN}⏭️  Non-interactive shell — keeping theme: ${MAGENTA}${current}${RESET}"
  fi

  # Explicit loop, not a `${valid[*]}` pattern-match — same IFS trap as above,
  # and this reads clearer as an actual membership test.
  local is_valid=false theme
  for theme in "${valid[@]}"; do
    [ "$theme" = "$choice" ] && {
      is_valid=true
      break
    }
  done
  if ! $is_valid; then
    echo -e "  ${YELLOW}⚠️  Unknown theme '${choice}', falling back to '${current}'${RESET}"
    choice="$current"
  fi

  if [ ! -f "$theme_file" ] || [ "$(cat "$theme_file")" != "$choice" ]; then
    echo "$choice" > "$theme_file"
    echo -e "  ${GREEN}✅ Theme set:  ${MAGENTA}${choice}${RESET}"
  else
    echo -e "  ${CYAN}⏭️  No changes: theme already '${choice}'${RESET}"
  fi

  mkdir -p "$HOME/.config"
  symlink_if_changed "$theme_file" "$HOME/.config/theme"
}

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
  symlink_if_changed "$REPO_ROOT/src/dotfiles/zsh/themes/batman.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/batman.zsh-theme"
  _setup_theme_selection

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
