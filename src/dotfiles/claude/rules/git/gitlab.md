# Git — GitLab (KaizenGaming / Work)

## Identity

- Username: `a.ntelifilippidis`
- Email: `a.ntelifilippidis@kaizengaming.com`
- Repos live under: `~/Projects/Work/`
- Identity auto-applied via `includeIf "gitdir:~/Projects/Work/"` in `~/.gitconfig`

## CLI

- Use `glab` for all GitLab operations (MRs, issues, pipelines, CI)
- Never use the GitLab web UI for things `glab` can do

## Workflow

- Default branch: `main` or `master` (check per repo)
- **Merge Requests** (not PRs) — use `glab mr create`
- At least 1 approval required before merge
- Rebase merge preferred — keeps linear history

## Git Conventions

### Branch Naming

CI pattern: `^(feature|bugfix|hotfix|release|chore|config)/([A-Z]+-\d+|NOJIRA)-.*`

- Work repos (`~/Projects/Work/`): `<type>/<TICKET>-<desc>` or `<type>/NOJIRA-<desc>`
- Non-work repos: `<type>/<desc>`

```bash
# work — with ticket
git checkout -b feature/KAI-123-add-login-flow

# work — no ticket
git checkout -b chore/NOJIRA-update-deps

# non-work
git checkout -b feature/add-login-flow
```

Types: `feature` | `bugfix` | `hotfix` | `release` | `chore` | `config`

### Commits

Conventional commits, imperative mood, **no ticket in the commit message**:

```
type(scope): what it does
```

- Keep messages straightforward and to the point
- The ticket lives in the branch name and MR — not the commit

### Creating an MR

**When the user says "create mr":**

1. Ask for the ticket number if not already provided
2. Run `glab mr create` and fill **every section** of the MR template from the diff — no placeholder text, no empty headings, no skipped checklist items
3. Set the ticket reference in the MR title or description

## MR Rules

- Never force-push to `main`/`master`
- Ensure pipeline passes before requesting review
- Delete source branch after merge (GitLab default — keep it on)

## CI/CD

- Pipeline config: `.gitlab-ci.yml`
- Never skip pipeline stages (`when: never` requires justification)
- Secrets via GitLab CI/CD variables — never in `.gitlab-ci.yml`
- Check pipeline status: `glab ci status`

## SSH

- Key: `~/.ssh/id_ed25519_gitlab` (work)
- Ensure `~/.ssh/config` routes `gitlab.com` (or company host) to the work key
