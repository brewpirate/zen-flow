# zen-marketplace

## Installation

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/plugin install agent-journal@zen
/plugin install context-factory@zen
/reload-plugins
```

## The Marketplace

Three plugins, one marketplace:

| Plugin | Description |
|--------|-------------|
| **[zenflow](plugins/zenflow/README.md)** | Structured development pipeline — idea → plan → execute → validate → review. 12 composable skills, parallel subagent execution, code audits, bug-fix pipelines, and collaborative sessions with worktree delegation. |
| **[agent-journal](plugins/agent-journal/README.md)** | Structured work journal for Claude Code agents. Write entries, read history, surface patterns, and run end-of-session retrospectives. Stored as append-only JSONL with a browser-based viewer. |
| **[total-recall](plugins/total-recall/README.md)** | 5 tokens to recall a 1000-token file. Samples model associations to generate training-data-resonant trigger phrases — cheap attention reweighting for files lost in long contexts. |

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
