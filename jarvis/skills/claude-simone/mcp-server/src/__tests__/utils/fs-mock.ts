import { vi } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';

interface MockFile {
  path: string;
  content: string;
  mtime?: Date;
}

export function createMockFileSystem(files: MockFile[]) {
  const fileMap = new Map<string, MockFile>();
  
  files.forEach(file => {
    fileMap.set(path.normalize(file.path), {
      ...file,
      mtime: file.mtime || new Date(),
    });
  });

  vi.mock('fs', () => ({
    existsSync: vi.fn((filePath: string) => {
      return fileMap.has(path.normalize(filePath));
    }),
    readFileSync: vi.fn((filePath: string, encoding?: any) => {
      const normalizedPath = path.normalize(filePath);
      const file = fileMap.get(normalizedPath);
      if (!file) {
        throw new Error(`ENOENT: no such file or directory, open '${filePath}'`);
      }
      return file.content;
    }),
    statSync: vi.fn((filePath: string) => {
      const normalizedPath = path.normalize(filePath);
      const file = fileMap.get(normalizedPath);
      if (!file) {
        throw new Error(`ENOENT: no such file or directory, stat '${filePath}'`);
      }
      return {
        mtime: file.mtime,
        isFile: () => true,
        isDirectory: () => false,
      };
    }),
    readdirSync: vi.fn((dirPath: string) => {
      const normalizedDir = path.normalize(dirPath);
      const files: string[] = [];
      
      fileMap.forEach((_, filePath) => {
        const dir = path.dirname(filePath);
        const fileName = path.basename(filePath);
        if (dir === normalizedDir && !files.includes(fileName)) {
          files.push(fileName);
        }
      });
      
      if (files.length === 0) {
        throw new Error(`ENOENT: no such file or directory, scandir '${dirPath}'`);
      }
      
      return files;
    }),
  }));

  return {
    addFile: (file: MockFile) => {
      fileMap.set(path.normalize(file.path), {
        ...file,
        mtime: file.mtime || new Date(),
      });
    },
    updateFile: (filePath: string, content: string) => {
      const normalizedPath = path.normalize(filePath);
      const file = fileMap.get(normalizedPath);
      if (file) {
        file.content = content;
        file.mtime = new Date();
      }
    },
    removeFile: (filePath: string) => {
      fileMap.delete(path.normalize(filePath));
    },
    getFileMap: () => fileMap,
  };
}