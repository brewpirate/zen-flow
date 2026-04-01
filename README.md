# zen-marketplace

> **Experimental** — All plugins in this marketplace are under active development. APIs, commands, and behavior may change without notice. Use at your own risk.

## Installation

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/plugin install agent-journal@zen
/plugin install total-recall@zen
/reload-plugins
```

## The Marketplace

Three plugins, one marketplace:

| Plugin | Description |
|--------|-------------|
| **[zenflow](plugins/zenflow/README.md)** | Structured development pipeline — idea → plan → execute → validate → review. 15 composable skills, 3 agents, 3 hooks. Parallel subagent execution, code audits, bug-fix pipelines, and collaborative sessions with worktree delegation and mid-session context refresh. |
| **[agent-journal](plugins/agent-journal/README.md)** | Structured work journal for Claude Code agents. 5 skills, 4 commands. Write entries, read history, surface patterns, and run end-of-session retrospectives. Stored as append-only JSONL with a browser-based viewer. |
| **[total-recall](plugins/total-recall/README.md)** | **Experimental.** 5 tokens to recall a 1000-token file. Samples model associations to generate training-data-resonant trigger phrases — cheap attention reweighting for files lost in long contexts. Convergence sampling validated (0.93 avg confidence across 26 files); behavioral efficacy unproven. |

## Plugin Structure

```
zen-flow/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/zenflow/              → see plugins/zenflow/README.md
│   ├── agents/
│   ├── commands/
│   ├── hooks/
│   └── skills/
├── plugins/agent-journal/        → see plugins/agent-journal/README.md
│   ├── commands/
│   ├── scripts/
│   └── skills/
└── plugins/total-recall/         → see plugins/total-recall/README.md
    ├── agents/
    ├── commands/
    └── skills/
```
