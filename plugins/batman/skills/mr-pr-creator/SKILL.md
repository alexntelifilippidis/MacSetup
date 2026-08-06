---
name: mr-pr-creator
description: Create a GitHub PR or GitLab MR end-to-end — detect the host from the remote, branch with the right naming convention, write conventional commits, retrieve the auth token from git-credential-manager without ever printing it, and write the description by following the repo's template if one exists, or short emoji-led human bullets giving the big picture if not. Use when asked to create a PR, create an MR, open a pull or merge request, or push a branch for review.
---

# MR/PR Creator

Detect the host **first** — every step after this depends on it:

```bash
git remote get-url origin
# https://github.com/...              → GitHub  → gh, "PR"
# https://gitlab.com/...  or self-hosted → GitLab → glab, "MR"
```

## 1. Branch

If already on a correctly named branch, skip this. Otherwise branch off the default
branch (`main`/`master`) first — **never commit directly on it**.

| Host                        | Pattern                                            | Example                                                       |
|------------------------------|-----------------------------------------------------|---------------------------------------------------------------|
| 🐙 GitHub                    | `(feature\|bugfix\|hotfix\|chore\|docs\|release)/<desc>` | `feature/add_login_flow`                                      |
| 🦊 GitLab (CI-enforced regex) | `^(feature\|bugfix\|hotfix\|release\|chore\|config)/([A-Z]+-\d+\|NOJIRA)-.*` | `feature/KAI-123-add_login_flow` · `chore/NOJIRA-update_deps` |

For GitLab, **ask for the ticket number if it isn't already known** — a branch that
doesn't match the regex fails CI immediately. Use `NOJIRA` only when there truly is no
ticket.

```bash
git checkout -b <type>/<desc>                  # GitHub
git checkout -b <type>/<TICKET>-<desc>          # GitLab
```

## 2. Commits

Conventional commits, imperative mood, on both hosts:

```
type(scope): what it does
```

- **GitLab: no ticket reference in the commit message** — it lives in the branch name
  and the MR, not repeated in every commit.
- **No `Co-authored-by` trailers on either host** — strip any Copilot or AI co-author
  line before committing.
- Keep messages short and to the point.

## 3. Push

```bash
git push -u origin <branch>
```

## 4. Resolve the token — never print it

Check the environment first; only fall back to git-credential-manager if unset.

```bash
# GitHub
[ -n "${GH_TOKEN:-${GITHUB_TOKEN:-}}" ] || \
  GH_TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill \
    | sed -n 's/^password=//p')

# GitLab — replace gitlab.com with the real host from `git remote get-url origin`
# if self-hosted
[ -n "${GITLAB_TOKEN:-${GLAB_TOKEN:-}}" ] || \
  GITLAB_TOKEN=$(printf "protocol=https\nhost=gitlab.com\n" | git credential fill \
    | sed -n 's/^password=//p')
```

Pass the resolved token **inline** to the one command that needs it — never assign it to
a variable that persists beyond that, never echo it.

> ⚠️ Use `sed -n 's/^password=//p'` to extract the value, **not** `awk -F= '{print $2}'`.
> `awk -F=` splits on *every* `=` in the line, so it silently truncates any token that
> contains one — and plenty do (base64-padded secrets, some PATs). Verified:
> `awk -F= '{print $2}'` on `password=abc=123=xyz` returns `abc`, dropping the rest.

## 5. Write the description

**Check for a template first** — it decides which of the two paths below you take:

| Host    | Template lookup order                                                              |
|---------|-------------------------------------------------------------------------------------|
| GitHub  | `.github/pull_request_template.md`                                                  |
| GitLab  | `.gitlab/merge_request_templates/Default.md` → `.gitlab/merge_request_templates/*.md` (first match) → `.github/pull_request_template.md` (fallback) |

### Repo has a template → follow it

**Fill every section from the diff.** No placeholder text, no empty headings, no
skipped checklist items. Delete a section only if it's explicitly marked optional and
doesn't apply.

### No template → short, human, skimmable bullets with emojis

Don't write a file-by-file changelog of what the code does — that's what the diff is
for. Write the **big picture**: what changed and why, so a reviewer gets it in the time
it takes to read five short lines.

- 3–6 bullets, one line each
- Lead each bullet with an emoji that matches its content — a signal, not decoration
- Group by *outcome*, not by file — "fixes the flaky retry" beats "updated retry.py"
- Skip anything a competent reviewer would consider obvious from the title

```markdown
## What changed
- 🐛 Fixed the retry loop double-firing on a 429 — was burning the rate limit budget
- ⚡ Cut cold-start latency ~40% by lazy-loading the model registry
- 🧹 Removed the now-dead feature-flag path from the old rollout
- 🧪 Added a regression test for the retry fix
```

Anti-pattern — a description that just re-narrates the diff:

```markdown
## What changed
- Modified retry.py
- Updated config.py to add a new setting
- Added test_retry.py
```

That tells a reviewer nothing they can't get from `git diff --stat`.

## 6. Create

```bash
GH_TOKEN=$GH_TOKEN gh pr create --title "..." --body "..."
GITLAB_TOKEN=$GITLAB_TOKEN glab mr create --title "..." --description "..."
```

If there's a linked Jira ticket, comment the MR/PR URL onto it and transition it to
"In Review" — see the `jira-ticket-creator` skill.

## Rules

- Never force-push to `main`/`master`.
- Draft for WIP: `gh pr create --draft`; GitLab MRs default to open — mark **Draft:** in
  the title if still WIP.
- Request review only once CI/pipeline is green.
- Merge strategy: squash for GitHub feature branches, merge commit for release branches;
  rebase merge for GitLab (keeps linear history).
- Delete the branch after merge.
- Never skip a GitLab pipeline stage (`when: never` needs justification in the MR).
