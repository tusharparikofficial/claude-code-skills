# Generate API Documentation

Generate API documentation from source code by scanning route definitions and handlers.

## Arguments

$ARGUMENTS - Optional format: `openapi`, `markdown`, or `html`. Defaults to `markdown`.

## Instructions

1. **Determine the output format** from `$ARGUMENTS`:
   - If empty or `markdown`: generate a Markdown reference document
   - If `openapi`: generate a valid `openapi.yaml` (OpenAPI 3.0+)
   - If `html`: generate a self-contained HTML API reference

2. **Detect the API framework** by scanning for:
   - **Express/Fastify/Koa/Hono**: `app.get()`, `router.post()`, route files
   - **NestJS**: `@Controller`, `@Get()`, `@Post()` decorators
   - **Django/DRF**: `urlpatterns`, `@api_view`, `ViewSet`
   - **FastAPI**: `@app.get()`, `@router.post()`, Pydantic models
   - **Flask**: `@app.route()`, `Blueprint`
   - **Spring Boot**: `@RestController`, `@RequestMapping`
   - **Go (net/http, Gin, Echo, Chi)**: `HandleFunc`, `r.GET()`, handler functions
   - **Rails**: `config/routes.rb`, controllers
   - **Laravel**: `routes/api.php`, controllers

3. **For each endpoint discovered, extract:**
   - HTTP method and path
   - Path parameters and query parameters
   - Request body schema (from types, interfaces, Pydantic models, DTOs, validation schemas)
   - Response schema (from return types, serializers, response models)
   - Authentication requirements (middleware, decorators, guards)
   - Error responses (from error handlers, exception filters)
   - Description from comments, docstrings, or decorators

4. **For Markdown format**, generate:
   ```markdown
   # API Reference

   Base URL: `<detected or configurable>`

   ## Authentication
   Description of auth mechanism (Bearer token, API key, session, etc.)

   ## Endpoints

   ### Resource Name

   #### `METHOD /path`
   Description.

   **Parameters:**
   | Name | In | Type | Required | Description |
   |------|-----|------|----------|-------------|

   **Request Body:**
   ```json
   { "example": "value" }
   ```

   **Response:** `200 OK`
   ```json
   { "example": "response" }
   ```

   **Errors:**
   | Status | Description |
   |--------|-------------|

   **Example:**
   ```bash
   curl -X METHOD http://localhost:PORT/path \
     -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     -d '{"example": "value"}'
   ```
   ```

5. **For OpenAPI format**, generate a valid `openapi.yaml`:
   - OpenAPI version 3.0.3 or 3.1.0
   - Complete `info` block with title, version, description
   - All paths with operations
   - Components/schemas for all request/response models
   - Security schemes
   - Validate structure is correct YAML

6. **For HTML format**, generate:
   - Self-contained single HTML file with embedded CSS
   - Navigation sidebar with endpoint groups
   - Collapsible endpoint details
   - Syntax-highlighted code examples
   - Copy-to-clipboard for curl examples

7. **Output the file:**
   - Markdown: `docs/API.md`
   - OpenAPI: `docs/openapi.yaml`
   - HTML: `docs/api.html`
   - Create the `docs/` directory if it doesn't exist
   - If the file already exists, show the user what changed and ask before overwriting
