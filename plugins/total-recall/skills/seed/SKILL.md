---
name: seed
description: Scan prompt files, CLAUDE.md docs, skill definitions, and other documentation to seed trigger phrases — bootstrapping total-recall from existing project knowledge.
---

# Seed — Bootstrap Triggers from Docs and Prompts

## Overview

Automatically discover and scan documentation, prompt files, skill definitions, and configuration docs in the project. This seeds the trigger index from existing project knowledge so total-recall is useful immediately without manually scanning every file.

## Process

### 1. Discover Seedable Files

Glob for documentation and prompt files across the project:

- `**/CLAUDE.md` — project instructions
- `**/.claude/**/*.md` — claude config docs
- `**/skills/**/SKILL.md` — skill definitions
- `**/agents/*.md` — agent definitions
- `**/commands/*.md` — command definitions
- `**/docs/**/*.md` — documentation directories
- `**/README.md` — readmes
- `**/*.prompt.md`, `**/*-prompt.md` — prompt files
- `**/ARCHITECTURE.md`, `**/CONTRIBUTING.md`, `**/CHANGELOG.md`

Exclude: `node_modules/`, `dist/`, `build/`, `.git/`

If the user provided a specific path, scan only that path.

### 2. Filter Already-Scanned

Read `.claude/triggers.json`. Skip any files that already have trigger entries unless the user passed `--force` or `--rescan`.

### 3. Invoke Researcher

For each batch of unscanned files (up to 20 per batch), spawn the `researcher` agent (use the Agent tool with `subagent_type` set to `total-recall:researcher`):

```
Generate trigger phrases for these files:
<list absolute file paths, one per line>
```

### 4. Store Results

Merge results into `.claude/triggers.json` following the same format as the scan skill. Tag seeded entries with `"source": "seed"` to distinguish from manual scans:

```json
{
  "src/auth/middleware.ts": {
    "phrase": "jwt route authentication guard",
    "samples": ["...", "..."],
    "convergence": ["jwt", "route", "auth"],
    "confidence": 0.85,
    "source": "seed",
    "scannedAt": "2026-03-31T10:00:00.000Z"
  }
}
```

### 5. Rebuild Index

After storing all results, invoke the `total-recall:index` skill to rebuild the master word index.

### 6. Report

```
Seeded N new triggers from M files:

  File                              | Trigger Phrase                    | Confidence
  --------------------------------- | --------------------------------- | ----------
  CLAUDE.md                         | project rules and conventions     | 0.88
  plugins/zenflow/skills/plan/...   | implementation planning workflow  | 0.92
  docs/ARCHITECTURE.md              | system design and structure       | 0.80

Skipped K files (already scanned). Use --rescan to regenerate.
Rebuilt recall index: X words → Y files.
```
