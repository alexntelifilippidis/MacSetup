# 🍺 homebrew

One `Brewfile` as the single source of truth for every CLI tool, cask, and App Store
app on the machine.

Deployed by [`setup_homebrew`](../../scripts/lib/homebrew.sh) · `make mac-setup`

---

## 📦 Files

| File       | Destination                          | How     |
|------------|--------------------------------------|---------|
| `Brewfile` | `$HOME/.config/homebrew/Brewfile`    | symlink |

Symlinked to `~/.config/homebrew/` so a **bare `brew bundle`** — no `--file` — works from
any directory. That path pairs with the `HOMEBREW_BUNDLE_FILE` export in
[`.zshrc`](../zsh/.zshrc).

---

## ⚙️ What `setup_homebrew` does

1. 🍺 Installs Homebrew if `brew` isn't on `PATH`, and appends `brew shellenv` to
   `~/.zprofile` — guarded by a `grep`, so re-running never duplicates the block.
2. 🔗 Symlinks the `Brewfile` into `~/.config/homebrew/`.
3. 🤝 `brew trust atlassian/acli` — that tap refuses to install until it's trusted.
4. 📥 `brew bundle check` first; installs only when something is actually missing, so a
   no-op run stays fast and quiet.

---

## 🔧 Everyday use

```bash
make update       # brew update + upgrade + bundle + cleanup
make whats-new    # what's outdated, with GitHub release notes — installs nothing
make doctor       # brew doctor + podman + Claude manifest checks
brew bundle       # bare — resolves via ~/.config/homebrew/Brewfile
```

---

## ➕ Adding a package

Edit `Brewfile` — keep it in the existing commented sections, and **add a trailing
comment for anything non-obvious**:

```ruby
brew "uv"             # Python package manager / runner — replaces pip/venv
cask "pycharm"
mas  "Xcode", id: 497799835
```

Then `make update`.

> ⚠️ **`brew bundle cleanup` uninstalls anything not listed here.** Before running a
> cleanup, add the tools you installed ad-hoc — or lose them. `make update` runs
> `brew cleanup` (cache pruning only), which is the safe one.
