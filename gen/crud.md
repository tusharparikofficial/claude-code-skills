# CRUD Generator

Generate complete CRUD (Create, Read, Update, Delete) operations for a model/entity, auto-detecting the project's tech stack.

## Arguments

$ARGUMENTS - `<ModelName> [fields...]` e.g. `User name:string email:string age:number active:boolean`

## Instructions

### Step 1: Parse Arguments

Parse the arguments to extract:
- **ModelName**: The first word (PascalCase entity name). If not provided, ask the user.
- **Fields**: Remaining words in `fieldName:type` format. Supported types: `string`, `number`, `integer`, `boolean`, `date`, `datetime`, `text`, `float`, `uuid`, `json`, `enum(val1|val2|...)`.
- If no fields are provided, check the project for an existing model/entity definition matching the ModelName and extract fields from it. If none found, ask the user to provide fields.

### Step 2: Detect Tech Stack

Search the project root for configuration files to determine the stack:

1. **TypeScript/Node.js**: Check for `package.json` with `typescript`, `ts-node`, `express`, `fastify`, `nestjs`, `hono`, or `koa` dependencies.
2. **Python/Django**: Check for `manage.py`, `settings.py`, or `django` in `requirements.txt` / `pyproject.toml`.
3. **Python/FastAPI**: Check for `fastapi` in `requirements.txt` / `pyproject.toml`.
4. **Go**: Check for `go.mod`.
5. **Java/Spring**: Check for `pom.xml` or `build.gradle` with Spring Boot dependencies.

Also detect the database layer:
- **Prisma**: `prisma/schema.prisma`
- **Drizzle**: `drizzle.config.ts`
- **TypeORM**: `typeorm` in dependencies
- **SQLAlchemy**: `sqlalchemy` in requirements
- **GORM**: `gorm.io/gorm` in go.mod
- **JPA/Hibernate**: Spring Data JPA in pom.xml

Also detect existing project patterns by searching for existing CRUD implementations to match the project's conventions (file structure, naming, error handling style, response format).

### Step 3: Generate Files by Stack

#### TypeScript/Node.js (Express/Fastify/Hono)

Generate the following files in the project's existing directory structure:

**1. Types file** (`types/<model>.types.ts` or matching project convention):
```
- Interface for the model with all fields properly typed
- CreateInput type (omit id, timestamps)
- UpdateInput type (Partial of CreateInput)
- Query/filter type with pagination (page, limit, sortBy, sortOrder)
- Response envelope type
```

**2. Validation schema** (`validators/<model>.validator.ts` or matching convention):
```
- Zod schemas for Create, Update, and Query params
- String fields: min/max length, patterns (email regex for email fields, etc.)
- Number fields: min/max ranges
- Enum fields: z.enum with provided values
- Export validate functions wrapping schema.parse with error formatting
```

**3. Service file** (`services/<model>.service.ts` or matching convention):
```
- create(data: CreateInput): Promise<Model>
- findAll(query: QueryInput): Promise<{ data: Model[], total: number, page: number, limit: number }>
- findById(id: string): Promise<Model | null>
- update(id: string, data: UpdateInput): Promise<Model>
- delete(id: string): Promise<void>
- Each method includes proper error handling (NotFoundError, ValidationError)
- Use the detected ORM (Prisma, Drizzle, TypeORM) or a repository pattern
```

**4. Controller/Route file** (`routes/<model>.routes.ts` or `controllers/<model>.controller.ts`):
```
- POST /  - Create
- GET /   - List with pagination, filtering, sorting
- GET /:id - Get by ID
- PUT /:id - Update
- DELETE /:id - Delete
- Request validation middleware using the Zod schemas
- Proper HTTP status codes (201 created, 200 ok, 204 no content, 404 not found, 422 validation error)
- Consistent error response format
```

**5. If Prisma detected**, also append model to `prisma/schema.prisma` if not already present.

#### Python/Django

**1. Model** (`models.py` or `models/<model>.py`):
```
- Django model class with all fields using proper Django field types
- Meta class with ordering, verbose_name
- __str__ method
- Any custom managers if needed
```

