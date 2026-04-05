# ZenFlow

ZenFlow is a Claude Code plugin that structures the development process into discrete stages. Rather than a single open-ended session, each piece of work moves through defined steps: idea, plan, execution, validation, and review. Each stage is a separate command with its own inputs, outputs, and quality expectations.

The key discipline: **you never write code before you have a plan, and you never end a session without checking your work.** Enforcement hooks make this automatic — Claude literally cannot skip the validation step, even if you ask it to.

> ZenFlow is derived from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent.

> [!WARNING]
> This plugin is under active development. APIs, commands, and behavior may change without notice.

## Installation

Type these commands inside a Claude Code session (not your regular terminal):

```
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/reload-plugins
```

`field-notes` works well alongside zenflow — it automatically logs each session as zenflow's final validation step. Install it too if you want persistent session history:

```
/plugin install field-notes@zen
/reload-plugins
```

## First-time setup

After installing, run this once in your project:

```
/zenflow:init
```

This scans your project and creates a config file at `.claude/zen.local.md`. Open that file and check what it generated — it auto-detects your language, framework, and doc locations, but you may want to adjust some values before using the pipeline.

Then open the interactive command menu:

```
/zen
```

This lists every available command with a short description. Good starting point if you're not sure what to run next.

## The pipeline

ZenFlow structures work into five sequential stages. Think of it as a checklist that Claude enforces for you:

```
idea → plan → [dispatch | exec-plan] → check-work → review
```

For a detailed breakdown of each stage with examples, see [The Pipeline](/plugins/zenflow/pipeline).

## Collab — the crown jewel

`/zenflow:collab` is where the real work happens. It opens a long-running partnership session with Claude Opus — not a task executor, but a thinking partner that explores, reasons, and delegates alongside you.

The agent stays in strategist mode: it reads code with you, surfaces trade-offs, writes structured handoffs, and spawns delegates for implementation. Side issues get extracted to fresh subagents (inline or in isolated worktrees) rather than handled inline, which keeps the primary session's context clean and its attention focused on the actual goal. When the session runs long, `/zenflow:context-refresh` sheds dead context — file reads, debug output, old diffs — without losing the partnership.

This is not a replacement for the pipeline. The pipeline is for planned feature work. Collab is for the work that can't be planned yet: exploring unfamiliar code, making architectural decisions, debugging something that doesn't have an obvious cause.

**See [Collab](/plugins/zenflow/collab) for the full reference, session patterns, and worked examples.**

## Standalone commands

These work independently of the pipeline — run them any time:

| Command | What it does |
|---------|-------------|
| `/zenflow:collab` | Long-running collaborative session with Claude Opus |
| `/zenflow:bug-fix` | Four-agent pipeline: two diagnose in parallel, one writes the fix, one reviews it |
| `/zenflow:audit` | Reviews your codebase against the coding rules in `.claude/rules/` |
| `/zenflow:audit changed` | Same, but only for files changed relative to main |
| `/zenflow:refactor` | Plans a refactor, checks regression test coverage, then executes |
| `/zenflow:status` | Shows in-progress plans, git status, and recent journal entries |
| `/zenflow:status recent` | Verifies recent work was completed by inspecting commits and tests |
| `/zenflow:docs` | Identifies stale documentation given recent changes and updates it |

## Hooks

Hooks are background scripts that run automatically at defined points in the session lifecycle — you don't invoke them directly. ZenFlow installs three:

| Hook | Type | Behavior |
|------|------|----------|
| `enforce-plan-mode-tools` | Stop | In plan mode, prevents ending a turn without calling `ExitPlanMode` or `AskUserQuestion` — keeps the planning phase from silently collapsing into execution |
| `enforce-work-validation` | Stop | After `exec-plan` or `dispatch`, prevents finishing the session without running `check-work` — nothing ships unvalidated |
| `enforce-local-plans` | PreToolUse | Intercepts plan writes to `~/.claude/plans/` and redirects them to `resources/plans/` so plans are always stored in the project, not the user's global config |

`Stop` hooks run after Claude finishes a response and can block it from ending. `PreToolUse` hooks intercept tool calls before they execute. If a hook fires, Claude receives an explanation and must correct course — it cannot override the hook.

See [Hooks](/plugins/zenflow/hooks) for more detail.

See [Hooks](/plugins/zenflow/hooks) for more detail.
