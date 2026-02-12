import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { mockConsoleLog, TEST_PROJECT_PATH } from '../__tests__/utils/index.js';
import { fixtures, mockProjectConfig } from '../__tests__/fixtures/index.js';
import Handlebars from 'handlebars';

// Mock dependencies before importing the module under test
vi.mock('fs/promises', () => ({
  readFile: vi.fn(),
  readdir: vi.fn(),
}));

vi.mock('fs', () => ({
  existsSync: vi.fn(),
}));

vi.mock('../utils/logger.js', () => ({
  logError: vi.fn(),
}));

// Mock the loader module
vi.mock('./loader.js', () => ({
  TemplateLoader: vi.fn().mockImplementation(() => ({
    loadPrompt: vi.fn(),
    compileTemplate: vi.fn(),
    loadPartial: vi.fn(),
    clearCache: vi.fn(),
  })),
}));

// Mock the config loader
vi.mock('../config/index.js', () => ({
  ConfigLoader: vi.fn().mockImplementation(() => ({
    getConfig: vi.fn(),
  })),
}));

// Mock the context builder
vi.mock('./context.js', () => ({
  buildTemplateContext: vi.fn(),
}));

// Mock the helpers
vi.mock('./helpers/index.js', () => ({
  registerHelpers: vi.fn(),
}));

// Import the module under test after setting up mocks
import { PromptHandler } from './handler.js';
import { TemplateLoader } from './loader.js';
import { ConfigLoader } from '../config/index.js';
import { buildTemplateContext } from './context.js';
import { registerHelpers } from './helpers/index.js';
import * as fs from 'fs';
import * as fsPromises from 'fs/promises';

