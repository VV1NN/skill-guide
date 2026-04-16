# skill-guide

> A prompt-driven skill navigator for Claude Code -- scans your installed skills and explains them in your language.

**Status: MVP** -- Tested with 10 skills + 15 commands. Core features work. See [Known Limitations](#known-limitations).

[繁體中文](README.zh-TW.md)

---

## The Problem

The Claude Code skills ecosystem is booming -- hundreds of thousands of skills on GitHub. But after installing them, most users hit the same wall:

- Skills are documented in English (or not documented at all)
- README files explain *what* a skill can do, not *how* to actually use it
- You install 10+ skills and have no idea where to start
- There's no way to see all your installed skills at a glance

**skill-guide** is a Claude Code skill that acts as a **navigator** for all your other skills -- it scans what you have installed and explains everything in your language.

## How It Works

skill-guide is **not a traditional program**. It consists of two markdown files that instruct Claude how to behave:

| File | Type | Purpose |
|------|------|---------|
| `SKILL.md` | Skill (auto-loaded) | Background knowledge -- Claude automatically understands how to navigate skills when the topic comes up |
| `commands/guide.md` | Slash Command | The `/guide` command -- explicitly triggered by the user, contains scanning logic and output format |

This means: the quality of output depends on Claude's ability to read your skill files, understand their content, and generate helpful explanations. It works well in practice, but it's heuristic, not deterministic. See [Known Limitations](#known-limitations).

**Skills vs Commands** -- a distinction many users don't understand:
- **Skills** load automatically when Claude detects relevant context. You don't need to do anything.
- **Commands** require you to type `/command-name` to trigger them.

skill-guide itself helps explain this distinction for all your other installed skills.

## What It Does

| Command | What happens |
|---------|-------------|
| `/guide` | Scans all installed skills & commands, shows a categorized overview with workflow recommendations |
| `/guide <name>` | Deep dive into a specific skill -- explains what it does, when to use it, how to use it, with examples |
| `/guide <goal>` | Describe what you want to do in plain language, get a step-by-step plan using your installed skills |
| `/guide --check` | Best-effort dependency detection -- extracts tools/APIs mentioned in your skills and checks if they're installed |
| `/guide --diff <repo>` | Compares your installed skills against a GitHub repo and shows what's missing. Works best with repos that follow standard skill directory layout |

## Quick Start

### Option 1: One-line install

```bash
git clone https://github.com/VV1NN/skill-guide.git && cd skill-guide && ./install.sh
```

### Option 2: Manual install

```bash
git clone https://github.com/VV1NN/skill-guide.git

mkdir -p ~/.claude/skills/skill-guide
cp skill-guide/SKILL.md ~/.claude/skills/skill-guide/SKILL.md
cp skill-guide/commands/guide.md ~/.claude/commands/guide.md
```

### Verify installation

Open Claude Code and type:

```
/guide
```

You should see a categorized overview of all your installed skills.

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
```

### Recommendation -- "I want to do X"

```
/guide I want to find IDOR vulnerabilities on a website
```

Returns a step-by-step plan:

```
Goal: Find IDOR vulnerabilities on a target website

Step 1: /scope target.com                       -- Confirm it's in scope
Step 2: /recon target.com                        -- Map all endpoints
Step 3: /hunt target.com --vuln-class idor       -- Hunt for IDORs
Step 4: /validate                                -- Verify the finding is real
Step 5: /report                                  -- Generate submission report

You do NOT need: web3-audit, meme-coin-audit, token-scan
```

### Dependency Check -- "Am I ready?"

```
/guide --check
```

Best-effort scan of tools and APIs your skills depend on:

```
## Environment Health Check

| Tool       | Status        | Required by           |
|------------|---------------|-----------------------|
| subfinder  | OK (v2.6.3)   | web2-recon, /recon    |
| nuclei     | MISSING       | web2-recon, /recon    |

### How to fix
- nuclei: `go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest`
```

> Note: Dependency detection is heuristic -- it extracts tool names mentioned in skill content. It may miss unlisted dependencies or flag tools that are optional.

### Diff -- "Am I missing anything?"

```
/guide --diff user/awesome-bb-skills
```

Compares your skills against a GitHub repo:

```
| Skill        | In source | Installed | Status  |
|--------------|-----------|-----------|---------|
| bug-bounty   | Yes       | Yes       | OK      |
| api-testing  | Yes       | No        | MISSING |
```

> Note: Diff works best with repos that use standard `skills/*/SKILL.md` and `commands/*.md` directory layouts. Non-standard structures may not be fully detected.

## Tested With

This skill has been tested in the following environment:

- **10 skills**: bb-methodology, bug-bounty, meme-coin-audit, report-writing, security-arsenal, triage-validation, web2-recon, web2-vuln-classes, web3-audit, skill-guide
- **15 slash commands**: autopilot, chain, guide, hunt, intel, recon, remember, report, resume, scope, surface, token-scan, triage, validate, web3-audit
- **Shell**: zsh (macOS default) and bash
- **All 5 modes tested**: overview, deep dive, recommendation, --check, --diff

### Bugs found and fixed during testing

| Bug | Cause | Fix |
|-----|-------|-----|
| `${!var}` env var check failed on macOS | zsh doesn't support bash indirect expansion | Wrapped in explicit `bash -c` |
| Glob patterns errored when no files matched | zsh treats no-match as error (unlike bash) | Wrapped all scans in explicit `bash -c` |

## Requirements

- Claude Code (CLI, desktop app, or IDE extension)
- Skills and commands must have frontmatter with `name:` and/or `description:` fields
- `--diff` mode requires `git` to clone remote repos
- `--check` mode requires `bash` (for env var detection)

## Known Limitations

- **Prompt-driven, not deterministic**: Output quality depends on Claude's interpretation of your skill files. Results are best-effort and may vary between sessions.
- **Dependency detection is heuristic**: `--check` extracts tool names mentioned in skill content. It cannot detect dependencies that aren't explicitly named, and may flag optional tools as required.
- **Diff requires standard layout**: `--diff` looks for `skills/*/SKILL.md` and `commands/*.md`. Repos with non-standard structures may not be fully scanned.
- **Frontmatter required**: Skills without `name:` or `description:` in their YAML frontmatter will be listed with incomplete information.
- **No caching**: Every `/guide` invocation rescans the filesystem. This is by design (always fresh) but means no persistent state between sessions.
- **Plugin marketplace skills**: Scanning `~/.claude/plugins/` paths is supported but less thoroughly tested than user-level skills.

## Compatibility

- Works with any Claude Code skills that use standard SKILL.md format
- Scans user-level (`~/.claude/`) and project-level (`.claude/`) skills
- Compatible with plugin marketplace skills (best-effort)
- Shell-compatible: tested on both zsh (macOS default) and bash
- No dependencies -- it's just two markdown files

## Uninstall

```bash
rm -rf ~/.claude/skills/skill-guide
rm ~/.claude/commands/guide.md
```

## Contributing

Contributions are welcome! Some ideas:

- **Test with different skill sets** -- report how guide works with your skills
- **Edge cases** -- skills without frontmatter, unusual directory structures
- **Screenshots** -- real output examples in different languages
- **Translations** -- improve the README in your language

## License

MIT
