# Database Migration Generator

Generate database migration files from a plain-English description of the schema change.

## Arguments

$ARGUMENTS - `<description>` - A natural language description of the migration, e.g. "add phone_number and verified columns to users table", "create posts table with title body author_id", "rename email to email_address in users", "add index on users.email".

## Instructions

### Step 1: Parse the Description

Analyze the migration description to determine:

- **Operation type**: CREATE TABLE, ADD COLUMN, DROP COLUMN, RENAME COLUMN, RENAME TABLE, ALTER COLUMN (type change), ADD INDEX, DROP INDEX, ADD CONSTRAINT, DROP CONSTRAINT, ADD FOREIGN KEY, CREATE ENUM, DATA MIGRATION
- **Target table(s)**: Which table(s) are affected
- **Columns involved**: Names, types, constraints
- **Relationships**: Foreign keys, references

Common description patterns:
```
"add X to Y"            --> ADD COLUMN X to table Y
"create X table"        --> CREATE TABLE X
"remove/drop X from Y"  --> DROP COLUMN X from table Y
"rename X to Z in Y"    --> RENAME COLUMN X to Z in table Y
"add index on X.Y"      --> CREATE INDEX on column Y of table X
"make X nullable in Y"  --> ALTER COLUMN X SET NULL in table Y
"change X type to Z"    --> ALTER COLUMN X TYPE Z
"add unique constraint" --> ADD UNIQUE CONSTRAINT
```

### Step 2: Detect Migration Tool

Search the project to determine which migration tool is in use:

1. **Prisma**: `prisma/schema.prisma` exists, `prisma` in package.json
2. **Drizzle**: `drizzle.config.ts` or `drizzle.config.js`, `drizzle-kit` in package.json
3. **Knex**: `knexfile.js` or `knexfile.ts`, `knex` in package.json
4. **TypeORM**: `typeorm` in package.json, `ormconfig` files
5. **Sequelize**: `sequelize` in package.json, `.sequelizerc`
6. **Django**: `manage.py` exists, Django in requirements
7. **Alembic**: `alembic.ini`, `alembic/` directory
8. **Flyway**: `flyway` configuration, `db/migration/` directory
9. **golang-migrate**: `migrate` in go.mod, `migrations/` directory with `.up.sql`/`.down.sql`
10. **goose**: `goose` in go.mod
11. **Liquibase**: `liquibase` configuration files
12. **Rails/ActiveRecord**: `Gemfile` with `rails`, `db/migrate/` directory

If no migration tool is detected, generate raw SQL migration files (up.sql + down.sql).

### Step 3: Infer Column Types

When columns are mentioned without explicit types, infer types from the column name:

```
Column Name Pattern       --> SQL Type              --> Prisma         --> Django
--------------------------|-------------------------|-----------------|------------------
*id (primary)             --> SERIAL / BIGSERIAL     --> Int @id        --> AutoField
*_id, *Id (foreign key)   --> INTEGER / BIGINT       --> Int            --> ForeignKey
*name*, *title*, *label*  --> VARCHAR(255)           --> String         --> CharField(255)
*email*                   --> VARCHAR(255)           --> String         --> EmailField
*password*, *hash*        --> VARCHAR(255)           --> String         --> CharField(255)
*description*, *bio*      --> TEXT                   --> String @db.Text--> TextField
*content*, *body*         --> TEXT                   --> String @db.Text--> TextField
*url*, *link*, *href*     --> VARCHAR(2048)          --> String         --> URLField
*phone*, *mobile*         --> VARCHAR(20)            --> String         --> CharField(20)
*slug*                    --> VARCHAR(255) UNIQUE    --> String @unique --> SlugField(unique)
*token*, *key*, *secret*  --> VARCHAR(255)           --> String         --> CharField(255)
*count*, *quantity*       --> INTEGER                --> Int            --> IntegerField
*price*, *amount*, *cost* --> DECIMAL(10,2)          --> Decimal        --> DecimalField(10,2)
*rating*, *score*         --> DECIMAL(3,2) or INT    --> Float          --> FloatField
*is_*, *has_*, *can_*     --> BOOLEAN DEFAULT false  --> Boolean        --> BooleanField
*active*, *enabled*       --> BOOLEAN DEFAULT true   --> Boolean        --> BooleanField
*verified*, *confirmed*   --> BOOLEAN DEFAULT false  --> Boolean        --> BooleanField
*date*, *_at*, *_on*      --> TIMESTAMP              --> DateTime       --> DateTimeField
*created*                 --> TIMESTAMP DEFAULT NOW  --> DateTime @default(now()) --> auto_now_add
*updated*                 --> TIMESTAMP              --> DateTime @updatedAt --> auto_now
*deleted*                 --> TIMESTAMP NULL         --> DateTime?      --> DateTimeField(null)
*status*                  --> VARCHAR(50)            --> String         --> CharField(50)
*type*, *kind*, *category*--> VARCHAR(50)            --> String         --> CharField(50)
*json*, *data*, *meta*    --> JSONB                  --> Json           --> JSONField
*image*, *avatar*, *photo*--> VARCHAR(2048)          --> String         --> ImageField/URLField
*ip*, *ip_address*        --> INET or VARCHAR(45)    --> String         --> GenericIPAddressField
*order*, *position*, *rank*-> INTEGER DEFAULT 0      --> Int @default(0)--> IntegerField(default=0)
*lat*, *latitude*         --> DECIMAL(10,8)          --> Float          --> FloatField
*lng*, *longitude*        --> DECIMAL(11,8)          --> Float          --> FloatField
*uuid*                    --> UUID DEFAULT gen_uuid  --> String @default(uuid()) --> UUIDField
```

