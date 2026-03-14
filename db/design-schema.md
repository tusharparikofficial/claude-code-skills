# Database Schema Designer

Design a complete database schema from a natural language description, generating entities, relationships, indexes, migration code, and an ER diagram.

## Arguments

$ARGUMENTS - Required description of the domain and entities. Examples: `multi-tenant SaaS with users, teams, projects, tasks`, `e-commerce platform with products, categories, orders, reviews`, `blog with posts, comments, tags, and user roles`. Be as descriptive as possible for a richer schema.

## Instructions

You are designing a database schema from requirements. Follow these steps precisely.

### Step 1: Detect Project Stack

Before designing, check the project for existing database tooling:

| ORM/Tool | Detection |
|----------|-----------|
| Prisma | `schema.prisma`, `@prisma/client` in `package.json` |
| Drizzle | `drizzle.config.ts`, `drizzle-orm` in `package.json` |
| TypeORM | `typeorm` in `package.json`, `@Entity()` decorators |
| Sequelize | `sequelize` in `package.json` |
| SQLAlchemy | `sqlalchemy` in `requirements.txt` or `pyproject.toml` |
| Django | `django` in `requirements.txt`, `models.py` pattern |
| GORM | `gorm.io/gorm` in `go.mod` |
| Knex | `knex` in `package.json` |
| golang-migrate | `golang-migrate` in `go.mod` |
| None detected | Default to raw SQL (PostgreSQL dialect) |

Also detect the database engine (PostgreSQL, MySQL, SQLite, MongoDB) from connection strings or configuration.

If no project context exists, ask the user or default to PostgreSQL with raw SQL.

### Step 2: Analyze Requirements

Parse `$ARGUMENTS` to extract:

1. **Entities**: Nouns in the description (users, teams, projects, tasks)
2. **Relationships**: Implied connections (users belong to teams, projects have tasks)
3. **Features**: Multi-tenancy, soft delete, audit trails, versioning, etc.
4. **Domain rules**: Business constraints implied by the description

### Step 3: Design Entities

For each entity, define:

#### Standard Fields (included on every table)
```
id          - Primary key (UUID v4 or auto-increment based on project convention)
created_at  - Timestamp, NOT NULL, DEFAULT NOW()
updated_at  - Timestamp, NOT NULL, DEFAULT NOW(), auto-updated
```

#### Optional Standard Fields (include where appropriate)
```
deleted_at  - Timestamp, nullable (for soft delete)
created_by  - FK to users, nullable (for audit trail)
updated_by  - FK to users, nullable (for audit trail)
```

#### Entity-Specific Fields
For each entity, design fields following these principles:

1. **Naming**: Use `snake_case` for column names
2. **Types**: Choose the most appropriate type:
   - `uuid` for IDs (preferred) or `bigint` for auto-increment
   - `varchar(N)` with appropriate length limits, not unbounded `text` for short strings
   - `text` only for long-form content (descriptions, body text)
   - `boolean` for flags, NOT `int` or `smallint`
   - `timestamptz` for all timestamps (timezone-aware)
   - `decimal(precision, scale)` for money, NOT `float`
   - `jsonb` for flexible/nested data (PostgreSQL), use sparingly
   - `enum` or lookup table for fixed value sets
3. **Constraints**:
   - `NOT NULL` by default; only make nullable with good reason
   - `UNIQUE` on natural keys (email, slug, username)
   - `CHECK` constraints for value ranges
   - `DEFAULT` values where sensible
4. **Foreign Keys**: Always define with `ON DELETE` behavior:
   - `CASCADE`: Child deleted when parent deleted (order items when order deleted)
   - `SET NULL`: Reference nulled when parent deleted (assigned_to when user deleted)
   - `RESTRICT`: Prevent parent deletion if children exist (user with orders)

### Step 4: Design Relationships

Map all relationships:

| Relationship | Implementation |
|-------------|---------------|
| One-to-One | FK with UNIQUE constraint on the "has one" side |
| One-to-Many | FK on the "many" side referencing the "one" side |
| Many-to-Many | Join table with composite PK or surrogate PK + unique constraint |
| Self-referential | FK referencing same table (e.g., `parent_id` on categories) |
| Polymorphic | Discriminator column + nullable FKs, or separate join tables per type |

