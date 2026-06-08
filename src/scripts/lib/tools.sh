#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

setup_copilot() {
  section "🤖" "GitHub Copilot Instructions" "$BLUE"
  mkdir -p "$HOME/.config/github-copilot/intellij"
  copy_if_changed "$REPO_ROOT/src/dotfiles/github-copilot/intellij/global-copilot-instructions.md" "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"
  copy_if_changed "$REPO_ROOT/src/dotfiles/github-copilot/intellij/global-agents-instructions.md" "$HOME/.config/github-copilot/intellij/global-agents-instructions.md"
  copy_if_changed "$REPO_ROOT/src/dotfiles/github-copilot/intellij/global-git-commit-instructions.md" "$HOME/.config/github-copilot/intellij/global-git-commit-instructions.md"

  # Copilot CLI (and any AGENTS.md-compatible tool) walks upward from CWD looking for
  # copilot-instructions.md. $HOME placement makes rules apply to every repo automatically.
  section "📜" "Copilot CLI Global copilot-instructions.md" "$CYAN"
  symlink_if_changed "$REPO_ROOT/src/dotfiles/github-copilot/intellij/global-agents-instructions.md" "$HOME/copilot-instructions.md"
}

setup_claude() {
  section "🤖" "Claude Code Config" "$MAGENTA"
  local src_dir="$REPO_ROOT/src/dotfiles/claude"
  local dst_dir="$HOME/.claude"

  # CLAUDE.md → ~/CLAUDE.md (global instructions root, not inside ~/.claude/)
  symlink_if_changed "$src_dir/CLAUDE.md" "$HOME/CLAUDE.md"

  # Symlink all other files preserving subdirectory structure
  while IFS= read -r -d '' src_file; do
    rel="${src_file#"$src_dir/"}"
    [[ "$rel" == "CLAUDE.md" ]] && continue
    dst="$dst_dir/$rel"
    mkdir -p "$(dirname "$dst")"
    symlink_if_changed "$src_file" "$dst"
  done < <(find "$src_dir" -type f -print0 | sort -z)
}
