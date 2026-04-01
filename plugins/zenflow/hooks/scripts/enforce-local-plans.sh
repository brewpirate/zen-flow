#!/usr/bin/env bash
# PreToolUse hook (Write): Block plan writes to ~/.claude/plans/, redirect to project dir
set -euo pipefail

input=$(cat)

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
if [[ -z "$file_path" ]]; then
  exit 0
fi

# Only care about writes to ~/.claude/plans/
if [[ "$file_path" != "$HOME/.claude/plans/"* ]]; then
  exit 0
fi

# Find configured plans dir from zen.local.md
project_dir=$(echo "$input" | jq -r '.cwd // empty')
plans_dir="resources/plans"

if [[ -n "$project_dir" && -f "$project_dir/.claude/zen.local.md" ]]; then
  configured=$(sed -n '/^---$/,/^---$/p' "$project_dir/.claude/zen.local.md" | grep -E '^\s+dir:' | head -1 | sed 's/.*dir:\s*//' | sed 's/#.*//' | xargs)
  if [[ -n "$configured" ]]; then
    plans_dir="$configured"
  fi
fi

filename=$(basename "$file_path")

printf '{"decision": "block", "reason": "Plan files must be saved in the project, not ~/.claude/plans/. Write to %s/%s instead."}' "$plans_dir" "$filename"
