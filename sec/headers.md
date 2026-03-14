# Implement Security Headers

Configure comprehensive HTTP security headers tailored to the project's framework and requirements.

## Arguments

$ARGUMENTS - Optional framework name: `express`, `nextjs`, `django`, `flask`, `fastapi`, `nginx`, `apache`, `nuxt`, `rails`, `spring`. Auto-detects if not specified.

## Instructions

You are implementing security headers for this project. If `$ARGUMENTS` specifies a framework, use it. Otherwise, auto-detect.

### Step 1: Framework Detection

If no framework was specified, detect it by examining:
- `package.json` for `next`, `express`, `koa`, `fastify`, `hapi`, `nuxt`
- `requirements.txt` / `pyproject.toml` for `django`, `flask`, `fastapi`, `starlette`
- `go.mod` for `gin`, `echo`, `fiber`, `chi`
- `Gemfile` for `rails`, `sinatra`
- `pom.xml` / `build.gradle` for `spring`
- `nginx.conf`, `apache2.conf`, `httpd.conf` for reverse proxy configs

Also identify:
- Does the app serve HTML pages (needs full CSP) or only an API (simpler headers)?
- Does the app use inline scripts or styles (affects CSP)?
- Does the app embed iframes or get embedded in iframes?
- Does the app use web workers or service workers?
- What CDN domains or third-party scripts are loaded?

### Step 2: Design the Header Configuration

Build the security headers configuration based on the project's needs:

#### Content-Security-Policy (CSP)

This is the most complex header. Tailor it to the project:

1. **Scan the codebase** for:
   - Inline `<script>` tags and `<style>` tags (will need `'unsafe-inline'` or nonces)
   - External script sources (CDNs, analytics, etc.)
   - External style sources (Google Fonts, CDNs, etc.)
   - Image sources (CDN, S3, external URLs)
   - Font sources (Google Fonts, self-hosted)
   - API endpoints (connect-src)
   - iframe embeds (frame-src)
   - Web workers (worker-src)
   - Form actions (form-action)

2. **Build the CSP directives**:
   ```
   default-src 'self';
   script-src 'self' <detected script sources>;
   style-src 'self' <detected style sources>;
   img-src 'self' data: <detected image sources>;
   font-src 'self' <detected font sources>;
   connect-src 'self' <detected API endpoints>;
   frame-src 'none' OR <detected iframe sources>;
   frame-ancestors 'none' OR 'self';
   form-action 'self';
   base-uri 'self';
   object-src 'none';
   upgrade-insecure-requests;
   ```

3. **For Next.js specifically**: Use nonce-based CSP with `next/headers` or middleware. Next.js requires `'unsafe-eval'` in development mode and potentially `'unsafe-inline'` for styled-jsx.

4. **Start with report-only mode** by using `Content-Security-Policy-Report-Only` header first, so existing functionality is not broken. Include a comment explaining how to switch to enforcement mode.

#### Other Security Headers

Configure all of the following:

```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=(), interest-cohort=()
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Resource-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
X-XSS-Protection: 0
```

Adjust based on project needs:
- If the app is embedded in iframes: change `X-Frame-Options` to `SAMEORIGIN` and adjust `frame-ancestors`.
- If the app uses `SharedArrayBuffer`: keep `COOP: same-origin` and `COEP: require-corp`.
- If the app does NOT use `SharedArrayBuffer` and loads cross-origin resources: consider `COEP: unsafe-none` or `credentialless`.
- If the app needs geolocation/camera/microphone: adjust `Permissions-Policy` accordingly.

### Step 3: Implement Headers (Framework-Specific)

#### Express / Node.js

1. Check if `helmet` is already installed. If not, install it: `npm install helmet`.
2. Add helmet middleware with custom configuration:
   ```js
   const helmet = require('helmet');

   app.use(helmet({
     contentSecurityPolicy: {
       directives: {
         // ... tailored CSP directives
       },
       reportOnly: true, // Start in report-only mode
     },
     strictTransportSecurity: {
       maxAge: 63072000,
       includeSubDomains: true,
       preload: true,
     },
     crossOriginOpenerPolicy: { policy: 'same-origin' },
     crossOriginResourcePolicy: { policy: 'same-origin' },
     crossOriginEmbedderPolicy: { policy: 'require-corp' },
     referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
     permissionsPolicy: {
       camera: [],
       microphone: [],
       geolocation: [],
     },
   }));
   ```
3. Place the middleware early in the middleware chain (before routes).

#### Next.js

