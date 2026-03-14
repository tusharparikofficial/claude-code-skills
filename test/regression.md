# Regression Test Generator

Generate a regression test from a bug description or issue URL that fails with the bug present and passes once fixed, preventing future regressions.

## Arguments

$ARGUMENTS - `<bug-description>` or `<issue-url>` — Either a plain-text description of the bug (e.g., "User can submit form with empty email field") or a GitHub/GitLab issue URL (e.g., `https://github.com/org/repo/issues/42`).

## Instructions

### Step 1: Gather Bug Details

#### If an issue URL was provided:
1. Fetch the issue details using the CLI:
   - GitHub: `gh issue view <number> --json title,body,labels,comments`
   - GitLab: `glab issue view <number>`
2. Extract from the issue:
   - Title and description
   - Steps to reproduce
   - Expected behavior
   - Actual (buggy) behavior
   - Any code snippets, stack traces, or error messages
   - Related files or components mentioned
   - Comments with additional context or investigation findings
3. Note the issue number and URL for linking in the test.

#### If a bug description was provided:
1. Parse the description to identify:
   - What the expected behavior should be
   - What the actual (buggy) behavior is
   - What input/conditions trigger the bug
   - Which component/module is affected
2. If the description is vague, search the codebase for related code:
   - Search for function names, error messages, or keywords mentioned
   - Identify the specific file(s) and function(s) involved

### Step 2: Locate the Affected Code

1. Based on the bug details, find the source code that contains (or should contain) the fix:
   - Search for relevant functions, classes, or modules
   - Trace the code path that the bug follows
   - Identify the exact condition that fails
2. Find the existing test file for this code:
   - If a test file exists, the regression test will be added there
   - If no test file exists, determine where to create one
3. Understand the current test coverage:
   - Are there tests that SHOULD have caught this bug but didn't?
   - What gap in testing allowed this bug to exist?

### Step 3: Design the Regression Test

1. Define the test scenario:
   - **Preconditions**: What state must exist before the test runs
   - **Action**: What operation triggers the bug
   - **Assertion**: What the correct behavior should be
2. Ensure the test is specific to this bug:
   - It should fail if the bug is reintroduced
   - It should not be a generic test that happens to cover the bug
   - It should test the exact input/condition that triggered the bug
3. Consider related edge cases that the same bug class might affect:
   - Similar inputs that might trigger the same issue
   - Related code paths with the same pattern

### Step 4: Write the Regression Test

Generate the test with this structure:

```
/**
 * Regression test for: <bug title/description>
 * Issue: <issue-url> (if available)
 *
 * Bug: <concise description of what was broken>
 * Fix: <concise description of what the correct behavior is>
 *
 * This test ensures the bug does not reoccur.
 */
describe('regression: <bug-title>', () => {

  test('should <expected correct behavior> when <trigger condition>', () => {
    // Arrange: Set up the exact conditions that triggered the bug
    // ...

    // Act: Perform the action that triggered the bug
    // ...

    // Assert: Verify the CORRECT behavior
    // This assertion FAILS with the bug present, PASSES with the fix
    // ...
  });

  // Additional related edge cases if applicable
  test('should also handle <related edge case>', () => {
    // ...
  });

});
```

#### Test Code Guidelines:

1. **Arrange section**: Reproduce the exact conditions from the bug report
   - Use the specific input values mentioned in the bug report
   - Set up the same state/context that triggered the bug
   - Mock dependencies as needed to isolate the buggy code

2. **Act section**: Perform exactly what the user/system did to trigger the bug
   - Call the function with the problematic input
   - Trigger the event sequence that exposed the bug
   - Simulate the user action that caused the failure

3. **Assert section**: Verify the CORRECT behavior
   - Assert what SHOULD happen (not what the bug caused)
   - Be specific — test the exact output, state change, or behavior
   - If the bug caused a crash, assert that it doesn't crash
   - If the bug caused wrong output, assert the correct output
   - If the bug caused a missing validation, assert the validation exists

### Step 5: Verify the Test Works

1. **Confirm the test currently fails or passes appropriately**:
   - If the bug has NOT been fixed yet: the test should FAIL (RED). This confirms the test correctly detects the bug.
   - If the bug HAS been fixed already: the test should PASS (GREEN). This confirms the test guards against regression.
2. Run the test:
   - JavaScript/TypeScript: `npx jest <file> -t "<test-name>"` or `npx vitest run <file>`
   - Python: `python -m pytest <file> -k "<test-name>" -v`
   - Go: `go test -v -run "<TestName>" ./<package>`
   - Java: `mvn test -Dtest="<TestClass>#<testMethod>"`
3. If the test passes when it should fail (bug unfixed), the test is not correctly targeting the bug — revise the assertions.
4. If the test fails for the wrong reason (import error, setup issue), fix the test infrastructure.

### Step 6: Add Context and Documentation

1. Add the regression test to the correct test file:
   - Place it in a `describe('regressions', ...)` or `describe('bug fixes', ...)` block if one exists
   - Otherwise, add it as a clearly labeled section at the end of the relevant test file
2. Include a link to the original issue in the test comment.
3. Add git blame-friendly comments explaining why the test exists.

### Step 7: Report

Present a summary:

```
## Regression Test Summary

### Bug
- **Issue**: <url or description>
- **Root cause**: <what caused the bug>
- **Affected code**: <file:function>

### Test Created
- **File**: <test-file-path>
- **Test name**: <full test name>
- **Status**: FAILING (bug present) / PASSING (bug already fixed)

### What the Test Verifies
- <specific assertion 1>
- <specific assertion 2>

### Related Tests to Consider
- <any additional edge cases worth testing>
```

### Important Guidelines

- The regression test must be MINIMAL — test only the specific bug, not general functionality.
- Use the exact input values from the bug report when possible, not abstract test data.
- The test should be understandable by someone reading it in 6 months — include clear comments about what the bug was.
- Always link to the original issue in the test comments for traceability.
- If the bug is in a private/internal function, test it through the public interface that exposed the bug.
- Do not modify the source code — only create or modify test files.
- If the test requires a specific database state or environment, document the prerequisites clearly.
- Group regression tests so they are easy to find — use consistent naming like `regression:` prefix or a dedicated describe block.
- If fixing the bug requires a code change, describe the expected fix but do not implement it — the test should guide the fix.
