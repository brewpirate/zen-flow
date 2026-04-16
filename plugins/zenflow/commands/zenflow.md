---
name: zenflow
description: Show the zenflow workflow menu — pick a skill to invoke
---

Print this numbered menu, then ask the user to enter a number:

```
Zenflow Skills
──────────────────────────────────────────

 Plan
  1.  /zenflow:idea        Brainstorm and design (explore → discover → design)
  2.  /zenflow:plan        Write implementation plan from spec or design

 Build
  3.  /zenflow:build       Build a GitHub issue into a PR
  4.  /zenflow:dispatch    Execute plan with parallel subagents
  5.  /zenflow:exec-plan   Execute plan step-by-step with checkpoints

 Review
  6.  /zenflow:review      Review a PR with structured verification

 Fix & Improve
  7.  /zenflow:bug-fix     Diagnose and fix with parallel diagnostics

 Collaborate
  8.  /zenflow:collab           Working session — plan and create issues together
  9.  /zenflow:context-refresh  Shed context mid-session with a knowledge handoff
  10. /zenflow:docs             Create or update documentation
  11. /zenflow:check-work       Run all quality gates (lint, format, tests, docs)

 Setup
  12. /zenflow:init        Scan codebase and generate zen.local.md config
  13. /zenflow:schedule    Schedule periodic trigger/rule refresh
──────────────────────────────────────────
```

After printing, ask: "Enter a number (1-13):"

Number-to-skill mapping:
1=zenflow:idea, 2=zenflow:plan, 3=zenflow:build, 4=zenflow:dispatch, 5=zenflow:exec-plan,
6=zenflow:review, 7=zenflow:bug-fix, 8=zenflow:collab, 9=zenflow:context-refresh,
10=zenflow:docs, 11=zenflow:check-work, 12=zenflow:init, 13=zenflow:schedule

Once the user enters a number, invoke the corresponding skill using the Skill tool. If the user adds extra text after the number, pass it as the `args` parameter.
