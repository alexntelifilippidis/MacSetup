# 🦇 batman

The one plugin of the [`batcave`](../../.claude-plugin/marketplace.json) marketplace.

---

## 📦 Contents

| Kind        | Status                                                              |
|-------------|---------------------------------------------------------------------|
| 🔌 **mcp**   | [Setup docs](./mcp/README.md) for GitHub · GitLab · Jira+Confluence · Databricks — **docs only, nothing deployed** |
| 🧠 **skills**| `mr-pr-creator` · `jira-ticket-creator` · `confluence-page-creator` — see [below](#-skills) |
| 🤖 **agents**| *(none yet)*                                                        |

No `commands/` and no `hooks/`, deliberately:

- Claude Code already exposes a skill as `/batman:<name>`, so a `commands/` dir would split
  one concept across two folders.
- `pre-commit` already runs the `shellcheck` + `shfmt` that a validation hook would
  duplicate, just later and without blocking mid-edit.

---

## 📥 Install

From this repo (local, tracks the working copy — a `git pull` updates the live assets):

```bash
make claude-plugins
```

From GitHub, on any machine:

```bash
claude plugin marketplace add alexntelifilippidis/MacSetup
claude plugin install batman@batcave
```

Restart Claude Code, then verify:

```bash
claude plugin details batman     # component inventory + token cost
make claude-validate             # manifests parse and agree
```

---

## 🧠 Skills

| Skill                      | Fires when                                                              |
|----------------------------|--------------------------------------------------------------------------|
| `mr-pr-creator`            | Creating a PR/MR — detects GitHub vs GitLab from the remote, branches with the right naming convention, writes conventional commits, resolves the token from git-credential-manager, fills the repo's template from the diff |
| `jira-ticket-creator`      | Drafting a Jira ticket — Overview / Business Value / Background / Technical Work / Acceptance Criteria, created via the Atlassian MCP or `acli` |
| `confluence-page-creator`  | Publishing a Confluence page from notes or a ticket — via the Atlassian MCP or the REST API, into a confirmed space + parent page |

`mr-pr-creator` and `jira-ticket-creator` chain together for "start ticket → open MR" —
the MR skill comments the URL back onto the ticket and transitions it via the Jira one.

---

## 🔌 MCP

[`mcp/`](./mcp/README.md) holds setup notes only — there is **no `.mcp.json`**, on purpose:

1. **This repo is public.** Real Atlassian and Databricks endpoints are internal
   infrastructure.
2. **The values are per-machine** — several Databricks workspaces and profiles.
3. **A plugin `.mcp.json` auto-registers on install**, so every server would try to connect
   on every session start, including ones you don't need.

Register servers with `claude mcp add` per the docs; keep endpoints in
[`.secrets.zsh`](../../src/dotfiles/zsh/README.md).

| Doc                                        | Products                | Notes                                     |
|--------------------------------------------|-------------------------|-------------------------------------------|
| [`github-mcp.md`](./mcp/github-mcp.md)     | 🐙 GitHub                | ⚠️ remote endpoint **can't** work in Claude Code — no DCR |
| [`gitlab-mcp.md`](./mcp/gitlab-mcp.md)     | 🦊 GitLab                | OAuth, no token to store                  |
| [`atlassian-mcp.md`](./mcp/atlassian-mcp.md)| 🧩 Jira **+** Confluence | one server covers both                    |
| [`databricks-mcp.md`](./mcp/databricks-mcp.md)| 🧪 Databricks         | 🚨 PATs not permitted — CLI-backed only    |

---

## ➕ Adding to this plugin

| Adding a… | Goes in                  | Needs                                       |
|-----------|--------------------------|---------------------------------------------|
| Skill     | `skills/<name>/SKILL.md` | `name` + `description` frontmatter          |
| Agent     | `agents/<name>.md`       | `name` + `description` frontmatter          |
| MCP note  | `mcp/<name>-mcp.md`      | no endpoints, no tokens — this repo is public |

For a skill, **the `description` is the only thing Claude sees when deciding whether to load
it** — write it as trigger conditions ("Use when writing or reviewing `.tf` files…"), not as
a topic label.

Then bump `version` in [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) and:

```bash
make claude-validate
claude plugin update batman
```

---

## 🚫 What is *not* here

Host-level Claude config can't live in a plugin and stays in
[`src/dotfiles/claude/`](../../src/dotfiles/claude/):

- `CLAUDE.md` → `$HOME/CLAUDE.md` — persona and always-on principles
- `statusline-command.sh` → `$HOME/.claude/`
- `settings.local.json` → `$HOME/.claude/` (gitignored)

The repo does **not** manage `~/.claude/settings.json` at all — Claude Code and external
installers write to it, so a setup script that merges or replaces it can only break a
working install.

---

## 📖 References

- [Plugins](https://code.claude.com/docs/en/plugins) · [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Skills](https://code.claude.com/docs/en/skills) · [Subagents](https://code.claude.com/docs/en/sub-agents) · [MCP](https://code.claude.com/docs/en/mcp)
