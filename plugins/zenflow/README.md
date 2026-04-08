# ZenFlow

A structured development pipeline for Claude Code that turns ideas into shipped, validated code through a series of composable skills.

ZenFlow is derived from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent — a pioneering set of Claude Code skills for structured, agent-driven development. Zen Flow adapts and extends those ideas into a bundled plugin with additional skills, hooks, agents, and configuration.

> **Experimental** — This plugin is under active development and its APIs, commands, and behavior may change without notice. Use at your own risk.

## Philosophy

> **Deep dive:** [Philosophy (Human)](PHILOSOPHY-HUMAN.md) | [Philosophy (Agent)](PHILOSOPHY-AGENT.md)

Every feature follows the same path: **idea → plan → execute → validate → review**. Each step has a dedicated skill with clear inputs, outputs, and quality gates. Skip a step and a hook blocks you. Follow the flow and you get consistent, high-quality results regardless of task complexity.

Zen Flow is opinionated about process but flexible about execution. You can run the full pipeline or invoke individual skills as needed.

## Installation

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/plugin install field-notes@zen
/reload-plugins
```

## Quick Start

Run `/zen` to see the interactive menu, or invoke any skill directly:

```
/zenflow:idea    Build a new user notification system
/zenflow:plan
/zenflow:dispatch
```

## The Pipeline

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1a1b26', 'primaryTextColor': '#c0caf5', 'lineColor': '#565f89', 'secondaryColor': '#24283b' }}}%%
graph LR
    idea["zenflow:idea<br/><small>Explore → Discover → Design</small>"]
    plan["zenflow:plan<br/><small>Implementation Plan</small>"]
    dispatch["zenflow:dispatch<br/><small>Parallel Subagents</small>"]
    execplan["zenflow:exec-plan<br/><small>Sequential Steps</small>"]
    check["zenflow:check-work<br/><small>5 Quality Gates</small>"]
    review["zenflow:review<br/><small>Code Review</small>"]

    idea --> plan
    plan --> dispatch
    plan --> execplan
    dispatch --> check
    execplan --> check
    check --> review

    style idea fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style plan fill:#7aa2f7,color:#1a1b26,stroke:#7aa2f7
    style dispatch fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style execplan fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style check fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style review fill:#f7768e,color:#1a1b26,stroke:#f7768e
```

### Full Pipeline

1. **`/zenflow:idea`** — Three modes based on idea maturity:
   - **Exploration** ("an idea") — open questions, research agents, periodic checkpoints. No proposals until the user signals readiness. Produces a mandatory exploration artifact.
   - **Discovery** ("a problem") — clear pain, unclear solution. Skips problem exploration, investigates solution approaches. Produces a mandatory discovery artifact.
   - **Design** ("the idea") — clear intent. Clarify → propose 2-3 approaches → present design → get approval.

   No code until the design is approved.

2. **`/zenflow:plan`** — Write a detailed implementation plan with bite-sized tasks, complete code in every step, exact commands, and TDD. Saved to `resources/plans/NNN-name.md`.

3. **Execute** (pick one):
   - **`/zenflow:dispatch`** — Parallel subagents per task with two-stage review (spec compliance + code quality). Recommended for plans with independent tasks.
   - **`/zenflow:exec-plan`** — Sequential execution with checkpoints. Better for tightly coupled tasks or when you want more control.

4. **`/zenflow:check-work`** — Five quality gates in order: lint, format, tests, docs, journal. Auto-discovers project commands from `package.json`/`CLAUDE.md`. Auto-fixes what it can, launches subagents for the rest. Enforced by a Stop hook — you cannot finish an execution session without running this.

5. **`/zenflow:review`** — Dispatch a code reviewer subagent with the git diff. Categorizes issues as Critical/Important/Minor with file:line references and a clear merge verdict.

### Standalone Skills

These work independently of the pipeline:

- **`/zenflow:collab`** — Collaborative working session (Opus model). You and the agent work together as a team — exploring code, building features, troubleshooting problems. When issues arise, they're extracted and delegated to fresh `collab-delegate` agents — either inline (quick fixes) or in **isolated worktrees** (larger issues that get their own branch and PR). Delegates load all project rules dynamically before starting work. Supports mid-session **context refresh** via `/zenflow:context-refresh`.

