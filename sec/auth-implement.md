# Implement Authentication System

Design and implement a complete authentication system with security best practices.

## Arguments

$ARGUMENTS - Authentication type: `jwt`, `session`, `oauth`, or `passkey`. Optionally append provider for OAuth (e.g., `oauth google`, `oauth github`).

## Instructions

You are implementing an authentication system. Parse `$ARGUMENTS` to determine the auth type and any additional configuration (e.g., OAuth provider).

### Step 0: Project Discovery

1. Detect the project language and framework.
2. Identify existing auth-related code (login pages, auth middleware, user models).
3. Identify the database and ORM in use.
4. Check for existing auth libraries already installed (passport, next-auth, django-allauth, etc.).
5. Determine if this is a new auth implementation or augmenting an existing one.

### Step 1: User Model / Schema

Ensure the user model/schema includes at minimum:

```
User:
  id: UUID (primary key, auto-generated)
  email: string (unique, indexed, validated)
  password_hash: string (nullable for OAuth-only users)
  created_at: timestamp
  updated_at: timestamp
  is_active: boolean (default true)
  is_email_verified: boolean (default false)
  failed_login_attempts: integer (default 0)
  locked_until: timestamp (nullable)
  last_login_at: timestamp (nullable)
```

For OAuth, add:
```
OAuthAccount:
  id: UUID
  user_id: FK -> User
  provider: string (google, github, etc.)
  provider_account_id: string
  access_token: string (encrypted)
  refresh_token: string (encrypted, nullable)
  expires_at: timestamp (nullable)
  UNIQUE(provider, provider_account_id)
```

For sessions, add:
```
Session:
  id: UUID (or secure random token)
  user_id: FK -> User
  expires_at: timestamp
  created_at: timestamp
  ip_address: string (nullable)
  user_agent: string (nullable)
```

For JWT with token blacklist, add:
```
BlacklistedToken:
  id: UUID
  jti: string (JWT ID, indexed)
  expires_at: timestamp
  blacklisted_at: timestamp
```

Create database migrations for these schemas.

### Step 2: Password Handling

Implement secure password handling:

1. **Hashing**: Use argon2id (preferred) or bcrypt (fallback).
   - **Node.js**: `npm install argon2` or `npm install bcrypt`
   - **Python**: `pip install argon2-cffi` or use `passlib`
   - **Go**: `golang.org/x/crypto/argon2` or `golang.org/x/crypto/bcrypt`

2. **Argon2id configuration** (OWASP recommended):
   ```
   memory: 19456 KiB (19 MiB)
   iterations: 2
   parallelism: 1
   tag length: 32 bytes
   ```

3. **Password strength validation**:
   - Minimum 8 characters (recommend 12+)
   - Maximum 128 characters (prevent DoS with extremely long passwords)
   - No requirement for specific character classes (per NIST 800-63B)
   - Check against common password list (top 10,000 breached passwords)
   - Check against user's email/name
   - Provide strength feedback to user

4. Create utility functions:
   - `hashPassword(plaintext) -> hash`
   - `verifyPassword(plaintext, hash) -> boolean`
   - `validatePasswordStrength(password, userInfo) -> { valid, feedback[] }`

### Step 3: Rate Limiting & Account Lockout

1. **Rate limiting on auth endpoints**:
   - Login: 5 attempts per minute per IP, 10 per minute per account
   - Registration: 3 per minute per IP
   - Password reset: 3 per hour per account
   - Use sliding window algorithm

2. **Account lockout**:
   - Lock account after 5 consecutive failed login attempts
   - Lock duration: 15 minutes (exponential backoff optional)
   - Track `failed_login_attempts` and `locked_until` on the user model
   - Reset counter on successful login
   - Return generic error "Invalid email or password" (never reveal which is wrong)

3. **Implementation**:
   - **Node.js**: Use `rate-limiter-flexible` or `express-rate-limit`
   - **Python**: Use `django-ratelimit`, `flask-limiter`, or `slowapi` (FastAPI)
   - **Go**: Use `golang.org/x/time/rate` or `ulule/limiter`

### Step 4: JWT Implementation (if auth type is `jwt`)

