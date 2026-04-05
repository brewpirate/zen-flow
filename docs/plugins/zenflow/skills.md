# Skills Reference

ZenFlow has 15 skills — commands you invoke to move work through different stages. This page explains what each one does, when to use it, and what to expect.

Skills fall into three categories:
- **Pipeline skills** — meant to be used in sequence for standard feature work
- **Standalone skills** — can be invoked at any time, independent of the pipeline
- **Auto-invoked** — run automatically as part of other skills; you don't call these directly

---

## Pipeline Skills

These are designed to be used in order. The pipeline moves from idea → plan → execute → validate → review.

---

### `/zenflow:init`

**What it does:** Scans your project and generates a configuration file at `.claude/zen.local.md`. This config tells every other ZenFlow skill how your project is organized.

**Run this once after installing.** It auto-detects:
- Programming language and framework
- Where your documentation lives (README, architecture docs, etc.)
- Which directories map to which types of work (routes, components, schemas, etc.)
- Which AI agents are available and which parts of the codebase they should handle

**What the generated config looks like:**
```yaml
project:
  language: typescript
  framework: nextjs

docs:
  readme: README.md
  architecture: docs/ARCHITECTURE.md

agents:
  - domain: api-routes
    dir: packages/server/src/routes/
    agent: Backend Architect
    rules:
      - error-handling
      - async-patterns
  - domain: frontend
    dir: packages/frontend/src/components/
    agent: Frontend Developer
    rules:
      - react-patterns
```

**What to do after:** Open `.claude/zen.local.md` and review what was generated. Adjust any directories or agent assignments that look wrong before using the rest of the pipeline.

**Re-running:** If you add new agents or restructure the project, run `/zenflow:init` again. It will show a diff and ask for approval before updating.

---

### `/zenflow:idea`

**What it does:** Helps you move from a rough idea to an approved design *before* any code is written. This is the entry point to the pipeline for all non-trivial work.

**Why this exists:** The most expensive place to catch a bad approach is after the code is already written. This skill forces alignment on *what* you're building and *why* before touching a single file.

**Three modes — selected automatically based on what you say:**

| Mode | When it applies | What happens |
|------|----------------|--------------|
| **Exploration** | The idea is vague or still forming | Claude asks open questions, researches the codebase, and helps you think — no proposals yet |
| **Discovery** | The problem is clear but the solution isn't | Claude investigates solution approaches and narrows toward a recommendation |
| **Design** | You know what you want to build | Claude clarifies requirements, proposes 2–3 approaches with trade-offs, presents a design for your approval |

**Hard rule:** No code is written until you explicitly approve the design. This is enforced — the skill refuses to proceed to implementation without your sign-off.

**What it produces:** A written artifact (exploration summary, discovery summary, or design doc) saved as a field-notes entry. If the session ends early, the work-in-progress is preserved.

**What comes next:** Once the design is approved, the skill automatically invokes `zenflow:plan`.

---

### `/zenflow:plan`

**What it does:** Takes an approved design and turns it into a detailed, step-by-step implementation plan. The plan is saved to `resources/plans/NNN-feature-name.md`.

**What a good plan includes:**
- A header with goal, architecture summary, and tech stack
- Tasks broken into steps small enough to verify individually (2–5 minutes each)
- Complete code in every step — not pseudocode, not "implement X here"
- Exact commands to run with expected output
- Tests written *before* or *alongside* the implementation (TDD)
- A Verification section at the end listing how to confirm the work is correct
- A Subagent Recommendation section suggesting how many parallel agents to use and which tasks are independent vs. sequential

**Why steps must be complete:** Plans are executed by agents (via `dispatch` or `exec-plan`). Vague steps like "add appropriate error handling" cause agents to guess and produce inconsistent results.

**After the plan is saved:** Claude offers two execution options and asks which you prefer:

1. **Subagent-driven** — dispatches agents per the Subagent Recommendation section (faster, parallel)
2. **Inline execution** — runs tasks step-by-step in the current session (more review, slower)

---

### `/zenflow:dispatch`

**What it does:** Executes a plan by dispatching a separate AI agent for each task. Tasks run in parallel when they're independent. Each task goes through two review passes before being marked complete.

**How it works:**

For each task in the plan:
1. A fresh **implementer agent** receives the task text and implements it — no shared context from the main session
2. A **spec reviewer** checks: does the implementation match what the plan specified?
3. A **code quality reviewer** checks: is the code well-written by the project's standards?
4. If either reviewer finds issues, the implementer fixes them and the reviewer checks again
5. Only when both reviewers approve is the task marked complete

After all tasks complete, a final reviewer checks the whole implementation, then `check-work` runs automatically.