- **`/zenflow:context-refresh`** — Shed accumulated context mid-session without losing continuity. Writes a structured knowledge handoff document to `.claude/handoffs/` capturing session goals, decisions, behavioral calibration, observations, open tasks, and next steps. After the user runs `/clear` and re-invokes `/zenflow:collab`, the session resumes from the handoff with minimal context loss. Designed for long collab sessions where dead context (old file reads, debug output) degrades quality.

- **`/zenflow:bug-fix`** — Four-agent diagnostic pipeline: two agents diagnose in parallel (root cause + cascade risk), a specialist writes the minimal fix with a regression test, a reviewer verifies.

- **`/zenflow:docs`** — Create or update project documentation. Reads `.claude/zen.local.md` for doc paths, assesses what's stale, asks what to update, writes it.

- **`/zenflow:audit`** — Audit codebase sections against configurable code standards. Dispatches specialist agents in parallel per section, each checking against rules defined in `.claude/rules/`. Supports **changed mode** (`/zenflow:audit changed`) for diff-only audits — only files modified vs main get checked. Full mode for comprehensive sweeps.

- **`/zenflow:refactor`** — Structured refactoring pipeline. Analyzes target code, proposes changes with before/after examples, ensures regression test coverage exists, then executes. Internal API changes are allowed if all callers are updated in the same scope; external-facing changes are not refactors.

- **`/zenflow:status`** — Quick snapshot of project state: active plans (any frontmatter `status != complete`), task progress, git status, session history, and journal entries. Supports **recent mode** (`/zenflow:status recent`) which verifies tasks from the last 72h were actually completed by inspecting tests, commits, and files, then stamps plans with `validated` frontmatter.

### Field Notes (separate plugin)

- **`/field-notes:write`** — Append a structured entry after completing work. Captures what happened, what went wrong, and what was learned.
- **`/field-notes:read`** — View recent entries with filtering by type, outcome, origin, branch, or keyword.
- **`/field-notes:summary`** — Aggregate patterns across sessions — recurring blockers, hot files, health signals.
- **`/field-notes:reflect`** — End-of-session retrospective with actionable takeaways.

Journal entries are stored in `.claude/journal.jsonl` (single file, append-only). See the [field-notes README](../field-notes/README.md) for the full schema and HTML viewer.

## Skills Reference

| Skill | Invocation | Model | Purpose |
|-------|-----------|-------|---------|
| Menu | `/zen` | — | Interactive skill picker |
| Init | `/zenflow:init` | — | Scan codebase and agents to generate zen.local.md config |
| Collab | `/zenflow:collab` | Opus | Collaborative session with inline + worktree delegation |
| Context Refresh | `/zenflow:context-refresh` | Opus | Shed context mid-session with knowledge handoff |
| Idea | `/zenflow:idea` | — | Explore → discover → design (three modes) |
| Plan | `/zenflow:plan` | — | Write implementation plan from spec |
| Execute (parallel) | `/zenflow:dispatch` | — | Subagent-per-task with two-stage review |
| Execute (sequential) | `/zenflow:exec-plan` | — | Step-by-step with checkpoints |
| Validate | `/zenflow:check-work` | — | Lint, format, tests, docs, journal gates |
| Review | `/zenflow:review` | — | Code review via subagent |
| Bug Fix | `/zenflow:bug-fix` | — | Diagnose and fix with agent pipeline |
| Docs | `/zenflow:docs` | — | Create or update documentation |
| Audit | `/zenflow:audit [changed]` | — | Audit code sections against standards; changed = diff-only |
| Refactor | `/zenflow:refactor` | — | Structured refactoring with regression safety |
| Status | `/zenflow:status [recent]` | — | Project state snapshot; recent mode verifies recent work |
| Testing Anti-Patterns | (automatic) | — | Enforces test quality rules — test real behavior, not mock behavior |
| Journal Write | `/field-notes:write` | — | Append structured journal entry |
| Journal Read | `/field-notes:read` | — | View and filter entries |
| Journal Summary | `/field-notes:summary` | — | Aggregate patterns and health signals |
| Journal Reflect | `/field-notes:reflect` | — | End-of-session retrospective |

