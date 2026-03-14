# Skill Chain

Chain multiple Claude Code skills into a single sequential workflow, creating a reusable composite skill.

## Arguments

$ARGUMENTS - Expected format: `<chain-name> <skill1> -> <skill2> -> <skill3> [-> ...]`

The chain name becomes the filename. Each skill is referenced by its `<category>/<skill-name>` path.

Examples:
- `scaffold-and-test gen/crud -> test/unit -> review/security-scan`
- `full-review review/code-review -> sec/audit -> test/unit`
- `new-feature meta/prompt-template -> gen/api-endpoint -> test/unit -> review/code-review`

Special argument:
- `list` - Show all existing chains

## Instructions

### 1. Handle List Command

If `$ARGUMENTS` is `list`:
- Use the Glob tool to find all `.md` files in `~/.claude/commands/meta/chains/`
- For each file, read the title and description
- Display as a table:
  ```
  ## Existing Chains

  | Chain | Steps | Description |
  |-------|-------|-------------|
  | <name> | skill1 -> skill2 -> skill3 | <description> |
  ```
- If no chains exist, report: "No chains found. Create one with: /meta/skill-chain <chain-name> <skill1> -> <skill2> -> <skill3>"
- Stop here.

### 2. Parse Arguments

Extract from `$ARGUMENTS`:
- **Chain name**: The first word (before the first space)
- **Skill references**: Split the remaining string by ` -> ` to get an ordered list of skill paths

Validate:
- Chain name must be a valid filename (alphanumeric, hyphens, underscores)
- At least 2 skills must be specified (a chain of 1 is just the skill itself)
- If parsing fails, show the expected format with an example

### 3. Validate Each Skill Exists

For each skill reference in the chain:
- Resolve the path to `~/.claude/commands/<skill-ref>.md`
- Use the Glob tool or Bash to check if the file exists
- Collect any missing skills

If any skills are missing, report all of them at once:
```
Cannot create chain. The following skills were not found:
  - <skill-ref-1> (expected at ~/.claude/commands/<skill-ref-1>.md)
  - <skill-ref-2> (expected at ~/.claude/commands/<skill-ref-2>.md)

Available skills can be listed with: /meta/skill-catalog
```
Do NOT create the chain if any skill is missing.

### 4. Check Chain Does Not Already Exist

Check if `~/.claude/commands/meta/chains/<chain-name>.md` already exists.
- If it does, report: "Chain '<chain-name>' already exists at ~/.claude/commands/meta/chains/<chain-name>.md. Delete it first or choose a different name."

### 5. Ensure Chains Directory

Ensure `~/.claude/commands/meta/chains/` exists using the Bash tool.

### 6. Read Skill Descriptions

For each skill in the chain, read its file and extract the title and first line of description. This information will be included in the chain skill file for documentation.

### 7. Generate Chain Skill File

Create the chain skill file with the following structure:

```markdown
# Chain: <Chain Name in Title Case>

Composite workflow that sequentially executes: <skill1> -> <skill2> -> <skill3>

## Arguments

$ARGUMENTS - Arguments are passed to the first skill in the chain. Subsequent skills receive context from the previous step.

## Chain Steps

| Step | Skill | Description |
|------|-------|-------------|
| 1 | /<skill1> | <skill1 description> |
| 2 | /<skill2> | <skill2 description> |
| 3 | /<skill3> | <skill3 description> |

## Instructions

Execute the following skills in order. After each step, carry forward the context (files modified, results produced, errors encountered) to the next step.

### Step 1: <Skill 1 Title>

Invoke the skill `/<skill1>` with the provided arguments.

Pass `$ARGUMENTS` as the input to this skill.

Capture:
- Files created or modified
- Key outputs or findings
- Any errors or warnings

### Step 2: <Skill 2 Title>

Invoke the skill `/<skill2>`.

Use the context from Step 1 as input:
- Reference files created/modified in Step 1
- Build upon findings from Step 1

Capture:
- Files created or modified
- Key outputs or findings
- Any errors or warnings

### Step N: <Skill N Title>

(Repeat pattern for each skill in the chain)

### Chain Summary

After all steps complete, provide a summary:

```
## Chain Execution Summary: <Chain Name>

| Step | Skill | Status | Key Output |
|------|-------|--------|------------|
| 1 | /<skill1> | PASS/FAIL | <summary> |
| 2 | /<skill2> | PASS/FAIL | <summary> |
| 3 | /<skill3> | PASS/FAIL | <summary> |

Total steps: <N>
Passed: <X>
Failed: <Y>
```

### Error Handling

- If any step fails, report the failure but continue to the next step unless the failure is critical (e.g., a file that subsequent steps depend on was not created).
- At the end, clearly indicate which steps failed and why.
- Suggest running individual skills for debugging: `/<failed-skill> <args>`
```

Adapt the step sections to use the actual skill names and descriptions gathered in step 6.

### 8. Write the Chain File

Write the generated content to `~/.claude/commands/meta/chains/<chain-name>.md`.

### 9. Confirm Creation

Read the file back to verify, then report:

```
Chain created successfully!

  Name: <chain-name>
  Path: ~/.claude/commands/meta/chains/<chain-name>.md
  Invoke: /meta/chains/<chain-name>
  Steps: <skill1> -> <skill2> -> <skill3>
  Total steps: <N>

Run the chain with: /meta/chains/<chain-name> <arguments-for-first-skill>
```

### Error Handling

- Invalid chain name (special characters): "Chain name must contain only letters, numbers, hyphens, and underscores."
- Single skill provided: "A chain must contain at least 2 skills. For a single skill, invoke it directly: /<skill>"
- Missing `->` separator: "Skills must be separated by ' -> '. Example: gen/crud -> test/unit -> review/code-review"
