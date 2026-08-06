# 🧱 lib

Self-contained setup modules sourced by [`setup.sh`](../setup.sh). One module per tool,
each exposing exactly one `setup_*` function.

---

## 📚 Modules

| Module            | Exposes            | What it deploys                                                                 |
|-------------------|--------------------|---------------------------------------------------------------------------------|
| 🍺 `homebrew.sh`  | `setup_homebrew`   | Homebrew itself, `shellenv` in `.zprofile`, `Brewfile` → `~/.config/homebrew/`   |
| 💻 `zsh.sh`       | `setup_zsh`        | Oh My Zsh, `kaizen`/`batman` themes, `.zshrc`, `.secrets.zsh` (seeded, `chmod 600`) |
| 🖥️ `iterm.sh`     | `setup_iterm`      | iTerm2 Dynamic Profiles (Batman + Default) → `~/Library/Application Support/iTerm2/DynamicProfiles/` |
| 🧪 `databricks.sh`| `setup_databricks` | `.databrickscfg` → `$HOME` (`chmod 600` first)                                  |
| 🌿 `git.sh`       | `setup_git`        | `.gitconfig` + work/personal identity includes                                  |
| 🐋 `podman.sh`    | `setup_podman`     | Podman machine + Docker Hub registry mirror                                     |
| 🦇 `claude.sh`    | `setup_claude`     | `CLAUDE.md`, statusline, merged `settings.json` keys, `batcave` marketplace      |

### 🔩 Shared, no `setup_*`

| Module        | Provides                                                                    |
|---------------|-----------------------------------------------------------------------------|
| `helpers.sh`  | `section`, **`copy_if_changed`**, **`symlink_if_changed`**                   |
| `colors.sh`   | `GREEN` `YELLOW` `BLUE` `CYAN` `MAGENTA` `RED` `DIM` `BOLD` `RESET` `SEP`    |

> 🔑 `copy_if_changed` and `symlink_if_changed` are the **only** deployment primitives.
> Never inline a `cp` or `ln` in a module — those two print consistent
> `✅ Updated` / `⏭️ No changes` output and are what make a re-run idempotent and quiet.

---

## 🧩 The self-contained contract

Every module sources its own dependencies and derives its own `REPO_ROOT` fallback:

```bash
#!/bin/bash
# shellcheck source=./helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
```

Why it's written this way:

- 🧪 **Testable in isolation** — `source lib/podman.sh && setup_podman` works without
  `setup.sh` having run first.
- 📍 **`BASH_SOURCE[0]`, not `$0`** — `$0` is the *calling* script when sourced, so it
  would resolve to the wrong directory.
- 🔗 **`${REPO_ROOT:-…}`** — honours the value `setup.sh` exports, falls back when the
  module is sourced directly.

---

## ➕ Adding a module

```bash
# 1. create lib/<tool>.sh with the header above + one setup_<tool>() function
# 2. wire it into setup.sh — source it, then call it in dependency order
# 3. add a small README to src/dotfiles/<tool>/ and link it from the root README index
make fmt && make lint && pre-commit run --all-files
```

Checklist for the function itself:

- [ ] 🔁 Idempotent — a second run prints only `⏭️ No changes`
- [ ] 📢 Opens with `section "<emoji>" "<Title>" "$COLOR"`
- [ ] 🔑 Uses `copy_if_changed` / `symlink_if_changed` — no bare `cp`/`ln`
- [ ] 📍 `$REPO_ROOT`-relative paths, `$HOME` not `~`, no `$(pwd)`
- [ ] 🛡️ Missing optional input warns and returns `0`; it never aborts the whole setup
- [ ] 🧹 `shellcheck -x --severity=warning` and `shfmt -i 2 -ci -sr` clean
