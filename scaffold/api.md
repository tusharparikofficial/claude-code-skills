# Scaffold API Service

Scaffold a production-ready API service with health checks, validation, logging, documentation, tests, and containerization.

## Arguments

$ARGUMENTS - `<project-name> <framework>` where framework is one of: express, fastapi, gin, spring

## Instructions

### 1. Parse Arguments

Extract from `$ARGUMENTS`:
- `project-name` (required) - the directory/project name
- `framework` (required) - one of: `express`, `fastapi`, `gin`, `spring`

If either is missing, ask the user. Validate framework is one of the four supported options.

### 2. Framework: Express (TypeScript)

If framework is `express`:

#### Initialize Project
```bash
mkdir <project-name> && cd <project-name>
pnpm init
pnpm add express cors helmet morgan compression zod http-status-codes
pnpm add @prisma/client
pnpm add -D typescript @types/node @types/express @types/cors @types/morgan
pnpm add -D ts-node tsx nodemon prisma
pnpm add -D jest @types/jest ts-jest supertest @types/supertest
pnpm add -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
pnpm add -D swagger-jsdoc swagger-ui-express @types/swagger-jsdoc @types/swagger-ui-express
pnpm add express-rate-limit pino pino-pretty
```

#### Create Directory Structure
```
src/
├── config/
│   ├── env.ts              # Environment validation with Zod
│   ├── database.ts          # Prisma client singleton
│   └── logger.ts            # Pino structured logger
├── middleware/
│   ├── error-handler.ts     # Global error handling middleware
│   ├── validate.ts          # Zod request validation middleware
│   ├── rate-limit.ts        # Rate limiting configuration
│   └── not-found.ts         # 404 handler
├── modules/
│   └── health/
│       ├── health.controller.ts
│       ├── health.routes.ts
│       └── health.test.ts
├── types/
│   └── index.ts             # Shared types and interfaces
├── utils/
│   ├── api-response.ts      # Standardized API response helper
│   └── api-error.ts         # Custom API error class
├── app.ts                   # Express app setup (middleware, routes)
└── server.ts                # Server entry point (listen)
prisma/
├── schema.prisma
└── seed.ts
```

#### Key Implementation Details

**Error Handler Middleware** - Catches all errors, distinguishes known ApiError from unexpected errors, returns consistent JSON envelope: `{ success, data, error, statusCode }`.

**Validation Middleware** - Accepts Zod schemas for `body`, `query`, `params`. Returns 400 with detailed validation errors.

**API Response Helper** - Consistent response format:
```typescript
{ success: boolean; data: T | null; error: string | null; meta?: { total, page, limit } }
```

**Health Check** - Returns status, timestamp, uptime, database connectivity, memory usage.

**Structured Logging** - Pino with request ID tracking, environment-aware log levels.

**OpenAPI/Swagger** - swagger-jsdoc with JSDoc annotations, served at `/api/docs`.

#### Scripts
```json
{
  "dev": "tsx watch src/server.ts",
  "build": "tsc",
  "start": "node dist/server.js",
  "test": "jest --passWithNoTests",
  "test:watch": "jest --watch",
  "lint": "eslint src/",
  "db:migrate": "prisma migrate dev",
  "db:seed": "tsx prisma/seed.ts"
}
```

---

### 3. Framework: FastAPI (Python)

If framework is `fastapi`:

#### Initialize Project
```bash
mkdir <project-name> && cd <project-name>
python -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn[standard] sqlalchemy alembic psycopg2-binary
pip install pydantic pydantic-settings python-dotenv
pip install structlog python-json-logger
pip install slowapi  # rate limiting
pip install pytest pytest-asyncio httpx factory-boy
pip install ruff mypy
```

Create `pyproject.toml` with project metadata, dependencies, and tool configurations.
Create `requirements.txt` and `requirements-dev.txt`.

#### Create Directory Structure
```
app/
├── __init__.py
├── main.py                  # FastAPI app factory
├── config.py                # Settings with pydantic-settings
├── database.py              # SQLAlchemy engine and session
├── dependencies.py          # Dependency injection (get_db, etc.)
├── models/
│   ├── __init__.py
│   └── base.py              # SQLAlchemy Base model with common fields
├── schemas/
│   ├── __init__.py
│   └── health.py            # Pydantic response schemas
├── api/
│   ├── __init__.py
│   ├── router.py            # Main API router
│   └── v1/
│       ├── __init__.py
│       └── health.py        # Health check endpoint
├── middleware/
│   ├── __init__.py
│   ├── error_handler.py     # Exception handlers
│   ├── logging.py           # Request logging middleware
│   └── cors.py              # CORS configuration
├── utils/
│   ├── __init__.py
│   ├── response.py          # Standardized response model
│   └── exceptions.py        # Custom exception classes
└── core/
    ├── __init__.py
    └── logger.py            # Structlog configuration
alembic/
├── env.py
├── versions/
└── alembic.ini
tests/
├── __init__.py
├── conftest.py              # Fixtures, test client, test DB
├── test_health.py
└── factories/
    └── __init__.py
```

