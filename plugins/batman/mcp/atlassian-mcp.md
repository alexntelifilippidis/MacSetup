# 🧩 Atlassian MCP — Jira + Confluence

**One server covers both.** Atlassian ships a single MCP endpoint spanning Jira, Confluence,
Bitbucket and JSM. Registering "jira" and "confluence" separately would duplicate every tool
schema and double the context cost for zero extra capability.

---

## 🔗 Endpoints

| Endpoint                                  | When                                         |
|-------------------------------------------|----------------------------------------------|
| `https://mcp.atlassian.com/v1/mcp/authv2` | Atlassian Cloud sites you own                |
| A self-hosted gateway                     | Any org that fronts Atlassian with its own MCP gateway |

> 🔒 **No org-specific hostname is recorded here — this repo is public.** If your Atlassian
> access goes through an internal gateway, get its URL from `claude mcp list` on an already
> configured machine and keep it in
> [`.secrets.zsh`](../../../src/dotfiles/zsh/README.md) as `ATLASSIAN_MCP_URL`.

Where an employer mandates a specific gateway, use that one — not the public endpoint.

---

## ✅ Setup

```bash
# ATLASSIAN_MCP_URL comes from .secrets.zsh; falls back to Atlassian Cloud
claude mcp add --transport http atlassian \
  "${ATLASSIAN_MCP_URL:-https://mcp.atlassian.com/v1/mcp/authv2}"
```

Then `/mcp` → select `atlassian` → approve in the browser. **OAuth — no token to store.**

> ℹ️ A connector configured in Claude Desktop or on claude.ai is **separate**. It shows up in
> `claude mcp list` prefixed `claude.ai …`, and having it connected there does *not* register
> it for Claude Code.

---

## 🧭 vs. `acli`

`acli` is already installed and authenticated from `ATLASSIAN_*` env vars in `.zshrc`, and
covers the common path — view a ticket, transition it, comment a link:

```bash
acli jira workitem view ABC-123
acli jira workitem transition ABC-123 "In Progress"
```

MCP is worth adding when you want Confluence **page** operations or richer Jira search
available to a subagent. For ticket-shaped work, `acli` is fewer moving parts.

---

## 🚫 Data rules

- **Never** put customer identifiers, identity/KYC records, screening hits, risk scores or
  case files into a Jira issue or Confluence page — via MCP or by hand.
- Mask or pseudonymize any customer ID, username, email or phone number before it reaches a
  ticket or page.
- Publishing content sourced from a private conversation into a shared space needs the
  participants' consent first.
- Never echo `ATLASSIAN_API_TOKEN`.

---

## 📖 References

- [Atlassian Rovo MCP server](https://support.atlassian.com/rovo/docs/getting-started-with-the-atlassian-remote-mcp-server/)
