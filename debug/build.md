# Build Error Fixer

Detect the project's build system, run the build, and iteratively fix all compilation errors until the build succeeds.

## Arguments

No required arguments. Automatically detects the build system from project files.

## Instructions

Follow these steps to fix all build errors iteratively.

### Step 1: Detect Build System

Use Glob to check for build configuration files in the project root. Check in this order and use the **first match**:

| File | Build System | Build Command |
|------|-------------|---------------|
| `package.json` | Node.js (npm/yarn/pnpm) | Check for lockfile: `pnpm-lock.yaml` -> `pnpm build`, `yarn.lock` -> `yarn build`, else `npm run build`. Also check `package.json` scripts for custom build commands. |
| `go.mod` | Go | `go build ./...` |
| `Cargo.toml` | Rust | `cargo build` |
| `pom.xml` | Maven | `mvn compile` |
| `build.gradle` or `build.gradle.kts` | Gradle | `./gradlew build` |
| `Makefile` | Make | `make` |
| `setup.py` or `pyproject.toml` | Python | `python -m py_compile` on changed files, or `python -m compileall .` |
| `CMakeLists.txt` | CMake | `cmake --build build` |
| `tsconfig.json` (no package.json) | TypeScript | `tsc --noEmit` |

If multiple build systems are detected, prefer the one most likely to be the primary (e.g., `package.json` over `tsconfig.json`).

Report which build system was detected.

### Step 2: Run Initial Build

Run the detected build command using the Bash tool. Capture both stdout and stderr. Set a reasonable timeout (120 seconds for most, 300 seconds for Java/Rust).

If the build **succeeds** with no errors, report success and stop.

If the build **fails**, proceed to Step 3.

### Step 3: Parse Build Errors

Extract all errors from the build output. For each error, capture:

1. **File path** - the source file with the error
2. **Line number** - where the error occurs
3. **Error code** - the compiler/linter error code (e.g., TS2304, E0433, C2065)
4. **Error message** - the human-readable description

Sort errors by file to batch fixes efficiently. Prioritize errors in this order:
1. Missing imports / unresolved modules (fixing these often resolves cascading errors)
2. Missing dependencies (need `npm install`, `go get`, etc.)
3. Type errors
4. Syntax errors
5. Other errors

### Step 4: Fix Errors (Iterative Loop)

For each error (up to 10 iterations of the full build cycle):

#### 4a. Read the Problematic File
Use the Read tool to read the file containing the error. Focus on the error location with surrounding context.

#### 4b. Identify the Fix

Common fix patterns:

**Missing Imports:**
- Search the codebase with Grep for where the symbol is defined or exported
- Add the correct import statement

**Missing Dependencies:**
- Run the appropriate install command: `npm install <pkg>`, `go get <pkg>`, `pip install <pkg>`, `cargo add <pkg>`

**Type Errors:**
- Check expected vs actual types
- Add type assertions, conversions, or fix the type definition
- For TypeScript: check `tsconfig.json` for strict mode settings

**Syntax Errors:**
- Fix missing brackets, semicolons, commas
- Fix incorrect language constructs

**Circular Dependencies:**
- Identify the dependency cycle
- Extract shared types/interfaces to a separate file
- Use lazy imports or dependency injection

**Missing Type Definitions:**
- Install `@types/<pkg>` for TypeScript
- Add type declaration file

#### 4c. Apply the Fix
Use the Edit tool to apply the fix.

#### 4d. Re-run Build
After fixing all errors from the current batch, re-run the build command.

- If build succeeds: proceed to Step 5
- If build fails with new errors: return to Step 4a with the new errors
- If the same errors persist after a fix attempt: try an alternative approach
- If 10 iterations are reached without success: proceed to Step 5 with remaining errors

### Step 5: Report Results

Provide a clear summary:

```
## Build Fix Report

**Build System**: <detected system>
**Build Command**: <command used>
**Result**: SUCCESS / PARTIAL (N errors remaining)

## Fixes Applied

| # | File | Error | Fix |
|---|------|-------|-----|
| 1 | src/foo.ts | TS2304: Cannot find name 'Bar' | Added missing import from ./types |
| 2 | src/db.ts | TS2345: Type mismatch | Fixed argument type to match interface |

## Remaining Issues (if any)

| # | File | Error | Why Not Fixed |
|---|------|-------|---------------|
| 1 | src/complex.ts | TS2322 | Requires architectural change |

## Iterations: N/10
```

If there are remaining issues that could not be auto-fixed, explain what manual steps are needed and why.
