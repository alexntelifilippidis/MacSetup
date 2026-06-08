# /review — Code Review

Review the current diff using the code-reviewer agent.

## Usage

```
/review [--fix] [--comment] [--security]
```

- `--fix`: apply safe 🟡/🟢 findings to the working tree (never auto-fix 🔴 blockers)
- `--comment`: post findings as inline PR/MR comments via `gh`/`glab`
- `--security`: also invoke the security-auditor agent

## Steps

1. Run `git diff HEAD` to get the current diff
2. Invoke the `code-reviewer` agent — five axes: Correctness, Security, Performance, Maintainability, Operational
3. If `--security`: also invoke the `security-auditor` agent
4. If `--fix`: apply 🟡/🟢 findings; present 🔴 blockers for explicit confirmation
5. If `--comment`: post via `gh pr review --comment` (GitHub) or `glab mr note` (GitLab)

## Severity

🔴 **Blocker** — must fix before merge:

- Logic bugs, race conditions, off-by-ones
- Secrets in code, injection flaws, PII exposure, missing authz
- Breaking changes without migration path

🟡 **Should-fix**:

- N+1 queries, unbounded loops, hot-path allocations
- Poor naming, tight coupling, missing system-boundary error handling

🟢 **Nit**:

- Style inconsistencies not caught by linter
- Minor readability

## Stack-Specific Checks

**Shell:** `shellcheck -x --severity=warning` clean · `shfmt -i 2` formatted · `$REPO_ROOT`-relative paths · idempotency verified

**Python:** `uv run ruff check` clean · no bare `pip`/`python`/`pytest` · type annotations on public functions

**Terraform:** `terraform validate` passes · `terraform fmt -check` clean · no wildcard IAM

**Scala:** no `var` · no `null` · no `.get` on `Option` · `SparkSession` injected, not built inside functions

**SQL:** CTEs over subqueries · leading commas · UPPERCASE keywords · `snake_case` identifiers
