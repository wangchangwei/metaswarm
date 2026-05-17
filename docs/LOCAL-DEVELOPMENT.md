# Local Development Setup Guide

This guide explains how to set up metaswarm as a **local development plugin** in Claude Code, so that changes you make to the metaswarm source code take effect immediately without needing to reinstall from the marketplace.

## Why Local Development?

When developing or customizing metaswarm, you want your code changes to be reflected immediately in your Claude Code session. Installing via the marketplace gives you a static snapshot — this guide creates a symlink-based setup that keeps your development version live.

## Prerequisites

- Claude Code installed (`claude` CLI available in PATH)
- metaswarm source code cloned locally (e.g., `/Users/luyan/metaswarm`)

## Step-by-Step Setup

### 1. Create Marketplace Cache Structure

```bash
mkdir -p ~/.claude/plugins/cache/metaswarm-marketplace/metaswarm
ln -sfn /PATH/TO/METASWARM ~/.claude/plugins/cache/metaswarm-marketplace/metaswarm/0.11.0
```

Replace `/PATH/TO/METASWARM` with your actual metaswarm clone path.

### 2. Create marketplace.json in Local Project

The marketplace manifest must be at the root of your metaswarm clone:

```json
{
    "name": "metaswarm-marketplace",
    "description": "Multi-agent orchestration framework for Claude Code, Gemini CLI, and Codex CLI",
    "owner": {
        "name": "David Sifry",
        "url": "https://github.com/dsifry"
    },
    "plugins": [
        {
            "name": "metaswarm",
            "description": "Multi-agent orchestration framework",
            "version": "0.11.0",
            "source": "./.claude-plugin/",
            "author": {
                "name": "David Sifry",
                "url": "https://github.com/dsifry"
            }
        }
    ]
}
```

**Important**: The `source` field must point to `"./.claude-plugin/"` because metaswarm's `plugin.json` lives inside that subdirectory, not at the project root.

### 3. Create marketplace.json in Cache

The plugin loader looks for `marketplace.json` at a specific nested path. Create a symlink:

```bash
mkdir -p ~/.claude/plugins/cache/metaswarm-marketplace/metaswarm/0.11.0/.claude-plugin
ln -s /PATH/TO/METASWARM/marketplace.json \
   ~/.claude/plugins/cache/metaswarm-marketplace/metaswarm/0.11.0/.claude-plugin/marketplace.json
```

### 4. Register the Marketplace

Add the marketplace to `~/.claude/plugins/known_marketplaces.json`:

```json
"metaswarm-marketplace": {
    "source": {
        "source": "local",
        "path": "/PATH/TO/METASWARM"
    },
    "installLocation": "/Users/luyan/.claude/plugins/marketplaces/metaswarm-marketplace",
    "lastUpdated": "2026-05-17T00:00:00.000Z"
}
```

The `installLocation` must be a symlink to your local project:

```bash
ln -sfn /PATH/TO/METASWARM ~/.claude/plugins/marketplaces/metaswarm-marketplace
```

### 5. Register the Plugin

Add the plugin to `~/.claude/plugins/installed_plugins.json`:

```json
"metaswarm@metaswarm-marketplace": [
    {
        "scope": "user",
        "installPath": "/Users/luyan/.claude/plugins/cache/metaswarm-marketplace/metaswarm/0.11.0",
        "version": "0.11.0",
        "installedAt": "2026-05-17T00:00:00.000Z",
        "lastUpdated": "2026-05-17T00:00:00.000Z",
        "gitCommitSha": "local-dev-link"
    }
]
```

### 6. Enable the Plugin

```bash
claude plugin enable metaswarm@metaswarm-marketplace
```

### 7. Verify

```bash
claude plugins list
```

You should see:

```
metaswarm@metaswarm-marketplace
  Version: 0.11.0
  Scope: user
  Status: ✔ enabled
```

## Key Files Modified

| File | Purpose |
|------|---------|
| `~/.claude/plugins/known_marketplaces.json` | Registers the `metaswarm-marketplace` name |
| `~/.claude/plugins/installed_plugins.json` | Registers the `metaswarm@metaswarm-marketplace` plugin |
| `~/.claude/settings.json` | Enables the plugin in `enabledPlugins` |
| `metaswarm/marketplace.json` | Marketplace manifest (created by you) |

## Directory Structure

```
~/.claude/plugins/
├── cache/
│   └── metaswarm-marketplace/
│       └── metaswarm/
│           └── 0.11.0/                   ← symlink → /PATH/TO/METASWARM
│               └── .claude-plugin/
│                   └── marketplace.json  ← symlink → /PATH/TO/METASWARM/marketplace.json
├── marketplaces/
│   └── metaswarm-marketplace/            ← symlink → /PATH/TO/METASWARM
└── known_marketplaces.json
```

## Troubleshooting

### "Plugin metaswarm not found in marketplace metaswarm-marketplace"

The `marketplace.json` is not in the right location. The plugin loader expects it at:
```
cache/metaswarm-marketplace/metaswarm/0.11.0/.claude-plugin/marketplace.json
```

Verify with:
```bash
find ~/.claude/plugins/cache/metaswarm-marketplace -name "marketplace.json"
```

### "source" field points to wrong location

If you see `plugin.json` not found errors, the `source` in `marketplace.json` may be wrong. For metaswarm:
- `plugin.json` is at `.claude-plugin/plugin.json`
- So `source` must be `"./.claude-plugin/"` (not `"./"`)

## Updating Version Number

When you want to track a different version of your local metaswarm, update the symlink target:

```bash
rm ~/.claude/plugins/cache/metaswarm-marketplace/metaswarm/0.11.0
ln -sfn /PATH/TO/METASWARM ~/.claude/plugins/cache/metaswarm-marketplace/metaswarm/0.11.0
```

Also update the `version` field in:
1. `metaswarm/marketplace.json`
2. `~/.claude/plugins/installed_plugins.json`

## Disabling the Local Plugin

```bash
claude plugin disable metaswarm@metaswarm-marketplace
```

To fully remove, delete the entries from `known_marketplaces.json`, `installed_plugins.json`, and remove the `metaswarm-marketplace` entries from `enabledPlugins` in `settings.json`.

## Commands in Claude Code

After installation, metaswarm commands are available as short slash commands:

| Command | Purpose |
|---------|---------|
| `/start-task` | Begin tracked work |
| `/setup` | Interactive project setup |
| `/review-design` | Trigger design review gate |
| `/pr-shepherd <pr>` | Monitor PR through merge |
| `/status` | Diagnostic checks |

Note: The `metaswarm:` prefix format (e.g., `/metaswarm:start-task`) is used in **Gemini CLI**, not Claude Code. In Claude Code, use the short command names directly.
