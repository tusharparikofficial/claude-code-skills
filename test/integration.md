# Integration Test Generator

Generate integration tests for API endpoints, covering success responses, validation errors, authentication, and data integrity.

## Arguments

$ARGUMENTS - `<route-file-or-endpoint-path>` — Path to the route/controller file defining API endpoints, or an endpoint pattern like `GET /api/users`. If a file path is given, tests are generated for all endpoints defined in that file.

## Instructions

### Step 1: Discover and Analyze Endpoints

1. Read the provided route/controller file.
2. For each endpoint, extract:
   - HTTP method (GET, POST, PUT, PATCH, DELETE)
   - Route path including parameters (e.g., `/api/users/:id`)
   - Request body schema (required fields, types, validation rules)
   - Query parameters (pagination, filtering, sorting)
   - Path parameters and their types
   - Response structure (success and error shapes)
   - Authentication/authorization requirements (middleware, guards, decorators)
   - Associated middleware (rate limiting, CORS, body parsing)
3. Trace into service/repository layers to understand:
   - Database models involved
   - Relationships and constraints
   - Business logic and validation rules
   - External service dependencies

### Step 2: Detect Testing Infrastructure

1. Identify the integration testing setup:
   - **Node.js/Express**: supertest, node-test-runner with fetch, chai-http
   - **Go**: net/http/httptest, testify
   - **Python/Django**: Django test client, pytest-django
   - **Python/FastAPI**: httpx.AsyncClient, TestClient
   - **Python/Flask**: Flask test client
   - **Java/Spring**: MockMvc, WebTestClient, RestAssured
2. Find existing integration test files to match patterns:
   - How the test server/app is initialized
   - How the test database is seeded and cleaned
   - How authentication tokens are generated for tests
   - How request/response assertions are structured
3. Identify test database setup:
   - In-memory databases (SQLite, H2)
   - Docker-based databases (testcontainers)
   - Transaction rollback patterns
   - Migration/seed scripts for test data

### Step 3: Generate Test Infrastructure

#### 3a: Test Setup
- Create or reuse app/server initialization for testing
- Set up test database connection and seeding
- Create helper functions:
  - `createAuthToken(user)` or equivalent for authenticated requests
  - `seedDatabase(fixtures)` for populating test data
  - `cleanDatabase()` for resetting state between tests
- Define test fixtures with realistic data:
  - Valid entities (users, posts, products, etc.)
  - Entities that violate constraints (for error testing)
  - Related entities (for relationship testing)

#### 3b: Test Lifecycle
- Before all: start test server, run migrations, seed base data
- Before each: reset database to known state, clear caches
- After each: rollback transactions or truncate tables
- After all: close connections, stop test server

### Step 4: Generate Tests for Each Endpoint

For each endpoint, generate the following test categories:

#### Success Responses
- **GET (list)**: Returns 200 with array, correct item count, correct item shape
- **GET (single)**: Returns 200 with correct entity, all fields present
- **POST (create)**: Returns 201 with created entity, verify entity persisted in database
- **PUT/PATCH (update)**: Returns 200 with updated entity, verify changes persisted
- **DELETE**: Returns 200 or 204, verify entity removed from database

#### Request Validation (400 Bad Request)
- Missing required fields (test each required field individually)
- Invalid field types (string where number expected, etc.)
- Fields exceeding length limits
- Invalid email/URL/date formats
- Invalid enum values
- Nested object validation
- Array validation (min/max items, item types)
- Empty request body when body is required

#### Authentication Errors (401 Unauthorized)
- Request with no auth token/cookie
- Request with expired token
- Request with malformed token
- Request with invalid credentials

#### Authorization Errors (403 Forbidden)
- Request from user without required role
- Request for resource owned by another user
- Request for admin-only endpoints as regular user

#### Not Found (404)
- Request with non-existent ID
- Request with valid format but non-existent resource
- Request to undefined route (if applicable)

#### Conflict Errors (409)
- Duplicate unique fields (email, username, etc.)
- Version conflict on optimistic locking
- State transition conflicts (e.g., publishing already-published item)

#### Query Parameter Handling
- **Pagination**: page/limit parameters, default values, out-of-range page
- **Sorting**: valid sort fields, sort direction, invalid sort field
- **Filtering**: filter by each supported field, multiple filters, invalid filter
- **Search**: search query, empty search, special characters in search

#### Response Structure Verification
- Content-Type header is correct (application/json)
- Response envelope structure matches convention (data, error, meta)
- Pagination metadata in list responses (total, page, pageSize, totalPages)
- HATEOAS links if applicable
- No sensitive data leaked (passwords, internal IDs, etc.)

#### Data Integrity
- Created/updated timestamps are set correctly
- Soft deletes mark records (not hard delete) if applicable
- Cascading operations work correctly (delete parent affects children)
- Transactions rollback on partial failure

### Step 5: Validate and Run

1. Write the test file to the correct location following project conventions.
2. Ensure the test database is configured (add instructions if not).
3. Run the integration tests:
   - Node.js: `npx jest --testPathPattern=<file> --runInBand` or `npx vitest run <file>`
   - Python: `python -m pytest <file> -v`
   - Go: `go test -v -run <TestName> ./<package>`
   - Java: `mvn test -Dtest=<TestClass>` or `gradle test --tests <TestClass>`
4. Fix any test infrastructure issues (connection errors, missing seeds, import errors).
5. Report summary:
   - Endpoints tested and test count per endpoint
   - Tests that revealed potential bugs (unexpected status codes, missing validation)
   - Missing endpoint coverage (endpoints without auth, without validation, etc.)
   - Recommendations for endpoint improvements

### Important Guidelines

- Run integration tests with `--runInBand` or equivalent to prevent parallel database conflicts.
- Use realistic but deterministic test data — avoid random values unless testing randomness.
- Never hardcode port numbers; use dynamic ports or environment variables.
- Test the full request-response cycle including middleware.
- Verify both the response AND the database state for mutating operations.
- Keep each test self-contained — do not depend on test execution order.
- Use descriptive test names: `POST /api/users - should return 400 when email is missing`.
- Mock external services (payment APIs, email services) but NOT the database.
