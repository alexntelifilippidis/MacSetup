#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

echo -e "${BLUE}🔧 Setting up your Mac 💻 environment...${RESET}"

# Install Homebrew
if ! command -v brew &> /dev/null; then
  echo -e "${YELLOW}🍺 Installing Homebrew...${RESET}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> "$HOME/.zprofile"
  echo "eval $(/opt/homebrew/bin/brew shellenv)" >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo -e "${GREEN}🍺 Homebrew already exists ✅.${RESET}"
fi

# Install packages from Brewfile
echo -e "${CYAN}📦 Installing 🍺 Brew packages...${RESET}"
brew bundle --file=./Brewfile | while IFS= read -r line; do printf "%b\n" "${line//Using /${GREEN}➜${RESET} ${MAGENTA}Using${RESET} }"; done

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${YELLOW}💻 Installing Oh My Zsh...${RESET}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo -e "${GREEN}💻 Oh My Zsh already exists ✅.${RESET}"
fi

# Symlink .zshrc
echo -e "${MAGENTA}🔗 Linking .zshrc...${RESET}"
ln -sf "$(pwd)/zsh/.zshrc" "$HOME/.zshrc"

# Configure Databricks CLI
echo -e "${CYAN}🧪 Setting up Databricks CLI config...${RESET}"
cp ./databricks/.databrickscfg "$HOME/.databrickscfg"
chmod 600 "$HOME/.databrickscfg"

# Configure GitConfig
echo -e "${BLUE}🛠️ Setting up Git config...${RESET}"
cp ./git-credential-manager/.gitconfig "$HOME/.gitconfig"
cp ./git-credential-manager/.gitconfig-personal "$HOME/Projects/Personal/.gitconfig"
cp ./git-credential-manager/.gitconfig-work "$HOME/Projects/Work/.gitconfig"

echo -e "${GREEN}✅ Done! Restart your terminal to see the changes.${RESET}"