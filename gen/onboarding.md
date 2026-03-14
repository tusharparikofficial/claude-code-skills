# Generate Developer Onboarding Guide

Generate a comprehensive onboarding guide for new developers joining the project.

## Instructions

1. **Analyze the entire project** by scanning:
   - Package manager files: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `Gemfile`, etc.
   - Lock files to detect exact tool versions: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, etc.
   - Runtime version files: `.node-version`, `.nvmrc`, `.python-version`, `.tool-versions`, `.ruby-version`, `rust-toolchain.toml`
   - Docker files: `Dockerfile`, `docker-compose.yml`
   - CI/CD config: `.github/workflows/`, `.gitlab-ci.yml`
   - Environment templates: `.env.example`, `.env.sample`
   - Configuration files: `tsconfig.json`, `eslint.config.*`, `prettier.*`, `.editorconfig`
   - Task runners: `Makefile`, `Taskfile.yml`, `justfile`, `scripts/` directory
   - Source code structure and architecture patterns
   - Test setup and configuration
   - Documentation: `docs/`, `README.md`, `CONTRIBUTING.md`

2. **Generate the onboarding guide** with these sections:

   ```markdown
   # Developer Onboarding Guide

   Welcome to [Project Name]. This guide will get you up and running.

   ## Prerequisites

   ### Required Tools
   | Tool | Version | Install |
   |------|---------|---------|
   | ... | ... | link or command |

   ### Accounts & Access
   - List of required accounts (GitHub, cloud providers, etc.)
   - Access permissions needed

   ## Getting Started

   ### 1. Clone & Install
   Step-by-step commands from clone to running.

   ### 2. Environment Setup
   - Copy .env.example and explain each variable
   - Local database/service setup
   - Required API keys and where to get them

   ### 3. Verify Setup
   Commands to verify everything is working correctly.

   ## Architecture Overview

   ### System Architecture
   High-level description of how the system works.
   Mermaid diagram if useful.

   ### Key Directories
   | Directory | Purpose |
   |-----------|---------|
   | `src/` | ... |
   | ... | ... |

   ### Key Files
   | File | Purpose |
   |------|---------|
   | ... | ... |

   ## Common Development Tasks

   ### Running the Application
   - Development mode
   - Production mode
   - With Docker

   ### Making Changes
   - Typical development workflow
   - Branch naming conventions
   - How to add a new feature/endpoint/page

   ### Database Operations
   - Running migrations
   - Seeding data
   - Connecting to local DB

   ## Testing

   ### Running Tests
   - Unit tests
   - Integration tests
   - E2E tests
   - Coverage reports

   ### Writing Tests
   - Where to put test files
   - Testing patterns used in this project
   - Mocking strategy

   ## Deployment

   ### Environments
   | Environment | URL | Branch |
   |-------------|-----|--------|

   ### How to Deploy
   Step-by-step deployment process.

   ### Monitoring & Logs
   How to access logs and monitoring.

   ## Debugging Tips

   - Common errors and solutions
   - How to debug locally
   - Useful debug commands
   - Log locations

   ## Team Conventions

   - Code style and linting rules
   - Commit message format
   - PR review process
   - Documentation expectations

   ## Useful Commands Cheatsheet

   | Command | Description |
   |---------|-------------|
   | `...` | ... |
   ```

3. **Quality checks:**
   - All commands are copy-pasteable and verified against the actual project
   - Tool versions match what the project actually requires
   - Directory descriptions are accurate (not guessed)
   - No placeholder text remains
   - Steps are in the correct order (dependencies before dependents)

4. **Write the file** to `docs/ONBOARDING.md`. Create the `docs/` directory if it doesn't exist. If the file exists, show the diff and confirm before overwriting.
