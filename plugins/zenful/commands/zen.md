---
name: zen
description: Show the zen workflow menu — pick a skill to invoke
---

Use AskUserQuestion to present zen workflow options. The tool supports max 4 options per question, so use a two-step flow: category first, then specific skill.

**Step 1 — Choose category:**

Question: "What do you want to do?"
Header: "Zen"

Options:
1. **Build something** — "Start a new feature: idea → plan → execute → validate"
2. **Fix or improve** — "Bug fix, refactor, audit, or code review"
3. **Work together** — "Collaborative session, docs, or status check"

**Step 2 — Based on category chosen:**

**If "Build something":**

Question: "Which build workflow?"
Header: "Build"

Options:
1. **zen:idea** — "Brainstorm and design. Three modes: explore, discover, design."
2. **zen:plan** — "Write a detailed implementation plan from a spec or design."
3. **zen:dispatch** — "Execute a plan with parallel subagents per task."
4. **zen:exec-plan** — "Execute a plan step-by-step with review checkpoints."

**If "Fix or improve":**

Question: "Which fix/improve workflow?"
Header: "Fix"

Options:
1. **zen:bug-fix** — "Diagnose and fix a bug with parallel diagnostic agents."
2. **zen:refactor** — "Structured refactoring — analyze, propose, test, execute."
3. **zen:audit** — "Audit codebase against code standards. Pass 'changed' for diff-only."
4. **zen:review** — "Request a code review from a reviewer subagent."

**If "Work together":**

Question: "Which workflow?"
Header: "Collab"

Options:
1. **zen:collab** — "Collaborative session — explore, build, delegate issues to fresh agents."
2. **zen:status** — "Quick snapshot: plans, tasks, git state. Pass 'recent' to verify work."
3. **zen:docs** — "Create or update project documentation."
4. **zen:check-work** — "Run all quality gates: lint, format, tests, docs, journal."

After the user selects a skill, invoke it using the Skill tool with the selected skill name (e.g., `skill: "zen:idea"`). If the user provides additional context with their selection, pass it as the `args` parameter.
