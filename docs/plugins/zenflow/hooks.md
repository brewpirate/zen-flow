# Hooks

ZenFlow installs three hooks automatically when the plugin is added. They enforce process discipline and cannot be bypassed through normal usage.

## enforce-plan-mode-tools

**Type:** Stop hook  
**File:** `hooks/scripts/enforce-plan-mode-tools.sh`

When Claude Code is in plan mode, this hook fires at the end of every turn and checks whether `ExitPlanMode` or `AskUserQuestion` was called. If neither was called, the turn is blocked.

This ensures plan mode turns are deliberate — either the agent exits plan mode when done, or it asks a question. It prevents the agent from silently ending a plan-mode turn without a clear next action.

## enforce-work-validation

**Type:** Stop hook  
**File:** `hooks/scripts/enforce-work-validation.sh`

After `/zenflow:exec-plan` or `/zenflow:dispatch` runs, this hook blocks the session from ending until `/zenflow:check-work` has been invoked. It checks for evidence that `check-work` ran in the current session.

This enforces that lint, format, tests, docs, and journal gates are always run after implementation — not skipped because things "seemed fine."

## enforce-local-plans

**Type:** PreToolUse hook  
**File:** `hooks/scripts/enforce-local-plans.sh`

Intercepts file write calls that target `~/.claude/plans/` and redirects them to the project's `resources/plans/` directory instead. This keeps implementation plans inside the project repository rather than in the user's global Claude config directory.

Plans in `resources/plans/` can be committed, reviewed, and referenced by other team members. Plans in `~/.claude/plans/` are user-local and not portable.

---

## How hooks interact with workflow

The hooks work together to enforce the intended sequence:

1. `enforce-plan-mode-tools` — keeps plan mode exits intentional
2. `enforce-work-validation` — prevents skipping validation after implementation
3. `enforce-local-plans` — keeps plan files in the project

None of these hooks require configuration. They install and activate automatically with the plugin.
