# prisma-skills

Prisma 7 migration and best practices skills for Claude Code.

## Skills

| Skill | Description |
|-------|-------------|
| `prisma7-custom-output` | Migrate from deprecated `prisma-client-js` to `prisma-client` with custom output directory |

## Installation

### Via Plugin Marketplace

```
/plugin marketplace add pwarnock/pwarnock-cc-plugins
/plugin install prisma-skills@pwarnock-cc-plugins
```

### Direct Install

```
/plugin add pwarnock/prisma-skills
```

## What's Included

### prisma7-custom-output

Guides the migration from the deprecated `prisma-client-js` generator (which outputs to `node_modules/.prisma/client/`) to the Prisma 7 `prisma-client` generator with a custom output directory. This eliminates monorepo hoisting bugs caused by stale nested `node_modules` copies on Vercel and other CI/CD platforms.

**Triggers on:** "migrate Prisma to custom output", "fix Prisma monorepo hoisting", "upgrade prisma-client-js to prisma-client", "move Prisma out of node_modules", stale Prisma types after deploy, build failures with missing PrismaClient models.

**Includes:**
- 9-step migration guide with code examples
- Migration checklist with verification commands
- Troubleshooting guide for 6 common error scenarios
- Schema generator examples (correct vs deprecated patterns)
- DB package barrel export template

## Requirements

- Prisma 7.x
- TypeScript 5.4+
- Node.js 20.19+
