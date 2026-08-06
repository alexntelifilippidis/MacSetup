---
name: jira-ticket-creator
description: Draft and create a Jira ticket using the board's standard template — Overview (user story), Business Value, Background, Technical Work, and a checklist of Acceptance Criteria — via acli or the Atlassian MCP server. Use when asked to write a Jira ticket, create a story or task, draft acceptance criteria, or turn a feature request into a ticket.
---

# Jira Ticket Creator

## The template

Every ticket follows the same five sections, in this order. Don't skip one just because
it feels thin — a missing **Acceptance Criteria** is the single most common reason a
ticket bounces back from review.

```markdown
## Overview

As a <role>, I want <capability>, so that <outcome>.

## Business Value

<Why this matters — the impact, in one or two sentences. Who benefits and how.>

## Background

<Context a reader needs that isn't obvious from the title — prior work, the trigger
for this ticket, related tickets/MRs, current-state pain.>

## Technical Work

- <Concrete, checkable task>
- <Concrete, checkable task>
- ...

## Acceptance Criteria

- [ ] <Observable, testable condition>
- [ ] <Observable, testable condition>
- ...
```

### Writing each section well

- **Overview** is a user story, not a task list — one sentence, `As a / I want / so that`.
  If there's no clear "who", the ticket is probably not ready to write yet.
- **Business Value** answers "why should anyone prioritize this" — not "what does it do"
  (that's Technical Work) and not "how do we know it worked" (that's Acceptance Criteria).
- **Background** carries the context that would otherwise live only in a Slack thread.
  Link related tickets rather than restating them.
- **Technical Work** is a checklist of steps, specific enough that someone else could pick
  the ticket up cold — "Add a setup command to the machine-setup repo" not "update setup".
- **Acceptance Criteria** are checkboxes, each one an **observable, testable condition** —
  "X is verified", "Y is added", not "make sure X works." If a criterion can't be checked
  off by looking at something concrete (a file, a command output, a running check), rewrite
  it until it can.

## Gathering the content

If the user hasn't given you all five sections, ask — don't invent Business Value or
Acceptance Criteria from a one-line request. A vague Overview is fine to tighten up
yourself; a missing Acceptance Criteria list is not something to guess at.

## Creating it

### Preferred — Atlassian MCP

If the `atlassian` MCP server is connected (`/mcp`), use its Jira issue-creation tool
directly with the assembled markdown body — it gets right the mapping to Atlassian
Document Format that plain-text APIs don't.

### Fallback — `acli`

```bash
acli jira workitem create \
  --project <BOARD> \
  --type Story \
  --summary "<title>" \
  --description "$(cat <<'EOF'
## Overview
...
EOF
)"
```

Credentials are already exported in `$HOME/.zshrc` (`ATLASSIAN_API_TOKEN`,
`ATLASSIAN_USER_EMAIL`, `ATLASSIAN_SITE_URL`) — never ask for them, never print them. See
the `jira-acli` skill for the login flow and everyday commands.

## After creating

Show the created ticket's key and URL. If this ticket kicks off work now:

```bash
git checkout -b feature/<KEY>-<slug-from-title>
acli jira workitem transition <KEY> "In Progress"
```

## Rules

- **Never put real customer data, identity/KYC records, screening hits, or case files** in
  a ticket body — synthetic examples only.
- Mask or pseudonymize any customer ID, email, or phone number that must be referenced.
- Keep Acceptance Criteria testable — if you can't say how it'll be checked off, it isn't
  ready to ship as a criterion yet.
