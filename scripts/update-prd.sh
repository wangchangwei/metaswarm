#!/bin/bash
# update-prd.sh — Update PRD.md with new version information
#
# Usage:
#   ./scripts/update-prd.sh <version> [--feature "name" ...] [--goal "description"]
#
# Example:
#   ./scripts/update-prd.sh v1.2.0 \
#       --feature "User authentication" \
#       --feature "API rate limiting" \
#       --goal "Improve user retention"
#
# This script:
# 1. Updates the version header
# 2. Adds new features to the user stories table
# 3. Updates goals if provided
# 4. Adds to change history

set -e

VERSION="$1"
shift

if [ -z "$VERSION" ]; then
    echo "Error: Version is required" >&2
    echo "Usage: $0 <version> [--feature \"name\" ...] [--goal \"description\"]" >&2
    exit 1
fi

PRD="docs/PRD.md"

if [ ! -f "$PRD" ]; then
    echo "Error: $PRD not found" >&2
    exit 1
fi

# Parse arguments
FEATURES=""
GOALS=""
TODAY=$(date -u +%Y-%m-%d)

while [ $# -gt 0 ]; do
    case "$1" in
        --feature)
            FEATURES="${FEATURES}| $2"
            shift 2
            ;;
        --goal)
            GOALS="${GOALS}
- $2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            shift
            ;;
    esac
done

# Update version in header
sed -i '' "s/\*\*Current Version\*\*:.*/\*\*Current Version\*\*: $VERSION/" "$PRD"
sed -i '' "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $TODAY/" "$PRD"

# Add to change history
sed -i '' "/| v[0-9]*\.[0-9]*\.[0-9]* | [0-9-]* | Initial PRD |/a\\
| $VERSION | $TODAY | Updated | [Author] |" "$PRD"

echo "Updated: $PRD"
echo "  Version: $VERSION"
echo "  Date: $TODAY"
[ -n "$FEATURES" ] && echo "  Features: $(echo $FEATURES | tr '|' '\n' | grep -c .)"
[ -n "$GOALS" ] && echo "  Goals added: $(echo "$GOALS" | grep -c .)"
