---
name: docs
description: Create or update project documentation. Use when adding new features, changing architecture, or when docs are missing or outdated. Generates README, ARCHITECTURE, API docs, and guides.
---

# Documentation

## Overview

Create or update project documentation to match the current state of the codebase. Uses `.claude/zen.local.md` to discover where docs live in each project.

**Announce at start:** "I'm using the zen:docs skill to update documentation."

## Configuration

Documentation paths are configured in `.claude/zen.local.md` (project-level) or `~/.claude/zen.local.md` (user defaults). Project-level overrides user defaults.

**Read this file first.** If it doesn't exist, ask the user where their docs live and create it.

### Config format

```yaml
# .claude/zen.local.md
---
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
    - name: Deployment Runbooks
      dir: docs/runbooks/
      glob: "**/*.md"
---

Optional markdown body with project-specific documentation conventions,
audience notes, or style guidelines that the agent should follow.
```

### Config fields

**Well-known files** (top-level strings):

| Field | Type | Description |
|-------|------|-------------|
| `docs.readme` | string | Path to README |
| `docs.architecture` | string | Path to architecture doc |
| `docs.claude` | string | Path to CLAUDE.md (agent instructions) |
| `docs.changelog` | string | Path to changelog |

**Additional doc locations** (`docs.paths` array):

Each entry is either a **single file** or a **directory** with a glob pattern.

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Human-readable label for this doc group |
| `path` | string | Path to a single file (mutually exclusive with `dir`) |
| `dir` | string | Path to a directory to scan (mutually exclusive with `path`) |
| `glob` | string | Glob pattern to match files within `dir` (default: `"*.md"`) |

All paths are relative to project root. Omit any field that doesn't apply.

**How paths are resolved at runtime:**
- `path` entries → read directly via `Read` tool
- `dir` + `glob` entries → use `Glob` tool to discover all matching files, then read each

### Missing config

If `.claude/zen.local.md` does not exist:

1. Scan common locations: `README.md`, `docs/`, `ARCHITECTURE.md`, `CLAUDE.md`, `CHANGELOG.md`
2. Ask the user to confirm the discovered paths and add any missing ones
3. Create `.claude/zen.local.md` with the confirmed config
4. Continue with the process below

## The Process

### Step 1: Load Config and Assess

1. Read `.claude/zen.local.md` — parse YAML frontmatter for doc paths, read body for conventions
2. Check what changed — run `git diff --stat` against the base branch or recent commits
3. For each configured doc path, read the file and note:
   - Does it exist?
   - Is it stale relative to recent code changes?
   - What sections does it cover?
4. Identify gaps:
   - New features with no docs
   - Changed behavior with stale docs
   - Missing setup steps
   - Undocumented API endpoints or CLI commands

### Step 2: Determine Scope

Present findings to the user via `AskUserQuestion`:

**Question:** "Which documentation should I create or update?"

Options based on what was found — only show options relevant to the project's config:
- **README** — installation, setup, usage, commands
- **Architecture** — system design, data flow, component relationships
- **API reference** — endpoints, request/response schemas, examples
- **Guide** — how-to for a specific workflow or feature
- **TSDoc** — inline documentation on exported symbols
- **Custom docs** — any entries from `docs.custom` that need updates
- **All of the above** — comprehensive documentation pass

### Step 3: Write Documentation

**For each document, follow these principles:**

**Accuracy over completeness:**
- Read the actual code before documenting behavior
- Verify commands work before including them
- Include exact file paths and function names
- Never document aspirational behavior — only what exists now

**Structure for scanning:**
- Lead with a one-sentence summary
- Use tables for reference material (flags, config options, API fields)
- Use code blocks for commands and examples
- Use headers liberally — readers search, they don't read linearly

**Audience awareness:**
- README: new users who need to get started
- ARCHITECTURE: developers who need the mental model
- API docs: integrators who need exact contracts
- CLAUDE.md: AI agents who need conventions and constraints
- Guides: users solving a specific problem

**Keep it DRY:**
- Don't duplicate information across docs — link instead
- Single source of truth: code → schema → docs (in that order)
- If a Zod schema defines the contract, reference it rather than rewriting it

**Follow project conventions:** If the markdown body of `zen.local.md` contains style guidelines or audience notes, follow them.

### Step 4: Verify

- Confirm all code examples compile/run
- Confirm all file paths exist
- Confirm all commands produce the described output
- Check for broken links between documents

## Document Templates

### README Section

```markdown
## [Feature Name]

[One sentence: what it does and why you'd use it.]

### Quick Start

\`\`\`bash
[exact command to try it]
\`\`\`

### Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `key`  | string | `"value"` | What it controls |

### Examples

[2-3 real examples showing common use cases]
```

### Architecture Section

```markdown
## [Component Name]

**Purpose:** [One sentence]

**Key files:**
- `path/to/main.ts` — [responsibility]
- `path/to/types.ts` — [responsibility]

**Data flow:**
[Source] → [Transform] → [Destination]

**Key decisions:**
- [Decision]: [Why] (not [Alternative])
```

## When NOT to Document

- Implementation details that change frequently (the code is the doc)
- Internal helper functions (TSDoc on exported symbols only)
- Obvious behavior (don't document that `getUser` gets a user)
- Temporary workarounds (fix them instead)

## Related Skills

- **zen:check-work** — Gate 4 (Update Documentation) uses this skill's approach
- **zen:plan** — Plans should reference documentation requirements in their Verification section
