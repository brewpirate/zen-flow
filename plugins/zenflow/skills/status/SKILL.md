---
name: status
description: "Quick project status — active plans, task progress, git state, and session history. Use when resuming work, checking progress, or handing off between sessions. Pass 'recent' to verify each task was actually completed."
---

# Status

## Overview

Show a quick snapshot of where things stand. Reads active plans, task state, git status, and session context to produce a concise status report.

**No confirmation needed** — this skill runs immediately and reports.

**Modes:**
- **Default** — fast scan, checkbox counts, frontmatter status
- **Deep** (`/zenflow:status recent`) — verifies each task was actually completed by checking the codebase, then stamps the plan with `validated` frontmatter

## The Process

### 1. Git State

```bash
git status --short
git log --oneline -5
git diff --stat
```

Report:
- Current branch
- Uncommitted changes (count + summary)
- Recent commits (last 5)
- Ahead/behind remote

### 2. Active Plans

Scan `resources/plans/` for all plans where frontmatter `status` is NOT `complete`. This catches `planned`, `in-progress`, and any other non-terminal state:

Use the `Glob` tool to find plan files, then `Read` each to check frontmatter. A plan is **active** if:
- `status: planned` — not started
- `status: in-progress` — work underway
- `status` field is missing — assumed not complete
- Any value other than `complete`

For each active plan, report:
- Plan name and file path
- Current status from frontmatter
- Task count (total, completed, remaining)
- Checkbox completion: count `- [x]` vs `- [ ]` in the plan
- `validated` field if present (from recent mode)
- `completed` date if present (for recently finished plans)

### 3. Task State

Check if any `TaskList` tasks exist in the current session:
- Pending tasks
- In-progress tasks
- Completed tasks
- Blocked tasks (and what blocks them)

### 4. Zen Skills Used This Session

Check the transcript for zen skill invocations:
- Which skills were invoked
- In what order
- Any that are still in progress (e.g., zenflow:exec-plan started but zenflow:check-work not yet called)

### 5. Journal

Read the most recent entry from `.claude/journal.jsonl` (if it exists):
- What was last worked on
- Any blockers or issues noted
- When the last session ended

## Deep Mode

**Triggered by:** `/zenflow:status recent` or when the user asks to verify/validate a plan.

Deep mode is a **recent work review habit** — it verifies that plans from the last few days were actually completed, so nothing gets overlooked. Run it daily or before handoffs.

### Scope: Recent Plans Only

Deep mode only verifies plans with recent activity (last 72 hours). It finds them by:

1. Plans with `completed` date in the last 72h
2. Plans with `status: in-progress`
3. Plans without a `validated` date (never verified)
4. Plans that have commits touching their listed files in the last 72h (via `git log --since`)

**Skip** plans that already have `validated` date within the last 72h — they've been checked recently.

This keeps recent mode fast and relevant. Old plans that drifted are someone else's problem — recent mode catches fresh work that might have been missed or half-done.

### Deep Verification Process

For each recent plan, verify every task using three signals (most reliable first):

**1. Tests** (strongest signal) — do the test files exist and pass?
```bash
<project-test-command> {test-file-path}
```
If the plan specifies test files, run them. Passing tests prove the behavior works regardless of how the code evolved.

**2. Commits** — did the work happen?
```bash
git log --oneline --since="72 hours ago" -- {file-paths}
```
Check that commits exist for the expected files. The commit message doesn't need to match the task name exactly — just confirm the files were touched.

**3. Files** (weakest signal) — do the expected files exist?
Check that files listed as "Create" exist. For "Modify" files, grep for key function names or types mentioned in the task.

### Task Verdicts

Each task gets a verdict:

| Verdict | Meaning |
|---------|---------|
| `done` | All files exist, changes verified, tests pass |
| `partial` | Some changes present but incomplete |
| `missing` | No evidence the task was implemented |
| `broken` | Files exist but tests fail |

### Deep Output

```
## Deep Verification: 245-realtime-notifications.md

### Task 1: SSE Event Schema — done
  ✓ packages/core/src/types/schema/sse-events.ts exists
  ✓ SSEEventSchema exported
  ✓ tests/unit/types/sse-events.test.ts — 4/4 passing

### Task 2: Stream Handler — partial
  ✓ packages/server/src/server/routes/sse.ts exists
  ✗ Missing: reconnection logic (described in step 4)
  ✓ tests/unit/routes/sse.test.ts — 3/3 passing

### Task 3: Client Subscriber — missing
  ✗ packages/frontend/src/lib/sse-client.ts does not exist
  ✗ No related commits found

Summary: 1 done, 1 partial, 1 missing, 0 broken
```

### Stamping the Plan

After recent verification, update the plan's frontmatter:

```yaml
---
status: complete          # or in-progress if tasks are missing/partial
validated: 2026-03-27
validated_summary: "3/5 done, 1 partial, 1 missing"
---
```

**Frontmatter fields added by recent mode:**

| Field | Type | Description |
|-------|------|-------------|
| `validated` | date | When recent verification was last run |
| `validated_summary` | string | Quick verdict summary |

Only stamp `status: complete` if ALL tasks are `done`. If any are `partial`, `missing`, or `broken`, keep `status: in-progress` and report what needs attention.

## Output Format (Default Mode)

```
## Status

**Branch:** feature/notifications (3 ahead of main, 2 uncommitted files)

**Active Plans:**
- 245-realtime-notifications.md — 3/5 tasks complete (60%)
- 246-audit-config.md — planned (not started)

**Current Session:**
- Tasks: 2 completed, 1 in progress, 2 pending
- Skills used: zenflow:idea → zenflow:plan → zenflow:dispatch (in progress)
- ⚠️ zenflow:check-work not yet invoked

**Last Journal (2026-03-26):**
- Worked on: SSE notification system
- Blocker: Rate limiting config unclear
```

## When to Use

- **Resuming work** — "Where was I?"
- **Before handoff** — summarize state for the next session or agent
- **Mid-session check** — "How much is left?"
- **After errors** — understand current state before debugging
- **Before marking complete** — `/zenflow:status recent` to verify everything was actually done
- **After another agent finished** — recent verify their work before trusting it

## Related Skills

- **zenflow:check-work** — If status shows execution without validation, remind to run it
- **zenflow:docs** — If status shows completed features without doc updates, suggest it
- **zenflow:audit** — If recent mode finds pattern violations, suggest an audit
