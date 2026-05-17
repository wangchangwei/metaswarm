# Version Management Guide

This document describes how versions are managed in this project.

## Version Number Format

We use [Semantic Versioning (semver)](https://semver.org/):

```
v{MAJOR}.{MINOR}.{PATCH}
```

| Component | Increment When |
|-----------|----------------|
| MAJOR | Breaking changes to API or architecture |
| MINOR | New features (backward-compatible) |
| PATCH | Bug fixes (backward-compatible) |

## Version Lifecycle

```
[Planning] → [Review] → [Approved] → [Implementation] → [Released]
     │            │            │              │              │
     ▼            ▼            ▼              ▼              ▼
  v{next}.0.0  docs/plans/  docs/designs/  .beads/plans/  docs/releases/
              v{version}    v{version}     active-plan    CHANGELOG.md
```

## Document Version Mapping

| Document | Location | Example | Notes |
|----------|----------|---------|-------|
| **PRD (Business)** | `docs/PRD.md` | — | **Always updated** after each release |
| **SPEC (Technical)** | `docs/SPEC.md` | — | **Always updated** after each release |
| Plan Document | `docs/plans/v{VERSION}-plan.md` | `docs/plans/v1.2.0-plan.md` | Historical snapshot |
| Design Document | `docs/designs/v{VERSION}-design.md` | `docs/designs/v1.2.0-design.md` | Historical snapshot |
| Version Detail | `docs/releases/v{VERSION}.md` | `docs/releases/v1.2.0.md` | Historical snapshot |
| Changelog | `docs/releases/CHANGELOG.md` | — | Append-only, cumulative |

## Version Number Management

### Getting Current Version

```bash
# Read from version file
cat version.txt

# Or from package.json
node -p "require('./package.json').version"
```

### Incrementing Version

```bash
# Major (breaking changes)
./scripts/bump-version.sh major

# Minor (new features)
./scripts/bump-version.sh minor

# Patch (bug fixes)
./scripts/bump-version.sh patch
```

### Pre-release Versions

```
v1.0.0-alpha    # Alpha release
v1.0.0-beta     # Beta release
v1.0.0-rc.1     # Release candidate
```

## Workflow

### 1. Planning Phase

When starting a new feature/change:
1. Determine target version (based on change type)
2. Create plan document: `docs/plans/v{NEXT_VERSION}-plan.md`
3. Version is tentative until implementation

### 2. Review Phase

1. Plan Review Gate validates the plan
2. Design Review Gate validates the design
3. Approved documents are copied to versioned locations

### 3. Implementation Phase

1. Implementation follows the approved plan
2. Plan persisted to `.beads/plans/active-plan.md`
3. All changes tracked with version tag

### 4. Release Phase

1. PR merged to main
2. Version bumped (if not already)
3. `docs/releases/v{VERSION}.md` created with release details
4. `docs/releases/CHANGELOG.md` updated
5. All versioned documents committed together

## Scripts

Located in `scripts/`:

| Script | Purpose |
|--------|---------|
| `next-version.sh` | Determine next version (major/minor/patch) |
| `bump-version.sh` | Increment version number |
| `create-version-doc.sh` | Create version detail document |
| `update-changelog.sh` | Update CHANGELOG.md |
| `update-prd.sh` | Update PRD.md (live business document) |
| `update-spec.sh` | Update SPEC.md (live technical document) |

## Integration with PR Shepherd

During PR merge, the PR Shepherd will:
1. Detect if version bump is needed
2. Prompt to create/update version documents
3. Ensure CHANGELOG is updated
4. Verify all version documents are committed
