import { promises as fs } from 'fs';
import path from 'path';

/**
 * Check if a file exists
 */
export async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

/**
 * Read JSON file safely
 */
export async function readJSON(filePath) {
  try {
    const content = await fs.readFile(filePath, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    return null;
  }
}

/**
 * Write JSON file with proper formatting
 */
export async function writeJSON(filePath, data) {
  await fs.writeFile(filePath, JSON.stringify(data, null, 2) + '\n', 'utf8');
}

/**
 * Get user home directory cross-platform
 */
export function getHomeDir() {
  return process.env.HOME || process.env.USERPROFILE || '';
}

/**
 * Get the current working directory
 * Returns the absolute path to the current directory
 */
export function getPlatformProjectPath() {
  return process.cwd();
}

/**
 * Check if running on Windows
 */
export function isWindows() {
  return process.platform === 'win32';
}