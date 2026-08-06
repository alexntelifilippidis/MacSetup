<!--
Why this template exists:
  Keeps PRs consistent with the same conventional-commit + branch-naming rules
  enforced in `.github/workflows/ci.yml` and the GitLab CI at work, so muscle
  memory transfers between repos.
  Delete sections that don't apply — do not leave empty headings.
-->

## 📌 Summary

<!-- One-line description of WHAT this PR does and WHY. Imperative mood.
     Example: "Gate podman stop/start on config sha256 to speed up re-runs." -->

## 🔗 Context

<!-- Link to the ticket, Slack thread, or issue. Use NOJIRA if none. -->

- Ticket: `PROJ-___` / `NOJIRA`
- Related MRs / issues:

## 🧩 Type of change

<!-- Tick all that apply. Must match the commit type prefix. -->

- [ ] ✨ `feat` — new feature
- [ ] 🐛 `fix` — bug fix
- [ ] 🔧 `chore` — tooling / deps / build
- [ ] 🤖 `ci` — CI/CD pipeline
- [ ] 📚 `docs` — documentation only
- [ ] 🚀 `perf` — performance improvement
- [ ] 🛠️ `refactor` — no behaviour change
- [ ] ⏪ `revert` — revert a previous commit
- [ ] 💅 `style` — formatting only
- [ ] 🧪 `test` — adding / updating tests

## 🧠 What changed

<!-- Bullet the concrete changes. Reviewer should skim this and know what to look for. -->

-
-

## 🧪 How was this tested?

<!-- Commands run, manual steps, or CI evidence. -->

```bash
# e.g.
make lint
pre-commit run --all-files
./setup.sh    # idempotent re-run, no diff expected
```

## 🚨 Risk & rollback

<!-- What breaks if this PR is bad? How to revert safely? -->

- Blast radius:
- Rollback plan: `git revert <sha>` / re-run previous `setup.sh`

## ✅ Checklist

- [ ] Branch name matches `^((feature|bugfix|hotfix|release|chore|config)/.+|main|master)$` (the actual check in `ci.yml`)
- [ ] PR title is a valid conventional commit (`feat(scope): ...`)
- [ ] `pre-commit run --all-files` passes locally
- [ ] `make lint` passes (shellcheck clean)
- [ ] No secrets, tokens, or real `.databrickscfg` values committed
- [ ] Docs / README updated if behaviour changed
- [ ] Script changes are **idempotent** (safe to re-run)

## 📸 Screenshots / terminal output

<!-- Optional. Drag-and-drop an image or paste a code block. -->
