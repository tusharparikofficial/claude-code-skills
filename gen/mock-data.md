# Mock Data Generator

Generate realistic mock/seed data from a model or schema definition.

## Arguments

$ARGUMENTS - `<model-name> [count]` - Name of the model/schema to generate data for. Optionally specify the number of records (default: 10).

## Instructions

### Step 1: Parse Arguments

- **model-name**: The first argument. The name of an entity, model, type, or schema in the project.
- **count**: The second argument (optional, default 10). Must be a positive integer. Maximum recommended: 1000.

### Step 2: Locate the Model Definition

Search the project for the model/schema definition:

1. **TypeScript**: Search for `interface <ModelName>`, `type <ModelName>`, Zod schema `<ModelName>Schema`, Prisma model in `schema.prisma`, Drizzle table definition, TypeORM entity.
2. **Python**: Search for Django model `class <ModelName>(models.Model)`, SQLAlchemy model, Pydantic model `class <ModelName>(BaseModel)`, dataclass.
3. **Go**: Search for `type <ModelName> struct`.
4. **Java**: Search for `@Entity class <ModelName>`, record, DTO.

If multiple related models are found (e.g., `User` and `UserProfile`), note the relationships for referential integrity.

### Step 3: Extract Field Information

For each field in the model, extract:
- **Field name**
- **Field type** (string, number, boolean, date, enum, relation, etc.)
- **Constraints** (nullable, unique, min/max, default, foreign key)
- **Enum values** (if applicable)
- **Relationship info** (belongsTo, hasMany, etc.)

### Step 4: Generate Realistic Data

Apply smart data generation rules based on field name and type. Use deterministic patterns (seeded) so regeneration produces the same data.

**Name-based data patterns**:
```
Field Name Pattern        --> Generated Data
-----------------------------------------------------------------
*firstName*, *first_name* --> Realistic first names (mix of genders, ethnicities)
*lastName*, *last_name*   --> Realistic last names
*name* (generic)          --> Full names (first + last)
*email*                   --> <lowercase_first>.<lowercase_last>@example.com (or other domains)
*username*                --> lowercase first + random digits
*password*, *hash*        --> bcrypt-like hash string "$2b$10$..." (NOT real passwords)
*phone*, *mobile*, *tel*  --> Formatted phone numbers "+1-555-XXX-XXXX"
*avatar*, *image*, *photo*--> URL to placeholder image "https://picsum.photos/seed/<id>/200"
*url*, *website*, *link*  --> "https://example-<n>.com"
*address*, *street*       --> Realistic street addresses
*city*                    --> Real city names
*state*                   --> Real state/province names
*country*                 --> Real country names (ISO codes if type is short string)
*zip*, *postal*           --> Valid-format zip codes
*lat*, *latitude*         --> Latitude between -90 and 90 (realistic city coordinates)
*lng*, *lon*, *longitude* --> Longitude between -180 and 180
*title*                   --> Realistic titles/headings
*description*, *bio*, *about*, *summary* --> Lorem-ipsum-like paragraph (1-3 sentences)
*content*, *body*         --> Longer text (2-5 paragraphs)
*slug*                    --> URL-friendly slug derived from title
*tags*, *labels*          --> Array of 2-5 realistic tag strings
*color*, *colour*         --> Hex color codes "#A1B2C3"
*price*, *amount*, *cost* --> Decimal number (10.00 - 999.99)
*quantity*, *count*, *stock* --> Integer (1-100)
*rating*, *score*         --> Number in range (1-5 or 0-100 based on type)
*status*                  --> From enum values, or "active"/"inactive"/"pending"
*type*, *category*        --> From enum values, or realistic categories
*role*                    --> "admin", "user", "editor", "viewer"
*age*                     --> Integer 18-80
*date*, *createdAt*, *created_at* --> ISO date string within last 2 years
*updatedAt*, *updated_at* --> ISO date after createdAt
*deletedAt*, *deleted_at* --> null (mostly) or ISO date after updatedAt
*startDate*, *start_date* --> Future date within 1 year
*endDate*, *end_date*     --> Date after startDate
*dob*, *birthday*, *birthDate* --> Date 18-80 years ago
*isActive*, *is_active*, *enabled*, *verified* --> Boolean (80% true)
*id*                      --> UUID v4 or sequential integer based on type
*token*, *apiKey*         --> Random hex string (32-64 chars)
*ip*, *ipAddress*         --> "192.168.X.X" or "10.0.X.X" (private ranges only)
*userAgent*               --> Realistic browser user agent string
```

