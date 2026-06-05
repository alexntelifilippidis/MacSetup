# MacSetup — Project Instructions

## Repo Structure

```
src/
├── dotfiles/              # config files deployed to $HOME (symlinked or copied)
│   ├── claude/
│   ├── databricks/
│   ├── git/
│   ├── github-copilot/
│   ├── homebrew/          # Brewfile
│   ├── podman/            # registries.conf
│   └── zsh/
└── scripts/
    ├── lib/               # shared modules sourced by setup.sh
    ├── setup.sh           # orchestrator — calls setup_* functions from lib/
    ├── setup_podman.sh    # standalone podman machine + registry setup
    └── whats_new.sh       # show outdated brew packages + release notes
```

## Shell Tooling

- Lint: `shellcheck -x --severity=warning <file>`
- Format: `shfmt -i 2 -w <file>`
- Prefer `jq` over Python for JSON manipulation
- Prefer `rg` and `gsed` over `grep` and `sed` when not writing scripts

## Workflow

After any change to shell scripts, always run:

```bash
pre-commit run --all-files
```

Run `make doctor` to verify the full environment is healthy.

## Make Targets

```bash
make mac-setup    # full setup: homebrew, dotfiles, symlinks, podman
make podman-setup # podman machine + registry mirror only
make lint         # shellcheck -x --severity=warning on all .sh files
make fmt          # shfmt on all .sh files
make update       # brew update + upgrade + bundle + cleanup
make whats-new    # outdated brew packages + GitHub release notes
make doctor       # brew doctor + podman info sanity check
make precommit    # install + run pre-commit on the whole repo
```

## Git Workflow

**Branch naming** — must match CI pattern:

```
(feature|bugfix|hotfix|release|chore|config)/-short-description
```

```bash
git checkout -b chore/add-homebrew-section
```

**Commit format** — conventional commits, imperative mood:

```
type(scope): what it does

# types: feat | fix | chore | ci | docs | perf | refactor | revert | style | test
# scope: optional, e.g. homebrew | zsh | podman | git | claude
```

**Before opening a PR**, always run:

```bash
pre-commit run --all-files   # must pass
make lint                    # shellcheck clean
make fmt                     # shfmt clean
make doctor                  # environment healthy
```

## Creating a PR

Use `gh pr create`. Read `.github/pull_request_template.md` and fill every section from the diff — no placeholder text, no empty headings, no skipped checklist items.

## Conventions

- All dotfiles live under `src/dotfiles/<tool>/`; all scripts under `src/scripts/`
- `setup.sh` is a pure orchestrator — logic belongs in `src/scripts/lib/*.sh` modules
- Each lib module sources its own dependencies via `BASH_SOURCE[0]` (self-contained)
- `REPO_ROOT` is exported by `setup.sh`; lib modules provide a `${REPO_ROOT:-}` fallback
- Never use `$(pwd)` or hardcoded paths — always use `$REPO_ROOT`-relative paths
- `copy_if_changed` and `symlink_if_changed` in `lib/helpers.sh` are the only deployment primitives — do not inline `cp`/`ln` in module functions
- Secrets: `src/dotfiles/zsh/.secrets.zsh` and `src/dotfiles/databricks/.databrickscfg` are gitignored, `chmod 600` always
