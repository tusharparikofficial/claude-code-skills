# Generate Project README

Generate a comprehensive, production-quality README.md for the current project.

## Instructions

1. **Analyze the project** by scanning these files and directories (skip any that don't exist):
   - `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json` (language/dependencies)
   - `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml` (containerization)
   - `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/` (CI/CD)
   - `.env.example`, `.env.sample`, `.env.template` (environment configuration)
   - `src/`, `lib/`, `app/`, `cmd/`, `internal/`, `pkg/` (source structure)
   - `tests/`, `test/`, `__tests__/`, `spec/` (testing)
   - `docs/`, `README.md` (existing documentation)
   - `LICENSE`, `LICENSE.md` (license)
   - `Makefile`, `Taskfile.yml`, `justfile` (task runners)
   - `k8s/`, `helm/`, `terraform/`, `pulumi/` (infrastructure)

2. **Detect the tech stack** from dependencies and file patterns. Identify:
   - Primary language and framework
   - Database(s) used
   - Key libraries and tools
   - Infrastructure and deployment targets

3. **Generate README.md** with these sections (omit sections that don't apply):

   ```markdown
   # Project Title

   One-line description of what this project does.

   ![CI Status badge if CI config found]
   ![License badge if LICENSE found]
   ![Language/Framework badges based on detected stack]

   ## Overview
   2-3 paragraph description of the project, its purpose, and key features.

   ## Tech Stack
   Table or list of technologies used with versions where detectable.

   ## Prerequisites
   - Required tools and minimum versions (Node.js, Python, Docker, etc.)
   - Required accounts or access (cloud providers, APIs, etc.)

   ## Installation
   Step-by-step installation commands.

   ## Configuration
   - List all environment variables from .env.example with descriptions
   - Required vs optional variables
   - Example values (never real secrets)

   ## Development
   - How to start the dev server
   - Hot reload info
   - Useful dev commands

   ## Testing
   - How to run tests
   - Test types available (unit, integration, e2e)
   - Coverage reporting

   ## Deployment
   - Deployment method (Docker, CI/CD, manual)
   - Environment-specific instructions
   - Required infrastructure

   ## API Overview
   If API routes are detected: brief table of key endpoints.

   ## Architecture
   - High-level architecture description
   - Key directory structure with explanations
   - Data flow summary

   ## Contributing
   - How to contribute
   - Branch naming conventions
   - PR process
   - Code style requirements

   ## License
   License type and link.
   ```

4. **Quality checks before outputting:**
   - All commands are copy-pasteable and correct
   - No placeholder text like "TODO" or "TBD" remains (use real info or omit)
   - Badge URLs are valid
   - Environment variable names match actual .env.example
   - Installation steps actually work for the detected stack

5. **Write the file** to `README.md` in the project root. If a README already exists, show the user the diff and ask for confirmation before overwriting.
