# Set Up Pre-Commit Hooks

Detect the project's tech stack and configure comprehensive pre-commit hooks for linting, formatting, type-checking, testing, and secret scanning.

## Arguments

$ARGUMENTS - No arguments required. Automatically detects the project stack.

## Instructions

1. Detect the project's tech stack by examining:
   - `package.json` (Node.js/TypeScript)
   - `pyproject.toml`, `setup.py`, `requirements.txt` (Python)
   - `go.mod` (Go)
   - `Cargo.toml` (Rust)
   - `pom.xml`, `build.gradle` (Java)
   - If multiple are present, configure hooks for all detected stacks.

2. Based on the detected stack, set up the appropriate hook system:

### Node.js / TypeScript

Install and configure **husky** + **lint-staged**:

- Run `npx husky init` (or `npx husky install` for older versions)
- Create `.husky/pre-commit` hook that runs `npx lint-staged`
- Create `.lintstagedrc.json` or add `lint-staged` config to `package.json`:
  - `*.{ts,tsx,js,jsx}`: Run ESLint with `--fix`, then Prettier with `--write`
  - `*.{json,md,yml,yaml,css,scss}`: Run Prettier with `--write`
  - `*.{ts,tsx}`: Run `tsc --noEmit` (type-check, no output)
  - `*.test.{ts,tsx,js,jsx}`: Run `vitest related --run` or `jest --findRelatedTests` (affected tests only)
- Create `.husky/commit-msg` hook for commit message validation:
  - Install `@commitlint/cli` and `@commitlint/config-conventional`
  - Create `commitlint.config.js` with conventional commits rules

### Python

Install and configure **pre-commit** framework:

- Create `.pre-commit-config.yaml` with hooks:
  - `ruff` - Linting and auto-fix (`ruff check --fix`)
  - `ruff-format` - Code formatting (`ruff format`)
  - `mypy` - Type checking
  - `pytest` - Run affected tests (if `pytest-testmon` is available)
  - `detect-secrets` - Secret scanning
  - `check-yaml` - YAML validation
  - `check-toml` - TOML validation
  - `trailing-whitespace` - Whitespace cleanup
  - `end-of-file-fixer` - EOF newline
  - `check-added-large-files` - Prevent large files (max 500KB)
- Add commit message hook:
  - `commitizen` for conventional commit validation
- Run `pre-commit install` to activate hooks
- Run `pre-commit install --hook-type commit-msg` for commit message validation

### Go

Create custom git hooks in `.githooks/` or use **pre-commit** framework:

- `.githooks/pre-commit` (shell script):
  - `gofmt -l` - Check formatting (fail if unformatted files found)
  - `go vet ./...` - Static analysis
  - `golangci-lint run` - Comprehensive linting
  - `go test ./...` - Run tests (or `go test -short ./...` for speed)
  - Secret scanning with `gitleaks` or `trufflehog`
- `.githooks/commit-msg`:
  - Validate conventional commit format using regex
- Configure git to use custom hooks directory: `git config core.hooksPath .githooks`
- Add `Makefile` target: `make hooks` to set up hooks path

### Rust

Create custom git hooks:

- `.githooks/pre-commit`:
  - `cargo fmt -- --check` - Check formatting
  - `cargo clippy -- -D warnings` - Lint with warnings as errors
  - `cargo test` - Run tests
- `.githooks/commit-msg`:
  - Conventional commit validation

3. Add **secret scanning** for all stacks:
   - If not already included, add `gitleaks` or `detect-secrets`:
     - Create `.gitleaks.toml` configuration (or `.secrets.baseline` for detect-secrets)
     - Allowlist known false positives
     - Scan staged files only for performance

4. Create or update `.gitignore` to exclude hook-related artifacts if needed.

5. Add a `Makefile` target or npm script for easy hook setup:
   - `make setup-hooks` or `npm run prepare`
   - Should be idempotent (safe to run multiple times)

6. Print a summary of:
   - What hooks were configured
   - What each hook checks
   - How to skip hooks in emergencies (`git commit --no-verify` -- note this should be rare)
   - How to run hooks manually
