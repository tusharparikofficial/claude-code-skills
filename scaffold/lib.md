# Scaffold Library/Package

Scaffold a publishable library or package with build configuration, testing, CI/CD, and documentation.

## Arguments

$ARGUMENTS - `<name> <language>` where language is one of: ts, python, go, rust

## Instructions

1. Parse the arguments to extract the library name and language.

2. Create the project directory with the given name in the current working directory.

3. Based on the language, scaffold the following:

### TypeScript (ts)
- Initialize `package.json` with:
  - Name (scoped if appropriate, e.g., `@scope/name`)
  - Version `0.1.0`
  - `"type": "module"`
  - `main`, `module`, `types` entry points
  - `exports` map with `.` entry for ESM and CJS
  - `files` array for published files
  - `sideEffects: false`
  - Scripts: `build`, `dev`, `test`, `lint`, `format`, `prepublishOnly`, `size`
  - `peerDependencies` if applicable
- Build with `tsup` or `rollup`:
  - `tsup.config.ts` with ESM + CJS output, declaration files, clean output
  - Or `rollup.config.js` with TypeScript plugin, declaration plugin
- `tsconfig.json` with strict mode, declaration, declarationMap, sourceMap
- Source files:
  - `src/index.ts` - Main export barrel file
  - `src/core/` - Core library functionality with sample module
  - `src/types.ts` - Public type definitions
  - `src/utils/` - Internal utilities
- Test setup with Vitest:
  - `vitest.config.ts`
  - `tests/` directory with sample tests
  - Coverage configuration (istanbul or v8)
- Documentation:
  - `README.md` with installation, usage, API reference template
  - `CHANGELOG.md` with initial entry
  - `LICENSE` (MIT default)
  - TypeDoc or API Extractor config for API docs generation
- CI/CD:
  - `.github/workflows/ci.yml` - Lint, test, build on PR
  - `.github/workflows/publish.yml` - Publish to npm on release tag
  - `.npmrc` with `//registry.npmjs.org/:_authToken=${NPM_TOKEN}`
- Config files: `.gitignore`, `.eslintrc.json`, `.prettierrc`, `.npmignore`

### Python
- Project structure:
  - `src/<name>/` package directory
  - `src/<name>/__init__.py` with `__version__`
  - `src/<name>/core.py` - Core library functionality
  - `src/<name>/types.py` - Type definitions (TypedDict, Protocol, dataclasses)
  - `src/<name>/utils.py` - Internal utilities
  - `src/<name>/exceptions.py` - Custom exceptions
  - `src/<name>/py.typed` - PEP 561 marker file
- `pyproject.toml` with:
  - `[build-system]` using setuptools or hatchling
  - `[project]` metadata (name, version, description, authors, license, classifiers)
  - `[project.optional-dependencies]` for dev dependencies
  - `[tool.pytest.ini_options]`
  - `[tool.mypy]` strict configuration
  - `[tool.ruff]` linting configuration
- Test setup:
  - `tests/conftest.py` with fixtures
  - `tests/test_core.py` with sample tests
  - `tests/test_types.py`
  - pytest with coverage configuration
- Documentation:
  - `README.md` with installation, usage, API reference
  - `CHANGELOG.md`
  - `LICENSE`
  - `docs/` directory with Sphinx or MkDocs configuration
- CI/CD:
  - `.github/workflows/ci.yml` - Lint (ruff), type check (mypy), test (pytest)
  - `.github/workflows/publish.yml` - Build and publish to PyPI on release
- Config files: `.gitignore`, `MANIFEST.in`

### Go
- Initialize Go module with `go mod init`
- Source files:
  - Root package files: `<name>.go` with core functionality
  - `types.go` - Type definitions
  - `errors.go` - Custom error types with sentinel errors
  - `options.go` - Functional options pattern for configuration
  - `doc.go` - Package-level documentation
  - `internal/` - Internal implementation details
  - `examples/` - Runnable example programs
- Test files:
  - `<name>_test.go` with table-driven tests
  - `examples_test.go` with testable examples (for godoc)
  - `benchmark_test.go` with benchmarks
- Documentation:
  - `README.md` with installation (`go get`), usage, API examples
  - `CHANGELOG.md`
  - `LICENSE`
  - Godoc-compatible comments on all exported types and functions
- CI/CD:
  - `.github/workflows/ci.yml` - go vet, golangci-lint, go test
  - `.github/workflows/release.yml` - Tag-based release
- `Makefile` with test, lint, bench, cover targets
- `.gitignore`, `.golangci.yml`

### Rust
- Initialize with `cargo init --lib`
- `Cargo.toml` with:
  - Package metadata (name, version, authors, description, license, repository)
  - `[lib]` section
  - Dependencies and dev-dependencies
  - Feature flags if applicable
  - `categories` and `keywords` for crates.io discoverability
- Source files:
  - `src/lib.rs` - Library root with public API and module declarations
  - `src/core.rs` - Core functionality
  - `src/types.rs` - Public type definitions
  - `src/error.rs` - Error types using `thiserror`
  - `src/utils.rs` - Internal utilities
- Test files:
  - Inline `#[cfg(test)]` modules in source files
  - `tests/integration_test.rs` - Integration tests
  - `benches/benchmark.rs` - Benchmarks using criterion
- Documentation:
  - `README.md` with installation, usage, examples
  - `CHANGELOG.md`
  - `LICENSE`
  - Doc comments (`///` and `//!`) on all public items
  - `examples/` directory with runnable examples
- CI/CD:
  - `.github/workflows/ci.yml` - cargo fmt, cargo clippy, cargo test
  - `.github/workflows/publish.yml` - Publish to crates.io on release
- `.gitignore`

4. After scaffolding, print a summary of created files, the publish target (npm/PyPI/pkg.go.dev/crates.io), and next steps.
