# Global GitHub Copilot Instructions

## About Me

I am a data/platform engineer working primarily with Python, Scala, Bash, and infrastructure tooling on macOS (Apple Silicon). I work across multiple projects including Databricks data pipelines and Mac environment automation.

---

## Languages & Tools I Use Daily

- **Python** 3.11+ — primary language for data engineering and scripting
- **Scala** 2.12 — Databricks/Spark notebooks and UOW jobs
- **Bash** — setup scripts, automation, CI/CD helpers
- **SQL / Spark SQL** — data transformations on Databricks
- **Terraform / HCL** — infrastructure as code
- **YAML** — Databricks Asset Bundles, GitLab CI/CD pipelines, job definitions
- **Markdown** — documentation

**Package Managers & Runners:**

- Python: always use `uv run` prefix (never plain `python`, `pytest`, or `ruff`)
- `uv` — Python package manager and runner (`uv add`, `uv sync`, `uv run`)
- macOS packages: Homebrew (`brew`)

**Key Tools:**

- Databricks CLI, PySpark, Delta Lake, dbt
- Podman (not Docker), podman-compose
- Git, GitHub CLI (`gh`), GitLab CLI (`glab`)
- pre-commit, shellcheck, hadolint
- Terraform, terraform-docs
- Hatch (Python project manager)
- PyCharm, IntelliJ IDEA

---

## Python Coding Standards

### Style & Formatting

- Follow **PEP 8** strictly, enforced by `ruff`
- **88 character line length** (Black-compatible)
- `snake_case` for functions and variables, `PascalCase` for classes, `UPPER_SNAKE_CASE` for constants
- Always run `uv run ruff format` before `uv run ruff check`

### Type Hints

- **Always** include type hints on all function parameters, return types, and class attributes (PEP 484)
- Use `from __future__ import annotations` for forward references when needed
- Prefer `list[str]` over `List[str]` (Python 3.10+ style)

### Docstrings

- **Sphinx-style docstrings only** — no Google or NumPy style
- Every module, class, and public function **must** have a docstring
- Use `:param`, `:return:`, `:raises:`, `:ivar:` — omit `:type:` and `:rtype:` since type hints are used
- Example:

  ```python
  def process_records(self, records: list[dict]) -> list[dict]:
      """Process and validate a list of records.

      :param records: List of raw data records to process
      :return: List of validated and transformed records
      :raises ValueError: If any record fails validation
      """
  ```

### Design Principles

- **Prefer OOP** — use classes to encapsulate related data and behaviour
- **Single Responsibility Principle** — each function does ONE thing, ideally ≤ 30 lines
- Extract complex logic into small, well-named private helper methods (`_method_name`)
- Prefer explicit over implicit — no magic numbers, use named constants

### What to NEVER do in Python

- Never use `print()` for application output — use `logging`
- Always use emojis in log messages for visual clarity:

  ```python
  import logging
  logger = logging.getLogger(__name__)

  logger.info("🚀 Starting pipeline run...")
  logger.info("✅ Records processed successfully: %d", count)
  logger.warning("⚠️ Missing optional field: %s", field_name)
  logger.error("❌ Failed to connect to source: %s", source)
  logger.debug("🔍 Processing record: %s", record_id)
  ```

- Never use `os.system()` — use `subprocess.run()` with explicit args
- Never use bare `except:` — always catch specific exceptions
- Never commit secrets or tokens — use environment variables or config files
- Never use plain `pytest` or `ruff` — always prefix with `uv run`

---

## Scala Coding Standards

- Scala 2.12 dialect, formatted with `scalafmt` (version 3.10.7, IntelliJ preset)
- Follow functional style where appropriate in Spark transformations
- Use `case class` for data models
- Avoid mutable state (`var`) — prefer `val`

---

## Bash / Shell Script Standards

- Always start with `#!/bin/bash`
- Use ANSI color codes for user-facing output:

  ```bash
  GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
  echo -e "${GREEN}Done!${RESET}"
  ```

- **Check before acting** — make scripts idempotent (safe to re-run):

  ```bash
  if ! command -v tool &> /dev/null; then
    echo "Installing tool..."
  fi
  ```

- Use `$HOME/` instead of `~/` for absolute paths
- Set explicit file permissions: `chmod 600` for secrets, `chmod +x` for scripts
- Always provide user feedback at each step with `echo`

---

## Terraform / HCL Standards

- Use `terraform fmt` before committing
- Always include `description` on every variable and output
- Group resources logically with comments
- Use `locals` to avoid repetition

---

## Git & CI/CD

- **Branch naming (strictly enforced by GitLab CI):**
  - Pattern: `^((feature|bugfix|hotfix|release|chore|config)/([A-Z]+-\d+|NOJIRA)-.*|main|master)$`
  - Examples: `feature/PROJ-123-add-login`, `bugfix/BST-456-fix-header`, `chore/NOJIRA-cleanup-deps`
- **Commit/MR messages:** conventional commits format — `feat:`, `fix:`, `chore:`, `ci:`, `docs:`, `perf:`, `refactor:`, `revert:`, `style:`, `test:`
- Always run pre-commit hooks before pushing: `pre-commit run --all-files`
- Never commit directly to `main` or `master`

---

## General Copilot Behaviour Preferences

### Do

- Give **concise, direct answers** — I prefer code over lengthy explanations
- Suggest tests for any new function or class
- Warn me about **security issues** (hardcoded secrets, weak permissions, SQL injection, etc.)
- Suggest the **idiomatic/best-practice** approach for the language
- Remind me to add type hints and docstrings if missing
- Use existing patterns already present in the file/project

### Do NOT

- Do not add unnecessary comments that just restate the code
- Do not use deprecated APIs without flagging them
- Do not suggest Docker when I use Podman
- Do not use `pip install` — suggest `uv add` or update `pyproject.toml`
- Do not wrap every suggestion in lengthy prose — get to the code

---

## Project Context Hints

- **`~/Projects/Personal/`** — personal projects (MacSetup, etc.)
- **`~/Projects/Work/`** — work projects (Databricks data platform, etc.)
- Git identity switches automatically based on directory via `.gitconfig` conditional includes
- Sensitive config files (`.databrickscfg`) should always be `chmod 600`
- Databricks bundle commands always require `--profile` flag
