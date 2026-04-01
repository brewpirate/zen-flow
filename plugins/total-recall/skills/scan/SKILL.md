---
name: scan
description: Study files and generate semantic trigger phrases by spawning a researcher agent that samples model associations and finds convergent patterns.
---

# Scan — Generate Trigger Phrases

## Overview

Scan one or more files to generate training-data-resonant trigger phrases. Each file is studied by 10 independent agents; a research agent then identifies convergent patterns across their responses to produce the most reliable semantic handle.

## Process

### 1. Resolve Input

- If the user provided a **file path**: use it directly
- If the user provided a **directory**: glob for relevant source files
  - Include: `**/*.{ts,tsx,js,jsx,py,go,rs,md,json,yaml,yml,sh,sql,css,scss,html,svelte,vue}`
  - Exclude: `node_modules/`, `dist/`, `build/`, `.git/`, `*.lock`, `*.min.*`
  - Cap at 20 files per run. If more, inform the user and process the first 20.
- If **no argument**: ask the user what to scan

### 2. Invoke Researcher Agent

Spawn the `researcher` agent (use the Agent tool with `subagent_type` set to `total-recall:researcher`). Provide it with the resolved file list:

```
Generate trigger phrases for these files:
<list each absolute file path, one per line>
```

The researcher will handle spawning 10 study agents per file and performing convergence analysis.

### 3. Store Results

Read `.claude/triggers.json` (create if it doesn't exist with `{"version": 1, "triggers": {}}`).

For each file result from the researcher, merge into the triggers object:

```json
{
  "src/auth/middleware.ts": {
    "phrase": "the final trigger phrase",
    "samples": ["all", "ten", "raw", "phrases", "..."],
    "convergence": ["recurring", "terms"],
    "confidence": 0.85,
    "scannedAt": "2026-03-31T10:00:00.000Z"
  }
}
```

Use **relative paths** (from project root) as keys. Write the updated file back.

### 4. Rebuild Index

After storing results, invoke the `total-recall:index` skill to rebuild the master word index from all triggers.

### 5. Report

Display results as a table:

```
File                        | Trigger Phrase                | Confidence
--------------------------- | ---------------------------- | ----------
src/auth/middleware.ts      | jwt route authentication guard | 0.90
src/db/connection.ts        | database connection pool mgmt  | 0.85
```

If any file had low confidence (< 0.6), note it and suggest rescanning.
