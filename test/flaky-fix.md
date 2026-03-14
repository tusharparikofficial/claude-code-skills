# Flaky Test Analyzer and Fixer

Analyze flaky tests to identify root causes, apply fixes, and verify stability through repeated execution.

## Arguments

$ARGUMENTS - `<test-file-path>` or `<test-name>` — Path to the test file containing flaky tests, or the specific test name/pattern that is flaky.

## Instructions

### Step 1: Identify the Flaky Test(s)

1. If a file path was provided:
   - Read the test file
   - Identify all test cases in the file
   - Ask for or infer which specific test(s) are flaky (if not all)

2. If a test name was provided:
   - Search the codebase for the test by name
   - Locate the test file and the specific test case

3. Determine the test runner command:
   - **Jest**: `npx jest <file> -t "<test-name>"`
   - **Vitest**: `npx vitest run <file>`
   - **pytest**: `python -m pytest <file> -k "<test-name>" -v`
   - **Go**: `go test -v -run "<TestName>" -count=1 ./<package>`
   - **JUnit**: `mvn test -Dtest="<TestClass>#<testMethod>"`

### Step 2: Confirm Flakiness

1. Run the test 10 times in sequence to establish a failure rate:

   **JavaScript/TypeScript (Jest):**
   ```
   for i in {1..10}; do npx jest <file> -t "<test>" 2>&1 | tail -1; done
   ```

   **JavaScript/TypeScript (Vitest):**
   ```
   for i in {1..10}; do npx vitest run <file> 2>&1 | tail -3; done
   ```

   **Python:**
   ```
   for i in {1..10}; do python -m pytest <file> -k "<test>" -x --tb=no -q 2>&1 | tail -1; done
   ```

   **Go:**
   ```
   for i in {1..10}; do go test -v -run "<Test>" -count=1 ./<pkg> 2>&1 | grep -E "PASS|FAIL"; done
   ```

2. Record results:
   - Pass count / Fail count out of 10
   - If 10/10 pass: test may not be flaky in current state — inform user
   - If 10/10 fail: test is consistently failing, not flaky — this is a different problem
   - If mixed results: confirmed flaky — proceed with analysis

3. Capture failure output from the failing runs:
   - Error messages and stack traces
   - Assertion failures (expected vs actual values)
   - Timeout errors
   - Any intermittent error patterns

### Step 3: Analyze Root Cause

Read the flaky test code and its source code dependencies. Check for each common flaky test cause:

#### 3a: Timing Issues
- **Symptoms**: Timeout errors, "element not found", assertion on async result
- **Check for**:
  - `setTimeout`/`setInterval` in source code that tests rely on
  - Missing `await` on async operations
  - Race conditions between parallel async operations
  - Hardcoded `sleep()`/`waitForTimeout()` that are too short
  - Tests that check state during an animation or transition
  - Event listeners that may fire before the test assertion

#### 3b: Shared Mutable State
- **Symptoms**: Test passes alone but fails when run with other tests
- **Check for**:
  - Global variables modified by tests without cleanup
  - Singleton instances carrying state between tests
  - Module-level variables that persist across test runs
  - Missing `beforeEach`/`afterEach` to reset state
  - Database records not cleaned up between tests
  - Environment variables set and not restored
  - Mock functions not reset between tests (`jest.restoreAllMocks()`)

#### 3c: External Service Dependencies
- **Symptoms**: Network errors, connection refused, varying response times
- **Check for**:
  - HTTP calls to real APIs (not mocked)
  - Database queries to a shared test database
  - File system operations on shared files
  - Redis/cache dependencies
  - Message queue dependencies

#### 3d: Database State Leakage
- **Symptoms**: Duplicate key errors, unexpected data, wrong counts
- **Check for**:
  - Tests creating data without cleanup
  - Auto-increment IDs causing conflicts
  - Transaction isolation issues
  - Missing database reset between tests
  - Parallel test execution sharing database

#### 3e: Random Data Without Seeding
- **Symptoms**: Test sometimes fails with specific random values
- **Check for**:
  - `Math.random()`, `uuid()`, `faker.*` without seed
  - Random data hitting edge cases intermittently
  - Random port selection conflicts
  - Random test ordering dependencies

#### 3f: Date/Time Sensitivity
- **Symptoms**: Fails at certain times of day, month boundaries, timezones
- **Check for**:
  - `new Date()` / `Date.now()` without mocking
  - Timezone-dependent assertions
  - Tests that assume a specific date/time
  - Token expiration based on real clock
  - Midnight/month-end/year-end boundary issues

