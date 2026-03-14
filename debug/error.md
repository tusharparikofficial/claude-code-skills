# Error Analyzer

Analyze an error message or stack trace, identify the root cause, and provide a specific fix.

## Arguments

$ARGUMENTS - An inline error message/stack trace OR a file path to an error log

## Instructions

Follow these steps precisely to diagnose and fix the error.

### Step 1: Determine Input Type

Check whether `$ARGUMENTS` is a file path or an inline error message:

- If it looks like a file path (starts with `/`, `./`, `~`, or ends with `.log`, `.txt`, `.err`), read the file using the Read tool to get the error content.
- If it is an inline error message, use the text directly.

Store the full error text for analysis.

### Step 2: Classify the Error Type

Identify which category the error falls into:

| Category | Indicators |
|----------|-----------|
| **Syntax Error** | `SyntaxError`, `ParseError`, `unexpected token`, `invalid syntax` |
| **Type Error** | `TypeError`, `type mismatch`, `cannot read property of undefined/null`, `NoneType has no attribute` |
| **Reference Error** | `ReferenceError`, `NameError`, `undefined variable`, `not defined` |
| **Import/Module Error** | `ModuleNotFoundError`, `ImportError`, `Cannot find module`, `No module named` |
| **Network Error** | `ECONNREFUSED`, `ETIMEDOUT`, `fetch failed`, `connection refused`, `timeout`, `CORS` |
| **Permission Error** | `EACCES`, `PermissionError`, `permission denied`, `EPERM` |
| **Memory Error** | `heap out of memory`, `MemoryError`, `OOM`, `allocation failed` |
| **HTTP Error** | `404`, `500`, `403`, `401`, `502`, `503` status codes |
| **Database Error** | `relation does not exist`, `duplicate key`, `deadlock`, `connection pool` |
| **Runtime Error** | Everything else - `RuntimeError`, `panic`, segfault, assertion failure |

Report the classification clearly.

### Step 3: Extract Location from Stack Trace

Parse the stack trace to find file paths and line numbers. Handle multiple formats:

- **Node.js/JavaScript**: `at functionName (file.js:line:col)` or `file.js:line:col`
- **Python**: `File "path.py", line N, in function`
- **Go**: `file.go:line` in goroutine traces
- **Rust**: `file.rs:line:col`
- **Java**: `at package.Class.method(File.java:line)`

Extract the **first application code location** (skip node_modules, site-packages, standard library frames).

If no stack trace is present, search the codebase for the error message text or relevant identifiers using Grep.

### Step 4: Read Source Code at Error Location

Use the Read tool to read the file identified in Step 3. Focus on the area around the error line (30 lines before and after for context).

If the file is not in the current project, search the project for related files using Glob and Grep.

### Step 5: Identify Root Cause

Based on the error type and source code, determine the root cause. Common root causes by category:

**TypeError / ReferenceError:**
- Accessing property on `undefined` or `null` - missing null check or optional chaining
- Wrong variable name or scope issue
- Incorrect function signature or argument count
- Missing return statement

**Import/Module Error:**
- Package not installed (check package.json, requirements.txt, go.mod)
- Wrong import path (relative vs absolute, missing file extension)
- Circular dependency
- Case sensitivity in file paths

**Network Error:**
- Service not running on expected port
- Wrong URL or hostname
- Missing CORS headers on server
- Expired or invalid auth token
- Firewall or proxy blocking

**Permission Error:**
- File owned by root, process running as user
- Missing execute permission on script
- Docker volume permission mismatch

**Memory Error:**
- Unbounded data loading
- Missing pagination or streaming
- Leak in event listeners or intervals

### Step 6: Search for Similar Patterns

Use Grep to search the codebase for similar patterns that might have the same issue. This helps identify:
- Whether the fix needs to be applied in multiple places
- Whether there is existing code that handles this correctly (to use as a reference pattern)
- Related configuration that might need updating

### Step 7: Apply the Fix

Use the Edit tool to apply the specific fix to the identified file. The fix should:

1. Address the root cause, not just suppress the symptom
2. Follow existing code style and patterns in the project
3. Handle edge cases (null checks, error boundaries, fallbacks)
4. Not introduce new issues

If the fix requires installing a dependency, run the appropriate install command:
- `npm install <pkg>` / `yarn add <pkg>` / `pnpm add <pkg>`
- `pip install <pkg>`
- `go get <pkg>`
- `cargo add <pkg>`

### Step 8: Report

Provide a clear summary:

```
## Error Analysis

**Error Type**: <category>
**Location**: <file>:<line>
**Root Cause**: <1-2 sentence explanation>

## Fix Applied

**File**: <file path>
**Change**: <description of what was changed and why>

## Similar Patterns

<list any other locations in the codebase that may need the same fix>
```

If the error cannot be fixed automatically (e.g., requires infrastructure changes, missing credentials, or external service issues), clearly explain what needs to be done manually and why.
