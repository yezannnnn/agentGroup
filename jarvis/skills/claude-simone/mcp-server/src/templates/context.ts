import { basename } from 'path';
import type { TemplateContext } from '../types/prompt.js';

export function buildTemplateContext(
  projectPath: string,
  args: Record<string, any> = {}
): TemplateContext {
  // Get project name from path
  const projectName = basename(projectPath);
  
  // Create date/time information
  const now = new Date();
  const timestamp = now.toISOString();
  const currentDate = now.toLocaleDateString();
  const currentTime = now.toLocaleTimeString();
  
  return {
    PROJECT_PATH: projectPath,
    PROJECT_NAME: projectName,
    TIMESTAMP: timestamp,
    CURRENT_DATE: currentDate,
    CURRENT_TIME: currentTime,
    ...args, // Merge in any user arguments
  };
}