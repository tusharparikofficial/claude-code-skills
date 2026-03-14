# Simplify Code

Simplify overly complex code by reducing cognitive load, cyclomatic complexity, and unnecessary abstraction.

## Arguments

$ARGUMENTS - `<file-path>` of the file to simplify.

## Instructions

### 1. Parse Arguments and Read File

- Extract the file path from `$ARGUMENTS`.
- Read the entire file content. Determine the language.
- Calculate an initial complexity estimate for the file (see step 6 for the method).

### 2. Identify Complexity Hotspots

Scan every function/method in the file. For each, estimate cyclomatic complexity by counting decision points: `if`, `else if`, `else`, `switch/case`, `for`, `while`, `do-while`, `try/catch`, `&&`, `||`, `??`, ternary `?:`. A function with complexity > 10 is a hotspot.

Sort functions by complexity (highest first) and focus simplification efforts on the worst offenders.

### 3. Detect and Simplify Patterns

For each complexity hotspot, apply the following simplification strategies where applicable:

#### a. Nested Ternaries → if/else or switch
- **Detect**: Ternary expressions nested more than 1 level deep.
- **Simplify**: Convert to `if/else` chain or `switch` statement.
- **Rationale**: Nested ternaries are notoriously hard to read and debug.
- **Example**:
  ```
  // Before
  const label = status === 'active' ? 'Active' : status === 'pending' ? 'Pending' : status === 'expired' ? 'Expired' : 'Unknown';

  // After
  const label = getStatusLabel(status);

  function getStatusLabel(status) {
    switch (status) {
      case 'active': return 'Active';
      case 'pending': return 'Pending';
      case 'expired': return 'Expired';
      default: return 'Unknown';
    }
  }
  ```

#### b. Complex Boolean Expressions → Named Predicates
- **Detect**: Boolean expressions with 3+ operators or that span multiple lines.
- **Simplify**: Extract into a named predicate function.
- **Example**:
  ```
  // Before
  if (user.age >= 18 && user.hasVerifiedEmail && !user.isBanned && user.subscription !== 'expired') {

  // After
  if (isEligibleUser(user)) {

  function isEligibleUser(user) {
    return user.age >= 18
      && user.hasVerifiedEmail
      && !user.isBanned
      && user.subscription !== 'expired';
  }
  ```

#### c. Unnecessary Abstractions → Inline
- **Detect**: Functions/classes/wrappers that add no value:
  - Functions that just call another function with the same arguments
  - Wrapper classes with a single method that delegates to another class
  - Abstract classes with only one concrete implementation
  - Interfaces with only one implementor that will never have more
  - Factory functions that always return the same type
- **Simplify**: Inline the abstraction — replace calls to the wrapper with calls to the underlying function/class.
- **Caution**: Only inline if the abstraction truly adds no value. If it provides a seam for testing or future extension, flag but do not inline.

#### d. Redundant Null Checks → Optional Chaining / Nullish Coalescing
- **Detect**: Verbose null/undefined checks:
  - `if (obj && obj.prop && obj.prop.nested)` → `obj?.prop?.nested`
  - `x !== null && x !== undefined ? x : default` → `x ?? default`
  - `if (x != null) { return x } else { return default }` → `return x ?? default`
- **Simplify**: Use optional chaining (`?.`) and nullish coalescing (`??`).

#### e. Verbose Error Handling → Consolidated
- **Detect**: Multiple try/catch blocks with identical or very similar catch handlers in the same function.
- **Simplify**: Consolidate into a single try/catch or extract error handling into a helper.
- **Example**:
  ```
  // Before
  try { a = await fetchA(); } catch (e) { log(e); throw new AppError('Failed', e); }
  try { b = await fetchB(); } catch (e) { log(e); throw new AppError('Failed', e); }

  // After
  const [a, b] = await Promise.all([
    withErrorHandling(() => fetchA()),
    withErrorHandling(() => fetchB()),
  ]);
  ```

#### f. Complex reduce → Simpler Alternative
- **Detect**: `reduce` calls with:
  - Accumulator that is an object being built up with many properties
  - Body longer than 5 lines
  - Nested conditions inside the reducer
