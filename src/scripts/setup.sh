#!/bin/bash
# Mac development environment setup — orchestrator.
# Run from any directory; uses REPO_ROOT derived from this file's location.
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
export REPO_ROOT

# shellcheck source=./lib/homebrew.sh
source "$SCRIPT_DIR/lib/homebrew.sh"
# shellcheck source=./lib/zsh.sh
source "$SCRIPT_DIR/lib/zsh.sh"
# shellcheck source=./lib/iterm.sh
source "$SCRIPT_DIR/lib/iterm.sh"
# shellcheck source=./lib/databricks.sh
source "$SCRIPT_DIR/lib/databricks.sh"
# shellcheck source=./lib/git.sh
source "$SCRIPT_DIR/lib/git.sh"
# shellcheck source=./lib/claude.sh
source "$SCRIPT_DIR/lib/claude.sh"
# shellcheck source=./lib/podman.sh
source "$SCRIPT_DIR/lib/podman.sh"

echo ""
echo -e "${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${BLUE}    🚀 Welcome to ${YELLOW}Mac Setup${BLUE} Experience! 🚀${RESET}"
echo -e "${GREEN}     🔧 Setting up your development environment 🔧${RESET}"
echo -e "${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""

setup_homebrew
setup_zsh
setup_iterm
setup_databricks
setup_git
setup_podman
setup_claude

echo ""
echo -e "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${GREEN}                  🎉 Setup Complete! 🎉${RESET}"
echo -e "${YELLOW}       Restart your terminal to apply all changes${RESET}"
echo -e "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""
