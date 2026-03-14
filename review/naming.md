# Naming Audit

Audit and improve naming quality across files for clarity, consistency, and convention adherence.

## Arguments

$ARGUMENTS - `<file-or-directory>` to audit. Can be a single file or directory.

## Instructions

### 1. Parse Arguments and Discover Files

- Extract the target path from `$ARGUMENTS`.
- If it is a directory, find all source files recursively.
- Read each file's content.
- Detect the project's existing naming conventions by sampling file names, variable styles, and import patterns across the codebase.

### 2. Detect Project Conventions

Before auditing, determine the dominant conventions already in use:

- **File naming**: kebab-case (`user-service.ts`), camelCase (`userService.ts`), snake_case (`user_service.py`), PascalCase (`UserService.java`)
- **Variable naming**: camelCase, snake_case, etc.
- **Constant naming**: SCREAMING_SNAKE_CASE vs camelCase
- **Class naming**: PascalCase (should be universal)
- **Language defaults**: Apply language-specific conventions (Python = snake_case, JS/TS = camelCase, Go = camelCase/PascalCase, Java = camelCase)

Record the detected conventions so that suggestions align with the project's style rather than imposing external preferences.

### 3. Audit Each File

For every declaration (variable, function, class, type, constant, parameter, file name), evaluate against the following rules. Record: file, line, current name, issue category, severity (HIGH / MEDIUM / LOW), and suggested replacement.

#### a. Function Naming
- **Rule**: Functions should start with a verb that describes the action.
- **Good verbs**: `get`, `set`, `create`, `update`, `delete`, `remove`, `find`, `search`, `fetch`, `load`, `save`, `send`, `receive`, `validate`, `check`, `is`, `has`, `can`, `should`, `will`, `parse`, `format`, `transform`, `convert`, `calculate`, `compute`, `build`, `render`, `handle`, `process`, `init`, `reset`, `clear`, `open`, `close`, `start`, `stop`, `enable`, `disable`
- **Flag**: Functions without a leading verb (e.g., `userData()` should be `getUserData()` or `fetchUserData()`).
- **Exception**: Factory functions named after the thing they create (`User()`, `createUser()` — both acceptable).
- **Severity**: MEDIUM

#### b. Variable Naming
- **Rule**: Variables should be descriptive nouns or noun phrases.
- **Flag** (HIGH):
  - Single-letter variables outside of loop counters (`i`, `j`, `k`) or lambda parameters: `x`, `d`, `t`, `n`, `s`
  - Generic names: `data`, `info`, `temp`, `tmp`, `result`, `res`, `ret`, `val`, `value`, `item`, `thing`, `obj`, `stuff`, `foo`, `bar`, `baz`
- **Suggest**: Replace with what the variable actually represents. `data` → `userProfile`, `temp` → `formattedAddress`, etc.
- **Exception**: In very short scopes (1-3 lines), generic names like `result` are acceptable.

#### c. Boolean Naming
- **Rule**: Booleans should read as yes/no questions.
- **Good prefixes**: `is`, `has`, `can`, `should`, `will`, `did`, `was`, `needs`, `allows`, `includes`, `supports`
- **Flag** (MEDIUM):
  - `active` → `isActive`
  - `visible` → `isVisible`
  - `loading` → `isLoading`
  - `error` → `hasError`
  - `permission` → `hasPermission`
  - `enabled` → `isEnabled`
- **Exception**: Boolean properties in data objects/DTOs that match an API contract should not be renamed.

#### d. Constant Naming
- **Rule**: Constants should use SCREAMING_SNAKE_CASE (JS/TS/Java/Go) or appropriate language convention.
- **Flag** (LOW):
  - `maxRetries` → `MAX_RETRIES`
  - `apiUrl` → `API_URL`
  - `defaultTimeout` → `DEFAULT_TIMEOUT`
- **Exception**: In Python, module-level constants are conventionally UPPER_CASE. In Go, exported constants are PascalCase.