describe('PromptHandler', () => {
  mockConsoleLog();

  let handler: PromptHandler;
  let mockLoader: any;
  let mockConfigLoader: any;
  const mockProjectPath = '/test/project';
  
  beforeEach(() => {
    vi.clearAllMocks();
    
    // Create fresh mock instances
    mockLoader = {
      loadPrompt: vi.fn(),
      compileTemplate: vi.fn(),
      loadPartial: vi.fn(),
      clearCache: vi.fn(),
    };
    
    mockConfigLoader = {
      getConfig: vi.fn(),
    };
    
    // Set up mocks to return our instances
    vi.mocked(TemplateLoader).mockReturnValue(mockLoader);
    vi.mocked(ConfigLoader).mockReturnValue(mockConfigLoader);
    
    handler = new PromptHandler(mockProjectPath);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('constructor', () => {
    it('should initialize with project path and register helpers', () => {
      expect(handler).toBeDefined();
      expect(TemplateLoader).toHaveBeenCalledWith(mockProjectPath);
      expect(ConfigLoader).toHaveBeenCalledWith(mockProjectPath);
      expect(registerHelpers).toHaveBeenCalled();
    });
  });

  describe('getPromptMessages()', () => {
    it('should return error message when prompt not found', async () => {
      mockLoader.loadPrompt.mockResolvedValue(null);
      
      const messages = await handler.getPromptMessages('non-existent');
      
      expect(messages).toHaveLength(1);
      expect(messages[0].role).toBe('user');
      expect(messages[0].content.text).toContain("Prompt 'non-existent' not found");
    });

    it('should render simple prompt without arguments', async () => {
      const mockPrompt = {
        name: 'simple',
        description: 'Simple prompt',
        template: 'Hello from {{project.name}}!',
      };
      
      mockLoader.loadPrompt.mockResolvedValue(mockPrompt);
      mockConfigLoader.getConfig.mockReturnValue({
        project: { name: 'Test Project' },
        contexts: [],
      });
      
      vi.mocked(buildTemplateContext).mockReturnValue({
        project: { name: 'Test Project' },
      });
      
      const compiledTemplate = vi.fn().mockReturnValue('Hello from Test Project!');
      mockLoader.compileTemplate.mockResolvedValue(compiledTemplate);
      
      // Mock file existence checks
      vi.mocked(fs.existsSync).mockReturnValue(false);
      
      const messages = await handler.getPromptMessages('simple');
      
      expect(messages).toHaveLength(1);
      expect(messages[0].content.text).toBe('Hello from Test Project!');
    });

    it('should include header partial when it exists', async () => {
      const mockPrompt = {
        name: 'with-header',
        description: 'Prompt with header',
        template: 'Main content',
      };
      
      mockLoader.loadPrompt.mockResolvedValue(mockPrompt);
      mockLoader.loadPartial.mockResolvedValue('Header content');
      
      vi.mocked(buildTemplateContext).mockReturnValue({});
      
      const headerCompiled = vi.fn().mockReturnValue('Rendered header');
      const mainCompiled = vi.fn().mockReturnValue('Rendered main');
      
      mockLoader.compileTemplate
        .mockResolvedValueOnce(headerCompiled) // For header
        .mockResolvedValueOnce(mainCompiled);  // For main
      
      vi.mocked(fs.existsSync).mockReturnValue(false);
      
      const messages = await handler.getPromptMessages('with-header');
      
      expect(messages[0].content.text).toBe('Rendered header\nRendered main');
    });

    it('should apply default values for missing arguments', async () => {
      const mockPrompt = {
        name: 'with-defaults',
        description: 'Prompt with default args',
        template: 'Value: {{value}}',
        arguments: [
          {
            name: 'value',
            description: 'A value',
            default: 'default-{{project.name}}',
          },
        ],
      };
      
      mockLoader.loadPrompt.mockResolvedValue(mockPrompt);
      
      const context = {
        project: { name: 'Test' },
      };
      vi.mocked(buildTemplateContext).mockReturnValue(context);
      
      // Compile default value template
      const defaultCompiled = vi.fn().mockReturnValue('default-Test');
      mockLoader.compileTemplate.mockResolvedValueOnce(defaultCompiled);
      
      // Compile main template
      const mainCompiled = vi.fn().mockImplementation((ctx) => 
        `Value: ${ctx.value}`
      );
      mockLoader.compileTemplate.mockResolvedValueOnce(mainCompiled);
      
      vi.mocked(fs.existsSync).mockReturnValue(false);
      
      const messages = await handler.getPromptMessages('with-defaults');
      
      expect(context.value).toBe('default-Test');
      expect(messages[0].content.text).toBe('Value: default-Test');
    });

    it('should auto-load constitution when it exists', async () => {
      const mockPrompt = {
        name: 'with-constitution',
        description: 'Prompt using constitution',
        template: 'Constitution: {{constitution}}',
      };
      
      mockLoader.loadPrompt.mockResolvedValue(mockPrompt);
      
      const context = {};
      vi.mocked(buildTemplateContext).mockReturnValue(context);
      
      // Mock constitution file exists and can be read
      vi.mocked(fs.existsSync).mockImplementation((path) => 
        path === '/test/project/.simone/constitution.md'
      );
      
      vi.mocked(fsPromises.readFile).mockResolvedValue('# Project Constitution\nRules...');
      
      const mainCompiled = vi.fn().mockImplementation((ctx) => 
        `Constitution: ${ctx.constitution}`
      );
      mockLoader.compileTemplate.mockResolvedValue(mainCompiled);
      
      const messages = await handler.getPromptMessages('with-constitution');
      
      expect(context.constitution).toBe('# Project Constitution\nRules...');
      expect(messages[0].content.text).toContain('Constitution: # Project Constitution');
    });

    it('should return error when constitution cannot be read', async () => {
      const mockPrompt = {
        name: 'with-constitution',
        description: 'Prompt using constitution',
        template: 'Test',
      };
      
      mockLoader.loadPrompt.mockResolvedValue(mockPrompt);
      vi.mocked(buildTemplateContext).mockReturnValue({});
      
      // Mock constitution file exists but read fails
      vi.mocked(fs.existsSync).mockImplementation((path) => 
        path === '/test/project/.simone/constitution.md'
      );
      
      vi.mocked(fsPromises.readFile).mockRejectedValue(new Error('Permission denied'));
      
      const messages = await handler.getPromptMessages('with-constitution');
      
      expect(messages[0].content.text).toContain('Failed to read constitution.md');
      expect(messages[0].content.text).toContain('Permission denied');
    });

    it('should add project context flags', async () => {
      const mockPrompt = {
        name: 'project-context',
        description: 'Prompt with project context',
        template: 'Has README: {{projectContext.hasReadme}}',
      };
      
      mockLoader.loadPrompt.mockResolvedValue(mockPrompt);
      
      const context = {};
      vi.mocked(buildTemplateContext).mockReturnValue(context);
      
      // Mock various file checks
      vi.mocked(fs.existsSync).mockImplementation((path) => {
        if (path.endsWith('README.md')) return true;
        if (path.endsWith('package.json')) return true;
        if (path.endsWith('src')) return true;
        return false;
      });
      
      const mainCompiled = vi.fn().mockImplementation((ctx) => 
        `Has README: ${ctx.projectContext.hasReadme}`
      );
      mockLoader.compileTemplate.mockResolvedValue(mainCompiled);
      
      const messages = await handler.getPromptMessages('project-context');
      
      expect(context.projectContext).toEqual({
        hasReadme: true,
        hasPackageJson: true,
        hasGitignore: false,
        hasSrcDir: true,
        hasTestDir: false,
      });
    });

    it('should handle template rendering errors', async () => {
      const mockPrompt = {
        name: 'error-template',
        description: 'Template that errors',
        template: '{{invalid syntax',
      };
      
      mockLoader.loadPrompt.mockResolvedValue(mockPrompt);
      vi.mocked(buildTemplateContext).mockReturnValue({});
      vi.mocked(fs.existsSync).mockReturnValue(false);
      
      mockLoader.compileTemplate.mockRejectedValue(new Error('Template error'));
      
      const messages = await handler.getPromptMessages('error-template');
      
      expect(messages[0].content.text).toContain('Template rendering error');
    });
  });

  describe('clearCache()', () => {
    it('should clear the loader cache', () => {
      handler.clearCache();
      
      expect(mockLoader.clearCache).toHaveBeenCalled();
    });
  });

  describe('listAvailablePrompts()', () => {
    it('should list prompts from project and built-in directories', async () => {
      // Mock directory listings
      vi.mocked(fsPromises.readdir).mockImplementation(async (dir) => {
        if (typeof dir === 'string' && dir.includes('.simone/prompts')) {
          return ['project-prompt.yaml', 'override.yaml'] as any;
        }
        if (typeof dir === 'string' && dir.includes('templates/prompts')) {
          return ['built-in.yaml', 'override.yaml'] as any;
        }
        return [] as any;
      });
      
      // Mock prompt loading
      mockLoader.loadPrompt.mockImplementation(async (name) => {
        if (name === 'project-prompt') {
          return { name: 'project-prompt', description: 'Project prompt' };
        }
        if (name === 'override') {
          return { name: 'override', description: 'Override prompt' };
        }
        if (name === 'built-in') {
          return { name: 'built-in', description: 'Built-in prompt' };
        }
        return null;
      });
      
      const prompts = await handler.listAvailablePrompts();
      
      expect(prompts).toHaveLength(3);
      expect(prompts.map(p => p.name)).toContain('project-prompt');
      expect(prompts.map(p => p.name)).toContain('override');
      expect(prompts.map(p => p.name)).toContain('built-in');
      
      // Verify project prompts were checked first (override should only be loaded once)
      expect(mockLoader.loadPrompt).toHaveBeenCalledWith('override');
      expect(mockLoader.loadPrompt).toHaveBeenCalledTimes(3);
    });

    it('should handle missing directories gracefully', async () => {
      vi.mocked(fsPromises.readdir).mockRejectedValue(new Error('ENOENT'));
      
      const prompts = await handler.listAvailablePrompts();
      
      expect(prompts).toEqual([]);
    });

    it('should filter out error prompts', async () => {
      vi.mocked(fsPromises.readdir).mockResolvedValue(['test.yaml'] as any);
      
      mockLoader.loadPrompt.mockResolvedValue({
        name: 'error',
        description: 'Error prompt',
        template: 'error',
      });
      
      const prompts = await handler.listAvailablePrompts();
      
      expect(prompts).toEqual([]);
    });
  });
});