# Skills Reference

A complete list of all ZenFlow commands and when to use each one.

## Pipeline Commands

These are meant to be used in sequence for a standard feature or fix.

| Command | When to use |
|---------|-------------|
| `/zenflow:init` | Once per project, after installing. Generates `.claude/zen.local.md`. |
| `/zenflow:idea` | At the start of any non-trivial feature. Moves from rough idea to approved design. |
| `/zenflow:plan` | After the design is approved. Writes a step-by-step implementation plan. |
| `/zenflow:dispatch` | When the plan has independent tasks that can run in parallel. |
| `/zenflow:exec-plan` | When tasks are tightly coupled or you want to review each step manually. |
| `/zenflow:check-work` | After implementation. Runs lint, format, tests, docs, and journal. Required before ending the session (enforced by hook). |
| `/zenflow:review` | After `check-work` passes. Dispatches a code reviewer with the git diff. |

## Standalone Commands

These can be invoked at any point, independently of the pipeline.

| Command | What it does |
|---------|-------------|
| `/zen` | Opens the interactive menu listing all available commands. |
| `/zenflow:collab` | Starts a long-running collaborative session (Opus). Delegates side problems to separate agents. |
| `/zenflow:context-refresh` | Writes a handoff document and prepares for a `/clear` + resume without losing context. |
| `/zenflow:bug-fix` | Four-agent bug diagnosis and fix pipeline. |
| `/zenflow:audit` | Audits the codebase against project coding rules. |
| `/zenflow:audit changed` | Same as `audit`, but only for files changed vs. main. |
| `/zenflow:refactor` | Analyzes, proposes, and executes a refactor with regression safety checks. |
| `/zenflow:status` | Shows active plans, git status, and recent journal entries. |
| `/zenflow:status recent` | Verifies recent work was completed and stamps plans as validated. |
| `/zenflow:docs` | Identifies stale documentation and updates it. |

## Auto-invoked

These run automatically and do not need to be called manually.

| Command | When it runs |
|---------|-------------|
| `testing-anti-patterns` (skill rule) | Applied automatically during test-writing stages. Enforces testing real behavior rather than implementation details. |
| `field-notes:write` | Called by `zenflow:check-work` at Gate 5. Falls back to writing JSONL directly if field-notes is not installed. |

## Field Notes Commands

These are part of the [field-notes plugin](/plugins/field-notes/) but integrate directly with ZenFlow.

| Command | What it does |
|---------|-------------|
| `/field-notes:write` | Appends a structured entry to `.claude/journal.jsonl`. |
| `/field-notes:read` | Shows recent entries, with optional filters. |
| `/field-notes:summary` | Aggregates patterns across a time range. |
| `/field-notes:reflect` | Runs an end-of-session retrospective and writes a `reflection` entry. |
