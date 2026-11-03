#!/usr/bin/env bash
# scaffold.sh — create a new Python project skeleton following the
# python-project-structure skill: src/ layout, layered package, pydantic-settings,
# structlog, ruff + mypy --strict + pytest (90% coverage) + pre-commit.
#
# Idempotent: existing files are never overwritten, and `uv add` is safe to re-run.
#
# Usage:
#   scaffold.sh <package_name> [target_dir]
#
# <package_name> is the import name (snake_case, e.g. order_engine); the distribution
# name is derived from it (order-engine). target_dir defaults to the current directory.
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <package_name> [target_dir]" >&2
  exit 1
}
[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage

PKG="$1"
TARGET="${2:-.}"

if ! [[ "$PKG" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "❌ package_name must be snake_case (^[a-z][a-z0-9_]*$): $PKG" >&2
  exit 1
fi
command -v uv > /dev/null || {
  echo "❌ uv not found — brew install uv" >&2
  exit 1
}

PROJECT="${PKG//_/-}"
ENV_PREFIX="$(printf '%s' "$PKG" | tr '[:lower:]' '[:upper:]')_"
ERROR_BASE="$(printf '%s' "$PKG" | awk -F_ '{for (i = 1; i <= NF; i++) printf "%s%s", toupper(substr($i, 1, 1)), substr($i, 2)}')Error"

mkdir -p "$TARGET"
cd "$TARGET"

# write_if_missing <path> — write stdin to <path> unless it already exists.
write_if_missing() {
  local path="$1"
  if [ -e "$path" ]; then
    echo "⏭️  exists, skipped: $path"
    cat > /dev/null
    return
  fi
  mkdir -p "$(dirname "$path")"
  cat > "$path"
  echo "✅ created: $path"
}

write_if_missing pyproject.toml << EOF
[project]
name = "${PROJECT}"
version = "0.1.0"
description = ""
requires-python = ">=3.11"
dependencies = []

[project.scripts]
${PROJECT} = "${PKG}.__main__:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
target-version = "py311"
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E", "W", "F", "I", "B", "UP", "SIM", "N", "S", "PT", "RUF", "TID",
    "C90", "PLR", "ERA", "FBT",
]

[tool.ruff.lint.flake8-tidy-imports]
ban-relative-imports = "all"

[tool.ruff.lint.mccabe]
max-complexity = 10

[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101", "PLR2004"]

[tool.mypy]
strict = true
plugins = ["pydantic.mypy"]
files = ["src", "tests"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = ["--import-mode=importlib", "--cov", "--cov-report=term-missing"]

[tool.coverage.run]
branch = true
source = ["${PKG}"]

[tool.coverage.report]
fail_under = 90
show_missing = true
exclude_also = ['if __name__ == "__main__":']
EOF

write_if_missing .gitignore << 'EOF'
.venv/
__pycache__/
*.py[cod]
.env
.coverage
htmlcov/
dist/
.mypy_cache/
.ruff_cache/
.pytest_cache/
EOF

write_if_missing .pre-commit-config.yaml << 'EOF'
default_install_hook_types: [pre-commit, pre-push]
repos:
  - repo: local
    hooks:
      - id: ruff-check
        name: ruff check
        entry: uv run ruff check --fix
        language: system
        types: [python]
      - id: ruff-format
        name: ruff format
        entry: uv run ruff format
        language: system
        types: [python]
      - id: mypy
        name: mypy
        entry: uv run mypy
        language: system
        types: [python]
        pass_filenames: false
      - id: pytest
        name: pytest
        entry: uv run pytest
        language: system
        pass_filenames: false
        stages: [pre-push]
EOF

SRC="src/${PKG}"

write_if_missing "${SRC}/__init__.py" << EOF
"""${PKG}."""
EOF

write_if_missing "${SRC}/py.typed" < /dev/null

write_if_missing "${SRC}/__main__.py" << EOF
"""Composition root — the only place that builds config, logging and dependencies."""

import structlog

from ${PKG}.config import Settings
from ${PKG}.logging_setup import configure_logging


def main() -> None:
    """Load settings, configure logging, wire dependencies and start the app."""
    settings = Settings()
    configure_logging(level=settings.log_level, use_json_logs=settings.use_json_logs)
    log = structlog.get_logger(__name__)
    log.info("app_started", app_name=settings.app_name)


if __name__ == "__main__":
    main()
EOF

write_if_missing "${SRC}/config.py" << EOF
"""Runtime settings, read from ${ENV_PREFIX}* env vars or a gitignored .env file."""

from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict

LogLevel = Literal["DEBUG", "INFO", "WARNING", "ERROR"]


class Settings(BaseSettings):
    """Typed runtime settings — instantiate once, in the composition root.

    :param app_name: name reported in logs, defaults to "${PROJECT}"
    :param log_level: minimum level that gets logged, defaults to "INFO"
    :param use_json_logs: emit JSON lines instead of console output, defaults to True
    """

    model_config = SettingsConfigDict(
        env_prefix="${ENV_PREFIX}",
        env_file=".env",
        extra="ignore",
        frozen=True,
    )

    app_name: str = "${PROJECT}"
    log_level: LogLevel = "INFO"
    use_json_logs: bool = True
EOF

write_if_missing "${SRC}/errors.py" << EOF
"""Exception hierarchy — every error raised here derives from ${ERROR_BASE}."""


class ${ERROR_BASE}(Exception):
    """Base error — catch this to handle anything the package raises."""
EOF

write_if_missing "${SRC}/logging_setup.py" << 'EOF'
"""structlog setup — call configure_logging() once, from the composition root."""

import logging

import structlog
from structlog.typing import Processor


def configure_logging(*, level: str = "INFO", use_json_logs: bool = True) -> None:
    """Configure structlog for the whole process.

    :param level: minimum level that gets logged, defaults to "INFO"
    :param use_json_logs: emit JSON lines instead of console output, defaults to True
    :raises KeyError: if ``level`` is not a known logging level name
    """
    processors: list[Processor] = [
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso", utc=True),
        structlog.processors.StackInfoRenderer(),
    ]
    if use_json_logs:
        processors += [
            structlog.processors.dict_tracebacks,
            structlog.processors.JSONRenderer(),
        ]
    else:
        processors.append(structlog.dev.ConsoleRenderer())

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.make_filtering_bound_logger(
            logging.getLevelNamesMapping()[level]
        ),
    )
EOF

write_if_missing "${SRC}/models/__init__.py" << 'EOF'
"""Domain objects — frozen Pydantic models. Imports no other layer."""
EOF

write_if_missing "${SRC}/repositories/__init__.py" << 'EOF'
"""I/O boundary — a Protocol per data source plus its concrete implementations."""
EOF

write_if_missing "${SRC}/services/__init__.py" << 'EOF'
"""Business logic — depends on repository Protocols, never on concrete I/O."""
EOF

write_if_missing "${SRC}/api/__init__.py" << 'EOF'
"""Entrypoints — HTTP routes, CLI, job tasks. Translate, then delegate to services."""
EOF

write_if_missing "tests/test_${PKG}/test_main.py" << EOF
import pytest

from ${PKG}.__main__ import main


def test_main_logs_startup(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    monkeypatch.setenv("${ENV_PREFIX}APP_NAME", "test-app")

    main()

    assert '"app_name": "test-app"' in capsys.readouterr().out
EOF

write_if_missing "tests/test_${PKG}/test_logging_setup.py" << EOF
import pytest
import structlog

from ${PKG}.logging_setup import configure_logging


def test_console_logs_filter_below_level(capsys: pytest.CaptureFixture[str]) -> None:
    configure_logging(level="WARNING", use_json_logs=False)
    log = structlog.get_logger()

    log.info("hidden_event")
    log.warning("shown_event")

    out = capsys.readouterr().out
    assert "shown_event" in out
    assert "hidden_event" not in out
EOF

uv add pydantic pydantic-settings structlog
uv add --dev pytest pytest-cov mypy ruff pre-commit

cat << EOF

🦇 Scaffolded ${PROJECT} in $(pwd)

Next:
  git init                                  # if not already a repo
  uv run pre-commit install
  uv run pre-commit run --all-files
  uv run pytest
EOF
