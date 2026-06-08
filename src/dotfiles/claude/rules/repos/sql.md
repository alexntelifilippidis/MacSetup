# Repo Conventions — SQL / Spark SQL

Applies inside Python files (`spark.sql(...)`, SQLAlchemy, dbt models) and Scala files (`spark.sql(...)`).

## Formatting

- Keywords: UPPERCASE — `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`
- Identifiers: `snake_case` — columns, tables, CTEs
- Indent: 2 spaces
- One column per line in `SELECT`
- Leading commas — `,col` not `col,`
- Always alias subqueries and CTEs

```sql
WITH active_users AS (
  SELECT
    user_id
    ,email
    ,created_at
  FROM users
  WHERE is_active = TRUE
)
SELECT
  au.user_id
  ,COUNT(e.event_id) AS event_count
FROM active_users AS au
LEFT JOIN events AS e
  ON au.user_id = e.user_id
GROUP BY au.user_id
```

## CTEs over Subqueries

- Always prefer CTEs (`WITH`) over nested subqueries
- One CTE per logical transformation step
- Name CTEs for what they represent, not what they do (`active_users` not `filtered`)

## Naming Conventions

- Tables: `snake_case`, plural — `user_events`, `order_items`
- Columns: `snake_case` — `user_id`, `created_at`
- Boolean columns: `is_*` or `has_*` — `is_active`, `has_subscription`
- Timestamp columns: `*_at` suffix — `created_at`, `updated_at`
- Date columns: `*_date` suffix — `order_date`
- Foreign keys: `<table>_id` — `user_id`, `order_id`

## Delta Lake / Spark SQL

- Prefer `MERGE INTO` for upserts over `INSERT OVERWRITE`
- Use `OPTIMIZE` + `ZORDER BY` on high-cardinality filter columns
- Partition by low-cardinality columns (date, region) — never by high-cardinality keys
- Always specify explicit column lists in `INSERT` — never rely on positional order
- `VACUUM` retention minimum 7 days — never set below Delta Lake default

## dbt (when applicable)

- Model naming: `<layer>_<entity>` — `stg_orders`, `fct_revenue`, `dim_users`
- Layers: `staging` → `intermediate` → `marts`
- Every model needs a `.yml` schema file with column descriptions and tests
- Use `ref()` and `source()` — never hardcode database/schema names
