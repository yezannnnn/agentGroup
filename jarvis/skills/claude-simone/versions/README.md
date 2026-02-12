# Version Management

This directory contains all version management tools and configuration for the Simone repository.

## Files

- `versions.json` - Central version tracking for all components
- `versions.schema.json` - JSON schema for versions.json validation
- `version-manager.js` - CLI tool for version management
- `VERSIONING.md` - Detailed versioning strategy documentation

## Quick Usage

From the repository root:

```bash
# List all component versions
npm run version:list

# Sync versions.json with package.json files
npm run version:sync

# Create tags for components
npm run tag:mcp      # Tag MCP server
npm run tag:hello    # Tag hello-simone
npm run tag:legacy   # Tag legacy Simone
```

## Components

1. **Legacy Simone** (`legacy/`) - Git tags only
2. **hello-simone** (`hello-simone/`) - NPM package
3. **MCP Server** (`mcp-server/`) - NPM package simone-mcp

See `VERSIONING.md` for the complete versioning strategy.
