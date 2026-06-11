# Git — GitHub (Personal)

## Identity

- Username: `<github-username>` — set in `~/.gitconfig` or `~/.claude/settings.local.json`
- Email: `<personal-email>` — set in `~/.gitconfig` or `~/.claude/settings.local.json`
- Repos live under: `~/Projects/Personal/`
- Identity auto-applied via `includeIf "gitdir:~/Projects/Personal/"` in `~/.gitconfig`

## CLI

- Use `gh` for all GitHub operations (PRs, issues, releases, checks)
- Never use the GitHub web UI for things `gh` can do

## Authentication

Never ask the user for a token. Retrieve from git-credential-manager and pass inline — never print, echo, or store the token in a visible variable:

```bash
GH_TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill | awk -F= '/^password/{print $2}') gh <command>
```

**Before overriding with a fetched token:** check whether `GH_TOKEN` (or `GITHUB_TOKEN`) is already set in the environment — if it is, skip the credential-manager lookup and use it directly. Overriding a valid env token with a credential-manager fetch will cause auth failures.

**To find the correct hostname** for credential lookup when auth fails, inspect the remote URL first:

```bash
git remote get-url origin
# e.g. https://github.com/... → use host=github.com
```

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

## Creating a PR

When the user says "create pr":

1. Retrieve the `GH_TOKEN` from git-credential-manager (see Authentication above)
2. Read the PR template from the repo: `.github/pull_request_template.md`
3. Fill **every section** of the template from the diff — no placeholder text, no empty headings, no skipped checklist items; delete sections marked optional if not applicable
4. Run `GH_TOKEN=$GH_TOKEN gh pr create --title "..." --body "..."`

## SSH

- Key: `~/.ssh/id_ed25519_github` (personal)
- Ensure `~/.ssh/config` routes `github.com` to the personal key
