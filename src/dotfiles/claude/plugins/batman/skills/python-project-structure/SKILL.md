---
name: python-project-structure
description: How to structure Python code — repo layout (src/), layered packages (models / repositories / services / api), module boundaries, meaningful naming, Sphinx docstrings without types, constructor dependency injection via Protocols, Pydantic models for all data (no dataclasses — defers to the pydantic skill), custom error hierarchy, structlog logging, pydantic-settings config, and the ruff + mypy --strict + pytest (90% coverage) + pre-commit toolchain. In a Dagster repo, also loads the dagster-expert skill. Use when creating a new Python project or package, adding a module/class/component to one, deciding where a piece of Python code belongs, reviewing a Python project's structure, or when asked to scaffold a Python repo.
---

# Python Project Structure

These are the defaults for **new** Python code. In an existing repo, its established
conventions win — follow them, and only propose (never silently apply) a restructure.

**Load these skills alongside this one:**

- `pydantic:pydantic` — **always**, before writing or reviewing any model, schema or settings class.
- `dagster-expert:dagster-expert` — **when the repo is a Dagster project**: `dagster` in
  `pyproject.toml` dependencies, a `[tool.dg]` / `[tool.dagster]` table, a `dg.toml`, or a
  `dg.Definitions(...)`. Dagster's project layout (`defs/`, components, `definitions.py`)
  wins over §1–2 where they conflict; the layering, naming, DI and toolchain rules still apply
  inside it.

Scaffold a new project with the bundled script — it is idempotent and never overwrites:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/python-project-structure/scripts/scaffold.sh" <package_name> [target_dir]
```

## 1. Repo layout — `src/`

```
repo/
├── pyproject.toml          # single source of truth: deps, ruff, mypy, pytest, coverage
├── uv.lock                 # committed
├── .pre-commit-config.yaml
├── src/
│   └── my_pkg/
│       ├── __init__.py
│       ├── py.typed
│       ├── __main__.py     # composition root — the ONLY place that wires things
│       ├── config.py       # pydantic-settings
│       ├── errors.py       # exception hierarchy
│       ├── logging_setup.py
│       ├── models/         # domain objects
│       ├── repositories/   # I/O: DBs, files, HTTP, Spark, Kafka
│       ├── services/       # business logic
│       └── api/            # entrypoints: HTTP routes, CLI commands, job tasks
└── tests/
    └── test_my_pkg/        # mirrors src/my_pkg/, every dir and file prefixed test_
        ├── test_main.py
        └── test_services/
            └── test_order_service.py
```

- `src/` means tests run against the **installed** package — packaging bugs surface locally.
- Python `>=3.11`. Managed with `uv` only (`uv add`, `uv run`), never bare `pip`/`python`.

## 2. Layers — imports flow one way

```
api  →  services  →  repositories  →  models
 └──────────┴──────────────┴──────────→ config, errors, logging_setup
```

| Layer           | Holds                                                        | Must not                                   |
|-----------------|--------------------------------------------------------------|--------------------------------------------|
| `models/`       | Frozen Pydantic models — the internal domain vocabulary      | import any other layer; do I/O             |
| `repositories/` | A `Protocol` per data source + its concrete implementations  | contain business rules                     |
| `services/`     | Business logic; depends on repository **Protocols**          | import a concrete repository; do I/O directly |
| `api/`          | Pydantic request/response schemas, routes, CLI, job tasks    | contain business logic — translate and delegate |

- A lower layer **never** imports a higher one. A cycle means a concept is in the wrong layer.
- Boundary schemas (`api/`, and inside `repositories/` when parsing external payloads) are
  separate Pydantic models from the domain ones — map them to `models/` types before handing
  data to `services/`, so an external contract change never leaks into business logic.

## 3. Modules and naming

- **One concept per module** — one class, or one cohesive group of functions. Split past ~300 lines.
- Name the module after the concept: `order_repository.py`, `pricing_service.py`, `order.py`.

Names say **what it is**, not how it's stored — the reader shouldn't need the body to
understand the name.

| Kind               | Rule                                              | ✅ Good                                  | ❌ Bad                     |
|--------------------|---------------------------------------------------|------------------------------------------|---------------------------|
| Class              | Noun, `PascalCase`, names its role                | `OrderRepository`, `PriceCalculator`     | `Manager`, `Handler`, `Data` |
| Function / method  | Verb phrase, `snake_case`, says what it does      | `cancel_order`, `load_settings`          | `process`, `do_it`, `handle` |
| Boolean            | Reads as a yes/no question                        | `is_active`, `has_expired`, `should_retry` | `active`, `flag`, `check` |
| Variable           | Noun describing the content, plural for collections | `pending_orders`, `retry_count`        | `data`, `tmp`, `lst`, `x`  |
| Constant           | `UPPER_SNAKE_CASE`, with unit if any              | `MAX_RETRIES`, `TIMEOUT_SECONDS`         | `N`, `TIMEOUT`            |
| Private            | `_` prefix                                        | `_parse_payload`                         | `parsePayload`            |

- No abbreviations except universal ones (`id`, `url`, `db`, `df` for a DataFrame).
- Single letters only for trivial loop indices or comprehensions (`i`, `k, v`).
- Put units in names when the type doesn't carry them: `delay_ms`, `size_bytes`.
- No type suffixes/prefixes: `orders` not `orders_list`, `settings` not `settings_obj`.
- **Absolute imports only** — `from my_pkg.models.order import Order`. Enforced by ruff
  (`TID252`, `ban-relative-imports = "all"`).
- Prefix private helpers with `_`. A layer's `__init__.py` stays empty (docstring only).

## 4. Components and dependency injection

Constructor injection, typed against Protocols, wired by hand in one composition root. No
DI framework, no module-level singletons.

```python
# src/my_pkg/repositories/order_repository.py
from typing import Protocol

