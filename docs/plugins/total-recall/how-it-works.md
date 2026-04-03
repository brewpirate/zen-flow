# How It Works

## Convergence sampling

When you run `/total-recall:scan` on a file, the researcher agent spawns 5 study agents in parallel. Each study agent reads the file independently and returns a 1–6 word phrase describing it. No coordination between agents.

After collecting all 5 phrases, the researcher checks for convergence: do 3 or more agents share key terms? If yes, those terms become the trigger phrase. If no — weak convergence — the researcher escalates to a larger model.

```
/total-recall:scan rules/error-handling.md --models sonnet

Research Agent (sonnet)
  │
  ├─ Spawn 5 × sonnet study agents in parallel
  │    each reads the file → returns 1-6 word phrase
  │
  ├─ Check convergence (3+ of 5 share key terms?)
  │    ├─ YES → synthesize trigger from convergent terms
  │    └─ NO  → escalate to opus, run 5 more
  │
  └─ Store result in .claude/triggers.json
```

## Model escalation

When Phase 1 convergence is weak, the escalation path is:
- Haiku weak → escalate to Sonnet
- Sonnet weak → escalate to Opus
- Opus weak → 5 more Opus agents (no further escalation)

This is based on cross-model testing that showed weak convergence in smaller models is usually a signal that the model is struggling to identify the file's core concept — repeating with the same model adds noise, not signal.

Files that consistently need escalation tend to be files that cover multiple topics. The escalation pattern functions as a complexity detector.

## Model-scoped triggers

Each model produces its own trigger phrase for the same file. Sonnet and Opus use different internal representations and converge on different terms. The `--models` flag lets you generate triggers for whichever models your agents actually use.

Example for a rule about code quality:
- Sonnet converges on: `"broken windows code quality ratchet"`
- Opus converges on: `"broken windows codebase quality ratchet"`

These are stored separately and agents look up triggers under their own model's section of the recall index.

## The recall index

After scanning, run `/total-recall:index` to build `.claude/recall-index.json`. This is a word-level reverse lookup:

```json
{
  "models": {
    "sonnet": {
      "ratchet": {
        "files": ["rules/broken-windows.md"],
        "phrase": "broken windows code quality ratchet",
        "weight": 0.95
      }
    }
  }
}
```

Agents check this index using the `recall-index` rule installed by the plugin. If a relevant term appears in the index, the agent uses the stored trigger phrase instead of re-reading the source file.

## Resonance linting

An accidental secondary use: low confidence scores from convergence sampling diagnose unfocused files.

If 5 study agents disagree significantly about what a file is "about," that disagreement is meaningful. A rule that's hard for the model to summarize is probably doing too many things.

Confidence thresholds observed in testing:
- **0.8+** — file is clear and focused; trigger will be reliable
- **0.6–0.8** — file may cover more than one concept; consider splitting
- **< 0.6** — file is unfocused; the convergence failure is a signal to rewrite or decompose it

In testing across 26 files, the lowest-scoring file (confidence 0.80) turned out to cover two distinct topics in one document — exactly what low confidence predicts.

## Agents

| Agent | Model | Role |
|-------|-------|------|
| **researcher** | Sonnet | Orchestrates sampling, runs convergence analysis, stores results |
| **study** | Haiku (default) | Reads a single file and returns a short phrase. Model overridden at call time to match the target model. |
| **compare-researcher** | Sonnet | Used only by `/total-recall:compare` for cross-model research |

## Using trigger phrases

Triggers are used two ways:

**Automatic (via the recall-index rule):** The installed rule instructs agents to check `.claude/recall-index.json` before re-reading files. When a relevant term is found, the agent uses the stored phrase.

**Manual injection:** Add the trigger phrase directly to a prompt before your instructions:

```
Don't forget: broken windows code quality ratchet. Now implement the user profile endpoint.
```

## Cost

One-time cost per file per model, amortized across future sessions:

- 5 study agent calls per file per target model
- 1 researcher call per batch (up to ~20 files)
- Phase 2 escalation adds 5 calls only when convergence is weak

Triggers for general engineering concepts (error handling, testing patterns, code quality) tend to be stable across projects using the same model.
