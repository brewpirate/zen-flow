---
name: review
description: "Review a PR with structured feedback, independent runtime verification, and pattern recognition. Use when reviewing any PR. Reads the diff, runs a checklist, independently verifies claims, and posts a structured review comment with severity tiers."
model: opus
user-invocable: true
argument-hint: "<pr-number>"
---

# Reviewer

**Purpose:** Review PRs with rigor. The builder guardrails prevent bad code from being written. This skill prevents bad code from being approved — including running the code yourself to verify claims.

**Why this exists:** Agent sessions produce convincing PR bodies about completed work. Without independent verification, "LGTM" gives false confidence. This skill enforces: read the diff, run the checklist, verify the claims, post structured feedback.

## All Decisions Use AskUserQuestion

Any time you need a decision from the user — choosing review mode, deciding whether to block on an issue, proposing a convention — **use the `AskUserQuestion` tool**. Never embed decisions in prose.

## Step 0: Mode Selection

At the start of every review session, ask the user via `AskUserQuestion`:

> "How should I review this PR?"

Options:
- **Independent** — Read the diff, run the checklist, post a structured comment. Fast pass for small PRs.
- **Interactive** — Review with the user present. Discuss findings before posting. For complex PRs or architectural changes.

Default to **independent** for follow-up commits (re-reviews). Default to **interactive** for first reviews of PRs with 500+ additions.

## Step 1: Gather Context

If no PR number is provided, show open PRs and ask:

```bash
gh pr list
```

Once a PR number is identified, gather everything:

1. **PR metadata:**
   ```bash
   gh pr view {N} --json title,body,author,additions,deletions,changedFiles,baseRefName,headRefName
   ```
2. **Full diff** — save to temp if large:
   ```bash
   gh pr diff {N}
   ```
3. **Linked issue** — read the acceptance criteria the PR should satisfy:
   ```bash
   # Extract issue number from PR body (look for "Closes #N" or "Fixes #N")
   gh issue view {issue-number} --json title,body,state,labels
   ```
4. **Commit history:**
   ```bash
   gh pr view {N} --json commits --jq '.commits[] | {oid: .oid[0:8], headline: .messageHeadline}'
   ```

**Do not start the checklist until you've read the full diff.** Skimming leads to missed issues.

For **re-reviews** (follow-up commits), read only the new commit(s):
```bash
git show {commit-sha}
```

## Step 2: Run the Review Checklist

Five focus areas, ordered by leverage. Check all five on every review.

### 2a. Runtime Verification — independently reproduce the PR's claims

This is the highest-leverage check.

**Procedure:**

1. Read the PR body's "Verification Performed" section. Note every claim.
2. Read the linked issue's "Verification Instructions" section. Note every checkbox.
3. For UI-related verification: invoke the `zenflow:playwright-verification` skill and follow its full procedure.
4. For backend verification: run the relevant commands, queries, or API calls.
5. Compare what you observe against what the PR body claims.
6. **If claims don't match reality → blocker.** Not a nit. The PR cannot ship until the claim is fixed or retracted.

**Proof artifacts go in the review comment** under the "Runtime Verification" section. Paste command output, DOM snapshots, or screenshot paths.

**When verification can't be performed** (no server, no test data, environment limitation): say so explicitly. Don't skip the section or substitute with "the code looks correct."

### 2b. Code Quality

| Check | What to verify | Severity |
|-------|---------------|----------|
| No type bypass | `as any` / `as never` / type assertions on external data — should use typed interfaces | Load-bearing |
| Error handling at boundaries | External API calls, user input, file I/O have proper error handling | Load-bearing |
| No dead code | Commented-out code, unused imports, unreachable branches | Soft nit |
| Follows project conventions | Patterns from CLAUDE.md and `.claude/rules/` are respected | Load-bearing |
| No security issues | Injection vectors, exposed secrets, unsafe deserialization | Blocker |

### 2c. Test Coverage Quality

| Check | What to verify |
|-------|---------------|
| Tests pin behavior, not implementation | Assertions on outputs and state, not internal function calls |
| Missing test matrix identified | For each new function: what inputs/paths/error conditions are tested? What's missing? |
| Regression tests for bugs fixed | If the PR fixes a bug, there's a test that would have caught it |
| Edge cases covered | Null/empty inputs, boundary values, concurrent access if applicable |

**When tests are missing:** don't just say "add tests." Produce the specific test matrix — test names, what each test asserts. The builder needs actionable guidance.

### 2d. PR Body Integrity

| Check | What to verify |
|-------|---------------|
| Acceptance criteria present | Issue's AC checklist copied into PR body with checked/unchecked items |
| Verification section has artifacts | Command output, screenshots — not "I tested it and it worked" |
| Deferred items documented | Each deferred item explains why and names a follow-up |
| Summary matches the diff | PR body doesn't overstate or understate what changed |

