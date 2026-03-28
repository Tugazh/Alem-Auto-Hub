#!/bin/bash
# Wrapper for codesign that strips metadata first

# Get the actual codesign binary
REAL_CODESIGN="/usr/bin/codesign"

# Check if we're signing Flutter.framework
if [[ "$@" == *"Flutter.framework"* ]]; then
    # Find the framework path in arguments
    for arg in "$@"; do
        if [[ "$arg" == *"Flutter.framework"* ]]; then
            # Strip metadata before signing
            xattr -cr "$arg" 2>/dev/null || true
            find "$arg" -type f -exec dot_clean -m {} \; 2>/dev/null || true
        fi
    done
fi

# Call the real codesign
exec "$REAL_CODESIGN" "$@"
