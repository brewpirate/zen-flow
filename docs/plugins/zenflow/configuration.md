# Configuration

All ZenFlow configuration lives in a single file: `.claude/zen.local.md`.

This file uses YAML frontmatter for structured settings and a markdown body for freeform notes. Generate it automatically with `/zenflow:init`, which scans your project to detect language, framework, and documentation structure.

## Generating the config

```
/zenflow:init
```

This reads your project's `package.json`, `CLAUDE.md`, and installed agents to produce a starting configuration. Review and adjust the output before relying on it.

## Config structure

```yaml
---
project:
  language: typescript
  framework: nextjs

docs:
  readme: README.md
  architecture: docs/ARCHITECTURE.md
  claude: CLAUDE.md
  changelog: CHANGELOG.md
  paths:
    - name: Guides
      dir: docs/
      glob: "*.md"
    - name: API Reference
      path: docs/api-reference.md

agents:
  - domain: api-routes
    dir: packages/server/src/server/routes/
    glob: "*.ts"
    agent: Backend Architect
    rules:
      - error-handling
      - options-objects
      - async-patterns
  - domain: frontend
    dir: packages/frontend/src/components/
    glob: "**/*.tsx"
    agent: Frontend Developer
    rules:
      - react-patterns
      - composition-patterns
---

Style notes: use tables for config options, code blocks for commands.
```

## Config keys

### `project`

Used by all skills to understand the project context.

| Key | Description |
|-----|-------------|
| `language` | Primary programming language |
| `framework` | Framework in use (if any) |

### `docs`

Used by `/zenflow:docs` to find and update documentation.

| Key | Description |
|-----|-------------|
| `readme` | Path to the main README |
| `architecture` | Path to architecture documentation |
| `claude` | Path to `CLAUDE.md` |
| `changelog` | Path to changelog |
| `paths` | List of named doc directories or files to monitor |

Each entry in `paths` can be either a directory (with `dir` and optional `glob`) or a single file (with `path`).

### `agents`

Used by `/zenflow:bug-fix` to map codebase sections to agents and rules.

| Field | Required | Description |
|-------|----------|-------------|
| `domain` | yes | A name for this codebase section |
| `dir` | yes | Directory path relative to project root |
| `glob` | no | File pattern within the directory (default: `**/*`) |
| `agent` | no | Agent name — must match the `name` frontmatter of an installed agent |
| `rules` | no | Rule names, resolved to `.claude/rules/{name}.md` |

## Config layering

ZenFlow reads config from two locations:

| Location | Scope |
|----------|-------|
| `.claude/zen.local.md` | Project — committed or gitignored per team preference |
| `~/.claude/zen.local.md` | User — personal defaults across all projects |

Project config takes precedence over user config when both exist.

## Markdown body

The content below the YAML frontmatter is freeform and not parsed by ZenFlow. It's a convenient place for notes that help the agent — style preferences, known constraints, context about the codebase.

```yaml
---
project:
  language: typescript
---

We use Bun as the runtime, not Node. Always check Bun-native API availability before
reaching for Node equivalents. See CLAUDE.md for the full list.
```
