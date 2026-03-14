#!/usr/bin/env bash
set -euo pipefail

# Claude Code Skills Uninstaller
# Removes all installed skill directories from ~/.claude/commands/

TARGET_DIR="$HOME/.claude/commands"

SKILL_DIRS=(
  agency ai data db debug devops ecom gen
  meta mkt perf review scaffold sec seo
  test ui workflow
)

echo "Claude Code Skills Uninstaller"
echo "=============================="
echo ""

read -p "This will remove all skill directories from $TARGET_DIR. Continue? [y/N] " confirm
[[ "$confirm" != [yY] ]] && echo "Aborted." && exit 0

removed=0
for dir in "${SKILL_DIRS[@]}"; do
  target="$TARGET_DIR/$dir"
  if [ -d "$target" ]; then
    rm -rf "$target"
    echo "  Removed: $dir/"
    ((removed++))
  fi
done

echo ""
echo "Removed $removed skill directories."
