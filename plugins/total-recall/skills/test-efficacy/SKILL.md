---
name: test-efficacy
description: Run the behavioral efficacy test — load rules, flood context with real code, test whether trigger phrases help an agent recall buried content vs re-reading, generic hints, or no intervention.
---

# Behavioral Efficacy Test Skill

The critical experiment: do trigger phrases actually help agents recall content that has decayed in long context windows?

## Tools

- Agent (to spawn efficacy-conductor)
- Read, Edit (to store results)

## Process

### 1. Parse Arguments

- **File paths**: Specific files to test (must have triggers in `.claude/triggers.json`)
- **`--flood-size N`**: Number of flood files (default 15)
- **`--questions N`**: Questions per file (default 3)
- **No arguments**: Conductor auto-selects top 3 files by confidence

### 2. Validate Triggers Exist

Read `.claude/triggers.json`. If specified files don't have triggers, warn the user and suggest running `/total-recall:scan` first.

### 3. Invoke Efficacy Conductor

Spawn the conductor agent:

```
Use Agent tool with:
  subagent_type: total-recall:efficacy-conductor
  prompt: |
    Run the behavioral efficacy test.
    
    Test files: <list file paths, or "auto-select top 3 by confidence">
    Flood size: <N>
    Questions per file: <N>
    
    Triggers data:
    <paste relevant entries from triggers.json>
```

### 4. Store Results

Read `.claude/efficacy-results.json` if it exists, otherwise create it. Append the conductor's output as a new run:

```json
{
  "version": 1,
  "runs": [
    <conductor output appended here>
  ]
}
```

### 5. Display Results

```markdown
## Behavioral Efficacy Test Results

**Date:** <timestamp>
**Files tested:** N
**Flood files:** N (~XK tokens of context displacement)

### Scores by Condition

| File | Trigger | Re-read | Generic | Baseline | Recovery Rate |
|------|---------|---------|---------|----------|---------------|
| file.md | X.X | X.X | X.X | X.X | XX% |

### Summary

- **Average trigger recovery rate:** XX% (trigger recovers XX% of re-read quality)
- **Trigger vs generic delta:** +X.X (convergent tokens add X.X points over generic hints)
- **Verdict:** <verdict string>

### Interpretation

- Recovery rate measures: (trigger - baseline) / (reread - baseline)
  - >70%: Strong validation — triggers work
  - 50-70%: Moderate — useful but imperfect
  - 30-50%: Weak — marginal utility
  - <30%: Triggers don't meaningfully outperform generic hints
  
- Trigger vs generic delta isolates whether the SPECIFIC convergent tokens matter
  or if any short reminder works equally well
```
