# Staged Diff Review

Review staged git changes before committing. Catches debug code, secrets, missing error handling, and other pre-commit issues.

## Arguments

No arguments required. Reviews the currently staged diff (`git diff --staged`).

## Instructions

### Step 1: Gather Staged Changes

Run the following commands in parallel using the Bash tool:

1. `git diff --staged` — the full staged diff
2. `git diff --staged --stat` — summary of files changed
3. `git diff --staged --name-only` — list of changed files

If the staged diff is empty, inform the user that there are no staged changes to review. Suggest they stage changes with `git add` first, then stop.

### Step 2: Check for Debug and Development Artifacts

Scan the staged diff (added lines only, lines starting with `+`) for:

**Debug Code**
- `console.log`, `console.debug`, `console.warn`, `console.error` (unless in a logger module)
- `print(` statements in non-Python-script files, or debug prints in Python
- `debugger` statements
- `binding.pry`, `byebug`, `pdb.set_trace()`, `breakpoint()`
- `var_dump`, `dd(`, `dump(`
- `System.out.println` in Java (unless in a logger)
- `fmt.Println` used for debugging in Go (check context)
- `log.Println` used for temporary debugging in Go

**Hardcoded Secrets and API Keys**
Scan for patterns matching:
- API keys: `(api[_-]?key|apikey)\s*[:=]\s*['"][a-zA-Z0-9]{16,}['"]` (case insensitive)
- Passwords: `(password|passwd|pwd)\s*[:=]\s*['"][^'"]+['"]` (case insensitive)
- Tokens: `(token|secret|auth)\s*[:=]\s*['"][a-zA-Z0-9_\-\.]{16,}['"]` (case insensitive)
- AWS keys: `AKIA[0-9A-Z]{16}`
- Private keys: `-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----`
- Connection strings with credentials: `://[^:]+:[^@]+@`
- Generic secrets: `(ghp_|sk-|sk_live_|pk_live_|xoxb-|xoxp-)` prefixed strings

**TODO/FIXME Without Tracking**
- `TODO` or `FIXME` comments that do not reference a ticket/issue number
- Flag these as informational — they are acceptable if intentional but should have tracking

**Commented-Out Code**
- Blocks of commented-out code (3+ consecutive commented lines that look like code, not documentation)
- Single commented-out function calls or statements

### Step 3: Check for Code Quality Issues

**Missing Error Handling**
- `catch` blocks that are empty or only log without re-throwing or handling
- Promises without `.catch()` or missing `try/catch` around `await`
- Functions that call APIs or I/O without error handling
- Go functions that ignore error returns: `result, _ := someFunc()`

**Type Safety Issues**
- New `any` types in TypeScript
- Type assertions without validation (`as SomeType` without checks)
- Implicit `any` from missing type annotations
- Unsafe type coercions

**Formatting and Consistency**
- Mixed indentation (tabs vs spaces) within the same file
- Trailing whitespace on added lines
- Missing trailing newline at end of file
- Inconsistent naming conventions within the diff (camelCase mixed with snake_case in the same file)

**Missing or Wrong Test Updates**
- If source files are modified but corresponding test files are not staged, flag as a warning
- If test files are modified, check that assertions are meaningful (not just `expect(true).toBe(true)`)
- New exported functions without corresponding test coverage

### Step 4: Check for Structural Issues

- Files that grew beyond 500 lines (check the file size after applying the diff)
- Functions added that exceed 50 lines
- Deeply nested code (>4 levels of indentation in added lines)
- Large files added to git that may not belong (binaries, generated files, node_modules, .env files)

### Step 5: Assess and Report

Format the output as:

```
## Staged Diff Review

**Files Changed**: <count> (+<additions> -<deletions>)
**Verdict**: PASS / FAIL / WARN

---

### Issues Found

#### BLOCKING (must fix before commit)

- [ ] `file.ext:line` — <issue description>
  **Fix**: <specific suggestion>

#### WARNINGS (should fix)

- [ ] `file.ext:line` — <issue description>
  **Suggestion**: <what to do>

#### INFO (for awareness)

- `file.ext:line` — <note>

---

### Pre-Commit Checklist

- [x/✗] No debug code
- [x/✗] No hardcoded secrets
- [x/✗] No commented-out code blocks
- [x/✗] Error handling present
- [x/✗] Type safety maintained
- [x/✗] Tests updated for changed code
- [x/✗] Formatting consistent
```

### Step 6: Final Verdict

- **PASS**: No blocking issues. Safe to commit.
- **WARN**: No blocking issues, but warnings should be reviewed. Provide the option to proceed or fix first.
- **FAIL**: Blocking issues found. List what must be fixed before committing.

If the verdict is FAIL, offer to fix the blocking issues automatically where possible (remove debug statements, fix formatting). Ask the user before making any changes.
