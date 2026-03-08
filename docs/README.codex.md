# Murphybread Superpowers for Codex

Guide for using the Murphybread fork with OpenAI Codex via native skill discovery.

For Claude Code specifics, including the difference between local skills and plugin marketplace state, see [README.claude.md](README.claude.md).

## Quick Install

Run the bootstrap installer:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/murphybread/superpowers/main/install.sh)
```

Or clone the fork and run the installer:

```bash
git clone https://github.com/murphybread/superpowers.git ~/.codex/superpowers
bash ~/.codex/superpowers/install.sh
```

## Manual Installation

### Prerequisites

- OpenAI Codex CLI
- Git

### Steps

1. Clone the repo:
   ```bash
   git clone https://github.com/murphybread/superpowers.git ~/.codex/superpowers
   ```

2. Run the installer:
   ```bash
   bash ~/.codex/superpowers/install.sh
   ```

3. Restart Codex.

### Windows

Use a junction instead of a symlink (works without Developer Mode):

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\superpowers" "$env:USERPROFILE\.codex\superpowers\skills"
```

## How It Works

Codex has native skill discovery — it scans `~/.agents/skills/` at startup, parses SKILL.md frontmatter, and loads skills on demand. The installer creates a single symlink:

```
~/.agents/skills/superpowers/ → ~/.codex/superpowers/skills/
```

The `using-superpowers` skill is discovered automatically and enforces skill usage discipline — no additional configuration needed.

## Usage

Skills are discovered automatically. Codex activates them when:
- You mention a skill by name (e.g., "use brainstorming")
- The task matches a skill's description
- The `using-superpowers` skill directs Codex to use one

### Personal Skills

This fork already bundles Murphybread custom skills inside `skills/`. Create additional personal skills in `~/.agents/skills/` if you want them to stay outside the repo:

```bash
mkdir -p ~/.agents/skills/my-skill
```

Create `~/.agents/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Use when [condition] - [what it does]
---

# My Skill

[Your skill content here]
```

The `description` field is how Codex decides when to activate a skill automatically — write it as a clear trigger condition.

## Updating

```bash
cd ~/.codex/superpowers && git pull
bash ~/.codex/superpowers/install.sh
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/superpowers
```

**Windows (PowerShell):**
```powershell
Remove-Item "$env:USERPROFILE\.agents\skills\superpowers"
```

Optionally delete the clone: `rm -rf ~/.codex/superpowers` (Windows: `Remove-Item -Recurse -Force "$env:USERPROFILE\.codex\superpowers"`).

## Troubleshooting

### Skills not showing up

1. Verify the symlink: `ls -la ~/.agents/skills/superpowers`
2. Check skills exist: `ls ~/.codex/superpowers/skills`
3. Restart Codex — skills are discovered at startup

### Windows junction issues

Junctions normally work without special permissions. If creation fails, try running PowerShell as administrator.

## Getting Help

- Report issues: https://github.com/obra/superpowers/issues
- Main documentation: https://github.com/obra/superpowers
