# Kanban File Format

Use this format for all projects in `kanban.md` and `kanbanArchive.md`.

## kanban.md Template

```markdown
# Multi Project Kanban

## Project: <project_name>

### TODO
- [ ] <PROJECT>-001 | <title> | owner=<owner> | updated_at=<YYYY-MM-DD>

### WIP
- [ ] <PROJECT>-002 | <title> | owner=<owner> | started_at=<YYYY-MM-DD> | updated_at=<YYYY-MM-DD>

### FREEZE
- [ ] <PROJECT>-003 | <title> | owner=<owner> | freeze_reason=<cost|decision|deploy_env|other> | frozen_at=<YYYY-MM-DD> | updated_at=<YYYY-MM-DD>

### DONE
- [x] <PROJECT>-004 | <title> | owner=<owner> | done_at=<YYYY-MM-DD> | updated_at=<YYYY-MM-DD>
```

Rules:
1. Keep lane order fixed: TODO, WIP, FREEZE, DONE.
2. Keep DONE newest first by `done_at`.
3. Keep at most 10 DONE items per project in `kanban.md`.

## kanbanArchive.md Template

```markdown
# Kanban Archive

## Archive Log
YYYY-MM-DDTHH:MM:SSZ | project=<project_name> | task_id=<PROJECT>-123 | title=<title> | done_at=<YYYY-MM-DD> | archived_reason=done_overflow
```

Rules:
1. Append-only log; do not reorder old records.
2. Add one line per overflowed DONE item.
3. Keep exact field keys for searchability.
