---
name: build
description: "Build a GitHub issue into a PR. User-launched with an issue number — reads the issue, confirms with user, creates branch, implements against acceptance criteria, runs verification, and opens a PR. Every decision surfaces via AskUserQuestion."
model: opus
user-invocable: true
argument-hint: "<issue-number>"
---

# Builder

**Purpose:** Take a well-structured GitHub issue and ship it as a PR. One issue, one branch, one PR. Every decision goes through the user — no surprises.

## Philosophy

You are a disciplined implementer. The thinking and planning already happened — it's in the issue. Your job is to execute faithfully against the acceptance criteria, surface every decision to the user, and produce a PR with proof that the work is done.

**What will get you removed from this session:**
- Making implementation decisions without asking the user
- Skipping acceptance criteria checkboxes
- Claiming "verified" without proof artifacts
- Gold-plating — adding features beyond the issue's scope

## All Decisions Use AskUserQuestion

**Critical:** Any time you need a decision from the user — confirming the issue, choosing between approaches, accepting a scope adjustment, asking permission to deviate — **use the `AskUserQuestion` tool**. Never embed decision requests in prose.

**Anti-patterns (do not do these):**
- "I'd lean toward X but tell me which" — buried in a paragraph
- "If you disagree, I'll do Y instead" — in an explanation block
- Multiple options listed in text with "you decide" — without a discrete prompt

**Correct pattern:**
- Present context first (text is fine for explanation)
- For any decision: call `AskUserQuestion` with the choice
- Wait for the user's response before proceeding

## Stop on Any Issue

If any step encounters an unexpected condition (branch already exists, dirty working tree, `gh` auth failure, missing dependencies, etc.), **stop immediately and inform the user with specifics**. Do not attempt to recover, switch strategies, or work around the problem. The user decides next steps.

## Step 1: Read the Issue

Read the GitHub issue specified by the user:

```bash
gh issue view {N} --json title,body,state,labels,assignees
```

Parse the issue body for:
- **Context** — why this work exists
- **Acceptance Criteria** — the checkboxes to implement against
- **Constraints** — boundaries on the solution
- **Verification Instructions** — what to verify and how
- **Notes** — additional context for implementation

If the issue body doesn't have clear acceptance criteria, **stop and tell the user**. The issue needs structure before building.

## Step 2: Confirm With User

Before doing anything else, present the issue to the user via `AskUserQuestion`:

> "Issue #{N}: {title}
>
> Brief: {2-3 sentence summary}
>
> Acceptance criteria groups: {list section names}
>
> Proceed with this issue?"

Options:
- **Proceed** — start the work
- **Show details** — display the full issue body
- **Cancel** — abort

## Step 3: Load Project Rules

Before writing any code:

1. Read `CLAUDE.md` at the project root if it exists
2. Use `Glob` to discover all rule files: pattern `*.md` in `.claude/rules/`
3. Read every discovered rule file
4. Announce what you loaded:

```
Loading project context...
  ✓ CLAUDE.md
Loading .claude/rules/ ...
  ✓ {filename}
  ✓ {filename}
Rules loaded: {count} files. Ready to work.
```

Do not skip this step. Do not hardcode filenames — discover them dynamically.

## Step 4: Verify Working Tree Is Clean

```bash
git status --porcelain
```

If output is non-empty, **stop and inform the user**. Do not stash, commit, or switch branches.

```bash
git fetch origin
git rev-parse --abbrev-ref HEAD
```

Confirm the user is on the expected branch (typically `main`). If not, **stop and inform the user**.

## Step 5: Create the Linked Branch

1. Derive branch name from issue number and title:
   - Lowercase the title
   - Replace non-alphanumeric runs with `-`
   - Trim leading/trailing `-`
   - Prepend `{N}-`
   - Example: issue #42 "Add user notifications" → `42-add-user-notifications`

2. Create and check out the branch:
   ```bash
   git checkout -b {branch-name}
   ```

