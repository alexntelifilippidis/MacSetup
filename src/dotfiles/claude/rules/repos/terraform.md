# Repo Conventions — Terraform

## Stack

- Provider: Azure (`hashicorp/azurerm`)
- State: remote backend (Azure Storage — never local state in prod)
- Secrets: Azure Key Vault or environment variables — never in `.tfvars`

## Module Structure

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf          # required_providers + terraform version constraint
├── backend.tf           # remote state config
├── terraform.tfvars     # non-sensitive defaults (gitignored for prod values)
└── modules/
    └── <name>/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Naming Conventions

- Resources: `snake_case` — `azurerm_resource_group.main`
- Variables: `snake_case` — `var.resource_group_name`
- Locals: `snake_case` — `local.tags`
- Modules: `kebab-case` directory name — `modules/storage-account/`
- Azure resources: follow `<project>-<env>-<resource>` pattern

## Workflow (Absolute)

```bash
terraform init
terraform validate
terraform plan -out=tfplan   # read-only — never skippable
# → get change management approval
terraform apply tfplan       # only with explicit confirmation + approved change ref
```

- `plan` is safe; `apply` requires explicit user confirmation every time
- Back up remote state before any destructive `apply`
- Use workspaces or separate backends per environment (dev/staging/prod)

## Safety Rules

- No wildcard IAM roles — least-privilege always
- `prevent_destroy = true` on stateful resources (databases, storage)
- Tag every resource: `environment`, `project`, `owner`, `managed_by = "terraform"`
- Run `terraform fmt -recursive` before committing
- `tflint` and `checkov` in CI for every PR/MR
