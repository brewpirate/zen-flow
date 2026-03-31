# zen-marketplace

## Installation

```bash
/plugin marketplace add brewpirate/zen-flow
/plugin install zen@zen
/plugin install agent-journal@zen
/plugin install context-factory@zen
/reload-plugins
```

## The Marketplace

Three plugins, one marketplace:

| Plugin | Description |
|--------|-------------|
| **[zen](plugins/zenflow/README.md)** | Structured development pipeline — idea → plan → execute → validate → review. 12 composable skills, parallel subagent execution, code audits, bug-fix pipelines, and collaborative sessions with worktree delegation. |
| **[agent-journal](plugins/agent-journal/README.md)** | Structured work journal for Claude Code agents. Write entries, read history, surface patterns, and run end-of-session retrospectives. Stored as append-only JSONL with a browser-based viewer. |
| **[context-factory](plugins/context-factory/README.md)** | Snapshot and fork Claude Code sessions. Freeze a fully loaded session — skills, paths, rules, tools, validation — then clone it into any future session with zero setup time. |

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
└── plugins/context-factory/      → see plugins/context-factory/README.md
    └── skills/
```
