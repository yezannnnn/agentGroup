# Project Review - Execute top to bottom

Perform a comprehensive project-level review focusing on architecture, progress, and technical decisions.

**IMPORTANT:**

- This is a high-level review of overall project state, not recent changes.
- Unless clearly mentioned in project documents, there is no timeline and schedule is irrelevant

## Create a TODO with EXACTLY these 9 Items

1. Analyze review scope and timing
2. Execute and assess test infrastructure health
3. Assess project documentation alignment
4. Review milestone and sprint progress
5. Analyze codebase architecture and structure
6. Audit file organization and workflow compliance
7. Evaluate technical decisions and complexity
8. Critique implementation quality (John Carmack perspective)
9. Provide comprehensive assessment with recommendations

Follow step by step and adhere closely to the following instructions for each step.

## DETAILS on every TODO item

### 1. Analyze review scope and timing

Check: <$ARGUMENTS>

If empty, perform full project review. Otherwise interpret <$ARGUMENTS> to identify specific focus areas (milestone, sprint, architecture component, etc.). Unless stated in Argument do not compare to previews project reviews in `.simone/10_STATE_OF_PROJECT`.

**IMPORTANT:** This review looks at overall project state in context of recent changes.

**CRITICAL:** Read `.simone/00_PROJECT_MANIFEST.md` FIRST to understand:

- Current milestone and sprint status
- What work is complete vs in-progress vs planned
- Active sprint objectives and deliverables

**CONTEXT CHECK:** Before evaluating functionality:

- Navigate to `.simone/03_SPRINTS/` to find the current sprint
- Read the sprint meta file to understand what's in scope
- Check completed vs planned tasks within the sprint
- Understand what future sprints will deliver

**REVIEW PRINCIPLE:** Evaluate against CURRENT SPRINT deliverables, not full milestone scope.

### 2. Execute and assess test infrastructure health

**CRITICAL:** Test infrastructure health is a BLOCKING criteria for sprint/milestone progression.

- USE test.md command to execute full test suite (@.claude/commands/simone/test.md)
- ANALYZE test results: passed/failed/skipped counts and failure categories
- CALCULATE test health score (0-10 scale):
  - 10: 100% pass rate, no infrastructure issues
  - 8-9: >95% pass rate, minor issues only
  - 6-7: 80-95% pass rate, some non-critical failures
  - 4-5: 60-80% pass rate, significant issues
  - 0-3: <60% pass rate, critical infrastructure problems
- CATEGORIZE failures:
  - Infrastructure: Import errors, missing modules
  - Configuration: Environment variables, database connections
  - Logic: Assertion failures, actual bugs
  - Flaky: Intermittent failures
- DETERMINE blocking status:
  - Score < 6: BLOCKS sprint progression
  - Score < 8: BLOCKS milestone completion
  - Score < 4: TRIGGERS emergency escalation
- IDENTIFY root causes of any infrastructure failures
- TRACK trend vs previous review (improvement/degradation)
- ASSESS test strategy validity for scope of the project. Tests should be pragmatic and help assuring functionality but not get in the way of development progress too much.

### 3. Assess project documentation alignment

**USE PARALLEL AGENTS** to follow these steps:

- READ all core documents in `.simone/01_PROJECT_DOCS/` especially ARCHITECTURE.md
- READ current milestone requirements in `.simone/02_REQUIREMENTS/`
- READ architecture decisions in `.simone/05_ARCHITECTURE_DECISIONS` as they might extend/contradict other documents
- IDENTIFY any gaps between documentation and current implementation
- CHECK if the project is still following the documented architecture vision
- VERIFY that current code structure matches documented patterns

**IMPORTANT:** Documentation is our source of truth. Any deviation needs justification.

### 4. Review milestone and sprint progress

**USE PARALLEL AGENTS** to follow these steps:

- READ `.simone/00_PROJECT_MANIFEST.md` for current status
- ANALYZE completed sprints in `.simone/03_SPRINTS/`
- COMPARE actual progress against CURRENT SPRINT deliverables (not full milestone)
- DISTINGUISH between sprint-level tasks vs milestone-level features
- ASSESS if current sprint focus aligns with milestone goals

### 5. Analyze codebase architecture and structure

#

**USE PARALLEL AGENTS** to follow these steps:

- EXAMINE overall project structure and organization
- ANALYZE import patterns and dependency relationships
- REVIEW database models and API structure for consistency
- CHECK for architectural patterns: are we following DDD, clean architecture, etc.?
- IDENTIFY any architectural debt or inconsistencies

**Focus areas:**

- **Directory structure** — logical organization, separation of concerns
- **Dependencies** — are we over-engineering? unnecessary libraries?
- **Models/Schemas** — consistency, proper relationships, normalization
- **APIs** — RESTful design, proper HTTP methods, consistent patterns
- **Configuration** — environment management, secrets handling

### 6. Audit file organization and workflow compliance

**IMPORTANT:** Check for workflow discipline and architectural boundary violations.

- **Root directory audit** — identify files that don't belong in project root
- **Development scripts** — verify all dev scripts follow `run_dev.py` pattern
- **Test file organization** — check tests are in `tests/` directory, not scattered
- **Documentation placement** — verify docs are in proper locations
- **Temporary/experimental files** — flag any `.py` files that look ad-hoc or experimental

