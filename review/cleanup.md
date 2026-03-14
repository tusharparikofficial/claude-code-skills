# Code Cleanup

Clean up code quality issues in bulk: remove dead code, debugging artifacts, and unnecessary clutter.

## Arguments

$ARGUMENTS - Optional `<file-or-directory>`. If omitted, operates on staged git changes (`git diff --cached --name-only`).

## Instructions

### 1. Parse Arguments and Discover Files

- If `$ARGUMENTS` is provided, use it as the target path.
- If `$ARGUMENTS` is empty or not provided:
  - Run `git diff --cached --name-only` to get staged files.
  - If no staged files, run `git diff --name-only` to get unstaged modified files.
  - If still no files, inform the user: "No staged or modified files found. Please provide a file or directory path."
- For directories, find all source files recursively (`.js`, `.jsx`, `.ts`, `.tsx`, `.py`, `.go`, `.java`, `.rb`, `.rs`, `.cpp`, `.c`, `.h`, `.hpp`).
- Read each file's content.

### 2. Scan for Cleanup Issues

For each file, scan for the following categories. Record: file, line number, category, the offending code, and suggested fix.

#### a. Debugging Statements
Remove these:
- `console.log(...)`, `console.debug(...)`, `console.warn(...)` (but NOT `console.error`)
- `console.dir(...)`, `console.table(...)`, `console.trace(...)`
- `console.time(...)`, `console.timeEnd(...)`
- `print(...)` used for debugging in Python (but NOT `print()` in scripts meant to output)
- `fmt.Println` / `fmt.Printf` used for debugging in Go (but NOT in CLI tools)
- `System.out.println` in Java (but NOT in main methods)
- `debugger` statements (JavaScript)
- `binding.pry` (Ruby), `import pdb; pdb.set_trace()` (Python)

**Preserve intentional logging:**
- `logger.*`, `log.*`, `logging.*` — these are intentional
- `console.error(...)` — typically intentional error reporting
- Lines with comments like `// keep`, `// intentional`, `# noqa` — preserve these

#### b. Commented-Out Code
Remove blocks of commented-out code (3+ consecutive commented lines that look like code, not documentation):
- Lines starting with `//` that contain code syntax (assignments, function calls, imports)
- Lines starting with `#` in Python that contain code syntax
- Block comments `/* ... */` that contain code
- Do NOT remove:
  - JSDoc / docstring comments
  - TODO / FIXME / NOTE / HACK comments
  - License headers
  - Explanation comments (English sentences)
  - Type annotations in comments (e.g., `// @ts-ignore`, `# type: ignore`)

#### c. Unused Imports
- Detect imports that are not referenced anywhere in the file body.
- For TypeScript: check both value and type usage (keep `import type` if the type is used).
- For Python: check if the imported name appears anywhere below the import.
- Do NOT remove:
  - Side-effect imports (`import './styles.css'`, `import 'reflect-metadata'`)
  - Re-exports (`export { x } from './y'`)
  - Imports used in type annotations / decorators

#### d. Unused Variables
- Find variables declared but never read.
- In destructuring, replace unused variables with `_` prefix or remove them.
- Do NOT flag:
  - Variables prefixed with `_` (conventional unused marker)
  - Variables used in type assertions
  - REST parameters that absorb extra values

#### e. Trailing Whitespace
- Remove trailing spaces and tabs from all lines.
- Normalize line endings if mixed (prefer LF).
- Remove excessive blank lines (more than 2 consecutive blank lines → reduce to 1).

#### f. Empty Code Blocks
- Flag and handle empty blocks:
  - `catch (e) {}` → add `// TODO: handle error` or minimal error logging
  - `if (condition) {}` → remove the entire if statement
  - `else {}` → remove the else clause
  - Empty function bodies → add a TODO comment or remove if unused
- Do NOT flag:
  - Intentionally empty callbacks: `() => {}`
  - Abstract method stubs
  - Interface method declarations

#### g. Unnecessary Type Assertions (TypeScript)
- `as any` — flag as HIGH priority, suggest proper typing
- `as unknown as T` — flag as MEDIUM, suggest proper generic or type guard
- Redundant type annotations where TypeScript can infer:
  - `const x: string = 'hello'` → `const x = 'hello'`
  - `const arr: number[] = [1, 2, 3]` → `const arr = [1, 2, 3]`
  - Return type annotations on single-expression functions where return type is obvious

#### h. Dead Functions
- Find functions that are:
  - Not exported AND not called anywhere in the file
  - Not referenced in any other file (search with Grep)
- Do NOT flag:
  - Functions used as callbacks or event handlers (may be referenced dynamically)
  - Functions in test files
  - Functions with decorator annotations

### 3. Apply Fixes

- Apply all fixes using the Edit tool.
- Process fixes in reverse line order within each file to avoid line-number drift.
- After fixing each file, re-read it to verify it still parses correctly.

### 4. Summary Report

Present a report in this format:

```
## Cleanup Report

### Files Modified: <N> / <total scanned>

| Category                | Found | Fixed | Skipped |
|-------------------------|-------|-------|---------|
| Debugging statements    |       |       |         |
| Commented-out code      |       |       |         |
| Unused imports          |       |       |         |
| Unused variables        |       |       |         |
| Trailing whitespace     |       |       |         |
| Empty code blocks       |       |       |         |
| Unnecessary type casts  |       |       |         |
| Dead functions          |       |       |         |
| **Total**               |       |       |         |

### Skipped Items (require manual review):
- <file>:<line> — <reason>

### Files Modified:
- <file-path> (<N> issues fixed)
- ...
```

### 5. Post-Cleanup Verification

- If the project has a linter (eslint, pylint, flake8, golint), run it to check for new issues.
- If the project has tests, run them to verify no regressions.
- Report test/lint results.

### 6. Important Rules

- NEVER remove code that has side effects (API calls, state mutations, event listeners) even if it looks unused.
- NEVER remove imports in files that use `eval()`, `require.resolve()`, or dynamic imports — they may be used dynamically.
- NEVER remove variables that are part of a public API (exported).
- When in doubt about whether something is intentional, SKIP it and list it in the "Skipped Items" section.
- Preserve all file formatting conventions (tabs vs spaces, indent width) — only remove trailing whitespace.
- If a file has zero issues, do not modify it and do not list it in the report.
