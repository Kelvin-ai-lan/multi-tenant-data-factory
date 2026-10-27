---
name: cross-db-compat
description: Enforces strict SQL portability guidelines to prevent codebase lock-in and enable smooth migration between Postgres and BigQuery.
---

## Task Execution Instructions

When working with cross-database code blocks, migrations, or database macros (`cross-db`, `bigquery_migration`, `sql_dialect`):

1. **Ban Native Dialects:** Prohibit the use of target-specific syntax shortcuts like double-colon notation (e.g., `::text` or `::timestamp`) and direct server-side system times like `NOW()` or `CURRENT_DATE`.
2. **Enforce Agnostic Macros:** Mandate the use of core cross-database dbt helper macros:
   - Use `{{ dbt.safe_cast(column, type) }}` for datatype translations.
   - Use standard wrappers like `{{ dbt.type_string() }}` or `{{ dbt.type_int() }}`.
   - Use agnostic time calculation wrappers like `{{ dbt.dateadd(...) }}` and `{{ dbt.current_timestamp() }}`.
