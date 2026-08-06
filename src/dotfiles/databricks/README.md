# 🧪 databricks

Databricks CLI profiles — `$HOME/.databrickscfg`, always `chmod 600`.

Deployed by [`setup_databricks`](../../scripts/lib/databricks.sh) · `make mac-setup`

---

## 📦 Files

| File                     | Git           | Destination            | How        |
|--------------------------|---------------|------------------------|------------|
| `.databrickscfg`         | 🚫 gitignored | `$HOME/.databrickscfg` | symlink 🔒 |
| `.databrickscfg_template`| ✅ committed  | — (copy source only)   | —          |

`setup_databricks` enforces `chmod 600` on the repo-side file **before** symlinking, so
the permissions are right even on a fresh clone.

---

## 🚀 First-time setup

```bash
cp src/dotfiles/databricks/.databrickscfg_template \
   src/dotfiles/databricks/.databrickscfg
chmod 600 src/dotfiles/databricks/.databrickscfg
$EDITOR src/dotfiles/databricks/.databrickscfg   # fill in host + token
make mac-setup
```

---

## 🔑 Auth options

The template covers all three; pick one per profile.

| Method                    | Keys                                                              |
|---------------------------|-------------------------------------------------------------------|
| 🎫 Personal Access Token   | `host`, `token`                                                   |
| 🏢 Azure Service Principal | `azure_tenant_id`, `azure_client_id`, `azure_client_secret`, `auth_type = azure-client-secret` |
| 💻 Databricks CLI OAuth    | `host`, `auth_type = databricks-cli`                              |

---

## ✅ Verify

```bash
databricks --profile DEFAULT current-user me
stat -f "%OLp %N" "$HOME/.databrickscfg"   # must print 600
```

---

## ⚠️ Rules

- **Always pass `--profile <name>` explicitly.** The default profile is whatever was
  configured last — not something a script or pipeline should depend on.
- **Never commit `.databrickscfg`.** It's gitignored *and* `gitleaks` scans for tokens in
  pre-commit; don't rely on only one of those catching you.
- Rotate a token the moment it's been echoed, logged, or pasted anywhere.
- Per-stack conventions for Databricks work live in the `sql-standards` skill in
  [`plugins/batman`](../../../plugins/batman/).
