# DTO Generator

Generate Data Transfer Objects (DTOs) and view models from domain models/entities, with mapper functions.

## Arguments

$ARGUMENTS - `<model-name> [dto-types...]` e.g. `User create,update,response,list` or just `User` (generates all four by default).

## Instructions

### Step 1: Parse Arguments

- **model-name**: The first argument. The name of the domain model/entity.
- **dto-types** (optional): Comma-separated list of DTO variants to generate. Valid values:
  - `create` - For creating new records (writable fields, required markers)
  - `update` - For updating records (all fields optional / partial)
  - `response` - For API responses (safe fields only, no secrets)
  - `list` - For list/summary views (minimal fields)
  - `detail` - For detailed single-record views (full safe fields + relations)
  - `filter` - For query/filter parameters (searchable fields + pagination)
- If no dto-types specified, default to: `create,update,response,list`

### Step 2: Locate the Domain Model

Search the project for the model definition:

1. **TypeScript**: `interface`, `type`, Prisma model, TypeORM `@Entity`, Drizzle table
2. **Python**: Django `models.Model`, SQLAlchemy model, Pydantic `BaseModel`, dataclass
3. **Go**: `type <Name> struct` (look in `models/`, `entities/`, `domain/`)
4. **Java**: `@Entity` class, JPA entity, record

Read the full model definition including:
- All fields with types
- Relationships (foreign keys, one-to-many, many-to-many)
- Field metadata (nullable, unique, default, constraints)
- Decorators/annotations

### Step 3: Classify Fields

Categorize each field for DTO generation:

```
Category          | Examples                                    | In Create | In Update | In Response | In List
------------------|---------------------------------------------|-----------|-----------|-------------|--------
Auto-generated    | id, uuid, createdAt, updatedAt, deletedAt   | NO        | NO        | YES         | YES (id only)
Writable          | name, email, title, description              | YES       | YES       | YES         | SOME
Sensitive         | password, passwordHash, secret, token, ssn   | YES*      | YES*      | NO          | NO
Internal          | internalNotes, adminFlag, rawData             | NO        | NO        | NO          | NO
Computed          | fullName, displayName, age (from dob)         | NO        | NO        | YES         | YES
Relation ID       | userId, categoryId, parentId                  | YES       | YES       | YES         | YES
Relation Object   | user, category, posts (nested)                | NO        | NO        | OPTIONAL    | NO
Summary           | name, title, email, status, createdAt         | -         | -         | -           | YES

* Sensitive fields in Create/Update: included but with appropriate handling (e.g., password in Create, not in Update unless password change endpoint)
```

### Step 4: Generate DTOs by Stack

#### TypeScript

Generate a file `<model>.dto.ts` (or matching project convention):

**CreateDTO**:
```typescript
// Fields: writable + required markers
// Omit: id, timestamps, computed, internal
// Include: relation IDs (userId, not user object)
// Validation: using Zod or class-validator decorators if detected

export interface Create<Model>Dto {
  name: string;          // required
  email: string;         // required
  bio?: string;          // optional (nullable in model)
  categoryId: string;    // required FK
}

// If Zod is used, also generate:
export const Create<Model>Schema = z.object({ ... });
export type Create<Model>Dto = z.infer<typeof Create<Model>Schema>;
```

**UpdateDTO**:
```typescript
// All writable fields made optional (Partial)
// Omit: id, timestamps, computed, internal
// Never include password unless this is explicitly a password-change DTO

export interface Update<Model>Dto {
  name?: string;
  email?: string;
  bio?: string;
  categoryId?: string;
}

// Or simply: export type Update<Model>Dto = Partial<Create<Model>Dto>;
// But only if they share the exact same fields. Otherwise, be explicit.
```

**ResponseDTO**:
```typescript
// All safe fields (no secrets)
// Include: id, timestamps, computed fields
// Include: relation objects as nested ResponseDTOs (optional/lazy)
// Exclude: password, hash, secret, token, internal fields

export interface <Model>ResponseDto {
  id: string;
  name: string;
  email: string;
  bio: string | null;
  category?: CategoryResponseDto;  // nested relation
  createdAt: string;               // ISO date string
  updatedAt: string;
}
```

**ListDTO**:
```typescript
// Minimal summary fields for list views
// Typically: id, primary display field, status, key metadata
// No nested relations (just IDs or names)

export interface <Model>ListDto {
  id: string;
  name: string;
  email: string;
  status: string;
  createdAt: string;
}

// Also generate a paginated list wrapper:
export interface <Model>ListResponseDto {
  data: <Model>ListDto[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}
```

**FilterDTO**:
```typescript
// Searchable/filterable fields + pagination + sorting

export interface <Model>FilterDto {
  search?: string;            // full-text search across name, email, etc.
  status?: string;            // enum filter
  categoryId?: string;        // FK filter
  createdAfter?: string;      // date range
  createdBefore?: string;
  page?: number;              // default 1
  limit?: number;             // default 20, max 100
  sortBy?: string;            // field name
  sortOrder?: 'asc' | 'desc'; // default 'desc'
}
```

#### Python (Django)

