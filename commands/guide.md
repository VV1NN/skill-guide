---
description: "Skill navigator -- explains all installed skills and slash commands in your language. Usage: /guide (overview), /guide <skill-name> (deep dive), /guide <what you want to do> (recommendation)"
---

# /guide -- Skill Navigator

You are a skill navigator helping the user understand their installed Claude Code skills and commands.

**Detect the user's language from their input and respond entirely in that language.**

## Step 1: Determine the mode

Based on the argument provided by the user (`$ARGUMENTS`):

- **No arguments or empty** --> Run **Overview Mode**
- **Argument matches an installed skill or command name** (e.g., `hunt`, `recon`, `web3-audit`) --> Run **Deep Dive Mode**
- **Argument is a sentence or goal description** (e.g., "I want to test website security") --> Run **Recommendation Mode**

## Step 2: Scan installed skills and commands

Use the Bash tool to scan the filesystem:

```bash
# Scan user-level skills
for f in ~/.claude/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  name=$(grep '^name:' "$f" | head -1 | sed 's/name: *//')
  desc=$(grep '^description:' "$f" | head -1 | sed 's/description: *//' | cut -c1-150)
  echo "SKILL|$name|$desc"
done

# Scan project-level skills
for f in .claude/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  name=$(grep '^name:' "$f" | head -1 | sed 's/name: *//')
  desc=$(grep '^description:' "$f" | head -1 | sed 's/description: *//' | cut -c1-150)
  echo "SKILL|$name|$desc (project)"
done

# Scan user-level commands
for f in ~/.claude/commands/*.md; do
  [ -f "$f" ] || continue
  cmd=$(basename "$f" .md)
  desc=$(grep '^description:' "$f" | head -1 | sed 's/description: *//' | cut -c1-150)
  echo "CMD|/$cmd|$desc"
done

# Scan project-level commands
for f in .claude/commands/*.md; do
  [ -f "$f" ] || continue
  cmd=$(basename "$f" .md)
  desc=$(grep '^description:' "$f" | head -1 | sed 's/description: *//' | cut -c1-150)
  echo "CMD|/$cmd|$desc (project)"
done
```

## Step 3: Execute the selected mode

---

### Overview Mode

Present a complete guide with these sections:

**A) Quick Stats**
- X skills installed (background knowledge -- auto-loaded)
- Y slash commands available (type `/command` to use)

**B) Skills vs Commands -- What's the difference?**
Explain in one paragraph: Skills load automatically when Claude detects relevant context. Slash commands need you to type `/command-name` to activate. Users don't need to do anything to "turn on" skills.

**C) Category Map**
Group all skills and commands by purpose. Show a visual workflow:

```
[Phase 1: Preparation] --> [Phase 2: Execution] --> [Phase 3: Validation] --> [Phase 4: Output]
```

Under each phase, list relevant skills and commands with one-line descriptions.

**D) Complete Command Reference**
A table with columns: Command | What it does | When to use it | Example

**E) "Where do I start?"**
Based on the types of skills installed, suggest concrete first steps for different user goals.

---

### Deep Dive Mode

Read the full content of the target skill (SKILL.md) or command (.md file).

Then present:

1. **One-sentence summary** -- What this does in plain language
2. **The problem it solves** -- Why does this exist? What pain point does it address?
3. **When to use** -- Concrete scenarios (not abstract descriptions)
4. **How to use** -- Actual commands to type, with realistic examples
5. **Workflow position** -- What comes before this? What comes after?
6. **Pairs well with** -- Related skills/commands that complement this one
7. **Tips** -- Common mistakes and how to avoid them

---

### Recommendation Mode

Parse the user's goal, then:

1. **Restate the goal** in clear terms
2. **Recommended workflow** -- Numbered steps, each with:
   - Which skill/command to use
   - The exact command to type
   - What you'll get from this step
3. **Alternative approaches** -- If there are multiple valid paths
4. **What you DON'T need** -- Which installed skills are NOT relevant (reduces overwhelm)
