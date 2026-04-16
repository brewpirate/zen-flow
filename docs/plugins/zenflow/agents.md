# Agents

ZenFlow includes two agents that are spawned by specific skills. They are not invoked directly — each one is launched as a subagent by the skill that needs it.

> **Note:** The `collab-delegate` agent was removed in favor of the 3-agent issue-driven workflow — see issue [#13](https://github.com/brewpirate/zen-flow/issues/13). Implementation work is now handled by the Builder skill (`/zenflow:build`) launched by the user.

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
