# Scaffold CLI Tool

Scaffold a complete CLI application with best-practice project structure, argument parsing, configuration, and testing.

## Arguments

$ARGUMENTS - `<name> <language>` where language is one of: node, go, rust, python

## Instructions

1. Parse the arguments to extract the CLI tool name and language.

2. Create the project directory with the given name in the current working directory.

3. Based on the language, scaffold the following:

### Node (TypeScript)
- Initialize with `package.json` (name, version, description, bin entry, scripts)
- Install Commander.js or Yargs for argument parsing
- Set up TypeScript with `tsconfig.json` (strict mode, ES2022 target, outDir)
- Create `src/index.ts` as the entry point with:
  - Version flag (`--version`, `-V`)
  - Help text (auto-generated from Commander/Yargs)
  - Colorized output using `chalk` or `picocolors`
  - Graceful error handling with colored error messages and proper exit codes
- Create `src/config.ts` for configuration file loading:
  - Look for `.<name>.json`, `.<name>.yaml`, or `.<name>rc` in home dir and cwd
  - Use `cosmiconfig` or manual loading
  - Merge config file values with CLI flags (flags take precedence)
- Create `src/logger.ts` for structured, colorized logging
- Create `src/commands/` directory with a sample command
- Set up testing with Vitest:
  - `vitest.config.ts`
  - `tests/` directory with sample test for the CLI entry point
  - `tests/commands/` with sample command test
- Add `.gitignore`, `.eslintrc.json`, `.prettierrc`
- Add a `README.md` with usage instructions

### Go
- Initialize Go module with `go mod init`
- Use Cobra for CLI framework:
  - `cmd/root.go` with root command, version flag, persistent flags
  - `cmd/version.go` for version subcommand
  - `cmd/<sample>.go` with a sample subcommand
- `main.go` as entry point calling `cmd.Execute()`
- `internal/config/config.go` using Viper for config file support:
  - YAML/JSON/TOML config file
  - Environment variable binding
  - Default values
- `internal/logger/logger.go` with colored output (using `fatih/color` or `charmbracelet/lipgloss`)
- Error handling with wrapped errors and meaningful exit codes
- `Makefile` with build, test, lint, install targets
- Test files: `cmd/root_test.go`, `internal/config/config_test.go`
- `.gitignore`, `README.md`

### Rust
- Initialize with `cargo init`
- Use Clap (derive API) for argument parsing:
  - `src/main.rs` with Clap App struct
  - Version from `Cargo.toml` via `env!("CARGO_PKG_VERSION")`
  - Subcommands via Clap derive enums
- `src/cli.rs` for CLI argument definitions
- `src/config.rs` for config file loading (using `serde` + `toml` or `figment`)
- `src/error.rs` with custom error types using `thiserror`
- `src/commands/mod.rs` with sample command module
- Colorized output using `colored` or `owo-colors`
- `Cargo.toml` with dependencies and metadata
- Tests in `tests/` directory and inline `#[cfg(test)]` modules
- `.gitignore`, `README.md`

### Python
- Use Click or Typer for CLI framework:
  - `src/<name>/__init__.py` with version
  - `src/<name>/cli.py` as entry point with Click/Typer group
  - `src/<name>/commands/` directory with sample command
- `src/<name>/config.py` for config file handling:
  - YAML/TOML config file support
  - XDG-compliant config paths
  - Environment variable overrides
- `src/<name>/logger.py` with `rich` for colorized output
- Error handling with custom exceptions and user-friendly messages
- `pyproject.toml` with project metadata, scripts entry point, dependencies
- `tests/` directory with `conftest.py` and sample tests using pytest
- `.gitignore`, `README.md`

4. After scaffolding, print a summary of created files and next steps (install deps, run tests, build).

5. Verify the project structure is correct by listing all created files.
