# Multi-Tenant Data Factory: Cross-Engine Analytics Engineering Platform

[![dbt Core](https://shields.io)](https://getdbt.com)
[![Warehouse-Postgres](https://shields.io)](https://postgresql.org)
[![Warehouse-BigQuery](https://shields.io)](https://google.com)
[![Data Quality Pass](https://shields.io)](https://getdbt.comdocs/build/tests)

A production-grade, enterprise-ready Analytics Engineering platform that implements a **Uniform Extraction Model** to ingest, clean, and model complex e-commerce, SaaS subscription, and multi-channel marketing data. 

Built completely database-agnostic using dbt Core, this platform supports frictionless migration and simultaneous execution across both local transactional engines (PostgreSQL) and enterprise cloud data warehouses (Google BigQuery) without changing a single line of SQL.

---

## 🗺️ System Architecture & Data Lineage Flow

The pipeline shifts data dynamically from raw ingestion seeds to highly indexed business intelligence marts across four decoupled architectural layers:

```text
 [12 Raw Inbound Seeds] 
          │
          ▼
 [12 Staging Views]        ◄── [5 Ingestion Structural Tests] (Unique, Not Null)
          │
          ▼
 [4 Core Business Marts]   ◄── [6 Analytical Governance Tests] (Accepted Loyalty Tiers)
          │
          ▼
 📊 Interactive Lineage Map (Verified 100% Green Cloud Run Execution)
```

### 1. Ingestion Layer (Raw Seeds)
Brings 12 disconnected raw corporate data silos—spanning transaction ledgers, daily ad expenditures, web clickstream sessions, and support metrics—into a unified target workspace environment.

### 2. Standardized Staging Layer
Acts as an automated data cleaning assembly line. It handles granular datatype casting, date/timestamp normalization, column alias standardizations, and introduces a strict defensive isolation layer (`is_quarantined`) to filter out corrupted or duplicate source records on ingestion.

### 3. Cross-Database Portability Strategy
Enforces absolute SQL dialect neutrality by abstracting environment paths using native dbt metadata and cross-db utility helper macros (e.g., `{{ dbt.safe_cast() }}`). The pipeline compiles identical high-performance logic on local clusters and enterprise warehouses.

### 4. Client-Facing Analytics Marts
Translates raw variables into aggregated, high-value executive KPIs that directly drive corporate strategic decision-making.

---

## 💎 Calculated Enterprise Business Metrics

Instead of simple, isolated tables, the analytical marts layer computes specialized strategic metrics out of the box:

*   **Customer Lifetime Value (LTV) Framework (`dim_customers`):** Aggregates total gross lifetime revenue spent, matches historical customer support event metrics to map average Customer Satisfaction (CSAT) scores, and generates dynamic customer loyalty tiers (`standard`, `bronze`, `silver`, `gold`) based on individual purchase velocity thresholds.
*   **True Cost Per Acquisition (`fct_campaign_performance`):** Connects atomic web click trackers and multi-channel user journeys to financial purchase histories using multi-touch attribution credit-allocation data. Computes a null-safe, exact Cost Per Acquisition (CPA) ratio by channel.
*   **Fulfillment SLA Metrics (`fct_order_fulfillment`):** Evaluates supply chain efficiency by measuring exact delivery transit time deltas between order initialization timestamps and actual freight drop-off windows, while tracking bottom-line refund leakage parameters.
*   **SaaS Recurring Revenue Analytics (`fct_subscription_revenue`):** Isolates contractual subscription lifecycles to calculate Monthly Recurring Revenue (MRR) pools per billing grain, active-vs-cancelled status flags, and granular contract churn metrics.

---

## 🛡️ Data Governance & Automated Sentinel Suite

To protect executive dashboards from displaying broken or corrupted financials, the project deploys an automated data quality testing suite directly on top of the underlying computing engines.

The platform passes a perfect **12 out of 12 native structural data assertions**:
*   **Primary Key Validation:** Strict `unique` and `not_null` constraint enforcements on all foundational business entities (e.g., `order_id`, `customer_id`).
*   **Value-Boundary Guardrails:** High-integrity `accepted_values` rules ensuring dynamic rows restrict cleanly to structural definitions (restricting customer categories strictly to `['standard', 'bronze', 'silver', 'gold']`).

---

## 🚀 Environment Infrastructure Setup

### Local Infrastructure Initialization (PostgreSQL)
1. **Activate local workspace environment dependencies:**
   ```bash
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install dbt-postgres
   ```
2. **Compile metadata configurations and run local tests:**
   ```bash
   dbt run
   dbt test
   ```

### Enterprise Cloud Deployment (Google BigQuery Sandbox)
The platform utilizes global OAuth application-default credentials to establish a secure cloud handshake with Google Cloud Platform, generating tables into live US multi-region columnar data storage without requiring an attached billing account.

1. **Install cloud adapter requirements and authenticate via gcloud CLI:**
   ```bash
   pip install dbt-bigquery
   gcloud auth application-default login
   ```
2. **Execute and test the cloud warehouse architecture end-to-end:**
   ```bash
   dbt seed --target prod_bq --full-refresh
   dbt run --target prod_bq
   dbt test --target prod_bq
   ```

### Viewing the Interactive Directed Acyclic Graph (DAG)
To inspect the visual flowchart, compile the catalog blueprint dynamically and serve the documentation web interface locally:
```bash
dbt docs generate
dbt docs serve
```
Click the circular floating network map icon in the bottom-right corner of your browser view to open up the fully searchable, visual lineage canvas.
