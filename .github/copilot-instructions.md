# Copilot Instructions: MacSetup

## Repository Summary
This is a **personal Mac development environment setup repository**. It provides automated configuration for a Mac development environment using Homebrew, Oh My Zsh, Databricks CLI, Git credential manager, and Podman with custom registry mirrors. The repository enables quick and reproducible setup of a development workstation.

**Tech Stack:** Bash shell scripts, Homebrew, Oh My Zsh, Git, Databricks CLI, Podman  
**Package Managers:** Homebrew (via Brewfile)  
**Environment:** macOS (optimized for Apple Silicon with `/opt/homebrew`)  
**Purpose:** Personal development environment automation

## Repository Structure

```
MacSetup/
├── Brewfile                          # Homebrew packages and casks to install
├── Makefile                          # Automation shortcuts with self-documenting help
├── README.md                         # Comprehensive setup documentation
├── setup.sh                          # Main setup script (orchestrates everything)
├── databricks/
│   ├── .databrickscfg                # Databricks CLI configuration
│   └── .databrickscfg_template       # Template for Databricks config
├── git-credential-manager/
│   ├── .gitconfig                    # Main Git configuration
│   ├── .gitconfig-personal           # Personal project Git settings
│   └── .gitconfig-work               # Work project Git settings
├── github-copilot/
│   └── intellij/
│       ├── global-copilot-instructions.md    # General coding style & Copilot behaviour
│       ├── global-agents-instructions.md     # Instructions for Copilot agentic tasks
│       └── global-git-commit-instructions.md # Conventional commit message generation
├── podman/
│   ├── QUICK_REFERENCE.md            # Podman SSH and registry commands
│   ├── README.md                     # Podman setup documentation
│   ├── registries.conf               # Docker Hub mirror configuration
│   └── setup_podman.sh               # Podman machine setup script
└── zsh/
    └── .zshrc                        # Oh My Zsh configuration
```

## Quick Start

### Initial Setup (One Command)
```bash
# Clone and run full setup
git clone https://github.com/yourusername/MacSetup.git
cd MacSetup
chmod +x setup.sh
./setup.sh
```

### Makefile Shortcuts
```bash
make help          # Show all available commands
make mac-setup     # Run full Mac setup (same as ./setup.sh)
make podman-setup  # Run only Podman machine setup
make brew-folder   # Show Homebrew installation path
```

## What Gets Installed

### Homebrew Packages (via Brewfile)
**Development Tools:**
- `git`, `gh` (GitHub CLI), `glab` (GitLab CLI), `copilot`
- `pre-commit`, `shellcheck`, `hadolint`
- `terraform`, `terraform-docs`
- `hatch` (Python project manager)
- `curl`, `unixodbc`

**Programming Languages:**
- Python: 3.10, 3.11, 3.12, 3.13
- Java: OpenJDK 11, 17

**Container Tools:**
- `podman`, `podman-compose`

**Databricks:**
- `databricks` CLI

**Zsh Enhancements:**
- `zsh-autosuggestions`
- `zsh-completions`
- `zsh-syntax-highlighting`

### Homebrew Casks (Applications)
- `git-credential-manager` - Secure Git credential storage
- `google-chrome` - Web browser
- `iterm2` - Terminal emulator
- `pycharm` - Python IDE
- `intellij-idea` - Java/Scala IDE
- `alfred` - Productivity app
- `chatgpt` - ChatGPT desktop app
- `podman-desktop` - Podman GUI

## Setup Script Workflow

The `setup.sh` script performs these steps in order:

1. **Install Homebrew** (if not present)
   - Adds Homebrew to `.zprofile` for Apple Silicon Macs
   - Sets up `/opt/homebrew/bin` in PATH

2. **Install Packages from Brewfile**
   - Runs `brew bundle --file=./Brewfile`
   - Installs all formulae and casks

3. **Install Oh My Zsh** (if not present)
   - Downloads and installs Oh My Zsh framework

4. **Symlink .zshrc**
   - Creates symlink from `zsh/.zshrc` to `~/.zshrc`

