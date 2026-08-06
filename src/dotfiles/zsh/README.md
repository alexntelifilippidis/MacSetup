# 💻 zsh

Shell config: Oh My Zsh, two custom themes, and the secrets file every other tool
reads its tokens from.

Deployed by [`setup_zsh`](../../scripts/lib/zsh.sh) · `make mac-setup`

---

## 📦 Files

| File                       | Destination                                    | How      |
|----------------------------|------------------------------------------------|----------|
| `.zshrc`                   | `$HOME/.zshrc`                                 | symlink  |
| `themes/kaizen.zsh-theme`  | `$HOME/.oh-my-zsh/custom/themes/`              | symlink  |
| `themes/batman.zsh-theme`  | `$HOME/.oh-my-zsh/custom/themes/`              | symlink  |
| `.secrets.zsh`             | `$HOME/.secrets.zsh`                           | symlink 🔒 |
| `.secrets.zsh.template`    | — (seed source only)                           | —        |

Oh My Zsh itself is installed from upstream on first run and skipped afterwards.

---

## 🔐 Secrets

```text
.secrets.zsh.template   ✅ committed   — placeholder REPLACE_ME values
.secrets.zsh            🚫 gitignored  — real tokens, chmod 600, never pushed
```

On a fresh machine `setup_zsh` seeds `.secrets.zsh` from the template, `chmod 600`s it,
and tells you to fill it in. On every later run it **re-enforces `600` and never
overwrites** your real file.

```bash
# after a fresh setup
$EDITOR src/dotfiles/zsh/.secrets.zsh   # replace every REPLACE_ME
exec zsh                                # reload
```

> ⚠️ Never `echo`, `cat`, or log this file. Never commit it. If a token here ever
> reaches a commit, rotate it — `git rm --cached` is not enough.

What lives here: `ATLASSIAN_*` (used by the `jira-acli` skill), Databricks and
registry tokens, and anything else that must not be in a committed dotfile.

---

## 🎨 Themes

| Theme    | Where it's used                                                |
|----------|----------------------------------------------------------------|
| `kaizen` | 🏢 Work palette — orange/blue, folder + clock segments          |
| `batman` | 🦇 Personal                                                    |

Switch by setting `ZSH_THEME` in `.zshrc`, then `exec zsh`.

---

## ➕ Adding a theme

1. Drop `<name>.zsh-theme` in `themes/`.
2. Add a `symlink_if_changed` line to [`setup_zsh`](../../scripts/lib/zsh.sh).
3. `make mac-setup`, set `ZSH_THEME=<name>`, `exec zsh`.

> 🧹 `.zshrc` is excluded from `shellcheck` and `shfmt` in
> [`.pre-commit-config.yaml`](../../../.pre-commit-config.yaml) — it's zsh, not bash,
> and shellcheck reports false SC2148/SC2034 on zsh arrays and plugin lists.
