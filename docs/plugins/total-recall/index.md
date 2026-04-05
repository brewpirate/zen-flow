# Total Recall

Total Recall helps Claude remember your project's rules and documentation in long sessions.

> [!WARNING]
> The trigger generation works reliably (see [Test Results](/plugins/total-recall/test-results)), but whether it measurably improves Claude's behavior in real sessions has not been conclusively demonstrated. Use it as a low-cost experiment rather than a guaranteed fix.

## The problem it solves

Claude Code sessions have a **context window** — a limit to how much text the model can hold in active memory at once. In a short session this isn't an issue. In a long one — say, 45 minutes of working through a complex feature — content that was loaded early (your project rules, coding standards, architecture docs) can get "pushed back" as newer content accumulates.

The model doesn't forget the files entirely, but may pay them less attention when generating responses.

**The expensive fix:** Re-read the files again mid-session. This costs tokens (which affects speed and cost) and makes the session longer.

**What Total Recall tries instead:** Generate a very short phrase — 1 to 6 words — that represents the core concept of each file. Store these phrases in an index. When Claude needs to refer to a rule, it checks the index first and uses the stored phrase instead of re-reading the whole file.

Think of it like a sticky note on your desk vs. going back to the original reference manual.

## How trigger phrases are generated

When you run a scan on a file, Total Recall spawns **5 independent study agents** in parallel. Each agent reads the file and returns a short phrase describing it — with no coordination between agents.

The phrases that appear across most agents are the ones the model most strongly associates with that content. Those convergent terms become the trigger phrase.

Example — a rule file about code quality might produce these five independent phrases:

```
"broken windows code quality"
"broken windows quality ratchet"
"code quality ratchet standard"
"broken windows quality enforcement"
"ratchet code quality rule"
```

Convergent terms: `broken`, `windows`, `quality`, `ratchet` → trigger: `"broken windows code quality ratchet"`

One interesting side effect: **different Claude models generate different trigger phrases for the same file.** Sonnet and Opus have different internal representations of the same content, so they converge on different terms. This is why you can generate model-specific triggers with `--models sonnet` or `--models opus`.

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
