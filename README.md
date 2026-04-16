# skill-guide

**The missing manual for your Claude Code skills.**

[繁體中文](README.zh-TW.md)

---

## The Problem

The Claude Code skills ecosystem is booming -- there are hundreds of thousands of skills available on GitHub. But after installing them, most users face the same problem:

- Skills are documented in English (or not documented at all)
- README files explain *what* a skill can do, not *how* to actually use it
- You install 10+ skills and have no idea where to start
- There's no way to see all your installed skills at a glance

**skill-guide** solves this. It's a Claude Code skill that acts as a **navigator** for all your other skills -- scanning what you have installed and explaining everything in your language.

## What It Does

| Command | What happens |
|---------|-------------|
| `/guide` | Scans all installed skills & commands, shows a categorized overview with workflow recommendations |
| `/guide <name>` | Deep dive into a specific skill -- explains what it does, when to use it, how to use it, with examples |
| `/guide <goal>` | Describe what you want to do, get a step-by-step plan using your installed skills |
| `/guide --check` | Scans your skills' dependencies and checks if the required tools/APIs are installed on your system |
| `/guide --diff <repo>` | Compares your installed skills against a skill pack (GitHub repo) and shows what's missing |

### Key Features

- **Multilingual** -- Responds in whatever language you write in (English, Chinese, Japanese, Spanish, etc.)
- **Dynamic** -- Reads your actual installed skills at runtime, not a hardcoded list
- **Workflow-oriented** -- Shows you the recommended order, not just a flat list
- **Beginner-friendly** -- Explains concepts in plain language with real examples

## Quick Start

### Option 1: One-line install

```bash
git clone https://github.com/vv1n/skill-guide.git && cd skill-guide && ./install.sh
```

### Option 2: Manual install

```bash
# Clone the repo
git clone https://github.com/vv1n/skill-guide.git

# Copy skill
mkdir -p ~/.claude/skills/skill-guide
cp skill-guide/SKILL.md ~/.claude/skills/skill-guide/SKILL.md

# Copy command
cp skill-guide/commands/guide.md ~/.claude/commands/guide.md
```

### Verify installation

Open Claude Code and type:

```
/guide
```

You should see a complete overview of all your installed skills in your language.

## Usage Examples

### Overview -- "What do I have?"

```
/guide
```

Returns a categorized map of all your skills and commands:

```
[Preparation] --> [Execution] --> [Validation] --> [Output]

Skills:  10 installed (auto-loaded)
Commands: 15 available (type /command to use)

...categorized table with descriptions...
```

### Deep Dive -- "How does this work?"

```
/guide hunt
```

Returns a beginner-friendly explanation:

```
## /hunt -- Vulnerability Hunter

One-sentence: Actively searches for security vulnerabilities on a target.

When to use:
- You've finished recon and have a list of endpoints
- You want to test a specific vulnerability class (SSRF, IDOR, etc.)

How to use:
  /hunt target.com
  /hunt target.com --vuln-class idor

What comes before: /recon, /surface
What comes after: /validate, /report
...
```

### Dependency Check -- "Am I ready?"

```
/guide --check
```

Scans every skill you have installed, extracts the tools and APIs they depend on, and checks your system:

```
## Environment Health Check

### Tools
| Tool       | Status        | Required by           |
|------------|---------------|-----------------------|
| subfinder  | OK (v2.6.3)   | web2-recon, /recon    |
| httpx      | OK (v1.3.7)   | web2-recon, /recon    |
| nuclei     | MISSING       | web2-recon, /recon    |
| forge      | MISSING       | web3-audit            |

### Environment Variables
| Variable        | Status  | Required by        |
|-----------------|---------|---------------------|
| CHAOS_API_KEY   | OK      | /recon              |
| SHODAN_API_KEY  | MISSING | /recon (optional)   |

### How to fix
- nuclei: `go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest`
- forge: `curl -L https://foundry.paradigm.xyz | bash && foundryup`
```

### Diff -- "Am I missing anything?"

```
/guide --diff user/awesome-bb-skills
```

Compares your installed skills against a GitHub repo (skill pack):

```
## Skill Diff: you vs user/awesome-bb-skills

| Skill        | In source | Installed | Status  |
|--------------|-----------|-----------|---------|
| bug-bounty   | Yes       | Yes       | OK      |
| api-testing  | Yes       | No        | MISSING |

Missing 2 skills, 1 command.

### Install missing
  mkdir -p ~/.claude/skills/api-testing
  cp ...
```

### Recommendation -- "I want to do X"

```
/guide I want to find IDOR vulnerabilities on a website
```

Returns a step-by-step plan using your installed skills:

```
Goal: Find IDOR vulnerabilities on a target website

Step 1: /scope target.com          -- Confirm it's in scope
Step 2: /recon target.com          -- Map all endpoints
Step 3: /hunt target.com --vuln-class idor  -- Hunt for IDORs
Step 4: /validate                  -- Verify the finding is real
Step 5: /report                    -- Generate submission report

You do NOT need: web3-audit, meme-coin-audit, token-scan
```

## How It Works

skill-guide consists of two files:

| File | Type | Purpose |
|------|------|---------|
| `SKILL.md` | Skill (auto-loaded) | Background knowledge -- Claude automatically understands how to navigate skills when the topic comes up |
| `commands/guide.md` | Slash Command | The `/guide` command -- explicitly triggered by the user |

**Skills vs Commands** -- this is a distinction many users don't understand:
- **Skills** load automatically when Claude detects relevant context. You don't need to do anything.
- **Commands** require you to type `/command-name` to trigger them.

skill-guide itself helps explain this distinction for all your other installed skills.

## Compatibility

- Works with any Claude Code skills, regardless of their source
- Scans user-level (`~/.claude/`) and project-level (`.claude/`) skills
- Compatible with plugin marketplace skills
- No dependencies -- it's just two markdown files

## Uninstall

```bash
rm -rf ~/.claude/skills/skill-guide
rm ~/.claude/commands/guide.md
```

## Contributing

Contributions are welcome! Some ideas:

- **Improve the scanning logic** -- handle edge cases in skill detection
- **Add example outputs** -- screenshots or recordings of guide in different languages
- **Test with more skill sets** -- report how guide works with different skill collections
- **Translations** -- improve the README in your language

## License

MIT
