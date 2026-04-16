# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest (main) | Yes |

## Reporting a Vulnerability

If you discover a security vulnerability in skill-guide, please report it responsibly.

### How to report

1. **Do NOT open a public GitHub issue** for security vulnerabilities
2. Email: **vv1ntw@gmail.com**
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to expect

- Acknowledgment within 48 hours
- Status update within 7 days
- Fix released as soon as possible, depending on severity

### Scope

Since skill-guide consists of markdown files and a shell script, relevant security concerns include:

- **Command injection** via `install.sh`
- **Path traversal** in file copy operations
- **Malicious content** in skill scanning logic that could be exploited by crafted SKILL.md files
- **Information disclosure** through scanning patterns

### Out of scope

- Vulnerabilities in Claude Code itself (report to [Anthropic](https://www.anthropic.com/responsible-disclosure))
- Vulnerabilities in skills that skill-guide scans (report to those skill authors)
