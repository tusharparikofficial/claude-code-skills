# Security Review

Security-focused code review against OWASP Top 10, secret detection, and web security best practices.

## Arguments

$ARGUMENTS - File path or directory to scan (defaults to staged changes if not provided or empty)

## Instructions

### Step 1: Determine Scope

If `$ARGUMENTS` is provided and not empty:
- Check if it is a file or directory using the Bash tool: `test -f "$ARGUMENTS" && echo "file" || (test -d "$ARGUMENTS" && echo "dir" || echo "notfound")`
- If file: scan that single file
- If directory: scan all source code files in that directory recursively. Use `find "$ARGUMENTS" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.php" -o -name "*.rs" -o -name "*.cs" \) | head -100` to get the list

If `$ARGUMENTS` is empty or not provided:
- Use `git diff --staged` to get staged changes
- If no staged changes, use `git diff` for unstaged changes
- If no changes at all, inform the user and stop

### Step 2: Identify Technology Stack

Before scanning, determine the project's technology stack by checking for:
- `package.json` (Node.js/JavaScript/TypeScript)
- `requirements.txt` / `pyproject.toml` / `Pipfile` (Python)
- `go.mod` (Go)
- `pom.xml` / `build.gradle` (Java)
- `Gemfile` (Ruby)
- `composer.json` (PHP)
- `Cargo.toml` (Rust)

This determines which vulnerability patterns are relevant.

### Step 3: OWASP Top 10 Analysis

Scan all files in scope for each category. Use Grep to search for patterns and Read to examine flagged files in detail.

#### A01: Injection

Search for:
- **SQL Injection**: String concatenation in SQL queries. Look for patterns like `"SELECT.*" + variable`, `f"SELECT.*{`, `query(.*\+.*)`  without parameterized queries
- **NoSQL Injection**: Unsanitized input in MongoDB queries (`$where`, `$regex` from user input), Firestore queries built from raw input
- **OS Command Injection**: `exec(`, `spawn(`, `system(`, `popen(`, `subprocess.call(.*shell=True`, backtick execution with user input
- **LDAP Injection**: LDAP queries built with string concatenation
- **Template Injection**: User input passed directly to template engines (`render_template_string`, `eval`, `new Function()`)
- **XPath Injection**: XPath queries with concatenated user input
- **Header Injection**: User input in HTTP headers without sanitization

For each finding, check if the input is validated/sanitized before use. If parameterized queries or prepared statements are used, it is NOT a finding.

#### A02: Broken Authentication

Search for:
- Weak password policies (no minimum length, no complexity requirements)
- Missing rate limiting on login endpoints
- Session tokens in URLs
- Missing session expiration or overly long session lifetimes
- Credentials sent over HTTP (not HTTPS)
- Password stored in plaintext or with weak hashing (MD5, SHA1 without salt)
- Missing multi-factor authentication for sensitive operations
- JWT issues: algorithm confusion (`alg: none`), missing expiration, weak secrets, missing audience/issuer validation

#### A03: Sensitive Data Exposure

Search for:
- Sensitive data in logs (`password`, `token`, `secret`, `ssn`, `credit_card` in log statements)
- PII in error messages returned to users
- Missing encryption for data at rest
- Sensitive data in local storage or cookies without secure flags
- API responses that include more data than necessary (over-fetching)
- Sensitive data in git history (check for `.env` files, credentials in config)

#### A04: XML External Entities (XXE)

Search for:
- XML parsers without entity resolution disabled
- `DocumentBuilderFactory` without `setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)`
- `lxml.etree.parse` without `resolve_entities=False`
- Any XML parsing of user-supplied content

#### A05: Broken Access Control

Search for:
- Missing authorization checks on endpoints (endpoints without auth middleware)
- Direct object references without ownership validation (using user-supplied IDs without checking permissions)
- Path traversal: user input in file paths without sanitization (`../` not stripped)
- CORS configured with `Access-Control-Allow-Origin: *` for authenticated endpoints
- Missing function-level access control (admin functions accessible by regular users)
- IDOR (Insecure Direct Object Reference) patterns

#### A06: Security Misconfiguration

Search for:
- Debug mode enabled in production (`DEBUG = True`, `NODE_ENV !== 'production'` checks missing)
- Default credentials in configuration
- Verbose error messages exposing stack traces to users
- Unnecessary features enabled (directory listing, admin consoles)
- Missing security headers (check for middleware/configuration)
- Permissive file upload without validation

#### A07: Cross-Site Scripting (XSS)

Search for:
- `dangerouslySetInnerHTML` in React without sanitization
- `innerHTML`, `outerHTML`, `document.write` with user input
- Template interpolation of user input without escaping (`v-html`, `{!! !!}` in Blade, `|safe` in Jinja2)
- URL schemes: `javascript:` in user-supplied URLs
- Event handlers with user input
- Missing Content-Security-Policy headers

#### A08: Insecure Deserialization

Search for:
- `pickle.loads()`, `yaml.load()` (without safe_load), `Marshal.load` with untrusted data
- `JSON.parse` of untrusted data used to instantiate objects
- `ObjectInputStream` in Java with untrusted data
- `unserialize()` in PHP with user input