**Why fresh agents per task:** Each agent starts with a clean context, which prevents confusion from earlier tasks bleeding into later ones. The orchestrating agent (you) provides exactly the context each implementer needs — no more, no less.

**Model selection:** The skill uses cheaper/faster models for straightforward mechanical tasks (single file, clear spec) and more capable models for tasks requiring judgment or cross-file coordination.

**When to use this vs. `exec-plan`:**
- Use `dispatch` when tasks in your plan are **independent** — they don't need to see each other's output
- Use `exec-plan` when tasks are **tightly coupled** — each step depends on the previous

**What it produces:** All tasks implemented and reviewed, `check-work` run, plan frontmatter updated to `complete`.

---

### `/zenflow:exec-plan`

**What it does:** Executes a plan sequentially in the current session, stopping at checkpoints for review between tasks.

**How it works:**
1. Reads the plan file and reviews it critically — raises concerns before starting
2. If the plan has a Subagent Recommendation section, follows it (agent types, skills, which tasks parallelize)
3. Runs tasks one at a time, marking each in-progress then complete
4. Stops and asks if it hits a blocker — never guesses
5. Runs `zenflow:check-work` at the end (enforced by a hook — can't skip)

**When to use this vs. `dispatch`:**
- Use `exec-plan` when tasks are **tightly coupled** (step 3 depends on step 2's output)
- Use `exec-plan` when you want to **review each step manually** before proceeding
- Use `dispatch` for faster parallel execution of independent tasks

---

### `/zenflow:check-work`

**What it does:** Runs five quality gates in sequence after implementation. A built-in hook prevents ending an execution session without running this.

**The five gates:**

| Gate | What it does |
|------|-------------|
| **1 — Lint** | Finds and runs your project's linter. If it fails, tries the auto-fix command first. Spawns a subagent for anything auto-fix can't handle. |
| **2 — Format** | Finds and runs your project's formatter. Same auto-fix-first approach. |
| **3 — Tests** | Runs the full test suite — not just the files you changed. If tests fail, spawns subagents to fix them, then re-runs everything. |
| **4 — Docs** | Reviews what changed in the session and updates documentation that's now stale (README, ARCHITECTURE, CLAUDE.md, etc.). |
| **5 — Journal** | Invokes `field-notes:write` to log the session. Falls back to writing directly to `.claude/journal.jsonl` if field-notes isn't installed. |

**Gates 1 and 2** can run in parallel. **Gate 3** waits for 1 and 2 to be clean. **Gates 4 and 5** can run in parallel after tests pass.

**Auto-fix behavior:** For lint and format failures, it tries the project's fix command first (`lint:fix`, `format:fix`, etc.) before escalating to a subagent. For test failures, it dispatches one subagent per failing test file.

**Stop condition:** If a gate still fails after two attempts, the skill stops and reports the failure rather than looping indefinitely.

---

### `/zenflow:review`

**What it does:** Dispatches a code reviewer agent with the git diff. The reviewer evaluates the changes independently — it doesn't have your session's history, only the diff and what was supposed to be built.

**What the reviewer returns:**
- Findings categorized as **Critical**, **Important**, or **Minor**, each with a file:line reference
- A clear verdict: ready to merge, needs changes, or blocked

**How to act on findings:**
- Fix **Critical** issues immediately — the review is not done until these are resolved
- Fix **Important** issues before moving on
- Note **Minor** issues for later (or fix them now if easy)

**When to use it:**
- After `check-work` passes on a completed feature
- Before merging to main
- When you want a fresh perspective on something you've been staring at

The review happens in a separate agent so it sees your work with fresh eyes — not influenced by your implementation decisions or the context you've built up.

---

## Standalone Skills

These work independently of the pipeline and can be invoked at any time.

---

### `/zen`

**What it does:** Opens an interactive menu listing every available command. Good starting point when you're not sure what to run next or want to see everything at a glance.

---

### `/zenflow:collab`

**What it does:** Opens a long-running collaborative session using Claude Opus. This is a fundamentally different mode from the pipeline — instead of executing tasks, Claude acts as a thinking partner.

**What "thinking partner" means in practice:**
- Claude explores the codebase with you, discusses architecture, and surfaces trade-offs
- It does *not* write code in the main session — when it's time to build, it writes a structured handoff and delegates to a subagent
- Side problems that come up get extracted and delegated to fresh agents (inline or in isolated git worktrees) instead of handled inline — this keeps the main session focused

**When to use collab:**
- Exploring unfamiliar code to understand how it works
- Thinking through a design decision with a sounding board
- Working through a complex bug where the root cause isn't obvious
- Any extended session where you want ongoing partnership rather than one-shot execution

**Delegation options:**
- **Inline** — the delegate agent works in the same directory and reports back
- **Worktree** — the delegate works in an isolated git worktree on its own branch, then submits a PR for review

**Session management:** Use `/zenflow:context-refresh` when the session gets long and starts feeling sluggish. See [Collab](/plugins/zenflow/collab) for the full reference.

---

### `/zenflow:context-refresh`

**What it does:** Writes a structured handoff document, then guides you through clearing the session and resuming cleanly.

**Why this exists:** In a long collab session, the context window fills with file reads, debug output, and old diffs that are no longer relevant. Re-reading everything costs attention and degrades response quality. A context refresh sheds the dead context without losing the partnership.

**What it captures in the handoff document:**
- Session goals and what was accomplished
- Active decisions and constraints
- Tasks in progress or delegated
- How you prefer to work (communication style, what corrections you gave)
- Observations about the session that don't fit neatly elsewhere
- Immediate next steps so the resume can pick up without re-exploring

**How the resume works:** After you run `/clear` and re-invoke `/zenflow:collab`, the new session automatically detects the handoff file and resumes from where you left off — goals, working style, and next steps intact.

**When to suggest it (collab watches for these signals):**
- 15+ files have been read and most are no longer relevant
- A long debug tangent consumed significant context
- Responses feel less sharp
- The session feels sluggish

---

### `/zenflow:bug-fix`

**What it does:** Diagnoses and fixes a bug using a four-agent pipeline.

**The four stages:**

1. **Reproduce** — Claude first confirms it can reproduce the bug before doing anything. If it can't reproduce, it stops and reports this rather than guessing.

2. **Parallel diagnosis** — Two agents run simultaneously:
   - **error-detective:** Traces the error to its root cause. Finds the exact file and line responsible. Distinguishes symptom from cause.
   - **error-coordinator:** Checks whether this error is part of a pattern, looks for cascade risk (will fixing this break something else?), and checks recent git history for related changes.

3. **Fix** — A specialist agent receives both diagnostic reports and implements a minimal fix. The specialist must:
   - Write a regression test *first* (TDD — the test should fail without the fix)
   - Implement the minimal fix to make the test pass
   - Run the full test suite to confirm no regressions
   - No refactoring, no unrelated improvements

4. **Review** — A code reviewer verifies the fix addresses the root cause (not just the symptom), the regression test actually covers the bug, and no new issues were introduced.

**Specialist selection:** The skill reads `.claude/zen.local.md` to match the bug's location to the right agent. If no match is found, it tells you which agent it selected and why.

**When the skill gives up:** After two genuinely different fix approaches fail, the skill marks itself STUCK and reports what was tried, where it failed, and what a human needs to decide. It doesn't loop indefinitely.

---

### `/zenflow:audit`

**What it does:** Reviews sections of your codebase against the coding rules defined in `.claude/rules/`. Dispatches one specialist agent per section in parallel.

**Two modes:**
- `/zenflow:audit` — audits everything configured in `.claude/zen.local.md`
- `/zenflow:audit changed` — only audits files modified relative to main (faster, good for pre-merge checks)

**How it's configured:** The `agents` array in `.claude/zen.local.md` defines which directories to audit, which rules to apply, and which agent type to use:

```yaml
agents:
  - domain: api-routes
    dir: packages/server/src/routes/
    rules:
      - error-handling
      - async-patterns
    agent: Backend Architect
```

**What each auditor produces:** A structured report with findings at `file:line` level, categorized as Critical, Important, or Minor.

**What you get at the end:** A merged report across all sections sorted by severity, followed by an offer to fix findings (immediately, via a structured plan, or save for later).

**Prerequisite:** Requires `zenflow:init` to have been run first. If no config exists, the skill tells you to run it.

---

### `/zenflow:refactor`

**What it does:** A structured refactoring pipeline — analyzes the target code, proposes concrete changes with before/after examples, ensures test coverage exists, then executes.

**Hard constraint:** Refactoring must not change external behavior — the public API that code *outside* this repository depends on. Internal API changes are allowed if all callers are updated in the same scope.

**The process:**

1. **Identify** — you specify what to refactor (a file, function, module, or pattern). If vague, Claude reads the code first and presents specific issues for you to choose from.

2. **Analyze** — reads all affected code, maps dependencies (who imports this, what does this import), identifies test coverage gaps, and catalogs specific problems.

3. **Propose** — presents a concrete before/after example for each change, an impact assessment (files modified/created, breaking changes), and asks for your approval before doing anything.

4. **Ensure coverage** — before touching anything, runs the full test suite to establish a baseline. If the target code lacks tests, writes characterization tests (tests that capture current behavior exactly) first. The refactor happens *only* after a safety net exists.

5. **Execute** — small refactors (1–3 files) are done directly; large ones (4+ files) go through `zenflow:plan` + `zenflow:dispatch`.

6. **Validate** — runs the full test suite again and confirms counts match or exceed baseline.

**Common refactoring patterns it supports:** Extract function, inline function, rename, split module, replace conditional with polymorphism, consolidate options object.

**When to stop:** If tests start failing during a refactor, the skill stops rather than adjusting tests to make them pass. Failing tests during refactoring mean the refactor changed behavior — that's the signal to investigate, not to fix the tests.

---

### `/zenflow:status`

**What it does:** Shows a quick snapshot of where things stand — active plans, task progress, git state, and recent journal entries.

**Two modes:**

**Default mode** — fast scan:
```
Branch: feature/notifications (3 ahead of main, 2 uncommitted files)

Active Plans:
- 245-realtime-notifications.md — 3/5 tasks complete (60%)
- 246-audit-config.md — planned (not started)

Current Session:
- Tasks: 2 completed, 1 in progress
- Skills used: zenflow:idea → zenflow:plan → zenflow:dispatch (in progress)
- ⚠ zenflow:check-work not yet invoked

Last Journal (2026-03-26):
- Worked on: SSE notification system
- Blocker: Rate limiting config unclear
```

**Deep mode** (`/zenflow:status recent`) — verifies recent work was actually done:
- Runs against plans from the last 72 hours
- Checks each task using three signals: tests passing, commits to the right files, expected files existing
- Returns a verdict for each task: `done`, `partial`, `missing`, or `broken`
- Stamps the plan's frontmatter with a `validated` date and summary

**When to use it:**
- When resuming work after a break ("Where was I?")
- Before handing off to another session or agent
- After another agent finishes work, to verify before trusting it
- At the end of a milestone to confirm everything was actually completed

---

### `/zenflow:docs`

**What it does:** Identifies documentation that's stale given recent code changes and updates it.

**How it works:**
1. Reads `.claude/zen.local.md` to find where your docs live
2. Runs `git diff` to see what changed in the current session
3. Reads each doc file and assesses whether it reflects the current state of the code
4. Asks which docs to update (README, architecture, API reference, guides, inline comments)
5. Updates the selected docs with accurate information from the actual code

**Principles it follows:**
- Reads the actual code before writing documentation — never documents behavior it hasn't verified
- Doesn't duplicate information across docs — links instead
- Docs should describe what exists now, not what's planned

**When it runs automatically:** `zenflow:check-work` Gate 4 uses the same approach. If docs are stale after implementation, `check-work` will update them.

---

## Auto-Invoked

These skills run as part of other commands. You don't invoke them directly.

---

### `testing-anti-patterns`

**What it does:** Enforces good testing practices during any test-writing stage. Applied automatically when agents write or modify tests.

**The five patterns it prevents:**

| Anti-pattern | What it looks like | Why it's a problem |
|---|---|---|
| **Testing mock behavior** | `expect(screen.getByTestId('sidebar-mock'))` | Verifies the mock works, not real behavior — test passes even if the real component is broken |
| **Test-only methods in production code** | A `destroy()` method only called from test files | Pollutes the production API with test-specific code that risks accidental production calls |
| **Mocking without understanding** | Mocking a method that writes config your test needs to read | Over-mocking breaks the test logic silently |
| **Incomplete mock data** | Only including the fields you think you need | Downstream code may access omitted fields — tests pass, production fails |
| **Tests as afterthought** | Writing code first, tests after | Violates TDD; means tests are structured around the implementation, not the behavior |

**The core rule:** Test real behavior, not mock behavior. Mocks are isolation tools — they remove external dependencies (network, database, file system) so tests run fast and reliably. They are not the subject of the test.

---

### `field-notes:write` (auto-invoked by check-work)

**What it does:** Logs the session to `.claude/journal.jsonl`. Called automatically by `zenflow:check-work` at Gate 5.

If `field-notes` is installed, the skill invokes it to prompt for session details. If it's not installed, `check-work` writes a structured entry directly to the JSONL file using the same schema.

See the [Field Notes plugin](/plugins/field-notes/) for the full logging reference.

---

## Field Notes Commands (from the field-notes plugin)

These commands are part of the `field-notes` plugin but integrate directly with ZenFlow. See [Field Notes](/plugins/field-notes/) for full documentation.

| Command | What it does |
|---------|-------------|
| `/field-notes:write` | Appends a structured entry to `.claude/journal.jsonl` |
| `/field-notes:read [filter]` | Shows recent entries with optional filtering |
| `/field-notes:summary [range]` | Aggregates patterns across a time range |
| `/field-notes:reflect` | Runs an end-of-session retrospective and writes a `reflection` entry |
