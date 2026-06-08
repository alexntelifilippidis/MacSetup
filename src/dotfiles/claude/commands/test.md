# /test — Run Tests

Stack-aware test runner following the project testing philosophy.

## Usage

```
/test [--unit] [--integration] [path]
```

- `--unit`: unit tests only
- `--integration`: integration tests only (may require external services — confirm before running)
- `path`: narrow to a specific file or directory

## Steps

### 1. Detect the stack

| Indicator | Runner |
|-----------|--------|
| `pyproject.toml` | Python — `uv run pytest` |
| `build.sbt` | Scala — `sbt test` |
| `tests/*.bats` | Shell — `bats` |

### 2. Run tests

**Python:**

```bash
uv run pytest -v                          # all
uv run pytest -v tests/unit/              # --unit
uv run pytest -v tests/integration/      # --integration
uv run pytest -v <path>                   # specific path
```

**Scala:**

```bash
sbt test                    # all
sbt "testOnly *<ClassName>*" # specific path/class
```

**Shell (bats):**

```bash
bats tests/unit/
bats <path>
```

### 3. Report

- Pass/fail counts per suite
- Failed test names with file:line
- Flag any test that was skipped or marked flaky

## Rules

- Never run integration tests against production resources — confirm target env first
- Flaky test = broken test — report it, never `@retry`
- If the diff adds new behaviour without tests, flag it as 🔴 missing coverage
- Idempotency: tests must produce the same result on re-run
