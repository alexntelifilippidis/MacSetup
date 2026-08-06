# 🦇 Claude Code

Both halves of Claude Code config live here, colocated for easy tracking:

| Half                                    | What                                             | Deployed?          |
|------------------------------------------|--------------------------------------------------|--------------------|
| **Host config** (this dir)               | `CLAUDE.md`, statusline, `settings.local.json`    | ✅ symlinked into `$HOME` |
| **`batcave` marketplace** ([`plugins/batman/`](plugins/batman/README.md)) | Skills, agents, MCP docs | ❌ read in place, never deployed |

## 📦 Host config

| File                    | Destination        |
|-------------------------|---------------------|
| `CLAUDE.md`             | `$HOME/CLAUDE.md` — **not** inside `.claude/` |
| `statusline-command.sh` | `$HOME/.claude/`     |
| `settings.local.json`   | `$HOME/.claude/` (gitignored, absent on a fresh clone) |

Three symlinks, nothing else — deployed by `setup_claude` in
[`lib/claude.sh`](../../scripts/lib/claude.sh) via `make mac-setup` or `make claude-setup`.

## ⚙️ `settings.json` ownership

Claude Code and its installers (`aicodemetricsd`, `claude-island`) write
`~/.claude/settings.json` directly. Marketplace registration happens through the `claude`
CLI — `make claude-plugins` — which owns that file's schema.

## ➕ Adding something

Skill, agent, or MCP doc → [`plugins/batman/`](plugins/batman/README.md). A file goes
directly in *this* dir only when it must live at a fixed `$HOME` path a plugin can't
reach — wire it in `_claude_link_host_files`.

## 📖 Docs

[Overview](https://code.claude.com/docs/en/overview) ·
[Settings](https://code.claude.com/docs/en/settings) ·
[Plugins](https://code.claude.com/docs/en/plugins) ·
[Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