1. **Token structure**:
   - **Access token**: Short-lived (15 minutes), contains user ID and roles
   - **Refresh token**: Long-lived (7 days), stored in HttpOnly cookie or secure storage
   - Each token gets a unique `jti` (JWT ID) for blacklisting

2. **Signing algorithm**: Use RS256 (RSA) or EdDSA (Ed25519), NOT HS256.
   - Generate a key pair for signing/verification.
   - Store the private key securely (env var or secret manager).
   - The public key can be shared for verification.

3. **Token payload**:
   ```json
   {
     "sub": "<user_id>",
     "iat": "<issued_at>",
     "exp": "<expiry>",
     "jti": "<unique_token_id>",
     "role": "<user_role>"
   }
   ```
   Do NOT include sensitive data (email, name, etc.) in the token payload.

4. **Token rotation**: When refreshing, issue a new refresh token and blacklist the old one (rotation). This limits the window for stolen refresh tokens.

5. **Token blacklist**: On logout, add the access token and refresh token `jti` to the blacklist. Clean up expired entries periodically.

6. **Cookie storage** (recommended for web apps):
   ```
   Set-Cookie: access_token=<token>; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=900
   Set-Cookie: refresh_token=<token>; HttpOnly; Secure; SameSite=Strict; Path=/api/auth/refresh; Max-Age=604800
   ```

### Step 5: Session Implementation (if auth type is `session`)

1. **Session store**: Use Redis (preferred for performance) or database.
   - **Node.js**: `express-session` with `connect-redis`
   - **Python/Django**: Django session framework with Redis backend
   - **Python/Flask**: `flask-session` with Redis backend

2. **Session configuration**:
   ```
   Session ID: Cryptographically random, 128+ bits of entropy
   Cookie name: __Host-session (with __Host- prefix for extra security)
   HttpOnly: true
   Secure: true
   SameSite: Lax
   Max-Age: 3600 (1 hour, extend on activity)
   Path: /
   Domain: not set (defaults to exact origin)
   ```

3. **Session fixation prevention**: Regenerate session ID after login and privilege escalation.

4. **Session expiry**:
   - Absolute timeout: 24 hours (force re-login)
   - Idle timeout: 1 hour (extend on each request)
   - Sliding window: Reset idle timer on activity

5. **Session data**: Store minimal data server-side (user ID, role, created_at). Never store sensitive data in the session.

### Step 6: OAuth Implementation (if auth type is `oauth`)

1. **Determine provider** from arguments (default to Google if not specified).

2. **PKCE flow** (for public clients like SPAs and mobile apps):
   - Generate `code_verifier` (43-128 chars, URL-safe random string)
   - Compute `code_challenge` = Base64URL(SHA256(code_verifier))
   - Send `code_challenge` and `code_challenge_method=S256` in auth request
   - Send `code_verifier` in token exchange

3. **State parameter**: Generate a random state parameter, store it in a short-lived cookie or session, and validate it on callback to prevent CSRF.

4. **Implementation**:
   - **Node.js/Express**: Use `passport` with provider-specific strategy, or implement manually with `openid-client`
   - **Next.js**: Use `next-auth` (Auth.js)
   - **Django**: Use `django-allauth` or `social-auth-app-django`
   - **Flask**: Use `authlib`
   - **FastAPI**: Use `authlib` or `httpx-oauth`

5. **Flow**:
   ```
   GET /api/auth/oauth/authorize?provider=google
     -> Generate state + PKCE, store in cookie
     -> Redirect to provider authorization URL

   GET /api/auth/oauth/callback?code=xxx&state=yyy
     -> Validate state matches cookie
     -> Exchange code for tokens (with code_verifier)
     -> Fetch user profile from provider
     -> Create or link user account
     -> Create session or issue JWT
     -> Redirect to app
   ```

6. **Account linking**: If a user with the same email already exists, link the OAuth account to the existing user (only if email is verified by the provider).

### Step 7: Passkey Implementation (if auth type is `passkey`)

1. **WebAuthn/FIDO2**: Implement using the Web Authentication API.
   - **Node.js**: Use `@simplewebauthn/server` and `@simplewebauthn/browser`
   - **Python**: Use `py_webauthn`

