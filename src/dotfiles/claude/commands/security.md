# /security — Security Audit

Run a security audit using the security-auditor agent.

## Usage

```
/security [--full] [--files <glob>]
```

- `--full`: audit the entire repo, not just the current diff
- `--files <glob>`: audit specific files (e.g. `--files "src/**/*.py"`)

## Steps

1. Determine scope:
   - Default: `git diff HEAD`
   - `--full`: all tracked files in the repo
   - `--files <glob>`: matching files only

2. Invoke the `security-auditor` agent on the scope.

3. Report findings in severity order: **Critical → High → Medium → Low**

## What's Checked

- **Secrets** — hardcoded tokens, passwords, API keys, connection strings
- **Injection** — command injection, SQL injection, path traversal
- **Auth** — missing authz checks, privilege escalation paths
- **PII** — unmasked customer IDs, emails, phone numbers in logs or output
- **Supply chain** — unverified external downloads, untrusted scripts sourced at runtime
- **Permissions** — credential files not `chmod 600` (`.secrets.zsh`, `.databrickscfg`)
- **IAM** — wildcard policies, over-broad permissions in Terraform

## Rules

- Never auto-fix **Critical** findings — present and require explicit confirmation
- Never print or echo actual secret values found
- AML/KYC workflow changes: flag and defer to AML team, do not auto-remediate
- PII findings: mask in output, flag location only
