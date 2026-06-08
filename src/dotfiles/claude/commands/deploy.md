# /deploy — Deploy Dotfiles & Setup

Deploy MacSetup dotfiles and tooling to the local machine.

## Usage

```
/deploy [target]
```

| Target | Command | What it does |
|--------|---------|-------------|
| `all` *(default)* | `make mac-setup` | Homebrew + dotfiles + symlinks + Podman |
| `homebrew` | `brew bundle --file=$HOME/.config/homebrew/Brewfile` | Packages only |
| `podman` | `make podman-setup` | Podman machine + registry mirror |
| `dotfiles` | `make mac-setup` | Dotfiles + symlinks (skips Homebrew) |

## Steps

### 1. Pre-flight — stop and report if any step fails

```bash
pre-commit run --all-files   # must pass
make lint                    # shellcheck clean
make fmt                     # shfmt clean
make doctor                  # environment healthy
```

### 2. Deploy

Run the command for the chosen target (default: `all`).

### 3. Post-deploy verification

```bash
make doctor
```

Verify secret files have correct permissions:

```bash
stat -f "%OLp %N" "$HOME/.secrets.zsh" "$HOME/.databrickscfg" 2>/dev/null
```

Both must show `600`. Fix with `chmod 600` if not.

## Safety Rules

- `symlink_if_changed` is idempotent — safe to re-run
- Require explicit confirmation before any destructive operation (`rm`, overwrite)
- Never run `make mac-setup` on a machine with uncommitted local dotfile changes without confirming
