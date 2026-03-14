# Fix Security Vulnerability

Identify, fix, test, and document a specific security vulnerability in the project.

## Arguments

$ARGUMENTS - A vulnerability description, CVE ID (e.g., `CVE-2024-1234`), or an audit finding reference (e.g., `C-001: SQL injection in /api/users`).

## Instructions

You are fixing a specific security vulnerability. The input is: `$ARGUMENTS`.

### Step 1: Research the Vulnerability

1. **If a CVE ID is provided**:
   - Search for the CVE details using web search or known CVE databases.
   - Identify: affected package, affected versions, fixed version, vulnerability type, severity (CVSS score).
   - Determine if the project uses the affected package and version by checking dependency files.

2. **If a vulnerability description is provided**:
   - Parse the description to identify: vulnerability type (SQLi, XSS, CSRF, etc.), affected area, severity.
   - Map to the relevant CWE (Common Weakness Enumeration) category.

3. **If an audit finding reference is provided**:
   - Locate the finding in the codebase based on the description.

4. Document your understanding:
   ```
   Vulnerability: <type>
   Severity: <CRITICAL/HIGH/MEDIUM/LOW>
   CWE: <CWE-ID if applicable>
   CVE: <CVE-ID if applicable>
   Affected component: <package or code area>
   ```

### Step 2: Identify Affected Code

1. Search the codebase for all instances of the vulnerable pattern or usage of the vulnerable dependency.
2. Map out every file and line that is affected.
3. Check for the same vulnerability pattern in other parts of the codebase (the reported instance may not be the only one).
4. List all affected locations:
   ```
   Affected files:
   - <file1>:<line> - <brief description>
   - <file2>:<line> - <brief description>
   ```

### Step 3: Determine Fix Approach

Choose the appropriate fix based on vulnerability type:

**Dependency CVE**:
- Update to the patched version.
- Check for breaking changes between current and patched version.
- If no patch exists, evaluate alternatives or implement a workaround.

**SQL Injection**:
- Replace string concatenation with parameterized queries.
- Use the ORM's built-in query builder instead of raw SQL.
- Add input validation as defense-in-depth.

**XSS (Cross-Site Scripting)**:
- Implement output encoding/escaping appropriate to the context (HTML, JS, URL, CSS).
- Use a sanitization library (DOMPurify, bleach, sanitize-html).
- Remove or replace `dangerouslySetInnerHTML`, `v-html`, or equivalent.

**CSRF**:
- Implement CSRF token generation and validation.
- Set `SameSite=Lax` or `SameSite=Strict` on cookies.
- Use framework-provided CSRF middleware.

**Broken Authentication**:
- Implement proper password hashing (argon2id or bcrypt).
- Add rate limiting to authentication endpoints.
- Implement account lockout after failed attempts.
- Use secure session/token configuration.

**Broken Access Control (IDOR/BOLA)**:
- Add ownership checks: verify the authenticated user owns the requested resource.
- Implement role-based or attribute-based access control middleware.
- Use indirect references instead of direct database IDs where possible.

**Insecure Deserialization**:
- Validate and sanitize serialized data before deserializing.
- Use safe deserialization methods (JSON instead of pickle/YAML with unsafe loaders).
- Add integrity checks (HMAC) on serialized data.

**Rate Limiting**:
- Add rate limiting middleware to the affected endpoint.
- Configure per-IP and per-user limits.
- Return proper 429 status with `Retry-After` header.

**Input Validation**:
- Add schema validation (Zod, Joi, Pydantic, etc.) to the endpoint.
- Validate type, length, format, and range of all inputs.
- Reject unexpected fields (allowlist approach).

### Step 4: Apply the Fix

1. Show the **BEFORE** state of the vulnerable code (the exact vulnerable lines).
2. Apply the fix with minimal, surgical changes. Do NOT refactor unrelated code.
3. Show the **AFTER** state of the fixed code.
4. If the fix requires a new dependency:
   - Choose a well-maintained, widely-used library.
   - Install it using the project's package manager.
   - Verify it does not introduce new vulnerabilities.
5. If the fix requires configuration changes (env vars, config files), document them clearly.

### Step 5: Add Security Tests

Write tests that:

1. **Prove the vulnerability existed** (the test would fail on the old code):
   - Send a malicious payload that would have exploited the vulnerability.
   - Verify it is now properly rejected or neutralized.

2. **Verify the fix works**:
   - Test with known attack payloads for the vulnerability type.
   - Test edge cases and bypass attempts.
   - Test that legitimate inputs still work correctly.

3. **Common test payloads by vulnerability type**:
   - SQLi: `' OR '1'='1`, `'; DROP TABLE users; --`, `1 UNION SELECT * FROM users`
   - XSS: `<script>alert(1)</script>`, `"><img src=x onerror=alert(1)>`, `javascript:alert(1)`
   - Path traversal: `../../etc/passwd`, `..\\..\\windows\\system32`
   - Command injection: `; ls -la`, `$(whoami)`, `` `id` ``
   - SSRF: `http://169.254.169.254/latest/meta-data/`, `http://localhost:6379/`

4. Place tests in the appropriate test directory following project conventions.
5. Run the tests to confirm they pass.

### Step 6: Verify No Regressions

1. Run the full test suite to ensure the fix does not break existing functionality.
2. If tests fail, determine whether the failure is:
   - Related to the fix (adjust the fix).
   - A pre-existing issue (note it but do not fix in this scope).
3. If the project has a build step, run the build to verify it succeeds.

### Step 7: Document the Fix

Present the complete fix report:

```
## Vulnerability Fix Report

### Vulnerability Details
- **Type**: <vulnerability type>
- **Severity**: <CRITICAL/HIGH/MEDIUM/LOW>
- **CVE**: <CVE-ID if applicable>
- **CWE**: <CWE category>
- **CVSS**: <score if known>

### Affected Code
| File | Line(s) | Description |
|------|---------|-------------|
| <file> | <lines> | <what was vulnerable> |

### Before (Vulnerable)
<code snippet showing vulnerable code>

### After (Fixed)
<code snippet showing fixed code>

### Fix Summary
<1-2 sentence description of what was changed and why>

### Tests Added
| Test | Purpose |
|------|---------|
| <test name> | <what it verifies> |

### Verification Steps
1. <How to manually verify the fix>
2. <How to run the automated tests>

### Additional Recommendations
- <Any related hardening suggestions>
```

### Important Rules

- NEVER introduce new vulnerabilities while fixing one.
- NEVER weaken existing security measures.
- ALWAYS use the principle of least privilege.
- ALWAYS validate on the server side, never rely solely on client-side validation.
- If unsure about the correct fix, err on the side of being more restrictive.
- If the fix requires a dependency update with breaking changes, document the migration steps.
