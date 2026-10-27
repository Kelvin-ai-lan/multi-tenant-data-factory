---
name: dbt-staging-generator
description: Automatically structures, cleans, and builds dbt staging files and source configurations when handling raw datasets.
---

<!-- Tip: Use /create-skill in chat to generate content with agent assistance -->

## Task Execution Instructions
When generating staging files or checking source manifests (`staging`, `source_yml`, `stg_`):

1. **Sources Mapping:** Build schemas inside `models/staging/_src__sources.yml` declaring database tables under the parent source key `raw_ecommerce`.
2. **Casting & Renaming:** Explicitly cast numeric, textual, and timestamp parameters using production-standard data modeling configurations. Convert all unstructured source names into uniform `snake_case`.
3. **Data Quality Filters:** Append strict conditional filtering statements inside the base staging CTE layer to remove records where validation check flags—specifically `is_quarantined` or `is_exact_duplicate_row`—evaluate as true.
