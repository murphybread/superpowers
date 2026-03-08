# Fork Bundling Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make `murphybread/superpowers` installable as a single package that restores Murphybread-specific prompts and bundled custom skills in a new environment.

**Architecture:** Keep the upstream Superpowers repository layout intact, add Murphybread-specific assets at the repository root, and install them with one portable Bash entrypoint. Use a shell test with a temporary `HOME` to verify backup behavior, prompt deployment, and skill symlink replacement before claiming success.

**Tech Stack:** Bash, git, symlinks, markdown prompt files, shell-based verification

---

### Task 1: Add a failing installer test

**Files:**
- Create: `tests/codex-install/test-install.sh`

**Step 1: Write the failing test**

Create a shell test that:
- Creates a temporary `HOME`
- Seeds existing `~/.codex/AGENTS.md`, `~/.claude/CLAUDE.md`, and `~/.agents/skills/superpowers`
- Runs `install.sh`
- Expects backup files with a `pre-murphybread-install` marker
- Expects the installed prompts to match the repository copies
- Expects `~/.agents/skills/superpowers` to point to the repository `skills` directory
- Re-runs the installer and expects no extra backup of already managed prompt files

**Step 2: Run test to verify it fails**

Run: `bash tests/codex-install/test-install.sh`

Expected: FAIL because `install.sh`, `AGENTS.md`, and `CLAUDE.md` are not yet present in the repository root.

### Task 2: Add portable Murphybread prompt files

**Files:**
- Create: `AGENTS.md`
- Create: `CLAUDE.md`

**Step 1: Write portable prompts**

Use the current local prompt rules as the source, but remove machine-specific paths so the files can be copied into a new environment safely.

**Step 2: Keep the Kanban guidance portable**

Replace the hardcoded `/home/ubuntu/pull-ledger` references with project-relative guidance so the prompts remain useful after installation elsewhere.

### Task 3: Bundle the custom skill

**Files:**
- Create: `skills/kanban-multi-project-manager/SKILL.md`
- Create: `skills/kanban-multi-project-manager/references/kanban-format.md`

**Step 1: Copy the existing custom skill into the repository skill tree**

Keep the existing skill name and contents so it becomes available automatically through the normal Superpowers symlink.

### Task 4: Implement the installer

**Files:**
- Create: `install.sh`

**Step 1: Write minimal installer behavior**

Implement a shell script that:
- Detects repository root from the script location
- Creates `~/.codex`, `~/.claude`, and `~/.agents/skills`
- Backs up unmanaged `AGENTS.md` and `CLAUDE.md` with `pre-murphybread-install` in the filename
- Copies the repository prompt files into place
- Replaces the `superpowers` skill entry with a symlink to this repository's `skills`
- Backs up any pre-existing unmanaged `~/.agents/skills/superpowers`
- Prints a concise summary

**Step 2: Mark managed files**

Add a stable marker so re-running `install.sh` does not back up files that were already installed by this script.

### Task 5: Update installation docs

**Files:**
- Modify: `.codex/INSTALL.md`
- Modify: `docs/README.codex.md`
- Modify: `README.md`

**Step 1: Point docs at the fork installer**

Document that a new environment can clone the fork and run `bash install.sh`.

### Task 6: Verify and merge

**Files:**
- Modify: none

**Step 1: Run verification**

Run:
- `bash tests/codex-install/test-install.sh`
- `bash -n install.sh`
- `test -f AGENTS.md`
- `test -f CLAUDE.md`
- `test -f skills/kanban-multi-project-manager/SKILL.md`

**Step 2: Merge branch into main**

Run:
- `git checkout main`
- `git merge --ff-only feat/writing-results`

If fast-forward is unavailable, stop and inspect before merging.
