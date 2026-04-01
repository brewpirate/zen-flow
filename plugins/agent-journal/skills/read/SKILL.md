---
name: read
description: Read recent journal entries. Use when resuming work, checking what was done recently, or reviewing a specific session's history.
---

# Journal: Read

## Overview

Read and display journal entries. Supports filtering by time range, type, branch, outcome, origin, or keyword.

**No confirmation needed** — runs immediately and displays results.

## Journal Location

Reads from `.claude/journal.jsonl` in the project root. If the file doesn't exist, report that no journal exists and suggest running `agent-journal:write`.

## Modes

### Recent (default)

Show the last N entries (default: 5):

```
/agent-journal:read
/agent-journal:read 10
```

### By type

Filter to a specific entry type:

```
/agent-journal:read bug-fix
/agent-journal:read refactor
```

### By time

Filter to entries from a time range:

```
/agent-journal:read today
/agent-journal:read week
/agent-journal:read 2026-03-27
```

### By branch

Filter to entries from a specific branch:

```
/agent-journal:read branch feature/notifications
```

### By outcome

Filter to entries with a specific outcome:

```
/agent-journal:read blocked
/agent-journal:read partial
```

### By origin

Show only primary sessions or delegated work:

```
/agent-journal:read delegated
/agent-journal:read primary
```

### By keyword

Search across all text fields (summary, workedOn, issues, insights, feedback):

```
/agent-journal:read search SSE
/agent-journal:read search "rate limiter"
```

## Display Format

Present entries in reverse chronological order (newest first):

```
## Journal — last 5 entries

◆ 2026-03-27 14:30 | work | completed | primary
  Branch: feature/notifications | Skill: zenflow:dispatch
  Worked on: plan: resources/plans/245-realtime-notifications.md
  Added real-time SSE notifications for issue state changes
  Files: 5 modified, 2 created | Tests: +8
  Insight: Two-stage review caught a missing reconnection handler
  Feedback: Worktree delegation kept context clean during side fix

◆ 2026-03-27 10:15 | bug-fix | completed | delegated
  Branch: fix/rate-limiter | Skill: zenflow:bug-fix
  Worked on: issue: rate limiter counter not resetting
  Fixed rate limiter counter not resetting between windows
  Files: 1 modified | Tests: +1

◆ 2026-03-26 16:00 | exploration | partial | primary
  Branch: feature/mastra | Skill: zenflow:collab
  Worked on: Mastra workflow integration patterns
  Explored Mastra workflow integration patterns
  Insight: Mastra's step() API changed in 0.5 — docs are outdated
  Would do differently: Check installed version before reading remote docs
  Feedback: Remote docs should be version-pinned in bookmarks

◆ 2026-03-26 11:00 | work | blocked | delegated
  Branch: fix/sse-backoff | Skill: zenflow:plan
  Worked on: plan: resources/plans/244-sse-backoff.md
  Attempted SSE backoff implementation, blocked by unclear retry semantics
  Blocker: No spec for max retry count — needs product decision

(4 entries shown, 23 total)
```

### Display rules

- Show `origin` badge (`primary` or `delegated`) — makes it clear who did the work
- Show `outcome` — `completed` entries are normal, highlight `blocked` and `partial`
- Only show non-empty optional fields (skip "Blocker: None" noise)
- `workedOn` always shown — it's the anchor for what this entry is about
- `feedback` shown when present — it's the meta-level learning

## The Process

1. Read `.claude/journal.jsonl`
2. Parse each line as JSON
3. Apply filters (type, time, branch, outcome, origin, keyword) if specified
4. Format and display in reverse chronological order
5. Show entry count summary

## Related Skills

- **agent-journal:write** — Append new entries
- **agent-journal:summary** — Aggregate patterns
- **agent-journal:reflect** — Session retrospective
