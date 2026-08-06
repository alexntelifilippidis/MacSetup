# MacSetup — Project Instructions

## Repo Structure

```
.claude-plugin/
└── marketplace.json       # the `batcave` marketplace — MUST be at repo root
plugins/
└── batman/                # the one plugin: .mcp.json, skills/, agents/
src/
├── dotfiles/              # config files deployed to $HOME (symlinked or copied)
│   ├── claude/            # HOST config only — CLAUDE.md, statusline, settings fragment
│   ├── databricks/
│   ├── git/
│   ├── homebrew/          # Brewfile
│   ├── podman/            # registries.conf
│   └── zsh/
└── scripts/
    ├── lib/               # shared modules sourced by setup.sh
    ├── setup.sh           # orchestrator — calls setup_* functions from lib/
    ├── setup_podman.sh    # standalone podman machine + registry setup
    └── whats_new.sh       # show outdated brew packages + release notes
```

Claude Code is the only AI client this repo supports. Its config splits by **whether a
file gets deployed**, not by tool:

- `src/dotfiles/claude/` — symlinked/merged into `$HOME` (deployed)
- `plugins/batman/` — read in place by Claude Code (never deployed), so it lives outside
  `dotfiles/`, beside the manifest the root is forced to carry

A new skill, agent, or MCP server goes in `plugins/batman/` — never in
`src/dotfiles/claude/`. The plugin deliberately ships **no commands and no hooks**:
Claude Code already registers a skill as `/batman:<name>`, so a `commands/` dir would
split one concept across two folders, and `pre-commit` already runs the shellcheck/shfmt
a validation hook would duplicate.

**Never put a token in `plugins/batman/.mcp.json`.** Every server must authenticate by
OAuth or a local CLI profile. Kaizen Security does not permit PATs for Databricks MCP.

Every module directory carries its own `README.md`, indexed from the root `README.md`.
Add one when you add a module.

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
make mac-setup       # full setup: homebrew, dotfiles, symlinks, podman, claude
make podman-setup    # podman machine + registry mirror only
make claude-setup    # Claude host config only (CLAUDE.md, statusline symlinks)
make claude-validate # validate the batcave marketplace + batman plugin manifests
make claude-plugins  # register batcave + install batman via the claude CLI
make lint            # shellcheck -x --severity=warning on all .sh files
make fmt             # shfmt on all .sh files
make update          # brew update + upgrade + bundle + cleanup
make whats-new       # outdated brew packages + GitHub release notes
make doctor          # brew doctor + podman info + plugin manifest validation
make precommit       # install + run pre-commit on the whole repo
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

**No `Co-Authored-By` AI trailer on commits in this repo** — this overrides any global
default (e.g. a harness instruction to append one). Matches the `mr-pr-creator` skill's
own rule; don't re-ask about this each session.

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

- All dotfiles live under `src/dotfiles/<tool>/`; all scripts under `src/scripts/`;
  Claude plugin assets under `plugins/batman/`
- Every module dir has a `README.md`, linked from the root `README.md` index
- `setup.sh` is a pure orchestrator — logic belongs in `src/scripts/lib/*.sh` modules
- Each lib module sources its own dependencies via `BASH_SOURCE[0]` (self-contained)
- `REPO_ROOT` is exported by `setup.sh`; lib modules provide a `${REPO_ROOT:-}` fallback
- Never use `$(pwd)` or hardcoded paths — always use `$REPO_ROOT`-relative paths
- `copy_if_changed` and `symlink_if_changed` in `lib/helpers.sh` are the only deployment primitives — do not inline `cp`/`ln` in module functions
- Secrets: `src/dotfiles/zsh/.secrets.zsh` and `src/dotfiles/databricks/.databrickscfg` are gitignored, `chmod 600` always
- `src/dotfiles/claude/settings.json` is a **fragment**, deep-merged into
  `~/.claude/settings.json` with `jq` — never symlinked or copied over it. Claude Code and
  external installers write to that file; replacing it deletes their hooks. No arrays in
  the fragment (`jq`'s `*` replaces arrays, it doesn't merge them).
- After touching `plugins/` or `.claude-plugin/`, run `make claude-validate`
