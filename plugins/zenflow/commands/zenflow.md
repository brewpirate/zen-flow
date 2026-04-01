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
  6.  /zenflow:refactor    Structured refactoring — analyze, propose, execute
  7.  /zenflow:audit       Audit codebase against standards ("changed" for diff-only)
  8.  /zenflow:review      Code review from a reviewer subagent

 Collaborate
  9.  /zenflow:collab      Working session — delegate issues to fresh agents
  10. /zenflow:docs        Create or update documentation
  11. /zenflow:status      Project snapshot ("recent" to verify work)
  12. /zenflow:check-work  Run all quality gates (lint, format, tests, docs)

 Setup
  13. /zenflow:init        Scan codebase and generate zen.local.md config
──────────────────────────────────────────
```

After printing, ask: "Enter a number (1-13):"

Number-to-skill mapping:
1=zenflow:idea, 2=zenflow:plan, 3=zenflow:dispatch, 4=zenflow:exec-plan,
5=zenflow:bug-fix, 6=zenflow:refactor, 7=zenflow:audit, 8=zenflow:review,
9=zenflow:collab, 10=zenflow:docs, 11=zenflow:status, 12=zenflow:check-work,
13=zenflow:init

Once the user enters a number, invoke the corresponding skill using the Skill tool. If the user adds extra text after the number, pass it as the `args` parameter.
