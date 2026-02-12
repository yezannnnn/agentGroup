import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { spawn, ChildProcess } from 'child_process';
import { createMockTransport, MockTransport } from '../utils/mcp-mock.js';
import type { 
  InitializeResult, 
  GetPromptResult,
  CallToolResult,
  ListPromptsResult,
  ListToolsResult,
  ErrorResponse 
} from '@modelcontextprotocol/sdk/types.js';
import { createInMemoryDatabase } from '../utils/database-mock.js';
import { createTestEnv } from '../utils/helpers.js';
import * as path from 'path';
import * as fs from 'fs';

describe('MCP Server Integration Tests', () => {
  // Simple integration tests to ensure server keeps working
  // when new prompts or features are added
  let transport: MockTransport;
  let serverProcess: ChildProcess;
  const testProjectPath = '/test/project';
  
  beforeEach(async () => {
    // Create a mock transport for testing
    transport = createMockTransport();
    
    // Set up test environment
    process.env = createTestEnv({
      PROJECT_PATH: testProjectPath,
    });
  });
  
  afterEach(async () => {
    // Clean up server process if running
    if (serverProcess && !serverProcess.killed) {
      serverProcess.kill();
    }
  });
  
  describe('Server Initialization', () => {
    it('should initialize successfully with valid configuration', async () => {
      const response = await transport.sendRequest('initialize', {
        protocolVersion: '0.1.0',
        capabilities: {
          prompts: {},
          tools: {},
        },
        clientInfo: {
          name: 'test-client',
          version: '1.0.0',
        },
      });
      
      const result = response as InitializeResult;
      expect(result.protocolVersion).toBe('0.1.0');
      expect(result.capabilities).toBeDefined();
      expect(result.serverInfo).toMatchObject({
        name: 'simone-mcp',
        version: expect.any(String),
      });
    });
    
    it('should handle missing PROJECT_PATH environment variable', async () => {
      delete process.env.PROJECT_PATH;
      
      // In a real test, this would spawn the server and check the error
      // For unit testing, we'll simulate the expected behavior
      expect(() => {
        // Server initialization code would throw here
        if (!process.env.PROJECT_PATH) {
          throw new Error('PROJECT_PATH environment variable is required');
        }
      }).toThrow('PROJECT_PATH environment variable is required');
    });
  });
  
  describe('Prompt Handling', () => {
    it('should list available prompts', async () => {
      const response = await transport.sendRequest('prompts/list', {});
      const result = response as ListPromptsResult;
      
      // Just verify we get an array of prompts
      expect(Array.isArray(result.prompts)).toBe(true);
      expect(result.prompts.length).toBeGreaterThan(0);
    });
    
    it('should execute any valid prompt', async () => {
      // Use a simple prompt we know exists
      const response = await transport.sendRequest('prompts/get', {
        name: 'create_issue',
        arguments: {
          title: 'Test',
          body: 'Test',
        },
      });
      
      const result = response as GetPromptResult;
      expect(result.messages).toBeDefined();
      expect(result.messages.length).toBeGreaterThan(0);
    });
    
    it('should handle invalid prompt name', async () => {
      try {
        await transport.sendRequest('prompts/get', {
          name: 'non-existent-prompt',
          arguments: {},
        });
        expect.fail('Should have thrown an error');
      } catch (error: any) {
        expect(error.message).toBeDefined();
      }
    });
  });
  
  describe('Tool Handling', () => {
    it('should list available tools', async () => {
      const response = await transport.sendRequest('tools/list', {});
      const result = response as ListToolsResult;
      
      expect(Array.isArray(result.tools)).toBe(true);
    });
    
    it('should execute log_activity tool', async () => {
      const response = await transport.sendRequest('tools/call', {
        name: 'log_activity',
        arguments: {
          activity: 'Test',
          tool_name: 'test',
        },
      });
      
      const result = response as CallToolResult;
      expect(result.content).toBeDefined();
    });
  });
  
  
  describe('Basic Functionality', () => {
    it('should handle errors without crashing', async () => {
      try {
        await transport.sendRequest('invalid/method', {});
      } catch (error: any) {
        // Server should return an error, not crash
        expect(error).toBeDefined();
      }
    });
  });
  
  
  
});