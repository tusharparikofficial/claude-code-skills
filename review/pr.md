# Pull Request Review

Deep multi-dimensional review of a pull request, analyzing correctness, security, performance, maintainability, testing, and breaking changes.

## Arguments

$ARGUMENTS - The PR number (e.g., `42`) or full PR URL (e.g., `https://github.com/owner/repo/pull/42`)

## Instructions

### Step 1: Fetch PR Details

Run the following commands in parallel using the Bash tool:

1. `gh pr view $ARGUMENTS --json number,title,body,author,baseRefName,headRefName,files,additions,deletions,changedFiles,labels,reviews,state`
2. `gh pr diff $ARGUMENTS`
3. `gh pr view $ARGUMENTS --json commits --jq '.commits[].messageHeadline'`

If `$ARGUMENTS` is a full URL, extract the PR number from it and use that with `gh pr view` and `gh pr diff`. If the command fails, try passing the full URL directly.

### Step 2: Understand Context

Before reviewing code, understand:
- What is the PR trying to accomplish? (Read title, body, commit messages)
- What is the base branch? What existing code is being modified?
- Read the key files being changed to understand the surrounding code context. Use the Read tool to examine the full current version of heavily-modified files.

### Step 3: Multi-Dimensional Review

Analyze the diff thoroughly across all six dimensions. For each finding, record the exact file path and line number from the diff.

#### 3a. Correctness
- Logic errors and off-by-one mistakes
- Null/undefined/nil handling — are all nullable paths covered?
- Race conditions in concurrent code (shared state, async operations)
- Edge cases: empty collections, zero values, negative numbers, boundary conditions
- Error handling: are errors caught, propagated, and reported correctly?
- State management: can state become inconsistent?
- Type mismatches or implicit conversions that lose data

#### 3b. Security
- Input validation: is all user input validated and sanitized before use?
- Injection vulnerabilities: SQL, NoSQL, OS command, template injection
- Authentication and authorization: are checks present and correct?
- Secret exposure: hardcoded API keys, passwords, tokens, connection strings
- SSRF, open redirect, path traversal risks
- Sensitive data in logs, error messages, or responses
- Insecure cryptography or random number generation

#### 3c. Performance
- N+1 query patterns (database calls inside loops)
- Missing database indexes for new query patterns
- Unnecessary re-renders in frontend components (missing memoization, unstable references)
- Large payloads without pagination or streaming
- Blocking synchronous operations in async contexts
- Missing caching for expensive operations
- Memory leaks (unclosed resources, growing collections, event listener leaks)
- Algorithmic complexity issues

#### 3d. Maintainability
- Naming: are variables, functions, and classes named clearly and consistently?
- Complexity: cyclomatic complexity, deep nesting (>4 levels), long functions (>50 lines)
- Duplication: is code duplicated that should be extracted?
- Coupling: does the change introduce tight coupling between modules?
- Single Responsibility: does each function/class do one thing well?
- Code organization: is the code in the right file/module/layer?
- Magic numbers or strings that should be constants

#### 3e. Testing
- Are new code paths covered by tests?
- Are tests meaningful (not just asserting true === true)?
- Are edge cases tested?
- Are error paths tested?
- Are mocks appropriate and not hiding real bugs?
- Are integration boundaries tested?
- Has test coverage decreased?

#### 3f. Breaking Changes
- API contract changes: renamed/removed endpoints, changed request/response shapes
- Database schema changes: are migrations reversible? Is there data loss risk?
- Configuration changes: new required env vars, changed defaults
- Dependency version bumps that may break consumers
- Behavioral changes that downstream consumers rely on
- Feature flag considerations for gradual rollout

### Step 4: Categorize Findings

Assign each finding a severity:

- **CRITICAL**: Must fix before merge. Security vulnerabilities, data loss, crashes, incorrect business logic.
- **HIGH**: Should fix before merge. Performance regressions, missing error handling, race conditions, inadequate test coverage for critical paths.
- **MEDIUM**: Should fix soon. Code smells, maintainability concerns, minor performance issues, missing edge case tests.
- **LOW**: Nice to fix. Style inconsistencies, minor naming improvements, documentation gaps.
- **NITPICK**: Optional. Personal preference, alternative approaches that are equally valid.

### Step 5: Generate Structured Output

Format the review as follows:

```
## PR Review: #<number> — <title>

**Author**: <author>
**Base**: <base-branch> ← <head-branch>
**Files Changed**: <count> (+<additions> -<deletions>)

---

### Summary

<2-3 sentence summary of what the PR does and the overall assessment: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION>

### Findings

#### CRITICAL (<count>)

**[C1]** <title>
- **File**: `path/to/file.ext:line`
- **Issue**: <description of the problem>
- **Impact**: <what could go wrong>
- **Fix**:
  ```<lang>
  // suggested fix
  ```

#### HIGH (<count>)

**[H1]** <title>
- **File**: `path/to/file.ext:line`
- **Issue**: <description>
- **Fix**:
  ```<lang>
  // suggested fix
  ```

#### MEDIUM (<count>)

**[M1]** <title>
- **File**: `path/to/file.ext:line`
- **Issue**: <description>
- **Suggestion**: <what to do>

#### LOW (<count>)

**[L1]** <title> — `path/to/file.ext:line` — <brief description>

#### NITPICK (<count>)

**[N1]** <title> — `path/to/file.ext:line` — <brief description>

---

### Checklist

- [ ] All CRITICAL issues resolved
- [ ] All HIGH issues resolved
- [ ] Tests pass and cover new code paths
- [ ] No secrets or sensitive data exposed
- [ ] Breaking changes documented (if any)
```

### Step 6: Provide Verdict

End with one of:
- **APPROVE**: No CRITICAL or HIGH issues. Code is ready to merge.
- **REQUEST CHANGES**: CRITICAL or HIGH issues found that must be addressed.
- **NEEDS DISCUSSION**: Architectural or design concerns that need team input.

If there are zero findings across all categories, say so explicitly — a clean PR is worth celebrating.