- **Simplify**: Replace with a `for...of` loop, `map` + `Object.fromEntries`, or `flatMap` as appropriate.
- **Rationale**: `reduce` is powerful but often less readable than alternatives for complex accumulations.

#### g. Unnecessary Wrapper Functions → Direct Usage
- **Detect**: Arrow functions or function expressions that just forward to another function:
  - `(x) => doSomething(x)` — can be replaced with `doSomething`
  - `function(err) { callback(err) }` — can be replaced with `callback`
- **Simplify**: Replace with the direct function reference.
- **Caution**: Do not simplify if the wrapper changes `this` binding, adds default arguments, or transforms parameters.

#### h. Over-Parameterized Functions → Options Object or Defaults
- **Detect**: Functions with more than 4 parameters, especially if several are optional or boolean flags.
- **Simplify**: Convert to an options object pattern:
  ```
  // Before
  function createUser(name, email, role, isActive, sendWelcome, teamId) {

  // After
  function createUser({ name, email, role = 'user', isActive = true, sendWelcome = false, teamId = null }) {
  ```

#### i. Deep Nesting → Early Returns
- **Detect**: Code with indentation depth > 3 levels.
- **Simplify**: Use guard clauses and early returns to flatten the structure:
  ```
  // Before
  function process(user) {
    if (user) {
      if (user.isActive) {
        if (user.hasPermission) {
          // actual logic
        }
      }
    }
  }

  // After
  function process(user) {
    if (!user) return;
    if (!user.isActive) return;
    if (!user.hasPermission) return;
    // actual logic
  }
  ```

#### j. Long Switch Statements → Lookup Table
- **Detect**: Switch statements with more than 5 cases that all return values or call functions.
- **Simplify**: Convert to an object/map lookup:
  ```
  // Before
  switch (type) {
    case 'a': return handleA();
    case 'b': return handleB();
    case 'c': return handleC();
    // ... many more
  }

  // After
  const handlers = { a: handleA, b: handleB, c: handleC, ... };
  return handlers[type]?.() ?? handleDefault();
  ```

### 4. Apply Simplifications

- Apply changes using the Edit tool.
- Process changes within each function from bottom to top to avoid line-number drift.
- After each file modification, re-read to verify correctness.

### 5. Run Tests

- If the project has tests, run them after all simplifications are applied.
- If any test fails, identify the offending simplification, revert it, and report the issue.

### 6. Complexity Report

Calculate and report complexity scores:

**Cyclomatic Complexity Estimation Method:**
- Start at 1 for each function.
- Add 1 for each: `if`, `else if`, `case`, `for`, `while`, `do`, `catch`, `&&`, `||`, `??`, ternary `?:`.
- Complexity 1-5: LOW (good), 6-10: MEDIUM (acceptable), 11-20: HIGH (needs simplification), 21+: CRITICAL (must simplify).

Present the report:

```
## Simplification Report for <file-path>

### Complexity Scores

| Function | Before | After | Change |
|----------|--------|-------|--------|
| processOrder | 18 (HIGH) | 7 (MEDIUM) | -11 |
| validateInput | 12 (HIGH) | 5 (LOW) | -7 |
| ... | ... | ... | ... |

**File average complexity:** <before> → <after>
**Total decision points removed:** <N>

### Changes Applied
1. Lines X-Y: Nested ternary → switch statement in `processOrder`
2. Lines X-Y: Complex boolean → named predicate `isEligibleUser`
3. ...

### Remaining Hotspots (manual review recommended)
- `functionName` (complexity: N) — <reason it could not be simplified automatically>
```

### 7. Important Rules

- NEVER change the behavior or output of the code — simplification is a pure refactoring.
- NEVER inline abstractions that serve as testing seams (dependency injection, mock boundaries).
- NEVER simplify error handling in a way that loses error context or changes error types.
- If a simplification makes the code LESS readable (subjective), skip it and explain why.
- Preserve all comments and documentation.
- When converting nested ternaries, prefer `switch` for value mapping and `if/else` for complex logic with side effects.
- If the file is already simple (all functions have complexity <= 5), report that and suggest no changes.
