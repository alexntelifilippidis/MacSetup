# API Conventions

## General

- Validate all inputs at system boundaries (user input, external APIs)
- Return structured errors — never bare strings
- All external HTTP calls: timeout + retry with backoff+jitter
- Dead-letter queues for any async/pipeline call

## Databricks / PySpark

- Always pass `--profile <profile>` to Databricks CLI
- Schema changes need migration plans + backward-compat windows
- Data contracts are APIs — breaking changes require a deprecation window
- Prefer Delta Lake merge over overwrite for idempotent writes

## Terraform / Azure

- `plan` is read-only; `apply` needs explicit confirmation + state backup
- Least-privilege on all IAM/service accounts — no wildcard policies
- Immutable infra preferred — avoid in-place mutations on prod resources

## Secrets

- All sensitive values via environment variables
- `chmod 600` on credential files (`.databrickscfg`, `.secrets.zsh`)
- Never log or print secrets
