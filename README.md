# 📁 Repository Name: MacSetup

## 🗂️ Structure:
```
mac-dev-setup/
├── Brewfile
├── setup.sh
├── zsh/
│   └── .zshrc
├── databricks/
│   └── .databrickscfg
├── README.md
```





Automated setup for a Mac development environment using:

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- Databricks CLI configuration
- Developer-friendly defaults

## 🚀 Quick Start

```bash
git clone https://github.com/yourusername/mac-dev-setup.git
cd mac-dev-setup
chmod +x setup.sh
./setup.sh
```
Make sure to customize .databrickscfg with your actual token/workspace before running.

🧰 Contents
	•	Brewfile: List of Homebrew packages to install
	•	setup.sh: Main setup script
	•	zsh/.zshrc: Your Zsh config (Oh My Zsh based)
	•	databricks/.databrickscfg: Template for Databricks CLI

---

### 🛠️ `setup.sh`

```bash
#!/bin/bash

echo "🔧 Setting up your Mac dev environment..."

# Install Homebrew
if ! command -v brew &> /dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages from Brewfile
echo "📦 Installing Brew packages..."
brew bundle --file=./Brewfile

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "💻 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Symlink .zshrc
echo "🔗 Linking .zshrc..."
ln -sf "$(pwd)/zsh/.zshrc" "$HOME/.zshrc"

# Configure Databricks CLI
echo "🧪 Setting up Databricks CLI config..."
mkdir -p "$HOME/.databricks"
cp ./databricks/.databrickscfg "$HOME/.databrickscfg"
chmod 600 "$HOME/.databrickscfg"

echo "✅ Done! Restart your terminal to see the changes."
```

⸻

### 📦 Brewfile
``` 
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"

brew "git"
brew "python"
brew "node"
brew "zsh"
brew "databricks-cli"

cask "visual-studio-code"
cask "google-chrome"
cask "iterm2"
```

⸻

### 🐚 zsh/.zshrc
```
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git z)

source $ZSH/oh-my-zsh.sh

export PATH="/opt/homebrew/bin:$PATH"

```
⸻

### 🔐 databricks/.databrickscfg
```
[DEFAULT]
host = https://<your-workspace-url>
token = <your-personal-access-token>

```
⸻
