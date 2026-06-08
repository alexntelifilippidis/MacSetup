# /review — Code Review

Review the current diff for correctness, security, and maintainability.

## Usage

```
/review [--fix] [--comment]
```

- `--fix`: apply findings to the working tree
- `--comment`: post findings as inline PR comments

## Review Criteria (in severity order)

🔴 **Blocker** — must fix before merge:

- Logic bugs, race conditions, off-by-ones
- Security: injection, secrets in code, missing authz, PII exposure
- Breaking changes without migration path

🟡 **Should-fix** — strong recommendation:

- N+1 queries, unbounded loops, allocation in hot paths
- Poor naming, low cohesion, tight coupling
- Missing error handling at system boundaries

🟢 **Nit** — optional improvement:

- Style inconsistencies not caught by linter
- Minor readability improvements

## Shell-Specific Checks

- `shellcheck -x --severity=warning` clean
- `shfmt -i 2` formatted
- No hardcoded paths — uses `$REPO_ROOT`
- Idempotency verified
