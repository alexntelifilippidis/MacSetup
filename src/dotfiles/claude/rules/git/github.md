# Git — GitHub (Personal)

## Identity

- Username: `alexntelifilippidis`
- Email: `alexntelifilippidis@gmail.com`
- Repos live under: `~/Projects/Personal/`
- Identity auto-applied via `includeIf "gitdir:~/Projects/Personal/"` in `~/.gitconfig`

## CLI

- Use `gh` for all GitHub operations (PRs, issues, releases, checks)
- Never use the GitHub web UI for things `gh` can do

## Workflow

- Default branch: `main`
- PRs (not MRs) — use `gh pr create`
- Read `.github/pull_request_template.md` before opening a PR
- Squash merge preferred for feature branches; merge commit for release branches

## Branch Naming

```
(feature|bugfix|hotfix|chore|docs|release)/<short-description>
```

## PR Rules

- Never force-push to `main`
- Draft PRs for WIP — `gh pr create --draft`
- Request review only when CI is green
- Delete branch after merge

## SSH

- Key: `~/.ssh/id_ed25519_github` (personal)
- Ensure `~/.ssh/config` routes `github.com` to the personal key
