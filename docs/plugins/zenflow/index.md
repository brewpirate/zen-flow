# ZenFlow

ZenFlow is a Claude Code plugin that structures the development process into discrete stages. Rather than a single open-ended session, each piece of work moves through defined steps: idea, plan, execution, validation, and review. Each stage is a separate command with its own inputs, outputs, and quality expectations.

The plugin includes enforcement hooks that prevent skipping stages — for example, you cannot end an execution session without running `check-work` first.

> ZenFlow is derived from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent.

> [!WARNING]
> This plugin is under active development. APIs, commands, and behavior may change without notice.

## Installation

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/reload-plugins
```

Installing `field-notes` alongside is recommended — `zenflow:check-work` invokes it automatically in Gate 5:

```bash
/plugin install field-notes@zen
/reload-plugins
```

## Setup (once per project)

After installing, generate the project config:

```
/zenflow:init
```

This creates `.claude/zen.local.md` with YAML frontmatter for structured settings and a markdown body for freeform notes. It auto-detects your project's language, framework, documentation paths, and maps codebase sections to agents. Review the generated file and adjust before running the pipeline.

Then open the interactive menu to see all available commands:

```
/zen
```

## Pipeline

The core workflow moves through five stages:

```
idea → plan → [dispatch | exec-plan] → check-work → review
```

See [The Pipeline](/plugins/zenflow/pipeline) for a full breakdown of each stage.

## Collab — The Crown Jewel

`/zenflow:collab` is where the real work happens. It opens a long-running partnership session with Claude Opus — not a task executor, but a thinking partner that explores, reasons, and delegates alongside you.

The agent stays in strategist mode: it reads code with you, surfaces trade-offs, writes structured handoffs, and spawns delegates for implementation. Side issues get extracted to fresh subagents (inline or in isolated worktrees) rather than burning primary session context. When the session gets long, a context refresh sheds dead context without losing the partnership.

**See [Collab](/plugins/zenflow/collab) for the full reference, session patterns, and worked examples.**

## Standalone Commands

Several commands work outside the pipeline:

- `/zenflow:collab` — long-running collaborative session (Opus). See [Collab](/plugins/zenflow/collab).
- `/zenflow:bug-fix` — runs a four-agent diagnostic pipeline to identify and fix a bug.
- `/zenflow:audit` — audits codebase sections against your project's coding rules.
- `/zenflow:refactor` — structured refactoring that checks for regression coverage before making changes.
- `/zenflow:status` — shows active plans, git status, and recent journal entries.

## Hooks

Three enforcement hooks install automatically with the plugin:

| Hook | Type | Behavior |
|------|------|----------|
| `enforce-plan-mode-tools` | Stop | In plan mode, prevents ending a turn without calling `ExitPlanMode` or `AskUserQuestion` |
| `enforce-work-validation` | Stop | After `exec-plan` or `dispatch`, prevents finishing without running `check-work` |
| `enforce-local-plans` | PreToolUse | Redirects plan writes from `~/.claude/plans/` to the project's `resources/plans/` directory |

See [Hooks](/plugins/zenflow/hooks) for more detail.