Generate serializers in `serializers/<model>_serializers.py`:
```python
class Create<Model>Serializer(serializers.Serializer):
    # Writable fields with validation
    name = serializers.CharField(max_length=255)
    email = serializers.EmailField()
    ...

class Update<Model>Serializer(serializers.Serializer):
    # All fields optional
    name = serializers.CharField(max_length=255, required=False)
    ...

class <Model>ResponseSerializer(serializers.ModelSerializer):
    class Meta:
        model = <Model>
        exclude = ['password', 'internal_notes']

class <Model>ListSerializer(serializers.ModelSerializer):
    class Meta:
        model = <Model>
        fields = ['id', 'name', 'email', 'status', 'created_at']
```

#### Python (FastAPI/Pydantic)

Generate schemas in `schemas/<model>_schemas.py`:
```python
class Create<Model>(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    email: EmailStr
    ...

class Update<Model>(BaseModel):
    name: str | None = None
    email: EmailStr | None = None
    ...

class <Model>Response(BaseModel):
    id: int
    name: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class <Model>ListItem(BaseModel):
    id: int
    name: str
    status: str

class <Model>ListResponse(BaseModel):
    data: list[<Model>ListItem]
    total: int
    page: int
    limit: int
```

#### Go

Generate in `internal/dto/<model>_dto.go`:
```go
type Create<Model>Request struct {
    Name       string `json:"name" validate:"required,min=1,max=255"`
    Email      string `json:"email" validate:"required,email"`
    CategoryID int64  `json:"categoryId" validate:"required"`
}

type Update<Model>Request struct {
    Name       *string `json:"name,omitempty" validate:"omitempty,min=1,max=255"`
    Email      *string `json:"email,omitempty" validate:"omitempty,email"`
    CategoryID *int64  `json:"categoryId,omitempty"`
}

type <Model>Response struct {
    ID        int64     `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"createdAt"`
}

type <Model>ListItem struct {
    ID     int64  `json:"id"`
    Name   string `json:"name"`
    Status string `json:"status"`
}

type <Model>ListResponse struct {
    Data       []<Model>ListItem `json:"data"`
    Total      int64             `json:"total"`
    Page       int               `json:"page"`
    Limit      int               `json:"limit"`
    TotalPages int               `json:"totalPages"`
}
```

#### Java/Spring

Generate in `dto/<Model>Dto.java` (or separate files per DTO):
```java
// Using records (Java 16+) or classes with Lombok
public record Create<Model>Request(
    @NotBlank @Size(max = 255) String name,
    @NotBlank @Email String email,
    @NotNull Long categoryId
) {}

public record Update<Model>Request(
    @Size(max = 255) String name,
    @Email String email,
    Long categoryId
) {}

public record <Model>Response(
    Long id,
    String name,
    String email,
    LocalDateTime createdAt
) {}

public record <Model>ListItem(
    Long id,
    String name,
    String status
) {}

// Page<<Model>ListItem> used for list responses (Spring Data)
```

### Step 5: Generate Mapper Functions

Generate mapper/converter functions between the domain model and each DTO:

**TypeScript**:
```typescript
// <model>.mapper.ts
export const <Model>Mapper = {
  toResponse(entity: <Model>): <Model>ResponseDto { ... },
  toListItem(entity: <Model>): <Model>ListDto { ... },
  toEntity(dto: Create<Model>Dto): Omit<<Model>, 'id' | 'createdAt' | 'updatedAt'> { ... },
  applyUpdate(entity: <Model>, dto: Update<Model>Dto): <Model> { ... },
  toListResponse(entities: <Model>[], total: number, page: number, limit: number): <Model>ListResponseDto { ... },
} as const;
```

**Python**:
```python
# Use classmethod on the Pydantic model, or standalone functions
@classmethod
def from_entity(cls, entity: <Model>) -> "<Model>Response":
    return cls.model_validate(entity)

def to_entity(dto: Create<Model>) -> dict:
    return dto.model_dump(exclude_unset=True)
```

**Go**:
```go
func To<Model>Response(entity *models.<Model>) *<Model>Response { ... }
func To<Model>ListItem(entity *models.<Model>) *<Model>ListItem { ... }
func To<Model>FromCreate(dto *Create<Model>Request) *models.<Model> { ... }
func Apply<Model>Update(entity *models.<Model>, dto *Update<Model>Request) { ... }
```

**Java**:
```java
// MapStruct interface if MapStruct is in dependencies, otherwise manual mapper class
@Mapper(componentModel = "spring")
public interface <Model>Mapper {
    <Model>Response toResponse(<Model> entity);
    <Model>ListItem toListItem(<Model> entity);
    <Model> toEntity(Create<Model>Request dto);
    void applyUpdate(@MappingTarget <Model> entity, Update<Model>Request dto);
}
```

### Step 6: File Placement

Follow the project's existing conventions:
- TypeScript: `dto/`, `types/`, or alongside the model
- Python Django: `serializers/` directory
- Python FastAPI: `schemas/` directory
- Go: `internal/dto/` or `pkg/dto/`
- Java: `dto/` package within the module

### Step 7: Summary

Print:
1. Domain model analyzed with field count
2. DTO variants generated (with field counts for each)
3. Fields excluded per DTO variant and why (sensitive, internal, auto-generated)
4. Mapper file path
5. Any fields where classification was uncertain (ask user to verify)
6. Generated file paths
