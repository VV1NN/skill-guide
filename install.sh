#!/bin/bash
# skill-guide installer
# Installs the skill-guide skill and /guide command into your Claude Code environment.

set -e

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills/skill-guide"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== skill-guide installer ==="
echo ""

# Create directories
mkdir -p "$SKILLS_DIR"
mkdir -p "$COMMANDS_DIR"

# Copy skill
cp "$SCRIPT_DIR/SKILL.md" "$SKILLS_DIR/SKILL.md"
echo "[OK] Installed skill: $SKILLS_DIR/SKILL.md"

# Copy command
cp "$SCRIPT_DIR/commands/guide.md" "$COMMANDS_DIR/guide.md"
echo "[OK] Installed command: $COMMANDS_DIR/guide.md"

echo ""
echo "Done! You can now use:"
echo "  /guide              -- overview of all installed skills"
echo "  /guide <name>       -- deep dive into a specific skill"
echo "  /guide <goal>       -- get recommendations for your goal"
echo ""
echo "To uninstall:"
echo "  rm -rf $SKILLS_DIR"
echo "  rm $COMMANDS_DIR/guide.md"
