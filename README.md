# 🍎 MacSetup

Automated, idempotent setup for a Mac development environment — Homebrew, Zsh, Git
identities, Databricks, Podman, Claude Code, and all dotfiles — driven by a `make`
interface and a modular `src/scripts/lib/` setup library.

Claude Code is the only AI client this repo supports, and it is configured as a
**plugin marketplace** (`batcave`) rather than a pile of symlinked files.

## 🗂️ Structure

```text
MacSetup/
├── Makefile
├── README.md
├── .pre-commit-config.yaml
├── .claude-plugin/
│   └── marketplace.json    # the `batcave` marketplace manifest (must be at repo root)
├── plugins/
│   └── batman/             # the one plugin: mcp docs, skills, agents
├── .github/
│   ├── pull_request_template.md
│   └── workflows/          # CI: lint + format + manifest validation
└── src/
    ├── dotfiles/           # config files symlinked / copied into $HOME
    │   ├── claude/         # Claude HOST config only — CLAUDE.md, statusline
    │   ├── databricks/     # .databrickscfg (gitignored — real values)
    │   ├── git/            # .gitconfig + work/personal identity includes
    │   ├── homebrew/       # Brewfile
    │   ├── podman/         # registries.conf
    │   └── zsh/            # .zshrc + .secrets.zsh (gitignored)
    └── scripts/
        ├── lib/            # self-contained setup_* modules sourced by setup.sh
        ├── setup.sh        # orchestrator — calls setup_* functions from lib/
        ├── setup_podman.sh # standalone podman machine + registry setup
        └── whats_new.sh    # outdated brew packages + GitHub release notes
```

### 📚 Module docs

Every module carries its own README. Start here:

| Module | Docs | What it covers |
|---|---|---|
| 🍺 homebrew | [`src/dotfiles/homebrew/`](src/dotfiles/homebrew/README.md) | Brewfile as single source of truth, `brew bundle` |
| 💻 zsh | [`src/dotfiles/zsh/`](src/dotfiles/zsh/README.md) | Oh My Zsh, themes, `.secrets.zsh` handling |
| 🌿 git | [`src/dotfiles/git/`](src/dotfiles/git/README.md) | Work/personal identity switching via `includeIf` |
| 🧪 databricks | [`src/dotfiles/databricks/`](src/dotfiles/databricks/README.md) | `.databrickscfg` profiles, auth methods, `chmod 600` |
| 🐋 podman | [`src/dotfiles/podman/`](src/dotfiles/podman/README.md) · [quick ref](src/dotfiles/podman/QUICK_REFERENCE.md) | Machine setup, Docker Hub mirror |
| 🦇 claude (host) | [`src/dotfiles/claude/`](src/dotfiles/claude/README.md) | `CLAUDE.md`, statusline, why settings.json is left alone |
| 🃏 batman plugin | [`plugins/batman/`](plugins/batman/README.md) | MCP setup docs, and how to add a skill or agent |
| ⚙️ scripts | [`src/scripts/`](src/scripts/README.md) | Orchestrator + standalone entry points |
| 🧱 lib | [`src/scripts/lib/`](src/scripts/lib/README.md) | The `setup_*` module contract, how to add one |

### 🧷 Why `plugins/` sits in the root

The layout splits on **whether a file gets deployed**, not on which tool owns it:

- `src/dotfiles/claude/` — symlinked into `$HOME`. ✅ deployed
- `plugins/batman/` — Claude Code reads it **in place** from this working copy, so it is
  never copied anywhere. ❌ not deployed → doesn't belong under `dotfiles/`

It sits in the root because Claude Code requires the marketplace manifest at exactly
`<repo>/.claude-plugin/marketplace.json`, and the plugin tree belongs beside it — which is
also where `claude plugin marketplace add <repo>` and every public marketplace repo expect
to find it.

## 🧭 Why this layout?

The repo separates **what gets deployed** (`src/dotfiles/`) from **how it gets
deployed** (`src/scripts/`). Each lives under `src/` so the repo root stays
reserved for project-level metadata (`Makefile`, `README.md`, `pyproject.toml`,
`.github/`, `.pre-commit-config.yaml`) — nothing in the root is symlinked
anywhere.

### `src/dotfiles/<tool>/` — one folder per tool

Every config file that lands in `$HOME` (or `$HOME/.<tool>/`) lives under
`src/dotfiles/<tool>/`. Grouping by **tool** instead of by file type means:

- Adding a new tool is one folder — no scattered edits across the tree
- A folder owns everything for its tool: configs, templates, and any
  tool-specific docs
- Deleting a tool is `git rm -r src/dotfiles/<tool>/` — clean removal
- The folder name is the obvious place to look (`git/`, `homebrew/`, `claude/`)

### `src/scripts/` — orchestrator + library

- `setup.sh` is a **pure orchestrator** — it exports `REPO_ROOT`, sources the
  `lib/` modules, and calls `setup_*` functions in order. No logic lives here.
