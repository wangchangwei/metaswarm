#!/bin/bash
# create-version-doc.sh — Create version detail document
#
# Usage:
#   ./scripts/create-version-doc.sh <version> [plan-file] [design-file]
#
# Creates: docs/releases/v{VERSION}.md
#
# Example:
#   ./scripts/create-version-doc.sh v1.2.0 \
#       "docs/plans/v1.2.0-plan.md" \
#       "docs/designs/v1.2.0-design.md"

set -e

VERSION="${1:-$(./scripts/next-version.sh minor)}"
PLAN_FILE="${2:-docs/plans/v${VERSION#v}-plan.md}"
DESIGN_FILE="${3:-docs/designs/v${VERSION#v}-design.md}"

# Ensure docs/releases exists
mkdir -p docs/releases

# Check if plan and design files exist
PLAN_CONTENT=""
if [ -f "$PLAN_FILE" ]; then
    PLAN_CONTENT=$(cat "$PLAN_FILE")
fi

DESIGN_CONTENT=""
if [ -f "$DESIGN_FILE" ]; then
    DESIGN_CONTENT=$(cat "$DESIGN_FILE")
fi

# Create version document
cat > "docs/releases/${VERSION#v}.md" << VERSION_EOF
# Release — ${VERSION}

**Created**: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Overview

Brief description of this release.

## Changes

### Added
- New feature 1
- New feature 2

### Changed
- Change 1

### Fixed
- Fix 1

### Removed
- Removed feature (if any)

## Documentation

- Plan: ${PLAN_FILE}
- Design: ${DESIGN_FILE}

## Migration Notes

Any breaking changes or migration steps required.

## Related PRs

- List related pull requests

---

## Full Plan Document

${PLAN_CONTENT}

---

## Full Design Document

${DESIGN_CONTENT}
VERSION_EOF

echo "Created: docs/releases/${VERSION#v}.md"
