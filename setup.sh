#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RED='\033[0;31m'
RESET='\033[0m'

SEP="──────────────────────────────────────────────"

# ─── Helpers ──────────────────────────────────────────────────────────────────

section() {
  local icon="$1"
  local title="$2"
  local color="$3"
  echo ""
  echo -e "${color}▶▶▶ ${icon} ${title} ◀◀◀${RESET}"
  echo -e "${color}${SEP}${RESET}"
}

# Copy src → dst only when content differs (or dst is missing).
# Applies chmod if a third argument is provided.
copy_if_changed() {
  local src="$1"
  local dst="$2"
  local perms="${3:-}"

  local src_label="${src#./}"
  local dst_label="${dst/#$HOME/\~}"

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
  local target="$1"
  local link="$2"

  local target_label="${target/#$HOME/\~}"
  local link_label="${link/#$HOME/\~}"

  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    echo -e "  ${CYAN}⏭️  No changes: ${MAGENTA}${link_label}${CYAN} already linked → ${target_label}${RESET}"
  else
    ln -sf "$target" "$link"
    echo -e "  ${GREEN}✅ Linked:     ${MAGENTA}${link_label}${GREEN} → ${target_label}${RESET}"
  fi
}

# ──────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${BLUE}    🚀 Welcome to ${YELLOW}Mac Setup${BLUE} Experience! 🚀${RESET}"
echo -e "${GREEN}     🔧 Setting up your development environment 🔧${RESET}"
echo -e "${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""

# ── Homebrew ──────────────────────────────────────────────────────────────────
section "🍺" "Homebrew" "$YELLOW"
if ! command -v brew &> /dev/null; then
  echo -e "  ${YELLOW}⬇️  Homebrew not found — installing now...${RESET}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> "$HOME/.zprofile"
  echo "eval $(/opt/homebrew/bin/brew shellenv)" >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo -e "  ${GREEN}✅ Homebrew installed and added to PATH${RESET}"
else
  echo -e "  ${CYAN}⏭️  No changes: Homebrew already installed ($(brew --version | head -1))${RESET}"
fi

# ── Brew Packages ─────────────────────────────────────────────────────────────
section "📦" "Brew Packages (Brewfile)" "$CYAN"
if brew bundle check --file=./Brewfile &> /dev/null; then
  echo -e "  ${CYAN}⏭️  No changes: All packages from Brewfile already installed${RESET}"
else
  echo -e "  ${YELLOW}⬇️  Installing missing packages...${RESET}"
  brew bundle --file=./Brewfile | while IFS= read -r line; do
    printf "%b\n" "  ${line//Using /${GREEN}➜${RESET} ${MAGENTA}Using${RESET} }"
  done
  echo -e "  ${GREEN}✅ Brew packages up to date${RESET}"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
section "💻" "Oh My Zsh" "$YELLOW"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "  ${YELLOW}⬇️  Oh My Zsh not found — installing now...${RESET}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo -e "  ${GREEN}✅ Oh My Zsh installed${RESET}"
else
  echo -e "  ${CYAN}⏭️  No changes: Oh My Zsh already installed at ~/.oh-my-zsh${RESET}"
fi

# ── Zsh Config ────────────────────────────────────────────────────────────────
section "🔗" "Zsh Config (.zshrc symlink)" "$MAGENTA"
symlink_if_changed "$(pwd)/zsh/.zshrc" "$HOME/.zshrc"

# ── Databricks CLI ────────────────────────────────────────────────────────────
section "🧪" "Databricks CLI Config" "$CYAN"
copy_if_changed ./databricks/.databrickscfg "$HOME/.databrickscfg" 600

# ── Git Config ────────────────────────────────────────────────────────────────
section "🛠️" "Git Config" "$BLUE"
copy_if_changed ./git-credential-manager/.gitconfig          "$HOME/.gitconfig"
copy_if_changed ./git-credential-manager/.gitconfig-personal "$HOME/Projects/Personal/.gitconfig"
copy_if_changed ./git-credential-manager/.gitconfig-work     "$HOME/Projects/Work/.gitconfig"

# ── Podman ────────────────────────────────────────────────────────────────────
section "🐋" "Podman Machine" "$MAGENTA"
bash ./podman/setup_podman.sh

# ── GitHub Copilot ────────────────────────────────────────────────────────────
section "🤖" "GitHub Copilot Instructions" "$BLUE"
mkdir -p "$HOME/.config/github-copilot/intellij"
copy_if_changed ./github-copilot/intellij/global-copilot-instructions.md  "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"
copy_if_changed ./github-copilot/intellij/global-agents-instructions.md   "$HOME/.config/github-copilot/intellij/global-agents-instructions.md"
copy_if_changed ./github-copilot/intellij/global-git-commit-instructions.md "$HOME/.config/github-copilot/intellij/global-git-commit-instructions.md"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${GREEN}                  🎉 Setup Complete! 🎉${RESET}"
echo -e "${YELLOW}       Restart your terminal to apply all changes${RESET}"
echo -e "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""

