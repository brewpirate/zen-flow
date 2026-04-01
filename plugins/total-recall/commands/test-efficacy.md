---
name: test-efficacy
description: Run behavioral efficacy test — does flooding context then injecting trigger phrases actually help recall?
arguments: "[file paths] [--flood-size N] [--questions N]"
user_invocable: true
---

Load and follow the `total-recall:test-efficacy` skill.

Pass user arguments as context — they may specify file paths, flood size, or question count.
