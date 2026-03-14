# Dead Code Detection

Find and report dead, unused, or unreachable code including exported functions, variables, types, files, dependencies, CSS classes, and API endpoints.

## Arguments

$ARGUMENTS - File path or directory to scan (defaults to project root if not provided or empty)

## Instructions

### Step 1: Determine Scope and Project Structure

If `$ARGUMENTS` is provided and not empty, use that path. Otherwise, use the current working directory.

Map the project structure:
1. `find <target> -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.rs" -o -name "*.cs" -o -name "*.css" -o -name "*.scss" -o -name "*.less" \) -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/__pycache__/*" -not -path "*/venv/*" -not -path "*/.venv/*" -not -path "*/vendor/*" -not -path "*/.git/*" | head -300`
2. Identify entry points: `main.ts`, `index.ts`, `app.ts`, `server.ts`, `main.py`, `app.py`, `main.go`, `Main.java`, etc.
3. Check for config files that reference source files: `webpack.config.*`, `vite.config.*`, `next.config.*`, `tsconfig.json`, `jest.config.*`

### Step 2: Detect Unused Exports

For each source file, find all exports and check if they are imported anywhere else.

**TypeScript/JavaScript:**

Use Grep to find all exports:
- `export function (\w+)` — named function exports
- `export const (\w+)` — named const exports
- `export class (\w+)` — named class exports
- `export interface (\w+)` — interface exports
- `export type (\w+)` — type exports
- `export enum (\w+)` — enum exports
- `export default` — default exports
- `export \{ (.+) \}` — re-exports

For each exported name, search the entire codebase for imports:
- `import.*\b<name>\b.*from` — named imports
- `import <name> from` — default imports
- `require\(.*\).*\b<name>\b` — CommonJS destructured imports
- `import\(.*\)` — dynamic imports

If an export is not imported anywhere outside its own file, flag it as potentially unused.

**Exceptions (do NOT flag):**
- Entry point files (main, index, app, server)
- Files referenced in build configs
- Route handlers referenced by a framework (Next.js pages/api, Express routes)
- Test files exporting test utilities
- Package entry points (listed in package.json `main`, `exports`, `types`)
- CLI script files (referenced in `bin` in package.json)

**Python:**

Find public functions and classes (not starting with `_`):
- `def (\w+)` where name does not start with `_`
- `class (\w+)` where name does not start with `_`

Search for imports of each:
- `from .* import.*\b<name>\b`
- `import.*\b<name>\b`

**Go:**

Find exported identifiers (capitalized names):
- `func ([A-Z]\w+)` — exported functions
- `type ([A-Z]\w+)` — exported types
- `var ([A-Z]\w+)` — exported variables

Search for usage across the module.

### Step 3: Detect Unused Variables and Parameters

**Within Files:**

Use Grep and Read to find variables that are declared but never referenced after declaration:
- TypeScript/JavaScript: `const \w+`, `let \w+`, `var \w+` — check if the name appears elsewhere in the file
- Function parameters that are never used in the function body
- Destructured variables that are not used: `const { unused, ...rest } = obj`

Focus on the most confident cases:
- Variables assigned but never read
- Function parameters that are clearly unused (not just callback signature placeholders like `_`)
- Imported names that are never referenced

**Go-specific:**
Go enforces this at compile time, so check for:
- Blank identifier usage that hides real issues: `_ = someFunc()` where the error should be checked
- Imported packages used only for side effects without a comment explaining why

### Step 4: Detect Unused Types and Interfaces

For TypeScript:
- Find all `interface` and `type` declarations
- Search for references to each type name throughout the codebase
- Check for types used only in other unused types (transitive unused)

For Python:
- Find all `TypedDict`, `NamedTuple`, `Protocol`, dataclass definitions
- Search for references

For Go:
- Find all `type` declarations
- Search for usage

Flag types that are:
- Defined but never used as a type annotation, parameter type, return type, or in a generic
- Only used in test files (might be test utilities, lower confidence)

### Step 5: Detect Orphan Files

Find source files that are not imported by any other file.

Method:
1. For each source file, extract its importable path (relative to project root or as a package)
2. Search all other files for imports of that path
3. If no file imports it and it is not an entry point, flag it as an orphan

**Exceptions (do NOT flag):**
- Entry points and configuration files
- Test files (they import source files, not the other way around)
- Script files referenced in package.json `scripts`
- Migration files
- Seed/fixture files
- Static assets
- Generated files (check for `@generated` or `auto-generated` comments)

### Step 6: Detect Unused Dependencies

Cross-reference package manifest with actual imports:

**Node.js (package.json):**
For each dependency in `dependencies` (not `devDependencies`):
1. Search for `import.*from ['"]<package>`, `require\(['"]<package>`, or dynamic `import\(['"]<package>`
2. Check `scripts` in package.json for CLI usage
3. Check config files for plugin references

For `devDependencies`:
1. Check if it is a build tool, test runner, or linter used in config
2. Check if it is a `@types/*` package for a used dependency
3. Check `scripts` for CLI usage

**Python (requirements.txt / pyproject.toml):**
For each listed package:
1. Search for `import <package>` or `from <package> import`
2. Note that package names may differ from import names (e.g., `Pillow` -> `PIL`, `beautifulsoup4` -> `bs4`)

**Go (go.mod):**
Run `go mod tidy -v 2>&1` if available, or manually check imports vs go.mod entries.

### Step 7: Detect Unused CSS Classes

If CSS/SCSS/LESS files are present:

1. Extract all class names defined in stylesheets: `.(\w[\w-]*)` patterns
2. Search template/component files for usage of each class name
3. Check for dynamic class names (template literals, `clsx`, `classnames` usage) — these make static analysis uncertain, so lower the confidence

