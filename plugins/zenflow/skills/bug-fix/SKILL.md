---
name: bug-fix
description: Use when fixing bugs, errors, or unexpected behavior. Launches parallel diagnostic agents then a specialist to fix. Use for any issue that starts with "X is broken", "X doesn't work", error reports, or failing tests.
---

# Bug Fix

## Overview

Diagnose and fix bugs using a 4-agent pipeline: two diagnostic agents analyze the problem in parallel, a specialist writes the fix, and a code reviewer verifies quality.

**Announce at start:** "I'm using the zenflow:bug-fix skill to diagnose and fix this issue."

## The Process

### Step 1: Reproduce and Confirm

Before launching agents, confirm the bug:
- Reproduce the error (run the failing command, test, or scenario)
- Capture the actual error output
- Note the expected vs actual behavior
- If the bug cannot be reproduced, stop and report this to the user

### Step 2: Parallel Diagnosis

Launch **two agents in parallel** via `Agent` tool:

**Agent 1 — error-detective** (subagent_type: `error-detective`)
- Trace the error to its root cause
- Identify the exact file(s) and line(s) responsible
- Distinguish symptom from cause
- Report: root cause, affected files, reproduction steps

**Agent 2 — error-coordinator** (subagent_type: `error-coordinator`)
- Check if this error is part of a pattern (similar errors elsewhere)
- Look for cascade potential (will fixing this break something else?)
- Check recent git history for related changes that may have introduced the bug
- Report: related errors, cascade risk, recent changes that may be relevant

### Step 3: Determine Specialist

Based on diagnostic results, select the specialist agent type:

1. **Config first** — read `agents` array from `.claude/zen.local.md`, match the affected file path against each entry's `dir`, use that entry's `agent` field
2. **Discovery fallback** — if no config match, glob `.claude/agents/*.md` and `~/.claude/agents/*.md`, read each file's `name` and `description`, match the bug's location and domain to the most relevant agent
3. **Final fallback** — use `general-purpose`

**Inform the user** which agent was selected and why. If falling back to discovery or default:
> "No config match for this bug domain — using [agent]. Run `/zenflow:init` to generate agent assignments, or add an entry to your zen.local.md config."

### Step 4: Fix

Launch the **specialist agent** with:
- Both diagnostic reports (detective + coordinator findings)
- The reproduction steps from Step 1
- Clear instructions:

The specialist must:
1. Write a **regression test first** that fails without the fix
2. Run the test to confirm it fails
3. Implement the **minimal fix** — no refactoring, no gold plating
4. Run the test to confirm it passes
5. Run the project's full test suite to confirm no regressions
6. Report: what was changed, why, files modified

### Step 5: Review

Launch a **code-reviewer** agent (subagent_type: `Code Reviewer`) with:
- The specialist's report
- The diagnostic reports for context
- Git diff of the fix

The reviewer checks:
- Fix addresses root cause (not just symptom)
- No unnecessary changes beyond the fix
- Regression test actually covers the bug
- No new issues introduced

If the reviewer finds issues: send feedback to the specialist agent to fix, then re-review.

### Step 6: Validate

Run **zenflow:check-work** skill to pass all quality gates.

## STUCK Criteria

Declare STUCK — do not keep retrying — when:
- Same failure after 2 genuinely different fix approaches
- Root cause is outside this codebase (external dependency, infrastructure)
- Diagnostic agents disagree on root cause and neither can be confirmed
- Fix requires architectural changes beyond a bug fix scope

When marking STUCK, report:
- What was tried
- Where it failed
- What a human needs to decide

## Remember

- Reproduce before diagnosing
- Diagnose before fixing (detective + coordinator in parallel)
- Regression test before fix code (TDD)
- Minimal fix — no gold plating
- Review before shipping
- STUCK after 2 failed approaches

## Related Skills

- **zenflow:check-work** — Required at Step 6; runs all quality gates
- **zenflow:review** — Template for the review step
- **error-detective** — Root cause analysis agent
- **error-coordinator** — Error correlation and cascade detection agent
