# 🍎 MacSetup

Automated, idempotent setup for a Mac dev environment — Homebrew, Zsh, Git identities,
Databricks, Podman, and Claude Code — driven by `make` and a modular
`src/scripts/lib/` setup library.

Claude Code is the only AI client this repo supports, configured as a **plugin
marketplace** (`batcave`) rather than a pile of symlinked files.

---

## 🗂️ Structure

```text
MacSetup/
├── Makefile
├── README.md
├── .pre-commit-config.yaml
├── .github/                    # CI: lint + format + manifest validation
└── src/
    ├── dotfiles/                # config deployed into $HOME
    │   ├── claude/              # 🦇 host config + the batcave marketplace — see below
    │   ├── databricks/          # .databrickscfg (gitignored)
    │   ├── git/                 # .gitconfig + work/personal identity includes
    │   ├── homebrew/            # Brewfile
    │   ├── iterm2/               # Dynamic Profiles (Batman + Default)
    │   ├── podman/               # registries.conf
    │   └── zsh/                 # .zshrc + .secrets.zsh (gitignored)
    └── scripts/
        ├── lib/                # self-contained setup_* modules
        ├── setup.sh             # orchestrator
        ├── setup_podman.sh      # standalone
        └── whats_new.sh         # standalone
```

## 📚 Docs — start here, not below

Every module has its own README with the *how* and *why*. This file only orients you.

| Module               | Docs                                                              | Covers                                                      |
|----------------------|--------------------------------------------------------------------|--------------------------------------------------------------|
| 🦇 claude + plugin    | [`src/dotfiles/claude/`](src/dotfiles/claude/README.md) → [`plugins/batman/`](src/dotfiles/claude/plugins/batman/README.md) | Host config, the `batcave` marketplace, skills, MCP setup docs |
| 🍺 homebrew           | [`src/dotfiles/homebrew/`](src/dotfiles/homebrew/README.md)        | Brewfile as single source of truth                          |
| 💻 zsh                | [`src/dotfiles/zsh/`](src/dotfiles/zsh/README.md)                   | Oh My Zsh, themes, `.secrets.zsh`                            |
| 🖥️ iterm2             | [`src/dotfiles/iterm2/`](src/dotfiles/iterm2/README.md)             | Dynamic Profiles (Batman + Default), theme sync              |
| 🌿 git                | [`src/dotfiles/git/`](src/dotfiles/git/README.md)                   | Work/personal identity switching, branch/commit conventions |
| 🧪 databricks         | [`src/dotfiles/databricks/`](src/dotfiles/databricks/README.md)     | `.databrickscfg` profiles, auth methods                      |
| 🐋 podman             | [`src/dotfiles/podman/`](src/dotfiles/podman/README.md)             | Machine setup, Docker Hub mirror                             |
| ⚙️ scripts            | [`src/scripts/`](src/scripts/README.md)                             | Orchestrator + standalone entry points                       |
| 🧱 lib                | [`src/scripts/lib/`](src/scripts/lib/README.md)                     | `setup_*` module contract, how to add one                    |

## 🚀 Quick Start

```bash
git clone https://github.com/alexntelifilippidis/MacSetup.git "$HOME/Projects/Personal/MacSetup"
cd "$HOME/Projects/Personal/MacSetup"
make mac-setup   # idempotent — safe to re-run any time
```

Before first run: seed `src/dotfiles/databricks/.databrickscfg` (from its `_template`)
and `src/dotfiles/zsh/.secrets.zsh` (from its `.template`), both `chmod 600`, both
gitignored.

## 🧰 Make Targets

```bash
make mac-setup        # everything, in order
make homebrew-setup    # Homebrew + Brewfile only
make zsh-setup          # Oh My Zsh, themes, .zshrc, secrets only
make iterm-setup        # iTerm2 Dynamic Profiles (Batman + Default) only
make databricks-setup   # .databrickscfg only
make git-setup          # .gitconfig + identity includes only
make podman-setup       # Podman machine + registry mirror only
make claude-setup       # CLAUDE.md + statusline symlinks only
make claude-validate    # validate the batcave marketplace + batman plugin manifests
make claude-plugins     # register batcave + install batman via the claude CLI
make lint · make fmt     # shellcheck / shfmt, matches CI
make doctor              # brew doctor + podman info + plugin manifest validation
make update · make whats-new · make precommit
make help                # full list, auto-generated from `## ` doc comments
```

Each `*-setup` target runs one `setup_*` function from `src/scripts/lib/` in isolation —
see [`lib/README.md`](src/scripts/lib/README.md) for the module contract.

## 🔒 Security

- `.databrickscfg` and `.secrets.zsh` — `chmod 600`, gitignored, always
- No tokens, passwords, or workspace URLs ever committed
- Git credentials come from `git-credential-manager` — see
  [`git/README.md`](src/dotfiles/git/README.md) for retrieval, and
  [`mr-pr-creator`](src/dotfiles/claude/plugins/batman/skills/mr-pr-creator/SKILL.md)
  for the exact pattern (and a real bug it fixes in a naive `awk` extraction)
