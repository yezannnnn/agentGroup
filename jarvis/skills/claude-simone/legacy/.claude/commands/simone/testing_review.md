# Testing Review - Execute top to bottom

Analyzes test implementation against the project's testing strategy to ensure tests remain balanced, purposeful, and aligned with development goals.

## Prerequisites Check

**FIRST**, check if a testing strategy document exists:

- CHECK for `.simone/01_PROJECT_DOCS/TESTING_STRATEGY.md`
- If NOT found, inform the user: "No testing strategy document found. Would you like me to help create one, or proceed with a general test quality review?"
- If user wants to proceed without strategy, adapt the review to focus on general test quality principles

## Create a TODO with EXACTLY these 7 Items

1. Load testing strategy document (or define review criteria)
2. Analyze test implementation structure
3. Evaluate test-to-code alignment
4. Identify misaligned or unnecessary tests
5. Assess critical functionality coverage
6. Generate modification recommendations
7. Create alignment report

Follow step by step and adhere closely to the following instructions for each step.

## DETAILS on every TODO item

### 1. Load testing strategy document (or define review criteria)

**Option A - Strategy document exists:**

- LOAD `.simone/01_PROJECT_DOCS/TESTING_STRATEGY.md`
- EXTRACT key principles and priorities
- IDENTIFY what should and shouldn't be tested
- NOTE coverage expectations and quality gates
- UNDERSTAND the testing philosophy

**Option B - No strategy document:**
Use general best practices as review criteria:

- Tests should focus on behavior, not implementation
- Critical paths must have coverage
- Tests should be maintainable and clear
- Avoid over-testing simple getters/setters
- Balance between coverage and maintenance burden

**DOCUMENT** which approach is being used for this review.

### 2. Analyze test implementation structure

**EXAMINE** the current test codebase:

- USE test.md command to run tests
- EXPLORE test directory structure and organization
- IDENTIFY test categories and their purposes
- CHECK test naming conventions and patterns
- NOTE any test infrastructure or utilities

**Focus on understanding what exists, not counting.**

### 3. Evaluate test-to-code alignment

**COMPARE** tests against actual implementation:

- For each major component, check if tests match functionality
- IDENTIFY tests that test implementation details vs behavior
- FIND tests with excessive setup or mocking
- LOCATE tests that break frequently on refactoring
- CHECK if test complexity matches code complexity

**Key question:** Do the tests validate what users care about?

### 4. Identify misaligned or unnecessary tests

**SEARCH** for tests that don't provide value:

**If using strategy document:**

- Tests for areas marked as "skip" in strategy
- Tests outside the defined scope
- Over-specified tests per strategy guidelines

**If using general principles:**

- Over-engineered tests for simple functionality
- Tests that break on every refactor
- Edge case tests for non-critical features
- Tests with excessive mocking/setup
- Performance tests without performance requirements

**Create a list of specific tests to modify or remove.**

### 5. Assess critical functionality coverage

**VERIFY** that essential functionality has appropriate tests:

**If using strategy document:**

- CHECK coverage of high-priority areas defined in strategy
- VERIFY strategy-specific requirements are tested

**For all reviews:**

- IDENTIFY gaps in critical path testing
- CHECK authentication/authorization if applicable
- VERIFY error handling for important operations
- ENSURE data integrity tests exist where needed
- CONFIRM integration points are tested

**Note specific gaps that need addressing.**

### 6. Generate modification recommendations

**CREATE** specific, actionable recommendations:

For each finding:

- SPECIFY the test file and function
- EXPLAIN why it needs modification
- SUGGEST the specific change (remove, simplify, add)
- PROVIDE example of the improved approach if helpful

**Format:**

```
File: tests/test_example.py::test_function_name
Issue: [What's wrong]
Action: [What to do]
Reason: [Why this aligns with strategy]
```

### 7. Create alignment report

**GENERATE** a focused report on test-strategy alignment:

- Get current timestamp using system date command
- Create report in `.simone/10_STATE_OF_PROJECT/YYYY-MM-DD-HH-MM-test-alignment.md`

**Report structure:**

```markdown
# Test-Strategy Alignment Review - [YYYY-MM-DD HH:MM]

## Alignment Summary

Overall alignment with testing strategy: [EXCELLENT | GOOD | NEEDS WORK | POOR]

Key findings:
- [Major finding about test suite health]
- [Major finding about coverage]
- [Major finding about maintenance burden]

## Tests Requiring Modification

### Remove (Over-engineered/Out of scope)
[List specific tests with reasons]

### Simplify (Too complex for purpose)
[List specific tests with simplification approach]

### Add (Critical gaps)
[List specific missing tests for critical paths]

## Recommended Actions

### Immediate (Blocking issues)
- [ ] [Specific action with file/test reference]

### Short-term (Quality improvements)
- [ ] [Specific action with file/test reference]

### Long-term (Technical debt)
- [ ] [Specific action with file/test reference]

## Test Health Indicators

- Tests align with code purpose: [YES | PARTIALLY | NO]
- Critical paths covered: [YES | PARTIALLY | NO]
- Maintenance burden reasonable: [YES | PARTIALLY | NO]
- Tests support development velocity: [YES | PARTIALLY | NO]

## Implementation Examples

[If needed, show before/after examples of test improvements]

## Next Review

Recommended review in: [X weeks/sprints]
Focus areas for next review: [Specific areas to monitor]
```

**IMPORTANT:** Focus on alignment and balance, not metrics. The goal is tests that serve the project's actual needs.
