import { describe, it, expect } from 'vitest';
import { normalizeFilePath } from './path-normalizer.js';
import * as path from 'path';

describe('normalizeFilePath', () => {
  const projectRoot = '/home/user/project';
  
  it('should convert absolute paths to relative', () => {
    expect(normalizeFilePath('/home/user/project/src/index.ts', projectRoot))
      .toBe('src/index.ts');
    
    expect(normalizeFilePath('/home/user/project/package.json', projectRoot))
      .toBe('package.json');
    
    expect(normalizeFilePath('/home/user/project/deeply/nested/file.ts', projectRoot))
      .toBe('deeply/nested/file.ts');
  });

  it('should handle absolute paths outside project root', () => {
    expect(normalizeFilePath('/home/user/other/file.ts', projectRoot))
      .toBe('../other/file.ts');
    
    expect(normalizeFilePath('/etc/config', projectRoot))
      .toBe('../../../etc/config');
  });

  it('should resolve relative paths starting with ./', () => {
    expect(normalizeFilePath('./src/index.ts', projectRoot))
      .toBe('src/index.ts');
    
    expect(normalizeFilePath('./package.json', projectRoot))
      .toBe('package.json');
    
    expect(normalizeFilePath('./deeply/nested/file.ts', projectRoot))
      .toBe('deeply/nested/file.ts');
  });

  it('should resolve relative paths starting with ../', () => {
    expect(normalizeFilePath('../project/src/index.ts', projectRoot))
      .toBe('src/index.ts');
    
    expect(normalizeFilePath('../../user/project/file.ts', projectRoot))
      .toBe('file.ts');
    
    expect(normalizeFilePath('../other/file.ts', projectRoot))
      .toBe('../other/file.ts');
  });

  it('should handle already relative paths', () => {
    expect(normalizeFilePath('src/index.ts', projectRoot))
      .toBe('src/index.ts');
    
    expect(normalizeFilePath('package.json', projectRoot))
      .toBe('package.json');
    
    expect(normalizeFilePath('deeply/nested/file.ts', projectRoot))
      .toBe('deeply/nested/file.ts');
  });

  it('should trim whitespace from paths', () => {
    expect(normalizeFilePath('  src/index.ts  ', projectRoot))
      .toBe('src/index.ts');
    
    expect(normalizeFilePath('\t./package.json\n', projectRoot))
      .toBe('package.json');
    
    expect(normalizeFilePath(' /home/user/project/file.ts ', projectRoot))
      .toBe('file.ts');
  });

  it('should handle empty and edge case inputs', () => {
    expect(normalizeFilePath('', projectRoot))
      .toBe('');
    
    expect(normalizeFilePath('.', projectRoot))
      .toBe('.');
    
    expect(normalizeFilePath('..', projectRoot))
      .toBe('..');
  });

  it('should handle Windows-style paths on Windows', () => {
    // This test will behave differently on Windows vs Unix
    // On Unix, Windows paths are treated as relative paths
    const windowsPath = 'C:\\Users\\project\\file.ts';
    const result = normalizeFilePath(windowsPath, projectRoot);
    
    // On Unix systems, this will be treated as a relative path
    if (path.sep === '/') {
      expect(result).toBe('C:\\Users\\project\\file.ts');
    }
    // On Windows systems, it would be normalized properly
    // We can't test this reliably in a cross-platform way
  });

  it('should handle complex relative paths', () => {
    expect(normalizeFilePath('./src/../lib/index.ts', projectRoot))
      .toBe('lib/index.ts');
    
    expect(normalizeFilePath('./src/./utils/./helper.ts', projectRoot))
      .toBe('src/utils/helper.ts');
    
    expect(normalizeFilePath('../project/./src/../lib/index.ts', projectRoot))
      .toBe('lib/index.ts');
  });

  it('should preserve relative paths that go outside project', () => {
    expect(normalizeFilePath('../../external/lib.ts', projectRoot))
      .toBe('../../external/lib.ts');
  });

  it('should handle root path', () => {
    expect(normalizeFilePath('/', projectRoot))
      .toBe(path.relative(projectRoot, '/'));
  });

  it('should handle paths with special characters', () => {
    expect(normalizeFilePath('./src/[id]/page.tsx', projectRoot))
      .toBe('src/[id]/page.tsx');
    
    expect(normalizeFilePath('./src/@auth/layout.tsx', projectRoot))
      .toBe('src/@auth/layout.tsx');
    
    expect(normalizeFilePath('./files/file with spaces.ts', projectRoot))
      .toBe('files/file with spaces.ts');
  });
});