**2. Serializer** (`serializers.py` or `serializers/<model>.py`):
```
- ModelSerializer with all fields
- CreateSerializer (writable fields only)
- UpdateSerializer (all fields optional)
- ListSerializer (summary fields)
- Field-level validation methods
```

**3. ViewSet** (`views.py` or `views/<model>.py`):
```
- ModelViewSet with queryset, serializer_class
- get_serializer_class() returning appropriate serializer per action
- Filtering, searching, ordering via django-filter
- Pagination class
- Permission classes
```

**4. URLs** (`urls.py`):
```
- Router registration for the viewset
- Append to existing urlpatterns if file exists
```

#### Python/FastAPI

**1. Model** (`models/<model>.py`):
```
- SQLAlchemy model with proper column types
- Table name, indexes, constraints
```

**2. Schema** (`schemas/<model>.py`):
```
- Pydantic BaseModel for Create, Update, Response, List
- Field validators with descriptions
- Config with from_attributes = True
```

**3. Service** (`services/<model>.py`):
```
- Async CRUD functions using SQLAlchemy async session
- Proper error handling with HTTPException
- Pagination support
```

**4. Router** (`routers/<model>.py`):
```
- APIRouter with prefix and tags
- All 5 CRUD endpoints with proper response_model
- Dependency injection for database session
- Status codes and error responses
```

#### Go

**1. Model** (`internal/models/<model>.go` or matching convention):
```
- Struct with json tags, db tags (if using sqlx/gorm)
- CreateRequest, UpdateRequest, ListRequest structs
- Response struct
```

**2. Repository** (`internal/repository/<model>_repository.go`):
```
- Interface defining CRUD methods
- Implementation with database queries
- Proper error wrapping with fmt.Errorf
```

**3. Service** (`internal/service/<model>_service.go`):
```
- Interface and implementation
- Business logic, validation
- Calls repository methods
```

**4. Handler** (`internal/handler/<model>_handler.go`):
```
- HTTP handlers for each CRUD operation
- Request parsing and validation
- JSON response encoding
- Proper HTTP status codes
- Error response format
```

#### Java/Spring Boot

**1. Entity** (`entity/<Model>.java`):
```
- @Entity with @Table annotation
- @Id with generation strategy
- All fields with proper JPA annotations
- @CreatedDate, @LastModifiedDate if auditing is set up
- Lombok annotations if Lombok is in dependencies
```

**2. Repository** (`repository/<Model>Repository.java`):
```
- Extends JpaRepository<Model, Long>
- Custom query methods if needed
- @Query annotations for complex queries
```

**3. Service** (`service/<Model>Service.java`):
```
- Interface + implementation
- @Service, @Transactional annotations
- CRUD methods with proper exception handling
- Pagination with Pageable
```

**4. Controller** (`controller/<Model>Controller.java`):
```
- @RestController with @RequestMapping
- All CRUD endpoints with @GetMapping, @PostMapping, @PutMapping, @DeleteMapping
- @Valid for request body validation
- ResponseEntity with proper status codes
- Exception handling via @ControllerAdvice or local @ExceptionHandler
```

**5. DTO** (`dto/<Model>Request.java`, `dto/<Model>Response.java`):
```
- Request DTO with Jakarta validation annotations
- Response DTO (excludes sensitive/internal fields)
- Mapper methods or MapStruct interface
```

### Step 4: Register Routes

After generating files, check if there is a central route/router registration file and add the new routes:
- Express: `app.use('/api/<models>', router)` in app.ts/index.ts
- FastAPI: `app.include_router(router)` in main.py
- Django: add to urlpatterns in urls.py
- Go: register handlers in router setup
- Spring: auto-detected via component scan (no action needed)

If unsure where to register, inform the user with the exact line to add.

### Step 5: Summary

Print a summary of all generated files with their paths, and note any manual steps needed (e.g., running migrations, registering routes, installing missing dependencies).
