# Repo Conventions — Python

## Stack

- Python 3.11+
- Package manager: `uv` — never bare `pip`, `pip install`, or `virtualenv`
- Linter/formatter: `ruff`
- Test runner: `pytest`
- Type checker: `mypy` (when present in project)

## Project Structure

```
<project>/
├── pyproject.toml       # single source of truth — deps, ruff, pytest config
├── uv.lock
├── src/
│   └── <package>/
│       ├── __init__.py
│       └── ...
└── tests/
    ├── unit/
    ├── integration/
    └── conftest.py
```

- Always `src/` layout — never flat layout for importable packages
- `tests/` at repo root, mirroring `src/<package>/` structure

## Commands

```bash
uv sync                        # install deps from lock file
uv add <package>               # add dependency
uv run pytest -v               # run tests
uv run ruff format .           # format
uv run ruff check --fix .      # lint + autofix
uv run mypy src/               # type-check
```

## pyproject.toml Conventions

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --tb=short"
```

## Code Rules

- Structured logging (`structlog` or `logging.getLogger`) — never bare `print()`
- Pure functions + dependency injection for testability
- Type annotations on all public functions
- No mutable default arguments
- `pathlib.Path` over `os.path`

## SQL within Python

See `@.claude/rules/repos/sql.md` for Spark SQL / raw SQL conventions used inside Python files.
