---
name: bristol-dependency-check
description: Check whether a change to a Databricks table has a dependency on Team Bristol, by searching the `de-platform-new-tenant` GitLab repo (Team Bristol's own Databricks platform code — team_name "Bristol", bundle `bristol_dabs`) for jobs/pipelines/notebooks that read or write it. Use when asked "does this table change affect Bristol", "check Bristol dependency", "will this break Bristol's jobs", or before merging a schema/table change that might have downstream consumers.
---

# Bristol Dependency Check

Team Bristol's Databricks platform code lives in one repo:
`https://gitlab.com/kaizengaming/projects/dna/data-platform/de-platform-new-tenant`.
Confirmed from the repo itself — `databricks_asset_bundles_variables.yml` sets
`team_name: "Bristol"` and `databricks.yml` bundles as `bristol_dabs`. So checking
"does table X have a Bristol dependency" means: **does this repo reference table X
anywhere** — if yes, some Bristol job/pipeline reads or writes it and changing it
without notice can break their run.

## 1. Locate the repo

The bundled script (`scripts/check-dependency.sh`) auto-detects a local checkout by
checking, in order: `$BRISTOL_REPO_PATH`, then `$HOME/Projects/{Work,Personal}/de-platform-new-tenant`,
`$HOME/{repos,git,gitlab,workspace,dev}/de-platform-new-tenant`, then a bounded `find`
under those roots.

- **Found** → proceed to step 2.
- **Not found** → tell the user, then ask before cloning (this pulls from GitLab, an
  outward action — confirm first per the "confirm before hard-to-reverse/outward
  actions" rule):

  ```bash
  git clone <ssh-or-https-url> "$HOME/Projects/Work/de-platform-new-tenant"
  ```

  Or let them point at an existing checkout elsewhere via `BRISTOL_REPO_PATH`.

## 2. Run the check

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/bristol-dependency-check/scripts/check-dependency.sh" <table1> [table2 ...]
```

- Accepts one or more table identifiers per run — bare name (`currency`), `schema.table`
  (`silver.currency`), or a full FQN (`catalog.schema.currency`). Prefer whatever
  specificity the user gave you; don't invent a catalog/schema they didn't mention.
- The script is **read-only** — it only greps the local checkout, it never clones,
  writes, or pushes anything.
- If `BRISTOL_REPO_PATH` was needed in step 1, export it before this call.

## 3. Read the report

The script prints a terminal report per table:

- `✅ No dependency found` — no reference anywhere in the repo. Safe to say Bristol is
  unaffected, but still mention this was a text-search check, not a lineage query.
- `⚠️ DEPENDENCY FOUND` — lists every `file:line` hit with a snippet, and where it can
  resolve one, the owning job/task (parsed from `databricks/jobs/*.yml` /
  `databricks/pipelines/*.yml` by matching the notebook path back to a job definition).
  A hit with no resolved job still counts — surface it, just note "owning job not
  auto-resolved, check manually."
- `Loose filename matches` — the table name also appears in a *file name* (this repo
  names some notebooks after their target table, e.g. `UOWCurrency.scala`,
  `mCurrencyCurrencyHistory.scala`). These are lower-confidence; call them out as
  "verify manually" rather than as confirmed dependencies.

Relay the script's report to the user close to verbatim — it's already formatted for
the terminal. Don't re-summarize away the file:line detail; that's the point of the
report.

## Caveats — say these out loud when relevant

- This is a **text search**, not real column/table lineage — a table read via a fully
  dynamic path (built from variables, not a literal) won't be found. If the report
  comes back clean but the user is confident there's a dependency, say so and suggest
  checking Unity Catalog lineage (`system.access.table_lineage`) as a stronger source
  of truth.
- Generic/short table names produce noisy hits even with word-boundary matching
  (`-w`) — if a table name is a common word, prefer the fuller `schema.table` or FQN
  form to cut noise.
- Job-ownership resolution is a heuristic (nearest `task_key:`/job key above the
  notebook-path match in the YAML) — good enough to point at the right job, not a
  guarantee for deeply nested or unusual job definitions.
