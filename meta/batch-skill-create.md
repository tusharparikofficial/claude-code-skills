# Batch Skill Create

Create multiple Claude Code skills at once from a specification file, enabling rapid bootstrapping of entire skill categories.

## Arguments

$ARGUMENTS - Path to a specification file (markdown or YAML format).

Examples:
- `./skills-spec.md`
- `~/.claude/specs/debug-skills.yaml`
- `/home/user/my-skills.md`

## Instructions

### 1. Validate the Spec File Exists

Use the Read tool to load the file at the path provided in `$ARGUMENTS`.

If the file does not exist or cannot be read, report:
```
Error: Specification file not found at: <path>
Provide a valid path to a markdown or YAML specification file.
See the format section below for how to structure the file.
```

### 2. Detect and Parse the Spec Format

The spec file can be in one of two formats. Detect automatically based on file extension and content.

#### Markdown Format (.md)

Expected structure:

```markdown
# Skill Batch: <batch-name>

Optional batch description.

## <category>/<skill-name>

<description - one or two sentences>

### Instructions Outline
- Step 1 description
- Step 2 description
- Step 3 description

### Arguments
<expected arguments description>

---

## <category>/<skill-name>

<description>

### Instructions Outline
- Step 1 description
- Step 2 description

---

(repeat for each skill)
```

#### YAML Format (.yaml, .yml)

Expected structure:

```yaml
batch: <batch-name>
description: Optional batch description

skills:
  - name: <skill-name>
    category: <category>
    description: <description>
    arguments: <expected arguments description>
    instructions:
      - Step 1 description
      - Step 2 description
      - Step 3 description

  - name: <skill-name>
    category: <category>
    description: <description>
    arguments: <expected arguments description>
    instructions:
      - Step 1 description
      - Step 2 description
```

Parse the file and extract a list of skill definitions. Each definition must have at minimum:
- **name**: The skill name (required)
- **category**: The category/directory (required)
- **description**: What the skill does (required)
- **instructions**: List of instruction steps (optional but recommended)
- **arguments**: Expected arguments format (optional)

If parsing fails, report the specific parsing error with the line number if possible.

### 3. Validate All Skill Definitions

Before creating any skills, validate the entire batch:

For each skill definition:
- Verify `name` is a valid filename (alphanumeric, hyphens, underscores)
- Verify `category` is a valid directory name
- Check if `~/.claude/commands/<category>/<skill-name>.md` already exists

Collect all validation results and display a pre-creation summary:

```
## Batch Creation Plan: <batch-name>

| # | Category | Skill | Status |
|---|----------|-------|--------|
| 1 | <category> | <name> | WILL CREATE |
| 2 | <category> | <name> | SKIP (exists) |
| 3 | <category> | <name> | ERROR: <reason> |

To create: <X>
To skip: <Y>
Errors: <Z>
```

If there are errors (invalid names, missing required fields), report them all but still proceed with the valid skills.

### 4. Create Each Valid Skill

For each skill marked as "WILL CREATE":

#### 4a. Create Category Directory

Ensure `~/.claude/commands/<category>/` exists. Create it if not.

#### 4b. Generate Skill Content

Use the same template structure as `/meta/skill-create`:

```markdown
# <Title Case of Skill Name>

<Description from spec>

## Arguments

$ARGUMENTS - <Arguments description from spec, or generate a reasonable default based on the skill description>

## Instructions

<Generate numbered steps from the instructions outline provided in the spec. Expand each outline item into a full, actionable step that:>
<- Starts with a verb>
<- References specific tools (Bash, Read, Grep, Edit, Write, Glob) where appropriate>
<- Is specific enough to be followed without ambiguity>

<If no instructions outline was provided, generate 3-5 reasonable steps based on the description.>

### Error Handling

<Generate 2-3 error handling scenarios relevant to this skill's purpose>

### Output Format

<Generate appropriate output format based on the skill's purpose>
```

#### 4c. Write the File

Write to `~/.claude/commands/<category>/<skill-name>.md`.

### 5. Generate Final Report

After processing all skills, produce a summary report:

```
## Batch Creation Report: <batch-name>

### Results

| # | Category | Skill | Result | Path |
|---|----------|-------|--------|------|
| 1 | <category> | <name> | CREATED | ~/.claude/commands/<category>/<name>.md |
| 2 | <category> | <name> | SKIPPED | (already exists) |
| 3 | <category> | <name> | FAILED | <error reason> |

### Summary
- Created: <X> skills
- Skipped: <Y> skills (already existed)
- Failed: <Z> skills
- Total in spec: <N> skills

### Next Steps
- Test new skills: /meta/skill-test <category>/<skill-name>
- Browse all skills: /meta/skill-catalog
- Chain skills together: /meta/skill-chain <chain-name> <skill1> -> <skill2>
```

### Error Handling

- **Invalid spec format**: If the file is neither valid markdown nor YAML spec format, provide a clear error with the expected format for both types.
- **Partial failure**: If some skills fail to create, still create the valid ones. Report all failures at the end.
- **Permission errors**: If a directory cannot be created, report the permission error and skip that skill.
- **Empty spec file**: "Specification file is empty. See expected format above."
- **No valid skills in spec**: "No valid skill definitions found in the specification file. Each skill must have at minimum: name, category, and description."

### Example Spec File (Markdown)

For reference, here is a complete example specification:

```markdown
# Skill Batch: Debug Tools

A collection of debugging and diagnostic skills.

## debug/trace-error

Trace an error message through the codebase to find its origin, propagation path, and root cause.

### Arguments
An error message or error code to trace

### Instructions Outline
- Search for the exact error message in the codebase
- Identify where the error is thrown/raised
- Trace the call chain backwards to find the root cause
- Report the full error propagation path

---

## debug/log-analyzer

Analyze application log files to find patterns, anomalies, and correlations.

### Arguments
Path to a log file or directory containing logs

### Instructions Outline
- Read the log file(s)
- Identify error patterns and frequency
- Find correlated events
- Generate a summary report with actionable insights

---
```