2. **Registration flow**:
   ```
   POST /api/auth/passkey/register/options
     -> Generate challenge, return PublicKeyCredentialCreationOptions
   POST /api/auth/passkey/register/verify
     -> Verify attestation response, store credential
   ```

3. **Authentication flow**:
   ```
   POST /api/auth/passkey/login/options
     -> Generate challenge, return PublicKeyCredentialRequestOptions
   POST /api/auth/passkey/login/verify
     -> Verify assertion response, authenticate user
   ```

4. **Store credentials**: Save credential ID, public key, sign counter, and transports for each registered passkey.

### Step 8: Implement Endpoints

Create the following endpoints (adapt paths to project conventions):

**Core Auth Endpoints**:
```
POST /api/auth/register        - Create new account
POST /api/auth/login           - Authenticate user
POST /api/auth/logout          - End session / blacklist tokens
POST /api/auth/refresh         - Refresh access token (JWT only)
GET  /api/auth/me              - Get current user profile
```

**Password Management**:
```
POST /api/auth/forgot-password - Request password reset email
POST /api/auth/reset-password  - Reset password with token
POST /api/auth/change-password - Change password (authenticated)
```

**OAuth** (if applicable):
```
GET  /api/auth/oauth/authorize - Start OAuth flow
GET  /api/auth/oauth/callback  - Handle OAuth callback
```

**Passkey** (if applicable):
```
POST /api/auth/passkey/register/options - Get registration options
POST /api/auth/passkey/register/verify  - Verify registration
POST /api/auth/passkey/login/options    - Get login options
POST /api/auth/passkey/login/verify     - Verify login
```

Each endpoint must:
- Validate all input with a schema (Zod, Joi, Pydantic, etc.)
- Return consistent response format
- Handle errors without leaking sensitive info
- Be rate limited appropriately

### Step 9: Auth Middleware / Guard

Create middleware that:

1. Extracts the token/session from the request (cookie or Authorization header).
2. Validates the token/session (signature, expiry, blacklist check).
3. Loads the user from the database (or cache).
4. Attaches the user to the request context.
5. Returns 401 if unauthenticated, 403 if unauthorized.

Create a role-based guard:
```
// Example usage
router.get('/admin/users', authenticate, authorize('admin'), handler)
router.get('/profile', authenticate, handler)
```

### Step 10: Security Tests

Write tests covering:

1. **Registration**: Valid registration, duplicate email, weak password, missing fields, rate limiting.
2. **Login**: Valid login, wrong password, wrong email, locked account, rate limiting.
3. **Token/Session**: Valid token accepted, expired token rejected, blacklisted token rejected, invalid signature rejected.
4. **Authorization**: Protected routes return 401 without auth, 403 without proper role, 200 with proper auth.
5. **Password reset**: Valid flow, expired token, used token, invalid token.
6. **Account lockout**: Account locks after N failures, unlocks after timeout.

### Output Format

```
## Authentication Implementation Report

### Configuration
- **Auth Type**: <jwt/session/oauth/passkey>
- **Framework**: <detected>
- **Password Hashing**: <argon2id/bcrypt>
- **Token Signing**: <RS256/EdDSA> (JWT only)

### Files Created/Modified
| File | Purpose |
|------|---------|
| <file> | <description> |

### Endpoints Implemented
| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| POST | /api/auth/register | User registration | No |
| ... | ... | ... | ... |

### Security Measures
- [x] Password hashing with <algorithm>
- [x] Rate limiting on auth endpoints
- [x] Account lockout after failed attempts
- [x] Secure cookie configuration
- [x] Input validation on all endpoints
- [x] CSRF protection
- [x] Token rotation (JWT) / Session fixation prevention (sessions)

### Environment Variables Required
| Variable | Description | Example |
|----------|-------------|---------|
| JWT_PRIVATE_KEY | RSA/EdDSA private key | (generate with openssl) |
| ... | ... | ... |

### Tests
- Total tests: X
- All passing: Yes/No

### Next Steps
1. <Set up environment variables>
2. <Run database migrations>
3. <Configure OAuth provider credentials (if OAuth)>
```
