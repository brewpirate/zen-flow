# Workflows & Diagrams

Common usage patterns with diagrams and step-by-step examples.

## Standard Feature Development

The most common flow: new feature from scratch through to a reviewed, validated implementation.

```
/zenflow:idea    Describe the feature you want to build
/zenflow:plan    Write the implementation plan
/zenflow:dispatch    Execute the plan with parallel subagents
/zenflow:check-work  Run lint, format, tests, docs, journal
/zenflow:review  Get a code review of the diff
```

**Example session:**

```
You: /zenflow:idea  Add webhook support for order status changes

[Agent explores requirements, proposes design, you approve]

You: /zenflow:plan

[Agent writes resources/plans/012-webhooks.md]

You: /zenflow:dispatch

[Agent spawns subagents per task; each goes through spec + quality review]

You: /zenflow:check-work

[All 5 gates pass]

You: /zenflow:review

[Reviewer returns: 2 Minor issues, merge verdict: ready with fixes]
```

---

## Collaborative Session

`collab` is ZenFlow's crown jewel — a long-running working session where you and Claude Opus operate as partners. Not a task executor: a thinking partner that explores, reasons, and delegates. See the **[Collab](/plugins/zenflow/collab)** page for the full reference.

```
/zenflow:collab    Start a collaborative session
```

When a side issue comes up, the agent delegates it rather than burning context:

```
You: /zenflow:collab

Agent: Found a bug in the rate limiter while exploring this.
       Delegating to a worktree agent — it'll get its own branch and PR.

[Worktree delegate creates branch, fixes bug, submits PR #47]

Agent: PR #47 is up. Back to the main feature.
```

If the session runs long and context gets noisy:

```
You: /zenflow:context-refresh

[Agent writes .claude/handoffs/notifications-2026-04-04T14:30.md]
[Captures goals, decisions, behavioral calibration, open tasks, next steps]

You: /clear
You: /zenflow:collab

[Agent detects handoff, restores calibration, resumes from Next Steps]
```

---

## Bug Fix

```
/zenflow:bug-fix    Describe the bug or paste the error

[Two agents diagnose in parallel: root cause + cascade risk]
[A specialist writes the minimal fix with a regression test]
[A reviewer verifies the fix]

/zenflow:check-work
/zenflow:review
```

---

## Code Audit

Audit the entire codebase against your project's coding rules:

```
/zenflow:audit
```

Audit only files changed on the current branch vs. main:

```
/zenflow:audit changed
```

The sections and rules used come from the `agents` config in `.claude/zen.local.md`. Each section gets its own specialist subagent running in parallel.

---

## Refactor

```
/zenflow:refactor    Describe what you want to refactor

[Agent analyzes target, proposes changes with before/after examples]
[Agent verifies regression tests exist or writes them]

You: [approve the proposal]

[Agent executes the refactor]

/zenflow:check-work
/zenflow:review
```

---

## Checking Recent Work

Verify that tasks completed in the last 72 hours were actually done:

```
/zenflow:status recent
```

The agent inspects tests, commits, and files to validate each completed task, then stamps plans with `validated` frontmatter.

---

## Flow Diagrams

### Idea Modes

```mermaid
flowchart TD
    start([zenflow:idea]) --> assess{"How concrete\nis the idea?"}

    assess -->|vague| explore["Exploration Mode\nResearch, open questions,\nperiodic checkpoints"]
    assess -->|clear problem\nunclear solution| discover["Discovery Mode\nInvestigate approaches,\nnarrow toward a recommendation"]
    assess -->|clear intent| design["Design Mode\nClarify, propose 2-3 approaches,\npresent design for approval"]

    explore --> exploreArtifact["Exploration artifact written\n(mandatory before proceeding)"]
    exploreArtifact --> discover

    discover --> discoverArtifact["Discovery artifact written\n(mandatory before proceeding)"]
    discoverArtifact --> design

    design --> approval{"Design approved?"}
    approval -->|no| design
    approval -->|yes| plan["zenflow:plan"]
```

### Full Pipeline

```mermaid
flowchart TD
    idea["zenflow:idea"] -->|design approved| plan["zenflow:plan"]
    plan -->|plan saved| choose{Execution mode?}
    choose -->|parallel tasks| dispatch["zenflow:dispatch"]
    choose -->|coupled tasks| execplan["zenflow:exec-plan"]
    dispatch --> check["zenflow:check-work"]
    execplan --> check
    check -->|all gates pass| review["zenflow:review"]
```

### Bug Fix Pipeline

```mermaid
flowchart TD
    bugfix["zenflow:bug-fix"] --> parallel["Parallel diagnosis"]
    parallel --> detective["error-detective\nRoot cause analysis"]
    parallel --> coordinator["error-coordinator\nCascade risk analysis"]
    detective --> fix["Specialist writes\nminimal fix + regression test"]
    coordinator --> fix
    fix --> reviewer["Reviewer verifies fix"]
    reviewer --> checkwork["zenflow:check-work"]
```

### Collab Session with Delegation

```mermaid
flowchart TD
    collab["zenflow:collab"] --> work["Work with agent interactively"]
    work --> sideIssue{"Side issue found?"}
    sideIssue -->|small| inline["Inline delegate\nHandles in current directory"]
    sideIssue -->|large| worktree["Worktree delegate\nIsolated branch + PR"]
    inline --> work
    worktree --> work
    work --> longSession{"Session getting long?"}
    longSession -->|yes| refresh["zenflow:context-refresh\nWrite handoff + /clear"]
    refresh --> collab
    longSession -->|no| done["Done"]
```