**Type-based fallbacks** (when name doesn't match above):
```
string   --> "sample_<fieldName>_<index>"
number   --> Random number in reasonable range
integer  --> Random integer 1-1000
boolean  --> Random true/false (50/50)
date     --> Random date within last year
uuid     --> Random UUID v4
json     --> { "key": "value_<index>" }
array    --> 2-5 items of the element type
```

**Enum fields**: Randomly select from the defined enum values with roughly equal distribution.

### Step 5: Ensure Referential Integrity

If the model has foreign key relationships:

1. **BelongsTo / ManyToOne**: Generate the referenced model's data first (or use existing seed data). Assign foreign key IDs that reference valid parent records.
2. **HasMany / OneToMany**: After generating parent records, generate child records referencing valid parent IDs.
3. **ManyToMany**: Generate junction table records linking valid IDs from both sides.
4. **Self-referential**: Some records have null parent (roots), others reference previously generated records.

Generate related models automatically if they don't have seed data yet, informing the user.

### Step 6: Ensure Data Quality

Apply these quality checks:
- **Unique fields**: Ensure no duplicates (emails, usernames, slugs)
- **Required fields**: Never null
- **Nullable fields**: ~20% chance of being null
- **Consistent dates**: createdAt < updatedAt < deletedAt; startDate < endDate
- **Realistic IDs**: Sequential integers starting from 1, or UUIDs
- **Diverse data**: Vary names, values, and patterns across records (avoid repetitive data)

### Step 7: Output Format

Detect the project's needs and generate the appropriate output format:

**JSON file** (default for TypeScript/JavaScript projects):
```json
// <model>-seed.json
[
  { "id": 1, "name": "Alice Johnson", "email": "alice.johnson@example.com", ... },
  { "id": 2, "name": "Bob Smith", "email": "bob.smith@example.com", ... }
]
```

**SQL INSERT statements** (if project uses raw SQL migrations):
```sql
-- seed_<model>.sql
INSERT INTO <table_name> (id, name, email, ...) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com', ...),
(2, 'Bob Smith', 'bob.smith@example.com', ...);
```

**TypeScript seed script** (if Prisma detected):
```typescript
// prisma/seed-<model>.ts
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

const <model>Data = [ ... ];

async function main() {
  for (const data of <model>Data) {
    await prisma.<model>.upsert({
      where: { id: data.id },
      update: {},
      create: data,
    });
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
```

**Python seed script** (if Django detected):
```python
# management/commands/seed_<model>.py or fixtures/<model>.json
# Django fixture format or management command with get_or_create
```

**Go seed script** (if Go project):
```go
// internal/seed/<model>_seed.go
// Struct literals with insert function
```

**Factory file** (if faker/factory_boy/fishery detected):
```
Generate a factory definition using the project's factory library
that can produce random instances on demand.
```

### Step 8: File Placement

- JSON: `data/seed/`, `prisma/seed/`, `fixtures/`, or project's existing seed directory
- SQL: `migrations/seed/`, `db/seeds/`, or similar
- Scripts: alongside existing seed scripts
- Factories: `tests/factories/`, `test/factories/`, `__tests__/factories/`

### Step 9: Summary

Print:
1. Model name and field count
2. Number of records generated
3. Output format and file path
4. Related models that were also seeded (with counts)
5. Any fields where realistic data could not be inferred (used fallback)
6. How to run the seed (e.g., `npx prisma db seed`, `python manage.py loaddata`, etc.)
