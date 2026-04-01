---
name: exec-plan
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the zenflow:exec-plan skill to implement this plan."

**Note:** This skill works best with subagent support. If subagents are available, consider using zenflow:dispatch instead for higher quality parallel execution.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them before starting
4. If no concerns: Create tasks via `TaskCreate` for each section of the plan, then proceed

### Step 2: Determine Execution Strategy

Check if the plan includes a **Subagent Recommendation** section (specifying which agents, skills, and parallelization to use).

- **If recommendation exists**: Follow it — use the specified agent types, skills, and parallelization strategy.
- **If no recommendation**: Launch a Plan subagent to analyze the plan and recommend:
  - How many subagents to use
  - Which subagent types (e.g., Senior Developer, Frontend Developer, Backend Architect)
  - Which skills each subagent needs (e.g., testing-anti-patterns, react-best-practices)
  - Which tasks can be parallelized vs must be sequential
  - Present the recommendation to the user before proceeding

### Step 3: Execute Tasks

For each task:
1. Mark as `in_progress` via `TaskUpdate`
2. Follow each step exactly (plan has bite-sized steps)
3. Launch subagents in parallel for independent tasks per the execution strategy
4. Run verifications as specified
5. Mark as `completed` via `TaskUpdate`

### Step 4: Complete Development (MANDATORY — enforced by hook)

⚠️ **A Stop hook will BLOCK you from finishing if you skip this step.** You cannot complete a zenflow:exec-plan session without invoking zenflow:check-work.

After all tasks complete, do these in order:

1. **Invoke zenflow:check-work:** Call the Skill tool with `skill: "zenflow:check-work"`. Do NOT manually run lint/format/test — the skill handles all 5 gates including the journal entry. **Announce completion of each gate by name** (Lint, Format, Tests, Docs, Journal) as you pass it. Skipping the journal gate is a rule violation.
2. **Update the plan file frontmatter:**
   ```yaml
   ---
   status: complete
   completed: YYYY-MM-DD
   ---
   ```
3. **Report summary:** what changed, files modified, test count delta

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- User updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- **Step 4 is not optional** — you MUST invoke `zenflow:check-work` before finishing. A hook enforces this.

## Related Skills

- **zenflow:plan** — Creates the plan this skill executes; should include a Subagent Recommendation section
- **zenflow:check-work** — Required at Step 4; runs all quality gates (lint, format, tests, docs, journal)
- **zenflow:dispatch** — Alternative skill for fully parallel execution with subagents