### 2e. Pattern Recognition — Convention Proposals

Track patterns across the diff (and across PRs if you have context):

**When the same issue appears in 3+ places in one PR:**

1. Name the pattern
2. Count the occurrences
3. Use `AskUserQuestion` to present options:
   - Extract a shared helper
   - Add a rule to `.claude/rules/`
   - Create a GitHub issue to track the convention
   - Do nothing (the pattern is intentional)

## Step 3: Write the Review Comment

Use this template. Every section is required — if a section has nothing to report, write "None."

```markdown
## Code Review

### Overview
{1-3 sentences: what the PR does, linked issue}

### Strengths
{Bullet points: conventions followed, good patterns, solid tests}

### Issues & Suggestions
{Numbered items. Each item:}
{**N. Title** — severity (blocker / load-bearing / soft nit)}
{Description}
{Concrete suggestion with code example if applicable}

### Bugs Found
{Bugs discovered during review or runtime verification.}
{Each: reproduction steps, expected vs actual, severity.}
{Directive: "Resolve via zenflow:bug-fix."}
{OR: "None"}

### Testing
{What's covered. What's missing.}
{If gaps: specific test matrix with names and assertions.}

### Runtime Verification
{What the reviewer independently verified, with proof artifacts.}
{OR: "Not performed — {reason}. PR body claims: {summary}."}

### Risk Assessment
{One line each: Correctness / Performance / Security}

### Verdict
{One of: Ship it / Approve-with-nits / Needs work}
{If nits: list the specific items to address.}
{If needs work: list the blockers that must be fixed.}
```

## Step 4: Post and Follow Up

**Independent mode:**
- Post the comment: `gh pr comment {N} --body-file /tmp/review-{N}.md`
- If verdict is "Ship it": `gh pr review {N} --approve --body "Approved — see review comment above."`
- If verdict is "Needs work": `gh pr review {N} --request-changes --body "Changes requested — see review comment above."`
- Summarize the verdict to the user

**Interactive mode:**
- Present findings to the user first
- Discuss any judgment calls
- Post after the user approves the comment

**On re-review (follow-up commits):**
- Read only the new commit(s)
- Check each item from the prior review: fixed / skipped / new issue introduced
- Use the shorter re-review template:

```markdown
## Re-review — follow-up commit {short-sha}

### {Item N from prior review} — {status}
{What was done, whether it's correct}

### New issues introduced
{None / list}

### Verdict
{Ship it / Still needs work}
```

## Bug Discovery During Review

Bugs found during review — especially during runtime verification — must be routed through `zenflow:bug-fix`, not patched inline.

### When to flag a bug

- Runtime verification reveals behavior that contradicts the PR's claims
- Runtime verification reveals a regression
- Code review reveals a logic error that would cause incorrect behavior
- A test exists but asserts the wrong thing (testing broken behavior as correct)

### How to flag in the review

In the **Bugs Found** section, provide:

1. **What you observed** — exact reproduction
2. **What you expected** — based on acceptance criteria
3. **Severity** — blocker or regression
4. **Directive**: "Resolve via `zenflow:bug-fix` — reproduce, diagnose, regression test before fix."

### What the builder must do

When the review contains a **Bugs Found** section:
1. Invoke `zenflow:bug-fix` with the reproduction from the review
2. The pipeline produces a regression test — no test, no merge
3. Push the fix as a follow-up commit on the same PR branch
4. Request re-review

### When NOT to flag as a bug

- Missing features not in the PR's acceptance criteria — that's a follow-up issue
- Code style violations — those go in "Issues & Suggestions"
- Performance concerns without observed degradation — flag in "Risk Assessment"
- Pre-existing bugs unrelated to this PR — create a separate issue

## Escalation Severity Guide

| Severity | Meaning | Action |
|----------|---------|--------|
| **Blocker** | Correctness issue, trust violation, security | Must fix before merge. Verdict: "Needs work." |
| **Load-bearing nit** | Correct today but will break under foreseeable change | Should fix in follow-up commit. Verdict: "Approve-with-nits." |
| **Soft nit** | Style, naming beyond enforced rules | Fix if touching the file; skip otherwise. Never blocks. |
| **Pattern proposal** | Recurring issue across 3+ locations | `AskUserQuestion` with codification options. Doesn't affect verdict. |

## What Not to Do

- **Don't approve without running the checklist.** "LGTM" without the protocol is worse than no review.
- **Don't gold-plate.** Review what was submitted. Don't suggest features beyond scope.
- **Don't block on soft nits.** If the only issues are cosmetic, approve-with-nits.
- **Don't skip runtime verification because it's slow.** If you can't verify, say so — don't silently skip.
- **Don't flag patterns without proposing a fix.** If you've flagged the same thing 3 times, propose a convention via `AskUserQuestion`.
- **Don't make decisions in prose.** Use `AskUserQuestion` for every decision.
