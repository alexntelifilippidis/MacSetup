# /lint — Lint & Format

Stack-aware lint and format runner.

## Usage

```
/lint [--fix]
```

- `--fix`: apply auto-fixable issues (ruff, shfmt, terraform fmt)

## Steps

### 1. Detect the stack

Check for these files to determine what to run:

| Indicator | Stack |
|-----------|-------|
| `*.sh` files or `Makefile` | Shell |
| `pyproject.toml` or `*.py` | Python |
| `build.sbt` or `*.scala` | Scala |
| `*.tf` or `terraform/` dir | Terraform |

Multiple stacks can be active simultaneously.

### 2. Run linters

**Shell:**

```bash
shellcheck -x --severity=warning $(find . -name "*.sh" -not -path "./.git/*")
shfmt -i 2 -l $(find . -name "*.sh" -not -path "./.git/*")   # -w if --fix
```

**Python:**

```bash
uv run ruff format --check .   # drop --check if --fix
uv run ruff check .            # add --fix if --fix
uv run mypy src/ 2>/dev/null || true   # only if mypy in pyproject.toml deps
```

**Scala:**

```bash
sbt scalafmtCheckAll 2>/dev/null || true   # only if scalafmt plugin present
sbt compile
```

**Terraform:**

```bash
terraform fmt -recursive -check   # drop -check if --fix
terraform validate
```

### 3. Report

- Group failures by linter
- Show file:line for each issue
- Summarise: `N issues across M files`
- Exit non-zero if any linter fails (even with `--fix` applied)