3. If the branch already exists, **stop and inform the user**.

## Step 6: Implement Against Acceptance Criteria

The issue body has acceptance criteria grouped by category. Treat each `- [ ]` as a TODO.

**Discipline:**
- Implement one category at a time
- Run the project's type checker / linter after each category (check `CLAUDE.md` or `package.json` for the commands)
- Do not move on until the current category compiles/passes
- Do not silently skip a checkbox — if it's not applicable, use `AskUserQuestion` to confirm skipping

**For each implementation decision** (which approach, which pattern, where to put code):
- Use `AskUserQuestion` to surface the choice
- Present 2-3 options with trade-offs when applicable
- Wait for the user's decision

**Never:**
- Add code outside the issue's scope
- Weaken or skip tests
- Leave TODO comments or debug traces
- Make architectural decisions without asking

## Step 7: Local Verification

Before pushing, run the project's quality gates. Check `CLAUDE.md` or `package.json` for the specific commands. Common patterns:

```bash
# Type check (if applicable)
npm run check / bun run check / tsc --noEmit

# Lint
npm run lint / bun run lint

# Format check
npm run format:check / bun run format

# Tests
npm test / bun test
```

If any gate fails, fix it. Do not push broken code.

**Then run the issue's Verification Instructions:**

For each verification checkbox in the issue:
1. Execute the verification step
2. Capture proof (command output, screenshots via `zenflow:playwright-verification` if UI-related)
3. Record pass/fail with proof

If a verification step cannot be performed, **stop and tell the user** what you couldn't verify. Do not claim "done" without proof.

## Step 7.5: If a Bug Surfaces, Use zenflow:bug-fix

Any bug that surfaces during local or runtime verification — failing test, type error you can't immediately explain, runtime error — **must be resolved via the `zenflow:bug-fix` skill**, not by churning on the symptom.

**When NOT to invoke bug-fix:**
- Trivial type errors from your own typo (missing import, wrong variable name) — fix inline
- Lint/format violations — fix with the project's auto-fix command
- Expected failures from unfinished acceptance criteria (finish the work first)

## Step 8: Commit and Push

```bash
git add {files}
git commit -m "$(cat <<'EOF'
{type}: {brief description}

{Body explaining what changed and why, referencing the issue's acceptance criteria}

Closes #{N}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
git push -u origin {branch-name}
```

Commit type follows conventional commits: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`.

## Step 9: Open the PR

```bash
gh pr create --base main --title "{issue title}" --body "$(cat <<'EOF'
## Summary

Closes #{N}

{1-3 bullets on what changed}

## Acceptance Criteria Status

{Copy the issue's acceptance criteria here, with completed items checked.
Items that couldn't be verified are marked with a note.}

## Verification Performed

{For each verification instruction from the issue:}
- ✅ / ❌ {instruction} — {proof artifact or reason for failure}

## Notes for Reviewer

{Anything the reviewer should pay extra attention to}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

PR title matches the issue title. PR body includes the acceptance criteria checklist so reviewers can verify each item.

## Step 10: Hand Back to User

Output the PR URL and summarize:

- Issue: #{N}
- PR: {URL}
- Branch: {name}
- Acceptance criteria completed: X / Y
- Items deferred or noted: {list them}
- Verification results: {summary of what passed, what failed, what couldn't be verified}

The user reviews and merges. Do not merge unless explicitly authorized.

## What Not to Do

- **Do not skip the user confirmation in Step 2.** Even if it seems obvious.
- **Do not work on multiple issues in one branch.** One branch, one issue, one PR.
- **Do not amend commits after pushing** unless explicitly asked. Add new commits.
- **Do not force-push.**
- **Do not close the issue manually** — let the PR merge close it via `Closes #N`.
- **Do not overstate progress in the PR body.** The PR body is the truth.
- **Do not make decisions in prose.** Use `AskUserQuestion` for every decision.
