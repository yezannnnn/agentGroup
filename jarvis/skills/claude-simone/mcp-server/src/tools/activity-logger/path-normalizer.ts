import { relative, isAbsolute, resolve } from 'path';

export function normalizeFilePath(filePath: string, projectRoot: string): string {
  const cleanPath = filePath.trim();
  
  if (isAbsolute(cleanPath)) {
    // Convert absolute path to relative
    return relative(projectRoot, cleanPath);
  }
  
  // Handle paths that start with ./ or ../
  if (cleanPath.startsWith('./') || cleanPath.startsWith('../')) {
    const absolutePath = resolve(projectRoot, cleanPath);
    return relative(projectRoot, absolutePath);
  }
  
  // Assume it's already relative to project root
  return cleanPath;
}