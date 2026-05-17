#!/bin/bash
# update-changelog.sh — Update CHANGELOG.md with new version entry
#
# Usage:
#   ./scripts/update-changelog.sh <version> [--added "item1" "--changed" "item2" ...]
#
# Example:
#   ./scripts/update-changelog.sh v1.2.0 \
#       --added "New feature" \
#       --fixed "Bug fix"
#
# This prepends a new version entry to docs/releases/CHANGELOG.md

set -e

VERSION="$1"
shift

if [ -z "$VERSION" ]; then
    echo "Error: Version is required" >&2
    echo "Usage: $0 <version> [--added \"item\"] [--changed \"item\"] [--fixed \"item\"]" >&2
    exit 1
fi

CHANGELOG="docs/releases/CHANGELOG.md"

# Ensure changelog exists
if [ ! -f "$CHANGELOG" ]; then
    cat > "$CHANGELOG" << 'HEADER'
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
### Changed
### Fixed

---
HEADER
fi

# Parse arguments
ADDED=""
CHANGED=""
FIXED=""
REMOVED=""
DEPRECATED=""

while [ $# -gt 0 ]; do
    case "$1" in
        --added)
            ADDED="${ADDED}- $2\n"
            shift 2
            ;;
        --changed)
            CHANGED="${CHANGED}- $2\n"
            shift 2
            ;;
        --fixed)
            FIXED="${FIXED}- $2\n"
            shift 2
            ;;
        --removed)
            REMOVED="${REMOVED}- $2\n"
            shift 2
            ;;
        --deprecated)
            DEPRECATED="${DEPRECATED}- $2\n"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            shift
            ;;
    esac
done

# Create new entry
NEW_ENTRY="## [${VERSION}] - $(date -u +%Y-%m-%d)

"

if [ -n "$ADDED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Added
$(printf "$ADDED")
"
fi

if [ -n "$CHANGED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Changed
$(printf "$CHANGED")
"
fi

if [ -n "$FIXED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Fixed
$(printf "$FIXED")
"
fi

if [ -n "$REMOVED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Removed
$(printf "$REMOVED")
"
fi

if [ -n "$DEPRECATED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Deprecated
$(printf "$DEPRECATED")
"
fi

# Create temp file with new entry
TEMP_FILE=$(mktemp)
echo -e "$NEW_ENTRY" > "$TEMP_FILE"

# Add separator and existing content (skip first 3 lines which are header)
tail -n +4 "$CHANGELOG" >> "$TEMP_FILE"

# Replace changelog
mv "$TEMP_FILE" "$CHANGELOG"

echo "Updated: $CHANGELOG with entry for $VERSION"
