# Troubleshooting Prisma 7 Custom Output Migration

## Error: `Property 'X' does not exist on type 'PrismaClient'`

**Cause:** TypeScript is resolving `PrismaClient` from a stale or base type definition instead of the generated one.

**Diagnosis:**
```bash
# Check which @prisma/client TypeScript resolves
grep -rn "from '@prisma/client'" packages/ apps/

# Check for nested .prisma directories
find . -path '*/node_modules/.prisma' -type d

# Verify generated types include the model
grep 'YourModelName' packages/db/src/generated/prisma/client.ts
```

**Fix:**
1. Ensure NO imports from `@prisma/client` remain — all should use the generated path
2. Remove nested `.prisma` dirs: `find packages -path '*/node_modules/.prisma' -type d -exec rm -rf {} +`
3. Regenerate: `rm -rf packages/db/src/generated && bunx prisma generate`

---

## Error: `Cannot find module './generated/prisma/client'`

**Cause:** `prisma generate` hasn't been run, or the output path is wrong.

**Diagnosis:**
```bash
ls packages/db/src/generated/prisma/client.ts
```

**Fix:**
1. Run `bunx prisma generate`
2. Verify the `output` path in `schema.prisma` is correct (relative to the schema file)
3. Ensure `.gitignore` doesn't block the generated dir from being read (it should block git-tracking, not filesystem access)

---

## Error: `Failed to resolve import "@prisma/client/runtime/client"` (in CI/Vite)

**Cause:** `@prisma/client` was removed from the DB package's `package.json`, but the generated `client.ts` internally imports `@prisma/client/runtime/client` for the Prisma runtime engine. Locally this works because bun hoists the package from the root `node_modules`, but CI's Vite import analysis resolves from the package directory context.

**Diagnosis:**
```bash
# Check if @prisma/client is in the DB package's dependencies
grep '@prisma/client' packages/db/package.json
```

**Fix:** Add `@prisma/client` back as a dependency in the DB package. The package is needed for its runtime — you just don't import `PrismaClient` from it directly anymore.

```json
{
  "dependencies": {
    "@prisma/adapter-pg": "^7.4.0",
    "@prisma/client": "^7.4.0",
    "pg": "^8.17.1"
  }
}
```

---

## Vercel Build Fails After Migration

**Cause:** Build cache may have stale `node_modules` from before the migration.

**Diagnosis:** Check the Vercel build log for the specific error. Common issues:
- Old `@prisma/client` cached in `node_modules`
- `prisma generate` running before `bun install` completes

**Fix:**
1. Clear Vercel build cache: Vercel Dashboard → Project → Settings → General → Clear Build Cache
2. Trigger a new deploy
3. Ensure the build command runs `prisma generate` AFTER `bun install`:
   ```
   cd ../.. && bun install && bunx prisma generate && bunx turbo build
   ```

---

## Seed Files Fail With Import Errors

**Cause:** Seed files at `prisma/seed/*.ts` need a relative path to the generated client.

**Fix:** The relative path from `prisma/seed/` to the generated client depends on project structure:

```typescript
// From prisma/seed/*.ts → packages/db/src/generated/prisma/client
import { PrismaClient } from '../../packages/db/src/generated/prisma/client'
```

Alternatively, if the DB package re-exports `PrismaClient`, seed files can import from it (requires the workspace package to be resolvable).

---

## TypeScript `moduleResolution` Issues

**Cause:** The generated client uses ESM exports. TypeScript must be configured to resolve them.

**Fix:** Ensure `tsconfig.json` has compatible settings:
```json
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true
  }
}
```

The `"bundler"` resolution mode works with Prisma 7's ESM output. Avoid `"node"` (CJS-only) or `"node16"` (stricter ESM).
