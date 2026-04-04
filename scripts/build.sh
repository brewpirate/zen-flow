#!/usr/bin/env bash
# build.sh — Generate marketplace.json from each plugin's .claude-plugin/plugin.json
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
PLUGINS_DIR="$REPO_ROOT/plugins"

python3 -c "
import json, os, glob

plugins_dir = '$PLUGINS_DIR'
entries = []

for path in sorted(glob.glob(os.path.join(plugins_dir, '*/.claude-plugin/plugin.json'))):
    plugin_dir = os.path.dirname(os.path.dirname(path))
    rel_source = './plugins/' + os.path.basename(plugin_dir)

    with open(path) as f:
        meta = json.load(f)

    entries.append({
        'name': meta['name'],
        'source': rel_source,
        'description': meta.get('description', ''),
        'version': meta['version'],
    })
    print(f'  {meta[\"name\"]} v{meta[\"version\"]}')

marketplace = {
    'name': 'zen-marketplace',
    'owner': {
        'name': 'Daniel Zenner',
        'email': 'daniel@zenner.zev',
    },
    'metadata': {
        'description': 'zenflow workflow: idea → plan → execute → validate → review. Plus field-notes for structured work logging.',
    },
    'plugins': entries,
}

with open('$MARKETPLACE_JSON', 'w') as f:
    json.dump(marketplace, f, indent=2)
    f.write('\n')

print(f'\nGenerated marketplace.json ({len(entries)} plugins)')
"
