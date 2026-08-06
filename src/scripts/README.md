# ⚙️ scripts

How things get deployed. `src/dotfiles/` is *what* gets deployed — this is the *how*.

---

## 📂 Layout

```text
scripts/
├── setup.sh          # 🎼 orchestrator — the only file that calls setup_* in order
├── setup_podman.sh   # 🐋 standalone: podman machine + registry mirror
├── whats_new.sh      # 📰 standalone: outdated brew packages + release notes
└── lib/              # 🧱 the setup_* modules — see lib/README.md
```

---

## 🎼 `setup.sh` — pure orchestrator

No logic lives here. It:

1. Derives and **exports `REPO_ROOT`** from `BASH_SOURCE[0]` — so it runs correctly from
   any working directory.
2. Sources every `lib/*.sh` module.
3. Calls each `setup_*` function in dependency order:

```text
setup_homebrew  🍺  →  brew + Brewfile          (first: everything else needs the tools)
setup_zsh       💻  →  Oh My Zsh, themes, secrets
setup_databricks🧪  →  .databrickscfg (chmod 600)
setup_git       🌿  →  .gitconfig + identity includes
setup_podman    🐋  →  machine + Docker Hub mirror
setup_claude    🦇  →  CLAUDE.md, statusline, settings keys, batcave marketplace
```

Order matters: `setup_homebrew` installs `jq`, `shellcheck`, and the `claude` CLI that
later modules depend on.

Run it with `make mac-setup` — never `bash setup.sh` from inside `src/scripts/`
(it works, but `make` is the documented entry point and the one CI mirrors).

---

## 🎯 Standalone entry points

Both are safe to run on their own and are also reachable via `make`:

| Script             | Target            | What it does                                        |
|--------------------|-------------------|-----------------------------------------------------|
| `setup_podman.sh`  | `make podman-setup` | Init/start the Podman machine, append the registry mirror inside the VM (backed up, deduped) |
| `whats_new.sh`     | `make whats-new`  | Lists outdated brew packages + GitHub release notes. **Installs nothing.** |

---

## 📐 Rules for anything in here

- 🔁 **Idempotent.** Every script must be safe to re-run — compare before mutating.
  All file deployment goes through `copy_if_changed` / `symlink_if_changed`.
- 🏠 **`$HOME`, never `~`.** `~` doesn't expand inside quotes.
- 📍 **`$REPO_ROOT`-relative paths, never `$(pwd)`.**
- 🧹 `shellcheck -x --severity=warning` and `shfmt -i 2 -ci -sr` clean —
  `make lint`, `make fmt`, and `pre-commit run --all-files` all enforce it.
- ➕ **Adding a script needs no Makefile edit** — `SHELL_SCRIPTS` in the
  [`Makefile`](../../Makefile) discovers `*.sh` under `src/scripts` and `plugins` via `find`.

See [`lib/README.md`](lib/README.md) for how to add a new `setup_*` module.
