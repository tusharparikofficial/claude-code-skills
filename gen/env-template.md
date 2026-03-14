# Environment Template Generator

Scan the codebase for all environment variable usage and generate a comprehensive `.env.example` file.

## Arguments

$ARGUMENTS - No required arguments. Optional: `[output-path]` to specify where to write the file (default: `.env.example` in project root).

## Instructions

### Step 1: Determine Output Path

- If an argument is provided, use it as the output file path.
- Otherwise, default to `.env.example` in the project root.
- If `.env.example` already exists, read it first to preserve any existing comments and grouping. The generated file will be a superset (adding new vars, keeping existing ones).

### Step 2: Detect Project Stack

Identify the languages and frameworks in use to know which patterns to search for:
- **Node.js/TypeScript**: `package.json`
- **Python**: `requirements.txt`, `pyproject.toml`, `setup.py`
- **Go**: `go.mod`
- **Java/Spring**: `pom.xml`, `build.gradle`
- **Ruby**: `Gemfile`
- **Rust**: `Cargo.toml`
- **PHP**: `composer.json`
- **Docker**: `Dockerfile`, `docker-compose.yml`

### Step 3: Scan for Environment Variable References

Search the entire codebase (excluding node_modules, .git, vendor, __pycache__, dist, build, .next, target) for environment variable access patterns:

**Node.js / TypeScript**:
```
Search patterns:
- process.env.VARIABLE_NAME
- process.env['VARIABLE_NAME']
- process.env["VARIABLE_NAME"]
- env.VARIABLE_NAME (when env = process.env or destructured)
- Deno.env.get("VARIABLE_NAME")
- import.meta.env.VARIABLE_NAME (Vite)
- NEXT_PUBLIC_* references (Next.js client-side)
```

**Python**:
```
Search patterns:
- os.environ["VARIABLE_NAME"]
- os.environ.get("VARIABLE_NAME")
- os.environ.get("VARIABLE_NAME", "default")
- os.getenv("VARIABLE_NAME")
- os.getenv("VARIABLE_NAME", "default")
- environ.get("VARIABLE_NAME") (from os import environ)
- config("VARIABLE_NAME") (python-decouple)
- env("VARIABLE_NAME") (django-environ)
- env.str("VARIABLE_NAME"), env.int("VARIABLE_NAME"), env.bool("VARIABLE_NAME")
- settings.VARIABLE_NAME where VARIABLE_NAME is uppercase (Django settings)
```

**Go**:
```
Search patterns:
- os.Getenv("VARIABLE_NAME")
- os.LookupEnv("VARIABLE_NAME")
- viper.Get("variable.name"), viper.GetString("variable.name"), etc.
- viper.BindEnv("variable_name")
- godotenv.Load() then os.Getenv
- cfg.GetEnv("VARIABLE_NAME")
```

**Java / Spring**:
```
Search patterns:
- @Value("${VARIABLE_NAME}")
- @Value("${VARIABLE_NAME:default}")
- System.getenv("VARIABLE_NAME")
- Environment.getProperty("variable.name")
- application.properties: ${VARIABLE_NAME}
- application.yml: ${VARIABLE_NAME}
```

**Ruby**:
```
Search patterns:
- ENV["VARIABLE_NAME"]
- ENV.fetch("VARIABLE_NAME")
- ENV["VARIABLE_NAME"] || "default"
```

**Docker / docker-compose**:
```
Search patterns:
- environment: section in docker-compose.yml
- ${VARIABLE_NAME} in docker-compose.yml
- ARG VARIABLE_NAME in Dockerfile
- ENV VARIABLE_NAME in Dockerfile
- .env file references
```

**Shell scripts**:
```
Search patterns:
- $VARIABLE_NAME or ${VARIABLE_NAME} in .sh files
- export VARIABLE_NAME= in .sh files
```

**Configuration files**:
```
Search patterns:
- .env, .env.local, .env.development, .env.production (if any exist, read them for variable names)
- Terraform .tf files: var.* references
- CI/CD files: .github/workflows/*.yml, .gitlab-ci.yml, Jenkinsfile
```

### Step 4: Extract Variable Details

For each discovered environment variable, collect:
- **Variable name**: The exact env var name
- **Source file(s)**: Where it's referenced (for internal tracking, not output)
- **Default value**: If a default is provided in code (e.g., `os.getenv("PORT", "3000")`)
- **Type hint**: Inferred from usage context (string, number, boolean, URL, path)
- **Required vs optional**: Required if no default is provided and used without fallback
- **Usage context**: What it's used for (database, auth, API, etc.)

### Step 5: Categorize Variables

Group variables by purpose. Use these categories (and create new ones if needed):

