# Agent Journal

A structured work journal for Claude Code agents. Write entries, read history, surface patterns, and reflect on sessions — all stored in a single JSONL file per project.

## Why

Agents do work, then the session ends and the context is gone. The journal captures what happened, what went wrong, and what was learned — so the next session (or the next agent) doesn't start from zero.

It's also a record for humans. Open the HTML viewer, filter by branch or outcome, and see exactly what your agents have been doing.

## Installation

```bash
/plugin marketplace add brewpirate/zen-flow
/plugin install agent-journal@zen
/reload-plugins
```

## Quick Start

```
/agent-journal:write                    # Record what you just did
/agent-journal:read                     # See last 5 entries
/agent-journal:read today               # Today's entries
/agent-journal:read blocked             # What's stuck
/agent-journal:summary                  # Patterns from the last week
/agent-journal:reflect                  # End-of-session retrospective
```

## Skills

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| Write | `/agent-journal:write` | Append a structured entry after completing work |
| Read | `/agent-journal:read [filter]` | View recent entries with filtering |
| Summary | `/agent-journal:summary [range]` | Aggregate patterns across sessions |
| Reflect | `/agent-journal:reflect` | End-of-session retrospective with actionable takeaways |

## Storage

Single file: `.claude/journal.jsonl` — one JSON object per line, append-only.

```
.claude/
  journal.jsonl      # The journal (JSONL)
```

JSONL was chosen over SQLite, markdown, or separate files because:
- **Append-only** — no merge conflicts, even when committed to git
- **Greppable** — `grep "blocked" .claude/journal.jsonl` works
- **Portable** — no dependencies, no migrations, no schema versioning
- **Machine-readable** — every line is valid JSON, parseable by any language

## Entry Schema

```json
{
  "timestamp": "2026-03-27T14:30:00.000Z",
  "workedOn": "plan: resources/plans/245-notifications.md",
  "branch": "feature/notifications",
  "type": "work",
  "origin": "primary",
  "skill": "zen:dispatch",
  "outcome": "completed",
  "summary": "Added real-time SSE notifications for issue state changes",
  "details": {
    "filesModified": ["src/routes/sse.ts", "src/types/events.ts"],
    "filesCreated": ["src/lib/sse-client.ts"],
    "testsAdded": 8,
    "testsModified": 0
  },
  "issues": "",
  "blockers": "",
  "workarounds": "",
  "insights": "Two-stage review caught a missing reconnection handler",
  "wouldDoDifferently": "Check Bun OTel compatibility before starting",
  "feedback": "Worktree delegation kept context clean during side fix",
  "duration": "4 hours"
}
```

### Required Fields

| Field | Description |
|-------|-------------|
| `timestamp` | ISO 8601 |
| `workedOn` | What this is about — plan path, issue number, or freeform description |
| `type` | `work`, `bug-fix`, `refactor`, `audit`, `exploration`, `review`, `reflection` |
| `summary` | One sentence describing what was accomplished |

### Key Optional Fields

| Field | Description |
|-------|-------------|
| `branch` | Git branch name |
| `origin` | `primary` (user's session) or `delegated` (spawned agent) |
| `skill` | Which skill was active (e.g., `zen:dispatch`) |
| `outcome` | `completed`, `partial`, `blocked`, `abandoned` |
| `feedback` | Meta-level process observations |

All other fields are optional. The schema is open — add custom fields as needed.

## Reading Entries

### In Claude Code

`/agent-journal:read` formats entries for the terminal:

```
◆ Mar 27 2:30 PM | work | completed | primary
  Branch: feature/notifications | Skill: zen:dispatch
  Worked on: plan: resources/plans/245-realtime-notifications.md
  Added real-time SSE notifications for issue state changes
  Files: 5 modified, 2 created | Tests: +8
  Insight: Two-stage review caught a missing reconnection handler
  ───
```

**Filters:**
- `/agent-journal:read 10` — last 10 entries
- `/agent-journal:read today` — today's entries
- `/agent-journal:read bug-fix` — by type
- `/agent-journal:read blocked` — by outcome
- `/agent-journal:read delegated` — by origin
- `/agent-journal:read branch feature/x` — by branch
- `/agent-journal:read search "rate limiter"` — keyword search

### In a Browser

Open `scripts/journal.html` and pick your `journal.jsonl` file. Or use the hash trick for zero-server viewing:

```bash
xdg-open "file://$(realpath scripts/journal.html)#$(base64 -w0 .claude/journal.jsonl)"
```

The viewer provides:
- Search across all fields
- Filter chips for type, outcome, origin
- Stats bar (entries, completed, blocked, delegated)
- Color-coded entries by outcome (green/yellow/red)
- Tokyo Night theme

## Summary & Health

`/agent-journal:summary` analyzes the last 7 days (or specify `week`, `month`, `all`):

```
Activity:       12 work, 4 bug-fix, 2 refactor, 3 exploration
Hot Files:      src/routes/api.ts (8 entries), src/core/context.ts (5)
Blockers:       "Mock pollution in tests" (3x), "Rate limiter unclear" (2x, resolved)
Top Insight:    Two-stage review catches different failure modes (3 mentions)
Skills:         zen:dispatch (8), zen:collab (5), zen:bug-fix (4)

Health:
  Bug-fix ratio:        17% (healthy < 25%)
  Workaround ratio:      9% (healthy < 15%)
  Blocker-free sessions: 78%
```

## Reflect

`/agent-journal:reflect` is an end-of-session retrospective:

1. Reconstructs a timeline of what happened
2. Analyzes what went well, what was harder than expected, what was learned
3. Produces actionable takeaways (doc gaps, rule updates, process improvements)
4. Writes a `reflection` type journal entry
5. Offers to act on suggestions (update docs, create issues, update rules)

## Integration with Zen Flow

`zen:check-work` Gate 5 invokes `agent-journal:write` automatically. If agent-journal isn't installed, it falls back to appending directly to `.claude/journal.jsonl` with the full schema.

Other zen skills that write journal entries:
- `zen:reflect` (via agent-journal:reflect)
- `zen:collab` delegates (via agent-journal:write with `origin: "delegated"`)

## Plugin Structure

```
agent-journal/
├── .claude-plugin/
│   └── plugin.json
├── scripts/
│   └── journal.html          # Browser-based viewer (Tokyo Night)
└── skills/
    ├── write/SKILL.md         # agent-journal:write
    ├── read/SKILL.md          # agent-journal:read
    ├── summary/SKILL.md       # agent-journal:summary
    └── reflect/SKILL.md       # agent-journal:reflect
```



### Session Reflection

```
You: /agent-journal:reflect
  → Session Timeline:
    10:15 — Started zen:collab, exploring SSE
    10:30 — Delegated rate limiter bug to worktree
    10:45 — Designed notification schema
    11:00 — Created plan, started zen:dispatch
    12:30 — All tasks complete, check-work passed

  → What Went Well:
    Worktree delegation kept context clean
    Two-stage review caught reconnection gap

  → Suggested Actions:
    - [ ] Add SSE keep-alive docs to ARCHITECTURE.md
    - [ ] Add timing test conventions to testing rules

  → "Any of these worth doing now?"
```