#### Key Implementation Details

**App Factory** (`main.py`) - Creates FastAPI app with lifespan for startup/shutdown, includes CORS, exception handlers, and routers. Auto-generates OpenAPI docs at `/docs` and `/redoc`.

**Settings** - pydantic-settings BaseSettings loading from `.env` with validation.

**Exception Handlers** - Custom handlers for `HTTPException`, `RequestValidationError`, and generic `Exception`. All return consistent JSON envelope.

**Rate Limiting** - slowapi with configurable limits per endpoint.

**Structured Logging** - structlog with request ID, timestamp, level, context.

**Database** - SQLAlchemy async session with dependency injection.

**Alembic** - Pre-configured for migrations with `alembic.ini`.

#### Scripts (Makefile)
```makefile
dev:        uvicorn app.main:app --reload --port 8000
test:       pytest -v --tb=short
lint:       ruff check app/ tests/
format:     ruff format app/ tests/
migrate:    alembic upgrade head
migration:  alembic revision --autogenerate -m "$(msg)"
```

---

### 4. Framework: Gin (Go)

If framework is `gin`:

#### Initialize Project
```bash
mkdir <project-name> && cd <project-name>
go mod init github.com/<user>/<project-name>
go get github.com/gin-gonic/gin
go get github.com/gin-contrib/cors
go get github.com/gin-contrib/requestid
go get go.uber.org/zap
go get github.com/jmoiron/sqlx
go get github.com/lib/pq
go get github.com/golang-migrate/migrate/v4
go get github.com/swaggo/gin-swagger
go get github.com/swaggo/swag/cmd/swag
go get github.com/joho/godotenv
go get github.com/ulule/limiter/v3
```

#### Create Directory Structure
```
cmd/
└── server/
    └── main.go              # Entry point
internal/
├── config/
│   └── config.go            # Environment configuration
├── handler/
│   └── health.go            # Health check handler
├── middleware/
│   ├── error.go             # Error recovery middleware
│   ├── logger.go            # Request logging middleware
│   ├── ratelimit.go         # Rate limiting
│   └── cors.go              # CORS configuration
├── model/
│   └── response.go          # Standard API response struct
├── repository/              # Data access layer
├── service/                 # Business logic layer
├── router/
│   └── router.go            # Route registration
└── database/
    └── postgres.go          # Database connection
migrations/
├── 000001_init.up.sql
└── 000001_init.down.sql
pkg/
├── apperror/
│   └── error.go             # Custom error types
└── logger/
    └── logger.go            # Zap logger setup
```

#### Key Implementation Details

**Standard Response** - Struct with `Success bool`, `Data interface{}`, `Error string`, `Meta *PaginationMeta`.

**Error Recovery** - Gin recovery middleware that catches panics and returns JSON errors.

**Structured Logging** - Uber Zap with request tracing.

**Health Check** - Returns status, DB ping, uptime, Go version.

**Swagger** - swag annotations for API documentation at `/swagger/`.

**Database** - sqlx with connection pooling, ping-based health check.

**Migrations** - golang-migrate CLI and programmatic support.

#### Makefile
```makefile
run:        go run cmd/server/main.go
build:      go build -o bin/server cmd/server/main.go
test:       go test ./... -v -count=1
lint:       golangci-lint run
swagger:    swag init -g cmd/server/main.go
migrate-up: migrate -path migrations -database $(DATABASE_URL) up
migrate-down: migrate -path migrations -database $(DATABASE_URL) down 1
```

---

### 5. Framework: Spring Boot (Java)

If framework is `spring`:

#### Initialize Project

Use Spring Initializr via curl or create manually:
```bash
curl https://start.spring.io/starter.zip \
  -d type=maven-project \
  -d language=java \
  -d javaVersion=21 \
  -d packaging=jar \
  -d name=<project-name> \
  -d dependencies=web,data-jpa,postgresql,validation,actuator,lombok \
  -o <project-name>.zip
unzip <project-name>.zip -d <project-name>
```

