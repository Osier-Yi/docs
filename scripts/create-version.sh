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

echo "Creating version $NEW_VERSION from $SOURCE_VERSION..."

# Copy the source version
cp -r "$SOURCE_DIR" "$TARGET_DIR"

# Replace version references in all mdx files
echo "Updating internal links..."
find "$TARGET_DIR" -name "*.mdx" -exec sed -i '' "s|/versions/$SOURCE_VERSION/|/versions/$NEW_VERSION/|g" {} \;

# Count modified files
MODIFIED_COUNT=$(grep -r "/versions/$NEW_VERSION/" "$TARGET_DIR" --include="*.mdx" -l 2>/dev/null | wc -l | tr -d ' ')

# Update redirects in docs.json
echo "Updating redirects in docs.json..."
if [[ "$NEW_VERSION" =~ dev$ ]]; then
    # Pre-release version: update /latest/ alias
    sed -i '' '/\/latest\/:slug\*/{ n; s|"destination": "/versions/[^"]*"|"destination": "/versions/'"$NEW_VERSION"'/:slug*"|; }' "$DOCS_JSON"
    REDIRECT_UPDATED="/latest/ -> $NEW_VERSION"
else
    # Stable version: update /stable/ alias
    sed -i '' '/\/stable\/:slug\*/{ n; s|"destination": "/versions/[^"]*"|"destination": "/versions/'"$NEW_VERSION"'/:slug*"|; }' "$DOCS_JSON"
    REDIRECT_UPDATED="/stable/ -> $NEW_VERSION"
fi

echo ""
echo "✅ Created version $NEW_VERSION"
echo "   Source: $SOURCE_DIR"
echo "   Target: $TARGET_DIR"
echo "   Files with updated links: $MODIFIED_COUNT"
echo "   Redirect updated: $REDIRECT_UPDATED"
echo ""
echo "Next steps:"
echo "  1. Update docs.json to add the new version to navigation"
echo "  2. Make your documentation changes in $TARGET_DIR"
echo "  3. Run 'mint dev' to preview"
