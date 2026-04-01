#!/usr/bin/env bash
# dev.sh — Symlink plugin sources into the Claude Code cache for live development.
# Prerequisite: run `/plugin marketplace add ./` and install plugins first.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLED_JSON="$HOME/.claude/plugins/installed_plugins.json"

# Rebuild marketplace.json from plugin.json files
"$REPO_ROOT/scripts/build.sh"
echo ""

# For each plugin, find its cache path and replace with symlink to source
python3 -c "
import json, os, glob

repo = '$REPO_ROOT'
plugins_dir = os.path.join(repo, 'plugins')
installed_path = '$INSTALLED_JSON'

with open(installed_path) as f:
    installed = json.load(f)

for path in sorted(glob.glob(os.path.join(plugins_dir, '*/.claude-plugin/plugin.json'))):
    plugin_dir = os.path.dirname(os.path.dirname(path))
    with open(path) as f:
        meta = json.load(f)

    name = meta['name']

    # Find matching entry in installed_plugins.json
    match = None
    for key, entries in installed['plugins'].items():
        if key.startswith(name + '@'):
            match = (key, entries[0])
            break

    if not match:
        print(f'SKIP {name} — not found in installed_plugins.json')
        print(f'  Install it first: /plugin install {name}')
        continue

    key, entry = match
    cache_path = entry['installPath']

    if os.path.islink(cache_path):
        target = os.readlink(cache_path)
        if target == plugin_dir:
            print(f'OK   {name} — already linked')
            continue
        os.unlink(cache_path)
    elif os.path.isdir(cache_path):
        import shutil
        shutil.rmtree(cache_path)

    os.symlink(plugin_dir, cache_path)
    print(f'LINK {name} → {cache_path}')
"

echo ""
echo "Dev mode active. Edits to plugin sources are now live."
echo "Restart Claude Code to pick up changes."