### Step 4: Generate Migration

#### Prisma

Prisma uses schema-first migrations. Modify `prisma/schema.prisma`:

1. Edit the schema file to add/modify/remove the model or fields.
2. Instruct the user to run: `npx prisma migrate dev --name <migration_name>`
3. Show the exact schema changes being made.

For the schema edit, follow existing patterns in the file (spacing, field order, etc.).

#### Drizzle

Generate a migration file in the configured migrations directory:

```typescript
// drizzle/<timestamp>_<description>.ts
import { sql } from 'drizzle-orm';
import { pgTable, varchar, integer, boolean, timestamp } from 'drizzle-orm/pg-core';

export async function up(db) {
  await db.execute(sql`ALTER TABLE ... ADD COLUMN ...`);
}

export async function down(db) {
  await db.execute(sql`ALTER TABLE ... DROP COLUMN ...`);
}
```

Also update the Drizzle schema file if one exists.

#### Knex

Generate a migration file:

```javascript
// migrations/<timestamp>_<description>.js
exports.up = function(knex) {
  return knex.schema.alterTable('<table>', function(table) {
    table.string('phone_number', 20);
    table.boolean('verified').defaultTo(false);
  });
};

exports.down = function(knex) {
  return knex.schema.alterTable('<table>', function(table) {
    table.dropColumn('phone_number');
    table.dropColumn('verified');
  });
};
```

#### Django

Generate a Django migration file:

```python
# <app>/migrations/<NNNN>_<description>.py
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('<app>', '<previous_migration>'),
    ]

    operations = [
        migrations.AddField(
            model_name='<model>',
            name='phone_number',
            field=models.CharField(max_length=20, blank=True, null=True),
        ),
    ]
```

Also update the Django model file to keep it in sync.

Detect the app name from the directory structure, and find the latest migration to set as dependency.

#### Alembic

Generate an Alembic migration:

```python
# alembic/versions/<revision>_<description>.py
"""<description>"""
from alembic import op
import sqlalchemy as sa

revision = '<generated_hash>'
down_revision = '<previous_revision>'
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.add_column('<table>', sa.Column('phone_number', sa.String(20), nullable=True))
    op.add_column('<table>', sa.Column('verified', sa.Boolean(), server_default='false'))

def downgrade() -> None:
    op.drop_column('<table>', 'verified')
    op.drop_column('<table>', 'phone_number')
```

Find the latest revision (head) for the `down_revision`.

#### golang-migrate

Generate paired SQL migration files:

```sql
-- <timestamp>_<description>.up.sql
ALTER TABLE <table> ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE <table> ADD COLUMN verified BOOLEAN NOT NULL DEFAULT false;

-- <timestamp>_<description>.down.sql
ALTER TABLE <table> DROP COLUMN IF EXISTS verified;
ALTER TABLE <table> DROP COLUMN IF EXISTS phone_number;
```

#### Raw SQL (fallback)

Generate paired SQL files:

```sql
-- migrations/<timestamp>_<description>.up.sql
BEGIN;
ALTER TABLE <table> ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE <table> ADD COLUMN verified BOOLEAN NOT NULL DEFAULT false;
COMMIT;

-- migrations/<timestamp>_<description>.down.sql
BEGIN;
ALTER TABLE <table> DROP COLUMN IF EXISTS verified;
ALTER TABLE <table> DROP COLUMN IF EXISTS phone_number;
COMMIT;
```

### Step 5: Safety Checks and Warnings

Analyze the migration for potentially dangerous operations and emit warnings:

**DANGER - Data Loss Risk**:
- Dropping a column: "WARNING: Dropping column '<col>' will permanently delete all data in that column. Ensure you have a backup or have migrated the data."
- Dropping a table: "WARNING: Dropping table '<table>' will permanently delete all data. This cannot be undone."
- Changing column type: "WARNING: Changing column type from <old> to <new> may cause data loss if existing values cannot be cast."
- Removing a NOT NULL constraint on a column that may have NULLs after rollback.

**CAUTION - Performance Risk**:
- Adding a NOT NULL column without a default to a large table: "CAUTION: This will lock the table and may fail if existing rows exist. Consider adding as nullable first, backfilling, then adding NOT NULL constraint."
- Adding an index on a large table: "CAUTION: Creating an index on a large table can lock it. Consider using CREATE INDEX CONCURRENTLY (PostgreSQL) or equivalent."
- Running a data migration on a large table: "CAUTION: Data migration on large tables should be batched to avoid long-running transactions."

**INFO - Best Practices**:
- Foreign key without index: "INFO: Consider adding an index on the foreign key column for query performance."
- String column without length: "INFO: Defaulting to VARCHAR(255). Adjust if you need longer values."

### Step 6: Generate Timestamp/Name

Name the migration file following the tool's convention:
- Knex/golang-migrate: `<YYYYMMDDHHmmss>_<snake_case_description>`
- Alembic: `<short_hash>_<snake_case_description>`
- Django: `<NNNN>_<snake_case_description>` (auto-incremented number)
- Flyway: `V<version>__<description>`
- Raw SQL: `<YYYYMMDDHHmmss>_<snake_case_description>`

### Step 7: Summary

Print:
1. Migration tool detected
2. Operation summary (what the migration does)
3. Generated file path(s)
4. Up migration: what it changes
5. Down migration: how to rollback
6. Any warnings (data loss, performance, etc.)
7. Command to run the migration (e.g., `npx prisma migrate dev`, `python manage.py migrate`, `knex migrate:latest`)
8. Command to rollback (e.g., `knex migrate:rollback`, `python manage.py migrate <app> <previous>`)
