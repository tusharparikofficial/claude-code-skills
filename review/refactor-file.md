# Refactor File

Analyze a file for refactoring opportunities and apply improvements.

## Arguments

$ARGUMENTS - `<file-path>` of the file to analyze. Append `--apply` to auto-apply all refactorings without confirmation.

## Instructions

### 1. Parse Arguments

- Extract the file path from `$ARGUMENTS`.
- Check if `--apply` flag is present. If so, apply all refactorings automatically. Otherwise, present findings and wait for user confirmation before applying each change.
- Read the entire file content. Determine the language from the file extension.

### 2. Analyze for Refactoring Opportunities

Scan the file systematically for each of the following categories. For every issue found, record: category, line range, severity (CRITICAL / HIGH / MEDIUM / LOW), and a clear explanation.

#### a. Long Functions (>50 lines)
- Measure each function/method body (excluding blank lines and comments).
- If >50 lines, identify logical sections that can become standalone functions.
- Name each extracted function based on what it does (verb + noun).

#### b. Deep Nesting (>3 levels)
- Count indentation depth inside functions.
- Suggest early returns / guard clauses to flatten nesting.
- Invert conditions where it reduces depth.

#### c. Code Duplication Within the File
- Find blocks of 3+ lines that appear more than once (exact or near-duplicate).
- Propose a helper function that captures the shared logic.

#### d. Magic Numbers and Strings
- Flag any literal number (except 0, 1, -1) or string used in logic.
- Propose a named constant with SCREAMING_SNAKE_CASE.
- Place constants at the top of the file or in a constants section.

#### e. Complex Conditionals
- Flag any `if` / ternary with more than 2 boolean operators.
- Extract into a named predicate function (`isEligible`, `hasPermission`, etc.).

#### f. Mutable Patterns
- Find `let` that could be `const` (JavaScript/TypeScript).
- Find object/array mutations (push, splice, direct property assignment on shared state).
- Suggest immutable alternatives: spread, Object.freeze, map/filter/reduce.

#### g. Imperative Loops
- Find `for`, `for...in`, `for...of`, `while` loops that accumulate results.
- Convert to `map`, `filter`, `reduce`, `flatMap`, `find`, `some`, `every` where appropriate.
- Only convert when the declarative version is clearer, not when it would hurt readability.

#### h. God Class (>300 lines or >7 public methods)
- If a class has too many responsibilities, identify distinct responsibility groups.
- Suggest splitting into focused classes with clear single responsibilities.
- Outline the dependency relationship between the new classes.

### 3. Present Findings

For each opportunity found, present in this format:

```
### [SEVERITY] Category — Lines X-Y

**Why refactor:** <explanation of the problem>

**Before:**
```<lang>
<original code snippet>
```

**After:**
```<lang>
<refactored code snippet>
```
```

Sort by severity: CRITICAL > HIGH > MEDIUM > LOW.

### 4. Summary Report

Print a summary table:

| Category | Count | Severity | Lines Affected |
|----------|-------|----------|----------------|
| ...      | ...   | ...      | ...            |

Include total refactoring opportunities found.

### 5. Apply Changes

- If `--apply` flag was set, apply all refactorings using the Edit tool. Apply in reverse line order to avoid line number shifts.
- If no `--apply` flag, ask: "Apply all refactorings? (yes/no/select)" and follow the user's choice.
- After applying, re-read the file to verify the result compiles/parses correctly.
- If the project has a test command (check package.json scripts, Makefile, etc.), run tests to verify no regressions.

### 6. Important Rules

- NEVER change public API signatures (function names, parameter order, return types) unless specifically asked.
- NEVER remove functionality — only restructure.
- Preserve all comments and documentation.
- Maintain consistent code style with the rest of the file.
- When extracting functions, place them near related code or at the bottom of the file before exports.
- If the file is already clean (no opportunities found), say so and suggest the next file to review if part of a larger directory.
