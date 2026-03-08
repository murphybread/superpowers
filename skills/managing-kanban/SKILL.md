---
name: managing-kanban
description: Use when starting any work session or task, before taking action. Apply when user assigns work, asks about project status, or mentions tasks across multiple projects.
---

# Multi-Project Kanban Management

## Overview

Manages tasks across multiple projects using two markdown files: `kanban.md` (active board)
and `kanbanArchive.md` (completion history). One master file covers all projects via
`[ProjectName]` tags — no per-project files, no sync issues.

**Core principle:** If kanban is configured -> read it before any work. If not configured -> skip silently and continue.

**Announce at start:** "I'm using the managing-kanban skill to check task context."

## Step 1: Check Configuration

```
1. Look for "## Kanban" section in ~/.claude/CLAUDE.md
2. If found -> read the Board path listed there (proceed to Step 2)
3. If not found -> skip kanban entirely, proceed with the user's task directly
```

**Do NOT stop work or prompt setup** if kanban is unconfigured.
Setup is opt-in (see Setup Wizard section below).

## Step 2: Read Board (Configured Users Only)

```
1. Read kanban.md -> record current rev:N
2. Review WIP, TODO, FREEZE sections for context
3. Surface blockers or WIP limit issues before starting new work
```

Red flags that mean you are violating this rule (for configured users):
- "This is a quick task, I'll skip the kanban check"
- "I already know what to work on"
- "The user told me directly, no need to check"

All of these mean: read `kanban.md` first.

## Setup Wizard (Optional, First Time Only)

Run only when user explicitly asks to set up kanban, or when they ask
"Where should I track my tasks?" and you surface kanban as an option.

```
1. Ask user: "Where is the master project directory?" (absolute path)
2. Create {dir}/kanban.md from kanban-template.md
3. Create {dir}/kanbanArchive.md with header only
4. Ask user: "Which projects should be registered?" (comma-separated names)
5. Add each project to the ## Projects section in kanban.md
6. Append to ~/.claude/CLAUDE.md:

## Kanban
- Board: {absolute-path}/kanban.md
- Archive: {absolute-path}/kanbanArchive.md
- RULE: Read Board file before starting any task. If not found: STOP and report path.

7. Confirm: read kanban.md back and show the user the initial state
```

## File Structure

### kanban.md

```markdown
# Kanban Board
_Updated: YYYY-MM-DD_
_rev: 1_

## Projects
- ProjectNameA
- ProjectNameB

## WIP (max 7)
- [ProjectA][P1][@alice] Task description

## TODO
- [ProjectB][P2] Task description

## FREEZE
- [ProjectC][P1][freeze:env][frozen:2026-02-20] Task description

## DONE (recent 10)
- [ProjectA][done:2026-02-26] Completed task
```

### kanbanArchive.md

```markdown
# Kanban Archive

## 2026-02
- [ProjectA][done:2026-02-15] Older completed task
```

## Task Format

`- [ProjectName][Priority][Size][@Assignee] Description`

All fields are bracket-enclosed and **order-independent** (except `[ProjectName]` must be first).
The description starts after the last `]` and may contain any characters including `|` and `:`.

| Tag | Required | Column | Example |
|-----|----------|--------|---------|
| `[ProjectName]` | Always | All | `[PullLedger]` |
| `[P1]` / `[P2]` / `[P3]` | Recommended | All | `[P2]` |
| `[S]` / `[M]` / `[L]` | Recommended | All | `[M]` |
| `[@name]` | Optional | All | `[@alice]` |
| `[ref:path]` | M/L only | All active | `[ref:pull-ledger/docs/plans/2026-02-26-gmail-sync.md]` |
| `[out:path]` | Optional | DONE + Archive | `[out:pull-ledger/docs/reports/2026-02-26-gmail-sync-report.md]` |
| `[freeze:type]` | FREEZE only | FREEZE | `[freeze:env]` |
| `[frozen:YYYY-MM-DD]` | FREEZE only | FREEZE | `[frozen:2026-02-20]` |
| `[done:YYYY-MM-DD]` | DONE only | DONE + Archive | `[done:2026-02-26]` |

**Freeze reason types:** `env` · `dependency` · `decision` · `external` · `research`

**Rule:** `[ProjectName]` must match an entry in the `## Projects` registry exactly (case-sensitive).
Before creating a task for a new project, add it to the registry first.

## Task Sizing and Plan Integration

### Sizing Rule

Agent decides size at task creation time:

| Size | Definition | Plan file |
|------|-----------|-----------|
| `[S]` | Completable in a single session | None — kanban card only |
| `[M]` | Requires 2–4 sessions, has clear sub-steps | Required before WIP |
| `[L]` | Multi-day, spans multiple sessions | Required + must be decomposed into sub-tasks |

**Decision heuristic:** If you cannot describe all the steps needed to complete this task
right now without researching further, it is not S.

### Plan File Workflow (M and L tasks)

When a task is sized M or L and is being moved to WIP for the first time:

```
1. Invoke superpowers:writing-plans skill
2. Plan file is created at: {project-dir}/docs/plans/YYYY-MM-DD-{topic}.md
3. Add [ref:relative-path] tag to the kanban card
4. Then proceed with WIP claim write
```

Path in `[ref:]` is relative to the workspace root (not the kanban.md directory).

Example:
```markdown
## WIP
- [PullLedger][P1][M][ref:pull-ledger/docs/plans/2026-02-26-gmail-sync.md] Gmail sync implementation
- [API][P2][S] Rate limiting header fix
```

### L Task Decomposition

