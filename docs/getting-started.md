# Getting Started

> [!WARNING]
> All plugins are under active development. APIs and behavior may change without notice.

## What is this?

This is a collection of **Claude Code plugins** — add-ons that give Claude new commands, automatic behaviors, and structured workflows inside your terminal sessions.

If you haven't used Claude Code before: it's a terminal tool (`claude`) that lets you pair-program with an AI model directly in your project. Plugins extend what it can do without you having to explain your workflow every session.

There are three plugins here:

| Plugin | What it does in one sentence |
|--------|------------------------------|
| **zenflow** | Guides you through building features step by step — idea, plan, code, test, review |
| **field-notes** | Keeps a log of what Claude did each session, so nothing is forgotten |
| **total-recall** | Helps Claude remember your project's rules and docs in long sessions |

You don't need all three. Start with just `zenflow` if you want to try the workflow.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and logged in
- A project folder where you already run `claude` (it should have a `.claude/` subfolder once initialized)

---

## Installation

All commands below are typed into a Claude Code session (not your regular terminal). Open Claude Code in your project first, then run:

**Step 1 — Register the plugin marketplace:**

```
/plugin marketplace add brewpirate/zenflow
```

This tells Claude Code where to find the plugins. You only do this once.

**Step 2 — Install the plugins you want:**

```
/plugin install zenflow@zen
/plugin install field-notes@zen
/plugin install total-recall@zen
```

You can install any combination. `field-notes` works well alongside `zenflow` because it automatically logs your sessions.

**Step 3 — Reload so the plugins take effect:**

```
/reload-plugins
```

> **What does `/reload-plugins` do?** It tells Claude Code to re-read all installed plugins. New commands won't appear until you run this.

### Not sure what to install?

| I want to… | Install |
|------------|---------|
| Try a structured way to build features | `zenflow` |
| Just keep a log of Claude sessions | `field-notes` |
| Help Claude remember docs in long sessions | `total-recall` |
| Get the full experience | all three |

---

## Using ZenFlow

ZenFlow gives Claude a structured approach to development. Instead of a freeform "build this thing" conversation, work moves through clearly defined stages — which means less going in circles and more predictable outcomes.

### First-time setup (once per project)

```
/zenflow:init
```

This reads your project and creates a config file at `.claude/zen.local.md`. The config tells Claude things like:

- What language and framework you're using
- Where your documentation lives
- Which parts of the codebase different agents should focus on

Open the generated file and read through it. Adjust anything that looks wrong before moving on.

Then open the command menu to see everything available:

```
/zen
```

### How the pipeline works

Think of ZenFlow as a checklist that makes sure you don't skip important steps. For any new feature or fix, work moves through five stages:

```
1. idea  →  2. plan  →  3. execute  →  4. check-work  →  5. review
```

**Stage 1 — Explore the idea**

```
/zenflow:idea
```

Describe what you want to build. Claude will ask questions, research the codebase, and work with you to arrive at a clear design *before writing any code*. This saves time — catching a bad approach at the idea stage is much cheaper than catching it after the code is written.

**Stage 2 — Write the plan**

```
/zenflow:plan
```

Turns the approved design into a detailed, step-by-step implementation plan. The plan is saved to `resources/plans/` in your project so it persists across sessions.

**Stage 3 — Execute the plan**

```
/zenflow:dispatch    # use when tasks can run at the same time (faster)
/zenflow:exec-plan   # use when each step depends on the previous one
```

- `dispatch` splits the plan into parallel tasks and runs them simultaneously using multiple Claude agents. Good for independent tasks like "add auth endpoints" + "update tests" + "update docs".
- `exec-plan` runs tasks one at a time, pausing for your review between each. Good for tightly coupled changes where order matters.

**Stage 4 — Validate the work**

```
/zenflow:check-work
```

Runs five checks in order: lint, format, tests, documentation review, and a journal entry. If any check fails, Claude attempts to fix it automatically.

> **Why can't I skip this?** A built-in hook (a background enforcement rule) prevents Claude from ending the session after execution without running `check-work` first. This is intentional — it catches issues before you move on.

**Stage 5 — Review the changes**

```
/zenflow:review
```

A separate Claude agent reads the git diff and gives you a structured review: a list of findings labeled Critical, Important, or Minor, and a merge verdict.

---

### Standalone commands

These can be used at any time, outside the pipeline:

