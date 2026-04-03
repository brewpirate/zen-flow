# Entry Schema

Each entry in `.claude/journal.jsonl` is a JSON object on a single line. The schema is open — you can add custom fields — but the fields below define the standard structure.

## Full example

```json
{
  "timestamp": "2026-03-27T14:30:00.000Z",
  "workedOn": "plan: resources/plans/245-notifications.md",
  "branch": "feature/notifications",
  "type": "work",
  "origin": "primary",
  "skill": "zenflow:dispatch",
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

## Required fields

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string | ISO 8601 timestamp |
| `workedOn` | string | What this entry is about — plan path, issue number, or freeform description |
| `type` | string | Entry type (see values below) |
| `summary` | string | One sentence describing what was accomplished |

### `type` values

| Value | When to use |
|-------|-------------|
| `work` | Standard implementation work |
| `bug-fix` | A bug was diagnosed and fixed |
| `refactor` | Code was refactored |
| `audit` | A code audit was run |
| `exploration` | Exploratory research or ideation |
| `review` | A code review was done |
| `reflection` | End-of-session retrospective (written by `reflect`) |

## Optional fields

| Field | Type | Description |
|-------|------|-------------|
| `branch` | string | Git branch name |
| `origin` | string | `primary` (user's session) or `delegated` (spawned subagent) |
| `skill` | string | Which zenflow skill was active, e.g. `zenflow:dispatch` |
| `outcome` | string | `completed`, `partial`, `blocked`, or `abandoned` |
| `details` | object | Files modified/created, tests added — structure is freeform |
| `issues` | string | What went wrong or was harder than expected |
| `blockers` | string | What is preventing progress (for `blocked` outcomes) |
| `workarounds` | string | How blockers were worked around |
| `insights` | string | Something learned that's worth remembering |
| `wouldDoDifferently` | string | Retrospective notes for next time |
| `feedback` | string | Meta-level observations about the process |
| `duration` | string | Rough time spent (freeform, e.g. "2 hours", "45 min") |

## How `reflect` uses the schema

`/agent-journal:reflect` reads recent entries, constructs a session timeline, and then writes a new entry with `type: "reflection"`. The reflection entry's `summary` captures key takeaways, and the `insights` and `wouldDoDifferently` fields contain actionable notes.

## Custom fields

The schema is open. Any additional fields you include are stored and surfaced by `read` and `summary`. For example, you might add a `prNumber` field to link entries to pull requests.
