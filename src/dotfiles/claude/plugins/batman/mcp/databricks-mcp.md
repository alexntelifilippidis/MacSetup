# 🧪 Databricks MCP

Databricks exposes MCP endpoints **on the workspace** — managed servers, Genie, Unity Catalog
functions. The exact path depends on which server you want.

---

## 🚨 No Personal Access Tokens

**Never wire Databricks MCP with a PAT.** No Bearer-token header, and no
`mcp-remote` + `DATABRICKS_TOKEN`. A PAT in an MCP config is a long-lived credential sitting
in a file that gets copied, backed up and synced — and it can't be scoped down to read-only.

Use one of these instead:

| Method | When |
|--------|------|
| **`uc-mcp-proxy`** + Databricks CLI (`stdio`) | **Default here.** No extra checkout to maintain. |
| [**ai-dev-kit**](https://github.com/databricks-solutions/ai-dev-kit) `run_server.py` (`stdio`) | When you also want the kit's Databricks skills on the same vendor-supported path |
| **OAuth** | Only when the client requires HTTP MCP; needs an OAuth app registered |

All three keep credentials in your **Databricks CLI profile** (`~/.databrickscfg`,
`chmod 600`) — never in a JSON config.

---

## ✅ Setup — `uc-mcp-proxy`

```bash
# in src/dotfiles/zsh/.secrets.zsh (gitignored) — the workspace host is internal
# infrastructure and this repo is public, so it does not get committed.
export DATABRICKS_MCP_URL="https://<workspace-host>/api/2.0/mcp/functions/system/ai"
export DATABRICKS_CONFIG_PROFILE="<profile-from-.databrickscfg>"
```

```bash
databricks auth login --profile "$DATABRICKS_CONFIG_PROFILE"

claude mcp add databricks -- uvx uc-mcp-proxy \
  --url "$DATABRICKS_MCP_URL" \
  --auth-type databricks-cli \
  --profile "$DATABRICKS_CONFIG_PROFILE"
```

Prerequisites: `uv` and the `databricks` CLI — both in the
[Brewfile](../../../../homebrew/Brewfile).

> ⚠️ **Expand the values, don't pass `${VAR}` literally.** A plugin `.mcp.json` with an
> unset `${DATABRICKS_MCP_URL}` expands to an empty `--url` and the server hangs until it
> is killed:
>
> ```text
> ✘ Failed to connect — connection timed out after 30000ms
> ```
>
> Verified failure mode. If a Databricks MCP server times out, check the URL resolved before
> anything else.

---

## 🗂️ Picking a profile

`~/.databrickscfg` holds several profiles across more than one workspace (dev/stg/prd,
SPN and user). The URL host and the profile **must be the same workspace** — a mismatch
authenticates fine and then 404s on every call.

```bash
grep -o '^\[.*\]' "$HOME/.databrickscfg"    # profile names only, never the tokens
databricks auth describe --profile <name>   # confirm host + identity
```

---

## ✅ Smoke check

One authenticated read-only action — a Unity Catalog metadata or catalog-list call.

```bash
claude mcp list      # expect: ✔ Connected
```

---

## 🔧 Troubleshooting

| Symptom | Cause |
|---------|-------|
| `connection timed out` | `--url` empty or unreachable — check the env var expanded |
| 404 on every call | URL host and CLI profile are different workspaces |
| auth failures | stale login — re-run `databricks auth login --profile <name>` |
| works in Inspector, not here | client config; compare JSON keys and restart Claude Code |

If the workspace uses IP access lists, your egress IP needs allowlisting.

---

## 📖 References

- [Connect non-Databricks clients to Databricks MCP servers](https://learn.microsoft.com/en-us/azure/databricks/generative-ai/mcp/connect-external-services)
- [Databricks managed MCP servers](https://learn.microsoft.com/en-us/azure/databricks/generative-ai/mcp/managed-mcp)
- [Databricks AI Development Kit](https://github.com/databricks-solutions/ai-dev-kit)
- CLI profiles: [`src/dotfiles/databricks/`](../../../../databricks/README.md)
