# total-recall

5 tokens to recall a 1000-token file. ~200:1 context compression through training-data resonance.

## The Problem

Rules, skills, and documentation loaded early in a long context window lose attention weight as newer content pushes them into the background. Re-reading them is expensive. Summarizing them loses specifics. You need a way to bring key content back to the front of the model's attention — cheaply.

## The Insight

Language models have consistent latent associations with content patterns. If you ask 5 independent agents to describe the same file in 6 words or fewer, the words that **converge across samples** are the ones most strongly encoded in training data. These convergent tokens are the model's own internal lookup keys for that content.

A trigger phrase built from these tokens doesn't summarize the file — it **reweights the model's attention** toward content already in context. 5 tokens that act as a spotlight, not a summary.

## What It's For

Total-recall is a **context priority system**. It targets key files — rules, skills, docs, CLAUDE.md — that are already loaded but decaying in attention. The trigger phrases aren't for finding files. They're for reshuffling what the model pays attention to.

Example: You have a code quality rule called "Broken Windows" loaded 40k tokens ago. Before asking an agent to write code, you inject:

> "Don't forget broken windows"

4 tokens. The rule is now front-of-mind instead of buried in context. No re-read, no summary, just an attention refresh at near-zero cost.

The models name the triggers — not you. Because the model knows its own associations better than you do. You might call a rule "code quality ratchet." The model might converge on "broken windows" independently — because that's where the weights are. The model's name is the one that works as a trigger because it's the one the model already responds to.

## Resonance Linting

An unexpected output: **low confidence scores diagnose unfocused rules**.

If 5 agents can't converge on a name for a rule, that rule is probably trying to do too many things. The convergence failure IS the diagnostic. If the model can't compress it into a resonant phrase, it probably can't attend to it well either.

Total-recall doesn't just generate triggers — it tells you which rules are well-written and which are mush.

- **High confidence (0.8+):** Rule is clear, focused, resonant. The trigger will work.
- **Medium confidence (0.6-0.8):** Rule might be doing two things. Consider splitting.
- **Low confidence (<0.6):** Rule is unfocused. Rewrite or decompose it.

## How It Works

```
/total-recall:scan skills/code-quality/SKILL.md
  │
  ▼
Research Agent (sonnet)
  │
  ├─ Phase 1: spawn 5 Study Agents (haiku) in parallel
  │    each reads the file → returns 1-6 word phrase
  │
  ├─ Check convergence: do 3+ of 5 share key terms?
  │    ├─ YES → strong signal, skip to synthesis
  │    └─ NO  → Phase 2: spawn 5 more agents
  │
  ├─ Find convergent tokens across all samples
  └─ Distill final trigger phrase
  │
  ▼
.claude/triggers.json  →  /total-recall:index  →  .claude/recall-index.json
(file → phrase)                                    (word → files reverse lookup)
```

### Two-Phase Sampling

Phase 1 runs 5 agents. If the file has a clear identity, convergence is strong and we stop — half the cost. If the signal is weak, Phase 2 runs 5 more for a total of 10. The `phases` field in the output tracks which files needed the extra round.

Files that consistently need Phase 2 are often files where the model can't decide what they're about — which usually means a human would struggle too. It's an accidental complexity detector.

## Commands

| Command | Description |
|---------|-------------|
| `/total-recall:scan <path>` | Study a file or directory and generate trigger phrases |
| `/total-recall:seed [path]` | Bootstrap triggers from docs, prompts, skills, and project knowledge |
| `/total-recall:list [filter]` | Show all stored triggers, optionally filtered |
| `/total-recall:index` | Rebuild the master word-to-files reverse lookup index |
| `/total-recall:forget <path>` | Remove triggers for a file or pattern |

## Storage

### Triggers — `.claude/triggers.json`

Maps files to their trigger phrases, raw samples, and convergence data:

```json
{
  "version": 1,
  "triggers": {
    "skills/code-quality/SKILL.md": {
      "phrase": "broken windows code quality",
      "samples": ["broken windows enforcement", "code quality ratchet rule", "..."],
      "convergence": ["broken", "windows", "quality"],
      "confidence": 0.92,
      "phases": 1,
      "scannedAt": "2026-03-31T10:00:00.000Z"
    }
  }
}
```

### Master Index — `.claude/recall-index.json`

Reverse lookup — given a word, find which files to load:

```json
{
  "version": 1,
  "builtAt": "2026-03-31T10:05:00.000Z",
  "triggerCount": 15,
  "index": {
    "broken windows": { "files": ["skills/code-quality/SKILL.md"], "weight": 0.95 },
    "dispatch": { "files": ["skills/dispatch/SKILL.md", "commands/dispatch.md"], "weight": 0.88 }
  }
}
```

## Seeding

Bootstrap triggers from existing project knowledge in one command:

```
/total-recall:seed
```

Auto-discovers: `CLAUDE.md`, skill definitions, agent definitions, command files, `README.md`, `ARCHITECTURE.md`, docs directories, and prompt files. Runs the same two-phase scan pipeline on each.

## Using Triggers

Inject trigger phrases into your prompts before task instructions:

```
Don't forget broken windows. Now implement the user profile endpoint.
```

Or add to your project's `CLAUDE.md` for automatic context routing:

```markdown
When you encounter a concept or phrase you lack context for, check `.claude/recall-index.json`.
Look up key terms to find which files to read for context.
```

## Why It Works

Traditional context management asks "how do I fit more into the window?" Total-recall asks "what's the minimum I need to inject to reweight attention toward content already in the window?"

The answer: the model's own convergent associations — the words it gravitates toward when independently describing the same content. These tokens are already the model's internal index keys. Total-recall just makes them explicit, persistent, and searchable.

It's not summarization. It's not retrieval. It's attention reshuffling — and it costs 5 tokens.
