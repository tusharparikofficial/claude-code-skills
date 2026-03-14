#!/usr/bin/env bash

SRC_DIR="$HOME/.claude/commands"
DEST_DIR="$HOME/.openclaw/skills"

created=0

for file in "$SRC_DIR"/*/*.md; do
  [ ! -f "$file" ] && continue

  dir=$(basename "$(dirname "$file")")
  name=$(basename "$file" .md)
  skill_name="${dir}-${name}"
  skill_dir="$DEST_DIR/$skill_name"

  # Get title
  title=$(grep -m1 '^# ' "$file" | sed 's/^# //')
  if [ -z "$title" ]; then
    title="$name"
  fi

  # Get description (first non-empty, non-heading line after title)
  desc=$(awk '/^# /{found=1; next} found && /^[^#\[]/ && NF{print; exit}' "$file")
  if [ -z "$desc" ]; then
    desc="$title - ${dir}/${name} skill"
  fi
  # Trim to 300 chars, single line
  desc=$(echo "$desc" | tr '\n' ' ' | cut -c1-300)

  mkdir -p "$skill_dir"

  # Write frontmatter
  printf -- '---\nname: %s\ndescription: %s\n---\n\n' "$skill_name" "$desc" > "$skill_dir/SKILL.md"

  # Append body
  cat "$file" >> "$skill_dir/SKILL.md"

  created=$((created + 1))
done

echo "Done! Created $created OpenClaw skills in $DEST_DIR"
