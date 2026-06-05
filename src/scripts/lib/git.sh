#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

setup_git() {
  section "🛠️" "Git Config" "$BLUE"
  # Ensure target directories exist on a fresh machine before copying into them.
  mkdir -p "$HOME/Projects/Personal" "$HOME/Projects/Work"
  copy_if_changed "$REPO_ROOT/src/dotfiles/git/.gitconfig" "$HOME/.gitconfig"
  copy_if_changed "$REPO_ROOT/src/dotfiles/git/.gitconfig-personal" "$HOME/Projects/Personal/.gitconfig"
  copy_if_changed "$REPO_ROOT/src/dotfiles/git/.gitconfig-work" "$HOME/Projects/Work/.gitconfig"
}
