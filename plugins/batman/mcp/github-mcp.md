# 🐙 GitHub MCP

Official server: [`github/github-mcp-server`](https://github.com/github/github-mcp-server).

---

## ⚠️ The remote server does not work in Claude Code

GitHub's hosted endpoint `https://api.githubcopilot.com/mcp/` **cannot be used from Claude
Code.** Verified failure:

```text
plugin:batman:github: https://api.githubcopilot.com/mcp/ (HTTP)
  ✘ Failed to connect — Incompatible auth server: does not support dynamic client registration
```

Claude Code obtains OAuth credentials via **dynamic client registration (DCR)**. GitHub's
MCP auth server doesn't support DCR — it expects a pre-registered client ID, which is why
the same URL works in VS Code and Copilot but not here.

**Do not** file this as a config bug. It's a server-side capability gap.

---

## ✅ Option A — local server (works)

Run GitHub's server locally over `stdio`. Needs a PAT, so the token goes in
`.secrets.zsh`, never in JSON.

```bash
# in src/dotfiles/zsh/.secrets.zsh (gitignored, chmod 600)
export GITHUB_MCP_PAT="ghp_..."           # fine-grained, least privilege
```

```bash
claude mcp add github \
  --env GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_MCP_PAT" \
  --env GITHUB_TOOLSETS="repos,issues,pull_requests" \
  -- podman run -i --rm \
       -e GITHUB_PERSONAL_ACCESS_TOKEN \
       -e GITHUB_TOOLSETS \
       ghcr.io/github/github-mcp-server
```

- **Scope the PAT down.** Fine-grained token, only the repos you need, read-only unless you
  actually want the agent opening PRs.
- **Scope the toolsets down** with `GITHUB_TOOLSETS` — the full set is large and every tool
  schema costs context on every session.
- Podman, not Docker (see [`src/dotfiles/podman/`](../../../src/dotfiles/podman/README.md)).
- Rotate the PAT if it is ever echoed, logged, or pasted anywhere.

---

## ✅ Option B — skip MCP, use `gh` (recommended)

For most work an MCP server buys nothing over the `gh` CLI, which is already installed,
already authenticated through **git-credential-manager**, and needs **no PAT of its own**:

```bash
GH_TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill \
  | sed -n 's/^password=//p') gh <command>
```

Use `sed -n 's/^password=//p'` here, not `awk -F= '{print $2}'` — the latter splits on
every `=` and truncates any token that happens to contain one.

This is the pattern the personal GitHub workflow already mandates — no long-lived token in
an env var, nothing to rotate, nothing to leak. Prefer it unless you specifically need
GitHub tools available to a subagent that can't shell out.

---

## 📖 References

- [github/github-mcp-server](https://github.com/github/github-mcp-server)
- [Using the GitHub MCP server](https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp/use-the-github-mcp-server)
