# Getting Started

::: warning Experimental
All plugins are under active development. APIs and behavior may change without notice.
:::

## Installation

Add the marketplace registry, then install whichever plugins you want:

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/plugin install agent-journal@zen
/plugin install total-recall@zen
/reload-plugins
```

The plugins are independent — you can install any subset. That said, `agent-journal` integrates with `zenflow:check-work` (Gate 5 auto-invokes it), so the two are commonly installed together.

## What each plugin installs

**zenflow** — adds commands under `/zenflow:*`, three enforcement hooks, and three agents. Requires `/zenflow:init` to generate a `.claude/zen.local.md` config file for your project before use.

**agent-journal** — adds commands under `/agent-journal:*` and a browser-based HTML viewer at `plugins/agent-journal/scripts/journal.html`. Writes to `.claude/journal.jsonl`.

**total-recall** — adds commands under `/total-recall:*` and a background rule that tells agents to check `.claude/recall-index.json` before re-reading files. Writes to `.claude/triggers.json` and `.claude/recall-index.json`.

## First steps with ZenFlow

After installing, generate the config file:

```
/zenflow:init
```

This scans your project and creates `.claude/zen.local.md` with detected language, framework, documentation paths, and agent-to-domain mappings. Review it and adjust as needed before running the pipeline.

Then open the interactive menu to see all available commands:

```
/zen
```

## First steps with Agent Journal

The journal writes automatically when `zenflow:check-work` completes (Gate 5). You can also write entries manually:

```
/agent-journal:write
```

To view entries in the terminal:

```
/agent-journal:read
/agent-journal:read today
/agent-journal:read blocked
```

## First steps with Total Recall

Scan a file to generate trigger phrases for it:

```
/total-recall:scan .claude/rules/my-rule.md --models sonnet
```

To batch-seed triggers from all your rules and documentation at once:

```
/total-recall:seed --models sonnet
```

After scanning, rebuild the index so agents can look up files by keyword:

```
/total-recall:index
```
