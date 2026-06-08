# Skill: Testing Patterns

Apply the project testing philosophy when writing or reviewing tests.

## Principles

- **Test pyramid**: many unit → fewer integration → minimal E2E
- Tests assert **behavior**, not implementation
- Avoid mocking what you don't own
- Flaky test = broken test — fix root cause, never `@retry`

## Shell Scripts

```bash
# Use bats-core for shell unit tests
bats tests/unit/test_helpers.bats

# Test idempotency: run twice, assert same outcome
setup_dotfiles && setup_dotfiles
```

## Python / PySpark

```bash
# Run with uv
uv run pytest -v

# For data pipelines: golden-file + schema/contract tests
tests/
├── unit/           # pure function tests
├── integration/    # real I/O, no mocks of owned code
└── golden/         # expected output fixtures
```

## Data Pipelines

- Golden-file tests + schema/contract tests > unit tests of transforms
- Test with a real (local/dev) Spark session — not mocked
- Assert schema, row counts, and key column values

## What NOT to Do

- No `unittest.mock` for owned modules
- No `@pytest.mark.flaky` or retry decorators
- No integration tests that hit production resources
- No tests that depend on execution order
