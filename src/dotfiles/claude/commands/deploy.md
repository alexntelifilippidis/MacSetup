# /deploy — Deploy Dotfiles & Setup

Run the MacSetup deployment pipeline.

## Usage

```
/deploy [target]
```

Targets: `dotfiles` | `homebrew` | `podman` | `all` (default: `all`)

## Steps

1. Run pre-flight checks:

   ```bash
   pre-commit run --all-files
   make lint
   make fmt
   make doctor
   ```

2. Deploy:

   ```bash
   make mac-setup       # full: homebrew + dotfiles + symlinks + podman
   make podman-setup    # podman machine + registry mirror only
   ```

3. Verify:

   ```bash
   make doctor
   ```

## Safety

- Always runs in staging / dry-run first if available
- Destructive operations (`rm`, overwrite) require explicit confirmation
- Symlinks use `symlink_if_changed` — idempotent, no silent overwrites
- Secret files (`chmod 600`) are verified post-deploy
