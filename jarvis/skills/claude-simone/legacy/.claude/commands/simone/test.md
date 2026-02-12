# Run tests and fix common issues

Follow these instructions from top to bottom.

## Create a TODO with EXACTLY these 4 items

1. Execute test suite
2. Analyze results and identify issues
3. Fix common problems if found
4. Provide test summary

---

## 1 · Execute test suite

### First, detect the project's test runner

1. **Python projects:**
   - If `pyproject.toml` exists with `[tool.poetry]`: Try `poetry run pytest`
   - If `setup.py` or `requirements.txt`: Try `pytest` or `python -m pytest`
   - If custom test script exists (e.g., `run_tests.py`, `run_dev.py`): Use that
   - Add common flags: `--tb=short` for pytest

2. **JavaScript/TypeScript projects:**
   - If `package.json` exists: Check "scripts" section for "test" command
   - Common: `npm test`, `npm run test`, `yarn test`, `pnpm test`
   - Framework specific: `jest`, `vitest`, `mocha`

3. **Other languages:**
   - Rust: `cargo test`
   - Go: `go test ./...`
   - Java: `mvn test` or `gradle test`
   - Ruby: `bundle exec rspec` or `rake test`
   - PHP: `composer test` or `phpunit`

### Execute the detected test command

- RUN the appropriate test command
- CAPTURE full output including any errors
- NOTE execution time and test counts

**If no test runner is found:** Report this to the user and ask for the correct test command.

## 2 · Analyze results and identify issues

Check for common issues in this order:

### Language-specific issues

**Python:**

- Missing **init**.py files (import errors, tests not discovered)
- Import path problems
- Fixture issues (pytest)
- Virtual environment problems

**JavaScript/TypeScript:**

- Module resolution errors
- Missing dependencies in node_modules
- Jest/Vitest configuration issues
- TypeScript compilation errors

**Common across languages:**

- Environment variable issues (missing config)
- Database/external service connection errors
- File path problems (absolute vs relative)
- Permission issues

## 3 · Fix common problems if found

**ONLY** fix these specific issues automatically:**

### Python-specific fixes

- CREATE empty `__init__.py` files where needed
- FIX simple import path issues
- ADD missing test directory to Python path if needed

### JavaScript/TypeScript fixes

- RUN `npm install` if node_modules missing
- FIX simple module resolution in jest.config.js
- CREATE missing test setup files

### General fixes

- CREATE missing test directories
- FIX file permissions if possible
- IDENTIFY missing env vars and inform user

**DO NOT** fix:

- Actual test logic failures
- Business logic bugs
- Complex configuration issues
- Database schema problems
- External service dependencies

## 4 · Provide test summary

Create a brief summary:

```
Test Results:
- Total: X tests
- Passed: Y (Z%)
- Failed: A
- Skipped: B
- Time: C seconds

Issues Fixed:
- [List any fixes applied]

Issues Found (requires manual fix):
- [List problems that need attention]

Status: PASSING | FAILING | BLOCKED
```

**IMPORTANT:** Keep it concise. This command should be quick and focused on running tests, not detailed analysis.
EOF < /dev/null