## Agents

| Agent | Model | Purpose | Source |
|-------|-------|---------|--------|
| `collab-delegate` | Opus | Fresh specialist spawned by zenflow:collab to handle extracted issues | — |
| `error-coordinator` | Sonnet | Cascade risk analysis in zenflow:bug-fix | [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/09-meta-orchestration/error-coordinator.md) |
| `error-detective` | Sonnet | Root cause analysis in zenflow:bug-fix | [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/04-quality-security/error-detective.md) |

> Agent assignments for skills are configured in `.claude/zen.local.md`. Run `/zenflow:init` to auto-generate config from your installed agents.

The collab-delegate agent:
- **Loads all project rules dynamically** — globs `.claude/rules/*.md` and reads every file, announcing each one
- **Has zen skills** — can invoke `zenflow:plan`, `zenflow:check-work`, `zenflow:review`, and `testing-anti-patterns`
- **Receives structured handoffs** — context, reproduction steps, relevant files, what was already tried
- **Can work in worktrees** — isolated branch, commits freely, submits PR as review gate
- **Can escalate** — reports `BLOCKED` if context is insufficient rather than guessing

## Hooks

Zen Flow includes three hooks that enforce workflow discipline:

| Hook | Type | What it does |
|------|------|-------------|
| `enforce-plan-mode-tools` | Stop | In plan mode, blocks ending a turn without calling `ExitPlanMode` or `AskUserQuestion` |
| `enforce-work-validation` | Stop | After `zenflow:exec-plan` or `zenflow:dispatch`, blocks finishing without running `zenflow:check-work` |
| `enforce-local-plans` | PreToolUse | Redirects plan file writes from `~/.claude/plans/` to the project's `resources/plans/` directory |

These fire automatically when the plugin is installed. No configuration needed.

## Configuration

All zen configuration lives in `.claude/zen.local.md` — a single file with YAML frontmatter for structured config and a markdown body for freeform notes. Run `/zenflow:init` to generate this file automatically from your codebase and installed agents.

### Config structure

