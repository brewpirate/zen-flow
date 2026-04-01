---
name: index
description: Build a reverse word-to-files index from all stored triggers. Enables fast lookup — given a word or concept, find which files to load.
allowed-tools: Read, Edit
---

# Index — Build Master Word Index

## Overview

Reads `.claude/triggers.json` and builds `.claude/recall-index.json` — a reverse lookup that maps individual words and terms to the files they came from. This is the fast path: when an agent encounters a concept, it checks the index to find which files are relevant.

## Process

### 1. Read Triggers

Read `.claude/triggers.json`. If it doesn't exist or has no triggers, report "No triggers to index. Run `/total-recall:scan` first."

### 2. Build Reverse Index

For each trigger entry:

1. Take the **active phrase** and all **convergence terms**
2. Tokenize into individual words
3. Normalize: lowercase, strip plurals (simple `s` suffix), collapse obvious synonyms (e.g., "auth"/"authentication"/"authenticate" → "auth")
4. For each normalized word, add the file path to that word's file list

### 3. Score Entries

For each word in the index, calculate a **weight** based on:
- How many triggers it appeared in (higher = more generic, lower weight)
- Whether it came from a convergence term (higher weight) vs just the phrase
- Inverse document frequency — words appearing in fewer files are more distinctive

### 4. Write Index

Write `.claude/recall-index.json`:

```json
{
  "version": 1,
  "builtAt": "2026-03-31T10:05:00.000Z",
  "triggerCount": 15,
  "index": {
    "jwt": {
      "files": ["src/auth/middleware.ts", "src/auth/token.ts"],
      "weight": 0.9
    },
    "route": {
      "files": ["src/auth/middleware.ts", "src/router/index.ts"],
      "weight": 0.6
    },
    "database": {
      "files": ["src/db/connection.ts", "src/db/migrations.ts"],
      "weight": 0.85
    }
  }
}
```

### 5. Prune Noise

Remove words with weight below 0.2 — these are too generic to be useful triggers (e.g., "data", "handle", "process").

Also remove common stop words: the, a, an, is, are, was, were, be, been, being, have, has, had, do, does, did, will, would, could, should, may, might, can, shall, for, and, but, or, nor, not, so, yet, both, either, neither, each, every, all, any, few, more, most, other, some, such, no, only, own, same, than, too, very, just, because, as, until, while, of, at, by, with, from, into, through, during, before, after, above, below, to, in, on, out, off, over, under, between, about, against, this, that, these, those, it, its.

### 6. Report

```
Built recall index: N words → M files
Top 10 most distinctive terms:
  jwt → src/auth/middleware.ts (0.95)
  migration → src/db/migrations.ts (0.92)
  ...
```
