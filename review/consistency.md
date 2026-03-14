# Consistency Check

Check and enforce consistency of patterns, conventions, and styles across the codebase.

## Arguments

$ARGUMENTS - Optional `<directory>` to scope the check. Defaults to the project root (current working directory).

## Instructions

### 1. Determine Scope

- If `$ARGUMENTS` is provided, use it as the root directory for the check.
- If not provided, use the current working directory.
- Discover all source files in the scope. Focus on application code (exclude `node_modules`, `vendor`, `dist`, `build`, `.git`, `__pycache__`, `.venv`, `venv`, `target`, `bin`).
- Detect the primary language(s) and framework(s) by examining file extensions, `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, `build.gradle`, etc.

### 2. Check Each Consistency Category

For each category below, sample files across the codebase, identify the patterns in use, determine which is the dominant (most common) pattern, and flag files that deviate. Record: category, file path, line(s), current pattern, dominant pattern, and suggested fix.

#### a. Error Handling Patterns
Scan for how errors are handled and propagated:

- **Patterns to detect**:
  - `throw new Error(...)` vs `return { error: ... }` vs `Result<T, E>` type vs error codes
  - `try/catch` vs `.catch()` vs error callback
  - Custom error classes vs plain Error vs string throws
  - Error wrapping/chaining patterns
- **Flag**: Files that use a different error handling pattern from the majority.
- **Report**: The dominant pattern and the deviators.

#### b. API Response Format
Scan API route handlers, controllers, and response-building code:

- **Patterns to detect**:
  - Envelope format: `{ success, data, error }` vs `{ status, result }` vs raw data
  - HTTP status code usage: consistent use of 200/201/400/404/500 or inconsistent
  - Error response shape: `{ message }` vs `{ error: { code, message } }` vs `{ errors: [...] }`
  - Pagination format: `{ items, total, page, limit }` vs `{ data, meta: { ... } }` vs cursor-based
- **Flag**: Endpoints that return differently shaped responses.

#### c. Naming Conventions
Check consistency of naming across the codebase:

- **Patterns to detect**:
  - Variable naming: camelCase vs snake_case (should be uniform per language)
  - Function naming: camelCase vs snake_case
  - File naming: kebab-case vs camelCase vs PascalCase vs snake_case
  - Component naming (React/Vue): PascalCase consistency
  - Test file naming: `*.test.ts` vs `*.spec.ts` vs `test_*.py` vs `*_test.go`
- **Flag**: Files/identifiers that break the dominant convention.

#### d. File Organization
Check where different types of code live:

- **Patterns to detect**:
  - Types/interfaces: co-located with implementation vs separate `types/` directory vs `*.types.ts` files
  - Utilities: single `utils/` directory vs distributed per-feature vs `*.utils.ts` files
  - Constants: single `constants/` file vs per-feature constants vs inline
  - Tests: co-located (`Component.test.ts` next to `Component.ts`) vs separate `__tests__/` directory vs top-level `tests/`
- **Flag**: Files that break the dominant organizational pattern.

#### e. Import Ordering
Check the order of imports:

- **Patterns to detect**:
  - Grouped: external packages first, then internal, then relative
  - Alphabetical within groups
  - Blank line separators between groups
  - Absolute vs relative import paths for internal modules
- **Flag**: Files with inconsistent import ordering.

#### f. Async Patterns
Check consistency of asynchronous code:

- **Patterns to detect**:
  - `async/await` vs Promise chains (`.then()`) vs callbacks
  - Error handling in async code: `try/catch` vs `.catch()`
  - Concurrent execution: `Promise.all` vs sequential `await`
  - Event-based patterns: EventEmitter vs pub/sub vs observables
- **Flag**: Files using a minority async pattern.

#### g. State Management (Frontend)
If a frontend framework is detected:

- **Patterns to detect**:
  - React: `useState` vs `useReducer` vs Redux vs Zustand vs MobX vs Context API
  - Global state access patterns
  - Data fetching: `useEffect` + `fetch` vs React Query vs SWR vs custom hooks
- **Flag**: Components using a different state management approach from the majority.

#### h. Database Query Patterns
If database code is detected:

- **Patterns to detect**:
  - Raw SQL vs query builder vs ORM
  - Parameterized queries vs string interpolation (security issue if interpolated)
  - Transaction patterns: manual begin/commit vs transaction wrappers
  - Connection handling: pool vs individual connections
- **Flag**: Files using a different database access pattern. Flag string interpolation in SQL as HIGH priority security concern.

#### i. Logging Format and Levels
Check logging consistency:

- **Patterns to detect**:
  - Logger library: `console.*` vs `winston` vs `pino` vs `bunyan` vs `logging` (Python) vs `log` (Go)
  - Log levels used: debug/info/warn/error consistency
  - Structured logging: `logger.info({ userId, action })` vs `logger.info('User ${userId} did ${action}')`
  - Context inclusion: request ID, user ID, timestamp format
- **Flag**: Files using inconsistent logging approaches.

#### j. Test Organization and Naming
Check test file consistency:

- **Patterns to detect**:
  - Test runner: Jest vs Vitest vs Mocha vs pytest vs Go testing
  - Describe/it structure vs flat test functions
  - Test naming: `should do X` vs `does X` vs `test X when Y`
  - Setup/teardown: `beforeEach` vs `setUp` vs test fixtures
  - Mock patterns: `jest.mock` vs manual mocks vs dependency injection
  - Assertion style: `expect(x).toBe(y)` vs `assert.equal(x, y)` vs `assert x == y`
- **Flag**: Test files that deviate from the dominant testing patterns.

### 3. Determine Dominant Patterns

For each category:
1. Count occurrences of each pattern variant across the codebase.
2. The variant used in >50% of cases is the "dominant" pattern.
3. If no clear majority (e.g., 40/60 split), flag the category as "no clear convention" and recommend the user choose one.

### 4. Present Findings

Organize the report by category:

```
## Consistency Report