from my_pkg.models.order import Order


class OrderRepository(Protocol):
    def get(self, order_id: str) -> Order: ...
    def save(self, order: Order) -> None: ...
```

```python
# src/my_pkg/services/order_service.py
import structlog

from my_pkg.errors import OrderNotFoundError
from my_pkg.repositories.order_repository import OrderRepository

log = structlog.get_logger(__name__)


class OrderService:
    """Apply order lifecycle rules on top of a repository.

    :param repository: where orders are read from and saved to
    """

    def __init__(self, repository: OrderRepository) -> None:
        self._repository = repository

    def cancel(self, order_id: str) -> None:
        """Cancel an order and persist the cancelled state.

        :param order_id: ID of the order to cancel
        :raises OrderNotFoundError: if no order exists with ``order_id``
        """
        order = self._repository.get(order_id)
        self._repository.save(order.cancelled())
        log.info("order_cancelled", order_id=order_id)
```

```python
# src/my_pkg/__main__.py — the composition root
def main() -> None:
    settings = Settings()
    configure_logging(settings.log_level, use_json_logs=settings.use_json_logs)
    service = OrderService(repository=SqlOrderRepository(settings.db_url))
    run_cli(service)
```

- Concrete implementations go in their own modules: `repositories/sql_order_repository.py`.
- Prefer a plain function when there is no state and no interface to satisfy.

## 5. Data types

| Use                                   | For                                                      |
|---------------------------------------|----------------------------------------------------------|
| Pydantic `BaseModel`, `ConfigDict(frozen=True)` | Internal domain objects in `models/`          |
| Pydantic `BaseModel`                  | Anything crossing a boundary: API payloads, external data, files |
| `pydantic_settings.BaseSettings`      | Runtime config, in `config.py` only                       |
| `typing.Protocol`                     | Interfaces between layers                                |

- **Pydantic only — no `@dataclass`, `NamedTuple` or `attrs`** for data types. Follow the
  `pydantic:pydantic` skill for constraints, validators, model hierarchies and serialization.
- Domain objects are immutable — "change" returns a new instance via
  `model.model_validate(model.model_dump() | changes)`. Avoid `model_copy(update=...)`: it
  skips validation.
- Never pass a raw `dict` between layers; give it a type.

## 6. Config

- One `Settings(BaseSettings)` in `config.py`, `frozen=True`, `env_prefix="MY_PKG_"`.
- Instantiated **once**, in `__main__.py`, then passed down — never `Settings()` inside a
  service or repository.
- Secrets come from env vars / a gitignored `.env` — never defaults in code. Type them
  `SecretStr`.

## 7. Errors

```python
# src/my_pkg/errors.py
class MyPkgError(Exception):
    """Base error for my_pkg — catch this to handle anything the package raises."""


class OrderNotFoundError(MyPkgError):
    def __init__(self, order_id: str) -> None:
        super().__init__(f"order {order_id!r} not found")
        self.order_id = order_id
```

- Every raised error derives from the package base `<Pkg>Error`.
- Wrap third-party exceptions at the repository boundary: `raise OrderNotFoundError(...) from exc`.
- Catch only in `api/` (to map to HTTP codes/exit codes) or where you can genuinely recover.
  No bare `except:`, no `except Exception: pass`.

## 8. Logging — structlog

- `configure_logging()` in `logging_setup.py`, called once from `__main__.py`.
- Per module: `log = structlog.get_logger(__name__)`. Never `print`.
- Events are `snake_case` verbs with fields as kwargs: `log.info("order_cancelled", order_id=...)`
  — never f-strings into the message.
- Correlation IDs: `structlog.contextvars.bind_contextvars(run_id=..., request_id=...)` at the
  entrypoint; every log line below inherits them.
- Never log secrets, tokens, or PII — mask/pseudonymise customer IDs, emails, phone numbers.

## 9. Docstrings — Sphinx (reST), no types

Every public module, class, method and function gets one. Types live **only** in the
annotations — never `:type:` or `:rtype:`, they drift from the signature.

```python
def cancel(self, order_id: str, *, reason: str = "customer_request") -> Order:
    """Cancel an order and persist the cancelled state.

    :param order_id: ID of the order to cancel
    :param reason: why the order is cancelled, defaults to "customer_request"
    :raises OrderNotFoundError: if no order exists with ``order_id``
    :return: the cancelled order
    """
