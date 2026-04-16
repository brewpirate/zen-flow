---
name: zenflow
description: Show the zenflow workflow menu — pick a skill to invoke
---

Print this numbered menu, then ask the user to enter a number:

```
Zenflow Skills
──────────────────────────────────────────

 Build
  1.  /zenflow:idea        Brainstorm and design (explore → discover → design)
  2.  /zenflow:plan        Write implementation plan from spec or design
  3.  /zenflow:dispatch    Execute plan with parallel subagents
  4.  /zenflow:exec-plan   Execute plan step-by-step with checkpoints

 Fix & Improve
  5.  /zenflow:bug-fix     Diagnose and fix with parallel diagnostics

 Collaborate
  6.  /zenflow:collab           Working session — delegate issues to fresh agents
  7.  /zenflow:context-refresh  Shed context mid-session with a knowledge handoff
  8.  /zenflow:docs             Create or update documentation
  9.  /zenflow:check-work       Run all quality gates (lint, format, tests, docs)

 Setup
  10. /zenflow:init        Scan codebase and generate zen.local.md config
──────────────────────────────────────────
```

After printing, ask: "Enter a number (1-10):"

Number-to-skill mapping:
1=zenflow:idea, 2=zenflow:plan, 3=zenflow:dispatch, 4=zenflow:exec-plan,
5=zenflow:bug-fix, 6=zenflow:collab, 7=zenflow:context-refresh, 8=zenflow:docs,
9=zenflow:check-work, 10=zenflow:init

Once the user enters a number, invoke the corresponding skill using the Skill tool. If the user adds extra text after the number, pass it as the `args` parameter.
