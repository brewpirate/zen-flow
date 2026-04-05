# ZenFlow

ZenFlow is a Claude Code plugin that gives your development sessions structure. Instead of a single open-ended "build this" conversation, work moves through defined stages: explore the idea, write a plan, execute it, validate everything, then review. Each stage is a separate command with clear inputs and outputs.

The key idea: **you never write code before you have a plan, and you never end a session without checking your work.** Enforcement hooks (background rules) make this automatic — Claude literally cannot skip the validation step.

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

## Collab — working with Claude as a partner

`/zenflow:collab` is different from the pipeline. It opens a long-running session with Claude Opus where you work together interactively — exploring the codebase, thinking through designs, troubleshooting. Claude acts as a thinking partner rather than a task executor.

When a side problem comes up mid-session, collab delegates it to a separate agent (either inline or in an isolated git worktree) instead of handling it inline. This keeps the main session focused and prevents context from getting cluttered.

When the session runs long, `/zenflow:context-refresh` writes a structured handoff document so you can run `/clear` and resume without losing your place.

**See [Collab](/plugins/zenflow/collab) for the full reference and examples.**

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

Hooks are background rules that run automatically — you don't invoke them directly. ZenFlow installs three:

| Hook | What it prevents |
|------|-----------------|
| `enforce-plan-mode-tools` | Ending a planning turn without exiting plan mode or asking a question — keeps the planning phase disciplined |
| `enforce-work-validation` | Ending an execution session without running `check-work` — ensures nothing ships without validation |
| `enforce-local-plans` | Writing plan files to `~/.claude/plans/` — redirects them to your project's `resources/plans/` so plans stay in the repo |

If Claude tries to skip a required step, the hook stops it and explains why. This is by design.

See [Hooks](/plugins/zenflow/hooks) for more detail.
