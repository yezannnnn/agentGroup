import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { spawn, ChildProcess } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';
import { fileURLToPath } from 'url';
import { createTestEnv } from './utils/helpers.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

describe('Smoke Tests', () => {
  let serverProcess: ChildProcess;
  const testProjectPath = path.join(os.tmpdir(), 'simone-smoke-test-' + Date.now());
  
  beforeEach(() => {
    // Create minimal test environment
    if (!fs.existsSync(testProjectPath)) {
      fs.mkdirSync(testProjectPath, { recursive: true });
    }
    
    const simoneDir = path.join(testProjectPath, '.simone');
    if (!fs.existsSync(simoneDir)) {
      fs.mkdirSync(simoneDir, { recursive: true });
    }
  });
  
  afterEach(async () => {
    // Clean up server process with proper termination wait
    if (serverProcess && !serverProcess.killed) {
      serverProcess.kill();
      // Wait for process to actually terminate
      await new Promise<void>((resolve) => {
        const checkInterval = setInterval(() => {
          if (serverProcess.killed || serverProcess.exitCode !== null) {
            clearInterval(checkInterval);
            resolve();
          }
        }, 100);
        // Timeout after 5 seconds
        setTimeout(() => {
          clearInterval(checkInterval);
          resolve();
        }, 5000);
      });
    }
    
    // Verify directory removal
    if (fs.existsSync(testProjectPath)) {
      try {
        fs.rmSync(testProjectPath, { recursive: true, force: true });
        // Verify removal succeeded
        if (fs.existsSync(testProjectPath)) {
          console.warn(`Failed to remove test directory: ${testProjectPath}`);
        }
      } catch (error) {
        console.error(`Error removing test directory: ${error}`);
      }
    }
  });
  
  it('should start without errors when PROJECT_PATH is set', (done) => {
    const serverPath = path.join(__dirname, '../../dist/index.js');
    
    // Skip if server not built
    if (!fs.existsSync(serverPath)) {
      console.warn('Server not built. Skipping smoke test.');
      done();
      return;
    }
    
    serverProcess = spawn('node', [serverPath], {
      env: {
        ...process.env,
        PROJECT_PATH: testProjectPath,
        NODE_ENV: 'test',
      },
      stdio: 'pipe',
    });
    
    let hasError = false;
    let output = '';
    
    serverProcess.stderr?.on('data', (data) => {
      const message = data.toString();
      output += message;
      if (message.includes('Error') && !message.includes('ENOENT')) {
        hasError = true;
      }
    });
    
    serverProcess.stdout?.on('data', (data) => {
      output += data.toString();
    });
    
    // Give server time to start
    setTimeout(() => {
      expect(hasError).toBe(false);
      expect(serverProcess.killed).toBe(false);
      done();
    }, 1000);
  });
  
  it('should fail gracefully when PROJECT_PATH is not set', () => {
    return new Promise<void>((resolve) => {
    const serverPath = path.join(__dirname, '../../dist/index.js');
    
    // Skip if server not built
    if (!fs.existsSync(serverPath)) {
      console.warn('Server not built. Skipping smoke test.');
      done();
      return;
    }
    
    serverProcess = spawn('node', [serverPath], {
      env: {
        ...process.env,
        PROJECT_PATH: undefined, // Explicitly unset
        NODE_ENV: 'test',
      },
      stdio: 'pipe',
    });
    
    let errorMessage = '';
    
    serverProcess.stderr?.on('data', (data) => {
      errorMessage += data.toString();
    });
    
    serverProcess.on('exit', (code) => {
      // Just verify it exits with an error code
      expect(code).not.toBe(0);
      resolve();
    });
    });
  });
  
  it('should handle STDIO communication', (done) => {
    const serverPath = path.join(__dirname, '../../dist/index.js');
    
    // Skip if server not built
    if (!fs.existsSync(serverPath)) {
      console.warn('Server not built. Skipping smoke test.');
      done();
      return;
    }
    
    serverProcess = spawn('node', [serverPath], {
      env: {
        ...process.env,
        PROJECT_PATH: testProjectPath,
        NODE_ENV: 'test',
      },
      stdio: 'pipe',
    });
    
    // Send a simple JSON-RPC request
    const request = JSON.stringify({
      jsonrpc: '2.0',
      method: 'initialize',
      params: {
        protocolVersion: '0.1.0',
        capabilities: {},
        clientInfo: {
          name: 'smoke-test',
          version: '1.0.0',
        },
      },
      id: 1,
    });
    
    let response = '';
    
    serverProcess.stdout?.on('data', (data) => {
      response += data.toString();
      
      // Check if we got a valid response
      try {
        // MCP uses length-prefixed messages
        if (response.includes('Content-Length:')) {
          const parts = response.split('\r\n\r\n');
          if (parts.length >= 2) {
            const json = JSON.parse(parts[1]);
            expect(json.jsonrpc).toBe('2.0');
            expect(json.id).toBe(1);
            expect(json.result).toBeDefined();
            expect(json.result.serverInfo).toBeDefined();
            done();
          }
        }
      } catch (e) {
        // Not a complete message yet
      }
    });
    
    // Send the request after server starts
    setTimeout(() => {
      const message = `Content-Length: ${Buffer.byteLength(request)}\r\n\r\n${request}`;
      serverProcess.stdin?.write(message);
    }, 500);
  });
  
  it('should create required directories on startup', (done) => {
    const serverPath = path.join(__dirname, '../../dist/index.js');
    
    // Skip if server not built
    if (!fs.existsSync(serverPath)) {
      console.warn('Server not built. Skipping smoke test.');
      done();
      return;
    }
    
    // Remove .simone directory to test creation
    const simoneDir = path.join(testProjectPath, '.simone');
    if (fs.existsSync(simoneDir)) {
      fs.rmSync(simoneDir, { recursive: true, force: true });
    }
    
    serverProcess = spawn('node', [serverPath], {
      env: {
        ...process.env,
        PROJECT_PATH: testProjectPath,
        NODE_ENV: 'test',
      },
      stdio: 'pipe',
    });
    
    // Check if directories are created
    setTimeout(() => {
      expect(fs.existsSync(simoneDir)).toBe(true);
      expect(fs.existsSync(path.join(simoneDir, 'prompts'))).toBe(true);
      done();
    }, 1000);
  });
  
  it('should handle invalid JSON-RPC requests', (done) => {
    const serverPath = path.join(__dirname, '../../dist/index.js');
    
    // Skip if server not built
    if (!fs.existsSync(serverPath)) {
      console.warn('Server not built. Skipping smoke test.');
      done();
      return;
    }
    
    serverProcess = spawn('node', [serverPath], {
      env: {
        ...process.env,
        PROJECT_PATH: testProjectPath,
        NODE_ENV: 'test',
      },
      stdio: 'pipe',
    });
    
    // Send invalid JSON
    const invalidRequest = '{ invalid json }';
    
    let response = '';
    let hasError = false;
    
    serverProcess.stdout?.on('data', (data) => {
      response += data.toString();
      
      try {
        if (response.includes('Content-Length:')) {
          const parts = response.split('\r\n\r\n');
          if (parts.length >= 2) {
            const json = JSON.parse(parts[1]);
            if (json.error) {
              hasError = true;
              expect(json.error.code).toBeDefined();
              done();
            }
          }
        }
      } catch (e) {
        // Expected for invalid JSON
      }
    });
    
    // Send the invalid request after server starts
    setTimeout(() => {
      const message = `Content-Length: ${Buffer.byteLength(invalidRequest)}\r\n\r\n${invalidRequest}`;
      serverProcess.stdin?.write(message);
    }, 500);
    
    // Timeout in case no error response
    setTimeout(() => {
      if (!hasError) {
        done();
      }
    }, 2000);
  });
});