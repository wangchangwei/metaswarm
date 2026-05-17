#!/bin/bash
# next-version.sh — Determine the next version number based on change type
#
# Usage:
#   ./scripts/next-version.sh major    # Returns v{MAJOR+1}.0.0
#   ./scripts/next-version.sh minor    # Returns v{MAJOR}.{MINOR+1}.0
#   ./scripts/next-version.sh patch    # Returns v{MAJOR}.{MINOR}.{PATCH+1}
#   ./scripts/next-version.sh          # Returns MINOR by default
#
# Reads current version from:
#   1. version.txt (if exists)
#   2. package.json version field (if exists)
#   3. Defaults to v0.1.0 if neither exists

set -e

TYPE="${1:-minor}"

# Find version file
if [ -f "version.txt" ]; then
    CURRENT=$(cat version.txt)
elif [ -f "package.json" ]; then
    CURRENT=$(node -p "require('./package.json').version" 2>/dev/null || echo "0.1.0")
else
    CURRENT="0.1.0"
fi

# Remove 'v' prefix if present
CURRENT="${CURRENT#v}"

# Split into components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# Increment based on type
case "$TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Error: Unknown version type: $TYPE" >&2
        echo "Usage: $0 [major|minor|patch]" >&2
        exit 1
        ;;
esac

echo "v${MAJOR}.${MINOR}.${PATCH}"