An L task must be broken into S/M sub-tasks before moving to WIP:

```markdown
## TODO
- [PullLedger][P1][L][ref:pull-ledger/docs/plans/2026-02-26-auth.md] Full auth system
  -> decompose into:
- [PullLedger][P1][M][ref:pull-ledger/docs/plans/2026-02-26-auth.md] OAuth login
- [PullLedger][P2][S] Session token expiry handling
- [PullLedger][P2][M] Auth middleware
```

The L task card is removed once sub-tasks are created. Sub-tasks share the parent's `[ref:]` path.

## State Transitions

Complete transition table — every valid move:

| From | To | Trigger | Required fields |
|------|----|---------|-----------------|
| TODO | WIP | Start working | Claim write immediately (see WIP Protocol) |
| WIP | DONE | Completed | Run DONE Protocol first, then add `[done:YYYY-MM-DD]` |
| WIP | FREEZE | Blocker mid-task | Add `[freeze:type]` + `[frozen:date]` |
| WIP | TODO | Deprioritized | No extra fields |
| FREEZE | TODO | Blocker resolved, not resuming yet | Remove freeze fields |
| FREEZE | WIP | Blocker resolved, resuming immediately | Remove freeze fields, claim write |
| FREEZE | DONE | Resolved externally | Run DONE Protocol first, then add `[done:YYYY-MM-DD]` |
| DONE | WIP | Reopened | Remove `[done:date]` |
| DONE | Archive | DONE count exceeds 10 | Move oldest `done:date` item |

Undefined transitions do not exist. If a situation does not match any row above,
surface it to the user before acting.

## WIP Protocol (Parallel Agent Safety)

When picking up a task from TODO:

```
1. Read kanban.md -> record rev:N
2. Count WIP items -> if >= 7: STOP, report "WIP limit reached (7/7).
   Move or freeze an existing WIP item before starting new work."
3. Move task to WIP in memory, set rev to N+1
4. Write kanban.md immediately (this write is the claim)
5. Re-read kanban.md -> verify your task appears in WIP
6. If task is missing (concurrent write collision): re-read, pick a different task
   or report conflict to user
```

Never perform step 6 (actual work) before step 4 (claim write) completes.

## Archive Rule

After every transition into DONE:

```
1. Count items in ## DONE section
2. If count <= 10: done, no action needed
3. If count > 10:
   a. Find item with oldest done:date
   b. Remove it from ## DONE
   c. Open kanbanArchive.md
   d. Find ## YYYY-MM section matching that done:date (create if missing)
   e. Copy the full card line as-is into that section (newest first within month)
   f. Optionally append a > note line for context (delays, decisions, resolutions)
   g. Increment rev in kanban.md
```

Archive format:
```markdown
## 2026-02
- [PullLedger][P1][M][ref:...][out:...][done:2026-02-26] Gmail sync implementation
  > Changed to polling approach, resolved notion rate limit issue
- [API][P2][S][done:2026-02-24] Rate limiting header fix
```

The `>` note is optional. Add only when there is context worth preserving
(delays, unexpected decisions, alternative approaches taken).

## Quick Reference

| Situation | Action |
|-----------|--------|
| Kanban not in CLAUDE.md | Skip silently, proceed with task |
| Kanban configured | Read board before any work |
| User asks to set up kanban | Run Setup Wizard |
| WIP reaches 7 | STOP, surface to user |
| DONE reaches 11 | Archive oldest item |
| New project name needed | Add to ## Projects registry first |
| M/L task -> WIP | Create plan file first, add [ref:] |
| L task in TODO | Decompose into S/M before WIP |
| M/L task -> DONE | Invoke superpowers:writing-results, add [out:] |

## Common Mistakes

| Mistake | Correct behavior |
|---------|-----------------|
| Stopping work when kanban not configured | Skip silently, continue with task |
| Prompting setup unprompted | Only run Setup Wizard when user explicitly asks |
| Pipe separators: `task \| P1 \| @alice` | Tag block only: `[P1][@alice] task` |
| Forgetting to increment `_rev_` | Always increment on every write |
| Archiving to wrong month | Parse `done:date` to determine the `## YYYY-MM` section |
| DONE overflow of 1 item goes unnoticed | Check count after every DONE addition |
| Using `[project-a]` and `[ProjectA]` interchangeably | Case-sensitive exact match to registry |
| Moving M task to WIP without a plan | Invoke `writing-plans` -> get `[ref:]` -> then claim WIP |
| L task sitting in TODO undecomposed | L tasks must be broken into S/M before any sub-task enters WIP |

## Red Flags

**For configured users:**
- Starting work without reading `kanban.md`
- Creating a task with an unregistered `[ProjectName]`
- Moving to WIP without immediately writing the claim
- WIP reaching 7 without surfacing to user
- DONE reaching 11+ without archiving the oldest item
- Skipping kanban check because "the task is obvious"
- Creating per-project kanban files instead of using the single master file
- Moving an M/L task to WIP without creating a plan file first
- Keeping an L task on the board without decomposing it into sub-tasks

**Never (all users):**
- Blocking work because kanban is not configured
- Running Setup Wizard without user request
- Force-creating CLAUDE.md entries without confirmation

## Integration

**Pairs with:**
- **superpowers:writing-plans** — required for M/L tasks before WIP claim
- **superpowers:writing-results** — optional for M/L tasks on DONE transition; produces `[out:]` path
- **superpowers:executing-plans** — reads kanban state before executing plan batches
- **superpowers:finishing-a-development-branch** — updates kanban to DONE after branch completion
