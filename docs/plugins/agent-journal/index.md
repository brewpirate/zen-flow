# Agent Journal

Agent Journal is a Claude Code plugin that appends structured log entries to a `.claude/journal.jsonl` file after work sessions. It provides commands to write entries, filter and read past entries, summarize patterns across sessions, and run end-of-session retrospectives.

::: warning Experimental
This plugin is under active development. APIs, commands, and behavior may change without notice.
:::

## Why

When a Claude Code session ends, the context is gone. Agent Journal captures a structured record of what happened — what was worked on, what went wrong, what was learned — so the next session or the next agent doesn't start from scratch.

The journal is also useful for humans. You can filter by branch, outcome, or date to see exactly what agents have been doing.

## Installation

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install agent-journal@zen
/reload-plugins
```

## Commands

| Command | What it does |
|---------|-------------|
| `/agent-journal:write` | Prompts for details and appends a structured entry to `journal.jsonl` |
| `/agent-journal:read [filter]` | Shows recent entries, with optional filtering |
| `/agent-journal:summary [range]` | Aggregates patterns across a time range |
| `/agent-journal:reflect` | Runs a retrospective and writes a `reflection` entry |
| `/agent-journal:view` | Opens the journal in the browser using the HTML viewer |

## Storage

All entries go to a single file: `.claude/journal.jsonl`

One JSON object per line, appended in chronological order. The format was chosen specifically because:

- **Append-only** — multiple agents can write entries without merge conflicts
- **Greppable** — `grep "blocked" .claude/journal.jsonl` works without any tooling
- **No dependencies** — any language can parse it, no migration needed

The file can be committed to the repository or added to `.gitignore`, depending on team preference.

## Integration with ZenFlow

`/zenflow:check-work` invokes `agent-journal:write` automatically as Gate 5. If agent-journal is not installed, `check-work` falls back to writing a journal entry directly to `.claude/journal.jsonl` using the same schema.

Other automatic integrations:
- `zenflow:collab` triggers `agent-journal:reflect` at the end of a session
- `zenflow:collab` delegate agents write entries with `origin: "delegated"` to distinguish their work from the primary session
- `zenflow:idea` writes `exploration` type entries when an exploration session completes

## Browser Viewer

The plugin includes an HTML viewer at `plugins/agent-journal/scripts/journal.html`. Open it in a browser, pick your `journal.jsonl` file, and browse entries with search and filter chips.

Alternatively, open it directly from the terminal without a server:

```bash
xdg-open "file://$(realpath scripts/journal.html)#$(base64 -w0 .claude/journal.jsonl)"
```

The viewer shows:
- A stats bar (entry count, completed, blocked, delegated)
- Filter chips for type, outcome, and origin
- Full-text search across all fields
- Color-coded entries by outcome
