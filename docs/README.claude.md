# Murphybread Superpowers for Claude Code

This fork supports Claude Code in two separate layers. They are related, but they are not the same thing.

## Layer 1: Local Skills and Prompt Files

The bootstrap installer manages these files:

- `~/.claude/CLAUDE.md`
- `~/.claude/skills/*`

This is what makes bundled skills like `managing-kanban` and `writing-results` available to Claude Code as local skills.

Install or refresh this layer with:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/murphybread/superpowers/main/install.sh)
```

After running it, restart Claude Code fully.

Verify:

```bash
ls -la ~/.claude/skills
```

You should see symlinks pointing into `~/.codex/superpowers/skills/`.

## Layer 2: Claude Plugin Marketplace Metadata

These repository files are plugin package metadata:

- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `hooks/*`
- `commands/*`

They describe how Claude Code can package and load this repo as a plugin through the plugin marketplace. They do **not** mean `install.sh` will directly rewrite your live Claude plugin cache.

The live Claude plugin state is stored separately under paths like:

- `~/.claude/plugins/installed_plugins.json`
- `~/.claude/plugins/known_marketplaces.json`
- `~/.claude/plugins/cache/...`
- `~/.claude/settings.json`

## What `install.sh` Does

`install.sh` intentionally handles only the portable parts:

- clone or update the fork into `~/.codex/superpowers`
- install `~/.codex/AGENTS.md`
- install `~/.claude/CLAUDE.md`
- link bundled Codex skills into `~/.agents/skills/superpowers`
- link bundled Claude skills into `~/.claude/skills/*`
- back up replaced files as `.pre-murphybread-install.<timestamp>.bak`

## What `install.sh` Does Not Do

`install.sh` does not directly edit:

- `~/.claude/plugins/installed_plugins.json`
- `~/.claude/plugins/known_marketplaces.json`
- `~/.claude/plugins/cache/...`
- `~/.claude/settings.json` plugin registration state

That is deliberate. Those files are runtime/plugin-manager state, not portable config.

## When You Need the Claude Plugin Too

If you only want local skills, `install.sh` is enough.

If you also want Claude plugin marketplace behavior such as plugin-installed commands or marketplace-managed hooks, install the plugin separately inside Claude Code.

The repository still carries the upstream plugin metadata, but local skills are now enough for the bundled Murphybread skills to be visible in Claude Code.

## Recommended Mental Model

- Codex: native skills via `~/.agents/skills/`
- Claude local skills: `~/.claude/skills/`
- Claude marketplace plugin: separate plugin system under `~/.claude/plugins/`

Treat these as three distinct installation targets.
