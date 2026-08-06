# 🔌 mcp

Setup notes for the MCP servers used on this machine. **Documentation only — nothing here is
deployed.** There is deliberately no `.mcp.json`; see [Why docs, not config](#-why-docs-not-config).

---

## 🗂️ Servers

| Doc                                        | Products                 | Transport | Auth                   |
|--------------------------------------------|--------------------------|-----------|------------------------|
| [`github-mcp.md`](./github-mcp.md)         | 🐙 GitHub                 | `stdio`   | PAT via env var        |
| [`gitlab-mcp.md`](./gitlab-mcp.md)         | 🦊 GitLab                 | `http`    | OAuth 2.0 (DCR)        |
| [`atlassian-mcp.md`](./atlassian-mcp.md)   | 🧩 Jira **+** Confluence  | `http`    | OAuth                  |
| [`databricks-mcp.md`](./databricks-mcp.md) | 🧪 Databricks / Unity Catalog | `stdio` | Databricks CLI profile |

> 🧩 **Jira and Confluence are one server.** Atlassian ships a single MCP endpoint covering
> both. Two entries would duplicate every tool schema and double the context cost for zero
> extra capability.

---

## 🧭 Why docs, not config

A committed `.mcp.json` here would be actively harmful:

1. **This repo is public.** Real endpoints are often internal infrastructure. Committing them
   publishes it for no benefit.
2. **The values are per-machine** — which Databricks workspace and CLI profile you want
   differs by task, and there are several of each in `~/.databrickscfg`.
3. **A plugin `.mcp.json` auto-registers on install.** Every listed server would try to
   connect on every session start, including the ones you don't need — each one a timeout or
   an auth prompt.

So: register servers with `claude mcp add` per the docs here, and keep endpoints in
[`.secrets.zsh`](../../../src/dotfiles/zsh/README.md) (gitignored, `chmod 600`).

---

## 🔐 Credential rules

- **Never commit a token, PAT, or client secret** — not in a config, not in these docs, not
  in an example.
- **Never add an `Authorization: Bearer …` header** to an MCP config. Prefer OAuth or a local
  CLI profile so the credential never enters a file at all.
- **Never wire Databricks MCP with a PAT** — see [`databricks-mcp.md`](./databricks-mcp.md).
- If a secret must reach a server, put it in `.secrets.zsh` and pass it as `${VAR}` — never
  inline.

CI enforces the shape of this: any `.mcp.json` under `plugins/` carrying an `Authorization`
header or an inline `token` / `secret` / `password` / `api_key` key fails the build.

---

## ✅ Verify a server

```bash
claude mcp list        # per-server health, without opening a session
claude                 # then /mcp — authorize, inspect tools
```

Then make one **read-only** call as a smoke check.

Troubleshooting: if a server works in MCP Inspector but not here, it's almost always client
config. Compare JSON keys (`mcpServers` vs `servers` — they differ by client) and restart.

---

## 📖 References

- [MCP in Claude Code](https://code.claude.com/docs/en/mcp) · [quickstart](https://code.claude.com/docs/en/mcp-quickstart)