**File Organization Rules to Enforce:**

- **Development scripts** — MUST go through `run_dev.py`, not standalone files
- **Test files** — MUST be in `tests/` directory with proper naming (`test_*.py`)
- **Documentation** — MUST be in `docs/` or `.simone/01_PROJECT_DOCS/`
- **Configuration** — MUST follow established patterns (`.env.example`, `pyproject.toml`)
- **Temporary files** — SHOULD NOT exist in committed code

**Red Flags to Identify:**

- Multiple scripts doing similar things (duplicate functionality)
- Random `.py` files in root directory
- Test files outside `tests/` directory
- Development scripts bypassing `run_dev.py`
- Unclear file purposes or experimental code

**CRITICAL:** File proliferation indicates workflow breakdown. Flag for immediate cleanup task creation.

### 7. Evaluate technical decisions and complexity

- ASSESS complexity vs. business value ratio
- REVIEW choice of frameworks, libraries, and tools
- ANALYZE if current patterns will scale with project growth
- IDENTIFY areas where we might be over-complicating simple problems
- CHECK for premature optimization or under-optimization

**IMPORTANT:** Think like an experienced developer. Are we solving the right problems the right way?

### 8. Critique implementation quality (John Carmack perspective)

Think as John Carmack would: focus on simplicity, performance, and maintainability, but keep the projects goal in mind. Especially long term vision as well. Don't over simplify.

- **Simplicity:** Are we solving problems in the most straightforward way?
- **Performance:** Are there obvious performance issues or bottlenecks?
- **Maintainability:** Will a new developer understand this code in 6 months?
- **Robustness:** How does the system handle edge cases and failures?
- **Technical debt:** What shortcuts are we taking that will hurt us later?

Be **brutally honest**. Carmack-level critique means no sugar-coating but still staying true to the project's reality.
Be thorough and **go above and beyond** in your analysis - leave no stone unturned.

### 9. Provide comprehensive assessment with recommendations

**IMPORTANT:** Get current timestamp and create output file

- Get current timestamp using system date command
- Create filename: `YYYY-MM-DD-HH-MM-<judgment-slug>.md` in `.simone/10_STATE_OF_PROJECT/`
- Judgment slug should be 2-3 words describing overall project health (e.g., "solid-progress", "needs-focus", "critical-issues", "doing-great", "on-track")

**IMPORTANT:** Write full report to the timestamped file with this format:

```markdown
# Project Review - [YYYY-MM-DD HH:MM]

## 🎭 Review Sentiment

[3 emojis only - no explanations]

## Executive Summary

- **Result:** EXCELLENT | GOOD | NEEDS_WORK | CRITICAL_ISSUES
- **Scope:** What areas were reviewed
- **Overall Judgment:** [2-3 word assessment used in filename]

## Test Infrastructure Assessment

- **Test Suite Status**: [PASSING/FAILING/BLOCKED] (X/Y tests)
- **Test Pass Rate**: X% (Y passed, Z failed)
- **Test Health Score**: X/10
- **Infrastructure Health**: [HEALTHY/DEGRADED/BROKEN]
  - Import errors: [count]
  - Configuration errors: [count]
  - Fixture issues: [count]
- **Test Categories**:
  - Unit Tests: X/Y passing
  - Integration Tests: X/Y passing
  - API Tests: X/Y passing
- **Critical Issues**:
  - [List of blocking test infrastructure problems]
  - [Module import mismatches]
  - [Environment configuration failures]
- **Sprint Coverage**: [% of sprint deliverables with passing tests]
- **Blocking Status**: [CLEAR/BLOCKED - reason]
- **Recommendations**:
  - [Immediate fixes required]
  - [Test infrastructure improvements needed]

## Development Context

- **Current Milestone:** [ID and status from manifest]
- **Current Sprint:** [ID and focus]
- **Expected Completeness:** [what SHOULD be done at this stage]

## Progress Assessment

- **Milestone Progress:** [percentage complete]
- **Sprint Status:** [current sprint assessment]
- **Deliverable Tracking:** [what's done vs planned]

## Architecture & Technical Assessment

- **Architecture Score:** 1-10 rating with explanation
- **Technical Debt Level:** LOW | MEDIUM | HIGH with specific examples
- **Code Quality:** [overall assessment with examples]

## File Organization Audit

- **Workflow Compliance:** GOOD | NEEDS_ATTENTION | CRITICAL_VIOLATIONS
- **File Organization Issues:** [list any misplaced files, duplicate scripts, etc.]
- **Cleanup Tasks Needed:** [specific file moves/deletions/consolidations required]

## Critical Findings
### Critical Issues (Severity 8-10)

[Lists of must-fix problems headed with #### heading, one empty line and then list of details]

### Improvement Opportunities (Severity 4-7)

[List of recommended enhancements headed with #### heading, one empty line and then list of details]

## John Carmack Critique 🔥

[Top 3 brutally honest observations about technical decisions]

## Recommendations

Based on your findings recommend Action items - chose whatever fits your findings

- **Important fixes:** What needs to be fixed immediately?
- **Optional fixes/changes:** What would still be recommended though optional?
- **Next Sprint Focus:** Can the user move to the next sprint?

```

**IMPORTANT:** Be specific with file paths and line numbers. This review should be actionable and permanently archived.
