#!/usr/bin/env bash
# Stop hook: Blocks agents from finishing a zen:exec-plan or zen:dispatch session
# without invoking zen:check-work.
#
# Also supports legacy skill names for backwards compatibility.
set -euo pipefail

input=$(cat)

# Prevent infinite loops
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active')
if [[ "$stop_hook_active" == "true" ]]; then
  exit 0
fi

# Don't interfere with plan mode (separate hook handles that)
permission_mode=$(echo "$input" | jq -r '.permission_mode')
if [[ "$permission_mode" == "plan" ]]; then
  exit 0
fi

# Get transcript path
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
  exit 0
fi

# Check if zen:exec-plan, zen:dispatch, or legacy executing-plans skill was activated
if ! grep -qE '"(zen:exec-plan|zen:dispatch|executing-plans)"' "$transcript_path" 2>/dev/null; then
  exit 0
fi

# Execution skill is active — check if zen:check-work or legacy work-validation was invoked
if grep -qE '"(zen:check-work|work-validation)"' "$transcript_path" 2>/dev/null; then
  exit 0
fi

# Block: execution skill active but check-work never ran
printf '{"decision": "block", "reason": "You are running a zen execution skill. You MUST invoke zen:check-work using the Skill tool before finishing. Run: skill: \"zen:check-work\". Do NOT skip this step."}'
