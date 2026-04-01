---
name: idea
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by assessing how concrete the idea is. A vague spark needs exploration before options. A clear intent is ready for design. Meet the idea where it is.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Step 0: Assess Maturity

Before anything else, read the user's input and assess where it falls:

**"An idea"** — vague, the user is still forming their thinking:
- "I want to improve how agents communicate"
- "We should do something about test performance"
- "What if we had a plugin system?"
- User says "I'm not sure yet", "just thinking out loud", "exploring"

→ Enter **Exploration Mode** — explore the *problem space*

**"A problem"** — clear pain point, but no direction for the solution yet:
- "Our observability is terrible"
- "Tests are flaky and slow"
- "The plugin loader is a bottleneck"
- User knows what's broken but not what to build

→ Enter **Discovery Mode** — the problem is known, explore the *solution space*

**"The idea"** — clear intent, the user knows what they want:
- "Add SSE notifications for issue state changes"
- "Convert the plugin loader to lazy initialization"
- "We need a journal skill with write, read, summary, reflect"

→ Enter **Design Mode**

If you can't tell, ask:

**"How would you describe where you are with this?"**
- "Still thinking" → Exploration Mode
- "I know the problem but not the solution" → Discovery Mode
- "I know what I want to build" → Design Mode

## Exploration Mode

The idea is still taking shape. Your job is to help the user think, not rush to solutions.

**Mindset:**
- Curiosity over efficiency — ask "why" and "what if", not "which option"
- No proposals yet — understand the problem space first
- Follow the user's energy — if they're excited about a tangent, explore it
- Think out loud together — share observations, not conclusions

**Process:**

1. **Explore project context** — check files, docs, recent commits to understand the landscape
2. **Ask open questions** — one at a time, understand the problem before thinking about solutions:
   - "What prompted this?"
   - "What's the pain point you're feeling?"
   - "Who is this for?"
   - "What does success look like?"
   - "What have you already considered?"
3. **Investigate together** — when a question needs real answers, spawn a research agent:
   ```
   Agent tool:
     description: "Research: [specific question]"
     subagent_type: Explore
     prompt: "[what to investigate and report back]"
   ```
   Share findings with the user and discuss implications.
4. **Checkpoint findings** — periodically summarize what you've learned together:
   ```
   "Here's where we are so far:
     - The problem is [X]
     - We've explored [Y] and [Z]
     - Open questions: [A], [B]
     - Emerging direction: [C]
   Does this feel right?"
   ```
5. **Watch for convergence** — when the user starts making decisions ("I think we should...", "Let's go with...", "The important part is..."), the idea is maturing. Ask:
   **"This is getting concrete — ready to move into design mode?"**
6. **Transition** — when the user says yes, switch to Design Mode with all the exploration context intact.

**Key principles for exploration:**
- **No proposals** until the user signals readiness
- **One question at a time** — don't overwhelm
- **Spawn research agents** for deep investigation — don't burn context reading 20 files
- **Checkpoint every 3-4 exchanges** — summarize so nothing is lost

### Exploration Artifact (mandatory)

Before transitioning to discovery or design mode, you MUST produce a written summary. This is non-negotiable — if the session dies, this artifact preserves everything.

Write an `agent-journal:write` entry of type `exploration` AND present the summary to the user:

```
## Exploration Summary

**Starting point:** [what the user originally said]
**Problem space:** [what we learned about the problem]
**Key findings:**
- [finding 1]
- [finding 2]
**Constraints discovered:** [what limits the solution]
**Emerging direction:** [where the thinking is heading]
**Open questions:** [what's still unresolved]
```

This feeds directly into discovery or design mode as the starting context.

## Discovery Mode

The problem is clear but the solution isn't. Skip problem exploration — the user already knows the pain. Focus on exploring *solutions*.

**Mindset:**
- The user doesn't need convincing that there's a problem — they told you
- Investigate what solutions exist, what others have done, what the codebase supports
- Compare approaches on concrete dimensions (complexity, risk, timeline, dependencies)

**Process:**

1. **Acknowledge the problem** — don't re-ask "what's the pain?" — the user told you
2. **Investigate the current state** — read the relevant code, understand what exists today
3. **Research approaches** — spawn research agents to explore:
   - How does the codebase currently handle this (or fail to)?
   - What patterns do similar projects use?
   - What are the constraints (dependencies, API compatibility, performance)?
4. **Present findings conversationally** — share what you learned, discuss trade-offs:
   - "I found three approaches others use for this..."
   - "The codebase already has [X] which we could build on..."
   - "The main constraint is [Y]..."
5. **Narrow together** — let the user react to findings and steer toward a direction
6. **Transition to design** — when a direction emerges, produce a discovery artifact and move to design mode

### Discovery Artifact (mandatory)

Before transitioning to design mode, produce:

```
## Discovery Summary

**Problem:** [the clear problem statement]
**Current state:** [how the codebase handles this today]
**Approaches investigated:**
1. [approach] — [trade-offs]
2. [approach] — [trade-offs]
3. [approach] — [trade-offs]
**Leading candidate:** [strongest approach so far, or "undecided — design mode will resolve"]
**Key constraints:** [what shapes the solution]
```

## Design Mode

The idea is clear. Now help the user make design decisions.

**Checklist:**

1. **Explore project context** (if not already done in exploration) — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design** — in sections scaled to their complexity, get user approval after each section
5. **Transition to implementation** — invoke zenflow:plan skill to create implementation plan

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message — if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**
- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

## After the Design

- Invoke the zenflow:plan skill to create a detailed implementation plan
- The design decisions from this conversation become the plan's Context and Architecture sections
- Do NOT invoke any other skill. zenflow:plan is the next step.

**The terminal state is invoking zenflow:plan.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after zenflow:idea is zenflow:plan.

## Key Principles

- **Meet the idea where it is** — vague ideas get exploration, clear ideas get design
- **One question at a time** — don't overwhelm with multiple questions
- **Multiple choice preferred** — easier to answer than open-ended when possible (design mode)
- **YAGNI ruthlessly** — remove unnecessary features from all designs
- **Explore alternatives** — always propose 2-3 approaches before settling (design mode)
- **Incremental validation** — present design, get approval before moving on
- **Be flexible** — go back and clarify when something doesn't make sense
- **Checkpoint often** — in exploration mode, summarize findings every 3-4 exchanges

## Related Skills

- **zenflow:plan** — the only skill invoked after design approval
- **zenflow:collab** — for ongoing collaborative work (zenflow:idea is for pre-implementation design)
- **agent-journal:write** — checkpoint exploration findings for future sessions
