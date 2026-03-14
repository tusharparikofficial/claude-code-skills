# API Client Generator

Generate a fully typed API client from an OpenAPI/Swagger specification file or URL.

## Arguments

$ARGUMENTS - `<openapi-spec-path-or-url>` Path to a local OpenAPI/Swagger JSON/YAML file, or a URL serving the spec.

## Instructions

### Step 1: Load the OpenAPI Specification

1. If the argument looks like a URL (starts with `http://` or `https://`), fetch the spec using the WebFetch tool or curl.
2. If the argument is a file path, read the file from disk.
3. Parse the spec (JSON or YAML). Identify the OpenAPI version (2.0/Swagger, 3.0, 3.1).
4. If the spec cannot be loaded or parsed, report the error clearly and stop.

### Step 2: Detect Project Language

Search the project root for configuration files:
- `package.json` or `tsconfig.json` --> TypeScript (use `fetch` API)
- `requirements.txt` or `pyproject.toml` --> Python (use `httpx` or `requests`)
- `go.mod` --> Go (use `net/http`)
- `pom.xml` or `build.gradle` --> Java (use `HttpClient` or `OkHttp`)

If multiple are found, prefer the one in the current working directory. If none found, default to TypeScript.

### Step 3: Extract API Information

From the spec, extract:
- **Base URL**: from `servers[0].url` (v3) or `host` + `basePath` (v2)
- **Authentication**: from `securityDefinitions` / `components.securitySchemes` (Bearer, API Key, OAuth2, Basic)
- **Endpoints**: all paths with their methods, parameters, request bodies, and responses
- **Schemas**: all schema definitions from `definitions` (v2) or `components.schemas` (v3)
- **Tags**: for grouping endpoints logically

### Step 4: Generate Type Definitions

Generate types/interfaces for every schema in the spec:

**TypeScript**:
```
- Export an interface for each schema
- Map OpenAPI types: string->string, integer->number, number->number, boolean->boolean, array->T[], object->nested interface
- Handle $ref references by resolving to the referenced type name
- Handle nullable fields with | null
- Handle required vs optional fields (optional uses ?)
- Handle enums as string literal unions
- Handle allOf (intersection types), oneOf/anyOf (union types)
- Handle date/date-time format as string (with JSDoc noting the format)
- Generate request body types and response types for each endpoint
- Generate query parameter interfaces for endpoints with query params
```

**Python**:
```
- Use Pydantic BaseModel for each schema
- Use typing module (Optional, List, Dict, Union, Literal)
- Map types: string->str, integer->int, number->float, boolean->bool, array->List[T]
- Handle enums as Literal types or Python Enum classes
- Use datetime for date-time format fields
- Handle Optional for nullable/non-required fields
```

**Go**:
```
- Generate structs with json tags for each schema
- Map types: string->string, integer->int64, number->float64, boolean->bool, array->[]T
- Use *T for optional/nullable fields
- Use time.Time for date-time fields
- Handle enums as string type with const block
```

### Step 5: Generate Client Functions

For each endpoint in the spec, generate a function:

**TypeScript**:
```typescript
// Pattern for each endpoint:
// - Function name: camelCase from operationId, or methodPath (e.g., getUsers, createUser)
// - Typed path parameters interpolated into URL
// - Typed query parameters appended as URLSearchParams
// - Typed request body for POST/PUT/PATCH
// - Typed return value from success response schema
// - Error handling with typed error response

// Generate a client class or object:
export class ApiClient {
  private baseUrl: string;
  private headers: Record<string, string>;

  constructor(config: ClientConfig) { ... }

  // Request/response interceptors
  addRequestInterceptor(fn: RequestInterceptor): void;
  addResponseInterceptor(fn: ResponseInterceptor): void;

  // Auth helpers
  setAuthToken(token: string): void;
  setApiKey(key: string, headerName?: string): void;

  // Generated endpoint methods
  async getUsers(params?: GetUsersParams): Promise<GetUsersResponse> { ... }
  async createUser(body: CreateUserRequest): Promise<CreateUserResponse> { ... }
  // ... etc
}
```

**Python**:
```python
# Generate a client class using httpx (async) or requests (sync)
# - Type hints on all methods
# - Dataclass or Pydantic models for request/response
# - Context manager support (__aenter__/__aexit__ for async)
# - Auth token/API key management
# - Request/response hooks
# - Retry logic with exponential backoff
```

**Go**:
```go
// Generate a client struct with methods
// - Context parameter on all methods
// - Functional options pattern for client configuration
// - Proper error types for API errors
// - Response structs with status code
// - Auth token management
// - HTTP client injection for testing
```

### Step 6: Generate Supporting Code

**Error Types**:
```
- ApiError class/struct with status code, message, response body
- Typed error responses from spec's error schemas (4xx, 5xx)
- Network error handling (timeout, connection refused)
```

**Configuration**:
```
- ClientConfig type with baseUrl, timeout, headers, auth
- Default configuration with sensible timeouts (30s)
- Environment variable support for base URL and auth tokens
```

**Interceptors**:
```
- Request interceptor: modify headers, log requests, add auth
- Response interceptor: handle common errors, transform responses, log
- Error interceptor: retry logic, error reporting
```

### Step 7: Generate Index/Barrel File

Create an index file that re-exports everything:
- All types
- The client class
- Configuration types
- Error types

### Step 8: File Placement

Place generated files following the project's conventions:
- TypeScript: `src/api/<api-name>/` or `src/lib/api/` or `src/clients/`
- Python: `<package>/api_client/` or `<package>/clients/`
- Go: `pkg/apiclient/` or `internal/client/`

If the project has an existing API client pattern, follow it.

### Step 9: Summary

Print:
1. List of all generated files with their paths
2. Total number of endpoints covered
3. Total number of types generated
4. Any endpoints that were skipped (and why)
5. Required dependencies that may need installing (e.g., `httpx`, `zod`)
6. Example usage snippet showing how to instantiate and use the client
