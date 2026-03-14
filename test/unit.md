# Unit Test Generator

Generate comprehensive unit tests for a function or module, covering happy paths, edge cases, error handling, and boundary conditions.

## Arguments

$ARGUMENTS - `<file-path> [function-name]` — Path to the source file, optionally followed by a specific function name to test. If no function name is given, generate tests for all exported/public functions.

## Instructions

### Step 1: Read and Analyze the Source File

1. Read the file at the provided path.
2. If a function name was specified, locate that function. If not, identify all exported/public functions and classes.
3. For each target function, analyze:
   - Input parameters (names, types, defaults, required vs optional)
   - Return type and possible return values
   - Side effects (mutations, API calls, file I/O, database operations)
   - Dependencies that need mocking (imports, injected services)
   - Error conditions (thrown exceptions, rejected promises, error returns)
   - Branching logic (if/else, switch, ternary, guard clauses)

### Step 2: Detect the Testing Framework and Conventions

1. Search the project for existing test files to determine patterns:
   - Look for `jest.config.*`, `vitest.config.*`, `pytest.ini`, `pyproject.toml [tool.pytest]`, `*_test.go`, `pom.xml` (JUnit), `build.gradle` (JUnit)
   - Check `package.json` for test scripts, jest/vitest config
   - Look for `conftest.py`, `setup.cfg`, `tox.ini`
2. Identify the test file naming convention:
   - JavaScript/TypeScript: `*.test.ts`, `*.spec.ts`, `__tests__/*.ts`
   - Python: `test_*.py`, `*_test.py`
   - Go: `*_test.go` (same package)
   - Java: `*Test.java` in `src/test/java/...`
3. Find existing test files for similar modules to match style:
   - Import patterns (how mocks are set up)
   - Describe/it vs test blocks
   - Assertion style (expect, assert, should)
   - How fixtures and helpers are used
4. Identify the test file location convention:
   - Adjacent to source (`foo.ts` -> `foo.test.ts`)
   - In `__tests__/` directory
   - In parallel `test/` or `tests/` directory
   - In `src/test/` (Java/Kotlin)

### Step 3: Generate the Test File

Create the test file with the following structure:

#### 3a: File Header and Imports
- Import the testing framework
- Import the function(s) under test
- Import or set up mocks for dependencies
- Add any shared type imports

#### 3b: Setup and Teardown
- If the function depends on external state (database, file system, environment variables), add `beforeEach`/`afterEach` (or language equivalent) to set up and clean up
- If mocking is needed, set up mock factories and reset them between tests
- Define shared test fixtures and factory functions for test data

#### 3c: Test Cases — Generate All of These Categories

**Happy Path Tests (typical usage):**
- Call with standard, expected inputs
- Verify the return value matches expectations
- Test with multiple valid input variations
- Test the most common usage patterns

**Edge Case Tests:**
- Empty values: empty string `""`, empty array `[]`, empty object `{}`
- Null and undefined (where applicable)
- Zero and negative numbers
- Maximum/minimum values (MAX_SAFE_INTEGER, very long strings)
- Single element collections
- Unicode and special characters in string inputs
- Whitespace-only strings

**Error Case Tests:**
- Invalid input types (if not caught by type system)
- Missing required parameters
- Verify correct exception/error is thrown
- Verify error messages are meaningful
- Test with malformed data structures

**Boundary Condition Tests:**
- Off-by-one scenarios
- Exactly at limit values
- Just above/below thresholds
- First and last elements in sequences
- Transition points in conditional logic

**Return Type Verification:**
- Verify the shape/structure of returned objects
- Verify array return types contain correct element types
- Verify async functions return proper promises/futures
- Verify void/undefined returns where expected

**State and Side Effect Tests (if applicable):**
- Verify mocked dependencies are called with correct arguments
- Verify call counts on mocks
- Verify no unexpected side effects
- Test idempotency if relevant

#### 3d: Test Naming
- Use descriptive test names that read as sentences
- Pattern: `should <expected behavior> when <condition>`
- Group related tests in describe/context blocks by behavior category

### Step 4: Validate and Finalize

1. Write the test file to the correct location following project conventions.
2. Run the tests to verify they compile and execute:
   - JavaScript/TypeScript: `npx jest <file>` or `npx vitest run <file>`
   - Python: `python -m pytest <file> -v`
   - Go: `go test -v -run <TestName> ./<package>`
   - Java: `mvn test -Dtest=<TestClass>` or `gradle test --tests <TestClass>`
3. If any tests fail due to test code errors (not legitimate failures), fix the test code and re-run.
4. Report a summary:
   - Number of test cases generated per category
   - Any functions that were difficult to test and why
   - Suggestions for improving testability of the source code (e.g., dependency injection, pure functions)

### Important Guidelines

- NEVER modify the source code being tested. Only create/modify test files.
- Match the project's existing test style exactly — do not introduce new patterns.
- Use realistic test data, not generic placeholder values like "test" or "foo".
- Prefer explicit assertions over snapshot tests for logic.
- Each test should be independent and not rely on execution order.
- Keep tests focused: one logical assertion per test (multiple `expect` calls are fine if they verify one behavior).
- Do not test private/internal functions directly — test them through public interfaces.
