import { vi, beforeEach, afterEach } from 'vitest';
import { EventEmitter } from 'events';
import type { Transport } from '@modelcontextprotocol/sdk/types.js';

export class MockTransport extends EventEmitter implements Transport {
  private _isClosed = false;
  public sentMessages: any[] = [];
  private requestHandlers = new Map<string, (params: any) => any>();
  private idCounter = 1;

  async send(message: any): Promise<void> {
    this.sentMessages.push(message);
  }

  async close(): Promise<void> {
    this._isClosed = true;
    this.emit('close');
  }

  get isClosed(): boolean {
    return this._isClosed;
  }

  simulateMessage(message: any) {
    this.emit('message', message);
  }

  clear() {
    this.sentMessages = [];
  }

  // Add request/response simulation for integration tests
  async sendRequest(method: string, params: any): Promise<any> {
    const id = this.idCounter++;
    const request = {
      jsonrpc: '2.0',
      method,
      params,
      id,
    };

    // Simulate server response based on method
    switch (method) {
      case 'initialize':
        return {
          protocolVersion: '0.1.0',
          capabilities: {
            prompts: {},
            tools: {},
          },
          serverInfo: {
            name: 'simone-mcp',
            version: '0.2.0',
          },
        };
      
      case 'prompts/list':
        return {
          prompts: [
            { name: 'create_issue', description: 'Create a new issue' },
            { name: 'create_pr', description: 'Create a pull request' },
          ],
        };
      
      case 'prompts/get':
        if (params.name === 'non-existent-prompt') {
          throw new Error('Prompt not found');
        }
        // Just return a basic response
        return {
          messages: [
            {
              role: 'user',
              content: 'Test prompt content',
            },
          ],
        };
      
      case 'tools/list':
        return {
          tools: [
            { name: 'log_activity', description: 'Log an activity' },
          ],
        };
      
      case 'tools/call':
        if (params.name === 'log_activity') {
          return {
            content: [{ type: 'text', text: 'Activity logged' }],
          };
        }
        throw new Error('Tool not found');
      
      default:
        throw new Error('Method not found');
    }
  }
}

export function createMockTransport(): MockTransport {
  return new MockTransport();
}

export function mockConsoleLog() {
  const originalLog = console.log;
  const originalError = console.error;
  const originalWarn = console.warn;

  beforeEach(() => {
    console.log = vi.fn();
    console.error = vi.fn();
    console.warn = vi.fn();
  });

  afterEach(() => {
    console.log = originalLog;
    console.error = originalError;
    console.warn = originalWarn;
  });
}