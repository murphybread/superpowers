---
name: kanban-multi-project-manager
description: Manage multi-project kanban boards stored in kanban.md with TODO/WIP/FREEZE/DONE lanes, enforce DONE recency limits, and roll older DONE items into kanbanArchive.md. Use when creating, updating, reviewing, or archiving project tasks across multiple concurrent projects.
---

# Kanban Multi Project Manager

## Overview

Maintain a single markdown kanban system for many projects. Keep active work visible in `kanban.md`, keep only recent DONE items there, and move older DONE history to `kanbanArchive.md`.

## Required Files

1. Ensure `kanban.md` exists in the target project root.
2. Ensure `kanbanArchive.md` exists in the same directory.
3. Use the canonical format in [kanban-format.md](references/kanban-format.md).

## Workflow

1. Parse board
- Read all project sections in `kanban.md`.
- Preserve project order and lane order: `TODO -> WIP -> FREEZE -> DONE`.

2. Apply requested changes
- Allowed actions: add task, move task, edit task fields, close task, reopen task.
- Keep `FREEZE` only for blocked tasks caused by cost, decision, or deployment-environment constraints.
- Require `freeze_reason` and `frozen_at` when moving an item into `FREEZE`.

3. Enforce DONE limit
- For each project, keep only the 10 most recent entries in `DONE`.
- Sort DONE by `done_at` descending (newest first).
- If more than 10 entries exist, move overflow entries to `kanbanArchive.md`.

4. Archive overflow entries
- Append one log line per overflow entry to `kanbanArchive.md`.
- Use the exact log schema from [kanban-format.md](references/kanban-format.md).
- Never rewrite existing archive history unless explicitly asked.

5. Validate integrity
- Confirm each task id is unique within a project.
- Confirm required fields by lane are present.
- Confirm no task appears in more than one lane in the same project.

## Output Contract

When updating boards, always report:
1. Changed files.
2. Project names touched.
3. Task transitions (from lane -> to lane).
4. Archive additions count.

## Task Line Rules

Use one-line task entries so diffs stay stable.

Base format:
`- [ ] <task_id> | <title> | owner=<owner> | updated_at=<YYYY-MM-DD>`

Additional fields:
- `WIP`: add `started_at=<YYYY-MM-DD>`
- `FREEZE`: add `freeze_reason=<cost|decision|deploy_env|other>` and `frozen_at=<YYYY-MM-DD>`
- `DONE`: use checkbox `[x]` and add `done_at=<YYYY-MM-DD>`

## Common Operations

Add task to TODO:
1. Create `task_id` using `<PROJECT>-NNN`.
2. Insert at top of `TODO` lane.

Close task:
1. Move item from `WIP` or `TODO` to top of `DONE`.
2. Set `[x]` and `done_at`.
3. Run DONE limit rule and archive overflow.

Freeze task:
1. Move task to `FREEZE`.
2. Add `freeze_reason` and `frozen_at`.

Unfreeze task:
1. Move task from `FREEZE` to top of `WIP`.
2. Remove freeze-only fields.
3. Add or refresh `started_at`.

## References

- [kanban-format.md](references/kanban-format.md): Canonical file templates and archive log schema
