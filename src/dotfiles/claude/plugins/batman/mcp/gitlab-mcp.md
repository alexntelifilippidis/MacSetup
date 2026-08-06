# 🦊 GitLab MCP

GitLab's own server, built into the instance. **Beta** since GitLab 18.6.

---

## 🔗 Endpoint

| Instance     | URL                                     |
|--------------|-----------------------------------------|
| GitLab.com   | `https://gitlab.com/api/v4/mcp`         |
| Self-managed | `https://<your-host>/api/v4/mcp`        |

Work repos here are on **gitlab.com** (SaaS) — confirm with
`git remote get-url origin` rather than assuming.

---

## ✅ Setup

```bash
claude mcp add --transport http gitlab https://gitlab.com/api/v4/mcp
```

Then in a session: `/mcp` → select `gitlab` → approve in the browser.

**Auth is OAuth 2.0 with dynamic client registration** — it happens automatically on first
connect. There is **no token to create, store, or rotate**. Do not add a PAT.

---

## 📋 Prerequisites

- **GitLab Duo** set to *Always on* or *On by default*
- Beta/experimental features enabled for your scope
- MCP server access allowed at the group or instance level

If any of those is off, the connection reports *needs authentication* and the OAuth flow
fails at the end. Ask the GitLab admin rather than retrying.

---

## 🧭 Is it worth it?

`glab` already covers MRs, issues, pipelines and CI, authenticated through
git-credential-manager with no long-lived token:

```bash
GITLAB_TOKEN=$(printf "protocol=https\nhost=gitlab.com\n" | git credential fill \
  | sed -n 's/^password=//p') glab <command>
```

Use `sed -n 's/^password=//p'` here, not `awk -F= '{print $2}'` — the latter splits on
every `=` and truncates any token that happens to contain one.

Add the MCP server when you want GitLab context available to a subagent that can't shell
out; otherwise `glab` is fewer moving parts and one less thing to authorize.

---

## 📖 References

- [GitLab MCP server](https://docs.gitlab.com/user/model_context_protocol/mcp_server/)