#### 3g: Network-Dependent Assertions
- **Symptoms**: Port conflicts, DNS resolution, connection timeouts
- **Check for**:
  - Hardcoded port numbers that may be in use
  - DNS-dependent tests
  - Tests relying on network speed
  - WebSocket connection timing

#### 3h: Test Order Dependencies
- **Symptoms**: Passes in isolation, fails in full suite (or vice versa)
- **Check for**:
  - Tests that depend on side effects of previous tests
  - Shared fixtures modified but not reset
  - Tests that skip setup because they assume prior test ran

### Step 4: Apply Fixes

For each identified root cause, apply the appropriate fix:

#### Timing Fixes
- Replace `sleep()/waitForTimeout()` with explicit condition waits
- Add proper `await` to all async operations
- Use `waitFor()` / `eventually()` patterns for assertion retries
- Increase timeouts only as a last resort, with a comment explaining why
- Use `fakeTimers` / `freezegun` to control time in tests

#### Shared State Fixes
- Add `beforeEach` to reset all shared state
- Add `afterEach` to clean up side effects
- Replace global mocks with per-test mocks
- Use `jest.isolateModules()` or equivalent for module state
- Ensure `jest.restoreAllMocks()` or equivalent runs after each test

#### External Service Fixes
- Mock all HTTP calls (use nock, msw, responses, httpretty)
- Use test containers for database dependencies
- Mock file system operations (memfs, mock-fs)
- Use in-memory alternatives for Redis/cache

#### Database Fixes
- Wrap each test in a transaction that rolls back
- Use unique data per test (prefixed with test name)
- Truncate tables in `beforeEach`
- Use separate test database with known state

#### Random Data Fixes
- Seed random generators: `faker.seed(12345)`
- Use deterministic UUIDs in tests
- Use fixed port allocation or dynamic port detection
- Set random seed in test setup

#### Date/Time Fixes
- Mock `Date.now()` / `new Date()` with fixed values
- Use `jest.useFakeTimers()` / `freezegun.freeze_time()`
- Test with explicit timezone configuration
- Avoid assertions on exact timestamps — use ranges or relative checks

#### Test Order Fixes
- Make each test fully self-contained
- Move shared setup into `beforeEach`, not into another test
- Avoid test interdependencies completely

### Step 5: Verify Stability

1. Run the fixed test 10 times again:
   ```
   for i in {1..10}; do <test-command> 2>&1 | tail -1; done
   ```

2. All 10 runs must pass. If any fail:
   - Analyze the remaining failure
   - Apply additional fixes
   - Re-run 10 times

3. Run the full test suite to ensure fixes didn't break other tests:
   - `npx jest` or `npx vitest run` or `python -m pytest` or `go test ./...`

4. If the full suite reveals new failures, the fix introduced a regression — revise.

### Step 6: Report

Present a structured report:

```
## Flaky Test Analysis Report

### Test Identified
- **File**: <test-file-path>
- **Test**: <test-name>
- **Initial flakiness**: X/10 failures

### Root Cause(s)
1. **<Category>**: <Specific description>
   - Evidence: <what in the test/code indicated this>
   - Location: <file:line>

### Fixes Applied
1. <Description of fix 1>
   - File modified: <path>
   - Change: <what was changed and why>

2. <Description of fix 2>
   - File modified: <path>
   - Change: <what was changed and why>

### Verification
- Post-fix stability: 10/10 passes
- Full suite: PASSING

### Prevention Recommendations
- <Suggestions to prevent similar flaky tests in the future>
- <Patterns or lint rules to adopt>
```

### Important Guidelines

- NEVER "fix" a flaky test by adding retries or increasing timeouts without addressing the root cause — those are bandaids, not fixes.
- NEVER delete or skip a flaky test to make CI green — fix it properly.
- If the fix requires changing source code (not just test code), explain the source code change needed but focus the fix on the test side first.
- A test that requires `sleep()` to pass is a test that will eventually fail — always use condition-based waits.
- Flaky tests often indicate real concurrency or state management bugs in the source code — note these even if the test fix is sufficient.
- After fixing, run the test BOTH in isolation AND as part of the full suite — some flaky tests only manifest in one context.
- Document the root cause in a code comment so future maintainers understand why the fix was necessary.
- If the test is fundamentally untestable in a deterministic way (e.g., true randomness, external timing), recommend restructuring the code for testability.
