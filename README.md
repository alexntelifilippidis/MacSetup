# 🍎 MacSetup

Automated, idempotent setup for a Mac development environment — Homebrew, Zsh, Git
identities, Databricks, Podman, GitHub Copilot, Claude Code, and all dotfiles —
driven by a `make` interface and a modular `src/scripts/lib/` setup library.

## 🗂️ Structure

```text
MacSetup/
├── Makefile
├── README.md
├── pyproject.toml          # uv project + ruff/pre-commit config
├── .pre-commit-config.yaml
├── .github/
│   ├── pull_request_template.md
│   └── workflows/          # CI: lint + format + commit conventions
└── src/
    ├── dotfiles/           # config files symlinked / copied into $HOME
    │   ├── claude/         # Claude Code: rules, agents, commands, skills, hooks
    │   ├── databricks/     # .databrickscfg (gitignored — real values)
    │   ├── git/            # .gitconfig + work/personal identity includes
    │   ├── github-copilot/ # global Copilot instructions
    │   ├── homebrew/       # Brewfile
    │   ├── podman/         # registries.conf
    │   └── zsh/            # .zshrc + .secrets.zsh (gitignored)
    └── scripts/
        ├── lib/            # self-contained setup_* modules sourced by setup.sh
        ├── setup.sh        # orchestrator — calls setup_* functions from lib/
        ├── setup_podman.sh # standalone podman machine + registry setup
        └── whats_new.sh    # outdated brew packages + GitHub release notes
```

## 🚀 Quick Start

```bash
git clone https://github.com/alexntelifilippidis/MacSetup.git "$HOME/Projects/Personal/MacSetup"
cd "$HOME/Projects/Personal/MacSetup"
make mac-setup
```

`make mac-setup` is **idempotent** — safe to re-run any time. It will only update
files whose content has changed.

Before first run, populate machine-local secrets:

- `$HOME/.databrickscfg` — generated from `src/dotfiles/databricks/.databrickscfg`
  (gitignored); fill in your workspace host + token, then `chmod 600`
- `$HOME/.secrets.zsh` — your shell environment secrets (gitignored), `chmod 600`

## 🧰 Make Targets

```bash
make mac-setup     # full setup: homebrew, dotfiles, symlinks, podman, claude, copilot
make podman-setup  # podman machine + registry mirror only
make lint          # shellcheck -x --severity=warning on all .sh files
make fmt           # shfmt -i 2 -ci -sr on all .sh files
make update        # brew update + upgrade + bundle + cleanup
make whats-new     # outdated brew packages + their GitHub release notes
make doctor        # brew doctor + podman info sanity check
make precommit     # install + run pre-commit on the whole repo
make help          # show this list (auto-generated from `## ` doc comments)
```

## 🔧 What `setup.sh` does

`src/scripts/setup.sh` is a pure orchestrator. It exports `REPO_ROOT`, sources the
modules under `src/scripts/lib/`, and runs each `setup_*` function in order:

| Function          | Module          | Result |
| ----------------- | --------------- | ------ |
| `setup_homebrew`  | `homebrew.sh`   | Install Homebrew + `brew bundle` |
| `setup_zsh`       | `zsh.sh`        | Oh My Zsh + symlink `.zshrc`, `.secrets.zsh` |
| `setup_databricks`| `databricks.sh` | Copy `.databrickscfg` (chmod 600) |
| `setup_git`       | `git.sh`        | Symlink `.gitconfig` + work / personal includes |
| `setup_podman`    | `podman.sh`     | Podman machine + Docker Hub mirror |
| `setup_copilot`   | `tools.sh`      | GitHub Copilot global instructions |
| `setup_claude`    | `tools.sh`      | Symlink every file under `src/dotfiles/claude/` into `$HOME/.claude/` |

All file deployment goes through `copy_if_changed` and `symlink_if_changed` in
`lib/helpers.sh` — content-aware, no silent overwrites, idempotent re-runs.

## 🤖 Claude Code Config

`src/dotfiles/claude/` contains a modular Claude Code configuration that is
auto-symlinked to `$HOME/.claude/` (with `CLAUDE.md` landing at `$HOME/CLAUDE.md`).

It includes:

- `rules/` — code style, API conventions, PR workflow, git identities
  (GitHub personal + GitLab work), and repo-type conventions (Terraform, Python, Scala, SQL)
- `agents/` — code-reviewer and security-auditor sub-agents
- `commands/` — `/review` and `/deploy` slash commands
- `skills/` — testing-patterns skill
- `hooks/` — pre-edit shellcheck + shfmt validation

See [`src/dotfiles/claude/README.md`](src/dotfiles/claude/README.md) for details.

## 🐋 Podman

`src/scripts/setup_podman.sh` configures a Podman machine with a Docker Hub mirror.

What it does:

1. Initializes and starts the Podman machine (idempotent)
2. SSHes into the VM and appends a registry mirror to
   `/etc/containers/registries.conf` (with backup, deduped)
3. Mirror: `registry.kaizengaming.eu/docker-hub-proxy` → `docker.io`

Run standalone with `make podman-setup`.

SSH into the VM:

```bash
podman machine ssh                                          # interactive
podman machine ssh -- "sudo cat /etc/containers/registries.conf"
podman machine list
```

## 🧪 Development

Pre-commit, shellcheck, shfmt, and markdownlint run on every commit and in CI.

```bash
pre-commit run --all-files   # must pass before opening a PR
make lint                    # shellcheck clean
make fmt                     # shfmt clean
make doctor                  # environment healthy
```

## 🌿 Git Conventions

Branch naming — must match CI regex
`^((feature|bugfix|hotfix|release|chore|config)/([A-Z]+-\d+|NOJIRA)-.*|main|master)$`:

```bash
git checkout -b chore/NOJIRA-update-brewfile
git checkout -b feature/KAI-123-add-thing      # work repos with a ticket
```

Commits use conventional commits, imperative mood:

```text
type(scope): what it does
# types: feat | fix | chore | ci | docs | perf | refactor | revert | style | test
```

Open PRs with `gh pr create` and fill **every section** of
`.github/pull_request_template.md`.

## 🔒 Security

- Credential files (`.databrickscfg`, `.secrets.zsh`) → `chmod 600` always, gitignored
- No tokens, passwords, or workspace URLs committed
- Git credentials are managed by `git-credential-manager` (installed via Brewfile)