### a. Error Handling
**Dominant pattern:** `throw new Error(...)` with custom error classes (used in 15/20 files)
**Deviators:**
- `src/services/payment.ts` (line 45): returns `{ error: ... }` instead of throwing
- `src/utils/validator.ts` (line 12): throws plain string instead of Error object
**Recommendation:** Convert deviators to use custom error classes with `throw`.

### b. API Response Format
**Dominant pattern:** `{ success: boolean, data: T | null, error: string | null }` (used in 8/10 endpoints)
**Deviators:**
- `src/routes/legacy-api.ts`: returns raw data without envelope
**Recommendation:** Wrap legacy endpoint responses in the standard envelope.

... (continue for all categories)
```

### 5. Summary Table

```
| Category | Dominant Pattern | Consistent Files | Deviating Files | Consistency % |
|----------|-----------------|------------------|-----------------|---------------|
| Error handling | throw + custom classes | 15 | 5 | 75% |
| API responses | { success, data, error } | 8 | 2 | 80% |
| Naming | camelCase | 45 | 3 | 94% |
| File organization | co-located tests | 30 | 5 | 86% |
| Import ordering | grouped + alphabetical | 40 | 8 | 83% |
| Async patterns | async/await | 35 | 3 | 92% |
| State management | useState + React Query | 12 | 2 | 86% |
| Database queries | ORM (Prisma) | 10 | 1 | 91% |
| Logging | pino structured | 18 | 4 | 82% |
| Test naming | describe/it + should | 20 | 3 | 87% |
| **Overall** | | | | **XX%** |
```

### 6. Prioritized Fix List

Present a prioritized list of files to update, sorted by impact:

```
### HIGH Priority (inconsistency causes bugs or confusion)
1. `src/services/payment.ts` — error handling pattern (returns instead of throws)
2. `src/routes/legacy-api.ts` — API response format (missing envelope)
3. `src/db/raw-query.ts` — string interpolation in SQL (security risk)

### MEDIUM Priority (inconsistency hurts maintainability)
4. `src/utils/validator.ts` — error handling (throws string)
5. `src/components/OldWidget.tsx` — uses class component pattern

### LOW Priority (stylistic inconsistency)
6. `src/helpers/format.ts` — import ordering
7. `src/config/database.ts` — naming convention
```

### 7. Suggest Automation

Based on the findings, recommend tooling to enforce consistency automatically:

- **ESLint rules**: suggest specific rules for import ordering, naming conventions, no-console, consistent-return.
- **Prettier config**: suggest settings for consistent formatting.
- **Pre-commit hooks**: suggest hooks that enforce the dominant patterns.
- **TypeScript strict mode**: suggest enabling strict checks if not already on.
- **Linter configs**: suggest pylint/flake8/golint configurations for non-JS projects.

### 8. Apply Fixes (Optional)

- Ask the user: "Apply consistency fixes? (all / high-only / select / none)"
- If the user chooses to apply:
  - Apply fixes in priority order.
  - After each file is fixed, verify it still parses/compiles.
  - Run tests after all fixes to verify no regressions.

### 9. Important Rules

- NEVER change code that follows a deliberate, documented convention (e.g., a legacy API that must maintain backward compatibility).
- NEVER enforce consistency on generated code, vendored dependencies, or third-party code.
- NEVER change test assertions to match a different style if the test framework requires a specific style.
- If two patterns are equally common (within 10%), present both and ask the user to choose rather than picking one arbitrarily.
- Consider that some inconsistencies are intentional — a different pattern in a specific module may exist for a good reason. Flag but do not auto-fix without confirmation.
- When checking naming conventions, respect language-specific norms: Python uses snake_case, Go uses camelCase/PascalCase, Java uses camelCase.
- The goal is not 100% uniformity — it is identifying unintentional drift that causes confusion. Some variation is natural and acceptable.
- Skip categories that are not applicable to the project (e.g., skip "State Management" for a backend-only project, skip "Database Queries" for a frontend-only project).
