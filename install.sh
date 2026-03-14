#!/usr/bin/env bash
set -euo pipefail

# Claude Code Skills Installer
# Installs all skills to ~/.claude/commands/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude/commands"

# Skill directories to install
SKILL_DIRS=(
  agency ai data db debug devops ecom gen
  meta mkt perf review scaffold sec seo
  test ui workflow
)

echo "Claude Code Skills Installer"
echo "============================"
echo ""
echo "Source: $SCRIPT_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Create target if needed
mkdir -p "$TARGET_DIR"

installed=0
skipped=0
updated=0

for dir in "${SKILL_DIRS[@]}"; do
  src="$SCRIPT_DIR/$dir"
  [ ! -d "$src" ] && continue

  mkdir -p "$TARGET_DIR/$dir"

  for file in "$src"/*.md; do
    [ ! -f "$file" ] && continue
    filename=$(basename "$file")
    target="$TARGET_DIR/$dir/$filename"

    if [ ! -f "$target" ]; then
      cp "$file" "$target"
      ((installed++))
    elif ! diff -q "$file" "$target" > /dev/null 2>&1; then
      cp "$file" "$target"
      ((updated++))
    else
      ((skipped++))
    fi
  done
done

# Install root-level skills (yt-search, yt-info, etc.)
for file in "$SCRIPT_DIR"/*.md; do
  [ ! -f "$file" ] && continue
  filename=$(basename "$file")
  # Skip catalog files
  [[ "$filename" == SKILLS-CATALOG* ]] && continue
  target="$TARGET_DIR/$filename"

  if [ ! -f "$target" ]; then
    cp "$file" "$target"
    ((installed++))
  elif ! diff -q "$file" "$target" > /dev/null 2>&1; then
    cp "$file" "$target"
    ((updated++))
  else
    ((skipped++))
  fi
done

total=$((installed + updated + skipped))

echo "Done!"
echo ""
echo "  Installed: $installed new skills"
echo "  Updated:   $updated existing skills"
echo "  Skipped:   $skipped unchanged skills"
echo "  Total:     $total skills"
echo ""
echo "Skills are now available in Claude Code via /category:skill-name"
echo "Run /meta:skill-catalog to see all available skills."