5. **Configure Databricks CLI**
   - Copies `.databrickscfg` to `~/.databrickscfg`
   - Sets permissions to 600 for security

6. **Configure Git**
   - Copies `.gitconfig` to `~/.gitconfig`
   - Copies conditional configs:
     - `.gitconfig-personal` → `~/Projects/Personal/.gitconfig`
     - `.gitconfig-work` → `~/Projects/Work/.gitconfig`

7. **Setup Podman Machine**
   - Calls `podman/setup_podman.sh`
   - Configures Docker Hub registry mirror

## Podman Setup

### What Podman Setup Does
1. Initializes Podman machine (if not exists)
2. Starts the Podman VM
3. Configures SSH access
4. Sets up Docker Hub mirror: `registry.kaizengaming.eu/docker-hub-proxy`
5. Appends registry config to `/etc/containers/registries.conf` inside VM
6. Enables insecure registry for HTTP access

### Podman Configuration
The script appends this configuration to `/etc/containers/registries.conf`:
```toml
[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "registry.kaizengaming.eu/docker-hub-proxy"
insecure = true
```

**Important:** `insecure = true` is required to avoid TLS handshake failures.

### Podman Commands

**Machine Management:**
```bash
podman machine start          # Start the VM
podman machine stop           # Stop the VM
podman machine list           # List all machines
podman machine ssh            # SSH into the VM
```

**SSH into Podman VM:**
```bash
# Interactive session
podman machine ssh

# Execute single command
podman machine ssh -- "sudo cat /etc/containers/registries.conf"

# Check if mirror is configured
podman machine ssh -- "sudo grep -A 2 'docker.io' /etc/containers/registries.conf"
```

**Container Operations:**
```bash
podman pull nginx             # Pull image (uses mirror)
podman run -d -p 8080:80 nginx  # Run container
podman ps                     # List running containers
podman ps -a                  # List all containers
podman logs <container>       # View logs
```

### Troubleshooting TLS Handshake Failures

If you see `tls: handshake failure` errors:

1. **Verify registry configuration:**
   ```bash
   podman machine ssh -- "sudo cat /etc/containers/registries.conf | tail -10"
   ```
   Should show `insecure = true` for the mirror.

2. **Re-run setup:**
   ```bash
   bash podman/setup_podman.sh
   ```

3. **Restart machine:**
   ```bash
   podman machine stop && podman machine start
   ```

4. **Test pull:**
   ```bash
   podman pull hello-world
   ```

**Root Cause:** Missing `insecure = true` flag prevents HTTP connections to the registry mirror.

## Git Configuration

The setup uses conditional Git configurations to separate personal and work settings:

**Main `.gitconfig`** contains conditional includes:
- Loads `.gitconfig-personal` when in `~/Projects/Personal/`
- Loads `.gitconfig-work` when in `~/Projects/Work/`

This allows different email addresses, signing keys, etc. based on project location.

## Customization Guide

### Adding New Homebrew Packages
Edit `Brewfile` and add:
```ruby
# For CLI tools
brew "package-name"

# For applications
cask "app-name"

# For taps (repositories)
tap "owner/repo"
```

Then run: `brew bundle --file=./Brewfile`

### Modifying Zsh Configuration
Edit `zsh/.zshrc` with your preferences. After editing:
```bash
source ~/.zshrc  # Reload configuration
```

### Updating Databricks Config
Edit `databricks/.databrickscfg` with your workspace details:
```ini
[DEFAULT]
host = https://<your-workspace-url>
token = <your-personal-access-token>

[profile-name]
host = https://<another-workspace>
token = <another-token>
```

Then copy to home:
```bash
cp databricks/.databrickscfg ~/.databrickscfg
chmod 600 ~/.databrickscfg
```

### Adding Git Configurations
Edit the appropriate config file:
- Global settings: `git-credential-manager/.gitconfig`
- Personal projects: `git-credential-manager/.gitconfig-personal`
- Work projects: `git-credential-manager/.gitconfig-work`

Then re-run setup or copy manually.

## Shell Script Coding Standards

When modifying or adding shell scripts in this project:

