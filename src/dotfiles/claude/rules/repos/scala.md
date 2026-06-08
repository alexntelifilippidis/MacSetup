# Repo Conventions — Scala

## Stack

- Scala 2.12 + (not 3.x — check `build.sbt` for `scalaVersion`)
- Build tool: SBT
- Spark: Apache Spark 3.x + Delta Lake
- Databricks runtime (production target)

## Project Structure

```
<project>/
├── build.sbt
├── project/
│   ├── build.properties     # sbt version
│   └── plugins.sbt
└── src/
    ├── main/
    │   └── scala/
    │       └── com/<org>/<project>/
    │           ├── Main.scala
    │           ├── jobs/
    │           └── utils/
    └── test/
        └── scala/
            └── com/<org>/<project>/
```

## SBT Commands

```bash
sbt compile
sbt test
sbt "testOnly *ClassName*"
sbt package              # produces fat jar for Databricks deployment
sbt scalafmtAll          # format (if scalafmt configured)
```

## Code Rules

- `case class` for data models — immutable by default
- Avoid `var` — prefer `val`
- Pattern match over `if/else` chains
- `Option` over `null` — never return `null`
- Avoid `.get` on `Option` — use `getOrElse`, `fold`, or pattern match
- Keep Spark transformations in pure functions that take and return `DataFrame`
- No side effects inside `Dataset.map` / `Dataset.flatMap`

## Spark / Delta Lake

- Use `SparkSession` injected as implicit or parameter — never `SparkSession.builder` inside a function
- Prefer `DataFrame` API over raw SQL strings in Scala code
- Delta merge for upserts — never overwrite a full table unless explicitly required
- Checkpoint streaming jobs — always set `checkpointLocation`
- Cache only when a `DataFrame` is used more than twice in the same job

## SQL within Scala

See `@.claude/rules/repos/sql.md` for Spark SQL conventions used inside Scala string literals or `spark.sql(...)` calls.
