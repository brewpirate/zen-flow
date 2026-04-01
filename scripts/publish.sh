#!/usr/bin/env bash
# publish.sh — Push tag and create GitHub release.
# Usage: ./scripts/publish.sh <plugin-name>
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGINS_DIR="$REPO_ROOT/plugins"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <plugin-name>"
    exit 1
fi

PLUGIN_NAME="$1"

# Find plugin.json and read version
VERSION=""
for pj in "$PLUGINS_DIR"/*/.claude-plugin/plugin.json; do
    name=$(python3 -c "import json; print(json.load(open('$pj'))['name'])")
    if [[ "$name" == "$PLUGIN_NAME" ]]; then
        VERSION=$(python3 -c "import json; print(json.load(open('$pj'))['version'])")
        break
    fi
done

if [[ -z "$VERSION" ]]; then
    echo "ERROR: plugin '$PLUGIN_NAME' not found"
    exit 1
fi

TAG="${PLUGIN_NAME}-v${VERSION}"

# Verify tag exists locally
if ! git -C "$REPO_ROOT" rev-parse "$TAG" &>/dev/null; then
    echo "ERROR: tag '$TAG' not found. Run release.sh first."
    exit 1
fi

echo "Publishing $PLUGIN_NAME v$VERSION"

# Push commits and tag
git -C "$REPO_ROOT" push origin main
git -C "$REPO_ROOT" push origin "$TAG"
echo "Pushed tag: $TAG"

# Extract changelog for this version
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"
NOTES=""
if [[ -f "$CHANGELOG_FILE" ]]; then
    NOTES=$(python3 -c "
import re
with open('$CHANGELOG_FILE') as f:
    content = f.read()
pattern = r'(## $PLUGIN_NAME v$VERSION.*?)(?=\n## |\Z)'
m = re.search(pattern, content, re.DOTALL)
if m:
    print(m.group(1).strip())
else:
    print('Release $PLUGIN_NAME v$VERSION')
")
fi

# Create GitHub release
gh release create "$TAG" \
    --repo "$(git -C "$REPO_ROOT" remote get-url origin)" \
    --title "$PLUGIN_NAME v$VERSION" \
    --notes "$NOTES"

echo ""
echo "Published: $PLUGIN_NAME v$VERSION"
echo "Release: $(gh release view "$TAG" --json url -q .url 2>/dev/null || echo '(check GitHub)')"
