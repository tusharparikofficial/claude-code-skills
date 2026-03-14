# Skill Test

Validate and quality-check an existing Claude Code skill by analyzing its structure, completeness, and actionability.

## Arguments

$ARGUMENTS - The skill to test, in one of these formats:
- `<category>/<skill-name>` (e.g., `debug/trace-error`)
- Full path to the skill file (e.g., `~/.claude/commands/debug/trace-error.md`)

## Instructions

### 1. Resolve the Skill Path

- If `$ARGUMENTS` contains a full path (starts with `/` or `~`), use it directly.
- If `$ARGUMENTS` is in `<category>/<skill-name>` format, resolve to `~/.claude/commands/<category>/<skill-name>.md`.
- If the file does not exist, report the error and list similar skills found under `~/.claude/commands/` that might be what the user meant.

### 2. Read the Skill File

Use the Read tool to load the full content of the skill file.

### 3. Structural Validation

Check for the presence and quality of each section. Score each as PASS, WARN, or FAIL:

| Check | Criteria | Weight |
|-------|----------|--------|
| **Title** | Has a `# Title` as the first line | Required |
| **Description** | Has 1-2 sentences after the title explaining purpose | Required |
| **Arguments section** | Has `## Arguments` with `$ARGUMENTS` reference | Required |
| **Argument format** | Arguments section describes expected format with examples | Important |
| **Instructions section** | Has `## Instructions` with numbered steps | Required |
| **Step count** | Has 3-10 instruction steps (not too few, not too many) | Important |
| **Actionable steps** | Each step starts with a verb and is specific | Important |
| **Tool references** | Instructions mention specific tools (Bash, Read, Grep, Edit, Write, Glob) | Recommended |
| **Error handling** | Has error handling section or inline error guidance | Recommended |
| **Output format** | Describes what the skill produces | Recommended |
| **Examples** | Includes usage examples | Optional |

### 4. Content Quality Checks

Analyze the instruction text for these quality issues:

- **Vague instructions**: Steps like "do the thing" or "handle appropriately" without specifics. Flag these.
- **Missing tool references**: If an instruction implies reading a file but does not mention the Read tool, flag it.
- **Broken references**: If the skill references other skills (e.g., "use /meta/skill-create"), verify those skills exist.
- **Overly long steps**: Any single step longer than 5 lines should probably be split.
- **Hardcoded paths**: Paths that should be parameterized but are hardcoded (excluding `~/.claude/` paths which are standard).
- **Missing input validation**: If the skill accepts arguments but never validates them, flag it.

### 5. Dry-Run Analysis

Walk through the instructions mentally as if executing them:

- Can each step actually be performed with the available tools?
- Is the ordering logical? (e.g., do not reference data before it is gathered)
- Are there implicit dependencies between steps that should be explicit?
- Would the skill produce useful output if run on a typical codebase?

### 6. Generate Report

Produce a structured report:

```
## Skill Test Report: <skill-name>

**Path**: <full-path>
**Quality Score**: <X>/10

### Structure
- Title: <PASS|WARN|FAIL> - <detail>
- Description: <PASS|WARN|FAIL> - <detail>
- Arguments: <PASS|WARN|FAIL> - <detail>
- Instructions: <PASS|WARN|FAIL> - <detail>
- Error Handling: <PASS|WARN|FAIL> - <detail>
- Output Format: <PASS|WARN|FAIL> - <detail>

### Issues Found
1. [SEVERITY] <issue description>
2. [SEVERITY] <issue description>

### Suggestions for Improvement
1. <actionable suggestion>
2. <actionable suggestion>

### Missing Sections
- <section name>: <why it would help>
```

Severity levels: CRITICAL (skill will fail), HIGH (skill may produce wrong results), MEDIUM (skill works but could be better), LOW (cosmetic or nice-to-have).

### Scoring Guide

Calculate the score based on:
- 10: All sections present, actionable steps, error handling, examples, tool references
- 8-9: All required sections, mostly actionable, minor gaps
- 6-7: Required sections present but some steps are vague or missing error handling
- 4-5: Missing important sections or multiple vague steps
- 2-3: Missing required sections, largely unactionable
- 1: Barely a valid skill file

### Error Handling

- If the skill file is empty, report score 0 with message "Empty skill file."
- If the file is not markdown, report "File does not appear to be a valid skill markdown file."
- If the path does not resolve to any file, list available skills and suggest the closest match.
