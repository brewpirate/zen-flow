---
name: audit
description: Audit codebase sections against configurable code standards using parallel specialist agents. Use when checking code quality, enforcing standards, or running periodic health checks on the codebase.
---

# Code Audit

## Overview

Audit codebase sections against configurable standards using parallel specialist agents. Each section gets reviewed by the right type of agent against the relevant standards. Produces a structured report with file:line findings.

**Announce at start:** "I'm using the zenflow:audit skill to audit the codebase."

**Modes:**
- **Full** (default) — audit all configured sections
- **Changed** (`/zenflow:audit changed`) — only audit files modified in the current branch vs main

## Changed Mode

When invoked with `changed`, only audit files that have been modified:

```bash
git diff --name-only main...HEAD
```

1. Get the list of changed files
2. For each changed file, find which audit section it belongs to (match against `dir` paths)
3. Only dispatch auditors for sections that have changed files, and only pass them the changed files
4. Files that don't match any configured section are reported as "uncovered" — suggest adding a section

This is fast enough for pre-merge checks and CI. Use full mode for periodic comprehensive audits.

## Configuration

Audit config is read from the `agents` array in `.claude/zen.local.md`:

```yaml
---
project:
  language: typescript
  framework: nextjs

agents:
  - domain: api-routes
    dir: packages/server/src/server/routes/
    glob: "*.ts"
    agent: Backend Architect
    rules:
      - error-handling
      - async-patterns
  - domain: frontend
    dir: packages/frontend/src/components/
    glob: "**/*.tsx"
    agent: Frontend Developer
    rules:
      - react-patterns
---
```

### Config fields used by zenflow:audit

| Field | Description |
|-------|-------------|
| `domain` | Section label in the audit report |
| `dir` | Directory to audit |
| `glob` | File pattern (default: `**/*`) |
| `agent` | Agent type to dispatch |
| `rules` | Rule names — resolved to `.claude/rules/{name}.md` |

### Missing config

If no `agents` array exists in `zen.local.md`, run **zenflow:init** first:

> "No zen config found. Run `/zenflow:init` to scan the codebase and generate config automatically."

## The Process

### Step 1: Load Config

1. Read `.claude/zen.local.md`
2. Parse the `agents` array from frontmatter
3. If missing, tell the user to run `/zenflow:init` and stop
4. For each agent entry, verify the dir exists and rules files exist
5. Report the audit plan: how many domains, how many files per domain, which agents will be dispatched

### Step 2: Dispatch Auditors

Launch **one subagent per section** in parallel via the `Agent` tool:

Each auditor receives:
- The section name and file list
- The full text of each referenced standards file
- Instructions to check every file against every standard

**Auditor instructions:**

```
You are auditing {section.name} against these standards:

{standards text}

Files to audit:
{file list}

For each file, check compliance with every standard. Report:

## Findings

### {filename}:{line}
- **Standard:** {which standard is violated}
- **Severity:** Critical | Important | Minor
- **Issue:** {what's wrong}
- **Fix:** {how to fix it}

### Summary
- Files audited: N
- Findings: N (Critical: N, Important: N, Minor: N)
- Clean files: N
```

**Agent type selection:**

1. **Config first** — use the `agent` field from the matching `agents` entry
2. **Discovery fallback** — if no `agent` is set, glob `.claude/agents/*.md` and `~/.claude/agents/*.md`, read each file's `name` and `description`, match by section domain and file types, fall back to `general-purpose`
3. **Inform the user** for any section using auto-selection:
   > "[N] sections are using auto-selected agents. Run `/zenflow:init` to generate agent assignments, or specify `agent` in your zen.local.md config."

### Step 3: Compile Report

After all auditors complete:

1. Merge findings from all sections into a single report
2. Sort by severity (Critical → Important → Minor)
3. Group by section
4. Present summary:

```
## Audit Report

**Sections audited:** 4
**Files audited:** 47
**Total findings:** 12 (Critical: 1, Important: 5, Minor: 6)

### Critical
1. [packages/server/src/server/routes/api.ts:45] — Missing error boundary...

### Important
...

### Minor
...

### Clean Sections
- Type Schemas (14 files) — no findings
```

### Step 4: Action Plan

After presenting the report, ask the user:

**Question:** "How should we handle the findings?"

Options:
- **Fix Critical only** — address blockers immediately
- **Fix Critical + Important** — comprehensive fix pass
- **Create plan** — invoke zenflow:plan to create a structured fix plan
- **Save report only** — write findings to a file for later

If fixing: dispatch subagents to fix findings, then run zenflow:check-work.

## Scheduled Audits

For recurring audits, suggest the user set up a cron job:

```
/loop 24h /zenflow:audit
```

## STUCK Criteria

- If a standards file doesn't exist, skip that standard and warn
- If a section directory doesn't exist, skip and warn
- If an auditor fails, report partial results from completed auditors
- Never block on a single section failure

## Related Skills

- **zenflow:check-work** — Runs after fixes are applied
- **zenflow:plan** — Creates a structured plan from audit findings
- **zenflow:refactor** — For larger structural improvements surfaced by audit
