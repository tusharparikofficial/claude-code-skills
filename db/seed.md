# Database Seed Data Generator

Generate realistic seed data for the project's database models.

## Arguments

$ARGUMENTS - Optional record count (e.g., "100", "1000") or leave blank for default (50 per model)

## Instructions

1. **Detect the project's ORM and models**:
   - Read `package.json`, `pyproject.toml`, `go.mod` to identify the framework.
   - Find model/schema definitions: Prisma schema, Drizzle schemas, TypeORM entities, Django models, SQLAlchemy models, Go structs with DB tags.
   - Parse each model: field names, types, constraints (required, unique, FK, enum values, defaults).

2. **Map relationships**:
   - Identify foreign key relationships between models.
   - Build a dependency graph: which models must be seeded first (parents before children).
   - Topologically sort models to determine seeding order.
   - Identify many-to-many junction tables.

3. **Generate realistic data** for each field type:
   - **Names**: Use realistic first/last names (not "Test User 1").
   - **Emails**: Generate from the name (e.g., john.smith@example.com). Ensure uniqueness.
   - **Dates**: Use realistic date ranges (birthdates 18-80 years ago, created_at in the last 2 years).
   - **Enums**: Distribute values realistically (not all the same value).
   - **Text**: Use realistic short descriptions, not lorem ipsum.
   - **Numbers**: Use realistic ranges (price: 9.99-999.99, quantity: 1-100).
   - **Booleans**: Mix true/false with realistic distribution (e.g., 90% active users).
   - **UUIDs**: Generate valid v4 UUIDs.
   - **JSON fields**: Generate valid JSON matching the expected structure.

4. **Ensure deterministic output**:
   - Use a fixed seed for the random number generator so runs produce identical data.
   - Document the seed value and how to change it.
   - Same input always produces same output for reproducible environments.

5. **Handle constraints**:
   - **Unique fields**: Track generated values and ensure no duplicates.
   - **Foreign keys**: Reference only IDs that have been created in earlier seed steps.
   - **NOT NULL**: Always provide values for required fields.
   - **Check constraints**: Generate values within valid ranges.
   - **Cascade deletes**: Document the order for teardown/cleanup.

6. **Generate the seed script** in the project's framework format:
   - **Prisma**: `prisma/seed.ts` using `prisma.model.createMany()`.
   - **Drizzle**: Seed file using `db.insert(table).values([...])`.
   - **Django**: Management command or fixture JSON.
   - **SQLAlchemy**: Python script using `session.add_all()`.
   - **TypeORM**: Seed file using repository or query builder.
   - **Raw SQL**: INSERT statements in correct order with ON CONFLICT handling.

7. **Add cleanup function**:
   - Delete seeded data in reverse dependency order.
   - Use transactions so cleanup is atomic.
   - Guard against running cleanup in production (check environment variable).

8. **Add CLI integration**:
   - `seed` - Run the seed script.
   - `seed --count N` - Override the default record count.
   - `seed --clean` - Remove all seeded data.
   - `seed --clean --seed` - Reset and re-seed.

9. **Parse `$ARGUMENTS`** for count: if a number is provided, use it as the per-model record count. Default to 50 if not specified.
