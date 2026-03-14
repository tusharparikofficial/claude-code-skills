# Security Audit

Perform a comprehensive security audit of the application, identifying vulnerabilities across multiple categories and providing actionable remediation.

## Arguments

$ARGUMENTS - Optional scope: `full` (default), `auth`, `api`, `data`, or `deps`. Limits the audit to a specific domain.

## Instructions

You are performing a security audit. Parse the scope from `$ARGUMENTS` (default to `full` if empty or unrecognized).

### Step 0: Project Discovery

1. Detect the project language and framework by examining `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, or equivalent.
2. Identify the web framework (Express, Next.js, Django, Flask, FastAPI, Gin, Rails, Spring, etc.).
3. Identify the database layer (ORM or raw queries).
4. Map out the application entry points (routes, controllers, handlers).

### Step 1: Dependency Scan (scope: full, deps)

1. Run the appropriate dependency audit command:
   - **Node.js**: `npm audit --json` or `yarn audit --json` or `pnpm audit --json`
   - **Python**: `pip-audit --format=json` (install with `pip install pip-audit` if missing, or just search `requirements.txt` / `pyproject.toml` for known-vulnerable version ranges)
   - **Go**: `govulncheck ./...` (if available, otherwise inspect `go.sum` manually)
   - **Rust**: `cargo audit` (if available)
   - **Ruby**: `bundle audit` (if available)
2. If the audit tool is not installed, manually search for commonly vulnerable packages and versions.
3. Categorize each finding by severity (CRITICAL/HIGH/MEDIUM/LOW).
4. For each vulnerable dependency, note the CVE ID, affected version, and fixed version.

### Step 2: Secret Scan (scope: full, data)

1. Search the entire codebase for hardcoded secrets using these patterns:
   - API keys: patterns like `AKIA`, `sk-`, `sk_live_`, `pk_live_`, `ghp_`, `gho_`, `github_pat_`
   - Passwords: variables named `password`, `passwd`, `secret`, `api_key`, `apiKey`, `token`, `auth`
   - Connection strings: `postgres://`, `mysql://`, `mongodb://`, `redis://`, `amqp://` with embedded credentials
   - Private keys: `-----BEGIN RSA PRIVATE KEY-----`, `-----BEGIN EC PRIVATE KEY-----`
   - AWS: `aws_access_key_id`, `aws_secret_access_key`
   - Generic: Base64-encoded strings in config files that look like secrets
2. Check `.env` files that might be committed (verify `.gitignore` includes `.env*`).
3. Check git history is not searched for secrets in this step (note recommendation to use `trufflehog` or `gitleaks` for git history scanning).
4. Check for secrets in CI/CD config files (`.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`).

### Step 3: Input Validation (scope: full, api)

1. Find all route handlers / controller methods that accept user input.
2. For each endpoint, check:
   - Is the request body validated against a schema (Zod, Joi, class-validator, Pydantic, marshmallow, etc.)?
   - Are URL parameters validated (type, range, format)?
   - Are query parameters validated?
   - Are file uploads validated (type, size, content)?
3. Flag any endpoint that processes user input without validation.

### Step 4: SQL Injection (scope: full, api, data)

1. Search for raw SQL query patterns:
   - String concatenation with user input: `"SELECT * FROM users WHERE id = " + id`
   - Template literals with user input: `` `SELECT * FROM users WHERE id = ${id}` ``
   - f-strings with user input: `f"SELECT * FROM users WHERE id = {id}"`
   - `.format()` with user input in SQL
   - `%s` formatting in Python without parameterized queries
2. Check ORM usage for raw query escapes (e.g., `Sequelize.literal()`, `django.db.connection.cursor()`, `gorm.Raw()`).
3. Verify parameterized queries are used everywhere.

### Step 5: XSS (scope: full, api)

1. Search for patterns that render user input into HTML:
   - React: `dangerouslySetInnerHTML` without sanitization
   - Vue: `v-html` directive with user data
   - Angular: `bypassSecurityTrustHtml`
   - Server-side templates: unescaped output (`{!! !!}` in Blade, `|safe` in Jinja2, `<%- %>` in EJS, `!{}` in Pug)
   - Direct DOM manipulation: `innerHTML`, `outerHTML`, `document.write()`
2. Check that user-generated content is sanitized (DOMPurify, bleach, sanitize-html, etc.).
3. Check for reflected XSS in URL parameters rendered in pages.

### Step 6: CSRF Protection (scope: full, auth, api)