#### e. Class / Type Naming
- **Rule**: Classes and types should be PascalCase nouns or noun phrases.
- **Flag** (HIGH):
  - Classes with verb names: `ProcessData` → `DataProcessor`
  - Classes with vague names: `Manager`, `Handler`, `Helper`, `Util` — suggest more specific names based on what the class actually does.
- **Flag** (MEDIUM):
  - Inconsistent suffixes: mixing `Service` / `Manager` / `Controller` for similar patterns.

#### f. File Naming
- **Rule**: File names should match the primary export/class and follow the project's casing convention.
- **Flag** (MEDIUM):
  - Inconsistent casing across similar files: `user-service.ts` alongside `orderService.ts`
  - File name does not match the primary export: file `helpers.ts` exports `class UserValidator`
  - Generic file names: `utils.ts`, `helpers.ts`, `misc.ts`, `index.ts` (index is fine for barrels)

#### g. Abbreviation Check
- **Flag** (LOW) abbreviations that hurt readability:
  - `usr` → `user`
  - `msg` → `message`
  - `btn` → `button`
  - `cb` → `callback`
  - `err` → `error`
  - `req` → `request`
  - `res` → `response`
  - `ctx` → `context`
  - `cfg` → `config`
  - `fn` → `function` (unless in a functional programming context)
  - `str` → `string` or more specific name
  - `num` → `number` or `count`
  - `arr` → `array` or `items`/`list`
  - `idx` → `index`
  - `len` → `length`
  - `prev` → `previous`
  - `curr` → `current`
- **Exception**: Well-known abbreviations in context are fine: `db` for database, `api` for API, `url` for URL, `id` for identifier, `io` for input/output. `req`/`res` are acceptable in HTTP handler parameters.

#### h. Consistency Across Related Items
- **Flag** (HIGH):
  - `getUser` paired with `fetchOrder` — inconsistent verb for the same kind of operation
  - `createItem` paired with `addItem` — are these different operations or the same?
  - `deleteUser` paired with `removeUser` — pick one convention
  - `UserDTO` alongside `OrderData` alongside `ProductModel` — inconsistent suffixes for the same concept

### 4. Present Findings

Group findings by file, then by severity:

```
## <file-path>

### HIGH Priority
1. Line 15: `data` → `userProfiles` — generic name that does not communicate what it holds
2. Line 42: `process()` → `validateAndSubmitOrder()` — function name does not describe the action

### MEDIUM Priority
3. Line 8: `active` → `isActive` — boolean should have is/has prefix
4. Line 30: `getData()` → `fetchUserProfile()` — both verb and noun are too generic

### LOW Priority
5. Line 3: `maxRetries` → `MAX_RETRIES` — constant should use SCREAMING_SNAKE_CASE
6. Line 22: `msg` → `message` — avoid abbreviations
```

### 5. Summary Report

```
## Naming Audit Summary

Files audited: <N>
Total issues: <N>
  HIGH: <N>
  MEDIUM: <N>
  LOW: <N>

Top issue categories:
  1. Generic variable names: <N>
  2. Missing boolean prefix: <N>
  3. Functions without verb: <N>
  4. Inconsistent naming: <N>
  5. Abbreviations: <N>

Detected project conventions:
  Files: <convention>
  Variables: <convention>
  Constants: <convention>
```

### 6. Apply Renames (Optional)

- Ask the user: "Apply suggested renames? (yes / select / no)"
- If yes or select:
  - For each rename, use the Edit tool with `replace_all: true` to rename within the file.
  - Search the entire codebase for references to the old name and update them.
  - If the rename is a file rename, use `mv` and update all import paths.
- After applying, run tests to verify no regressions.

### 7. Important Rules

- NEVER rename public API symbols without explicit user approval — they may break external consumers.
- NEVER rename variables that match an external API contract (database columns, API request/response fields).
- NEVER rename variables inside third-party type definitions or generated code.
- Respect language-specific conventions: Python uses snake_case, Java uses camelCase, Go exports are PascalCase.
- When suggesting names, provide the rationale so the user can evaluate.
- If the project has an ESLint naming convention rule or similar, align suggestions with it.
- Flag inconsistencies as higher priority than individual naming issues — consistency matters more than any single name.
