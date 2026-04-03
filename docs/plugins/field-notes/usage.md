# Reading & Filtering

## Reading entries

`/field-notes:read` shows the last 5 entries formatted for the terminal:

```
◆ Mar 27 2:30 PM | work | completed | primary
  Branch: feature/notifications | Skill: zenflow:dispatch
  Worked on: plan: resources/plans/245-realtime-notifications.md
  Added real-time SSE notifications for issue state changes
  Files: 5 modified, 2 created | Tests: +8
  Insight: Two-stage review caught a missing reconnection handler
  ───
```

## Filters

Pass a filter argument to narrow results:

| Command | Shows |
|---------|-------|
| `/field-notes:read 10` | Last 10 entries |
| `/field-notes:read today` | Entries from today |
| `/field-notes:read bug-fix` | Entries with `type: "bug-fix"` |
| `/field-notes:read blocked` | Entries with `outcome: "blocked"` |
| `/field-notes:read delegated` | Entries with `origin: "delegated"` |
| `/field-notes:read branch feature/x` | Entries from a specific branch |
| `/field-notes:read search "rate limiter"` | Keyword search across all fields |

## Summary

`/field-notes:summary` aggregates the last 7 days by default. Pass a range to change the window:

```
/field-notes:summary week
/field-notes:summary month
/field-notes:summary all
```

Example output:

```
Activity:       12 work, 4 bug-fix, 2 refactor, 3 exploration
Hot Files:      src/routes/api.ts (8 entries), src/core/context.ts (5)
Blockers:       "Mock pollution in tests" (3x), "Rate limiter unclear" (2x, resolved)
Top Insight:    Two-stage review catches different failure modes (3 mentions)
Skills:         zenflow:dispatch (8), zenflow:collab (5), zenflow:bug-fix (4)

Health:
  Bug-fix ratio:         17% (healthy < 25%)
  Workaround ratio:       9% (healthy < 15%)
  Blocker-free sessions: 78%
```

The health section flags patterns that might indicate process issues. High bug-fix ratios can suggest insufficient upfront planning; high workaround ratios can suggest recurring unresolved problems.

## Reflect

`/field-notes:reflect` runs an end-of-session retrospective:

1. Reads recent entries to reconstruct a session timeline
2. Identifies what went well, what was harder than expected, and what was learned
3. Generates actionable takeaways (documentation gaps, rule updates, process changes)
4. Writes a `reflection` type entry to the journal
5. Offers to act on suggestions immediately (update docs, create issues, update rules)

Example:

```
You: /field-notes:reflect

Session Timeline:
  10:15 — Started zenflow:collab, exploring SSE
  10:30 — Delegated rate limiter bug to worktree
  10:45 — Designed notification schema
  11:00 — Created plan, started zenflow:dispatch
  12:30 — All tasks complete, check-work passed

What Went Well:
  Worktree delegation kept context clean
  Two-stage review caught reconnection gap

Suggested Actions:
  - Add SSE keep-alive docs to ARCHITECTURE.md
  - Add timing test conventions to testing rules

"Any of these worth doing now?"
```

## Browser viewer

Open `plugins/field-notes/scripts/journal.html` in a browser, select your `journal.jsonl` file, and use the search and filter chips to browse entries. The viewer uses a Tokyo Night color scheme and color-codes entries by outcome.

Open directly from the terminal without a server:

```bash
xdg-open "file://$(realpath scripts/journal.html)#$(base64 -w0 .claude/journal.jsonl)"
```
