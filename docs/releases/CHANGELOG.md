# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

---

## [Version Format]

This changelog follows semantic versioning (semver):
- **MAJOR** version: Incompatible API changes
- **MINOR** version: New functionality (backward-compatible)
- **PATCH** version: Bug fixes (backward-compatible)

### Version Naming Convention

| Type | Format | Example |
|------|--------|---------|
| Full version | `v{MAJOR}.{MINOR}.{PATCH`} | `v1.2.3` |
| Minor version | `v{MAJOR}.{MINOR}.x` | `v1.2.x` |
| Major version | `v{MAJOR}.x.x` | `v1.x.x` |

---

## Adding New Entries

When adding a new version:

```markdown
## [{VERSION}] - {YYYY-MM-DD}

### Added
- New feature description

### Changed
- Change description

### Fixed
- Bug fix description

### Migration Notes (if needed)
- Any breaking changes or migration steps
```

---

## Related Documents

- Full version details: See `v{VERSION}.md` in this directory
- Plan document: See `../plans/v{VERSION}-plan.md`
- Design document: See `../designs/v{VERSION}-design.md`
