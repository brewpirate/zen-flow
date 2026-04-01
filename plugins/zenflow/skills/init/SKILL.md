---
name: init
description: Study the codebase and available agents to generate a zen.local.md config. Run once to onboard a new project, or re-run to update config after adding agents.
---

# zenflow:init

## Overview

Scan the codebase and available agents to generate a `zen.local.md` config tailored to this project. Auto-triggered when `zenflow:audit` or `zenflow:bug-fix` finds no config; also invocable directly via `/zenflow:init`.

**Announce at start:** "I'm using the zenflow:init skill to configure zen for this project."

## Config Structure

`zenflow:init` generates `.claude/zen.local.md` with this structure:

```yaml
---
project:
  language: typescript       # primary language detected
  framework: nextjs          # framework detected (if any)

docs:
  readme: README.md
  architecture: docs/ARCHITECTURE.md
  claude: CLAUDE.md
  changelog: CHANGELOG.md
  paths:
    - name: Guides
      dir: docs/guides/
      glob: "*.md"
    - name: API Reference
      path: docs/api-reference.md

plans:
  dir: resources/plans          # where plan files are stored (relative to project root)

agents:
  - domain: api-routes
    dir: packages/server/src/routes/
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

**Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `domain` | yes | Logical name for this codebase section |
| `dir` | yes | Directory path relative to project root |
| `glob` | no | File pattern (default: `**/*`) |
| `agent` | no | Agent name from discovered agents |
| `rules` | no | Rule names mapping to `.claude/rules/{name}.md` |

## The Process

### Phase 1: Codebase Scan

Spawn an **Explore subagent** to perform a deep codebase scan:

```
Agent tool:
  subagent_type: Explore
  prompt: |
    Perform a deep scan of this codebase and report back:

    1. **Project metadata** — detect primary language and framework from:
       - package.json (dependencies, scripts)
       - pyproject.toml / setup.py
       - Cargo.toml
       - go.mod
       - Any other manifest files at the root

    2. **Directory structure** — walk the full tree (not just top-level), identify logical sections:
       - Group by responsibility (routes, components, services, schemas, tests, config, etc.)
       - Note dir paths and primary file extensions per section
       - Sample 2-3 key files per section to understand patterns

    3. **Existing rules** — glob `.claude/rules/*.md`, list available rule names

    4. **Existing config** — read `.claude/zen.local.md` if it exists, report current structure

    5. **Documentation** — detect common doc files and directories:
       - README.md at project root
       - docs/ directory — list subdirs and glob patterns present
       - ARCHITECTURE.md, CHANGELOG.md, CLAUDE.md
       - Any other top-level .md files likely to be docs

    Report: language, framework, list of sections (name + dir + glob + suggested rules), existing rules available, existing config (if any), detected doc files/dirs.
```

### Phase 2: Agent Discovery

After the Explore subagent returns:

1. Glob `.claude/agents/*.md` and `~/.claude/agents/*.md`
2. Read `name` and `description` from each file's frontmatter
3. For each codebase section from Phase 1, score available agents:
   - Read the agent's description
   - Match against the section's dir path, file types, and suggested rules
   - Pick the highest-scoring agent
   - Note unmatched sections

**Coverage check:** If more than half the sections have no good agent match, or no agents were found at all:

> "⚠️ Agent coverage is weak — [N] of [M] sections have no good match.
> Browse [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) to find specialist agents, install them to `.claude/agents/`, then re-run `/zenflow:init`."

Continue regardless — the user can add agents and re-run.

### Phase 3: Build Recommendation

Construct the recommended config from Phase 1 + Phase 2 results:

```yaml
project:
  language: <detected>
  framework: <detected or omit if none>

docs:
  readme: <path if detected>
  architecture: <path if detected>
  claude: <path if detected>
  changelog: <path if detected>
  paths:               # only if additional doc dirs were found
    - name: <name>
      dir: <dir>       # for directories
      glob: "*.md"
    - name: <name>
      path: <path>     # for single files

agents:
  - domain: <section name>
    dir: <dir>
    glob: <glob>
    agent: <matched agent name or omit if no match>
    rules:
      - <rule name>   # only rules that exist in .claude/rules/
```

Only include `docs` fields that were actually detected. Omit `paths` if no additional doc directories were found.

### Phase 4: Present and Approve

Present the recommendation to the user:

```
## Recommended zen.local.md config

**Project:** TypeScript / Next.js

**Docs detected:**

| Key | Path |
|-----|------|
| readme | README.md |
| architecture | docs/ARCHITECTURE.md |
| changelog | CHANGELOG.md |

**Additional paths:** 2 detected (Guides, API Reference)

**Agent domains:** 4 sections found

| Domain | Dir | Agent | Rules |
|--------|-----|-------|-------|
| api-routes | packages/server/src/routes/ | Backend Architect | error-handling, async-patterns |
| frontend | packages/frontend/src/components/ | Frontend Developer | react-patterns |
| schemas | packages/core/src/types/ | (no match) | typescript-patterns |
| tests | tests/ | (no match) | — |

⚠️ 2 sections have no agent match. Consider adding specialists from awesome-claude-code-subagents.

**Accept this config?** (yes / edit / skip sections)
```

Wait for user response before proceeding. If the user wants to edit, accept their changes conversationally before writing.

### Phase 5: Write Config

After approval:

1. Check if `.claude/zen.local.md` already exists
2. **If it exists:** merge — preserve any existing keys not managed by `zenflow:init`, update `project`, `docs`, and `agents` sections
3. **If it doesn't exist:** write fresh

Write the approved YAML as frontmatter in `.claude/zen.local.md`. Preserve any existing markdown body below the frontmatter.

Confirm:
> "Config written to `.claude/zen.local.md`. Run `/zenflow:audit` to audit the codebase or `/zenflow:bug-fix` to diagnose a bug — both will now use this config."

## Re-run Behavior

When re-run on a project that already has config:
- Show a diff of what would change
- Ask: "Update config with these changes?"
- Merge on approval, skip unchanged sections

## STUCK Criteria

- If the codebase has no detectable structure, report what was found and ask the user to describe their sections manually
- If no agent files exist anywhere, skip agent matching and note it clearly — config is still useful without agents

## Related Skills

- **zenflow:audit** — reads `agents` from config for section-to-agent mapping
- **zenflow:bug-fix** — reads `agents` from config for specialist selection
- **zenflow:docs** — reads `docs` from config for documentation paths
