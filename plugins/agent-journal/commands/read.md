---
name: read
description: Read recent journal entries. Use when resuming work, checking what was done recently, or reviewing a specific session's history.
---

Invoke the `agent-journal:read` skill using the Skill tool. If the user provided arguments, pass them as the `args` parameter.

Examples:
- `/agent-journal:read` — show last 5 entries
- `/agent-journal:read 10` — show last 10 entries
- `/agent-journal:read today` — entries from today
- `/agent-journal:read search SSE` — keyword search
