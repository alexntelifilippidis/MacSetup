#!/bin/bash

# Simple color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Simple loading with spinner animation
show_loading() {
    local msg="$1"
    local cmd="$2"
    
    echo -n "  $msg "
    
    # Run command in background
    eval "$cmd" > /dev/null 2>&1 &
    local pid=$!
    
    # Spinner animation
    local spin='|/-\'
    local i=0
    
    # Show spinner while command runs
    while kill -0 $pid 2>/dev/null; do
        printf "\b${spin:$((i%4)):1}"
        sleep 0.1
        ((i++))
    done
    
    # Clear spinner and show checkmark
    printf "\b✅"
    
    wait $pid
    echo ""
    return $?
}

# Simple success message
success() {
    echo -e "  ${GREEN}✅ $1${NC}"
}

# Simple info message
info() {
    echo -e "  ${BLUE}→ $1${NC}"
}

# Simple error message
error() {
    echo -e "  ${RED}❌ $1${NC}"
}

# Header
echo -e "\n${BOLD}${BLUE}🔧 Mac Setup Script${NC}"
echo -e "${BOLD}Setting up your development environment...${NC}\n"

# Install Homebrew
echo -e "${BOLD}1. Installing Homebrew${NC}"
if ! command -v brew &> /dev/null; then
    info "Homebrew not found, installing..."
    show_loading "Installing Homebrew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    echo >> "$HOME/.zprofile"
    echo "eval $(/opt/homebrew/bin/brew shellenv)" >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# Install packages from Brewfile
echo -e "\n${BOLD}2. Installing Brew packages${NC}"
info "Reading Brewfile and installing packages..."
show_loading "Installing packages" "brew bundle --file=./Brewfile --quiet"
success "Brew packages installed"

# Install Oh My Zsh
echo -e "\n${BOLD}3. Installing Oh My Zsh${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    show_loading "Setting up Oh My Zsh" 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    success "Oh My Zsh installed"
else
    success "Oh My Zsh already installed"
fi

# Symlink .zshrc
echo -e "\n${BOLD}4. Configuring Zsh${NC}"
info "Linking .zshrc configuration..."
ln -sf "$(pwd)/zsh/.zshrc" "$HOME/.zshrc"
success ".zshrc linked"

# Configure Databricks CLI
echo -e "\n${BOLD}5. Setting up Databricks CLI${NC}"
info "Copying Databricks configuration..."
cp ./databricks/.databrickscfg "$HOME/.databrickscfg"
chmod 600 "$HOME/.databrickscfg"
success "Databricks CLI configured"

# Configure GitConfig
echo -e "\n${BOLD}6. Setting up Git configuration${NC}"
info "Copying Git configuration files..."
cp ./git-credential-manager/.gitconfig "$HOME/.gitconfig"
cp ./git-credential-manager/.gitconfig-personal "$HOME/Projects/Personal/.gitconfig"
cp ./git-credential-manager/.gitconfig-work "$HOME/Projects/Work/.gitconfig"
success "Git configuration completed"

# Final message
echo -e "\n${BOLD}${GREEN}🎉 Setup Complete!${NC}"
echo -e "${YELLOW}Please restart your terminal to see all changes.${NC}\n"