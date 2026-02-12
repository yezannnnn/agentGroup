# Versioning Strategy

This repository contains three distinct components, each with its own versioning. Current versions are tracked in `versions.json`.

## Components

1. **Legacy Simone** (`./legacy`)
   - Type: Git tags only
   - Tag format: `legacy/vX.Y.Z`
   - The original directory-based command system

2. **hello-simone** (`./hello-simone`)
   - Type: NPM package
   - Tag format: `hello/vX.Y.Z`
   - NPM installer for Simone (supports both MCP and legacy)

3. **MCP Server** (`./mcp-server`)
   - Type: NPM package (simone-mcp)
   - Tag format: `mcp/vX.Y.Z`
   - Model Context Protocol implementation

## Version Management

### Central Version Tracking

All component versions are tracked in `versions.json` at the repository root. This serves as the single source of truth for version information.

### Version Manager Script

Use the version manager script to work with versions:

```bash
# List all component versions and their tag status
node scripts/version-manager.js list

# Create a git tag for a component
node scripts/version-manager.js tag mcp-server

# Sync versions.json with package.json files
node scripts/version-manager.js sync

# Migrate old tags to new naming scheme
node scripts/version-manager.js migrate-tags
```

### Release Process

#### For NPM Packages (MCP Server, hello-simone)

1. Update version in the component's `package.json`:

   ```bash
   cd mcp-server
   npm version patch  # or minor, major
   ```

2. Sync the central version file:

   ```bash
   node scripts/version-manager.js sync
   ```

3. Commit changes:

   ```bash
   git add .
   git commit -m "chore(mcp): bump version to x.y.z"
   ```

4. Create and push tag:

   ```bash
   node scripts/version-manager.js tag mcp-server
   git push origin mcp/vx.y.z
   ```

5. GitHub Actions will automatically publish to NPM

#### For Legacy Simone

1. Update version in `versions.json` manually
2. Update `legacy/CHANGELOG.md`
3. Commit changes
4. Create tag:

   ```bash
   node scripts/version-manager.js tag legacy
   git push origin legacy/vx.y.z
   ```

## GitHub Releases

Create GitHub releases using the appropriate tag:

- **Legacy**: Use `legacy/vX.Y.Z` tags
- **MCP Server**: Use `mcp/vX.Y.Z` tags
- **hello-simone**: Use `hello/vX.Y.Z` tags

Include component-specific changelogs and assets in each release.

## NPM Publishing

NPM packages are automatically published when tags are pushed:

- `mcp/v*` tags trigger publishing of `simone-mcp`
- `hello/v*` tags trigger publishing of `hello-simone`

**Required Secret**: Set `NPM_TOKEN` in GitHub repository secrets
