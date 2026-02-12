/**
 * @module Templates
 * @description Central initialization and exports for the templating system.
 * Manages Handlebars template loading, compilation, and rendering for the MCP server.
 */

import { PromptHandler } from './handler.js';

export { PromptHandler } from './handler.js';
export { TemplateLoader } from './loader.js';
export { buildTemplateContext } from './context.js';
export * from './helpers/index.js';

/**
 * Initialize the templating system for a project
 * @param {string} projectPath - The path to the project
 * @returns {PromptHandler} An initialized prompt handler instance
 */
export function initializeTemplating(projectPath: string): PromptHandler {
  return new PromptHandler(projectPath);
}