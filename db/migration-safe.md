# Zero-Downtime Database Migration

Generate safe, zero-downtime database migrations using the expand-contract pattern.

## Arguments

$ARGUMENTS - Description of the schema change (e.g., "rename users.name to users.full_name", "add NOT NULL constraint to orders.email")

## Instructions

1. **Detect the project's ORM and database** by reading `package.json`, `pyproject.toml`, `go.mod`, or config files. Identify: Prisma, Drizzle, TypeORM, Knex, Django, SQLAlchemy, golang-migrate, or raw SQL.

2. **Analyze the change** described in `$ARGUMENTS`:
   - Classify the change type: column rename, type change, add NOT NULL, drop column, add index, table rename, add FK constraint.
   - Identify the risk level: safe (additive), moderate (index, nullable change), dangerous (rename, type change, drop).
   - Determine if the change can be done in a single step or requires expand-contract.

3. **Generate expand-contract migrations** for dangerous changes:

   **Column Rename** (`old_name` -> `new_name`):
   - Phase 1 (Expand): Add `new_name` column. Create trigger to sync `old_name` -> `new_name`. Backfill existing data.
   - Phase 2 (Migrate code): Update application to read/write `new_name`. Deploy.
   - Phase 3 (Contract): Drop trigger. Drop `old_name` column.

   **Type Change** (e.g., varchar -> integer):
   - Phase 1 (Expand): Add new column with target type. Create trigger to sync and cast. Backfill with cast + error handling.
   - Phase 2 (Migrate code): Update application to use new column. Deploy.
   - Phase 3 (Contract): Drop trigger. Drop old column. Rename new column if needed.

   **Add NOT NULL**:
   - Phase 1: Add default value or backfill NULLs. Update application to always provide value.
   - Phase 2: Add NOT NULL constraint (use `ALTER TABLE ... SET NOT NULL` or equivalent).
   - Phase 3: Remove default if it was temporary.

   **Add Index**:
   - Use `CREATE INDEX CONCURRENTLY` (Postgres) or equivalent non-locking syntax.
   - Add `IF NOT EXISTS` guard.
   - Set appropriate `statement_timeout` to avoid long locks.

4. **For each phase, generate**:
   - **Migration file**: Using the project's ORM migration format.
   - **Verification query**: SQL to confirm the migration applied correctly (e.g., check column exists, data backfilled, constraint active).
   - **Rollback migration**: Reverse the change safely.
   - **Estimated duration**: Based on table size heuristics.

5. **Add safety checks**:
   - Before each migration: verify preconditions (column exists, table not locked, no long-running queries).
   - After each migration: run verification query.
   - Lock timeout: set a short lock timeout (5s) so migrations fail fast instead of blocking.
   - Transaction boundaries: wrap DDL in transactions where supported (Postgres), avoid for MySQL DDL.

6. **Generate deployment instructions**:
   - Step-by-step runbook for each phase.
   - What to monitor during migration (lock waits, replication lag, error rates).
   - Rollback procedure for each phase.
   - Estimated total time including code deployment between phases.

7. **Write the migration files** in the project's migration directory, following the existing naming convention and format.
