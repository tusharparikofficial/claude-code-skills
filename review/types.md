# Type Coverage Audit

Audit TypeScript or Python type coverage and correctness. Finds unsafe types, missing annotations, and suggests proper typing.

## Arguments

$ARGUMENTS - File path or directory to audit for type coverage

## Instructions

### Step 1: Determine Language and Scope

Check the target path:
- If `$ARGUMENTS` is a file, determine the language from its extension
- If `$ARGUMENTS` is a directory, scan for file types to determine the primary language

Detect the language:
- TypeScript: `.ts`, `.tsx` files, presence of `tsconfig.json`
- Python: `.py` files, presence of `pyproject.toml`, `setup.py`, `mypy.ini`, `pyrightconfig.json`

If both TypeScript and Python files exist, analyze both and report separately.

List all files in scope:
- TypeScript: `find <target> -type f \( -name "*.ts" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -path "*/dist/*" -not -path "*/.next/*" | head -100`
- Python: `find <target> -type f -name "*.py" -not -path "*/__pycache__/*" -not -path "*/venv/*" -not -path "*/.venv/*" | head -100`

### Step 2: TypeScript Analysis

If TypeScript files are in scope, perform the following checks by reading each file and using Grep to search for patterns.

#### 2a. Find All `any` Types

Search for explicit `any` usage:
- `:\s*any` — explicit `any` type annotations
- `as any` — type assertions to `any`
- `<any>` — generic `any` type arguments
- `: any\[\]` — arrays of any
- `Record<string, any>` — records with any values
- `Promise<any>` — promises resolving to any
- `Function` type (equivalent to `any` for functions)

For each `any` found:
1. Read the surrounding context to understand what the value actually is
2. Suggest a proper type based on how the value is used downstream
3. If the value comes from an external API, suggest creating an interface for it

Exclude files where `any` is genuinely unavoidable (type definition files wrapping untyped libraries).

#### 2b. Missing Return Types on Exported Functions

Search for exported functions without explicit return types:
- `export function \w+\([^)]*\)\s*{` (missing `: ReturnType` before `{`)
- `export const \w+ = \([^)]*\)\s*=>` (arrow functions without return type)
- `export const \w+ = async \([^)]*\)\s*=>` (async arrow functions)
- `export default function` without return type

For each, infer the return type from the function body and suggest it.

#### 2c. Loose Types That Could Be Narrowed

Search for:
- `string` where a string literal union would be more precise (e.g., `type Status = string` should be `type Status = 'active' | 'inactive'`)
- `number` where a specific range or enum would be better
- `object` type (almost always too loose)
- `{}` type (allows any non-nullish value)
- `string | number` where only one type is actually used at runtime
- Array types without proper element typing: `any[]`, `Array<any>`

#### 2d. Null/Undefined Handling

Check for:
- Non-null assertions (`!`) — each one is a potential runtime error. Flag and suggest proper null checks
- Optional chaining (`?.`) without handling the undefined case
- Missing null checks before accessing properties of potentially nullable values
- `as` type assertions that remove `null | undefined` without validation
- Functions that accept `T | null | undefined` but don't check before use

Check if `strictNullChecks` is enabled in `tsconfig.json`. If not, flag as HIGH priority.

#### 2e. Generic Constraints

Search for:
- Unconstrained generics (`<T>`) that should have bounds (`<T extends Base>`)
- Generics that are only used once (unnecessary generic, should use concrete type)
- Missing generic parameters on types that need them
- Overly broad constraints that could be narrowed

#### 2f. Discriminated Unions

Look for:
- Union types that are not properly discriminated (no common literal field)
- Switch/if-else on union types without exhaustive handling
- Missing `never` check in default case of discriminated union switch
- Type narrowing that relies on `typeof` or `instanceof` when a discriminated union would be safer

### Step 3: Python Analysis

If Python files are in scope, perform the following checks.

#### 3a. Functions Without Type Hints

Search for functions missing type annotations:
- `def \w+\(` followed by parameters without `: type` annotations
- Functions missing return type: `def \w+\([^)]*\)\s*:` without `-> ReturnType`
- Lambda functions (inherently untyped, flag if assigned to a typed variable)
- Class methods missing `self`/`cls` parameter type hints (these are optional but check return types)

For each, suggest appropriate type hints based on:
- How the function is called
- What values are returned
- Docstring hints

#### 3b. Optional Usage

Check for:
- Parameters with default `None` but not typed as `Optional[T]` or `T | None`
- Functions that return `None` in some paths but the return type does not include `None`
- `Optional` used in contexts where it is misleading (e.g., `Optional[List[T]]` when an empty list is the right default)
- Missing `from __future__ import annotations` for modern union syntax (`X | Y`)