For many-to-many join tables:
- Name as `entity1_entity2` (alphabetical order) or a domain-specific name (e.g., `team_members` instead of `teams_users`)
- Include `created_at` for when the relationship was established
- Include any relationship-specific fields (e.g., `role` on team_members)

### Step 5: Design Indexes

Create indexes following these rules:

1. **Primary keys**: Automatically indexed
2. **Foreign keys**: ALWAYS create an index on every FK column
3. **Unique constraints**: Automatically create unique indexes
4. **Query-pattern indexes**: Based on expected query patterns:
   - Composite indexes for common filter combinations (most selective column first)
   - Covering indexes for frequently-run queries (INCLUDE clause)
   - Partial indexes for filtered queries (WHERE clause on index)
5. **Sorting indexes**: For common ORDER BY patterns, include the sort column in a composite index
6. **Full-text search**: GIN index on `tsvector` columns (PostgreSQL) for text search

Name indexes as: `idx_{table}_{columns}` (e.g., `idx_orders_user_id_status`)

### Step 6: Handle Special Patterns

Based on the requirements, apply these patterns where appropriate:

#### Multi-Tenancy
- Add `tenant_id` (or `organization_id`) FK to every tenant-scoped table
- Include `tenant_id` as the first column in all composite indexes
- Consider Row Level Security (RLS) policies for PostgreSQL
- Add CHECK constraint or trigger to prevent cross-tenant references

#### Soft Delete
- Add `deleted_at` timestamp column (nullable, NULL = active)
- Create partial index: `WHERE deleted_at IS NULL` for active record queries
- Application must filter by `deleted_at IS NULL` in all queries (or use middleware/scope)

#### Audit Trail
- Add `created_by`, `updated_by` FK columns
- Consider a separate `audit_log` table for full change tracking:
  ```
  audit_log: id, table_name, record_id, action (INSERT/UPDATE/DELETE), old_values (jsonb), new_values (jsonb), user_id, timestamp
  ```

#### Versioning
- Add `version` integer column with optimistic locking
- Or separate `_history` table for full version tracking

#### Slug/URL-friendly identifiers
- Add `slug` varchar column with UNIQUE constraint
- Generate from title/name with collision handling

### Step 7: Generate Schema Code

Generate the schema in the format matching the detected project stack.

#### If Prisma:
```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  // ... fields
  posts     Post[]
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
  @@index([email])
}
```

#### If Drizzle:
```typescript
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  name: varchar('name', { length: 255 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (table) => ({
  emailIdx: index('idx_users_email').on(table.email),
}));
```

#### If Django:
```python
class User(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, max_length=255)
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users'
        indexes = [models.Index(fields=['email'], name='idx_users_email')]
```

#### If SQLAlchemy:
```python
class User(Base):
    __tablename__ = 'users'
    id = mapped_column(UUID, primary_key=True, default=uuid4)
    email = mapped_column(String(255), unique=True, nullable=False)
    name = mapped_column(String(255), nullable=False)
    created_at = mapped_column(DateTime, server_default=func.now(), nullable=False)
    updated_at = mapped_column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
```

#### If Raw SQL:
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users (email);
```

### Step 8: Generate ER Diagram

Generate a Mermaid `erDiagram` showing all entities, their fields, and relationships. Follow the same conventions as the `er-diagram` skill.

### Step 9: Output

Present in this order:

1. **Requirements Summary**: Restated requirements and assumptions made
2. **Entity List**: Table of all entities with field count and description
3. **Schema Code**: Full schema in the detected ORM format (or raw SQL)
4. **ER Diagram**: Mermaid diagram in a fenced code block
5. **Index Strategy**: Table of all indexes with rationale
6. **Migration Notes**: Any considerations for applying this schema:
   - Recommended migration order (respecting FK dependencies)
   - Seed data suggestions
   - Performance considerations for large datasets
7. **Design Decisions**: Brief explanation of key choices made:
   - Why UUID vs auto-increment
   - Why certain relationships were modeled as they were
   - Any normalization trade-offs

Do NOT save to a file unless the user explicitly asks. Output everything directly in the response so the user can review before committing to the schema.
