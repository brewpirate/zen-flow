# Agents

ZenFlow includes three agents that are spawned by specific commands. They are not invoked directly — each one is launched as a subagent by the skill that needs it.

## collab-delegate

**Model:** Opus  
**Spawned by:** `/zenflow:collab`

When a side problem comes up during a collab session, the delegate agent handles it instead of the primary session. This keeps the main session focused and prevents its context from filling up with unrelated debugging work.

The delegate:

- **Loads all project rules before starting** — globs `.claude/rules/*.md` and reads every file, announcing each one
- **Has access to zenflow skills** — can invoke `zenflow:plan`, `zenflow:check-work`, `zenflow:review`, and the testing-anti-patterns rule
- **Receives a structured handoff** — context, reproduction steps, relevant files, and what was already tried
- **Can work in a worktree** — if the issue is large enough, the delegate gets an isolated branch, commits freely, and submits a PR for review rather than working in the main directory
- **Can escalate** — reports `BLOCKED` with a clear explanation if the handoff context is insufficient, rather than making assumptions

## error-detective

**Model:** Sonnet  
**Spawned by:** `/zenflow:bug-fix`  
**Source:** [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/04-quality-security/error-detective.md)

Focuses on root cause analysis. Given a bug description or error trace, it traces the failure back to its origin and produces a diagnosis with evidence. Runs in parallel with `error-coordinator`.

## error-coordinator

**Model:** Sonnet  
**Spawned by:** `/zenflow:bug-fix`  
**Source:** [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents/blob/main/categories/09-meta-orchestration/error-coordinator.md)

Focuses on cascade risk — what else might break if this bug is fixed a certain way, and what are the downstream effects of the proposed change. Runs in parallel with `error-detective`.

## code-reviewer (skill-internal)

**Spawned by:** `/zenflow:review`

Not a standalone agent — this is an inline prompt template used by the review skill to evaluate diffs. It checks production readiness, categorizes findings by severity, and produces a structured review. Defined in `plugins/zenflow/skills/review/code-reviewer.md`.

---

## Custom agent assignments

Which agent handles a given domain is configured in `.claude/zen.local.md` under the `agents` key. Run `/zenflow:init` to generate this config automatically based on your installed agents.

```yaml
agents:
  - domain: api-routes
    dir: packages/server/src/routes/
    glob: "*.ts"
    agent: Backend Architect
    rules:
      - error-handling
      - async-patterns
  - domain: frontend
    dir: packages/frontend/src/components/
    glob: "**/*.tsx"
    agent: Frontend Developer
    rules:
      - react-patterns
```

The `agent` field must match the `name` frontmatter of an installed agent. The `rules` field maps to files in `.claude/rules/{name}.md`.
