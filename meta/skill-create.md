# Skill Create

Create a new Claude Code slash command skill from a natural language description.

## Arguments

$ARGUMENTS - Expected format: `<category>/<skill-name> <description>`

Examples:
- `debug/trace-error Trace an error through the codebase to find its root cause`
- `gen/api-endpoint Generate a REST API endpoint with validation and tests`
- `review/security-scan Scan code for common security vulnerabilities`

## Instructions

### 1. Parse Arguments

Extract the following from `$ARGUMENTS`:

- **Skill path**: Everything before the first space (e.g., `debug/trace-error`)
  - **Category**: The part before the `/` (e.g., `debug`)
  - **Skill name**: The part after the `/` (e.g., `trace-error`)
- **Description**: Everything after the first space

If the arguments do not contain a `/` separating category and skill name, or if the description is missing, report the error clearly and stop:
```
Error: Invalid format. Expected: <category>/<skill-name> <description>
Example: debug/trace-error Trace an error through the codebase
```

### 2. Validate Skill Does Not Already Exist

Check if the file already exists at `~/.claude/commands/<category>/<skill-name>.md`.

- If it exists, report: `Skill '<category>/<skill-name>' already exists at <full-path>. Use a different name or delete the existing skill first.`
- Do NOT overwrite existing skills.

### 3. Create Category Directory

Ensure the directory `~/.claude/commands/<category>/` exists. Create it if it does not.

### 4. Generate Skill Content

Create the skill markdown file using this template structure. Adapt the content intelligently based on the description provided:

```markdown
# <Title Case of Skill Name>

<Description provided by user, expanded into 1-2 clear sentences.>

## Arguments

$ARGUMENTS - <Infer what arguments this skill would need based on the description. Be specific about format and provide examples.>

## Instructions

<Generate 3-7 numbered steps that logically implement the described skill. Each step should be:>
<- Actionable (starts with a verb)>
<- Specific (mentions tools, files, or patterns to use)>
<- Atomic (does one thing)>

### Error Handling

<List 2-4 common failure scenarios and how to handle them:>
<- Invalid input>
<- Missing files or dependencies>
<- Edge cases specific to this skill's domain>

### Output Format

<Describe what the skill should output when complete:>
<- Summary of actions taken>
<- Any files created or modified>
<- Next steps or recommendations>
```

When generating the instructions:
- Use the Bash tool for file system operations, git commands, and running scripts
- Use the Read tool to read files
- Use the Grep tool for searching codebases
- Use the Glob tool for finding files by pattern
- Use the Edit tool for modifying existing files
- Use the Write tool only for creating new files
- Reference specific tool names so the skill is actionable

### 5. Write the File

Write the generated content to `~/.claude/commands/<category>/<skill-name>.md`.

### 6. Confirm Creation

After writing, read the file back to confirm it was created correctly. Report:

```
Skill created successfully!

  Path: ~/.claude/commands/<category>/<skill-name>.md
  Invoke: /<category>/<skill-name>
  Category: <category>
  Description: <first line of description>

Tip: Test this skill with /meta/skill-test <category>/<skill-name>
```
