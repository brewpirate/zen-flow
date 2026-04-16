# total-recall

> **Experimental** — This plugin explores an unproven concept: whether convergence sampling can generate trigger phrases that meaningfully reweight LLM attention in long contexts. Preliminary results are promising (see [Test Results](#test-results)) but the critical behavioral efficacy test remains unrun. Use with appropriate skepticism.

5 tokens to recall a 1000-token file. ~200:1 context compression through training-data resonance.

## The Problem

Rules, skills, and documentation loaded early in a long context window lose attention weight as newer content pushes them into the background. Re-reading them is expensive (~1000 tokens each). Summarizing them loses specifics. You need a way to bring key content back to the front of the model's attention — cheaply.

## The Insight

Language models have consistent latent associations with content patterns. If you ask 5 independent agents to describe the same file in 6 words or fewer, the words that **converge across samples** are the ones most strongly encoded in training data. These convergent tokens are the model's own internal lookup keys for that content.

A trigger phrase built from these tokens doesn't summarize the file — it **reweights the model's attention** toward content already in context. 5 tokens that act as a spotlight, not a summary.

The models name the triggers — not you. Because the model knows its own associations better than you do. You might call a rule "code quality ratchet." The model might converge on "broken windows" independently — because that's where the weights are.

Critically, **each model has its own lookup keys**. Cross-model testing (see [CROSS_MODEL_RESULTS.md](CROSS_MODEL_RESULTS.md)) showed that Sonnet converges on "broken windows code quality ratchet" while Opus converges on "broken windows codebase quality ratchet" — same concept, different internal keys. Triggers are generated per-model to match the agent that will consume them.

## How It Works

```
/total-recall:scan rules/broken-windows.md --models sonnet,opus
  │
  ▼
Research Agent (sonnet)
  │
  ├─ Per target model: spawn 5 Study Agents in parallel
  │    (5 × sonnet + 5 × opus = 10 total)
  │    each reads the file → returns 1-6 word phrase
  │
  ├─ Per model: check convergence (3+ of 5 share key terms?)
  │    ├─ YES → strong signal, skip to synthesis
  │    └─ NO  → Phase 2: escalate to next larger model
  │
  ├─ Per model: find convergent tokens, synthesize trigger
  ├─ Cross-model: identify shared terms (universal triggers)
  │
  ▼
.claude/triggers.json          →  /total-recall:index  →  .claude/recall-index.json
(file → per-model phrases)                                (word → per-model lookups)
```

### Model-Scoped Triggers

Triggers are stored per-model. When you run `/total-recall:scan --models sonnet,opus`, the researcher spawns 5 study agents **per target model** and runs convergence analysis independently for each. You specify the models your agents actually use.

### Two-Phase Sampling with Model Escalation

Phase 1 runs 5 agents at the target model. If convergence is weak, Phase 2 **escalates to a larger model** instead of repeating:
- Haiku weak → escalate to Sonnet
- Sonnet weak → escalate to Opus
- Opus weak → 5 more Opus (no further escalation)

This replaces the original "more of the same" Phase 2. Cross-model data showed the problem isn't sample size — it's model capability.

Files that consistently need escalation are often files where the model can't decide what they're about — which usually means a human would struggle too. It's an accidental complexity detector.

### Dual Activation Mechanism

Triggers operate on two systems simultaneously:

- **Parametric knowledge** — The trigger activates concepts deeply encoded in the model's weights. "Broken windows" evokes software quality discipline without any file in context.
- **In-context attention** — When full content was loaded earlier but has decayed, the trigger refocuses attention on that earlier content. It bridges parametric knowledge and in-context content.

## Resonance Linting

An unexpected output: **low confidence scores diagnose unfocused rules**.

If 5 agents can't converge on a name for a rule, that rule is probably trying to do too many things. The convergence failure IS the diagnostic. If the model can't compress it into a resonant phrase, it probably can't attend to it well either.

- **High confidence (0.8+):** Rule is clear, focused, resonant. The trigger will work.
- **Medium confidence (0.6-0.8):** Rule might be doing two things. Consider splitting.
- **Low confidence (<0.6):** Rule is unfocused. Rewrite or decompose it.

In testing, the lowest-confidence file (04-claude-integration, 0.80) covered two distinct topics (SDK mode AND CLI subprocess mode) — correctly flagged by weak convergence.

## Commands

| Command | Description |
|---------|-------------|
| `/total-recall:scan <path> [--models m1,m2]` | Study a file or directory and generate model-scoped trigger phrases |
| `/total-recall:seed [path] [--models m1,m2]` | Bootstrap triggers from docs, prompts, skills, and project knowledge |
| `/total-recall:list [filter]` | Show all stored triggers, optionally filtered |
| `/total-recall:index` | Rebuild the master word-to-files reverse lookup index |
| `/total-recall:write` | Write trigger phrases from triggers.json into file frontmatter |
| `/total-recall:forget <path>` | Remove triggers for a file or pattern |
| `/total-recall:compare <path>` | Cross-model comparison — run study agents on haiku, sonnet, and opus to compare phrase generation |

## Architecture

### Agents

| Agent | Model | Role |
|-------|-------|------|
| **researcher** | Sonnet | Orchestrates model-aware two-phase sampling, per-model convergence, cross-model analysis |
| **study** | Haiku (default) | Reads a single file and returns a 1-6 word phrase — model overridden at call time |
| **compare-researcher** | Sonnet | Runs haiku/sonnet/opus comparison for research purposes |

### Skills

| Skill | Description |
|-------|-------------|
| **scan** | Resolve file/directory input, invoke researcher with `--models`, store model-scoped results |
| **seed** | Auto-discover documentation and prompt files, batch-scan with model targeting |
| **index** | Build per-model reverse lookup (word → files + phrase) from triggers.json |
| **list** | Display stored triggers with optional filtering |
| **write** | Write trigger phrases from triggers.json into file frontmatter |
| **forget** | Remove triggers for a file or glob pattern |
| **compare** | Cross-model comparison research tool |

### Rules

| Rule | Description |
|------|-------------|
| **recall-index** | Instructs agents to check `.claude/recall-index.json` before re-reading files, using their own model's triggers |

### Storage

**Triggers** — `.claude/triggers.json` (v2, model-scoped)

```json
{
  "version": 2,
  "triggers": {
    "rules/broken-windows.md": {
      "models": {
        "sonnet": {
          "phrase": "broken windows code quality ratchet",
          "samples": ["broken windows enforcement", "code quality ratchet rule", "..."],
          "convergence": ["broken", "windows", "ratchet"],
          "confidence": 0.98,
          "phases": 1
        },
        "opus": {
          "phrase": "broken windows codebase quality ratchet",
          "samples": ["..."],
          "convergence": ["broken", "windows", "codebase", "quality", "ratchet"],
          "confidence": 0.99,
          "phases": 1
        }
      },
      "crossModelTerms": ["broken", "windows", "quality", "ratchet"],
      "scannedAt": "2026-04-01T10:00:00.000Z"
    }
  }
}
```

**Master Index** — `.claude/recall-index.json` (v2, model-aware)

Per-model reverse lookup — agents find triggers matched to their own model:

```json
{
  "version": 2,
  "builtAt": "2026-04-01T10:05:00.000Z",
  "triggerCount": 15,
  "models": {
    "sonnet": {
      "ratchet": {
        "files": ["rules/broken-windows.md"],
        "phrase": "broken windows code quality ratchet",
        "weight": 0.95
      }
    },
    "opus": {
      "ratchet": {
        "files": ["rules/broken-windows.md"],
        "phrase": "broken windows codebase quality ratchet",
        "weight": 0.98
      }
    }
  },
  "crossModel": {
    "ratchet": { "files": ["rules/broken-windows.md"], "weight": 0.95 }
  }
}
```

## Test Results

Tested against 26 files from a real project (barf-ts) — 14 engineering rules + 12 documentation files.

| Metric | Result |
|--------|--------|
| Files tested | 26 |
| Average confidence | 0.93 |
| Phase 1 convergence rate | 100% |
| Highest confidence | 0.99 (testing.md) |
| Lowest confidence | 0.80 (04-claude-integration.md) |
| Total Haiku calls | 130 |

### Selected Results

| File | Trigger | Confidence |
|------|---------|------------|
| testing | test behavior not implementation | 0.99 |
| error-handling | throw typed errors at boundaries | 0.98 |
| bun-native-apis | prefer bun native over node | 0.98 |
| options-objects | single options object for parameters | 0.98 |
| README.md | autonomous issue driven development | 0.98 |
| dependency-injection | injectable dependencies over globals | 0.95 |
| zod-schemas | zod schemas source of truth | 0.95 |
| broken-windows | quality ratchet broken windows | 0.90 |
| 04-claude-integration | dual path into claude | 0.80 |

### Key Findings

1. **Semantic salience, not statistical** — "ratchet" appears once in its source file (a hapax legomenon TF-IDF would discard), yet 2/5 agents independently surfaced it as the defining metaphor. "globals" encodes what the file argues *against*, not what it contains. "assembly line" appeared in 3/5 samples for agent-roles despite never appearing in the source file.

2. **Fixed points exist** — testing.md hit 0.99 confidence with near-identical phrases from all 5 agents. This phrase is a stable attractor in the model's output distribution — the pipeline reverse-engineered a lookup key that was already there.

3. **Natural composability** — Triggers compose into imperative sentences: *"throw typed errors at boundaries, test behavior not implementation, quality ratchet broken windows"* — 17 tokens encoding 14 files of engineering discipline.

4. **Low confidence = diagnostic** — The lowest-scoring file (0.80) covered two distinct topics, correctly flagged by weak convergence. Phase 2 frequency could serve as a code complexity metric.

Full results and raw sample data: [TEST_CASE.md](TEST_CASE.md) | [FEASIBILITY.md](FEASIBILITY.md)

## Using Triggers

### Automatic (via rule)

The plugin includes a `rules/recall-index.md` rule that instructs agents to check `.claude/recall-index.json` before re-reading files. Agents look up terms under their own model's section and get the trigger phrase optimized for their associative network.

### Manual injection

Inject trigger phrases into prompts before task instructions:

```
Don't forget broken windows code quality ratchet. Now implement the user profile endpoint.
```

## Cross-Model Comparison Results

Cross-model testing (14 files × 3 models = 210 agent calls) revealed that **triggers are model-specific, not universal**. Full data: [CROSS_MODEL_RESULTS.md](CROSS_MODEL_RESULTS.md)

| Metric | Haiku | Sonnet | Opus |
|--------|-------|--------|------|
| Average confidence | 0.94 | 0.96 | 0.98 |
| Perfect fixed points (5/5 identical) | 0% | 21% | 64% |

Key findings:
- **Opus produces dramatically more stable triggers** — 9/14 files had 5/5 identical phrases
- **Sonnet uniquely abstracts** to imperative concepts ("prefer bun over node fs") while Opus goes maximally specific ("zod4 strict tsdoc pino biome gates")
- **Cross-model shared terms** (e.g., "options, object, positional, params") are the strongest, most portable triggers
- **This is why triggers are now model-scoped** — each model has its own associative network and optimal lookup keys

The `/total-recall:compare` command runs all three models for research:

```
/total-recall:compare rules/broken-windows.md
```

## Behavioral Efficacy: What We Tested

We ran three iterations of synthetic behavioral tests attempting to measure whether triggers help recall content that has decayed in long contexts:

| Test | Context Load | Method | Result |
|------|-------------|--------|--------|
| v1 — Passive flood | ~60K tokens | Read 10 source files | All conditions identical |
| v2 — Active engagement | ~80K tokens | 5 deep analysis tasks | All conditions identical |
| v3 — Heavy engagement | ~136K tokens | 12 deep analysis tasks across 30+ files | All conditions identical |

**Finding: Synthetic tests cannot reproduce attention decay.** Sonnet retained perfect recall of a ~1K token rule file at every tested depth, even after performing 12 substantive code review, debugging, and architecture analysis tasks. All conditions (trigger, generic hint, no intervention) scored identically.

**Why:** Attention decay is an organic phenomenon that builds over real working sessions — temporal distance, context switching, conversational noise, system-level context compression. A synthetic single-turn test cannot reproduce this. The decay happens over 45 minutes and dozens of exchanges, not over token count alone.

**Implication:** Behavioral efficacy must be measured through real-session instrumentation, not synthetic tests. The trigger mechanism itself is validated (convergence sampling produces model-specific lookup keys), but whether in-session attention decay is a real problem for current large-context models remains an open question.

## What's Proven vs. Unproven

### Proven

- Pipeline reliably extracts high-quality semantic handles for engineering concept content
- Convergent sampling finds conceptual salience (metaphors, contrasts) that TF-IDF cannot
- Cost model is favorable: one-time investment, permanent portable results
- Phase 1 is sufficient for well-structured concept files (100% in testing)
- Low convergence scores correctly identify unfocused or multi-topic content
- **Triggers are model-specific** — different models converge on different lookup keys (cross-model test, 210 agents)
- **Opus produces the most stable triggers** — 64% perfect fixed point rate vs 0% for Haiku

### Unproven

- **Behavioral efficacy in real sessions** — synthetic tests showed no decay up to 136K tokens; real-session instrumentation is needed to test whether triggers help over long, multi-turn working sessions
- **Novel code boundary** — does the mechanism hold for project-specific code with thin parametric backing?
- **Whether attention decay is a real problem** for current large-context models (200K+ token windows)

## Cost

One-time per file per model, amortized across all future sessions:

- 5 study agent calls per file **per target model** (e.g., `--models sonnet,opus` = 10 calls/file)
- 1 Sonnet researcher call per batch (up to 20 files)
- Model escalation (Phase 2) adds 5 calls only when needed
- Triggers for universal engineering concepts are portable across projects (within the same model)

## Why It Works (Theory)

Traditional context management asks "how do I fit more into the window?" Total-recall asks "what's the minimum I need to inject to reweight attention toward content already in the window?"

The answer: the model's own convergent associations — the words it gravitates toward when independently describing the same content. These tokens are already the model's internal index keys. Total-recall just makes them explicit, persistent, and searchable.

It's not summarization. It's not retrieval. It's attention reshuffling — and it costs 5 tokens.