1. Add headers to `next.config.js` (or `next.config.ts`):
   ```js
   const securityHeaders = [
     { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
     { key: 'X-Content-Type-Options', value: 'nosniff' },
     { key: 'X-Frame-Options', value: 'DENY' },
     { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
     { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
     { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
     { key: 'Cross-Origin-Resource-Policy', value: 'same-origin' },
     // CSP configured separately with nonces in middleware
   ];

   module.exports = {
     async headers() {
       return [{ source: '/(.*)', headers: securityHeaders }];
     },
   };
   ```
2. For CSP with nonces, create or update `middleware.ts` to generate a nonce per request and set the CSP header with it.

#### Django

1. Add security middleware settings to `settings.py`:
   ```python
   SECURE_HSTS_SECONDS = 63072000
   SECURE_HSTS_INCLUDE_SUBDOMAINS = True
   SECURE_HSTS_PRELOAD = True
   SECURE_CONTENT_TYPE_NOSNIFF = True
   X_FRAME_OPTIONS = 'DENY'
   SECURE_REFERRER_POLICY = 'strict-origin-when-cross-origin'
   SECURE_CROSS_ORIGIN_OPENER_POLICY = 'same-origin'
   ```
2. For CSP, install `django-csp` (`pip install django-csp`) and configure:
   ```python
   CSP_DEFAULT_SRC = ("'self'",)
   CSP_SCRIPT_SRC = ("'self'",)
   CSP_STYLE_SRC = ("'self'",)
   # ... etc
   CSP_REPORT_ONLY = True  # Start in report-only mode
   ```
3. Ensure `django.middleware.security.SecurityMiddleware` is in `MIDDLEWARE`.

#### Flask / FastAPI

1. For Flask, install `flask-talisman` (`pip install flask-talisman`) or implement a custom `@app.after_request` handler.
2. For FastAPI, create a middleware that adds headers to every response:
   ```python
   @app.middleware("http")
   async def add_security_headers(request, call_next):
       response = await call_next(request)
       response.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains; preload"
       response.headers["X-Content-Type-Options"] = "nosniff"
       # ... etc
       return response
   ```

#### Nginx

1. Add to the `server` block or `http` block:
   ```nginx
   add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
   add_header X-Content-Type-Options "nosniff" always;
   add_header X-Frame-Options "DENY" always;
   add_header Referrer-Policy "strict-origin-when-cross-origin" always;
   add_header Content-Security-Policy-Report-Only "default-src 'self'; ..." always;
   add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
   add_header Cross-Origin-Opener-Policy "same-origin" always;
   add_header Cross-Origin-Resource-Policy "same-origin" always;
   add_header Cross-Origin-Embedder-Policy "require-corp" always;
   ```
2. Use `always` to ensure headers are sent even on error responses.

### Step 4: Test the Headers

1. If a dev server can be started, suggest a curl command to verify headers:
   ```bash
   curl -I http://localhost:<port>/ 2>/dev/null | grep -iE "^(content-security|strict-transport|x-content-type|x-frame|referrer-policy|permissions-policy|cross-origin)"
   ```
2. List any headers that are still missing or misconfigured.
3. Recommend online tools for production validation:
   - https://securityheaders.com
   - https://observatory.mozilla.org

### Step 5: CSP Report-Only Rollout Plan

Provide a clear rollout plan:

```
## CSP Rollout Plan

### Phase 1: Report-Only Mode (1-2 weeks)
- Deploy with `Content-Security-Policy-Report-Only` header.
- Monitor for violations in browser console or report endpoint.
- Adjust directives based on legitimate violations.

### Phase 2: Tighten Directives
- Remove unnecessary `'unsafe-inline'` by migrating to nonces or hashes.
- Remove `'unsafe-eval'` by eliminating `eval()` usage.
- Restrict sources to specific domains instead of wildcards.

### Phase 3: Enforce
- Switch from `Content-Security-Policy-Report-Only` to `Content-Security-Policy`.
- Keep a report-uri/report-to endpoint for ongoing monitoring.
```

### Output Format

Present the implementation summary:

```
## Security Headers Implementation

**Framework**: <detected>
**Mode**: Report-Only (CSP) / Enforced (other headers)

### Headers Configured
| Header | Value | Status |
|--------|-------|--------|
| Content-Security-Policy | <value> | Report-Only |
| Strict-Transport-Security | max-age=63072000; includeSubDomains; preload | Enforced |
| ... | ... | ... |

### Files Modified
- `<file>` - <what was changed>

### CSP Sources Detected
- Scripts: <list of script sources found>
- Styles: <list of style sources found>
- Images: <list of image sources found>
- Fonts: <list of font sources found>
- APIs: <list of connect sources found>

### Next Steps
1. <Deploy and monitor CSP report-only>
2. <Adjust CSP based on violations>
3. <Switch to enforcement>

### Verification Command
curl -I http://localhost:<port>/
```
