# Set Up Development Environment

Create a comprehensive setup script that installs prerequisites, configures the environment, and verifies everything works.

## Arguments

$ARGUMENTS - No arguments required. Automatically detects the project stack.

## Instructions

1. Analyze the project to determine:
   - Programming language(s) and required versions (from `.tool-versions`, `.nvmrc`, `.python-version`, `go.mod`, `rust-toolchain.toml`, `package.json` engines field)
   - Package manager (npm, yarn, pnpm, pip, poetry, go modules, cargo)
   - Database requirements (check for docker-compose, Prisma schema, Django settings, migration files)
   - External service dependencies (Redis, Elasticsearch, message queues)
   - Environment variables needed (from `.env.example`, `.env.template`, or documented in README)

2. Create a setup script `scripts/setup.sh` (or `scripts/setup.py` for Python projects):

### Prerequisites Check
   - Check OS (macOS, Linux, WSL) and provide OS-specific instructions
   - Verify required language runtime version is installed:
     - Node.js: Check against `.nvmrc` or `engines` field, suggest `nvm` if wrong version
     - Python: Check against `.python-version`, suggest `pyenv` if wrong version
     - Go: Check against `go.mod` go directive
     - Rust: Check `rustup` and toolchain version
   - Check for required system tools (git, docker, make, curl)
   - Check for required CLI tools (database clients, cloud CLIs)
   - Print clear error messages with installation instructions for any missing prerequisites

### Dependency Installation
   - Install language-specific dependencies:
     - Node: `npm install` / `yarn install` / `pnpm install`
     - Python: `pip install -e ".[dev]"` or `poetry install`
     - Go: `go mod download`
     - Rust: `cargo build`
   - Install pre-commit hooks if configured (run `make setup-hooks` or equivalent)
   - Install any global tools needed (linters, formatters)

### Environment Configuration
   - Copy `.env.example` to `.env` if `.env` does not exist
   - Prompt for or generate required secrets (generate random values for development)
   - Validate that all required environment variables have values
   - Set up local SSL certificates if needed (using `mkcert`)

### Database Setup
   - Start database containers if `docker-compose.yml` exists (`docker compose up -d db`)
   - Wait for database to be ready (health check loop)
   - Run migrations:
     - Prisma: `npx prisma migrate dev`
     - Django: `python manage.py migrate`
     - Go: Run migration tool
     - TypeORM/Drizzle: Run migration command
   - Seed development data if a seed script exists

### Verification
   - Run the test suite to verify setup: `npm test` / `pytest` / `go test ./...`
   - Start the dev server briefly and check it responds (curl health endpoint)
   - Print a summary of what was set up and any manual steps remaining

3. Make the script executable: `chmod +x scripts/setup.sh`

4. Create a `scripts/teardown.sh` for cleanup:
   - Stop Docker containers
   - Remove database volumes (with confirmation)
   - Remove `.env` (with confirmation)

5. Update the project `README.md` (or create a "Development Setup" section if none exists):
   - Add a "Getting Started" or "Development Setup" section
   - Reference the setup script: `./scripts/setup.sh`
   - Document any manual steps not covered by the script
   - List available development commands (dev server, tests, lint, build)

6. Print a summary of:
   - Created files
   - What the setup script will do
   - How to run it
   - Any prerequisites that need manual installation
