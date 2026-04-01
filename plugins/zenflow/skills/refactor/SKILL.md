---
name: refactor
description: Structured refactoring pipeline — analyze target code, propose changes with before/after examples, plan, execute with regression coverage. Use when improving existing code without changing behavior.
---

# Refactor

## Overview

Structured approach to improving existing code without changing behavior. Analyzes the target, proposes the refactor with concrete before/after examples, creates a plan with regression test coverage, then executes.

**Announce at start:** "I'm using the zenflow:refactor skill to improve this code."

<HARD-GATE>
Refactoring MUST NOT change **external** behavior — observable outputs, public API contracts consumed by code outside this repository.

**Internal API changes are allowed** if all callers are updated in the same scope. Examples:
- Converting 3+ positional params to an options object (required by project rules)
- Renaming an internal function and updating all call sites
- Splitting a module and updating internal imports

If external consumers exist (npm package, REST API, CLI flags), signature changes are NOT a refactor — use zenflow:idea instead.
</HARD-GATE>

## The Process

### Step 1: Identify Target

Determine what to refactor. The user may specify:
- A file or directory
- A function or module
- A pattern ("all uses of X")
- An audit finding from zenflow:audit

If vague ("refactor the auth module"), explore the code first:
1. Read the target files
2. Identify specific issues (duplication, complexity, coupling, naming)
3. Present findings and ask which issues to address

### Step 2: Analyze

For the identified target:

1. **Read all affected code** — the target files plus their callers and callees
2. **Map dependencies** — who imports this? Who does this import?
3. **Identify test coverage** — which tests exercise this code? Are there gaps?
4. **Catalog issues** — specific problems to fix:
   - Duplication (same logic in N places)
   - Complexity (deeply nested, long functions)
   - Coupling (too many dependencies, god objects)
   - Naming (unclear, inconsistent, abbreviated)
   - Pattern violations (doesn't follow codebase conventions)

### Step 3: Propose

Present the refactor proposal to the user with:

**Before/After examples** — concrete code showing the transformation:

```
### Change 1: Extract shared validation logic

**Before** (duplicated in 3 files):
{code snippet from file A}
{code snippet from file B}

**After** (shared helper):
{proposed helper function}
{updated call site}

**Files affected:** fileA.ts, fileB.ts, fileC.ts, new: shared/validation.ts
```

**Impact assessment:**
- Files modified: N
- Files created: N
- Test files affected: N
- Breaking changes: none (or list them — if any, this isn't a refactor)

**Risk areas:**
- Any subtle behavior changes to watch for
- Edge cases that might be affected
- Areas without test coverage

Ask: **"Does this refactor plan look right? Any changes?"**

### Step 4: Ensure Regression Coverage

Before making any changes:

1. **Run existing tests** — run the project's full test suite to establish baseline (all must pass)
2. **Identify coverage gaps** — if the target code lacks tests, write them FIRST
3. **Write characterization tests** — tests that capture current behavior exactly:
   - Call the function with representative inputs
   - Assert on current outputs (even if they seem wrong)
   - These tests become the safety net for the refactor

This is non-negotiable. Refactoring without tests is just rearranging.

### Step 5: Execute

Two options based on scope:

**Small refactor (1-3 files):** Execute directly in this session.
1. Make changes incrementally — one logical change at a time
2. Run tests after each change
3. If any test fails, stop and investigate (don't fix the test — the refactor may be wrong)

**Large refactor (4+ files):** Invoke zenflow:plan to create a detailed plan, then zenflow:dispatch to execute.
- Each task should be a self-contained refactoring step
- Tests must pass after every task
- Code review after each task catches drift

### Step 6: Validate

After refactoring is complete:

1. Run full test suite (must match or exceed baseline count)
2. Run type checker if the project has one
3. Compare behavior — if the refactor touched API boundaries, verify responses match
4. Invoke **zenflow:check-work** for full quality gates

## Refactoring Patterns

### Extract Function
**When:** Same logic in 2+ places, or a function does too many things.
**How:** Pull the shared/excess logic into a named function. Update all call sites.

### Inline Function
**When:** A function just wraps another call with no added value.
**How:** Replace call sites with the direct call. Delete the wrapper.

### Rename
**When:** Name doesn't match what the thing does.
**How:** Rename with LSP (find all references), update tests, update docs.

### Split Module
**When:** A file has grown beyond one clear responsibility.
**How:** Identify responsibility boundaries, create new files, move code, update imports.

### Replace Conditional with Polymorphism
**When:** Complex switch/if-else blocks that grow with each new case.
**How:** Extract to discriminated union or strategy pattern.

### Consolidate Options Object
**When:** Function has 3+ positional parameters (per project conventions).
**How:** Replace with single options object, update all call sites.

## Red Flags

**Stop and reassess if:**
- Tests start failing and you're not sure why
- The "refactor" requires changing test assertions (behavior changed)
- The change is growing beyond the original scope
- You're touching files not in the original impact assessment

**Never:**
- Delete tests to make a refactor pass
- Change function signatures that external code depends on
- Refactor and add features in the same change
- Skip the baseline test run

## Related Skills

- **zenflow:audit** — Surfaces code quality issues that may warrant refactoring
- **zenflow:plan** — Creates detailed plan for large refactors
- **zenflow:dispatch** — Executes multi-task refactor plans with subagents
- **zenflow:check-work** — Required after refactoring is complete
- **zenflow:review** — Verify the refactor maintains quality