#### 3c. TypeVar Constraints

Search for:
- `TypeVar` declarations and verify they have appropriate bounds/constraints
- `TypeVar` used only once (unnecessary, should use concrete type)
- Missing `TypeVar` where a function parameter and return type should be linked
- `TypeVar` with `bound=` that is too broad

#### 3d. Protocol Implementations

Check for:
- Classes that implement a protocol pattern but don't explicitly declare it (structural subtyping that could be made explicit)
- `Protocol` classes with missing method signatures
- Runtime protocol checks using `isinstance` with `@runtime_checkable`
- ABC usage where Protocol would be more appropriate

#### 3e. Type Narrowing

Check for:
- `isinstance` checks that could use `TypeGuard` for better narrowing
- `assert isinstance(x, T)` used for type narrowing (fragile, removed with `-O`)
- Cast/type:ignore comments that could be replaced with proper narrowing
- Missing `TYPE_CHECKING` imports for type-only dependencies

### Step 4: Run Type Checker (If Available)

Attempt to run the project's type checker for additional insights:
- TypeScript: `npx tsc --noEmit 2>&1 | head -50` (check for compiler errors)
- Python: `mypy <target> --ignore-missing-imports 2>&1 | head -50` or `pyright <target> 2>&1 | head -50`

If the type checker is not installed, note it as a recommendation.

### Step 5: Calculate Coverage Metrics

Count and categorize:
- Total functions/methods in scope
- Functions with complete type annotations (all params + return type)
- Functions with partial annotations
- Functions with no annotations
- Total `any` / untyped occurrences
- Total type assertions / casts
- Total non-null assertions (TypeScript) or type:ignore comments

Calculate:
- **Type Coverage**: `(fully typed functions / total functions) * 100`
- **Type Safety Score**: penalize for `any`, non-null assertions, type:ignore, unsafe casts

### Step 6: Generate Report

```
## Type Coverage Audit Report

**Scope**: <file/directory>
**Language**: TypeScript / Python / Both
**Date**: <current date>

---

### Summary

**Type Coverage**: <percentage>% (<fully typed> / <total> functions)
**Type Safety Score**: <score>/100
**Overall Assessment**: <Excellent / Good / Needs Improvement / Poor>

---

### Findings

#### `any` / Untyped Usage (<count>)

| # | File | Line | Current | Suggested Type |
|---|------|------|---------|----------------|
| 1 | `path/file.ext` | 42 | `any` | `UserProfile` |
| 2 | `path/file.ext` | 87 | `any[]` | `OrderItem[]` |
| ... | | | | |

#### Missing Return Types (<count>)

| # | File | Line | Function | Suggested Return |
|---|------|------|----------|-----------------|
| 1 | `path/file.ext` | 15 | `getUser` | `Promise<User \| null>` |
| ... | | | | |

#### Loose Types (<count>)

**[TYPE-L1]** `path/file.ext:line`
- **Current**: `status: string`
- **Suggested**: `status: 'active' | 'inactive' | 'pending'`
- **Rationale**: <how the value is used>

#### Null Safety Issues (<count>)

**[TYPE-N1]** `path/file.ext:line`
- **Issue**: Non-null assertion on potentially null value
- **Current**: `user!.name`
- **Fix**: `if (user) { user.name } else { /* handle null */ }`

#### Generic Issues (<count>)

**[TYPE-G1]** `path/file.ext:line`
- **Issue**: <description>
- **Fix**: <suggestion>

#### Type Narrowing Issues (<count>)

**[TYPE-R1]** `path/file.ext:line`
- **Issue**: <description>
- **Fix**: <suggestion>

---

### Coverage by File

| File | Functions | Typed | Coverage | Issues |
|------|-----------|-------|----------|--------|
| `path/file1.ext` | 12 | 10 | 83% | 2 any |
| `path/file2.ext` | 8 | 3 | 38% | 5 missing |
| ... | | | | |

---

### Recommendations

1. **Quick wins**: <files/functions that are easy to type and would raise coverage most>
2. **High-value targets**: <critical code paths that should be typed for safety>
3. **Configuration**: <tsconfig/mypy settings to enable for stricter checking>

### Configuration Suggestions

<For TypeScript>
- Enable `strict: true` in tsconfig.json (or list individual strict flags to enable)
- Enable `noUncheckedIndexedAccess` for safer array/object access
- Consider `exactOptionalPropertyTypes` for stricter optional handling

<For Python>
- Enable `strict` mode in mypy.ini
- Add `from __future__ import annotations` for modern syntax
- Consider using `pyright` in strict mode for additional checks
```

Offer to fix the most impactful type issues automatically. Prioritize functions in critical code paths (API handlers, data processing, shared utilities) over internal helpers.
