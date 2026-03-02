---
name: writing-results
description: Use when implementation work is complete and needs documentation - after finishing a feature, after executing a plan, or when explicitly asked to write a completion report.
---

# Writing Results

## Overview

Write a structured result document for completed implementation work. Pairs with `writing-plans` — one plan doc, one result doc.

**Announce at start:** "I'm using the writing-results skill to create the result report."

**Context:** Run after implementation is complete. Works standalone — no kanban required.

**Save reports to:** `docs/reports/YYYY-MM-DD-<feature-name>-report.md`

---

## Template

Use `report-template.md` from this skill's directory as the base.

**To customize:** Add to `~/.claude/CLAUDE.md`:
```markdown
## Docs
- Report template: path/to/your-template.md
```
If configured, use that file instead. Otherwise use `report-template.md`.

---

## Filling the Report

### Header
- **Goal** — what the work was *intended* to deliver
- **Outcome** — what was *actually* delivered (may differ)

### Summary
Metadata only. No narrative here.
- **Scope** — Public or Private (determines anonymization level before sharing)
- **Impact** — list only areas actually affected

### Why
Explain the problem that made this work necessary. One short paragraph.

### Architecture / Flow
Show what changed structurally. Prefer before/after comparison over prose description. Include sequence only for multi-step flows.

### Verification
List exactly what was run. Commands + expected vs actual output. Enough for someone else to reproduce the check.

### Troubleshooting
Freeform. Cover only non-trivial issues: what caused it, how it was resolved, how the fix was confirmed. Write "None." if nothing significant occurred. Do not leave blank.

### References
Links to related issues, docs, or PRs. Skip if none.

---

## Pairing with Plans

Plan and report are linked by matching feature slugs:

```
docs/plans/   2026-02-26-gmail-sync.md               ← written at start
docs/reports/ 2026-03-02-gmail-sync-report.md        ← written at end
```

If a plan exists, reference it in the report header. Feature slug must match exactly.

---

## Kanban Integration (Optional)

If using `managing-kanban`, after saving the report:

1. Find the DONE card for this task
2. Add `[out:{relative-path}]` tag to the card
3. Increment `_rev:N_` in kanban.md

```markdown
## DONE
- [ProjectA][P1][M][ref:path/to/plan][out:path/to/report][done:2026-03-02] Feature name
```

---

## Remember

- Do not leave any section blank — write "None." or "N/A" explicitly
- Feature slug must match between plan and report filenames
- Troubleshooting is not optional to fill — "None." is a valid answer
