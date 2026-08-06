# 🦇 batman

The one plugin of the [`batcave`](../../.claude-plugin/marketplace.json) marketplace.

---

## 📦 Contents

| Kind        | Status                                                              |
|-------------|---------------------------------------------------------------------|
| 🔌 **mcp**   | [Setup docs](./mcp/README.md) for GitHub · GitLab · Jira+Confluence · Databricks — **docs only, nothing deployed** |
| 🧠 **skills**| `mr-pr-creator` · `jira-ticket-creator` · `confluence-page-creator` — see [below](#-skills) |
| 🤖 **agents**| *(none yet)*                                                        |

Every skill is also invocable directly as `/batman:<name>`.

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

Servers register through `claude mcp add`, per the setup doc for each — endpoints live in
[`.secrets.zsh`](../../../zsh/README.md). See [`mcp/README.md`](./mcp/README.md) for the
full picture.

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

## 📍 Host config

One level up, in [`src/dotfiles/claude/`](../../README.md) itself:

- `../../CLAUDE.md` → `$HOME/CLAUDE.md`
- `../../statusline-command.sh` → `$HOME/.claude/`
- `../../settings.local.json` → `$HOME/.claude/` (gitignored)

`~/.claude/settings.json` is owned by Claude Code and `make claude-plugins` — see
[details](../../README.md#-settingsjson-ownership).

---

## 📖 References

- [Plugins](https://code.claude.com/docs/en/plugins) · [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Skills](https://code.claude.com/docs/en/skills) · [Subagents](https://code.claude.com/docs/en/sub-agents) · [MCP](https://code.claude.com/docs/en/mcp)
