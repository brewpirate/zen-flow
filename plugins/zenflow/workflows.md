# Workflows & Diagrams

[Back to README](README.md)

## Navigation

**Diagrams**
- [zenflow:idea — Three Modes](#zenflowidea--three-modes)
- [Full Pipeline Flow](#full-pipeline-flow)
- [Bug Fix Pipeline](#bug-fix-pipeline)
- [Collab Session Flow](#collab-session-flow)
- [Context Refresh Flow](#context-refresh-flow)

**Examples**
- [New Feature (full pipeline)](#new-feature-full-pipeline)
- [Collab Session (inline delegation)](#collab-session-inline-delegation)
- [Collab Session (worktree delegation)](#collab-session-worktree-delegation)
- [Context Refresh (mid-session)](#context-refresh-mid-session)
- [Bug Fix](#bug-fix)
- [Documentation Update](#documentation-update)

---

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
    check -->|"all gates pass"| done([Ship It])

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
    finish -->|"context heavy"| refresh["<b>zenflow:context-refresh</b><br/><small>Write handoff → /clear → resume</small>"]
    refresh --> work
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
    style refresh fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style finish fill:#24283b,color:#c0caf5,stroke:#565f89
    style check fill:#e0af68,color:#1a1b26,stroke:#e0af68
```

### Context Refresh Flow

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1a1b26', 'primaryTextColor': '#c0caf5', 'lineColor': '#565f89', 'secondaryColor': '#24283b', 'tertiaryColor': '#24283b' }}}%%
flowchart TD
    trigger(["Context getting heavy"]) --> suggest
    suggest["Agent Suggests Refresh<br/><small>Never unilateral — user decides</small>"]
    suggest --> approved{User agrees?}
    approved -->|no| back([Continue Working])
    approved -->|yes| name

    name["Establish Session Name<br/><small>User picks a label<br/>(e.g., 'auth-rewrite')</small>"]
    name --> capture

    subgraph capture ["Capture Session State"]
        direction TB
        observations["Observations & Discoveries<br/><small>Aha moments, direction shifts,<br/>user patterns</small>"]
        calibration["Behavioral Calibration<br/><small>Working style, corrections,<br/>partnership dynamics</small>"]
        tasks["Snapshot Tasks<br/><small>Open, in-progress, completed</small>"]
        delegates["Check Active Delegates<br/><small>Warn if any in-flight</small>"]
    end

    capture --> journal["Write Journal Entry<br/><small>type: context-refresh</small>"]
    journal --> write["Write Handoff Document<br/><small>.claude/handoffs/&lt;name&gt;-&lt;timestamp&gt;.md</small>"]
    write --> confirm["Confirm with User<br/><small>'Ready to clear'</small>"]
    confirm --> clear[/"User runs /clear"/]
    clear --> reopen[/"User invokes /zenflow:collab"/]

    reopen --> detect["Detect Handoff File<br/><small>Check .claude/handoffs/ for recent files</small>"]
    detect --> stale{"< 2 hours old?"}
    stale -->|no| fresh["Suggest Fresh Start<br/><small>Use journal + memory instead</small>"]
    stale -->|yes| read["Read Handoff Document"]
    read --> philosophy["Re-read Collab Philosophy<br/><small>Calibration fade mitigation</small>"]
    philosophy --> restore["Restore Calibration<br/><small>Apply user prefs & corrections</small>"]
    restore --> summary["Summarize State to User<br/><small>'Here's where we are...'</small>"]
    summary --> confirm2{"User confirms?"}
    confirm2 -->|yes| resume([Resume from Next Steps])
    confirm2 -->|"things changed"| adjust["Update Understanding<br/><small>Adjust before continuing</small>"]
    adjust --> resume

    style trigger fill:#24283b,color:#c0caf5,stroke:#565f89
    style suggest fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style approved fill:#24283b,color:#c0caf5,stroke:#565f89
    style back fill:#24283b,color:#c0caf5,stroke:#565f89
    style name fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style capture fill:#24283b,color:#c0caf5,stroke:#565f89
    style observations fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style calibration fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style tasks fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style delegates fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style journal fill:#73daca,color:#1a1b26,stroke:#73daca
    style write fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style confirm fill:#7aa2f7,color:#1a1b26,stroke:#7aa2f7
    style clear fill:#f7768e,color:#1a1b26,stroke:#f7768e
    style reopen fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style detect fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style stale fill:#24283b,color:#c0caf5,stroke:#565f89
    style fresh fill:#24283b,color:#c0caf5,stroke:#565f89
    style read fill:#7dcfff,color:#1a1b26,stroke:#7dcfff
    style philosophy fill:#bb9af7,color:#1a1b26,stroke:#bb9af7
    style restore fill:#e0af68,color:#1a1b26,stroke:#e0af68
    style summary fill:#7aa2f7,color:#1a1b26,stroke:#7aa2f7
    style confirm2 fill:#24283b,color:#c0caf5,stroke:#565f89
    style resume fill:#9ece6a,color:#1a1b26,stroke:#9ece6a
    style adjust fill:#73daca,color:#1a1b26,stroke:#73daca
```

---

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

### Context Refresh (mid-session)

```
You: /zenflow:collab  Let's work on the auth system together
  → Starting collab session (Opus).

  ... (2 hours of exploration, debugging, delegating)

Agent: "We've read a lot of files and gone through some debug tangents.
  Want to do a context refresh so we can continue with a clean slate?"

You: Good idea
  → "What should we call this session?"
You: auth-rewrite
  → Writing context refresh handoff...
  → Journal entry written (type: context-refresh)
  → Handoff saved to .claude/handoffs/auth-rewrite-2026-04-01T14:30:00Z.md
  → "Ready to clear. Run /clear, then re-invoke /zenflow:collab."

You: /clear

You: /zenflow:collab
  → Detected handoff: auth-rewrite (30 seconds ago)
  → Re-reading collab philosophy...
  → "Resuming session 'auth-rewrite'. Here's where we are:
     - Mapped the auth middleware chain, delegated session token fix to worktree
     - Decided on JWT rotation strategy with 15-min expiry
     - Next up: design the refresh token endpoint
     Does this match your understanding?"

You: Yes, let's continue
  → [Resumes from next steps with clean context]
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

### Documentation Update

```
You: /zenflow:docs
  → Reads .claude/zen.local.md for doc paths
  → Scans docs/, finds 3 stale guides
  → "Which docs should I update?" → Guides + README
  → Updates with current behavior
```
