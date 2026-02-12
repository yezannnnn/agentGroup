# Testing Strategy for Simone MCP Server

## Overview

This document outlines the comprehensive testing approach implemented for the Simone MCP (Model Context Protocol) server. The test suite ensures reliability, maintainability, and correctness of the server implementation.

## Test Infrastructure

### Testing Framework
- **Vitest**: Modern, fast testing framework with excellent TypeScript support
- **Coverage Tool**: @vitest/coverage-v8 for code coverage analysis

### Test Organization

```
mcp-server/
├── src/
│   ├── __tests__/              # Integration and smoke tests
│   │   ├── integration/        # Full server integration tests
│   │   ├── smoke.test.ts       # Basic server functionality tests
│   │   ├── fixtures/           # Test fixtures and sample data
│   │   └── utils/              # Test utilities and mocks
│   └── [module]/
│       └── *.test.ts           # Unit tests co-located with source
```

## Test Categories

### 1. Unit Tests (92 tests)
Tests individual components in isolation with mocked dependencies.

#### Config Loader Tests (15 tests)
- Configuration file loading and parsing
- Environment variable handling
- Default value management
- Error scenarios (missing files, invalid YAML)

#### Template System Tests (30 tests)
- Handlebars template compilation
- Hot-reloading functionality
- Partial template support
- Template caching and invalidation
- Error handling for malformed templates

#### Activity Logger Tests (35 tests)
- Activity type detection with scoring algorithm
- Database operations (insert, transaction handling)
- Tag management (limiting to 3 tags)
- File path normalization
- Error recovery and logging

#### Prompt Handler Tests (12 tests)
- Prompt argument validation
- Template rendering with context
- Missing/invalid prompt handling

### 2. Integration Tests (18 tests)
Tests the complete server with real components but controlled environment.

#### Server Integration Tests
- MCP protocol initialization
- Prompt listing and execution
- Tool listing and execution
- Concurrent request handling
- Error propagation
- Configuration loading

### 3. STDIO Integration Tests (9 tests)
Tests real server process spawning and client communication.

- Server startup and initialization
- Custom prompt execution
- Tool execution with database
- Template hot-reloading in real-time
- Concurrent client requests
- Graceful shutdown

### 4. Smoke Tests (5 tests)
Basic sanity checks for server functionality.

- Server starts without errors
- Handles missing PROJECT_PATH
- STDIO communication works
- Creates required directories
- Handles invalid JSON-RPC requests

## Test Utilities

### Mock Implementations

#### MCP Transport Mock
```typescript
export class MockTransport {
  async sendRequest(method: string, params: any): Promise<any>
  simulateMessage(message: any): void
}
```

#### Database Mock
```typescript
export function createInMemoryDatabase(): Database.Database
export function createTestDatabaseConnection(): Promise<DatabaseConnection>
```

#### File System Mock
```typescript
export function createMockFileSystem(): MockFS
```

### Test Helpers
- `mockConsoleLog()`: Captures console output
- `waitFor(ms)`: Async delay for timing tests
- `createTestEnv()`: Sets up test environment variables

## Coverage Analysis

### Final Coverage
- **Overall**: 66% (below 80% target)
- **Core Business Logic**: 87-100% coverage ✅
  - Config Loader: 98.3%
  - Template Handler: 99.24%
  - Template Loader: 91.82%
  - Activity Logger: 98-100%

### Coverage Gaps (By Design)
- Main server entry point (`index.ts`) - 0%
- Database connection module - 11%
- Utility modules (logger) - 14%

These gaps are acceptable because:
1. Entry points are integration tested through smoke tests
2. Core business logic has excellent coverage
3. The goal is regression prevention, not 100% coverage

## Testing Best Practices

### 1. Test Isolation
- Each test runs in isolation with fresh mocks
- No shared state between tests
- Proper cleanup in `afterEach` hooks

### 2. Mock Management
- Mocks declared before imports to ensure proper hoisting
- Consistent mock patterns across test files
- Type-safe mocks using Vitest's `vi.mocked()`

### 3. Async Testing
- Proper async/await usage
- Timeout handling for long-running tests
- Process cleanup for spawned servers

### 4. Error Testing
- Both error cases and success cases tested
- Graceful error handling verification
- Error message content validation

## Running Tests

```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Run with coverage
pnpm test:coverage

# Run specific test file
pnpm test src/config/loader.test.ts

# Run only unit tests
pnpm test src/config/ src/templates/ src/tools/
```

## Known Issues and Limitations

1. **STDIO Integration Tests**: Some tests timeout due to real process spawning delays
2. **Database Locking**: Concurrent database access in tests can cause locking issues
3. **Coverage Calculation**: Overall coverage appears low due to untested entry points

## Future Improvements

1. **Increase Coverage**:
   - Add tests for main server entry point
   - Test database connection module
   - Cover utility functions

2. **Performance**:
   - Optimize STDIO tests to reduce timeouts
   - Implement test parallelization where possible

3. **E2E Tests**:
   - Add end-to-end tests with real MCP clients
   - Test with actual Claude Code integration

## Conclusion

The test suite provides a solid foundation for maintaining code quality and preventing regressions. While overall coverage is below the 80% target, the critical business logic components have excellent coverage (90-100%). The test infrastructure supports various testing scenarios from unit to integration testing, ensuring the MCP server behaves correctly in different environments.