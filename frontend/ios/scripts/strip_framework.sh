#!/bin/bash
# Strip macOS metadata from frameworks before codesigning

set -e

FRAMEWORK_PATH="$1"

if [ -z "$FRAMEWORK_PATH" ]; then
    echo "Usage: $0 <framework_path>"
    exit 1
fi

echo "Stripping metadata from: $FRAMEWORK_PATH"

# Remove extended attributes
xattr -cr "$FRAMEWORK_PATH" 2>/dev/null || true

# Remove resource forks
find "$FRAMEWORK_PATH" -type f -exec dot_clean -m {} \; 2>/dev/null || true

echo "Metadata stripped successfully"