1. Identify all state-changing endpoints (POST, PUT, PATCH, DELETE).
2. Check for CSRF protection:
   - Token-based: CSRF tokens in forms and validated server-side
   - SameSite cookies: `SameSite=Strict` or `SameSite=Lax`
   - Custom headers: requiring custom headers like `X-Requested-With`
   - Framework built-in: Django CSRF middleware, Express csurf, etc.
3. Check that API endpoints using cookie-based auth have CSRF protection.
4. Note: Token-based auth (Bearer tokens in headers) is inherently CSRF-safe.

### Step 7: Authentication & Authorization (scope: full, auth)

1. Check authentication implementation:
   - Password hashing algorithm (must be argon2, bcrypt, or scrypt - NOT md5, sha1, sha256)
   - Password strength requirements enforced
   - Rate limiting on login endpoint
   - Account lockout after failed attempts
   - Secure session/token management
2. Check authorization:
   - Every protected endpoint has auth middleware/guard
   - Role-based or permission-based access control
   - No broken object-level authorization (BOLA/IDOR) - users can only access their own resources
   - Admin endpoints properly restricted
3. Check token/session security:
   - JWT: proper algorithm (RS256/EdDSA, not HS256 with weak secret), expiry set, refresh token rotation
   - Sessions: secure cookie flags (HttpOnly, Secure, SameSite), proper expiry

### Step 8: Security Headers (scope: full, api)

1. Check for security headers configuration:
   - Content-Security-Policy
   - Strict-Transport-Security
   - X-Content-Type-Options
   - X-Frame-Options
   - Referrer-Policy
   - Permissions-Policy
2. Check the framework configuration, middleware, or reverse proxy config for these headers.
3. Flag any missing headers.

### Step 9: CORS Configuration (scope: full, api)

1. Find CORS configuration in the codebase.
2. Check for overly permissive settings:
   - `Access-Control-Allow-Origin: *` with credentials
   - Reflecting the Origin header without validation
   - Wildcard in allowed methods or headers
   - Overly broad origin whitelist
3. Verify that CORS is configured to allow only the intended origins.

### Step 10: Encryption (scope: full, data)

1. Check for proper TLS/HTTPS enforcement:
   - HSTS headers
   - HTTP to HTTPS redirect
   - No mixed content
2. Check encryption at rest:
   - Sensitive data in database (PII, payment info) is encrypted
   - Encryption keys are properly managed (not hardcoded)
3. Check for use of weak cryptographic algorithms:
   - MD5 or SHA1 for anything security-related
   - DES or 3DES
   - ECB mode for block ciphers
   - Small RSA keys (<2048 bits)

### Step 11: Error Handling (scope: full, api)

1. Search for error handlers and catch blocks.
2. Check that error responses to clients:
   - Do NOT include stack traces in production
   - Do NOT include internal file paths
   - Do NOT include SQL queries or database details
   - Do NOT include dependency versions
   - Return generic messages to users while logging detailed info server-side
3. Check for unhandled promise rejections / unhandled exceptions.

### Step 12: Logging (scope: full, data)

1. Search for logging statements (`console.log`, `logger.info`, `logging.debug`, etc.).
2. Check that logs do NOT contain:
   - Passwords or credentials
   - API keys or tokens
   - Full credit card numbers
   - Social security numbers
   - Personal health information
   - Session tokens
3. Check that sensitive request fields are redacted in request logging middleware.

### Output Format

Present findings in this structure:

```
## Security Audit Report

**Project**: <name>
**Framework**: <detected framework>
**Scope**: <scope>
**Date**: <current date>
**Risk Score**: <X/100> (0 = no risk, 100 = critical risk)

### Executive Summary

<2-3 sentence overview of security posture>

### Findings

#### CRITICAL (must fix immediately)

**[C-001] <Title>**
- **Category**: <category>
- **Location**: `<file:line>`
- **Description**: <what the vulnerability is>
- **Impact**: <what an attacker could do>
- **Remediation**:
<specific code fix>
- **Reference**: <CWE/OWASP link if applicable>

#### HIGH (fix before next release)
...

#### MEDIUM (fix in next sprint)
...

#### LOW (address when convenient)
...

### Statistics
- Total findings: X
- Critical: X | High: X | Medium: X | Low: X
- Categories covered: X/12

### Recommendations
1. <Prioritized action items>
```

If the scope is not `full`, only execute the steps relevant to the chosen scope and adjust the report accordingly.