1. **Use Bash shebang:** Start with `#!/bin/bash`

2. **Color output:** Use ANSI color codes for better UX
   ```bash
   GREEN='\033[0;32m'
   YELLOW='\033[1;33m'
   RESET='\033[0m'
   echo -e "${GREEN}Success!${RESET}"
   ```

3. **Check before installing:**
   ```bash
   if ! command -v tool &> /dev/null; then
     echo "Installing tool..."
   fi
   ```

4. **Make scripts idempotent:** Safe to run multiple times without side effects

5. **Use absolute paths for user files:** `$HOME/.config` not `~/.config`

6. **Set file permissions explicitly:**
   ```bash
   chmod 600 sensitive-file  # Read/write for owner only
   chmod +x script.sh        # Make executable
   ```

7. **Validate critical operations:**
   ```bash
   if [ -f "$HOME/.databrickscfg" ]; then
     echo "File already exists"
   fi
   ```

8. **Provide user feedback:** Echo what's happening at each step

## Common Tasks

### Re-running Full Setup
```bash
./setup.sh
# OR
make mac-setup
```
The scripts are idempotent and safe to re-run.

### Re-running Only Podman Setup
```bash
bash podman/setup_podman.sh
# OR
make podman-setup
```

### Updating Homebrew Packages
```bash
brew update           # Update Homebrew itself
brew upgrade          # Upgrade all packages
brew bundle --file=./Brewfile  # Install any new packages from Brewfile
```

### Checking Installed Versions
```bash
brew --version
python3 --version
git --version
databricks --version
podman --version
```

### Finding Homebrew Installation
```bash
make brew-folder
# OR
brew --prefix
```

## Maintenance

### Keeping Brewfile Updated
Periodically review installed packages:
```bash
brew list              # List all installed formulae
brew list --cask       # List all installed casks
brew bundle dump       # Generate Brewfile from installed packages
```

### Cleaning Up Homebrew
```bash
brew cleanup           # Remove old versions
brew autoremove        # Remove unused dependencies
brew doctor            # Check for issues
```

### Backing Up Configurations
All config files are in this repository. To backup:
```bash
cd ~/Projects/Personal/MacSetup
git add -A
git commit -m "Update configurations"
git push
```

## Troubleshooting

### Homebrew Not Found After Install
Add to `.zprofile` or `.zshrc`:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Oh My Zsh Installation Fails
Manually install:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Podman Machine Won't Start
```bash
podman machine stop
podman machine rm
bash podman/setup_podman.sh  # Re-initialize
```

### Git Credential Manager Issues
Check installation:
```bash
git credential-manager --version
```

Re-install if needed:
```bash
brew reinstall git-credential-manager
```

### Databricks CLI Authentication
List profiles:
```bash
databricks auth profiles
```

Test connection:
```bash
databricks workspace list
```

## Important Notes

1. **Apple Silicon:** Scripts assume Homebrew is at `/opt/homebrew` (Apple Silicon default)

2. **Directory Structure:** Git configs assume `~/Projects/Personal` and `~/Projects/Work` exist

3. **Sensitive Data:** Never commit real tokens/passwords to `.databrickscfg`. Use templates instead.

4. **Idempotency:** All scripts check for existing installations before proceeding

5. **Podman vs Docker:** This setup uses Podman, which is Docker-compatible but rootless

6. **Registry Mirror:** The Kaizen Gaming registry mirror requires network access to `registry.kaizengaming.eu`

7. **Multiple Python Versions:** Brewfile installs Python 3.10-3.13. Use `python3.11` to specify version.

## Quick Reference

**Run full setup:** `./setup.sh` or `make mac-setup`  
**Setup Podman only:** `make podman-setup`  
**Show help:** `make help`  
**SSH to Podman:** `podman machine ssh`  
**Check Podman config:** `podman machine ssh -- "sudo cat /etc/containers/registries.conf"`  
**Update packages:** `brew bundle --file=./Brewfile`  
**Reload Zsh:** `source ~/.zshrc`

**End of Instructions** - This guide covers the complete MacSetup repository for automated Mac development environment configuration.