For CSS Modules (`.module.css`):
- Check the import: `import styles from './file.module.css'`
- Check for `styles.<className>` usage in the component

For Tailwind CSS:
- Skip this check (classes are utility-based and not defined in stylesheets)

### Step 8: Detect Potentially Dead API Endpoints

If this is a backend project:

1. Find all route/endpoint definitions:
   - Express: `router.get\(`, `app.post\(`, etc.
   - Next.js: files in `pages/api/` or `app/api/`
   - Django: `path\(` in urls.py
   - Flask: `@app.route\(`
   - Go: `http.HandleFunc\(`, `mux.Handle\(`
   - Spring: `@GetMapping`, `@PostMapping`, etc.

2. For full-stack projects, search the frontend code for API calls matching each endpoint path
3. Flag endpoints that have no matching client-side calls

Note: This has lower confidence because:
- External clients may call the API
- Mobile apps may use the endpoints
- Only flag as POSSIBLE, never DEFINITE

### Step 9: Detect Potentially Dead Database References

If database schemas or migrations are present:

1. Find column names defined in migrations or schema files
2. Search the codebase for references to each column name
3. Flag columns that appear in schema but are never referenced in application code

Note: Lower confidence — columns may be used by other services, reports, or direct SQL. Always flag as POSSIBLE.

### Step 10: Estimate Impact

For each category of dead code found, estimate:
- **Lines of code**: Count lines in unused files, exported functions, etc.
- **Bundle size reduction** (for frontend): Estimate based on file sizes of unused code
- **Maintenance burden**: Code that must be maintained but provides no value

### Step 11: Generate Report

```
## Dead Code Detection Report

**Scope**: <directory analyzed>
**Files Scanned**: <count>
**Date**: <current date>

---

### Summary

**Total Dead Code Found**: ~<lines> lines across <categories> categories
**Estimated Bundle Size Reduction**: <size> (if applicable)
**Confidence Distribution**: <n> DEFINITE, <n> LIKELY, <n> POSSIBLE

---

### Unused Exports (<count>)

#### DEFINITE (no references found anywhere)

| # | File | Export | Type | Lines |
|---|------|--------|------|-------|
| 1 | `path/file.ext` | `functionName` | function | 25 |
| 2 | `path/file.ext` | `ClassName` | class | 80 |

#### LIKELY (only referenced in tests or same file)

| # | File | Export | Type | Lines | Notes |
|---|------|--------|------|-------|-------|
| 1 | `path/file.ext` | `helperFn` | function | 10 | Only in test |

### Unused Variables (<count>)

| # | File | Line | Variable | Confidence |
|---|------|------|----------|------------|
| 1 | `path/file.ext` | 42 | `tempResult` | DEFINITE |

### Unused Types/Interfaces (<count>)

| # | File | Type Name | Confidence |
|---|------|-----------|------------|
| 1 | `path/file.ext` | `OldUserProfile` | DEFINITE |

### Orphan Files (<count>)

| # | File | Lines | Confidence | Notes |
|---|------|-------|------------|-------|
| 1 | `path/orphan.ext` | 150 | DEFINITE | Not imported anywhere |
| 2 | `path/maybe.ext` | 45 | LIKELY | May be dynamically imported |

### Unused Dependencies (<count>)

| # | Package | Type | Confidence | Action |
|---|---------|------|------------|--------|
| 1 | `some-package` | production | DEFINITE | `npm uninstall some-package` |
| 2 | `unused-lib` | production | LIKELY | Verify, then remove |

### Unused CSS Classes (<count>)

| # | File | Class | Confidence |
|---|------|-------|------------|
| 1 | `styles.css` | `.old-banner` | DEFINITE |
| 2 | `component.module.css` | `.unused-variant` | LIKELY |

### Potentially Dead API Endpoints (<count>)

| # | Method | Path | File | Confidence |
|---|--------|------|------|------------|
| 1 | GET | `/api/v1/legacy` | `routes.ts:45` | POSSIBLE |

### Potentially Dead Database Columns (<count>)

| # | Table | Column | Schema File | Confidence |
|---|-------|--------|-------------|------------|
| 1 | users | `legacy_field` | `migrations/003.sql` | POSSIBLE |

---

### Impact Summary

| Category | Items | Lines | Bundle Impact |
|----------|-------|-------|---------------|
| Unused Exports | <n> | <lines> | <size> |
| Orphan Files | <n> | <lines> | <size> |
| Unused Dependencies | <n> | N/A | <size> |
| Unused CSS | <n> | <lines> | <size> |
| Dead Endpoints | <n> | <lines> | N/A |
| **Total** | **<n>** | **<lines>** | **<size>** |

---

### Cleanup Commands

```bash
# Remove unused dependencies
<package manager uninstall commands>

# Delete orphan files (verify before running)
<rm commands>
```

### Caveats

- Dynamic imports, reflection, and metaprogramming may cause false positives
- Framework conventions (decorators, dependency injection, file-based routing) may reference code indirectly
- External consumers (other services, mobile apps) may use exports flagged as unused
- Always verify LIKELY and POSSIBLE items before removing

### Recommendations

1. **Safe to remove now** (DEFINITE confidence): <list>
2. **Verify before removing** (LIKELY confidence): <list>
3. **Investigate further** (POSSIBLE confidence): <list>
4. **Tooling recommendations**: Install ecosystem-specific dead code tools:
   - TypeScript: `knip`, `ts-prune`
   - Python: `vulture`
   - Go: `deadcode` (from golang.org/x/tools)
   - General: Configure your linter's no-unused rules
```

Important: Always err on the side of caution. It is better to flag something as POSSIBLE than to miss dead code, but never say DEFINITE unless you are certain there are no dynamic references. Offer to help remove DEFINITE dead code if the user wants.
