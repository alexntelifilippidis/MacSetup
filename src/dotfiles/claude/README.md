# Claude Code Configuration

Files in this directory are symlinked into `$HOME/.claude/` by `make mac-setup`.

| File | Symlink target | Purpose |
|---|---|---|
| `CLAUDE.md` | `$HOME/CLAUDE.md` | Global instructions loaded into every session |
| `settings.json` | `$HOME/.claude/settings.json` | Hooks, theme, status line config |
| `statusline-command.sh` | `$HOME/.claude/statusline-command.sh` | Custom two-row status line script |

## Documentation

- [Claude Code overview](https://docs.anthropic.com/en/docs/claude-code)
- [Settings reference](https://docs.anthropic.com/en/docs/claude-code/settings)
- [Hooks reference](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Status line](https://docs.anthropic.com/en/docs/claude-code/status-line)
