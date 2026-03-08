# Installing Murphybread Superpowers for Codex

Enable the Murphybread fork in Codex with one installer script. Clone the fork, run `install.sh`, and let it install the prompts plus bundled skills.

## Prerequisites

- Git

## Installation

1. **Clone the Murphybread fork:**
   ```bash
   git clone https://github.com/murphybread/superpowers.git ~/.codex/superpowers
   ```

2. **Run the installer:**
   ```bash
   bash ~/.codex/superpowers/install.sh
   ```

   **Windows (PowerShell):**
   ```powershell
   bash "$env:USERPROFILE\.codex\superpowers\install.sh"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## Migrating from old bootstrap

If you installed superpowers before native skill discovery, you need to:

1. **Update the repo:**
   ```bash
   cd ~/.codex/superpowers && git pull
   ```

2. **Re-run the installer**:
   ```bash
   bash ~/.codex/superpowers/install.sh
   ```

3. **Remove the old bootstrap block** from `~/.codex/AGENTS.md` if you still have one — any block referencing `superpowers-codex bootstrap` is no longer needed.

4. **Restart Codex.**

## Verify

```bash
ls -la ~/.agents/skills/superpowers
ls ~/.codex/superpowers/skills
```

You should see a symlink (or junction on Windows) pointing to your fork's bundled skills directory.

## Updating

```bash
cd ~/.codex/superpowers && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/superpowers
rm ~/.codex/AGENTS.md
rm ~/.claude/CLAUDE.md
```

Optionally restore the `.pre-murphybread-install.*.bak` files that the installer created, then delete the clone: `rm -rf ~/.codex/superpowers`.
