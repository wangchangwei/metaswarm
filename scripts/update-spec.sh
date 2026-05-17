#!/bin/bash
# update-spec.sh — Update SPEC.md with new version information
#
# Usage:
#   ./scripts/update-spec.sh <version> [--feature "name" ...]
#
# Example:
#   ./scripts/update-spec.sh v1.2.0 --feature "User authentication" --feature "API rate limiting"
#
# This script:
# 1. Updates the version header
# 2. Adds new features to the features table
# 3. Adds to recent changes table
# 4. Preserves all other content

set -e

VERSION="$1"
shift

if [ -z "$VERSION" ]; then
    echo "Error: Version is required" >&2
    echo "Usage: $0 <version> [--feature \"name\" ...]" >&2
    exit 1
fi

SPEC="docs/SPEC.md"

if [ ! -f "$SPEC" ]; then
    echo "Error: $SPEC not found" >&2
    exit 1
fi

# Parse features
FEATURES=""
while [ $# -gt 0 ]; do
    case "$1" in
        --feature)
            FEATURES="${FEATURES}| $2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            shift
            ;;
    esac
done

TODAY=$(date -u +%Y-%m-%d)

# Update version in header
sed -i '' "s/\*\*Current Version\*\*:.*/\*\*Current Version\*\*: $VERSION/" "$SPEC"
sed -i '' "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $TODAY/" "$SPEC"

# Add new features to the table (if any)
if [ -n "$FEATURES" ]; then
    # Find the features table and add new entries before the last |
    for feature in $FEATURES; do
        # Add feature row before the closing |
        sed -i '' "s/| \[Feature name\] | v1.0.0 | Active |/| ${feature#|} | $VERSION | Active |\n| [Feature name] | v1.0.0 | Active |/" "$SPEC"
    done
fi

# Add to recent changes table
sed -i '' "/| v[0-9]*\.[0-9]*\.[0-9]* | [0-9-]* | Initial release |/a\\
| $VERSION | $TODAY | Updated" "$SPEC"

echo "Updated: $SPEC"
echo "  Version: $VERSION"
echo "  Date: $TODAY"
[ -n "$FEATURES" ] && echo "  Features added: $(echo $FEATURES | tr '|' '\n' | wc -l)"
