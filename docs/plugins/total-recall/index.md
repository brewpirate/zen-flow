# Total Recall

Total Recall generates short "trigger phrases" for your project's files — rules, documentation, skills — by sampling how the model itself describes them. Those phrases can be injected back into future prompts to bring early-context content back into active attention without re-reading the full file.

> [!WARNING]
> The trigger generation works reliably (see [Test Results](/plugins/total-recall/test-results)), but whether it measurably improves Claude's behavior in real sessions has not been conclusively demonstrated. Use it as a low-cost experiment rather than a guaranteed fix.

## The problem

Rules, skills, and documentation loaded early in a long context window get pushed into the background as newer content accumulates. Re-reading them mid-session costs tokens and makes sessions longer. Summarizing them loses specifics. The question this plugin tries to answer: is there a cheaper way to bring key content back into active attention?

## The approach

Language models have consistent associations with content patterns from training. If you ask multiple independent agents to describe the same file in a few words, the terms that appear across most of them are the ones most strongly encoded in the model's weights — the model's own "lookup keys" for that content.

A trigger phrase built from these convergent terms doesn't summarize the file — it's an attempt to activate associations the model already has. 5 tokens rather than re-reading 1,000.

**How convergence sampling works:** When you scan a file, Total Recall spawns 5 independent study agents in parallel. Each reads the file and returns a short phrase — 1 to 6 words — with no coordination between agents. Terms that appear across most agents become the trigger phrase.

Example — a rule file about code quality might produce these five independent descriptions:

```
"broken windows code quality"
"broken windows quality ratchet"
"code quality ratchet standard"
"broken windows quality enforcement"
"ratchet code quality rule"
```

Convergent terms: `broken`, `windows`, `quality`, `ratchet` → trigger: `"broken windows code quality ratchet"`

Notice that "ratchet" appears in the trigger even though it may appear only once in the source file — TF-IDF would discard it as rare. Convergence sampling surfaces conceptual salience, not keyword frequency.

**Model-specific triggers:** Different models converge on different terms for the same file. Sonnet and Opus have different internal representations of the same content. This is why triggers are stored per-model, and why `--models sonnet,opus` generates separate phrases for each. See [Cross-Model Results](/plugins/total-recall/test-results#cross-model-comparison) for detail.

**A secondary use — resonance linting:** Low confidence scores (below 0.7) mean agents disagreed significantly about what a file is "about." That disagreement is diagnostic: a rule that's hard for the model to summarize is probably doing too many things. In testing, the lowest-scoring file (0.80) turned out to cover two distinct topics — exactly what low confidence predicts.

## Installation

Type these commands inside a Claude Code session:

```
/plugin marketplace add brewpirate/zenflow
/plugin install total-recall@zen
/reload-plugins
```

## Setup (once, then update when files change)

**Step 1 — Generate trigger phrases for your rules and docs:**

```
/total-recall:seed --models sonnet
```

This scans your `.claude/rules/` folder, skills, and documentation. It takes a few minutes because it runs 5 agents per file. Use `--models sonnet,opus` if you also use Claude Opus in your sessions.

**Step 2 — Build the lookup index:**

```
/total-recall:index
```

Creates `.claude/recall-index.json` — a searchable map of trigger words to files. Once this exists, a background rule installed by the plugin tells Claude to check this index before re-reading any file.

**Step 3 — Verify what was generated:**

```
/total-recall:list
```

Shows all triggers and their confidence scores. A score close to 1.0 means agents agreed strongly. A lower score (below 0.7) can mean the file covers multiple topics — worth splitting if you see it.

## Commands

| Command | What it does |
|---------|-------------|
| `/total-recall:scan <path> [--models m1,m2]` | Generate a trigger phrase for one file or directory |
| `/total-recall:seed [path] [--models m1,m2]` | Batch-generate triggers for all rules, skills, and docs |
| `/total-recall:index` | Rebuild the lookup index after scanning |
| `/total-recall:list [filter]` | Show all stored triggers |
| `/total-recall:forget <path>` | Remove triggers for a file you've deleted or renamed |
| `/total-recall:compare <path>` | See how haiku, sonnet, and opus each describe the same file |

## Keeping triggers current

Triggers don't update automatically when you edit a file. After making changes:

```
/total-recall:scan .claude/rules/my-rule.md --models sonnet
/total-recall:index
```

After deleting a file:

```
/total-recall:forget .claude/rules/old-rule.md
/total-recall:index
```

## Comparing models

```
/total-recall:compare .claude/rules/error-handling.md
```

Runs all three models on the same file and shows the different phrases each produces. Useful for understanding whether to generate model-specific triggers or whether one model's trigger is good enough for all.

## What gets stored

Two files in `.claude/`:

**`triggers.json`** — the trigger phrase for each scanned file, organized by model

**`recall-index.json`** — a reverse lookup: each word in any trigger phrase maps back to the files it came from, organized by model

The plugin also installs a rule file (`rules/recall-index.md`) that instructs Claude to check this index before re-reading a file. When a matching entry is found, Claude uses the trigger phrase instead — saving context.

## What is and isn't proven

**Proven:**
- Trigger generation reliably produces short, semantically meaningful phrases
- Confidence scores correctly identify unfocused or multi-topic files
- Different models generate different triggers for the same content
- Opus produces the most stable, consistent output

**Not yet proven:**
- Whether trigger injection measurably improves Claude's behavior in real long sessions
- Whether the attention effects this is designed to address are significant in practice with current 200K+ token context windows

See [Test Results](/plugins/total-recall/test-results) for the full data.
