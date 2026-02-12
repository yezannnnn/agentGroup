import { vi } from 'vitest';
import * as path from 'path';
import * as os from 'os';

// Use system temp directory for better isolation
export const TEST_PROJECT_PATH = path.join(os.tmpdir(), 'simone-test-' + Date.now());
export const TEST_CONFIG_PATH = path.join(TEST_PROJECT_PATH, '.simone', 'project.yaml');

export function createTestEnv(overrides: Record<string, string> = {}) {
  return {
    PROJECT_PATH: TEST_PROJECT_PATH,
    NODE_ENV: 'test',
    ...overrides,
  };
}

export function createSafeTestEnv(overrides: Record<string, string> = {}) {
  // Store original env for restoration
  const originalEnv = { ...process.env };
  
  // Create test environment
  const testEnv = {
    PROJECT_PATH: TEST_PROJECT_PATH,
    NODE_ENV: 'test',
    ...overrides,
  };
  
  // Apply test env
  Object.assign(process.env, testEnv);
  
  // Return restore function
  return {
    restore: () => {
      process.env = originalEnv;
    }
  };
}

export function waitFor(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

export async function waitForCondition(
  condition: () => boolean | Promise<boolean>,
  timeout = 5000,
  interval = 100
): Promise<void> {
  const start = Date.now();
  
  while (Date.now() - start < timeout) {
    if (await condition()) {
      return;
    }
    await waitFor(interval);
  }
  
  throw new Error(`Condition not met within ${timeout}ms`);
}

export function createTestLogger() {
  return {
    info: vi.fn(),
    error: vi.fn(),
    warn: vi.fn(),
    debug: vi.fn(),
  };
}

export function expectToThrowAsync(fn: () => Promise<any>, errorMessage?: string) {
  return expect(fn()).rejects.toThrow(errorMessage);
}