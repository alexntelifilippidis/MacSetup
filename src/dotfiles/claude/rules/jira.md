# Jira (acli)

## CLI

- Use `acli` for all Jira operations — never open the browser for things acli can do
- Installed via `brew install acli` (tap: `atlassian/homebrew-acli`)

## Authentication

Credentials are exported in `~/.zshrc` on this machine and are always available in the shell environment:

```bash
export ATLASSIAN_API_TOKEN='...'
export ATLASSIAN_USER_EMAIL='your.email@example.com'
export ATLASSIAN_SITE_URL='https://your-org.atlassian.net'
```

Log in once to write the acli config:

```bash
echo "$ATLASSIAN_API_TOKEN" | acli jira auth login \
  --site "${ATLASSIAN_SITE_URL#https://}" \
  --email "$ATLASSIAN_USER_EMAIL" \
  --token
```

Never ask for credentials — the env vars are always set in the shell.

## Key Commands

```bash
# Fetch ticket context before starting work
acli jira workitem view BST-123

# Transition ticket status
acli jira workitem transition BST-123 "In Progress"
acli jira workitem transition BST-123 "In Review"
acli jira workitem transition BST-123 "Done"

# Post a comment (e.g. MR link)
acli jira workitem comment add BST-123 --body "MR: <url>"

# List tickets assigned to me
acli jira workitem list --assignee=currentUser() --status "In Progress"

# Search with JQL
acli jira workitem list --jql 'project = BST AND sprint in openSprints() AND assignee = currentUser()'
```

## Workflow Integration

**When the user says "start ticket BST-NNN":**

1. `acli jira workitem view BST-NNN` — read title, description, acceptance criteria
2. Create branch: `git checkout -b feature/BST-NNN-<slug-from-title>`
3. `acli jira workitem transition BST-NNN "In Progress"`

**When the user says "create mr" on a ticket branch:**

1. Follow MR creation steps in `@.claude/rules/git/gitlab.md`
2. `acli jira workitem comment add BST-NNN --body "MR: <url>"` — link MR to ticket
3. `acli jira workitem transition BST-NNN "In Review"`
