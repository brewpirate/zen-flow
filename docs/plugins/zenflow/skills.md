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

## Standalone Commands

These can be invoked at any point, independently of the pipeline.

| Command | What it does |
|---------|-------------|
| `/zen` | Opens the interactive menu listing all available commands. |
| `/zenflow:collab` | Long-running collaborative session (Opus). You and the agent work as partners — exploring, deciding, delegating. See the [Collab](/plugins/zenflow/collab) page. |
| `/zenflow:context-refresh` | Writes a handoff document and prepares for a `/clear` + resume without losing context. Used within a collab session. |
| `/zenflow:bug-fix` | Four-agent bug diagnosis and fix pipeline. |
| `/zenflow:docs` | Identifies stale documentation and updates it. |

> **Temporarily removed (2026-04-15):** `/zenflow:audit`, `/zenflow:refactor`, `/zenflow:review`, `/zenflow:status`, and the `testing-anti-patterns` skill. Tracked in issues [#8](https://github.com/brewpirate/zen-flow/issues/8)–[#12](https://github.com/brewpirate/zen-flow/issues/12) for restoration.

## Auto-invoked

These run automatically and do not need to be called manually.

| Command | When it runs |
|---------|-------------|
| `field-notes:write` | Called by `zenflow:check-work` at Gate 5. Falls back to writing JSONL directly if field-notes is not installed. |

## Field Notes Commands

These are part of the [field-notes plugin](/plugins/field-notes/) but integrate directly with ZenFlow.

| Command | What it does |
|---------|-------------|
| `/field-notes:write` | Appends a structured entry to `.claude/journal.jsonl`. |
| `/field-notes:read` | Shows recent entries, with optional filters. |
| `/field-notes:summary` | Aggregates patterns across a time range. |
| `/field-notes:reflect` | Runs an end-of-session retrospective and writes a `reflection` entry. |
