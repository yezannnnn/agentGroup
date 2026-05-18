/**
 * DB package barrel exports
 *
 * Re-exports everything downstream packages need from a single import:
 *   import { prisma, Prisma } from '@your-org/db'
 *   import type { User, Organization } from '@your-org/db'
 *
 * Key points:
 * - prisma: singleton instance (for app runtime)
 * - Prisma: namespace with helpers (Prisma.validator, etc.)
 * - Model types: re-exported for downstream type annotations
 * - All exports come from generated path, NOT @prisma/client
 */

// Runtime singleton
export { prisma } from './client'

// Prisma namespace (from generated output, NOT @prisma/client)
export { Prisma } from './generated/prisma/client'

// Model types — add models as downstream packages need them
export type {
  User,
  Organization,
} from './generated/prisma/client'