| Command | What it does |
|---------|-------------|
| `/zenflow:collab` | Opens a long collaborative session with Claude Opus. Useful for exploring unfamiliar code or thinking through a tricky design. Claude works as a thinking partner, not just a task executor. |
| `/zenflow:bug-fix` | Diagnoses a bug using four agents in parallel — two for root cause analysis, one to write the fix, one to review it. |
| `/zenflow:audit` | Reviews your codebase against the coding rules defined in your project. |
| `/zenflow:refactor` | Plans and executes a refactor, checking for test coverage before making any changes. |
| `/zenflow:status` | Shows what plans are in progress, recent git activity, and recent journal entries. |

---

## Using Field Notes

Field Notes keeps a log of what happened in each Claude Code session. When a session ends, the context disappears — Field Notes captures a structured record so you (and Claude) can pick up where things left off.

### How logging works

If you have both `zenflow` and `field-notes` installed, logging is **automatic** — `zenflow:check-work` writes a journal entry as its final step. You don't need to do anything.

To write an entry manually (or if you're using field-notes without zenflow):

```
/field-notes:write
```

Claude will ask what was worked on, what the outcome was, any blockers you hit, and what you learned. The entry is saved to `.claude/journal.jsonl` in your project.

### Reading past sessions

```
/field-notes:read                         # The 5 most recent entries
/field-notes:read 10                      # The 10 most recent entries
/field-notes:read today                   # Only today's work
/field-notes:read blocked                 # Sessions that got stuck
/field-notes:read bug-fix                 # Bug-fix sessions only
/field-notes:read branch feature/login    # Work on a specific branch
/field-notes:read search "rate limiter"   # Search by keyword
```

### Spotting patterns

```
/field-notes:summary           # Last 7 days — what files keep coming up, recurring blockers
/field-notes:summary week
/field-notes:summary month
/field-notes:summary all
```

The summary shows health metrics like your bug-fix ratio and how often sessions get blocked. High numbers here can signal a process problem worth fixing.

### End-of-session retrospective

```
/field-notes:reflect
```

Reads your recent journal entries, reconstructs a timeline of the session, and identifies what went well, what was harder than expected, and what could be done differently. Ends with suggested follow-up actions (docs to update, issues to file) and asks if you want to act on them immediately.

### Viewing the journal in a browser

```
/field-notes:view
```

Opens an HTML viewer where you can search, filter, and browse entries visually.

---

## Using Total Recall

Claude Code sessions have a **context window** — a limit on how much text the model can hold in memory at once. In a long session, files and rules loaded early in the conversation get "pushed back" as new content is added. The model doesn't forget them, but may give them less attention.

Total Recall addresses this by generating short **trigger phrases** for your project files. A trigger phrase is a 1–6 word description that represents the key concept of a file. When Claude needs to refer to a rule or document, it can use the trigger phrase (5 tokens) rather than re-reading the whole file (hundreds or thousands of tokens).

> **Important:** Trigger generation is validated to produce accurate, meaningful phrases. Whether they actually improve recall in long sessions is still being tested — see [Test Results](/plugins/total-recall/test-results) for the full picture.

### Setup (do this once, then repeat when files change)

**Step 1 — Generate trigger phrases for all your rules and docs:**

```
/total-recall:seed --models sonnet
```

This scans your `.claude/rules/` folder, skills, and any documentation. It runs 5 independent study agents per file — each reads the file and describes it in a few words. The words that appear most consistently across agents become the trigger phrase.

Use `--models sonnet,opus` if you use Claude Opus in your sessions too, since each model develops slightly different internal descriptions.

**Step 2 — Build the lookup index:**

```
/total-recall:index
```

Creates a searchable index at `.claude/recall-index.json`. Once this exists, a background rule instructs Claude to check the index before re-reading any file — so recall becomes automatic.

**Step 3 — Check what was generated:**

```
/total-recall:list
/total-recall:list error-handling    # Filter to entries matching a keyword
```

### Keeping triggers up to date

When you edit a file, re-scan it and rebuild the index:

```
/total-recall:scan .claude/rules/my-rule.md --models sonnet
/total-recall:index
```

When you delete a file:

```
/total-recall:forget .claude/rules/old-rule.md
/total-recall:index
```

### Comparing how models describe a file

```
/total-recall:compare .claude/rules/error-handling.md
```

Runs all three models (haiku, sonnet, opus) on the same file. Useful if you want to see how differently they describe the same content, and decide which models to generate triggers for.
