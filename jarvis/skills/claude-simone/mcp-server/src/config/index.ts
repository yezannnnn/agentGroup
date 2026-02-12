/**
 * @module Config
 * @description Central configuration module for the Simone MCP server.
 * Provides environment configuration and project configuration loading.
 */

export * from './types.js';
export * from './loader.js';

/**
 * Environment configuration interface
 */
export interface EnvConfig {
  projectPath: string;
}

/**
 * Get environment configuration from process environment variables
 * @returns {EnvConfig} The environment configuration
 * @throws {Error} If required environment variables are missing
 */
export function getEnvConfig(): EnvConfig {
  const projectPath = process.env['PROJECT_PATH'];
  
  if (!projectPath) {
    throw new Error('PROJECT_PATH environment variable is required. Please check your .mcp.json configuration.');
  }
  
  return {
    projectPath,
  };
}