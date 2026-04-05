# Getting Started

> [!WARNING]
> All plugins are under active development. APIs and behavior may change without notice.

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed and authenticated
- A project directory with Claude Code initialized (`.claude/` folder)

## Installation

Add the marketplace registry, then install whichever plugins you want:

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/plugin install field-notes@zen
/plugin install total-recall@zen
/reload-plugins
```

The plugins are independent — you can install any subset. That said, `field-notes` integrates with `zenflow:check-work` (Gate 5 auto-invokes it), so the two are commonly installed together.

### Install only what you need

| Goal | Install |
|------|---------|
| Structured development pipeline | `zenflow` |
| Session logging only | `field-notes` |
| Context recall only | `total-recall` |
| Full suite | all three |

## What each plugin installs

**zenflow** — Adds commands under `/zenflow:*`, three enforcement hooks, and three agents. Run `/zenflow:init` once after installing to generate a `.claude/zen.local.md` config file for your project.

**field-notes** — Adds commands under `/field-notes:*` and a browser-based HTML viewer at `plugins/field-notes/scripts/journal.html`. Writes structured entries to `.claude/journal.jsonl`.

**total-recall** — Adds commands under `/total-recall:*` and a background rule that instructs agents to check `.claude/recall-index.json` before re-reading files. Writes to `.claude/triggers.json` and `.claude/recall-index.json`.

---

## Using ZenFlow

### Setup (once per project)

After installing, generate the project config:

```
/zenflow:init
```

This scans your project and creates `.claude/zen.local.md` with detected language, framework, documentation paths, and agent-to-domain mappings. Review it and adjust before running the pipeline.

Open the interactive menu to see all available commands:

```
/zen
```

### The development pipeline

ZenFlow structures work through five stages:

```
/zenflow:idea → /zenflow:plan → /zenflow:dispatch (or exec-plan) → /zenflow:check-work → /zenflow:review
```

**Starting a new feature:**

```
/zenflow:idea
```

Describe your idea. The command picks a mode automatically — exploration (vague ideas), discovery (clear problem, unclear solution), or design (clear requirements). No code is written until you approve the design.

**Writing a plan:**

```
/zenflow:plan
```

Produces a step-by-step implementation plan saved to `resources/plans/`. Each step includes code, commands, and tests.

**Executing the plan:**

```
/zenflow:dispatch    # parallel — for independent tasks
/zenflow:exec-plan   # sequential — for tightly coupled tasks
```

**Validating the work:**

```
/zenflow:check-work
```

Runs lint, format, tests, docs check, and journal entry in sequence. A hook prevents ending the session without running this first.

**Reviewing the diff:**

```
/zenflow:review
```

Dispatches a code reviewer with the git diff. Returns categorized findings (Critical / Important / Minor) and a merge verdict.

### Standalone commands

These work independently of the pipeline:

```
/zenflow:collab      # Long-running collaborative session with Claude Opus
/zenflow:bug-fix     # Four-agent bug diagnosis and fix pipeline
/zenflow:audit       # Audit codebase against your project rules
/zenflow:refactor    # Structured refactoring with regression safety
/zenflow:status      # Show active plans, git status, recent journal
```

---

## Using Field Notes

### Writing entries

The journal writes automatically when `zenflow:check-work` completes (Gate 5). To write entries manually:

```
/field-notes:write
```

You'll be prompted for what was worked on, outcome, insights, and blockers. The entry is appended to `.claude/journal.jsonl`.

### Reading the journal

```
/field-notes:read              # Last 5 entries
/field-notes:read 10           # Last 10 entries
/field-notes:read today        # Today's entries
/field-notes:read blocked      # Entries with outcome: blocked
/field-notes:read bug-fix      # Entries of type: bug-fix
/field-notes:read branch main  # Entries from a specific branch
/field-notes:read search "rate limiter"  # Keyword search
```

### Patterns and retrospectives

```
/field-notes:summary           # Last 7 days — hot files, blockers, health metrics
/field-notes:summary week
/field-notes:summary month
/field-notes:summary all

/field-notes:reflect           # End-of-session retrospective with actionable takeaways
```

### Browser viewer

```
/field-notes:view
```

Opens `plugins/field-notes/scripts/journal.html` in your browser. Pick your `journal.jsonl` file and browse with search and filter chips.

---

## Using Total Recall

### Scan a file

Generate trigger phrases for a single file:

```
/total-recall:scan .claude/rules/my-rule.md --models sonnet
```

This runs 5 study agents in parallel, each independently describing the file in a few words. Terms that appear across most agents become the trigger phrase.

### Seed all rules and docs at once

```
/total-recall:seed --models sonnet
```

Batch-scans your rules, skills, and documentation directories. Use `--models sonnet,opus` to generate model-specific triggers for both.

### Build the index

After scanning, rebuild the reverse lookup so agents can find files by keyword:

```
/total-recall:index
```

### View and manage triggers

```
/total-recall:list                   # Show all triggers
/total-recall:list error-handling    # Filter by keyword
/total-recall:forget .claude/rules/old-rule.md  # Remove triggers for a file
/total-recall:compare .claude/rules/my-rule.md  # Compare triggers across all three models
```

### How triggers are used

Once the index is built, a rule installed by the plugin instructs agents to check `.claude/recall-index.json` before re-reading files. When a relevant term is found, the agent uses the stored trigger phrase instead of re-reading.

You can also inject trigger phrases manually:

```
Don't forget: broken windows code quality ratchet. Now implement the user profile endpoint.
```
