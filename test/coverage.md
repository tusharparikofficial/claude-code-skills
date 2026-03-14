# Test Coverage Analyzer

Analyze test coverage, identify uncovered code, and generate targeted tests to increase coverage toward the 80% minimum threshold.

## Arguments

$ARGUMENTS - `<file-or-directory>` (optional) — Path to a specific file or directory to analyze. Defaults to the project root if omitted.

## Instructions

### Step 1: Detect the Coverage Toolchain

1. Identify the project language and testing framework by examining:
   - `package.json` — look for jest, vitest, c8, nyc, istanbul in devDependencies and scripts
   - `pyproject.toml`, `setup.cfg`, `pytest.ini` — look for coverage configuration
   - `go.mod` — Go projects use built-in `go test -cover`
   - `pom.xml`, `build.gradle` — look for JaCoCo, Cobertura plugins
   - `.nycrc`, `jest.config.*`, `vitest.config.*` — coverage configuration
2. Determine the coverage command:
   - **Jest**: `npx jest --coverage --coverageReporters=json-summary --coverageReporters=text`
   - **Vitest**: `npx vitest run --coverage --reporter=json`
   - **pytest**: `python -m pytest --cov=<source-dir> --cov-report=json --cov-report=term-missing`
   - **Go**: `go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out`
   - **JaCoCo**: `mvn test jacoco:report` or `gradle test jacocoTestReport`
   - **c8/nyc**: `npx c8 report --reporter=json-summary --reporter=text`
3. Check if coverage thresholds are already configured in the project.

### Step 2: Run Coverage Analysis

1. Execute the coverage command for the target file/directory.
2. If coverage fails to run, diagnose and fix the issue:
   - Missing coverage dependency — suggest installation command
   - Configuration errors — identify and explain the fix
   - Test failures blocking coverage — report the failing tests
3. Parse the coverage output to extract:
   - **Overall metrics**: statement %, branch %, function %, line %
   - **Per-file metrics**: coverage % for each source file
   - **Uncovered lines**: specific line numbers not covered
   - **Uncovered branches**: specific branch conditions not covered
   - **Uncovered functions**: functions with 0% coverage

### Step 3: Identify Coverage Gaps

1. Sort files by coverage percentage (lowest first).
2. For each file below 80% coverage, analyze what is uncovered:
   - **Uncovered functions**: list each uncovered function with its purpose
   - **Uncovered branches**: list each uncovered if/else, switch case, ternary
   - **Uncovered error paths**: catch blocks, error returns, validation failures
   - **Uncovered edge cases**: default cases, fallthrough logic, guard clauses
3. Categorize gaps by priority:
   - **P0 - Critical paths**: Business logic, data transformations, API handlers
   - **P1 - Error handling**: Catch blocks, validation errors, edge cases
   - **P2 - Branches**: Conditional logic, feature flags, configuration paths
   - **P3 - Utilities**: Helper functions, formatters, type guards

### Step 4: Generate Targeted Tests

For each coverage gap, starting with P0:

1. Read the uncovered source code to understand what it does.
2. Determine the test file where new tests should be added:
   - If a test file already exists for the source file, add tests to it
   - If no test file exists, create one following project conventions
3. Generate tests that specifically exercise the uncovered lines:
   - For uncovered functions: write happy path + error case tests
   - For uncovered branches: write tests that trigger each branch
   - For uncovered error paths: write tests that trigger each error condition
   - For uncovered edge cases: write tests with boundary inputs
4. Ensure new tests integrate with existing test structure:
   - Use the same describe/context grouping pattern
   - Reuse existing test helpers and fixtures
   - Follow the same assertion style

### Step 5: Verify Coverage Improvement

1. Run the coverage command again after adding tests.
2. Compare before and after metrics:
   - Overall coverage change (e.g., 62% -> 84%)
   - Per-file coverage improvements
   - Remaining uncovered areas
3. If still below 80%, identify what remains uncovered and generate additional tests.
4. Repeat until 80% is reached or all practical test cases are exhausted.

### Step 6: Generate Coverage Report

Present a structured report:

```
## Coverage Report

### Before
| Metric     | Coverage |
|------------|----------|
| Statements | XX%      |
| Branches   | XX%      |
| Functions  | XX%      |
| Lines      | XX%      |

### After
| Metric     | Coverage |
|------------|----------|
| Statements | XX%      |
| Branches   | XX%      |
| Functions  | XX%      |
| Lines      | XX%      |

### Files Needing Attention
| File | Before | After | Gap |
|------|--------|-------|-----|
| ...  | XX%    | XX%   | XX% |

### Tests Added
- <test-file>: X new test cases covering <description>
- ...

### Remaining Uncovered Code
- <file:line> — <reason it's hard to test>
- ...

### Recommendations
- ...
```

### Important Guidelines

- Focus on meaningful coverage, not vanity metrics — do not write tests that execute code without meaningful assertions.
- Do not test generated code (protobuf stubs, ORM migrations, auto-generated types).
- Do not test trivial getters/setters unless they contain logic.
- Coverage of error handling paths is more valuable than covering additional happy paths.
- Branch coverage is often more revealing than line coverage — prioritize testing conditional logic.
- If a function is genuinely untestable (e.g., process exit handlers), note it as an exclusion rather than writing a fragile test.
- Use `/* istanbul ignore next */` or equivalent sparingly and only with a comment explaining why.
- Never lower existing coverage thresholds to make tests pass.
