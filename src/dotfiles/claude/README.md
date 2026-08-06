# Claude Code — Host Config

Only the config Claude Code reads directly and that **cannot live in a plugin**.
Skills, agents, commands and hooks are not here — they ship as the `batman` plugin of
the `batcave` marketplace under [`plugins/batman/`](../../../plugins/batman/).

## Contents

| File                    | Destination                   | How        | Notes                                              |
|-------------------------|-------------------------------|------------|----------------------------------------------------|
| `CLAUDE.md`             | `$HOME/CLAUDE.md`             | symlink    | Global instruction root — **not** inside `.claude/` |
| `statusline-command.sh` | `$HOME/.claude/`              | symlink    | Stable path referenced by `settings.json`           |
| `settings.local.json`   | `$HOME/.claude/`              | symlink    | Gitignored — machine-specific, absent on a fresh clone |
| `settings.json`         | `$HOME/.claude/settings.json` | **merged** | A fragment. See below.                             |

Deployed by `setup_claude` in [`src/scripts/lib/claude.sh`](../../scripts/lib/claude.sh),
via `make mac-setup` or `make claude-setup`.

## `settings.json` is a fragment, not a file

It holds only the keys this repo owns:

| Key                       | Why it's here                                          |
|---------------------------|--------------------------------------------------------|
| `theme`                   | Personal preference, worth version-controlling         |
| `statusLine`              | Points at the symlinked `statusline-command.sh`        |
| `extraKnownMarketplaces`  | Registers `batcave` from this working copy             |
| `enabledPlugins`          | Enables `batman@batcave`                               |

`setup_claude` deep-merges it into the live file with `jq` (`$live * $managed`), so every
other key survives. **It is never symlinked or copied over the live file** — Claude Code
writes to `~/.claude/settings.json` itself (`model`, `/config`, plugin state), and so do
external installers like `aicodemetricsd`. Replacing that file would silently delete their
hook registrations, and the failure is invisible until you notice telemetry stopped.

Two consequences to keep in mind when editing the fragment:

- **No arrays.** `jq`'s `*` operator merges objects recursively but *replaces* arrays.
  A `hooks` key here would wipe the live hook list.
- **`$HOME` and `$REPO_ROOT` are expanded at deploy time**, so the committed file holds
  no machine-specific absolute paths. Write them literally.

## Adding a Claude asset

If it's a skill, agent, command, or hook → it belongs in
[`plugins/batman/`](../../../plugins/batman/), not here. Only add a file to this
directory if Claude Code reads it from a fixed path in `$HOME` and a plugin cannot
provide it — and then wire it explicitly in `_claude_link_host_files`. There is no
`find` loop any more, deliberately: the previous version symlinked *every* file under
this directory into `~/.claude/`, which is how `settings.json` got in scope in the
first place.

## Docs

- [Claude Code overview](https://code.claude.com/docs/en/overview)
- [Settings reference](https://code.claude.com/docs/en/settings)
- [Plugins](https://code.claude.com/docs/en/plugins) · [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Skills](https://code.claude.com/docs/en/skills) · [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Hooks](https://code.claude.com/docs/en/hooks) · [Status line](https://code.claude.com/docs/en/statusline)
