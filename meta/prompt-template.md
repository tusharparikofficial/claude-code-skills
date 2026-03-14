# Prompt Template

Create, manage, and apply reusable prompt templates for common development patterns.

## Arguments

$ARGUMENTS - One of the following:

- `create <template-name> <context>` - Create a new template with the given context
- `apply <template-name> <variable=value> [variable=value ...]` - Apply a template with variable substitution
- `list` - List all available templates
- `show <template-name>` - Display a template's content
- `delete <template-name>` - Remove a template

Examples:
- `create api-endpoint REST endpoint with auth, validation, and error handling`
- `apply api-endpoint language=typescript framework=express resource=users`
- `list`
- `show code-review`

## Instructions

### 1. Parse the Command

Extract the sub-command from the first word of `$ARGUMENTS`:
- `create`, `apply`, `list`, `show`, or `delete`

If the sub-command is not recognized, report:
```
Unknown command: <word>. Available commands: create, apply, list, show, delete
```

### 2. Ensure Templates Directory

Ensure `~/.claude/templates/` exists. Create it if it does not.

### 3. Execute the Sub-Command

---

#### Sub-Command: `create`

**Parse**: Extract `<template-name>` (second word) and `<context>` (remaining words).

**Generate the template** based on the context. Use the following built-in template types as guidance for structure, but adapt freely based on the context:

**code-review**: Template for reviewing code changes
```
# Code Review: {{component_name}}

## Language/Framework: {{language}} / {{framework}}

## Review Checklist
- [ ] Code readability and naming conventions
- [ ] Error handling completeness
- [ ] Input validation at boundaries
- [ ] No hardcoded secrets or credentials
- [ ] Immutable data patterns used
- [ ] Functions under 50 lines
- [ ] Test coverage adequate

## Focus Areas
{{focus_areas}}

## Instructions
1. Read the changed files
2. Analyze against the checklist above
3. Report findings by severity (CRITICAL, HIGH, MEDIUM, LOW)
4. Suggest specific fixes for each issue
```

**bug-fix**: Template for diagnosing and fixing bugs
```
# Bug Fix: {{bug_description}}

## Reproduction
{{repro_steps}}

## Environment: {{language}} / {{framework}}

## Instructions
1. Reproduce the issue by examining the code path described
2. Search the codebase for related patterns using Grep
3. Identify the root cause
4. Write a failing test that captures the bug
5. Implement the fix (minimal change)
6. Verify the test passes
7. Check for similar bugs elsewhere in the codebase
```

**feature-implement**: Template for implementing new features
```
# Feature: {{feature_name}}

## Context: {{language}} / {{framework}}
## Scope: {{scope_description}}

## Instructions
1. Research existing patterns in the codebase
2. Plan the implementation (identify files to create/modify)
3. Write tests first (TDD - RED phase)
4. Implement the feature (GREEN phase)
5. Refactor for clarity (IMPROVE phase)
6. Verify all tests pass and coverage is adequate
7. Run code review checks
```

**refactor**: Template for refactoring code
```
# Refactor: {{component_name}}

## Goal: {{refactor_goal}}
## Constraints: {{constraints}}

## Instructions
1. Read and understand the current implementation
2. Identify code smells and improvement opportunities
3. Ensure existing tests pass before changes
4. Apply refactoring in small, verified steps
5. Run tests after each step
6. Verify no behavior changes (same inputs produce same outputs)
```

**test-write**: Template for writing tests
```
# Tests: {{component_name}}

## Type: {{test_type}} (unit | integration | e2e)
## Framework: {{test_framework}}

## Instructions
1. Read the component/module under test
2. Identify all public functions and their edge cases
3. Write test cases covering:
   - Happy path
   - Error cases
   - Edge cases (empty input, null, boundary values)
   - Integration points
4. Verify coverage meets 80% threshold
```

**Variable syntax**: Use `{{variable_name}}` for placeholders. Variables should be descriptive and snake_case.

**Write the template** to `~/.claude/templates/<template-name>.md`.

**Confirm**:
```
Template created: <template-name>
  Path: ~/.claude/templates/<template-name>.md
  Variables: {{var1}}, {{var2}}, ...
  Apply with: /meta/prompt-template apply <template-name> var1=value var2=value
```

---

#### Sub-Command: `apply`

**Parse**: Extract `<template-name>` (second word) and key=value pairs from remaining words.

**Read** the template from `~/.claude/templates/<template-name>.md`.

**Substitute** all `{{variable}}` placeholders with the provided values.

**Report** any variables in the template that were not provided (leave them as `{{variable}}` with a warning).

**Output** the fully rendered template content.

---

#### Sub-Command: `list`

**Scan** `~/.claude/templates/` for all `.md` files.

**Display** each template with its name and the first line of content:
```
## Available Templates

| Template | Description |
|----------|-------------|
| <name> | <first heading or line> |
| ... | ... |

Total: <N> templates
```

If no templates exist, report: "No templates found. Create one with: /meta/prompt-template create <name> <context>"

---

#### Sub-Command: `show`

**Read** and display the full content of `~/.claude/templates/<template-name>.md`.

If the template does not exist, report the error and list available templates.

---

#### Sub-Command: `delete`

**Check** if `~/.claude/templates/<template-name>.md` exists.

**Delete** the file using the Bash tool.

**Confirm**: "Template '<template-name>' deleted."

### Error Handling

- If template already exists on `create`, ask: "Template '<name>' already exists. The existing template will NOT be overwritten. Use `delete` first, then `create` again."
- If template not found on `apply`/`show`/`delete`, list available templates as suggestions.
- If no variable values provided on `apply`, show the template with all variables highlighted and list what needs to be provided.
