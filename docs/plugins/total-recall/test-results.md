# Test Results

## Convergence sampling validation

Tested against 26 files from a real project — 14 engineering rules and 12 documentation files.

| Metric | Result |
|--------|--------|
| Files tested | 26 |
| Average confidence | 0.93 |
| Phase 1 convergence rate | 100% |
| Highest confidence | 0.99 (testing.md) |
| Lowest confidence | 0.80 (04-claude-integration.md) |
| Total agent calls | 130 (Haiku) |

### Selected results

| File | Trigger phrase | Confidence |
|------|----------------|------------|
| testing | test behavior not implementation | 0.99 |
| error-handling | throw typed errors at boundaries | 0.98 |
| bun-native-apis | prefer bun native over node | 0.98 |
| options-objects | single options object for parameters | 0.98 |
| README.md | autonomous issue driven development | 0.98 |
| dependency-injection | injectable dependencies over globals | 0.95 |
| zod-schemas | zod schemas source of truth | 0.95 |
| broken-windows | quality ratchet broken windows | 0.90 |
| 04-claude-integration | dual path into claude | 0.80 |

### Observations

**The model surfaces semantic meaning, not keywords.** The word "ratchet" appears once in its source file — a term TF-IDF would discard as low-frequency — but 2 of 5 agents independently identified it as the defining metaphor. "Globals" appeared in triggers for a dependency injection rule, encoding what the file argues *against*, not what it contains directly. "Assembly line" appeared in 3 of 5 samples for an agent-roles file without appearing in the source at all.

**Some files have stable attractors.** `testing.md` hit 0.99 confidence with near-identical phrases from all 5 agents. The phrase `"test behavior not implementation"` is a fixed point in the model's output distribution for that content.

**Low confidence is diagnostic.** The file with the lowest confidence (0.80, `04-claude-integration.md`) covered two distinct topics: SDK mode and CLI subprocess mode. The convergence weakness correctly identified the multi-topic structure.

---

## Cross-model comparison

A separate cross-model test ran 14 files through all three models: Haiku, Sonnet, and Opus. 210 total agent calls.

| Metric | Haiku | Sonnet | Opus |
|--------|-------|--------|------|
| Average confidence | 0.94 | 0.96 | 0.98 |
| Perfect fixed points (5/5 identical phrases) | 0% | 21% | 64% |

Key findings:

- **Triggers are model-specific.** Sonnet and Opus generate different trigger phrases for the same file. For a code quality rule, Sonnet converged on `"broken windows code quality ratchet"` and Opus on `"broken windows codebase quality ratchet"`. Same concept, different internal representations.
- **Opus produces the most stable output.** 9 of 14 files had all 5 agents return identical phrases. This is why `--models opus` is recommended when you want triggers for Opus-based agents.
- **Sonnet abstracts more.** Sonnet tends toward imperative framings (`"prefer bun over node fs"`), while Opus trends toward enumerating specific concepts (`"zod4 strict tsdoc pino biome gates"`).
- **Cross-model shared terms exist.** Some terms appear in both Sonnet and Opus triggers — words like "options", "object", "positional", "params" for a function signature rule. These cross-model terms are the most portable triggers.

Full raw data: [CROSS_MODEL_RESULTS.md](https://github.com/brewpirate/zen-flow/blob/main/plugins/total-recall/CROSS_MODEL_RESULTS.md)

---

## Behavioral efficacy tests

Three rounds of synthetic tests attempted to measure whether injecting trigger phrases actually helps a model recall content that has been pushed deep into a long context.

| Test | Context size | Method | Result |
|------|-------------|--------|--------|
| v1 — Passive flood | ~60K tokens | Read 10 source files | All conditions identical |
| v2 — Active engagement | ~80K tokens | 5 deep analysis tasks | All conditions identical |
| v3 — Heavy engagement | ~136K tokens | 12 deep analysis tasks across 30+ files | All conditions identical |

All three tests showed no measurable difference between trigger injection, a generic hint, and no intervention at all.

**Why the tests showed no effect:** Sonnet retained perfect recall of a ~1K token rule file at every tested depth, even after 12 substantive code review and architecture tasks. The model did not exhibit the attention decay the test was designed to measure.

**Why that doesn't fully answer the question:** Attention decay in practice appears to be an organic phenomenon — it accumulates over real working sessions through temporal distance, context switching, conversational noise, and system-level context compression. A synthetic single-turn test cannot reproduce the conditions. The decay, if it exists, happens over 45 minutes and dozens of exchanges, not over token count alone in a controlled test.

**Current status:** The trigger generation mechanism works as described and produces high-quality semantic handles for content. Whether these triggers provide measurable benefit in real long-horizon sessions is an open question. The behavioral efficacy claim requires real-session instrumentation to test, which has not yet been run.

---

## What is and isn't established

### Established

- Convergence sampling reliably generates short, semantically meaningful phrases for engineering concept files
- The sampling finds conceptual salience — metaphors, contrasts — that frequency-based methods miss
- Phase 1 is sufficient for well-structured, focused files (100% in testing)
- Low confidence scores correctly identify files covering multiple topics
- Different models produce different trigger phrases for the same file
- Opus produces more stable output than Sonnet or Haiku

### Not yet established

- Whether trigger injection meaningfully improves attention recall in real, long multi-turn sessions
- Whether attention decay during real sessions is significant enough to matter for current large-context models (200K+ token windows)
- Whether the mechanism holds for project-specific code with thin parametric backing (vs. general engineering concepts)
