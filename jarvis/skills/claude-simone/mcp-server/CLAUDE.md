# CLAUDE Instructions - MCP Server Development

## Overview

This is the MCP (Model Context Protocol) server implementation for Simone. This is a complete rewrite of the legacy directory-based command system.

## Tech Stack

- **Package Manager**: pnpm (v9.15.2)
- **Language**: TypeScript 5.8.3
- **MCP SDK**: @modelcontextprotocol/sdk (official)
- **Database**: SQLite with better-sqlite3
- **Testing**: Vitest + coverage-v8
- **Build**: tsup
- **Node.js**: >=20.0.0
- **Code Quality**: ESLint 9, Prettier, Husky, lint-staged, commitlint

## Project Structure

```plain
./mcp-server/
├── src/              # TypeScript source
│   ├── config/       # Configuration management
│   ├── templates/    # Handlebars templates and prompts
│   ├── tools/        # MCP tools (activity logger, etc.)
│   ├── types/        # TypeScript type definitions
│   └── utils/        # Utility functions
├── dist/             # Build output (gitignored)
├── coverage/         # Test coverage (gitignored)
├── package.json
├── tsconfig.json
├── vitest.config.ts
├── eslint.config.js
└── README.md
```

## Development Commands

```bash
pnpm dev              # Development mode with hot-reload
pnpm build            # Build for production
pnpm test             # Run tests
pnpm test:coverage    # Run tests with coverage
pnpm lint             # Lint code
pnpm format           # Format code with Prettier
pnpm typecheck        # Type checking
pnpm clean            # Clean build artifacts
```

## Development Standards

### Versioning (SemVer)

- Currently in pre-release (0.x.y) - stay here until API stabilizes
- **Patch bumps** (0.1.0 → 0.1.1): Do automatically after commits for bug fixes
- **Minor bumps** (0.1.0 → 0.2.0): Only with user confirmation for new features
- **Major bumps** (0.x.y → 1.0.0): Only with explicit user approval

### Commits

- Use conventional commits: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Commits are validated by commitlint
- Pre-commit hooks run linting and formatting

### Changelog

- Maintained in Keep a Changelog format
- Use `generate-changelog` prompt to create human-readable entries
- Categories: Added, Changed, Deprecated, Removed, Fixed, Security

### Release Process

1. Run appropriate release script: `pnpm release:patch/minor/major`
2. This will bump version and update changelog
3. Commit and push changes
4. Do NOT release without user approval for minor/major versions

## Architecture Notes

### MCP Server Design

- **Environment-based project context**: Project path passed via `PROJECT_PATH` env variable
- **Handlebars templating**: Hot-reloading prompt system with partials support
- **SQLite activity logging**: Persistent tracking of development activities
- **Modular prompts**: YAML-based prompt definitions with template inheritance

### Usage Pattern

When configured in a project's `.mcp.json`:

```json
{
  "mcpServers": {
    "simone": {
      "command": "npx",
      "args": ["simone-mcp"],
      "env": {
        "PROJECT_PATH": "/path/to/project"
      }
    }
  }
}
```

## Development Guidelines

1. **TypeScript strict mode** - All code must pass strict type checking
2. **Error handling** - Log errors to files, not console
3. **Testing** - Write tests for new features
4. **Documentation** - Update README and inline docs
5. **Performance** - Keep the server lightweight and fast

## Current Implementation Status

### Completed

- Basic MCP server with stdio transport
- Handlebars templating system with hot-reload
- Activity logging tool with SQLite backend
- GitHub integration prompts
- Development tooling setup

### In Progress

- Task source adapters (GitHub issues, markdown files)
- Project configuration system
- Additional MCP tools

### Planned

- Task management tools
- Project analytics
- Integration with more services
