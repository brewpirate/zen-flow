---
layout: home

hero:
  name: zen-marketplace
  text: Claude Code plugins for structured development
  tagline: A collection of experimental plugins that add workflow structure, session logging, and context management to Claude Code.
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started
    - theme: alt
      text: GitHub
      link: https://github.com/brewpirate/zen-flow

features:
  - icon: 🌊
    title: ZenFlow
    details: Adds a development pipeline to Claude Code — from initial idea through implementation, validation, and code review. Each stage is a separate command with defined inputs and outputs.
    link: /plugins/zenflow/
    linkText: Documentation

  - icon: 📓
    title: Agent Journal
    details: Writes structured log entries after each work session. Entries are stored as JSONL and can be read, filtered, and summarized. Includes a browser-based viewer.
    link: /plugins/agent-journal/
    linkText: Documentation

  - icon: 🧠
    title: Total Recall
    details: Generates short trigger phrases for files by sampling how the model independently describes them. The phrases can be injected later to help the model re-focus on content that has drifted out of active attention.
    link: /plugins/total-recall/
    linkText: Documentation
---

::: warning Experimental
All plugins in this marketplace are under active development. APIs, commands, and behavior may change without notice.
:::

## Plugins

| Plugin | What it does |
|--------|-------------|
| **[zenflow](/plugins/zenflow/)** | A structured pipeline for going from idea to reviewed code. 15 commands, 3 agents, 3 enforcement hooks. |
| **[agent-journal](/plugins/agent-journal/)** | Appends structured entries to a `.claude/journal.jsonl` file after work sessions. 5 commands, HTML viewer. |
| **[total-recall](/plugins/total-recall/)** | Generates model-specific trigger phrases for files using convergence sampling. 6 commands, 3 agents. |
