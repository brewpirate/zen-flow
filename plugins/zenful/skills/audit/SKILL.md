---
name: audit
description: Audit codebase sections against configurable code standards using parallel specialist agents. Use when checking code quality, enforcing standards, or running periodic health checks on the codebase.
---

# Code Audit

## Overview

Audit codebase sections against configurable standards using parallel specialist agents. Each section gets reviewed by the right type of agent against the relevant standards. Produces a structured report with file:line findings.

**Announce at start:** "I'm using the zen:audit skill to audit the codebase."

**Modes:**
- **Full** (default) — audit all configured sections
- **Changed** (`/zen:audit changed`) — only audit files modified in the current branch vs main

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

Audit sections are configured in `.claude/zen.local.md` under the `audit` key:

```yaml
---
audit:
  sections:
    - name: API Routes
      dir: packages/server/src/server/routes/
      glob: "*.ts"
      agent: Backend Architect
      standards:
        - error-handling
        - options-objects
        - async-patterns
    - name: Frontend Components
      dir: packages/frontend/src/components/
      glob: "**/*.tsx"
      agent: Frontend Developer
      standards:
        - react-patterns
        - composition-patterns
    - name: Core Orchestration
      dir: packages/core/src/core/
      glob: "**/*.ts"
      agent: Software Architect
      standards:
        - dependency-injection
        - zod-schemas
        - typescript-patterns
    - name: Type Schemas
      dir: packages/core/src/types/
      glob: "**/*.ts"
      agent: typescript-pro
      standards:
        - zod-schemas
        - typescript-patterns
---
```

### Section fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Human-readable label for the section |
| `dir` | string | Directory to audit (relative to project root) |
| `glob` | string | File pattern to match (default: `"**/*.ts"`) |
| `path` | string | Single file to audit (alternative to `dir` + `glob`) |
| `agent` | string | Agent type to dispatch (maps to Claude Code subagent types) |
| `standards` | array | List of standard names — resolved to `.claude/rules/{name}.md` files |

### Standards resolution

Each standard name maps to a rules file:
- `error-handling` → `.claude/rules/error-handling.md`
- `react-patterns` → `.claude/rules/react-patterns.md`
- `typescript-patterns` → `.claude/rules/typescript-patterns.md`

The agent receives the full text of each standards file as context.

### Missing config

If no `audit` section exists in `zen.local.md`:

1. Scan the project for common code directories
2. Read `.claude/rules/` to discover available standards
3. Ask the user which sections and standards to audit
4. Offer to save the config to `zen.local.md`

## The Process

### Step 1: Load Config

1. Read `.claude/zen.local.md` — parse the `audit` section
2. For each section, verify the directory/files exist
3. For each standard, read the rules file from `.claude/rules/`
4. Report the audit plan to the user:
   - How many sections
   - How many files per section
   - Which agents will be dispatched

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

**Agent type selection:** Use the `agent` field from the section config. Common mappings:
- `Backend Architect` — API routes, services, middleware
- `Frontend Developer` — React components, hooks, stores
- `Software Architect` — Core architecture, orchestration
- `typescript-pro` — Type system, schemas, generics
- `Security Engineer` — Auth, input validation, secrets
- `Senior Developer` — General-purpose (default if not specified)

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
- **Create plan** — invoke zen:plan to create a structured fix plan
- **Save report only** — write findings to a file for later

If fixing: dispatch subagents to fix findings, then run zen:check-work.

## Scheduled Audits

For recurring audits, suggest the user set up a cron job:

```
/loop 24h /zen:audit
```

## STUCK Criteria

- If a standards file doesn't exist, skip that standard and warn
- If a section directory doesn't exist, skip and warn
- If an auditor fails, report partial results from completed auditors
- Never block on a single section failure

## Related Skills

- **zen:check-work** — Runs after fixes are applied
- **zen:plan** — Creates a structured plan from audit findings
- **zen:refactor** — For larger structural improvements surfaced by audit
