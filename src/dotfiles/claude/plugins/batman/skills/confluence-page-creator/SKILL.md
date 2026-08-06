---
name: confluence-page-creator
description: Draft, structure, and publish a Confluence page from notes, a ticket, or a markdown draft, via the Atlassian MCP server, into a specific space and parent page — emoji-led headings, and linking to official/vendor docs instead of copying their content so the page doesn't need maintaining as those docs change. Use when asked to create a Confluence page, publish documentation, write up a design doc or runbook, or turn notes/a ticket into a wiki page.
---

# Confluence Page Creator

## ⚠️ Requires the Atlassian MCP server — `acli` cannot create pages

`acli confluence page` only supports `view` as of `acli` 1.3.22 — there is no `create`
subcommand. Don't attempt one; it doesn't exist.

Check connectivity first:

```bash
claude mcp list | grep atlassian
```

If it isn't connected, say so and stop — tell the user to run `/mcp` and authorize the
`atlassian` server before continuing. Don't fall back to a raw REST call: Confluence
storage format is XHTML, not markdown, and hand-building it is exactly the class of bug
that's invisible until the page renders.

## 1. Get the two things you cannot proceed without

- **Space key** — which Confluence space the page lives in.
- **Parent page** — what it nests under (title or page ID). A page with no parent lands
  at the space root, which is rarely intended.

**Ask if either is missing.** Publishing to the wrong space or as an orphan page is
exactly the kind of thing that's annoying to notice and fix after the fact — confirm
before creating, don't guess.

## 2. Draft first, publish second

Turn the source material (notes, a ticket, a rough draft) into a page **draft** and show
it before creating anything. Structure:

- One clear `H1` title — usually the page title itself, so the body starts at `H2`.
- Short intro paragraph — what this page is and who it's for.
- **Emoji-led headings** — one per section, matching its content (🚀 setup, 🔧
  configuration, 🐛 troubleshooting, 🔐 auth, 📖 references) so the page skims at a
  glance in the space's page tree, not just when open.
- Headings that map to how someone will actually search or skim, not to the order ideas
  occurred to you.
- Tables for anything tabular — comparisons, config keys, status. Not bullet lists
  pretending to be tables.
- Code blocks with a language tag for any command or config snippet.
- A short "🔗 Related" or "See also" section linking sibling pages, if any exist.

Keep it as **short as the content allows.** A page that repeats the ticket it came from
adds a place for the two to drift out of sync.

### Link to the official source instead of copying it

For anything that already has a canonical home — vendor docs, an API reference, a
setup guide that changes with the tool's version — **link to it, don't paste it in.**
A copied version is a second thing that goes stale the moment the original updates, and
nobody remembers to sync it. Reserve the page's own words for the parts only this org
or this page can say: local conventions, internal endpoints, decisions, gotchas.

```markdown
## 🚀 Setup
See the [official GitLab MCP server docs](https://docs.gitlab.com/user/model_context_protocol/mcp_server/)
for the base setup. Our specific addition:
- 🔧 Use the internal gateway URL from `.secrets.zsh`, not the public endpoint
```

not:

```markdown
## 🚀 Setup
1. Run `claude mcp add --transport http gitlab https://gitlab.com/api/v4/mcp`
2. [... six more steps duplicating the vendor doc, none of them ours to maintain ...]
```

## 3. Publish via the Atlassian MCP

Use the MCP server's Confluence page-creation tool with the space key, the parent page
ID, and the drafted body. It handles the markdown → storage-format conversion — don't
hand-write storage-format XHTML.

## 4. After publishing

Report the page URL. If it was sourced from a Jira ticket, comment the URL back onto the
ticket (see `jira-ticket-creator` / `jira-acli`).

## Rules

- **Confirm the space and parent before publishing** — this is the one step in this skill
  worth pausing for.
- **Never publish real customer data** — identity/KYC records, screening hits, risk
  scores, case files, or anything tying data to an identifiable customer. Synthetic
  examples only.
- Mask or pseudonymize any customer ID, username, email, or phone number that must appear.
- **Get explicit consent before publishing content sourced from a private conversation**
  into a space others can read.
- Apply GDPR data minimization — don't include personal data the page doesn't need.
- **Never print or log the Atlassian API token or any MCP auth material.**
