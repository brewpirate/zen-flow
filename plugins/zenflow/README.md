# ZenFlow

A structured development pipeline for Claude Code that turns ideas into shipped, validated code through a series of composable skills.

ZenFlow is derived from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent — a pioneering set of Claude Code skills for structured, agent-driven development. Zen Flow adapts and extends those ideas into a bundled plugin with additional skills, hooks, agents, and configuration.

## Philosophy

Every feature follows the same path: **idea → plan → execute → validate → review**. Each step has a dedicated skill with clear inputs, outputs, and quality gates. Skip a step and a hook blocks you. Follow the flow and you get consistent, high-quality results regardless of task complexity.

Zen Flow is opinionated about process but flexible about execution. You can run the full pipeline or invoke individual skills as needed.

## Installation

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install zenflow@zen
/plugin install agent-journal@zen
/reload-plugins
```

## Quick Start

Run `/zen` to see the interactive menu, or invoke any skill directly:

```
/zenflow:idea    Build a new user notification system
/zenflow:plan
/zenflow:dispatch
```

## The Marketplace

Two plugins, one marketplace:

| Plugin | Skills | Purpose |
|--------|--------|---------|
| **zen** | 12 skills, 1 agent, 1 command, 2 hooks | The development workflow |
| **agent-journal** | 4 skills, HTML viewer | Structured work logging |

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

- **`/zenflow:collab`** — Collaborative working session (Opus model). You and the agent work together as a team — exploring code, building features, troubleshooting problems. When issues arise, they're extracted and delegated to fresh `collab-delegate` agents — either inline (quick fixes) or in **isolated worktrees** (larger issues that get their own branch and PR). Delegates load all project rules dynamically before starting work.

- **`/zenflow:bug-fix`** — Four-agent diagnostic pipeline: two agents diagnose in parallel (root cause + cascade risk), a specialist writes the minimal fix with a regression test, a reviewer verifies.

- **`/zenflow:docs`** — Create or update project documentation. Reads `.claude/zen.local.md` for doc paths, assesses what's stale, asks what to update, writes it.

- **`/zenflow:audit`** — Audit codebase sections against configurable code standards. Dispatches specialist agents in parallel per section, each checking against rules defined in `.claude/rules/`. Supports **changed mode** (`/zenflow:audit changed`) for diff-only audits — only files modified vs main get checked. Full mode for comprehensive sweeps.

- **`/zenflow:refactor`** — Structured refactoring pipeline. Analyzes target code, proposes changes with before/after examples, ensures regression test coverage exists, then executes. Internal API changes are allowed if all callers are updated in the same scope; external-facing changes are not refactors.

- **`/zenflow:status`** — Quick snapshot of project state: active plans (any frontmatter `status != complete`), task progress, git status, session history, and journal entries. Supports **recent mode** (`/zenflow:status recent`) which verifies tasks from the last 72h were actually completed by inspecting tests, commits, and files, then stamps plans with `validated` frontmatter.

### Agent Journal (separate plugin)

- **`/agent-journal:write`** — Append a structured entry after completing work. Captures what happened, what went wrong, and what was learned.
- **`/agent-journal:read`** — View recent entries with filtering by type, outcome, origin, branch, or keyword.
- **`/agent-journal:summary`** — Aggregate patterns across sessions — recurring blockers, hot files, health signals.
- **`/agent-journal:reflect`** — End-of-session retrospective with actionable takeaways.

Journal entries are stored in `.claude/journal.jsonl` (single file, append-only). See the [agent-journal README](plugins/agent-journal/README.md) for the full schema and HTML viewer.

## Skills Reference

| Skill | Invocation | Model | Purpose |
|-------|-----------|-------|---------|
| Menu | `/zen` | — | Interactive skill picker |
| Init | `/zenflow:init` | — | Scan codebase and agents to generate zen.local.md config |
| Collab | `/zenflow:collab` | Opus | Collaborative session with inline + worktree delegation |
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
| Journal Write | `/agent-journal:write` | — | Append structured journal entry |
| Journal Read | `/agent-journal:read` | — | View and filter entries |
| Journal Summary | `/agent-journal:summary` | — | Aggregate patterns and health signals |
| Journal Reflect | `/agent-journal:reflect` | — | End-of-session retrospective |

## Agents

| Agent | Model | Purpose | Source |
|-------|-------|---------|--------|
| `collab-delegate` | Opus | Fresh specialist spawned by zenflow:collab to handle extracted issues | — |
| `error-coordinator` | — | Cascade risk analysis in zenflow:bug-fix | [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/09-meta-orchestration/error-coordinator.md) |
| `error-detective` | — | Root cause analysis in zenflow:bug-fix | [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/04-quality-security/error-detective.md) |

> Agent assignments for skills are configured in `.claude/zen.local.md`. Run `/zenflow:init` to auto-generate config from your installed agents.

The collab-delegate agent:
- **Loads all project rules dynamically** — globs `.claude/rules/*.md` and reads every file, announcing each one
- **Has zen skills** — can invoke `zenflow:plan`, `zenflow:check-work`, `zenflow:review`, and `testing-anti-patterns`
- **Receives structured handoffs** — context, reproduction steps, relevant files, what was already tried
- **Can work in worktrees** — isolated branch, commits freely, submits PR as review gate
- **Can escalate** — reports `BLOCKED` if context is insufficient rather than guessing

## Hooks

Zen Flow includes two Stop hooks that enforce workflow discipline:

| Hook | What it does |
|------|-------------|
| `enforce-plan-mode-tools` | In plan mode, blocks ending a turn without calling `ExitPlanMode` or `AskUserQuestion` |
| `enforce-work-validation` | After `zenflow:exec-plan` or `zenflow:dispatch`, blocks finishing without running `zenflow:check-work` |

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
├── plugins/zen/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/
│   │   └── collab-delegate.md        # Opus-powered specialist for zenflow:collab
│   ├── commands/
│   │   └── zen.md                    # /zen interactive menu
│   ├── hooks/
│   │   ├── hooks.json                # Stop hook registration
│   │   └── scripts/
│   │       ├── enforce-plan-mode-tools.sh
│   │       └── enforce-work-validation.sh
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
│       └── collab/SKILL.md           # zenflow:collab — collaborative session (Opus)
└── plugins/agent-journal/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── scripts/
    │   └── journal.html              # Browser-based viewer (Tokyo Night)
    └── skills/
        ├── write/SKILL.md            # agent-journal:write
        ├── read/SKILL.md             # agent-journal:read
        ├── summary/SKILL.md          # agent-journal:summary
        └── reflect/SKILL.md          # agent-journal:reflect
```

## Workflow Diagrams

### zenflow:idea — Three Modes

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1a1b26', 'primaryTextColor': '#c0caf5', 'lineColor': '#565f89', 'secondaryColor': '#24283b', 'tertiaryColor': '#24283b' }}}%%
flowchart TD
    start([User invokes zenflow:idea]) --> assess{"How concrete<br/>is the idea?"}

    assess -->|"vague / still forming"| explore["<b>Exploration Mode</b><br/><small>Open questions, research agents,<br/>checkpoint every 3-4 exchanges</small>"]
    assess -->|"clear problem,<br/>unclear solution"| discover["<b>Discovery Mode</b><br/><small>Investigate solutions, compare<br/>approaches, narrow together</small>"]
    assess -->|"clear intent,<br/>ready to build"| design["<b>Design Mode</b><br/><small>Clarify → propose 2-3<br/>approaches → present design</small>"]

    explore --> exploreArtifact["Exploration Artifact<br/><small>Written summary (mandatory)</small>"]
    exploreArtifact --> discover

    discover --> discoverArtifact["Discovery Artifact<br/><small>Written summary (mandatory)</small>"]
    discoverArtifact --> design

    design --> approval{"Design approved?"}
    approval -->|no| design
    approval -->|yes| plan["<b>zenflow:plan</b>"]

    style start fill:#24283b,color:#c0caf5,stroke:#565f89
    style assess fill:#24283b,color:#c0caf5,stroke:#565f89
    style explore fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style discover fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style design fill:#7aa2f7,color:#1a1b26,stroke:#7aa2f7
    style exploreArtifact fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style discoverArtifact fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style approval fill:#24283b,color:#c0caf5,stroke:#565f89
    style plan fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
```

### Full Pipeline Flow

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1a1b26', 'primaryTextColor': '#c0caf5', 'lineColor': '#565f89', 'secondaryColor': '#24283b', 'tertiaryColor': '#24283b' }}}%%
flowchart TD
    start([User has an idea]) --> idea
    idea["<b>zenflow:idea</b><br/>Explore → Discover → Design"]
    idea -->|design approved| plan
    plan["<b>zenflow:plan</b><br/>Write Implementation Plan"]
    plan -->|"plan saved"| choose{Execution Strategy?}
    choose -->|parallel| dispatch["<b>zenflow:dispatch</b><br/>Subagent per Task"]
    choose -->|sequential| execplan["<b>zenflow:exec-plan</b><br/>Step-by-step"]

    dispatch --> task1["Task 1: Implement"]
    dispatch --> task2["Task 2: Implement"]
    dispatch --> taskN["Task N: Implement"]
    task1 --> specrev1["Spec Review"]
    task2 --> specrev2["Spec Review"]
    taskN --> specrevN["Spec Review"]
    specrev1 --> qualrev1["Quality Review"]
    specrev2 --> qualrev2["Quality Review"]
    specrevN --> qualrevN["Quality Review"]
    qualrev1 --> check
    qualrev2 --> check
    qualrevN --> check

    execplan -->|"all tasks done"| check

    check["<b>zenflow:check-work</b><br/>Lint → Format → Tests → Docs → Journal"]
    check -->|"all gates pass"| review
    review["<b>zenflow:review</b><br/>Final Code Review"]
    review --> done([Ship It])

    style start fill:#24283b,color:#c0caf5,stroke:#565f89
    style idea fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style plan fill:#7aa2f7,color:#1a1b26,stroke:#7aa2f7
    style choose fill:#24283b,color:#c0caf5,stroke:#565f89
    style dispatch fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style execplan fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style task1 fill:#73daca,color:#1a1b26,stroke:#73daca
    style task2 fill:#73daca,color:#1a1b26,stroke:#73daca
    style taskN fill:#73daca,color:#1a1b26,stroke:#73daca
    style specrev1 fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style specrev2 fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style specrevN fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style qualrev1 fill:#f7768e,color:#1a1b26,stroke:#f7768e
    style qualrev2 fill:#f7768e,color:#1a1b26,stroke:#f7768e
    style qualrevN fill:#f7768e,color:#1a1b26,stroke:#f7768e
    style check fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style review fill:#f7768e,color:#1a1b26,stroke:#f7768e
    style done fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
```

### Bug Fix Pipeline

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1a1b26', 'primaryTextColor': '#c0caf5', 'lineColor': '#565f89', 'secondaryColor': '#24283b', 'tertiaryColor': '#24283b' }}}%%
flowchart TD
    bug([Bug Reported]) --> reproduce
    reproduce["Reproduce & Confirm"]
    reproduce -->|confirmed| diag

    subgraph diag ["Parallel Diagnosis"]
        detective["error-detective<br/><small>Root cause analysis</small>"]
        coordinator["error-coordinator<br/><small>Cascade risk check</small>"]
    end

    diag --> specialist
    specialist["Specialist Agent<br/><small>Regression test → Minimal fix</small>"]
    specialist --> reviewer["Code Reviewer<br/><small>Verify fix quality</small>"]
    reviewer -->|issues found| specialist
    reviewer -->|approved| check["<b>zenflow:check-work</b>"]
    check --> done([Fixed])

    style bug fill:#24283b,color:#c0caf5,stroke:#565f89
    style reproduce fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style diag fill:#24283b,color:#c0caf5,stroke:#565f89
    style detective fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style coordinator fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style specialist fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style reviewer fill:#f7768e,color:#1a1b26,stroke:#f7768e
    style check fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style done fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
```

### Collab Session Flow

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1a1b26', 'primaryTextColor': '#c0caf5', 'lineColor': '#565f89', 'secondaryColor': '#24283b', 'tertiaryColor': '#24283b' }}}%%
flowchart TD
    start(["/zenflow:collab"]) --> work
    work["Working Together<br/><small>Explore, build, discuss</small>"]
    work --> issue{"Issue found?"}
    issue -->|"quick fix<br/>(< 2 min)"| inline["Fix Inline"]
    inline --> work
    issue -->|"complex"| extract["Extract Issue<br/><small>Context + repro + files</small>"]
    extract --> delegateType{"Scope?"}
    delegateType -->|small| inlineDelegate["Spawn Delegate<br/><small>Inline, same branch</small>"]
    delegateType -->|large| worktreeDelegate["Spawn Delegate<br/><small>Worktree → PR</small>"]
    inlineDelegate -.->|async| result["Delegate Reports Back"]
    worktreeDelegate -.->|async| pr["Delegate Submits PR"]
    extract --> work
    result -.-> work
    pr -.-> work
    issue -->|no| work

    work --> finish{Done?}
    finish -->|more work| work
    finish -->|yes| check["<b>zenflow:check-work</b>"]

    style start fill:#24283b,color:#c0caf5,stroke:#565f89
    style work fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style issue fill:#24283b,color:#c0caf5,stroke:#565f89
    style inline fill:#73daca,color:#1a1b26,stroke:#73daca
    style extract fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style delegateType fill:#24283b,color:#c0caf5,stroke:#565f89
    style inlineDelegate fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style worktreeDelegate fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style result fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style pr fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style finish fill:#24283b,color:#c0caf5,stroke:#565f89
    style check fill:#e0af68,color:#1a1b26,stroke:#e0af68
```

### Audit Flow

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1a1b26', 'primaryTextColor': '#c0caf5', 'lineColor': '#565f89', 'secondaryColor': '#24283b', 'tertiaryColor': '#24283b' }}}%%
flowchart TD
    start(["/zenflow:audit"]) --> mode{"Mode?"}
    mode -->|full| config["Read zen.local.md<br/><small>All audit sections</small>"]
    mode -->|changed| diff["git diff main...HEAD<br/><small>Only changed files</small>"]
    diff --> config
    config --> dispatch

    subgraph dispatch ["Parallel Audit Agents"]
        a1["Backend Architect<br/><small>API Routes</small>"]
        a2["Frontend Developer<br/><small>Components</small>"]
        a3["Software Architect<br/><small>Core</small>"]
        a4["typescript-pro<br/><small>Schemas</small>"]
    end

    dispatch --> report["Compile Report<br/><small>Critical → Important → Minor</small>"]
    report --> action{"Action?"}
    action -->|fix| fix["Dispatch Fix Agents"]
    action -->|plan| plan["<b>zenflow:plan</b>"]
    action -->|save| save["Save Report"]
    fix --> check["<b>zenflow:check-work</b>"]

    style start fill:#24283b,color:#c0caf5,stroke:#565f89
    style mode fill:#24283b,color:#c0caf5,stroke:#565f89
    style diff fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style config fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style dispatch fill:#24283b,color:#c0caf5,stroke:#565f89
    style a1 fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style a2 fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style a3 fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style a4 fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style report fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style action fill:#24283b,color:#c0caf5,stroke:#565f89
    style fix fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style plan fill:#7aa2f7,color:#1a1b26,stroke:#7aa2f7
    style save fill:#73daca,color:#1a1b26,stroke:#73daca
    style check fill:#e0af68,color:#1a1b26,stroke:#e0af68
```