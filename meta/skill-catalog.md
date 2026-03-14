# Skill Catalog

List all available Claude Code slash command skills, grouped by category, with descriptions.

## Arguments

$ARGUMENTS - Optional filter. Can be:
- Empty (lists all skills)
- A category name (e.g., `meta`, `debug`, `gen`) to show only that category
- A search term (e.g., `test`, `security`) to filter skills by name or description

## Instructions

### 1. Scan for Skills

Use the Glob tool to find all `.md` files recursively under `~/.claude/commands/`:
- Pattern: `**/*.md`
- Path: `~/.claude/commands/`

### 2. Read Each Skill File

For every `.md` file found, use the Read tool to extract:
- **Title**: The first `# ` heading in the file
- **Description**: The first non-empty line after the title (the brief description paragraph)
- **Category**: The subdirectory name (e.g., `meta`, `debug`). Files directly in `~/.claude/commands/` have category `root`.
- **Skill name**: The filename without `.md` extension
- **Invoke command**: `/<category>/<skill-name>` or `/<skill-name>` for root skills

Read files in parallel where possible for performance.

### 3. Apply Filter (if provided)

If `$ARGUMENTS` is not empty:
- First, check if it matches a category name exactly. If so, show only skills in that category.
- Otherwise, treat it as a search term and filter skills where the term appears in the skill name, title, or description (case-insensitive).

### 4. Group and Sort

- Group skills by category
- Sort categories alphabetically
- Sort skills alphabetically within each category

### 5. Display Results

Output the catalog in this format:

```
# Skill Catalog

## <Category> (<count> skills)

| Skill | Command | Description |
|-------|---------|-------------|
| <Title> | /<category>/<name> | <First line of description> |
| ... | ... | ... |

## <Category> (<count> skills)

| Skill | Command | Description |
|-------|---------|-------------|
| ... | ... | ... |

---
Total: <N> skills across <M> categories
```

If a filter was applied, add: `Filter: "<filter-term>" | Showing <X> of <Total> skills`

### 6. Handle Edge Cases

- If no skills are found at all, report: "No skills found in ~/.claude/commands/. Create your first skill with /meta/skill-create."
- If a filter matches nothing, report: "No skills matching '<filter>' found. Available categories: <list-categories>."
- If a skill file is malformed (no title), show the filename with description "Malformed skill file - missing title".

### Output Format

The final output should be a clean, readable table that the user can quickly scan to find the skill they need. Keep descriptions to one line (truncate at 80 characters if longer).
