import { promises as fs } from 'fs';
import { join, dirname } from 'path';

let errorLogPath: string | null = null;
let debugLogPath: string | null = null;

/**
 * Initialize the logger with the project path
 */
export function initializeLogger(projectPath: string): void {
  errorLogPath = join(projectPath, '.simone', 'logs', 'mcp-server.error.log');
  debugLogPath = join(projectPath, '.simone', 'logs', 'mcp-server.debug.log');
}

/**
 * Log an error to the error log file
 */
export async function logError(error: Error | string): Promise<void> {
  if (!errorLogPath) {
    return; // Logger not initialized, silently skip
  }

  try {
    const timestamp = new Date().toISOString();
    const message = error instanceof Error 
      ? `${error.message}\n${error.stack || ''}`
      : error;
    
    const logEntry = `[${timestamp}] ERROR: ${message}\n\n`;
    
    // Ensure log directory exists
    await fs.mkdir(dirname(errorLogPath), { recursive: true });
    
    // Append to log file
    await fs.appendFile(errorLogPath, logEntry, 'utf8');
  } catch {
    // Silently fail if logging fails - we don't want to crash the server
  }
}

/**
 * Log debug information to the debug log file
 */
export async function logDebug(message: string): Promise<void> {
  if (!debugLogPath) {
    return; // Logger not initialized, silently skip
  }

  try {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] DEBUG: ${message}\n`;
    
    // Ensure log directory exists
    await fs.mkdir(dirname(debugLogPath), { recursive: true });
    
    // Append to log file
    await fs.appendFile(debugLogPath, logEntry, 'utf8');
  } catch {
    // Silently fail if logging fails - we don't want to crash the server
  }
}