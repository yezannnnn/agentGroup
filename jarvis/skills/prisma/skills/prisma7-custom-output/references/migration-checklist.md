# Prisma 7 Custom Output Migration Checklist

Use this checklist when migrating a project from `prisma-client-js` to `prisma-client`.

## Pre-Migration

- [ ] Confirm Prisma version is 7.x (`bunx prisma --version`)
- [ ] Confirm Node.js 20.19+ and TypeScript 5.4+
- [ ] Confirm `prisma.config.ts` exists at project root
- [ ] Identify all files importing from `@prisma/client`:
  ```bash
  grep -rn "from '@prisma/client'" . --include='*.ts' --include='*.tsx'
  ```
- [ ] Identify nested `.prisma` directories:
  ```bash
  find . -path '*/node_modules/.prisma' -type d
  ```

## Migration

- [ ] Update `prisma/schema.prisma` generator block:
  - Change `provider` from `"prisma-client-js"` to `"prisma-client"`
  - Add `output` directive (path relative to schema file)
- [ ] Update `.gitignore` with new generated output path
- [ ] Run `bunx prisma generate` — verify output at configured path
- [ ] Update DB package `client.ts` — import `PrismaClient` from generated path
- [ ] Update DB package `index.ts` — re-export from generated path
- [ ] Keep `@prisma/client` in DB package `package.json` (needed for runtime engine)
- [ ] Update seed files — import from generated path or DB package
- [ ] Update CLI scripts — import from generated path or DB package
- [ ] Simplify `postinstall` — remove nested `.prisma` cleanup workarounds
- [ ] Run `bun install` to update lockfile

## Post-Migration Verification

- [ ] `bunx prisma generate` succeeds with new output path
- [ ] `bunx tsc --noEmit` passes (no type errors)
- [ ] `bunx vitest run` passes (all tests green)
- [ ] `bun run lint` passes (no lint errors)
- [ ] No remaining `@prisma/client` imports in packages/apps:
  ```bash
  grep -rn "from '@prisma/client'" packages/ apps/
  # Expected: no matches
  ```
- [ ] Seed script works: `bunx prisma db seed`
- [ ] Vercel preview build succeeds (push to branch and check)

## Rollback

If the migration fails:

1. Revert commits: `git revert HEAD~N..HEAD` (N = number of migration commits)
2. Reinstall: `bun install && bunx prisma generate`
3. Push to trigger clean build

The old `prisma-client-js` provider remains supported as a backwards-compat alias.
