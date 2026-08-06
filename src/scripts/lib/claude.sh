#!/bin/bash
# lib/claude.sh — deploy this repo's Claude Code host config.
#
# Scope is deliberately narrow: three symlinks, nothing else.
#
# This module does NOT touch $HOME/.claude/settings.json. Claude Code writes to
# that file itself (model, /config, plugin state) and so do external installers
# (aicodemetricsd, claude-island). Merging or replacing it from a setup script is
# a good way to break a working Claude install for no benefit — marketplace
# registration is done by the `claude` CLI instead, via `make claude-plugins`,
# which owns that file and knows its schema.
#
# The batcave marketplace under plugins/ is registered once with
# `make claude-plugins`; after that a `git pull` updates the live assets with no
# re-deploy, because the marketplace source is a `directory` pointing at this
# working copy.
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

# Host-level files, deployed as symlinks so a git pull is enough to update them.
_claude_link_host_files() {
  local src_dir="$1" dst_dir="$2"

  # CLAUDE.md lands at $HOME/CLAUDE.md — Claude Code's global instruction root,
  # NOT inside $HOME/.claude/.
  symlink_if_changed "$src_dir/CLAUDE.md" "$HOME/CLAUDE.md"

  # settings.json references this at a stable path, so repointing the symlink
  # migrates the source with no settings edit.
  symlink_if_changed "$src_dir/statusline-command.sh" "$dst_dir/statusline-command.sh"

  # Machine-specific overrides — gitignored, so absent on a fresh clone.
  if [ -f "$src_dir/settings.local.json" ]; then
    symlink_if_changed "$src_dir/settings.local.json" "$dst_dir/settings.local.json"
  else
    echo -e "  ${CYAN}⏭️  Skipped:    settings.local.json not in repo (gitignored)${RESET}"
  fi
}

# Report what the batcave marketplace ships and whether it is registered yet.
# Purely informational — this module never registers it, `make claude-plugins` does.
_claude_report_plugin() {
  local plugin_dir="$REPO_ROOT/plugins/batman"
  local kind count

  [ -d "$plugin_dir" ] || {
    echo -e "  ${YELLOW}⚠️  Missing:    plugins/batman not found in repo${RESET}"
    return 0
  }

  # -not -name .gitkeep: the placeholder that keeps an empty dir in git is not an
  # asset, and counting it reports "1 skills" for a plugin that ships none.
  for kind in skills agents; do
    if [ -d "$plugin_dir/$kind" ]; then
      count=$(find "$plugin_dir/$kind" -mindepth 1 -maxdepth 1 -not -name '.gitkeep' | wc -l | tr -d ' ')
      echo -e "  ${GREEN}📦 batman:     ${MAGENTA}${count}${GREEN} ${kind}${RESET}"
    fi
  done

  if ! command -v claude > /dev/null 2>&1; then
    echo -e "  ${YELLOW}⚠️  claude CLI not on PATH — install the Claude Code cask${RESET}"
    return 0
  fi

  if claude plugin list 2> /dev/null | grep -q 'batman@batcave'; then
    echo -e "  ${CYAN}⏭️  No changes: batman@batcave already installed${RESET}"
  else
    echo -e "  ${YELLOW}⚠️  Not registered yet — run: ${MAGENTA}make claude-plugins${RESET}"
  fi
}

setup_claude() {
  section "🦇" "Claude Code Config" "$MAGENTA"

  local src_dir="$REPO_ROOT/src/dotfiles/claude"
  local dst_dir="$HOME/.claude"

  mkdir -p "$dst_dir"
  _claude_link_host_files "$src_dir" "$dst_dir"

  section "🃏" "batcave Marketplace" "$MAGENTA"
  _claude_report_plugin
}
