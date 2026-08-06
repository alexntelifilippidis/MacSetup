# 🌿 git

Two Git identities on one machine — **work** and **personal** — switched automatically by
which directory a repo lives in. No per-repo `git config` ever needed.

Deployed by [`setup_git`](../../scripts/lib/git.sh) · `make mac-setup`

---

## 📦 Files

| File                 | Destination                          | Identity                              |
|----------------------|--------------------------------------|---------------------------------------|
| `.gitconfig`         | `$HOME/.gitconfig`                   | Global — includes + credential helper |
| `.gitconfig-work`    | `$HOME/Projects/Work/.gitconfig`     | 🏢 Work                                |
| `.gitconfig-personal`| `$HOME/Projects/Personal/.gitconfig` | 🏠 GitHub personal                     |

All three are **copied** (not symlinked) — `setup_git` creates
`$HOME/Projects/{Work,Personal}` first so a fresh machine has somewhere to put them.

---

## 🔀 How the identity switch works

```ini
# ~/.gitconfig
[user]                                        # ← fallback, MUST come first
    name = work-username
    email = work@example.com

[includeIf "gitdir:~/Projects/Work/"]         # ← wins inside ~/Projects/Work/
    path = ~/Projects/Work/.gitconfig

[includeIf "gitdir:~/Projects/Personal/"]     # ← wins inside ~/Projects/Personal/
    path = ~/Projects/Personal/.gitconfig
```

> ⚠️ **Order is load-bearing.** Git resolves a key by *last value wins*, and an
> `includeIf` is expanded at the position it appears. A bare `[user]` block placed
> **after** the includes silently overrides both of them — every personal commit then
> gets the work email, with no warning. Keep the fallback at the top.

Verify which file actually won:

```bash
cd ~/Projects/Personal/<repo> && git config --show-origin user.email
# → file:/Users/…/Projects/Personal/.gitconfig  alexntelifilippidis@gmail.com
```

---

## 🔐 Credentials

```ini
[credential]
	helper =                                              # reset inherited helpers
	helper = /usr/local/share/gcm-core/git-credential-manager
[credential "https://dev.azure.com"]
	useHttpPath = true                                    # Azure DevOps needs per-repo paths
```

- The empty `helper =` clears anything inherited from a system config before setting ours.
- Tokens live in **git-credential-manager**, never in a dotfile. Retrieve them inline —
  see the `github-workflow` / `gitlab-workflow` skills in
  [`plugins/batman`](../../../plugins/batman/).

---

## ➕ Adding an identity

1. Add `.gitconfig-<context>` here with just a `[user]` block.
2. Add an `includeIf "gitdir:~/Projects/<Context>/"` to `.gitconfig` — **below** the
   fallback `[user]`.
3. Add a `copy_if_changed` line to [`setup_git`](../../scripts/lib/git.sh).
4. `make mac-setup`, then confirm with `git config --show-origin user.email`.
