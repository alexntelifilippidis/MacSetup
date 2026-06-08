# Code Style Rules

## Shell / Bash

- Indent: 2 spaces (`shfmt -i 2`)
- Lint: `shellcheck -x --severity=warning`
- Paths: always `$HOME/` — never `~/`
- Variables: `${VAR:-}` for optional, `${VAR:?}` for required
- Never use `$(pwd)` — use `$REPO_ROOT`-relative paths
- Prefer `rg` over `grep`, `gsed` over `sed` in tooling (not in scripts)

## Python

- Version: 3.11+
- Formatter: `uv run ruff format`
- Linter: `uv run ruff check --fix`
- Package manager: `uv add` / `uv sync` — never bare `pip`
- Runner: `uv run <cmd>` — never bare `python`, `pytest`, `ruff`

## General

- No hardcoded secrets, tokens, or passwords
- Structured logging over `print()`
- Pure functions + dependency injection for testability
- Idempotent scripts — safe to re-run
