# The Pipeline

The ZenFlow pipeline moves work through five stages. Each stage has a defined purpose, and hooks prevent skipping the validation stage.

## Stage 1 — Idea (`/zenflow:idea`)

`idea` helps you move from a rough thought to an approved design before any code is written. It has three modes, selected automatically based on how you describe your idea:

**Exploration mode** — for vague or still-forming ideas. The agent asks open questions, does research, and checks in periodically. No implementation proposals are made until you signal you're ready. Ends with a mandatory written exploration artifact.

**Discovery mode** — for cases where the problem is clear but the solution isn't. Skips problem exploration, investigates solution approaches, and narrows toward a recommendation. Ends with a mandatory written discovery artifact.

**Design mode** — for cases where you know what you want to build. The agent clarifies requirements, proposes 2–3 approaches with tradeoffs, presents a design, and waits for your approval. No code until the design is approved.

The mandatory artifacts exist so that if the session ends early, the work-in-progress survives.

## Stage 2 — Plan (`/zenflow:plan`)

`plan` writes a detailed implementation plan and saves it to `resources/plans/NNN-name.md`. A good plan includes:

- Tasks broken into steps small enough to verify individually
- Complete code in each step (not pseudocode)
- Exact commands to run
- Tests written before or alongside the implementation

The plan file becomes the input for the execution stage.

## Stage 3 — Execute

Two options depending on your plan's structure:

### `/zenflow:dispatch` — Parallel execution

Spawns one subagent per task. Each task goes through two review passes:

1. **Spec reviewer** — did the implementation match the plan?
2. **Code quality reviewer** — does the code meet project standards?

Use this when tasks in the plan are independent of each other.

### `/zenflow:exec-plan` — Sequential execution

Runs tasks one at a time, stopping at checkpoints for review. Use this for tightly coupled tasks where later steps depend on the output of earlier ones, or when you want to review each step before proceeding.

## Stage 4 — Check Work (`/zenflow:check-work`)

Runs five gates in order. Each gate must pass before the next runs:

| Gate | What it does |
|------|-------------|
| 1 — Lint | Finds and runs the project linter from `package.json` or `CLAUDE.md` |
| 2 — Format | Finds and runs the project formatter |
| 3 — Tests | Finds and runs the test suite |
| 4 — Docs | Checks whether documentation is up to date given what changed |
| 5 — Journal | Invokes `agent-journal:write` (or falls back to writing the JSONL directly if the plugin isn't installed) |

Gates that fail are auto-fixed where possible. For failures that require judgment, `check-work` spawns a subagent to handle the fix.

A Stop hook prevents ending an execution session without running this command.

## Stage 5 — Review (`/zenflow:review`)

Dispatches a code reviewer subagent with the git diff. The reviewer outputs:

- A list of issues categorized as **Critical**, **Important**, or **Minor**, each with a `file:line` reference
- A clear merge verdict: ready to merge, needs changes, or blocked

---

## Standalone Commands

These operate independently from the main pipeline.

### `/zenflow:collab`

Opens a long-running collaborative session using the Opus model. The agent works with you interactively — exploring the codebase, building features, troubleshooting issues. When a side problem comes up, it's extracted and delegated to a separate `collab-delegate` agent rather than handled inline, keeping the main session focused.

Delegation options:
- **Inline** — the delegate agent works in the same directory and reports back
- **Worktree** — the delegate works in an isolated git worktree on its own branch, then submits a PR for review

Use `/zenflow:context-refresh` to shed accumulated context mid-session without ending it.

### `/zenflow:context-refresh`

Writes a structured handoff document to `.claude/handoffs/` that captures session goals, decisions made, open tasks, and next steps. After running `/clear` and re-invoking `/zenflow:collab`, the new session reads the handoff and resumes with minimal context loss.

Useful in long sessions where old file reads and debug output are accumulating without adding value.

### `/zenflow:bug-fix`

Runs a four-agent pipeline:

1. Two agents diagnose in parallel — one focuses on root cause, one focuses on cascade risk
2. A specialist writes a minimal fix with a regression test
3. A reviewer verifies the fix

### `/zenflow:audit`

Audits sections of your codebase against the rules defined in `.claude/rules/`. Dispatches one specialist agent per section in parallel.

- `/zenflow:audit` — audits the entire codebase
- `/zenflow:audit changed` — audits only files modified relative to main

The sections and rules are configured in `.claude/zen.local.md` under the `agents` key.

### `/zenflow:refactor`

Structured refactoring pipeline. The agent analyzes the target code, proposes changes with before/after examples, verifies regression test coverage exists, then executes. Internal API changes are in scope; external-facing API changes are not.

### `/zenflow:status`

Shows current project state: active plans (any with `status != complete` in frontmatter), task progress, git status, recent session history, and recent journal entries.

`/zenflow:status recent` — verifies tasks completed in the last 72 hours by inspecting tests, commits, and files, then stamps plans with `validated` frontmatter.

### `/zenflow:docs`

Reads `.claude/zen.local.md` to find documentation paths, assesses which docs are stale given recent changes, asks which ones to update, and writes the updates.
