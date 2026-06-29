#!/bin/bash

# Usage: ./scripts/create-version.sh <new-version> [source-version]
# Example: ./scripts/create-version.sh 2.0.4dev
# Example: ./scripts/create-version.sh 2.0.4dev 2.0.3

set -e

NEW_VERSION="$1"
SOURCE_VERSION="$2"

if [ -z "$NEW_VERSION" ]; then
    echo "Usage: $0 <new-version> [source-version]"
    echo "Example: $0 2.0.4dev"
    echo "Example: $0 2.0.4dev 2.0.3"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCS_ROOT="$(dirname "$SCRIPT_DIR")"
VERSIONS_DIR="$DOCS_ROOT/versions"
DOCS_JSON="$DOCS_ROOT/docs.json"

# If source version not specified, find the latest version
if [ -z "$SOURCE_VERSION" ]; then
    # Get all version directories, sort by version number (descending), take the first
    SOURCE_VERSION=$(ls -1 "$VERSIONS_DIR" | sort -V -r | head -1)
    
    if [ -z "$SOURCE_VERSION" ]; then
        echo "Error: No existing versions found in $VERSIONS_DIR"
        exit 1
    fi
fi

SOURCE_DIR="$VERSIONS_DIR/$SOURCE_VERSION"
TARGET_DIR="$VERSIONS_DIR/$NEW_VERSION"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source version directory not found: $SOURCE_DIR"
    exit 1
fi

if [ -d "$TARGET_DIR" ]; then
    echo "Error: Target version already exists: $TARGET_DIR"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to update docs.json but was not found."
    exit 1
fi

echo "Creating version $NEW_VERSION from $SOURCE_VERSION..."

# Copy the source version
cp -r "$SOURCE_DIR" "$TARGET_DIR"

# Replace version references in all mdx files
echo "Updating internal links in mdx files..."
find "$TARGET_DIR" -name "*.mdx" -exec sed -i '' "s|/versions/$SOURCE_VERSION/|/versions/$NEW_VERSION/|g" {} \;

# Count modified files
MODIFIED_COUNT=$(grep -r "/versions/$NEW_VERSION/" "$TARGET_DIR" --include="*.mdx" -l 2>/dev/null | wc -l | tr -d ' ')

# Update docs.json: clone navigation entry per language + update redirects
echo "Updating docs.json (navigation + redirects)..."
PY_OUTPUT=$(DOCS_JSON="$DOCS_JSON" SOURCE_VERSION="$SOURCE_VERSION" NEW_VERSION="$NEW_VERSION" python3 <<'PYEOF'
import copy
import json
import os

docs_json_path = os.environ["DOCS_JSON"]
source_version = os.environ["SOURCE_VERSION"]
new_version = os.environ["NEW_VERSION"]

with open(docs_json_path, "r", encoding="utf-8") as f:
    data = json.load(f)


def update_paths(obj):
    """Recursively rewrite any 'versions/<SOURCE_VERSION>/' substring."""
    src = f"versions/{source_version}/"
    dst = f"versions/{new_version}/"
    if isinstance(obj, str):
        return obj.replace(src, dst)
    if isinstance(obj, list):
        return [update_paths(x) for x in obj]
    if isinstance(obj, dict):
        return {k: update_paths(v) for k, v in obj.items()}
    return obj


added = []
skipped = []
languages = data.get("navigation", {}).get("languages", []) or []
for lang_entry in languages:
    lang = lang_entry.get("language", "?")
    versions = lang_entry.get("versions", []) or []

    # Skip if the new version already exists for this language
    if any(v.get("version") == new_version for v in versions):
        skipped.append(f"{lang}(already exists)")
        continue

    # Locate the source version block
    source_idx = next(
        (i for i, v in enumerate(versions) if v.get("version") == source_version),
        None,
    )
    if source_idx is None:
        skipped.append(f"{lang}(source '{source_version}' not in navigation)")
        continue

    # Deep-copy, update version field, then rewrite all internal paths
    new_entry = copy.deepcopy(versions[source_idx])
    new_entry["version"] = new_version
    new_entry = update_paths(new_entry)

    # Insert right BEFORE the source version so newer versions appear higher
    versions.insert(source_idx, new_entry)
    lang_entry["versions"] = versions
    added.append(lang)

# Update redirects (/latest/ for dev, /stable/ for release)
is_dev = new_version.endswith("dev")
target_source = "/latest/:slug*" if is_dev else "/stable/:slug*"
redirect_updated = ""
for redirect in data.get("redirects", []) or []:
    if redirect.get("source") == target_source:
        redirect["destination"] = f"/versions/{new_version}/:slug*"
        redirect_updated = f"{target_source} -> /versions/{new_version}/:slug*"
        break

with open(docs_json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"ADDED={','.join(added)}")
print(f"SKIPPED={','.join(skipped)}")
print(f"REDIRECT={redirect_updated}")
PYEOF
)

NAV_ADDED=$(echo "$PY_OUTPUT" | sed -n 's/^ADDED=//p')
NAV_SKIPPED=$(echo "$PY_OUTPUT" | sed -n 's/^SKIPPED=//p')
REDIRECT_UPDATED=$(echo "$PY_OUTPUT" | sed -n 's/^REDIRECT=//p')

echo ""
echo "✅ Created version $NEW_VERSION"
echo "   Source: $SOURCE_DIR"
echo "   Target: $TARGET_DIR"
echo "   Files with updated links: $MODIFIED_COUNT"
echo "   Navigation added for: ${NAV_ADDED:-<none>}"
if [ -n "$NAV_SKIPPED" ]; then
    echo "   Navigation skipped:    $NAV_SKIPPED"
fi
echo "   Redirect updated:      ${REDIRECT_UPDATED:-<no matching redirect found>}"
echo ""
echo "Next steps:"
echo "  1. Review docs.json to confirm the new version block looks right"
echo "  2. Make your documentation changes in $TARGET_DIR"
echo "  3. Run 'mint dev' to preview"