If curl is not practical, create the project directory structure manually with a proper `pom.xml` (or `build.gradle`) including dependencies: Spring Web, Spring Data JPA, PostgreSQL Driver, Validation, Actuator, Lombok, Flyway, SpringDoc OpenAPI.

#### Create Directory Structure
```
src/main/java/com/example/<project>/
├── Application.java                     # @SpringBootApplication entry point
├── config/
│   ├── CorsConfig.java                  # CORS configuration
│   ├── RateLimitConfig.java             # Rate limiting with Bucket4j or filter
│   └── OpenApiConfig.java               # SpringDoc OpenAPI config
├── controller/
│   └── HealthController.java            # Health check endpoint
├── dto/
│   ├── ApiResponse.java                 # Generic response wrapper
│   └── ErrorResponse.java               # Error response DTO
├── exception/
│   ├── GlobalExceptionHandler.java      # @ControllerAdvice
│   ├── ApiException.java                # Custom runtime exception
│   └── ResourceNotFoundException.java   # 404 exception
├── model/                               # JPA entities
├── repository/                          # Spring Data repositories
├── service/                             # Business logic
└── util/                                # Utility classes
src/main/resources/
├── application.yml                      # Main configuration
├── application-dev.yml                  # Dev profile
├── application-prod.yml                 # Prod profile
└── db/migration/
    └── V1__init.sql                     # Flyway migration
src/test/java/com/example/<project>/
├── ApplicationTests.java
└── controller/
    └── HealthControllerTest.java
```

#### Key Implementation Details

**ApiResponse<T>** - Generic response wrapper: `success`, `data`, `error`, `timestamp`.

**GlobalExceptionHandler** - `@ControllerAdvice` handling `MethodArgumentNotValidException`, `ApiException`, `ResourceNotFoundException`, generic `Exception`.

**Health Check** - Custom endpoint returning status, DB connectivity, JVM info. Also configure Spring Actuator at `/actuator/health`.

**Logging** - SLF4J + Logback with structured JSON output in production. MDC for request tracing.

**OpenAPI** - SpringDoc auto-generating docs at `/swagger-ui.html`.

**Validation** - Jakarta Bean Validation on request DTOs with `@Valid`.

**Flyway** - Auto-run migrations on startup.

#### Maven Wrapper
Ensure `mvnw` is included. Add scripts in `Makefile` or document in README:
```makefile
run:    ./mvnw spring-boot:run
build:  ./mvnw clean package -DskipTests
test:   ./mvnw test
```

---

### 6. Common Across All Frameworks

After framework-specific setup, create these for every project:

#### Docker Setup

Create `Dockerfile` (multi-stage, framework-appropriate):
- **Express**: node:20-alpine, build stage, production stage with `node dist/server.js`
- **FastAPI**: python:3.12-slim, install deps, copy app, run with uvicorn
- **Gin**: golang:1.22-alpine build stage, scratch/distroless runtime with compiled binary
- **Spring**: eclipse-temurin:21-jdk build stage, eclipse-temurin:21-jre runtime

All Dockerfiles must:
- Use non-root user
- Include HEALTHCHECK instruction
- Optimize layer caching (deps before source)
- Include `.dockerignore`

Create `docker-compose.yml`:
```yaml
services:
  app:
    build: .
    ports:
      - "<port>:<port>"
    env_file: .env
    depends_on:
      db:
        condition: service_healthy
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-appdb}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

#### CI/CD Pipeline

Create `.github/workflows/ci.yml` with:
- Lint step
- Type check step (where applicable)
- Test step with coverage
- Build step
- Appropriate caching (pnpm/pip/go/maven)

#### Environment Files

Create `.env.example` documenting all required environment variables.
Create `.env` with development defaults.
Add `.env` to `.gitignore`.

#### Git Setup

Create `.gitignore` appropriate for the framework.
Initialize git repo:
```bash
git init
git add .
git commit -m "feat: scaffold <framework> API service"
```

#### README.md

Generate README with:
- Project name, description, tech stack
- Prerequisites
- Quick start (local development)
- API documentation link
- Available endpoints
- Environment variables table
- Docker usage instructions
- Testing instructions
- Project structure

### 7. Final Verification

Run the appropriate lint and build commands for the framework. Fix any errors. Report the final project structure and confirm the API starts successfully with a health check response.
