
## Workflow Examples

### New Feature (full pipeline)

```
You: /zenflow:idea  I want to improve how agents communicate results
  → "How concrete is this? Still forming, clear problem, or ready to design?"

You: Still forming — I know there's a problem but I'm not sure what to build
  → [Exploration mode: open questions, research agents investigate
     current communication patterns, checkpoint findings]
  → Exploration artifact produced

  → "This is getting concrete — ready to move into discovery?"
You: Yes
  → [Discovery mode: investigates 3 approaches — structured reports,
     streaming events, journal integration]
  → Discovery artifact produced: leading candidate is journal integration

  → "Ready to design?"
You: Yes, let's go with journal integration
  → [Design mode: clarifies schema, proposes architecture, presents design]
  → Design approved

You: /zenflow:plan
  → Plan saved to resources/plans/245-agent-communication.md

You: Subagent-Driven
  → /zenflow:dispatch executes 5 tasks with parallel subagents
  → Each task: implement → spec review → code quality review
  → /zenflow:check-work runs all 5 gates
  → Done
```

### Collab Session (inline delegation)

```
You: /zenflow:collab  Let's work on the notification system together
  → Starting collab session (Opus). Working on notifications together.

You: Let's start by looking at how SSE works in the server
  → [Reads SSE handler together, discusses architecture]
  → "The stream handler looks clean but I notice the rate limiter
     has a bug — it's not resetting the counter. Want to fix it
     inline or delegate?"

You: Delegate it, let's stay focused on notifications
  → [Extracts issue with context, reproduction steps, files involved]
  → [Spawns collab-delegate agent with full handoff]
  → Delegate:
      Loading project context...
        ✓ CLAUDE.md
      Loading .claude/rules/ ...
        ✓ error-handling.md
        ✓ async-patterns.md
        ✓ ... (all rules)
      Rules loaded: 13 files. Ready to work.
      [Writes regression test, fixes rate limiter]
  → "Rate limiter fix is in — added counter reset in middleware.
     Back to notifications..."
```

### Collab Session (worktree delegation)

```
You: /zenflow:collab  Let's explore the plugin system together
  → Starting collab session (Opus). Exploring plugins together.

You: I think the plugin loader needs a complete rewrite
  → [Reads plugin loader, discusses problems together]
  → "This is bigger than a side fix — 6 files involved, needs a plan.
     Want me to delegate this to a worktree so we can keep exploring?"

You: Yes, fire and forget — we'll review the PR later
  → [Extracts issue with full context and architectural notes]
  → [Spawns collab-delegate in isolated worktree]
  → "Delegate is working on its own branch. It'll plan the rewrite,
     implement it, and submit a PR. We'll review when it's ready.
     Back to exploring — what else did you want to look at?"

  → ... (20 minutes later, delegate finishes)
  → "The plugin loader PR is up: #247 — rewrites loader with
     lazy initialization, adds 12 tests. Review it when you're ready."

You: We'll look at it after we finish here
  → [Continues working, PR waiting for review]
```

### Bug Fix

```
You: /zenflow:bug-fix  SSE connections drop after 30 seconds
  → Reproduces the bug
  → Launches error-detective + error-coordinator in parallel
  → Detective: keep-alive interval missing in stream handler
  → Coordinator: no cascade risk, isolated to SSE module
  → Specialist writes regression test + minimal fix
  → Code reviewer approves
  → /zenflow:check-work validates
```

### Code Audit (full)

```
You: /zenflow:audit
  → Reads audit config from .claude/zen.local.md
  → Dispatches 4 specialist agents in parallel:
    Backend Architect → API Routes (12 files, 3 standards)
    Frontend Developer → Components (8 files, 1 standard)
    Software Architect → Core Orchestration (15 files, 4 standards)
    typescript-pro → Type Schemas (14 files, 2 standards)
  → Report: 49 files audited, 7 findings (1 Critical, 3 Important, 3 Minor)
  → "How should we handle findings?" → Fix Critical + Important
  → Dispatches fix agents, runs zenflow:check-work
```

### Code Audit (changed files only)

```
You: /zenflow:audit changed
  → Runs git diff --name-only main...HEAD
  → 6 files changed: 3 in routes/, 2 in components/, 1 in types/
  → Maps to 3 audit sections (skips Core Orchestration — no changes there)
  → Dispatches 3 agents (not 4 — only affected sections):
    Backend Architect → API Routes (3 files)
    Frontend Developer → Components (2 files)
    typescript-pro → Type Schemas (1 file)
  → Report: 6 files audited, 2 findings (0 Critical, 1 Important, 1 Minor)
  → Fast — finished in under a minute
```

### Refactor (internal API change)

```
You: /zenflow:refactor  triageIssue has 5 positional params, should be options object
  → Reads triageIssue and all 8 call sites
  → "This changes an internal function signature. All 8 callers are in this repo
     — no external consumers. This qualifies as an internal API refactor."
  → Proposes:
    Before: triageIssue(issueId, config, provider, db, sessionId)
    After:  triageIssue({ issueId, config, provider, db, sessionId })
  → Shows before/after for each of the 8 call sites
  → You approve
  → Writes characterization tests, updates signature + all callers, tests pass
  → zenflow:check-work validates
```

### Refactor (module split)

```
You: /zenflow:refactor  packages/core/src/core/triage.ts is getting unwieldy
  → Reads triage.ts and all callers/callees
  → Identifies: 3 responsibilities mixed in one file, 2 duplicated patterns
  → Proposes split into triage-interview.ts + triage-classifier.ts + triage.ts
  → Shows before/after for each extraction
  → You approve
  → Writes characterization tests, executes split, all tests pass
  → zenflow:check-work validates
```

### Recent Work Verification

```
You: /zenflow:status recent
  → Recent Verification: 245-realtime-notifications.md

  Task 1: SSE Event Schema — done
    ✓ packages/core/src/types/schema/sse-events.ts exists
    ✓ SSEEventSchema exported
    ✓ tests/unit/types/sse-events.test.ts — 4/4 passing

  Task 2: Stream Handler — partial
    ✓ packages/server/src/server/routes/sse.ts exists
    ✗ Missing: reconnection logic (described in step 4)
    ✓ tests/unit/routes/sse.test.ts — 3/3 passing

  Task 3: Client Subscriber — missing
    ✗ packages/frontend/src/lib/sse-client.ts does not exist

  Summary: 1 done, 1 partial, 1 missing
  → Updated frontmatter: validated: 2026-03-27, status: in-progress
```

### Documentation Update

```
You: /zenflow:docs
  → Reads .claude/zen.local.md for doc paths
  → Scans docs/, finds 3 stale guides
  → "Which docs should I update?" → Guides + README
  → Updates with current behavior
```

### Quick Status Check

```
You: /zenflow:status
  → Branch: feature/notifications (3 ahead, 2 uncommitted)
  → Active plan: 245-realtime-notifications.md (3/5 tasks, 60%)
  → Session: zenflow:dispatch in progress, zenflow:check-work not yet invoked
  → Last journal: worked on SSE system, blocker on rate limiting
```