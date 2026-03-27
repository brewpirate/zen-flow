---
name: plan
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans as if handing them to a junior developer on their first day with this codebase. Document everything: which files to touch, complete code for every step, exact commands to run, and how to verify each change. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent checkpoints.

Assume they can write code but know nothing about barf's architecture, conventions, or testing patterns. Leave nothing implicit.

**Announce at start:** "I'm using the zen:plan skill to create the implementation plan."

**Save plans to:** `resources/plans/NNN-descriptive-name.md`
- Run `ls -r resources/plans/` to find the highest existing `NNN`, increment by 1, zero-pad to 3 digits
- Example: if `225-three-layer-prompts.md` is highest, next is `226-your-feature-name.md`

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during zen:idea. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Checkpoint — present changes for review" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
---
status: planned
---

# [Feature Name] Implementation Plan

> **For agentic workers:** Use zen:dispatch (recommended) or zen:exec-plan to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `packages/core/src/core/new-file.ts`
- Modify: `packages/core/src/core/existing-file.ts:123-145`
- Test: `tests/unit/new-file.test.ts`

- [ ] **Step 1: Write the failing test**

```typescript
// Use the project's test framework (Jest, Vitest, bun:test, pytest, etc.)
import { describe, it, expect } from '<test-framework>'
import { specificFunction } from '<project-import-path>'

describe('specificFunction', () => {
  it('should return expected result for valid input', () => {
    const result = specificFunction({ id: '001', config })
    expect(result).toBe(expected)
  })
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `<project-test-command> <test-file-path>`
Expected: FAIL with "module not found"

- [ ] **Step 3: Write minimal implementation**

```typescript
export function specificFunction(opts: {
  id: string
  config: Config
}): ExpectedType {
  const { id, config } = opts
  return expected
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `<project-test-command> <test-file-path>`
Expected: PASS

- [ ] **Step 5: Checkpoint — verify all tests pass before moving to next task**
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent checkpoints

## Verification Section

Every plan MUST end with a `## Verification` section listing how to confirm the work is correct. This feeds `zen:check-work` and gives the executing agent clear success criteria.

Include:
- Unit tests to write and what they cover
- Integration tests if applicable
- Commands to run (the project's test, lint, and type-check commands)
- Regression checks (existing tests must still pass)

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Subagent Recommendation

After the self-review passes, add a **Subagent Recommendation** section to the end of the plan. This tells `zen:exec-plan` how to staff the work.

Include:
- **Number of subagents** — how many parallel workers are needed
- **Agent types** — which specializations (e.g., Senior Developer, Frontend Developer, Backend Architect)
- **Skills per agent** — which skills each agent should use (e.g., testing-anti-patterns, react-best-practices, zod-schema)
- **Parallelization strategy** — which tasks are independent (can run in parallel) vs sequential (must wait for prior tasks)
- **Dependencies** — if Task 3 depends on Task 1's output, say so

Example:

```markdown
## Subagent Recommendation

- **3 subagents** for parallel execution
- Agent 1 (Senior Developer): Tasks 1-2 (schema + validation) — skills: zod-schema
- Agent 2 (Senior Developer): Tasks 3-4 (API routes + error handling) — sequential
- Agent 3 (Senior Developer): Task 5 (context bundle changes)
- Tasks 1-2 and 3-4 and 5 are independent — run all 3 agents in parallel
- Task 6 (tests) depends on all others — run after agents complete
- **Required skill for all agents:** testing-anti-patterns
```

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `resources/plans/NNN-name.md`. Two execution options:**

**1. Subagent-Driven (recommended)** — I dispatch subagents per the recommendation above, parallel execution, fast iteration

**2. Inline Execution** — Execute tasks in this session using zen:exec-plan, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- Use zen:dispatch skill
- Follow the Subagent Recommendation from the plan

**If Inline Execution chosen:**
- Use zen:exec-plan skill
- Sequential execution with verification between tasks
