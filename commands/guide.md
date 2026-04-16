---
description: "Skill navigator -- explains all installed skills and slash commands in your language. Usage: /guide (overview), /guide <skill-name> (deep dive), /guide <what you want to do> (recommendation), /guide --check (dependency check), /guide --diff <repo-url> (compare with a skill pack)"
---

# /guide -- Skill Navigator

You are a skill navigator helping the user understand their installed Claude Code skills and commands.

**Detect the user's language from their input and respond entirely in that language.**

## Step 1: Determine the mode

Based on the argument provided by the user (`$ARGUMENTS`):

- **No arguments or empty** --> Run **Overview Mode**
- **`--check`** --> Run **Dependency Check Mode**
- **`--diff <repo-url-or-skill-pack-name>`** --> Run **Diff Mode**
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

---

### Dependency Check Mode (`--check`)

Check whether the user's environment has the tools and dependencies required by their installed skills.

**Step 1: Scan all installed skills and read their full SKILL.md content.**

**Step 2: Extract dependency signals from each skill.** Look for:
- Tool names mentioned in the skill (e.g., `subfinder`, `httpx`, `nuclei`, `ffuf`, `katana`, `node`, `python3`, `go`, `foundry`, `forge`)
- Commands referenced in code blocks (e.g., `subfinder -d`, `httpx -l`, `nuclei -t`)
- Language runtimes mentioned (e.g., Python, Node.js, Go, Rust)
- External services or API keys mentioned (e.g., `CHAOS_API_KEY`, `SHODAN_API_KEY`)

**Step 3: Check which tools are actually installed** by running:

```bash
# For each tool found in skills, check if it exists
for tool in subfinder httpx nuclei ffuf katana waybackurls gau dnsx nmap nikto sqlmap \
            node python3 go forge cast solc foundryup pip3 npm cargo rustc \
            git curl jq gh docker; do
  if command -v "$tool" &>/dev/null; then
    version=$("$tool" --version 2>/dev/null | head -1 || echo "installed")
    echo "OK|$tool|$version"
  else
    echo "MISSING|$tool"
  fi
done
```

**Step 4: Check for API keys / environment variables** commonly needed:

```bash
# Use bash explicitly for ${!var} indirect expansion (not supported in zsh)
bash -c '
for var in CHAOS_API_KEY SHODAN_API_KEY GITHUB_TOKEN ETHERSCAN_API_KEY; do
  if [ -n "${!var}" ]; then
    echo "ENV_OK|$var"
  else
    echo "ENV_MISSING|$var"
  fi
done
'
```

**Step 5: Present results as a health report:**

```
## Environment Health Check

### Tools
| Tool | Status | Required by |
|------|--------|-------------|
| subfinder | OK (v2.6.3) | web2-recon, /recon |
| httpx | OK (v1.3.7) | web2-recon, /recon |
| nuclei | MISSING | web2-recon, /recon |
| forge | MISSING | web3-audit, /web3-audit |

### Environment Variables
| Variable | Status | Required by |
|----------|--------|-------------|
| CHAOS_API_KEY | OK | /recon |
| SHODAN_API_KEY | MISSING | /recon (optional) |

### Summary
- X/Y tools installed
- Z tools missing
- A/B env vars configured

### How to fix
(Provide install commands for each missing tool, e.g.)
- nuclei: `go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest`
- forge: `curl -L https://foundry.paradigm.xyz | bash && foundryup`
```

---

### Diff Mode (`--diff <source>`)

Compare the user's installed skills against a skill pack (a GitHub repo or known skill collection) to show what's missing.

**Step 1: Determine the source.**
- If the argument is a GitHub URL (e.g., `https://github.com/user/repo`) or a `user/repo` shorthand, clone it to a temp directory
- If the argument is a local path, use it directly

```bash
# Clone to temp if it's a GitHub reference
if echo "$SOURCE" | grep -qE '(github\.com|^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$)'; then
  REPO_URL="$SOURCE"
  # Normalize to full URL if shorthand
  echo "$REPO_URL" | grep -q "github.com" || REPO_URL="https://github.com/$REPO_URL"
  TEMP_DIR=$(mktemp -d)
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR/source-pack" 2>/dev/null
  SOURCE_DIR="$TEMP_DIR/source-pack"
else
  SOURCE_DIR="$SOURCE"
fi
```

**Step 2: Scan the source for skills and commands.**

```bash
# Scan source skills
for f in "$SOURCE_DIR"/skills/*/SKILL.md "$SOURCE_DIR"/*/SKILL.md "$SOURCE_DIR"/SKILL.md; do
  [ -f "$f" ] || continue
  name=$(grep '^name:' "$f" | head -1 | sed 's/name: *//')
  echo "SOURCE_SKILL|$name"
done

# Scan source commands
for f in "$SOURCE_DIR"/commands/*.md "$SOURCE_DIR"/*.md; do
  [ -f "$f" ] || continue
  # Skip README and non-command files
  basename "$f" | grep -qiE '^(readme|license|changelog|contributing)' && continue
  cmd=$(basename "$f" .md)
  desc=$(grep '^description:' "$f" | head -1 | sed 's/description: *//' | cut -c1-100)
  [ -n "$desc" ] && echo "SOURCE_CMD|$cmd|$desc"
done
```

**Step 3: Compare against installed skills and commands** (use the scan from Step 2 of the main flow).

**Step 4: Present a diff report:**

```
## Skill Diff: your environment vs <source>

### Skills
| Skill | In source | Installed | Status |
|-------|-----------|-----------|--------|
| bug-bounty | Yes | Yes | OK |
| web2-recon | Yes | Yes | OK |
| api-testing | Yes | No | MISSING |

### Commands
| Command | In source | Installed | Status |
|---------|-----------|-----------|--------|
| /hunt | Yes | Yes | OK |
| /fuzz | Yes | No | MISSING |

### Summary
- You have X/Y skills from this pack
- Missing Z skills, W commands

### How to install missing items
(Provide copy-paste commands to install each missing skill/command)
```

**Step 5: Clean up temp directory if created.**

```bash
[ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
```
