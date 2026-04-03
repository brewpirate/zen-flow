# Total Recall

Total Recall generates short "trigger phrases" for files by running multiple study agents that each independently describe the same file in a few words. Terms that appear consistently across agents — convergent terms — become the trigger phrase for that file.

The idea is that these phrases, derived from how the model itself describes the content, can be injected later into prompts to help the model refocus on files it loaded earlier but has since deprioritized in a long context.

> [!WARNING]
> The trigger generation mechanism is validated (see [Test Results](/plugins/total-recall/test-results)), but whether injecting these phrases actually improves recall in real sessions has not been conclusively demonstrated. Synthetic behavioral tests showed no measurable effect. Real-session instrumentation is needed.

## The Problem

Rules, skills, and documentation loaded early in a long context window get pushed into the background as newer content is added. Re-reading them costs tokens. Summarizing them loses specifics. The question this plugin tries to answer: is there a cheaper way to bring key content back into active attention?

## The Approach

Language models have consistent associations with content patterns from training. If you ask multiple independent agents to describe the same file in a few words, the terms that appear across most of them are the ones most strongly encoded in the model's weights — the model's own "lookup keys" for that content.

A trigger phrase built from these convergent terms doesn't summarize the file — it's an attempt to activate associations the model already has. 5 tokens rather than re-reading 1,000.

One notable property: **different models converge on different terms for the same file**. Sonnet and Opus independently reading the same rule file will often produce different trigger phrases. This is why triggers are stored per-model. See [Cross-Model Results](/plugins/total-recall/test-results#cross-model-comparison) for detail.

## Installation

```bash
/plugin marketplace add brewpirate/zenflow
/plugin install total-recall@zen
/reload-plugins
```

## Commands

| Command | What it does |
|---------|-------------|
| `/total-recall:scan <path> [--models m1,m2]` | Study a file or directory and generate trigger phrases |
| `/total-recall:seed [path] [--models m1,m2]` | Batch-scan docs, rules, skills, and project knowledge |
| `/total-recall:list [filter]` | Show all stored triggers |
| `/total-recall:index` | Rebuild the reverse lookup index from stored triggers |
| `/total-recall:forget <path>` | Remove triggers for a file or glob pattern |
| `/total-recall:compare <path>` | Run all three models (haiku/sonnet/opus) for comparison |

## Storage

Two files in `.claude/`:

**`.claude/triggers.json`** — stores per-model trigger phrases for each scanned file

**`.claude/recall-index.json`** — a reverse lookup: word → list of files that have that word in their trigger phrases, organized by model

The plugin also installs a rule (`rules/recall-index.md`) that instructs agents to check the recall index before re-reading files. The rule tells agents to look up relevant terms under their own model's section of the index and use the trigger phrase instead of re-reading the file if one exists.

## Quick start

Scan a single rule file:

```
/total-recall:scan .claude/rules/error-handling.md --models sonnet
```

Scan all rules and docs at once:

```
/total-recall:seed --models sonnet,opus
```

Rebuild the word index after scanning:

```
/total-recall:index
```

View stored triggers:

```
/total-recall:list
/total-recall:list error-handling
```
