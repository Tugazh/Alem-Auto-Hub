#!/bin/bash
# Pre-build script to clean macOS metadata from Flutter SDK

set -e

echo "Cleaning macOS metadata from Flutter SDK..."

# Find Flutter SDK path
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"

if [ -d "$FLUTTER_ROOT" ]; then
    # Clean metadata from iOS engine binaries
    find "$FLUTTER_ROOT/bin/cache/artifacts/engine" -name "*.framework" -type d -exec xattr -cr {} \; 2>/dev/null || true
    find "$FLUTTER_ROOT/bin/cache/artifacts/engine" -type f -exec xattr -c {} \; 2>/dev/null || true
    find "$FLUTTER_ROOT/bin/cache/artifacts/engine" -type f -exec dot_clean -m {} \; 2>/dev/null || true
    echo "✓ Flutter SDK cleaned"
else
    echo "⚠ Flutter SDK not found at $FLUTTER_ROOT"
fi

# Clean project build directory
if [ -d "$SRCROOT/../build" ]; then
    find "$SRCROOT/../build" -name "*.framework" -type d -exec xattr -cr {} \; 2>/dev/null || true
    find "$SRCROOT/../build" -type f -exec xattr -c {} \; 2>/dev/null || true
    echo "✓ Build directory cleaned"
fi

echo "Metadata cleanup complete"
