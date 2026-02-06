#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

echo ""
echo -e "${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${BLUE}    🚀 Welcome to ${YELLOW}Mac Setup${BLUE} Experience! 🚀${RESET}"
echo -e "${GREEN}     🔧 Setting up your environment 🔧${RESET}"
echo -e "${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""

# Install Homebrew
if ! command -v brew &> /dev/null; then
  echo -e "${YELLOW}▶▶▶ 🍺 Installing Homebrew ◀◀◀${RESET}"
  echo -e "${YELLOW}──────────────────────────────────────${RESET}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> "$HOME/.zprofile"
  echo "eval $(/opt/homebrew/bin/brew shellenv)" >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo -e "${GREEN}✅ Homebrew is already installed and ready to use! 🍺${RESET}"
fi

# Install packages from Brewfile
echo ""
echo -e "${CYAN}▶▶▶ 📦 Installing Brew packages ◀◀◀${RESET}"
echo -e "${CYAN}──────────────────────────────────────${RESET}"
brew bundle --file=./Brewfile | while IFS= read -r line; do printf "%b\n" "${line//Using /${GREEN}➜${RESET} ${MAGENTA}Using${RESET} }"; done

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo ""
  echo -e "${YELLOW}    ▶▶▶ 💻 Installing Oh My Zsh ◀◀◀${RESET}"
  echo -e "${YELLOW}    ─────────────────────────────────${RESET}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo ""
  echo -e "${GREEN}✅ Oh My Zsh is already installed and configured! 💻${RESET}"
fi

# Symlink .zshrc
echo ""
echo -e "${MAGENTA}▶▶▶ 🔗 Linking .zshrc ◀◀◀${RESET}"
echo -e "${MAGENTA}──────────────────────────────────────${RESET}"
ln -sf "$(pwd)/zsh/.zshrc" "$HOME/.zshrc"

# Configure Databricks CLI
echo ""
echo -e "${CYAN}▶▶▶ 🧪 Setting up Databricks CLI config ◀◀◀${RESET}"
echo -e "${CYAN}────────────────────────────────────────────${RESET}"
cp ./databricks/.databrickscfg "$HOME/.databrickscfg"
chmod 600 "$HOME/.databrickscfg"

# Configure GitConfig
echo ""
echo -e "${BLUE}▶▶▶ 🛠️ Setting up Git config ◀◀◀${RESET}"
echo -e "${BLUE}──────────────────────────────────────${RESET}"
cp ./git-credential-manager/.gitconfig "$HOME/.gitconfig"
cp ./git-credential-manager/.gitconfig-personal "$HOME/Projects/Personal/.gitconfig"
cp ./git-credential-manager/.gitconfig-work "$HOME/Projects/Work/.gitconfig"

# Setup Podman
echo ""
echo -e "${MAGENTA}▶▶▶ 🐋 Setting up Podman Machine ◀◀◀${RESET}"
echo -e "${MAGENTA}──────────────────────────────────────${RESET}"
bash ./podman/setup_podman.sh

echo ""
echo -e "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo -e "${GREEN}             🎉 Setup Complete! 🎉${RESET}"
echo -e "${YELLOW}     Please restart your terminal to see changes${RESET}"
echo -e "${GREEN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
echo ""