```

- First line: one-sentence summary in the imperative, ending with a period.
- Order: summary → blank line → optional detail → `:param:` → `:raises:` → `:return:`.
- One `:param:` per parameter (skip `self`/`cls`); append `, defaults to <value>` when it has a default.
- One `:raises:` per exception the caller should handle.
- `:return:` only when the function returns something — omit it for `-> None`.
- Classes document constructor params in the class docstring, not in `__init__`.
- Private (`_`-prefixed) helpers and tests: docstring optional.

## 10. Readability

Optimise for the next reader, not for the fewest lines. Boring and obvious beats clever.

- **Guard clauses, early returns** — handle the edge cases first, keep the happy path un-indented.
  Max ~2 levels of nesting inside a function.
- **Small functions** — one job, one level of abstraction, ~30 lines max. If you need a
  comment to separate "steps", each step is a function.
- **Name intermediate values** instead of nesting calls or chaining long expressions.
- **No magic values** — `MAX_RETRIES = 3` at module level, not a bare `3` in a condition.
- **Keyword-only args** (`*`) for booleans and for 2+ params of the same type — call sites
  read `send(order, notify_customer=True)`, never `send(order, True)`.
- **Comprehensions only when they fit on one line** with at most one `if`; otherwise a loop.
- **Comments explain _why_, never _what_** — if the code needs a "what" comment, rename or
  extract instead.
- No dead code, commented-out code, or `TODO` without a ticket.

```python
# ❌ nested, magic number, positional bool, unnamed intermediates
def process(o, f):
    if o:
        if o.status != "cancelled":
            if len([i for i in o.items if i.qty > 0 and i.price > 0]) > 0:
                return send(o, f)


# ✅ guard clauses, named values, keyword-only flag
def ship_order(order: Order, *, notify_customer: bool) -> Shipment | None:
    if order.is_cancelled:
        return None

    billable_items = [item for item in order.items if item.is_billable]
    if not billable_items:
        return None

    return send_shipment(order, billable_items, notify_customer=notify_customer)
```

ruff enforces the measurable parts: `C90` (complexity ≤ 10), `PLR` (too many
args/branches/returns, magic values), `ERA` (commented-out code), `FBT` (positional bools).

## 11. Tests

- `tests/` mirrors `src/`, with `test_` prefixed to **every** directory and file:
  `src/my_pkg/services/order_service.py` → `tests/test_my_pkg/test_services/test_order_service.py`.
  `__main__.py` → `test_main.py`.
- The prefix keeps test dirs from shadowing the real package; with
  `--import-mode=importlib`, test dirs need no `__init__.py`.
- Fake your own Protocols with small in-memory classes; reserve `unittest.mock` for
  third-party code.
- Coverage gate **90%** with branch coverage, enforced in `pyproject.toml`.
- Test files are typed too (`-> None`), and covered by `mypy --strict`.

## 12. Toolchain

| Tool                | Run with                | Config                                   |
|---------------------|-------------------------|------------------------------------------|
| ruff lint + format  | `uv run ruff check --fix` · `uv run ruff format` | `[tool.ruff]`             |
| mypy `--strict`     | `uv run mypy`           | `[tool.mypy]` + `pydantic.mypy` plugin   |
| pytest + coverage   | `uv run pytest`         | `[tool.pytest.ini_options]`, `[tool.coverage.*]` |
| pre-commit          | `uv run pre-commit run --all-files` | local hooks calling `uv run` — same versions as the lockfile |

Pre-commit runs ruff + mypy on commit and pytest on push.

## ✅ Checklist before finishing

- [ ] New code sits in the right layer and imports only downward
- [ ] One concept per module, absolute imports only
- [ ] Classes, functions and variables have meaningful names — no `data`, `tmp`, `Manager`, `process`
- [ ] Readable: guard clauses, ≤ 2 nesting levels, small functions, no magic values, keyword-only bools
- [ ] Dependencies injected through `__init__`, typed as Protocols, wired in `__main__.py`
- [ ] All data types are Pydantic (domain models frozen) — no dataclasses
- [ ] Dagster repo → `dagster-expert` loaded and its layout respected
- [ ] Errors derive from `<Pkg>Error`; logs are structlog events with fields
- [ ] Public API has Sphinx docstrings — `:param:` / `:raises:` / `:return:`, no `:type:` / `:rtype:`
- [ ] `uv run pre-commit run --all-files` passes and `uv run pytest` stays ≥ 90%