```yaml
---
project:
  language: typescript       # detected primary language
  framework: nextjs          # detected framework (if any)

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

### Config keys

| Key | Used by | Description |
|-----|---------|-------------|
| `project` | All skills | Detected language and framework |
| `docs` | zenflow:docs | Documentation file paths and directories |
| `agents` | zenflow:audit, zenflow:bug-fix | Domain-to-agent mapping for the codebase |

### agents fields

| Field | Required | Description |
|-------|----------|-------------|
| `domain` | yes | Logical name for this codebase section |
| `dir` | yes | Directory path relative to project root |
| `glob` | no | File pattern (default: `**/*`) |
| `agent` | no | Agent name — must match an installed agent's `name` frontmatter |
| `rules` | no | Rule names resolved to `.claude/rules/{name}.md` |

### Layering

- **Project-level:** `.claude/zen.local.md` — committed or gitignored per team preference
- **User-level:** `~/.claude/zen.local.md` — personal defaults across all projects
- Project config overrides user config.

## Design Principles

- **Human controls commits** — agents write code and present changes; the human decides when to commit
- **Project-agnostic** — no hardcoded toolchain; skills discover commands from `package.json`, `CLAUDE.md`, or config files
- **Mandatory artifacts** — exploration and discovery modes produce written summaries before transitioning; if the session dies, the artifact survives
- **Context protection** — collab delegates side issues to fresh agents instead of burning primary session context
- **Hooks enforce gates** — you can't skip validation, so quality is structural, not aspirational

## Plugin Structure

```
zen-marketplace/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/zenflow/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/
│   │   ├── collab-delegate.md        # Opus — specialist for zenflow:collab
│   │   ├── error-detective.md        # Sonnet — root cause analysis
│   │   └── error-coordinator.md      # Sonnet — cascade risk analysis
│   ├── commands/
│   │   ├── zenflow.md                # /zen interactive menu
│   │   ├── idea.md                   # /zenflow:idea
│   │   ├── plan.md                   # /zenflow:plan
│   │   ├── dispatch.md               # /zenflow:dispatch
│   │   ├── exec-plan.md              # /zenflow:exec-plan
│   │   ├── check-work.md             # /zenflow:check-work
│   │   ├── review.md                 # /zenflow:review
│   │   ├── bug-fix.md                # /zenflow:bug-fix
│   │   ├── refactor.md               # /zenflow:refactor
│   │   ├── audit.md                  # /zenflow:audit
│   │   ├── docs.md                   # /zenflow:docs
│   │   └── status.md                 # /zenflow:status
│   ├── hooks/
│   │   └── scripts/
│   │       ├── enforce-plan-mode-tools.sh    # Stop — plan mode discipline
│   │       ├── enforce-work-validation.sh    # Stop — check-work enforcement
│   │       └── enforce-local-plans.sh        # PreToolUse — keep plans in project
│   └── skills/
│       ├── idea/SKILL.md             # zenflow:idea — explore → discover → design
│       ├── plan/SKILL.md             # zenflow:plan — write implementation plans
│       ├── exec-plan/SKILL.md        # zenflow:exec-plan — sequential execution
│       ├── dispatch/                  # zenflow:dispatch — parallel subagent execution
│       │   ├── SKILL.md
│       │   ├── implementer-prompt.md
│       │   ├── spec-reviewer-prompt.md
│       │   └── code-quality-reviewer-prompt.md
│       ├── check-work/SKILL.md       # zenflow:check-work — 5 quality gates
│       ├── review/                    # zenflow:review — code review
│       │   ├── SKILL.md
│       │   └── code-reviewer.md
│       ├── bug-fix/SKILL.md          # zenflow:bug-fix — diagnostic pipeline
│       ├── docs/SKILL.md             # zenflow:docs — documentation
│       ├── audit/SKILL.md            # zenflow:audit — code standards audit
│       ├── refactor/SKILL.md         # zenflow:refactor — structured refactoring
│       ├── status/SKILL.md           # zenflow:status — project snapshot + recent verify
│       ├── collab/SKILL.md           # zenflow:collab — collaborative session (Opus)
│       ├── context-refresh/SKILL.md  # zenflow:context-refresh — mid-session context shed
│       ├── init/SKILL.md             # zenflow:init — generate zen.local.md config
│       └── testing-anti-patterns/SKILL.md  # test quality enforcement
└── plugins/field-notes/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── commands/
    │   ├── write.md                  # /field-notes:write
    │   ├── read.md                   # /field-notes:read
    │   ├── summary.md                # /field-notes:summary
    │   └── reflect.md                # /field-notes:reflect
    ├── scripts/
    │   └── journal.html              # Browser-based viewer (Tokyo Night)
    └── skills/
        ├── write/SKILL.md            # field-notes:write
        ├── read/SKILL.md             # field-notes:read
        ├── summary/SKILL.md          # field-notes:summary
        ├── reflect/SKILL.md          # field-notes:reflect
        └── view/SKILL.md             # field-notes:view — open in browser
```

## Workflows & Diagrams

See **[workflows.md](workflows.md)** for all workflow diagrams and usage examples.

**Diagrams:** [Idea Modes](workflows.md#zenflowidea--three-modes) | [Full Pipeline](workflows.md#full-pipeline-flow) | [Bug Fix](workflows.md#bug-fix-pipeline) | [Collab Session](workflows.md#collab-session-flow) | [Context Refresh](workflows.md#context-refresh-flow) | [Audit](workflows.md#audit-flow)

**Examples:** [New Feature](workflows.md#new-feature-full-pipeline) | [Collab (inline)](workflows.md#collab-session-inline-delegation) | [Collab (worktree)](workflows.md#collab-session-worktree-delegation) | [Context Refresh](workflows.md#context-refresh-mid-session) | [Bug Fix](workflows.md#bug-fix) | [Audit](workflows.md#code-audit-full) | [Refactor](workflows.md#refactor-internal-api-change) | [Status](workflows.md#quick-status-check)