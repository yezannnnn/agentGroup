---
name: prisma7-custom-output
description: >-
  This skill should be used when the user asks to "migrate Prisma to custom output",
  "fix Prisma monorepo hoisting", "upgrade prisma-client-js to prisma-client",
  "move Prisma out of node_modules", or encounters "stale Prisma types after deploy",
  "prisma-client-js deprecated", or build failures where PrismaClient types are
  missing models in a Turborepo/monorepo. Guides the migration from deprecated
  prisma-client-js (node_modules output) to prisma-client (custom output directory)
  in Prisma 7.
---

# Prisma 7 Custom Output Migration

Migrate a Prisma 7 project from the deprecated `prisma-client-js` generator (which outputs to `node_modules/.prisma/client/`) to the `prisma-client` generator with a custom output directory. This eliminates an entire class of monorepo bugs caused by stale nested `node_modules` copies.

**Citations:**
- [Prisma v7 Turborepo guide](https://github.com/prisma/docs/blob/main/content/900-ai/prompts/turborepo.mdx)
- [Prisma v7 upgrade guide](https://www.prisma.io/docs/orm/more/upgrade-guides/upgrading-versions/upgrading-to-prisma-7)
- [Prisma generators reference](https://www.prisma.io/docs/orm/prisma-schema/overview/generators)

## Why This Migration Matters

With `prisma-client-js`, the generated client lives in `node_modules/.prisma/client/`. In monorepos, this causes:

1. **Hoisting bugs** — package managers may create nested `node_modules/@prisma/client/` copies in workspace packages that declare `@prisma/client` as a dependency. `prisma generate` writes to root, but TypeScript resolves through the nested copy.
2. **Stale build caches** — CI/CD (especially Vercel) caches `node_modules` between deploys. After schema changes or Prisma upgrades, the cached nested copies contain stale types.
3. **Phantom type errors** — `Property 'X' does not exist on type 'PrismaClient'` when the model IS in the schema.

With `prisma-client`, the generated client lives in a directory controlled by the project (e.g., `packages/db/src/generated/prisma/`). No `node_modules` resolution games.

## Detection: Is This Migration Needed?

Check the schema file for the deprecated pattern:

```prisma
# DEPRECATED — needs migration
generator client {
  provider = "prisma-client-js"
  # no output directive — defaults to node_modules
}
```

Check for nested `.prisma` directories:

```bash
find packages -path '*/node_modules/.prisma' -type d
```

If either is true, proceed with migration.

## Migration Steps

### 1. Update Schema Generator

Change the generator block in the schema file (usually `prisma/schema.prisma`):

```prisma
generator client {
  provider = "prisma-client"
  output   = "<relative-path-to-output>"
}
```

The `output` path is **relative to the schema file**. Common patterns:

| Schema location | DB package location | Output value |
|----------------|--------------------|----|
| `prisma/schema.prisma` | `packages/db/src/` | `"../packages/db/src/generated/prisma"` |
| `packages/db/prisma/schema.prisma` | `packages/db/src/` | `"../src/generated/prisma"` |
| `schema.prisma` (root) | `src/` | `"./src/generated/prisma"` |

### 2. Update `.gitignore`

Add the new generated output directory and remove the old `node_modules`-based entry:

```gitignore
# Prisma generated client (output of `prisma generate`)
<path-to-generated-dir>
```

### 3. Run `prisma generate`

```bash
bunx prisma generate   # or npx/pnpm exec
```

Verify output appears at the configured path.

### 4. Update DB Package Imports

Change all imports in the database package from `@prisma/client` to the generated path:

```typescript
// Before
import { PrismaClient } from '@prisma/client'
import { Prisma } from '@prisma/client'

// After
import { PrismaClient } from './generated/prisma/client'
import { Prisma } from './generated/prisma/client'
```

### 5. Update DB Package Exports

The database package barrel (`index.ts`) should re-export everything downstream needs:

```typescript
export { prisma } from './client'
export { Prisma, PrismaClient } from './generated/prisma/client'
export type { YourModel, YourEnum } from './generated/prisma/client'
```

Re-exporting `PrismaClient` allows seed files and CLI scripts to construct their own instances when needed.

### 6. Keep `@prisma/client` as a Runtime Dependency

**Do NOT remove `@prisma/client` from dependencies.** The generated client internally imports `@prisma/client/runtime/client` for the Prisma runtime engine. What changes is that **your code** no longer imports `PrismaClient` or types from `@prisma/client` — you import from the generated path instead. But the package itself must remain installed.

```json
{
  "dependencies": {
    "@prisma/adapter-pg": "^7.4.0",
    "@prisma/client": "^7.4.0",
    "pg": "^8.17.1"
  }
}
```

**Why it works locally without it:** Bun/npm/pnpm hoist `@prisma/client` to root `node_modules` (transitively via `prisma` CLI). But CI's Vite import analysis resolves from the package directory context, where it may not be found if not declared as a direct dependency.

### 7. Update Seed Files and CLI Scripts

Files that construct their own `PrismaClient` (seeds, scripts) need updated imports:

```typescript
// Before
import { PrismaClient } from '@prisma/client'

// After — use relative path to generated dir
import { PrismaClient } from '../../packages/db/src/generated/prisma/client'

// Or import through the DB package (if it re-exports PrismaClient)
import { PrismaClient } from '@baptize/db'
```

### 8. Clean Up Postinstall

If the project had workarounds for nested `.prisma` cleanup, remove them. The postinstall only needs:

```json
"postinstall": "DATABASE_URL=${DATABASE_URL:-placeholder} prisma generate || true"
```

### 9. Verify

```bash
# Regenerate from scratch
rm -rf <generated-output-dir>
bunx prisma generate

# Type check
bunx tsc --noEmit

# Tests
bunx vitest run

# Confirm no stale imports
grep -rn "from '@prisma/client'" packages/ apps/ src/
```

## Common Pitfalls

### Vercel Build Command

Vercel's build command should still run `prisma generate` — it writes to the source tree, not `node_modules`, so caching issues are eliminated:

```bash
cd ../.. && DATABASE_URL=placeholder bunx prisma generate && bunx turbo build
```

### Driver Adapter Import

`@prisma/adapter-pg` (and other adapters) remain as regular npm dependencies — only `@prisma/client` is removed. The adapter is imported normally:

```typescript
import { PrismaPg } from '@prisma/adapter-pg'
```

### Type Re-exports

When re-exporting model types from the DB package, use `export type` for types and `export` for runtime values:

```typescript
// Runtime values
export { prisma } from './client'
export { Prisma, PrismaClient } from './generated/prisma/client'

// Type-only exports
export type { User, Organization } from './generated/prisma/client'
```

### Workflow Files (Vercel Workflows)

`'use step'` functions that dynamically import `@baptize/db` work unchanged — the import resolves through the workspace package, which now internally uses the generated path:

```typescript
'use step'
const { prisma } = await import('@baptize/db')  // no change needed
```

## Additional Resources

### Reference Files

- **`references/migration-checklist.md`** — Step-by-step checklist with verification commands
- **`references/troubleshooting.md`** — Common errors and fixes during migration

### Example Files

- **`examples/schema-generator.prisma`** — Correct generator block examples
- **`examples/db-package-index.ts`** — Barrel exports from generated path

The singleton client pattern (with lazy proxy and PrismaPg adapter) is documented inline in Step 4 above. The only import change is `PrismaClient` from the generated path instead of `@prisma/client`.
