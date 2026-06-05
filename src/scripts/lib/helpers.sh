#!/bin/bash
# Shared helper functions — source after colors.sh.
# shellcheck source=./colors.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/colors.sh"

section() {
  local icon="$1" title="$2" color="$3"
  echo ""
  echo -e "${color}▶▶▶ ${icon} ${title} ◀◀◀${RESET}"
  echo -e "${color}${SEP}${RESET}"
}

# Copy src → dst only when content differs (or dst is missing).
# Optional third arg: chmod permissions to apply to dst.
copy_if_changed() {
  local src="$1" dst="$2" perms="${3:-}"
  # Strip REPO_ROOT prefix for repo-side paths; replace HOME with ~ for dst.
  local src_label="${src#"${REPO_ROOT:-}/"}"
  src_label="${src_label#./}"
  local dst_label="${dst/#$HOME/~}"

  if [ ! -f "$dst" ] || ! diff -q "$src" "$dst" &> /dev/null; then
    cp -f "$src" "$dst"
    [ -n "$perms" ] && chmod "$perms" "$dst"
    echo -e "  ${GREEN}✅ Updated:    ${MAGENTA}${src_label}${GREEN} → ${dst_label}${RESET}"
  else
    echo -e "  ${CYAN}⏭️  No changes: ${MAGENTA}${src_label}${CYAN} → ${dst_label}${RESET}"
  fi
}

# Create / update a symlink only when it doesn't already point at the target.
symlink_if_changed() {
  local target="$1" link="$2"
  # Strip REPO_ROOT prefix for repo-side paths; replace HOME with ~ for $HOME paths.
  local target_label="${target/#$HOME/~}"
  target_label="${target_label#"${REPO_ROOT:-}/"}"
  local link_label="${link/#$HOME/~}"
  link_label="${link_label#"${REPO_ROOT:-}/"}"

  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    echo -e "  ${CYAN}⏭️  No changes: ${MAGENTA}${link_label}${CYAN} already linked → ${target_label}${RESET}"
  else
    ln -sf "$target" "$link"
    echo -e "  ${GREEN}✅ Linked:     ${MAGENTA}${link_label}${GREEN} → ${target_label}${RESET}"
  fi
}
