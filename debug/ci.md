# CI/CD Pipeline Debugger

Diagnose CI/CD pipeline failures using GitHub Actions, identify root causes, and suggest or apply fixes.

## Arguments

$ARGUMENTS - A GitHub Actions run ID, a PR number (e.g., `#123`), or leave empty to use the latest failed run

## Instructions

Follow these steps to diagnose and fix CI/CD pipeline failures.

### Step 1: Identify the Failed Run

Determine the target run based on `$ARGUMENTS`:

**If a run ID is provided** (numeric value without `#`):
```bash
gh run view <run-id> 2>&1
```

**If a PR number is provided** (starts with `#` or contains `pr`):
```bash
gh pr checks <pr-number> 2>&1
```
Then find the failed check and get its run ID:
```bash
gh run list --branch <pr-branch> --limit 5 2>&1
```

**If no arguments provided**, get the latest failed run:
```bash
gh run list --status failure --limit 5 2>&1
```
Use the most recent failed run.

If `gh` is not available or not authenticated, report that GitHub CLI is required and provide setup instructions.

### Step 2: Get Failure Details

Fetch the detailed failure information:

```bash
gh run view <run-id> --log-failed 2>&1
```

Also get the run summary for context:

```bash
gh run view <run-id> 2>&1
```

Extract from the output:
- **Workflow name**: which workflow file ran
- **Trigger**: push, pull_request, schedule, workflow_dispatch
- **Branch**: which branch triggered the run
- **Failed job(s)**: which job(s) failed
- **Failed step(s)**: which step(s) within the job failed
- **Error message**: the actual error text
- **Duration**: how long the run took (unusually long may indicate timeout)

### Step 3: Classify the Failure

Categorize the failure into one of these types:

| Category | Indicators | Priority |
|----------|-----------|----------|
| **Build Error** | Compilation failure, type error, syntax error, missing import | Fix code |
| **Test Failure** | Test assertion failed, test timeout, test error | Fix test or code |
| **Lint/Format Error** | ESLint, Prettier, Black, gofmt, Clippy violations | Fix formatting |
| **Dependency Error** | Package install failure, version conflict, missing package | Fix deps |
| **Environment Error** | Missing secret, wrong Node/Python/Go version, missing tool | Fix CI config |
| **Infrastructure Error** | Runner out of disk, network timeout downloading deps, GitHub outage | Retry or fix config |
| **Flaky Test** | Passes sometimes, fails sometimes (check history) | Fix test reliability |
| **Timeout** | Job exceeded time limit | Optimize or increase timeout |
| **Permission Error** | Cannot access resource, token expired, insufficient permissions | Fix permissions |

### Step 4: Check for Flakiness

If the failure is a test failure, check if it might be flaky:

```bash
gh run list --workflow <workflow-name> --limit 10 2>&1
```

Look at the recent history:
- If the same test passes and fails intermittently, it is likely flaky
- If it started failing consistently after a specific commit, it is a real regression
- If it only fails on certain branches, it may be a merge conflict issue

For flaky tests, note the pattern (timing-dependent, order-dependent, environment-dependent).

### Step 5: Read the CI Configuration

Read the workflow file to understand the CI setup:

Use Glob to find workflow files:
```
.github/workflows/*.yml
.github/workflows/*.yaml
```

Read the relevant workflow file using the Read tool. Check for:

- **Runner**: `ubuntu-latest`, `macos-latest`, custom runner
- **Matrix**: multiple versions/platforms being tested
- **Steps**: the sequence of commands being run
- **Environment variables**: secrets, env vars, build args
- **Caching**: whether dependency caching is configured
- **Timeouts**: job and step timeout settings
- **Concurrency**: whether concurrent runs are managed

### Step 6: Diagnose Root Cause

Based on the failure category, perform targeted diagnosis:

#### Build/Lint/Type Errors:
- Read the failing file at the reported line number using the Read tool
- Check if the error exists in the local codebase (may have been fixed locally but not pushed)
- Verify the build command matches what runs locally

#### Test Failures:
- Read the failing test file
- Read the source code being tested
- Check if the test expects specific environment variables or fixtures
- Check if there are timing dependencies (sleep, setTimeout, race conditions)

#### Dependency Errors:
- Read `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `go.sum`, `requirements.txt`, `Cargo.lock`
- Check for version conflicts or yanked packages
- Check if the CI cache might be stale

#### Environment Errors:
- Check that required secrets are referenced correctly: `${{ secrets.NAME }}`
- Check the runtime version matches what is expected (Node 18 vs 20, Python 3.11 vs 3.12)
- Check if required tools are installed in the CI step

#### Flaky Tests:
- Look for race conditions, hardcoded ports, time-dependent assertions
- Check for missing test isolation (shared state between tests)
- Check for external service dependencies without mocks

### Step 7: Provide Fix

Based on the diagnosis, apply fixes or provide specific guidance:

**For code issues** (build errors, test failures, lint errors):
- Use the Edit tool to fix the source file
- Verify the fix works locally if possible (run the failing command)

**For CI configuration issues:**
- Use the Edit tool to modify the workflow YAML file
- Common fixes:
  - Pin runtime versions: `node-version: '20'` instead of `node-version: 'latest'`
  - Add missing secrets to the workflow
  - Fix caching keys
  - Add timeout limits
  - Add retry logic for flaky steps

**For dependency issues:**
- Update lockfile
- Pin problematic dependency versions
- Clear CI cache by changing cache key

**For flaky tests:**
- Add proper test isolation
- Replace time-dependent assertions with polling/retry
- Mock external services
- Add explicit waits instead of arbitrary sleeps

### Step 8: Report

```
## CI/CD Failure Analysis

**Workflow**: <workflow name>
**Run**: <run-id> (<link if available>)
**Branch**: <branch name>
**Trigger**: <push/PR/schedule>

### Failed Step

**Job**: <job name>
**Step**: <step name>
**Category**: <Build Error / Test Failure / etc.>

### Error Message

```
<the actual error output, trimmed to relevant lines>
```

### Root Cause

<1-3 sentence explanation of why this failed>

### Flakiness Assessment

- **Is this flaky?**: Yes/No
- **Evidence**: <history of pass/fail pattern>
- **If flaky, pattern**: <timing / ordering / environment dependent>

### Fix

**Confidence**: HIGH / MEDIUM / LOW

**Changes Made**:
| File | Change |
|------|--------|
| <file> | <description> |

**Changes Suggested** (if manual steps needed):
1. <step>
2. <step>

### Prevention

<suggestion to prevent this type of failure in the future, e.g., add pre-commit hook, pin versions, add test timeout>
```

If the fix was applied to code, remind the user to commit and push to trigger a new CI run. If the fix requires CI config changes that cannot be tested locally, note that the fix will be verified on the next run.
