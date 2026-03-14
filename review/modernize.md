# Modernize Code

Modernize legacy code patterns to use current language idioms and best practices.

## Arguments

$ARGUMENTS - `<file-or-directory>` to modernize. Can be a single file or a directory (all supported files will be processed).

## Instructions

### 1. Parse Arguments and Discover Files

- Extract the target path from `$ARGUMENTS`.
- If it is a directory, find all source files (`.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `.py`, `.go`, `.java`).
- For each file, determine the language and applicable modernization rules.
- Read each file's content.

### 2. Detect Legacy Patterns

Scan for the following patterns by language. For each detection, record: file, line range, pattern name, severity (HIGH = likely bug risk, MEDIUM = readability/maintainability, LOW = stylistic).

#### JavaScript / TypeScript

| Legacy Pattern | Modern Replacement | Severity |
|---|---|---|
| `var` declarations | `const` (preferred) or `let` | HIGH |
| Callback-based async (callback hell) | `async/await` | HIGH |
| `.then().catch()` Promise chains | `async/await` with try/catch | MEDIUM |
| `require()` / `module.exports` (CommonJS) | `import` / `export` (ES Modules) | MEDIUM |
| Class components (React) | Functional components with hooks | MEDIUM |
| `string + concatenation` | Template literals `` `${var}` `` | LOW |
| `for (var i = 0; ...)` loops | `for...of`, `.map()`, `.filter()`, `.reduce()` | MEDIUM |
| `Object.assign({}, obj, ...)` | Spread `{ ...obj, ... }` | LOW |
| `arguments` keyword | Rest parameters `...args` | MEDIUM |
| `$.ajax()`, jQuery DOM manipulation | `fetch()` / vanilla DOM / framework | MEDIUM |
| `new Promise((resolve, reject) => ...)` wrapping callback | Promisify or use async API directly | MEDIUM |
| `apply` / `call` for spreading args | Spread syntax `fn(...args)` | LOW |
| `typeof x !== 'undefined' && x !== null` | Optional chaining `x?.prop` / nullish coalescing `x ?? default` | MEDIUM |
| `exports.foo = function` | `export function foo` | MEDIUM |
| `Array.prototype.slice.call(nodeList)` | `Array.from(nodeList)` or `[...nodeList]` | LOW |
| `obj.hasOwnProperty('key')` | `Object.hasOwn(obj, 'key')` | LOW |

#### Python

| Legacy Pattern | Modern Replacement | Severity |
|---|---|---|
| `print` statement (Python 2) | `print()` function | HIGH |
| `except Exception, e` | `except Exception as e` | HIGH |
| `dict.has_key(k)` | `k in dict` | HIGH |
| `xrange()` | `range()` | MEDIUM |
| `raw_input()` | `input()` | MEDIUM |
| `unicode` / `basestring` types | `str` (Python 3) | HIGH |
| `%s` string formatting | f-strings `f"{var}"` | LOW |
| `.format()` string formatting | f-strings `f"{var}"` | LOW |
| `os.path.join` chains | `pathlib.Path` | MEDIUM |
| Missing type hints | Add type annotations | MEDIUM |
| `dict()` constructor | Dict literal `{}` | LOW |
| `lambda` assigned to variable | `def` function | LOW |
| `map(lambda ...)` / `filter(lambda ...)` | List comprehension / generator expression | MEDIUM |
| `try/except` without specific exception | Catch specific exceptions | HIGH |
| `open()` without context manager | `with open() as f:` | HIGH |

### 3. Plan Modernization

For each file with detected patterns, create a modernization plan:

```
## <file-path>

Patterns found: <N>
Risk level: HIGH / MEDIUM / LOW (highest severity found)

1. [HIGH] Lines 12-15: var → const/let
   - `var users = []` → `const users = []`
   - `var i = 0` → `let i = 0`

2. [MEDIUM] Lines 30-55: callback → async/await
   - Refactor `fs.readFile(path, (err, data) => {...})` to `const data = await fs.readFile(path)`
   - Wrap in try/catch for error handling

...
```

### 4. Apply Modernizations

Process files one at a time. For each file:

#### a. Apply Changes in Safe Order
1. Module system changes first (`require` → `import`, `module.exports` → `export`).
2. Variable declarations (`var` → `const`/`let`).
3. Async patterns (callbacks → async/await, Promise chains → async/await).
4. Syntax modernizations (template literals, spread, optional chaining, etc.).
5. Framework-specific changes (class components → functional, jQuery → vanilla) last.

#### b. Preserve Behavior
- NEVER change the logic or behavior of the code.
- When converting callbacks to async/await, ensure error handling is preserved.
- When converting class components to functional, map lifecycle methods to hooks:
  - `componentDidMount` → `useEffect(() => {}, [])`
  - `componentDidUpdate` → `useEffect(() => {})`
  - `componentWillUnmount` → `useEffect(() => { return () => cleanup }, [])`
  - `this.state` / `this.setState` → `useState`
  - `this.props` → function parameters
- When converting CommonJS to ESM:
  - `const x = require('y')` → `import x from 'y'`
  - `const { a, b } = require('y')` → `import { a, b } from 'y'`
  - `module.exports = x` → `export default x`
  - `exports.a = x` → `export const a = x`
  - Update `package.json` `"type": "module"` if needed.

### 5. Run Tests

- After all changes are applied, check if the project has a test command:
  - `package.json` → `npm test` or `npm run test`
  - `Makefile` → `make test`
  - `pytest.ini` / `setup.cfg` / `pyproject.toml` → `pytest`
  - `go.mod` → `go test ./...`
- Run the test command. If tests fail:
  - Identify which modernization caused the failure.
  - Revert that specific change.
  - Report the issue to the user.

### 6. Summary Report

```
Modernization complete:

Files processed: <N>
Patterns modernized: <N>
  - var → const/let: <N>
  - callbacks → async/await: <N>
  - CommonJS → ESM: <N>
  - ... (etc.)

Skipped (manual review needed):
  - <file>:<line> — <reason>

Tests: PASS / FAIL (details) / NOT RUN
```

### 7. Important Rules

- NEVER modernize test files differently from source files — keep them consistent.
- NEVER convert CommonJS to ESM if the project explicitly uses CommonJS (`"type": "commonjs"` in package.json, or `.cjs` extension).
- NEVER convert class components if the project uses class-based patterns intentionally (check for `shouldComponentUpdate`, `getSnapshotBeforeUpdate`, error boundaries).
- If a file mixes old and new patterns, modernize the old ones to match the new ones already present.
- Preserve all comments, documentation, and whitespace style.
- If a conversion is risky or ambiguous, flag it for manual review instead of applying it.
- When processing a directory, show progress: "Processing file X of N: <filename>".
