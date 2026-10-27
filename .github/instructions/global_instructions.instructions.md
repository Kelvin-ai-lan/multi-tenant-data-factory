---
description: Automatically loaded when working inside the dbt Core project to enforce workspace boundaries and generalist syntax rules.
---

# PROJECT CONTEXT & DIRECTORY BOUNDARIES

All tasks must execute strictly within the boundaries of this verified local workspace setup. The pipeline layout must remain strictly database-agnostic to enable running on local development environments while supporting frictionless cloud migration pipelines.

- **Project Path:** `C:\Users\kelvin\Downloads\ecommerce_transform\ecommerce_db_pg`

## 1. Directory Governance Standard

- `models/staging/`: Houses inbound schema abstraction manifests, explicit datatype standardization, data quality isolating logic, and universal field-renaming translations.
- `models/marts/`: Houses clean business domain models, dimensional matrices, and transactional factual modules mapped exclusively via structural `{{ ref() }}` macro functions.

## 2. Generalist Syntax Guardrails

- Under no circumstances will you generate DDL/DML mutation keywords (`CREATE TABLE`, `DROP`, `INSERT INTO`).
- Code exclusively in modular, highly readable `SELECT` query block structures utilizing isolated Common Table Expressions (CTEs).
- Never hardcode physical schema names or database prefixes in model files; enforce absolute reliance on dbt configuration parameters (`{{ source() }}` and `{{ ref() }}`).
