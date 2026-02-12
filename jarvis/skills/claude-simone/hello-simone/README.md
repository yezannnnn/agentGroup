# hello-simone

Installer for Simone - AI-powered project management system.

## Installation

```bash
npx hello-simone
```

## Options

### MCP Version (Recommended)

Install the new Model Context Protocol version:

```bash
npx hello-simone --mcp
```

This will:

- Configure your project's `.mcp.json`
- Create `.simone/config.yaml` template
- Provide setup instructions for Claude Desktop

### Legacy Version

Install the original directory-based version:

```bash
npx hello-simone --legacy
# or just
npx hello-simone
```

## MCP Early Preview Notice

The MCP version is in early preview:

- No import process from legacy Simone yet
- Best tested on non-critical projects
- Please report issues on GitHub or contact @helmi on Discord

## Requirements

### MCP Version

- GitHub CLI (`gh`) or GitHub MCP server
- Node.js >= 18.0.0
- Git repository (required)

## Cross-Platform Compatibility

The installer automatically detects your project directory and configures it correctly for all platforms:

- ✅ **Windows** (CMD, PowerShell, Git Bash)
- ✅ **macOS**
- ✅ **Linux**
- ✅ **WSL** (Windows Subsystem for Linux)

## After Installation

For MCP version:

1. Fill in `.simone/config.yaml` with your project details
2. Restart Claude Desktop
3. Run `/hello_simone` in Claude to verify configuration

For legacy version:

- Check the `.simone/` directory in your project
- See the legacy documentation for usage

## License

MIT