```
# ===========================
# Application
# ===========================
NODE_ENV, APP_ENV, ENVIRONMENT, PORT, HOST, APP_NAME, APP_URL, LOG_LEVEL, DEBUG

# ===========================
# Database
# ===========================
DATABASE_URL, DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, REDIS_URL, MONGODB_URI

# ===========================
# Authentication & Security
# ===========================
JWT_SECRET, JWT_EXPIRES_IN, SESSION_SECRET, COOKIE_SECRET, ENCRYPTION_KEY,
BCRYPT_ROUNDS, CORS_ORIGINS, ALLOWED_HOSTS

# ===========================
# OAuth / Social Login
# ===========================
GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET,
FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, AUTH0_DOMAIN, AUTH0_CLIENT_ID

# ===========================
# Email / Notifications
# ===========================
SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, SENDGRID_API_KEY,
FROM_EMAIL, MAILGUN_API_KEY, TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN

# ===========================
# Cloud Storage
# ===========================
AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, AWS_S3_BUCKET,
CLOUDINARY_URL, GCS_BUCKET, AZURE_STORAGE_CONNECTION_STRING

# ===========================
# Third-Party APIs
# ===========================
STRIPE_SECRET_KEY, STRIPE_PUBLISHABLE_KEY, STRIPE_WEBHOOK_SECRET,
OPENAI_API_KEY, ANTHROPIC_API_KEY, SENTRY_DSN, SEGMENT_WRITE_KEY

# ===========================
# Feature Flags
# ===========================
FEATURE_*, ENABLE_*, FF_*

# ===========================
# Infrastructure
# ===========================
DOCKER_*, K8S_*, DEPLOY_*, CI_*
```

### Step 6: Generate Example Values

For each variable, generate a safe example/placeholder value:

```
Variable Pattern        --> Example Value
-----------------------|----------------------------------
*_URL, *_URI            --> "postgresql://user:password@localhost:5432/dbname" or "redis://localhost:6379"
*_HOST                  --> "localhost"
*_PORT                  --> Appropriate default port (5432, 3306, 6379, 8080, etc.)
*_NAME (database)       --> "myapp_dev"
*_USER                  --> "myapp_user"
*_PASSWORD              --> "change_me_in_production"
*_SECRET, *_KEY (auth)  --> "your-secret-key-change-in-production-min-32-chars"
*_API_KEY               --> "your-api-key-here"
*_TOKEN                 --> "your-token-here"
NODE_ENV                --> "development"
DEBUG                   --> "true"
LOG_LEVEL               --> "info"
PORT                    --> The default from code, or "3000"
*_EMAIL                 --> "noreply@example.com"
*_DOMAIN                --> "localhost"
*_REGION                --> "us-east-1"
*_BUCKET                --> "my-bucket-name"
CORS_ORIGINS            --> "http://localhost:3000"
*_ENABLED, *_ACTIVE     --> "true" or "false"
SENTRY_DSN              --> "https://examplePublicKey@o0.ingest.sentry.io/0"
```

NEVER use real secrets, API keys, or tokens. Always use obvious placeholders.

### Step 7: Generate the .env.example File

Write the file with this format:

```bash
# ============================================================
# Environment Configuration
# Generated by /gen/env-template
# ============================================================
#
# Copy this file to .env and fill in the values:
#   cp .env.example .env
#
# Variables marked [REQUIRED] must be set for the app to start.
# Variables marked [OPTIONAL] have defaults or are not critical.
#

# ===========================
# Application
# ===========================

# [REQUIRED] Application environment
NODE_ENV=development

# [OPTIONAL] Server port (default: 3000)
PORT=3000

# [OPTIONAL] Log level: debug | info | warn | error
LOG_LEVEL=info

# ===========================
# Database
# ===========================

# [REQUIRED] PostgreSQL connection string
DATABASE_URL="postgresql://user:password@localhost:5432/myapp_dev"

# [OPTIONAL] Redis URL for caching
REDIS_URL="redis://localhost:6379"

# ===========================
# Authentication
# ===========================

# [REQUIRED] Secret key for JWT signing (min 32 characters)
JWT_SECRET="your-secret-key-change-in-production-min-32-chars"

# ...and so on for each category
```

### Step 8: Check for Undocumented Variables

Compare the discovered variables against:
1. Any existing `.env.example` or `.env.sample` file
2. Any existing documentation mentioning environment variables

Report variables that are:
- **Used in code but not documented**: These are the ones just added to `.env.example`
- **Documented but not used in code**: May be stale; warn the user
- **In .env but not in .env.example**: Security risk if .env is accidentally committed

### Step 9: Check .gitignore

Verify that `.env` (and variants like `.env.local`, `.env.production`) are in `.gitignore`. If not, warn the user:

```
WARNING: .env is not in .gitignore! Secrets may be committed to the repository.
Add these lines to .gitignore:
  .env
  .env.local
  .env.*.local
  .env.production
```

### Step 10: Summary

Print:
1. Total environment variables discovered
2. Breakdown by category (e.g., "Database: 4, Auth: 3, APIs: 5")
3. Required vs optional count
4. Variables that were newly discovered (not in existing .env.example)
5. Variables in code but potentially stale (no longer used)
6. Path to generated `.env.example` file
7. Any security warnings (.gitignore, hardcoded secrets found in code)
8. Reminder to copy and fill in values:
   ```
   Next steps:
   1. cp .env.example .env
   2. Fill in the [REQUIRED] values
   3. Ensure .env is in .gitignore
   ```
