# 🔌 mcp

Setup notes for the MCP servers used here. Register each via `claude mcp add`, per its
doc below; keep endpoints in [`.secrets.zsh`](../../../../zsh/README.md)
(gitignored, `chmod 600`).

---

## 🗂️ Servers

| Doc                                        | Products                 | Transport | Auth                   |
|--------------------------------------------|--------------------------|-----------|------------------------|
| [`github-mcp.md`](./github-mcp.md)         | 🐙 GitHub                 | `stdio`   | PAT via env var        |
| [`gitlab-mcp.md`](./gitlab-mcp.md)         | 🦊 GitLab                 | `http`    | OAuth 2.0 (DCR)        |
| [`atlassian-mcp.md`](./atlassian-mcp.md)   | 🧩 Jira **+** Confluence  | `http`    | OAuth                  |
| [`databricks-mcp.md`](./databricks-mcp.md) | 🧪 Databricks / Unity Catalog | `stdio` | Databricks CLI profile |

> 🧩 **Jira and Confluence are one server.** Atlassian ships a single MCP endpoint covering
> both.

---

## 🔐 Credential rules

- **Never commit a token, PAT, or client secret** — not in a config, not in these docs, not
  in an example.
- **Never add an `Authorization: Bearer …` header** to an MCP config. Prefer OAuth or a local
  CLI profile so the credential never enters a file at all.
- **Never wire Databricks MCP with a PAT** — see [`databricks-mcp.md`](./databricks-mcp.md).
- If a secret must reach a server, put it in `.secrets.zsh` and pass it as `${VAR}`.

CI checks the shape of this: any `.mcp.json` under `src/dotfiles/claude/plugins/` carrying
an `Authorization` header or an inline `token` / `secret` / `password` / `api_key` key fails
the build.

---

## ✅ Verify a server

```bash
claude mcp list        # per-server health, without opening a session
claude                 # then /mcp — authorize, inspect tools
```

Then make one **read-only** call as a smoke check.

Troubleshooting: if a server works in MCP Inspector but not here, compare JSON keys
(`mcpServers` vs `servers` — they differ by client) and restart.

---

## 📖 References

- [MCP in Claude Code](https://code.claude.com/docs/en/mcp) · [quickstart](https://code.claude.com/docs/en/mcp-quickstart)