#### A09: Using Components with Known Vulnerabilities

Check:
- Run `npm audit --json 2>/dev/null` or `pip-audit --format json 2>/dev/null` or `govulncheck ./... 2>/dev/null` if available
- Check for outdated dependencies that may have known CVEs
- Flag any pinned dependency versions that are known-vulnerable

#### A10: Insufficient Logging and Monitoring

Search for:
- Missing logging on authentication events (login, logout, failed attempts)
- Missing logging on authorization failures
- Missing logging on input validation failures
- Sensitive data in logs (passwords, tokens, credit cards)
- Missing audit trail for data modifications
- No rate limiting on critical endpoints

### Step 4: Additional Security Checks

**CSRF Protection**
- Forms without CSRF tokens
- State-changing operations on GET requests
- Missing `SameSite` cookie attribute
- CSRF middleware disabled or bypassed

**CORS Configuration**
- Wildcard origins with credentials
- Overly permissive CORS policies
- Missing CORS configuration (defaults may be insecure)

**CSP Headers**
- Missing Content-Security-Policy
- `unsafe-inline` or `unsafe-eval` in CSP
- Overly broad source directives

**Cookie Security**
- Missing `Secure` flag (cookies sent over HTTP)
- Missing `HttpOnly` flag (cookies accessible via JavaScript)
- Missing `SameSite` attribute
- Sensitive data in cookies without encryption

**Rate Limiting**
- Missing rate limiting on authentication endpoints
- Missing rate limiting on API endpoints that perform expensive operations
- Missing rate limiting on endpoints that send emails/SMS

**Secret Detection**
Scan all files in scope with these regex patterns:
- AWS: `AKIA[0-9A-Z]{16}`, `aws_secret_access_key`
- GitHub: `ghp_[a-zA-Z0-9]{36}`, `gho_`, `ghu_`, `ghs_`, `ghr_`
- Stripe: `sk_live_[a-zA-Z0-9]{24,}`, `pk_live_`
- Slack: `xoxb-`, `xoxp-`, `xoxs-`
- OpenAI: `sk-[a-zA-Z0-9]{32,}`
- Generic: `(password|secret|token|api_key|apikey|auth)\s*[:=]\s*['"][^\s'"]{8,}['"]`
- Private keys: `-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----`
- Connection strings: `(mongodb|postgres|mysql|redis):\/\/[^:]+:[^@]+@`

### Step 5: Generate Report

Format as:

```
## Security Review Report

**Scope**: <file/directory/staged changes>
**Technology Stack**: <detected stack>
**Scan Date**: <current date>

---

### Executive Summary

<2-3 sentences: overall security posture, number of findings by severity, most critical issue>

---

### Findings

#### CRITICAL (<count>)

**[SEC-C1]** <OWASP Category> — <title>
- **File**: `path/to/file.ext:line`
- **Vulnerability**: <detailed description of the vulnerability>
- **Attack Vector**: <how an attacker could exploit this>
- **Impact**: <what damage could result>
- **Remediation**:
  ```<lang>
  // Current vulnerable code
  <vulnerable code>

  // Fixed code
  <remediated code>
  ```

#### HIGH (<count>)

**[SEC-H1]** <OWASP Category> — <title>
- **File**: `path/to/file.ext:line`
- **Vulnerability**: <description>
- **Remediation**:
  ```<lang>
  <fix>
  ```

#### MEDIUM (<count>)

**[SEC-M1]** <title>
- **File**: `path/to/file.ext:line`
- **Issue**: <description>
- **Recommendation**: <what to do>

#### LOW (<count>)

**[SEC-L1]** <title> — `path/to/file.ext:line` — <description and recommendation>

---

### OWASP Top 10 Coverage

| Category | Status | Findings |
|----------|--------|----------|
| A01: Injection | PASS/FAIL | <count> |
| A02: Broken Authentication | PASS/FAIL | <count> |
| A03: Sensitive Data Exposure | PASS/FAIL | <count> |
| A04: XXE | PASS/FAIL/N/A | <count> |
| A05: Broken Access Control | PASS/FAIL | <count> |
| A06: Security Misconfiguration | PASS/FAIL | <count> |
| A07: XSS | PASS/FAIL | <count> |
| A08: Insecure Deserialization | PASS/FAIL/N/A | <count> |
| A09: Known Vulnerabilities | PASS/FAIL | <count> |
| A10: Insufficient Logging | PASS/FAIL | <count> |

### Additional Checks

| Check | Status |
|-------|--------|
| CSRF Protection | PASS/FAIL/N/A |
| CORS Configuration | PASS/FAIL/N/A |
| CSP Headers | PASS/FAIL/N/A |
| Cookie Security | PASS/FAIL/N/A |
| Rate Limiting | PASS/FAIL/N/A |
| Secret Detection | PASS/FAIL |

---

### Remediation Priority

1. <Most critical fix with estimated effort>
2. <Second priority>
3. ...
```

If there are CRITICAL findings, emphasize that they must be fixed before the code is deployed or merged. Offer to apply remediation fixes automatically for CRITICAL and HIGH issues.
