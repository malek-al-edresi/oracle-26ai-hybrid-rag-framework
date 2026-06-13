# Installation Guide

Deploying the Oracle Vector Search RAG Toolkit into your environment is designed to be as seamless as possible.

## Prerequisites

Before starting, ensure your environment meets the following requirements:
1. **Oracle Database**: Oracle Database 23ai or 26ai.
2. **Privileges**: Your database schema must have the required privileges to create `TABLES`, `VIEWS`, `PACKAGES`, `TRIGGERS`, and `INDEXES`.
3. **ONNX Models (Optional but Recommended)**: The toolkit by default relies on the `E5_SMALL` model being imported into the database using `DBMS_VECTOR.LOAD_ONNX_MODEL`.
4. **Tools**: Oracle SQLcl, SQL*Plus, or Oracle APEX SQL Commands.

## Step-by-Step Installation

### 1. Download the Toolkit
Clone or download the repository to your local machine:
```bash
git clone https://github.com/your-username/oracle-vector-search-rag-toolkit.git
cd oracle-vector-search-rag-toolkit
```

### 2. Connect to your Database
Connect to your target Oracle Database schema using SQLcl:
```bash
sqlcl user/password@//localhost:1521/FREE
```

### 3. Run the Install Script
The `scripts/` directory contains a master `install.sql` script that sequentially deploys all required objects.

```sql
SQL> @scripts/install.sql
```

The script will output the progress as it creates:
- Tables & Constraints
- Views
- PL/SQL Packages (Specifications and Bodies)
- Triggers
- Vector Indexes

### 4. Verify the Installation
Run the built-in system health check to ensure everything is functioning correctly:

```sql
SET SERVEROUTPUT ON;
DECLARE
    v_health_report CLOB;
BEGIN
    v_health_report := AI_SEC_RAG_SYSTEM_ALL_SUB_ADMIN_PKG.check_system_health();
    DBMS_OUTPUT.PUT_LINE(v_health_report);
END;
/
```
If the status returns `HEALTHY`, your installation was successful!

## Uninstallation

If you need to completely remove the toolkit from your schema, run the uninstallation script:

```sql
SQL> @scripts/uninstall.sql
```
> [!WARNING]
> Running the uninstall script will `DROP` all tables and **permanently delete** all indexed documents, chunks, and embeddings.
