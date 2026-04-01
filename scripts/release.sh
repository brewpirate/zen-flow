#!/usr/bin/env bash
# release.sh — Bump version in plugin.json, regenerate marketplace.json, changelog, commit, tag.
# Usage: ./scripts/release.sh <plugin-name> <major|minor|patch>
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGINS_DIR="$REPO_ROOT/plugins"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <plugin-name> <major|minor|patch>"
    echo ""
    echo "Plugins:"
    for pj in "$PLUGINS_DIR"/*/.claude-plugin/plugin.json; do
        name=$(python3 -c "import json; print(json.load(open('$pj'))['name'])")
        ver=$(python3 -c "import json; print(json.load(open('$pj'))['version'])")
        echo "  $name  (v$ver)"
    done
    exit 1
fi

PLUGIN_NAME="$1"
BUMP_TYPE="$2"

if [[ "$BUMP_TYPE" != "major" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "patch" ]]; then
    echo "ERROR: bump type must be major, minor, or patch"
    exit 1
fi

# Find plugin.json for this plugin
PLUGIN_JSON=""
PLUGIN_DIR=""
for pj in "$PLUGINS_DIR"/*/.claude-plugin/plugin.json; do
    name=$(python3 -c "import json; print(json.load(open('$pj'))['name'])")
    if [[ "$name" == "$PLUGIN_NAME" ]]; then
        PLUGIN_JSON="$pj"
        PLUGIN_DIR="$(dirname "$(dirname "$pj")")"
        break
    fi
done

if [[ -z "$PLUGIN_JSON" ]]; then
    echo "ERROR: plugin '$PLUGIN_NAME' not found"
    exit 1
fi

# Read current version and bump
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")
NEW_VERSION=$(python3 -c "
parts = '$CURRENT_VERSION'.split('.')
idx = {'major': 0, 'minor': 1, 'patch': 2}['$BUMP_TYPE']
parts[idx] = str(int(parts[idx]) + 1)
for i in range(idx + 1, 3):
    parts[i] = '0'
print('.'.join(parts))
")

echo "Releasing $PLUGIN_NAME: $CURRENT_VERSION → $NEW_VERSION"

# Update version in plugin.json
python3 -c "
import json
with open('$PLUGIN_JSON') as f:
    data = json.load(f)
data['version'] = '$NEW_VERSION'
with open('$PLUGIN_JSON', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"
echo "Updated plugin.json"

# Regenerate marketplace.json
"$REPO_ROOT/scripts/build.sh"

# Generate changelog from git log since last tag
LAST_TAG=$(git tag -l "${PLUGIN_NAME}-v*" --sort=-v:refname | head -1 || true)

CHANGELOG_ENTRY="## $PLUGIN_NAME v$NEW_VERSION ($(date +%Y-%m-%d))"$'\n\n'
if [[ -n "$LAST_TAG" ]]; then
    COMMITS=$(git log "$LAST_TAG"..HEAD --oneline -- "$PLUGIN_DIR" 2>/dev/null || true)
else
    COMMITS=$(git log --oneline -- "$PLUGIN_DIR" 2>/dev/null || true)
fi

if [[ -n "$COMMITS" ]]; then
    while IFS= read -r line; do
        CHANGELOG_ENTRY+="- ${line#* }"$'\n'
    done <<< "$COMMITS"
else
    CHANGELOG_ENTRY+="- Release $NEW_VERSION"$'\n'
fi

# Prepend to CHANGELOG.md
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"
if [[ -f "$CHANGELOG_FILE" ]]; then
    EXISTING=$(cat "$CHANGELOG_FILE")
    printf '%s\n\n%s' "$CHANGELOG_ENTRY" "$EXISTING" > "$CHANGELOG_FILE"
else
    echo "$CHANGELOG_ENTRY" > "$CHANGELOG_FILE"
fi
echo "Updated CHANGELOG.md"

# Commit and tag
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
git -C "$REPO_ROOT" add "$PLUGIN_JSON" "$MARKETPLACE_JSON" "$CHANGELOG_FILE"
git -C "$REPO_ROOT" commit -m "release: $PLUGIN_NAME v$NEW_VERSION"
git -C "$REPO_ROOT" tag "${PLUGIN_NAME}-v${NEW_VERSION}"

echo ""
echo "Created tag: ${PLUGIN_NAME}-v${NEW_VERSION}"
echo "Run ./scripts/publish.sh $PLUGIN_NAME to push and create a GitHub release."
