# Field Notes

Field Notes appends structured log entries to a `.claude/journal.jsonl` file after work sessions. It provides commands to write entries, filter and read past entries, summarize patterns across sessions, and run end-of-session retrospectives.

> [!WARNING]
> This plugin is under active development. APIs, commands, and behavior may change without notice.

## Why

When a Claude Code session ends, the context is gone. Field Notes captures a structured record of what happened — what was worked on, what went wrong, what was learned — so the next session or the next agent doesn't start from scratch.

The journal is also useful for humans. You can filter by branch, outcome, or date to see exactly what agents have been doing. Over time, summary and reflect commands surface patterns: which files keep causing problems, which blockers recur, whether the bug-fix ratio is trending in the wrong direction.

## Installation

Type these commands inside a Claude Code session:

```
/plugin marketplace add brewpirate/zenflow
/plugin install field-notes@zen
/reload-plugins
```

## Quick start

At the end of a work session, log what happened:

```
/field-notes:write
```

Claude will ask a few questions — what you worked on, how it went, any blockers, and what you learned — then append the entry to `.claude/journal.jsonl`.

To see recent entries:

```
/field-notes:read
```

To see a summary of the past week:

```
/field-notes:summary
```

## Commands

| Command | What it does |
|---------|-------------|
| `/field-notes:write` | Asks for session details and appends an entry to `journal.jsonl` |
| `/field-notes:read [filter]` | Shows recent entries, with optional filtering |
| `/field-notes:summary [range]` | Aggregates patterns across a time range |
| `/field-notes:reflect` | Runs an end-of-session retrospective and writes a `reflection` entry |
| `/field-notes:view` | Opens the journal in your browser |

## Reading and filtering entries

`/field-notes:read` shows the last 5 entries. Pass a filter to narrow results:

```
/field-notes:read 10                      # Last 10 entries
/field-notes:read today                   # Only today
/field-notes:read blocked                 # Sessions that got stuck
/field-notes:read bug-fix                 # Bug-fix sessions only
/field-notes:read branch feature/login    # Work on a specific branch
/field-notes:read search "auth"           # Search across all fields
```

## Summaries and patterns

```
/field-notes:summary           # Last 7 days (default)
/field-notes:summary week
/field-notes:summary month
/field-notes:summary all
```

A summary shows you things like:

- Which files keep getting modified (hot files)
- Blockers that come up repeatedly
- The ratio of bug-fix sessions to feature sessions
- How often sessions get blocked vs. completing successfully

High bug-fix ratios can indicate insufficient planning. Recurring blockers with the same description usually mean something needs to be documented or fixed permanently.

## End-of-session retrospectives

```
/field-notes:reflect
```

Reads your recent journal entries, builds a timeline of the session, and identifies:

- What went well
- What was harder than expected
- What could be improved

Then suggests follow-up actions — documentation gaps to fill, rules to add, issues to file — and asks if you want to act on them immediately.

## How logging connects to ZenFlow

If you have `zenflow` installed, logging is automatic. The final step of `zenflow:check-work` (Gate 5) calls `field-notes:write` and prompts for the entry. You don't need to remember to log.

Other automatic integrations:
- `zenflow:collab` calls `field-notes:reflect` at the end of a session
- Agents spawned by `zenflow:collab` write entries with `origin: "delegated"` so you can tell their work apart from the primary session
- `zenflow:idea` writes an `exploration` entry when an exploration session wraps up

## Storage

All entries go to a single file: `.claude/journal.jsonl`

Each line is one JSON object, appended in order. Example entry:

```json
{
  "timestamp": "2026-03-27T14:30:00.000Z",
  "workedOn": "feature/notifications — SSE endpoint",
  "branch": "feature/notifications",
  "type": "work",
  "outcome": "completed",
  "summary": "Added real-time SSE notifications for issue state changes",
  "insights": "Two-stage review caught a missing reconnection handler",
  "blockers": ""
}
```

The file is intentionally simple:

- **Append-only** — multiple agents can write entries at the same time without conflicts
- **Searchable with basic tools** — `grep "blocked" .claude/journal.jsonl` works with no extra tooling
- **No dependencies** — any language or tool can read it

You can commit this file to your repository or add it to `.gitignore` depending on whether you want shared history.

## Browser viewer

The plugin includes an HTML viewer at `plugins/field-notes/scripts/journal.html`. Open it in a browser, pick your `journal.jsonl` file, and browse entries with search and filter chips.

```
/field-notes:view
```

Or open it directly from the terminal without a server:

```bash
xdg-open "file://$(realpath scripts/journal.html)#$(base64 -w0 .claude/journal.jsonl)"
```

The viewer shows:
- A stats bar (entry count, completed, blocked, delegated)
- Filter chips for type, outcome, and origin
- Full-text search across all fields
- Color-coded entries by outcome
