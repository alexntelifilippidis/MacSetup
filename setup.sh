#!/bin/bash

echo "🔧 Setting up your Mac 💻 environment..."

# Install Homebrew
if ! command -v brew &> /dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo >> "$HOME/.zprofile"
  echo "eval $(/opt/homebrew/bin/brew shellenv)" >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "🍺 Homebrew already exists ✅."
fi

# Install packages from Brewfile
echo "📦 Installing 🍺 Brew packages..."
brew bundle --file=./Brewfile

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "💻 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "💻 Oh My Zsh already exists ✅."
fi

# Symlink .zshrc
echo "🔗 Linking .zshrc..."
ln -sf "$(pwd)/zsh/.zshrc" "$HOME/.zshrc"

# Configure Databricks CLI
echo "🧪 Setting up Databricks CLI config..."
cp ./databricks/.databrickscfg "$HOME/.databrickscfg"
chmod 600 "$HOME/.databrickscfg"

# Configure GitConfig
echo "🛠️ Setting up Git config..."
cp ./git-credential-manager/.gitconfig "$HOME/.gitconfig"
cp ./git-credential-manager/.gitconfig-personal "$HOME/Projects/Personal/.gitconfig"
cp ./git-credential-manager/.gitconfig-work "$HOME/Projects/Work/.gitconfig"

echo "✅ Done! Restart your terminal to see the changes."