- `src/scripts/lib/*.sh` are **self-contained modules**. Each module sources
  its own dependencies via `BASH_SOURCE[0]`, so `lib/podman.sh` can be tested
  in isolation without `setup.sh` running first.
- Standalone entry points (`setup_podman.sh`, `whats_new.sh`) live next to
  `setup.sh` so they're equally discoverable.

### Two deployment primitives, never inlined

`lib/helpers.sh` exports exactly two file-deployment helpers:

| Helper                | When to use                          |
| --------------------- | ------------------------------------ |
| `symlink_if_changed`  | Source of truth lives in this repo; edits to the dotfile in `$HOME` should reflect back |
| `copy_if_changed`     | Files that must be locally mutable (secrets, machine-specific tokens) without dirtying the repo |

Module functions **never** inline `cp` or `ln -sf` — this keeps deployment
idempotent and ensures consistent logging across every tool.

### Why a Makefile on top?

The `Makefile` is the **stable user interface**. Implementation underneath can
move (split modules, rename libs, swap shellcheck for another linter) without
changing what the user types. CI and local dev share the exact same commands
(`make lint`, `make fmt`, `pre-commit run --all-files`) — no drift between
"works on my machine" and "works in CI."

### Why split git identity into three files?

`src/dotfiles/git/.gitconfig` is the entrypoint. It uses `includeIf
"gitdir:..."` to load `.gitconfig-personal` when working under
`~/Projects/Personal/` and `.gitconfig-work` under `~/Projects/Work/`. Two
identities, zero per-repo `git config` commands, zero accidental commits with
the wrong email.

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
make mac-setup       # full setup: homebrew, dotfiles, symlinks, podman, claude
make podman-setup    # podman machine + registry mirror only
make claude-setup    # Claude host config only (CLAUDE.md, statusline symlinks)
make claude-validate # validate the batcave marketplace + batman plugin manifests
make claude-plugins  # register batcave + install batman via the claude CLI
make lint            # shellcheck -x --severity=warning on all .sh files
make fmt             # shfmt -i 2 -ci -sr on all .sh files
make update          # brew update + upgrade + bundle + cleanup
make whats-new       # outdated brew packages + their GitHub release notes
make doctor          # brew doctor + podman info + plugin manifest validation
make precommit       # install + run pre-commit on the whole repo
make help            # show this list (auto-generated from `## ` doc comments)
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
| `setup_claude`    | `claude.sh`     | Symlink `CLAUDE.md` + statusline, merge managed `settings.json` keys, report the `batman` plugin |

All file deployment goes through `copy_if_changed` and `symlink_if_changed` in
`lib/helpers.sh` — content-aware, no silent overwrites, idempotent re-runs.

## 🦇 Claude Code

Claude Code config splits across two surfaces, because only one of them can live in
a plugin.

### 1. `plugins/batman/` — the `batcave` marketplace

Registered once with `make claude-plugins`. The marketplace source is a `directory`
pointing at this working copy, so **a `git pull` updates the live assets with no re-deploy**.

| Kind        | Contents                                                                     |
|-------------|------------------------------------------------------------------------------|
| 🔌 **mcp**   | [Setup docs](plugins/batman/mcp/README.md) — GitHub · GitLab · Jira+Confluence · Databricks. **Docs only; no `.mcp.json`.** |
| 🧠 **skills**| `mr-pr-creator` · `jira-ticket-creator` · `confluence-page-creator`         |
| 🤖 **agents**| *(none yet)*                                                                 |

No `commands/` and no `hooks/`, deliberately — Claude Code already exposes a skill as
`/batman:<name>`, and `pre-commit` already runs the shellcheck/shfmt a validation hook
would duplicate.

MCP ships as **documentation, not config**: a plugin `.mcp.json` auto-registers on install,
so every server would try to connect on every session start — and real endpoints are
internal infrastructure that doesn't belong in a public repo. Register servers with
`claude mcp add` per the docs, keeping endpoints in `.secrets.zsh`.

Install on another machine straight from GitHub:

```bash
claude plugin marketplace add alexntelifilippidis/MacSetup
claude plugin install batman@batcave
```

See [`plugins/batman/README.md`](plugins/batman/README.md) for the catalog and how to add a
skill or agent.

### 2. `src/dotfiles/claude/` — host config

Only what a plugin cannot carry. Three symlinks, nothing else:

| File                    | Destination                   |
|-------------------------|-------------------------------|
| `CLAUDE.md`             | `$HOME/CLAUDE.md`             |
| `statusline-command.sh` | `$HOME/.claude/`              |
| `settings.local.json`   | `$HOME/.claude/` (gitignored) |

> ⚠️ **The repo deliberately does not manage `~/.claude/settings.json`.** Claude Code writes
> to that file itself (`model`, `/config`, plugin state) and so do external installers.
> A setup script that copies, symlinks, or merges over it can only break a working install —
> marketplace registration is left to the `claude` CLI (`make claude-plugins`), which owns
> that file and knows its schema.

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
