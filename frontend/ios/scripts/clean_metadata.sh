#!/bin/bash
# Clean extended attributes and resource forks before build

set -e

echo "Cleaning extended attributes from build directory..."

# Clean build directory
if [ -d "${SRCROOT}/../build/ios" ]; then
    find "${SRCROOT}/../build/ios" -type f -exec xattr -c {} \; 2>/dev/null || true
    find "${SRCROOT}/../build/ios" -name "*.framework" -type d -exec xattr -cr {} \; 2>/dev/null || true
    dot_clean -m "${SRCROOT}/../build/ios" 2>/dev/null || true
fi

# Clean native_assets
if [ -d "${SRCROOT}/../build/native_assets" ]; then
    find "${SRCROOT}/../build/native_assets" -type f -exec xattr -c {} \; 2>/dev/null || true
    find "${SRCROOT}/../build/native_assets" -name "*.framework" -type d -exec xattr -cr {} \; 2>/dev/null || true
    dot_clean -m "${SRCROOT}/../build/native_assets" 2>/dev/null || true
fi

# Clean Pods directory
if [ -d "${SRCROOT}/Pods" ]; then
    find "${SRCROOT}/Pods" -name "*.framework" -type d -exec xattr -cr {} \; 2>/dev/null || true
fi

echo "Metadata cleaning complete."
