# API Contract Test Generator

Generate contract tests from an OpenAPI/Swagger specification to verify that API responses match their documented schemas, status codes, and headers.

## Arguments

$ARGUMENTS - `<openapi-spec-path>` or `<api-base-url>` — Path to the OpenAPI/Swagger spec file (YAML or JSON), or the base URL of an API that serves its spec at a standard endpoint (`/openapi.json`, `/swagger.json`, `/docs`).

## Instructions

### Step 1: Load and Parse the API Specification

1. If a file path was provided:
   - Read the OpenAPI spec file (YAML or JSON)
   - Parse and validate the spec structure
   - Identify the spec version (OpenAPI 3.x, Swagger 2.0)

2. If a URL was provided:
   - Attempt to fetch the spec from common endpoints:
     - `<base-url>/openapi.json`
     - `<base-url>/swagger.json`
     - `<base-url>/api-docs`
     - `<base-url>/docs/openapi.json`
   - Parse the fetched spec

3. Extract from the spec:
   - All endpoints (paths + methods)
   - Request schemas (body, query params, path params, headers)
   - Response schemas per status code
   - Required fields and their types
   - Enum constraints and value ranges
   - Authentication schemes (Bearer, API key, OAuth2)
   - Content types (application/json, multipart/form-data, etc.)
   - Server base URLs

### Step 2: Detect Testing Framework

1. Search the project for existing test infrastructure:
   - **Node.js**: supertest, axios, node-fetch, got + jest/vitest
   - **Python**: requests, httpx, pytest
   - **Go**: net/http, testify
   - **Java**: RestAssured, MockMvc, WebTestClient
2. Find existing API/contract tests to match style.
3. Check for existing schema validation libraries:
   - **Node.js**: ajv, zod, joi, yup
   - **Python**: pydantic, marshmallow, jsonschema
   - **Go**: go-jsonschema
   - **Java**: json-schema-validator
4. Determine if tests should run against:
   - Local dev server (most common)
   - Test/staging environment
   - Mock server

### Step 3: Generate Schema Validators

For each unique response schema in the spec:

1. Create a schema validator function that checks:
   - All required fields are present
   - Field types match (string, number, boolean, array, object)
   - Enum fields contain only allowed values
   - Nested objects match their schemas recursively
   - Array items match their item schema
   - Nullable fields accept null
   - String formats (date-time, email, uuid, uri) if specified
   - Number constraints (minimum, maximum, multipleOf)
   - String constraints (minLength, maxLength, pattern)

2. Reuse validators for shared schemas (`$ref` components).

### Step 4: Generate Contract Tests

For each endpoint in the spec, generate tests in these categories:

#### 4a: Success Response Contract Tests

For each documented success status code (200, 201, 204):

```
test('<METHOD> <path> - response matches schema for <status>', () => {
  // 1. Make request with valid data
  // 2. Assert status code matches
  // 3. Assert Content-Type header matches spec
  // 4. Assert response body matches schema:
  //    - All required fields present
  //    - Field types correct
  //    - Enum values valid
  //    - Nested objects valid
  // 5. Assert no extra undocumented fields (optional strict mode)
});
```

#### 4b: Error Response Contract Tests

For each documented error status code (400, 401, 403, 404, 409, 422, 500):

```
test('<METHOD> <path> - error response matches schema for <status>', () => {
  // 1. Make request that triggers this error
  // 2. Assert status code matches
  // 3. Assert error response body matches error schema:
  //    - Error message field present
  //    - Error code/type field if documented
  //    - Validation details for 400/422
  //    - No sensitive data leaked
});
```

#### 4c: Request Validation Contract Tests

For endpoints with request body schemas:

```
test('<METHOD> <path> - rejects request missing required field <field>', () => {
  // 1. Send request with each required field missing
  // 2. Assert 400 or 422 response
  // 3. Assert error references the missing field
});

test('<METHOD> <path> - rejects request with wrong type for <field>', () => {
  // 1. Send request with wrong type for each field
  // 2. Assert 400 or 422 response
});
```

#### 4d: Authentication Contract Tests

For endpoints requiring authentication:

```
test('<METHOD> <path> - returns 401 without authentication', () => {
  // 1. Make request without auth header/token
  // 2. Assert 401 status
  // 3. Assert error response matches auth error schema
});
```

#### 4e: Header Contract Tests

```
test('<METHOD> <path> - response includes required headers', () => {
  // 1. Make request
  // 2. Assert Content-Type matches spec
  // 3. Assert pagination headers if documented (X-Total-Count, Link)
  // 4. Assert rate limit headers if documented (X-RateLimit-*)
  // 5. Assert CORS headers if documented
});
```

#### 4f: Pagination Contract Tests (for list endpoints)

```
test('<METHOD> <path> - pagination response matches spec', () => {
  // 1. Make request with pagination params
  // 2. Assert pagination metadata structure matches spec
  // 3. Assert page size respects limit parameter
  // 4. Assert first/last page behavior
});
```

### Step 5: Generate Test Data Factories

1. For each request schema, create a factory that generates valid request data:
   - All required fields with valid values
   - Optional fields with realistic defaults
   - Helper to override specific fields for negative testing
2. Use realistic but deterministic values:
   - Valid emails, UUIDs, dates
   - Strings within length constraints
   - Numbers within min/max ranges
   - Valid enum values

### Step 6: Configure Test Environment

1. Set up base URL configuration (environment variable or config file).
2. Set up authentication helper:
   - Token generation or retrieval
   - API key configuration
   - OAuth2 flow for testing
3. Add request/response logging for debugging failures.
4. Configure timeout settings appropriate for the target environment.

### Step 7: Validate and Run

1. Write all test files following project conventions.
2. Start the local dev server if testing locally.
3. Run the contract tests:
   - Node.js: `npx jest --testPathPattern=contract` or `npx vitest run contract`
   - Python: `python -m pytest tests/contract/ -v`
   - Go: `go test -v -tags=contract ./...`
4. Analyze failures:
   - **Schema mismatch**: API response doesn't match documented schema — this is a real bug (either in the API or the spec)
   - **Missing endpoint**: Documented endpoint returns 404 — implementation missing
   - **Extra fields**: Response contains undocumented fields — spec needs updating
5. Report summary:
   - Endpoints tested vs total documented endpoints
   - Schema violations found (response doesn't match spec)
   - Spec gaps (undocumented fields, missing error schemas)
   - Recommendations for spec or API fixes

### Important Guidelines

- Contract tests verify the SHAPE of responses, not business logic — that belongs in integration tests.
- Run contract tests against a real (local or staging) server, not mocks — the point is to verify the real API matches its spec.
- Use strict schema validation by default (flag extra undocumented fields) — this catches spec drift.
- Generate one test file per API resource/tag for maintainability.
- Keep test data factories in a shared helper file for reuse.
- Contract tests should be fast — they verify structure, not performance.
- If the spec and API disagree, report BOTH as potential issues — do not assume either is correct.
- For large APIs, allow running contract tests for a subset of endpoints (by tag, path prefix, or method).
- Version the contract tests alongside the spec — when the spec changes, tests should update.
