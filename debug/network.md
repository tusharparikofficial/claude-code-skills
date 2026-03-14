# Network Debugger

Diagnose network and HTTP connectivity issues with systematic checks from DNS through application layer.

## Arguments

$ARGUMENTS - A URL to test (e.g., `https://api.example.com/health`) OR a description of the issue (e.g., "API returning 403", "CORS error on /api/users")

## Instructions

Follow these diagnostic steps in order. Each step narrows down the problem layer.

### Step 1: Parse the Input

Determine what was provided in `$ARGUMENTS`:

- **If a URL**: Extract the protocol, hostname, port, and path. Use this URL directly for diagnostics.
- **If a description**: Search the codebase for relevant URLs, API endpoints, and configuration using Grep. Look in:
  - Environment files (`.env`, `.env.*`)
  - Config files (`config.*`, `settings.*`)
  - API client code (search for `fetch`, `axios`, `http.get`, `requests.get`, `http.Client`)
  - Docker compose files (for service URLs)

  Identify the target URL from the codebase context.

If no URL can be determined, ask for clarification. Do not proceed without a target.

### Step 2: DNS Resolution Check

Run the following using Bash:

```bash
host <hostname>
```

Or if `host` is not available:

```bash
dig +short <hostname>
```

Or as fallback:

```bash
getent hosts <hostname>
```

**Diagnose DNS issues:**
- `NXDOMAIN` / not found: hostname does not exist. Check for typos, verify domain registration.
- Resolves to `127.0.0.1` or `0.0.0.0`: local resolution, check `/etc/hosts` or local DNS.
- Resolves to private IP: internal service, verify network access.
- Multiple IPs: load balanced, note all IPs.

If DNS fails, report the DNS issue and suggest fixes (check hostname spelling, DNS server config, `/etc/hosts` entries). Stop further diagnostics unless the user wants to continue.

### Step 3: TCP Connectivity Check

Test raw TCP connectivity to the resolved host and port:

```bash
timeout 5 bash -c "echo > /dev/tcp/<hostname>/<port>" 2>&1 && echo "TCP OK" || echo "TCP FAILED"
```

Or use `nc` if available:

```bash
nc -zv -w 5 <hostname> <port> 2>&1
```

Default ports: HTTP=80, HTTPS=443. Use the explicit port from the URL if specified.

**Diagnose TCP issues:**
- Connection refused: service is not listening on that port. Check if the service is running, correct port is configured.
- Connection timed out: firewall blocking, wrong IP, or host is down.
- Network unreachable: routing issue, VPN not connected.

If TCP fails, report the connectivity issue. Check if the service is supposed to be local (Docker, localhost) and verify it is running.

### Step 4: TLS/SSL Certificate Validation

If the URL uses HTTPS, check the certificate:

```bash
echo | openssl s_client -connect <hostname>:<port> -servername <hostname> 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>&1
```

Also check for certificate chain issues:

```bash
curl -vI --max-time 10 https://<hostname>:<port>/ 2>&1 | grep -E "(SSL|certificate|expire|issuer|subject)"
```

**Diagnose TLS issues:**
- Certificate expired: check `notAfter` date, needs renewal
- Self-signed certificate: not trusted by default, needs CA trust or `--insecure` flag (dev only)
- Hostname mismatch: certificate CN/SAN does not match the requested hostname
- Chain incomplete: intermediate certificates missing from server config
- Protocol version mismatch: server may require TLS 1.2+ or client may not support it

### Step 5: HTTP Request with Verbose Output

Make the actual HTTP request with verbose output:

```bash
curl -v --max-time 15 -o /dev/null -w "\nHTTP_CODE: %{http_code}\nTIME_TOTAL: %{time_total}s\nTIME_CONNECT: %{time_connect}s\nTIME_STARTTRANSFER: %{time_starttransfer}s\nSIZE_DOWNLOAD: %{size_download}\n" "<full-url>" 2>&1
```

If the endpoint requires authentication, search the codebase for auth headers, tokens, or API keys and include them:

```bash
curl -v --max-time 15 -H "Authorization: Bearer <token>" "<full-url>" 2>&1
```

Capture and analyze the full response including headers and body.

### Step 6: Diagnose by HTTP Status Code

Based on the response status code:

| Code | Issue | Investigation |
|------|-------|---------------|
| **301/302** | Redirect | Check Location header, may need to follow redirects or update URL |
| **400** | Bad Request | Check request body format, content-type header, query parameters |
| **401** | Unauthorized | Check auth token, API key, credentials. Search codebase for auth config. |
| **403** | Forbidden | Check permissions, CORS preflight, IP allowlist, WAF rules |
| **404** | Not Found | Check URL path, API version, route registration in server code |
| **405** | Method Not Allowed | Check HTTP method (GET vs POST etc.), check server route definitions |
| **413** | Payload Too Large | Check request body size, server upload limits (nginx client_max_body_size) |
| **429** | Rate Limited | Check rate limit headers (X-RateLimit-*), implement backoff |
| **500** | Internal Server Error | Check server logs, the issue is server-side |
| **502** | Bad Gateway | Proxy/load balancer cannot reach upstream. Check upstream service. |
| **503** | Service Unavailable | Service overloaded or in maintenance. Check health endpoints. |
| **504** | Gateway Timeout | Upstream too slow. Check backend performance. |

### Step 7: CORS-Specific Diagnosis

If the issue involves CORS (Cross-Origin Resource Sharing), run a preflight check:

```bash
curl -v -X OPTIONS -H "Origin: <frontend-origin>" -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: Content-Type,Authorization" "<api-url>" 2>&1
```

Check the response for required CORS headers:
- `Access-Control-Allow-Origin` - must match the frontend origin or be `*`
- `Access-Control-Allow-Methods` - must include the requested method
- `Access-Control-Allow-Headers` - must include requested headers
- `Access-Control-Allow-Credentials` - must be `true` if sending cookies

If CORS headers are missing, search the codebase for CORS configuration:
- Express: search for `cors` middleware
- Django: search for `CORS_ALLOWED_ORIGINS` or `django-cors-headers`
- Go: search for `Access-Control-Allow-Origin`
- Nginx: search for `add_header` in nginx config

Provide the specific configuration fix needed.

### Step 8: Check Application Code

Search the project codebase for code making the failing request:

Use Grep to find:
- The URL being called
- Error handling around the request
- Retry logic or timeout configuration
- Request headers and body construction

Identify if the issue is in the client code (wrong URL, missing headers, incorrect payload) vs server/infrastructure.

### Step 9: Report and Fix

Provide a diagnosis report:

```
## Network Diagnosis

**Target**: <URL>
**Issue Layer**: DNS / TCP / TLS / HTTP / Application

### Diagnostic Results

| Check | Result | Status |
|-------|--------|--------|
| DNS Resolution | <IP addresses> | OK/FAIL |
| TCP Connectivity | <port status> | OK/FAIL |
| TLS Certificate | <cert details> | OK/FAIL/N/A |
| HTTP Response | <status code> | OK/FAIL |
| CORS Headers | <present/missing> | OK/FAIL/N/A |

### Root Cause

<1-2 sentence explanation of what is wrong and why>

### Fix

<specific fix with commands or code changes>
```

If the fix involves code changes in the project, apply them using the Edit tool. If the fix requires infrastructure changes (DNS, firewall, server config), provide the exact commands or configuration needed.
