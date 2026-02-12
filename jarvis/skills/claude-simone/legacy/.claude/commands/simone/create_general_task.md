# Create General Task - Execute top to bottom

Creates a new general task in `.simone/04_GENERAL_TASKS/` following project documentation standards.

## Create a TODO with EXACTLY these 10 Items

1. Parse task arguments and determine task ID
2. Load project context and documentation requirements
3. Verify task doesn't duplicate existing work
4. Research codebase for implementation context
5. Create task file using standard template
6. Fill in task details with proper context
7. Add technical guidance and codebase references
8. Update project manifest with new task
9. Validate task alignment with architecture
10. Perform final quality check and report

## DETAILS on every TODO item

### 1. Parse task arguments and determine task ID

The argument format is: `<Task Title or Description>`

- If arguments are empty, prompt user for task details
- Generate sequential task ID by examining existing tasks in `.simone/04_GENERAL_TASKS/`
- Find highest task number (T###) and increment by 1
- Format: `T###_<Task_Title_Snake_Case>.md`
- **IMPORTANT:** Task IDs must be sequential with no gaps

### 2. Load project context and documentation requirements

Use PARALLEL SUBAGENTS to READ and UNDERSTAND the project's context:

- READ `.simone/00_PROJECT_MANIFEST.md` - Get current project state and direction
- READ `.simone/01_PROJECT_DOCS/ARCHITECTURE.md` - Understand system constraints
- READ latest files in `.simone/10_STATE_OF_PROJECT/` - Review current state
- SCAN `.simone/05_ARCHITECTURE_DECISIONS/` for relevant ADRs
- **IMPORTANT:** General tasks must align with documented architecture

### 3. Verify task doesn't duplicate existing work

**SEARCH** comprehensively for potential duplicates:

- Check all files in `.simone/04_GENERAL_TASKS/`
- Search sprint tasks in `.simone/03_SPRINTS/*/T*.md`
- Look for similar functionality in completed milestones
- **CRITICAL:** If duplicate found, stop and report to user with file reference

### 4. Research codebase for implementation context

Based on the task description, use PARALLEL SUBAGENTS to:

- SEARCH for existing patterns similar to what the task requires
- IDENTIFY key interfaces, classes, or modules that will be affected
- FIND examples of similar implementations in the codebase
- LOCATE relevant test patterns and existing test files
- DISCOVER error handling and logging patterns used
- MAP OUT integration points with existing code
- **DOCUMENT** all findings for inclusion in task

### 5. Create task file using standard template

**USE** the task template in `.simone/99_TEMPLATES/task_template.md` as base structure:

- Copy template structure exactly
- Place file in `.simone/04_GENERAL_TASKS/T###_<Title>.md`
- Include timestamp: Execute `date '+%Y-%m-%d %H:%M:%S'` for creation time
- **IMPORTANT:** Follow template structure precisely - no deviations

### 6. Fill in task details with proper context

Populate the task file with:

- **Title**: Clear, actionable task name
- **Context**: Link to architecture docs and project state
- **Requirements**: Specific, measurable outcomes
- **Acceptance Criteria**: Clear definition of done
- **Dependencies**: Reference relevant sprints/milestones
- **Implementation Notes**: Technical approach aligned with architecture
- **CRITICAL:** All content must reference existing documentation

### 7. Add technical guidance and codebase references

**Technical Guidance section:**

- Key interfaces and integration points discovered in step 4
- Specific imports and module references from codebase
- Existing patterns to follow (with file references)
- Database models or API contracts to work with
- Error handling approach used in similar code
- Testing patterns found in the codebase

**Implementation Notes section:**

- Step-by-step implementation approach based on research
- Key architectural decisions to respect (reference ADRs)
- Specific files and functions to modify or extend
- Testing approach based on existing test patterns
- Performance considerations if relevant

**IMPORTANT:** Do NOT include code examples. Provide structural guidance and file references only.

### 8. Update project manifest with new task

**UPDATE** `.simone/00_PROJECT_MANIFEST.md`:

- Add task to "## General Tasks" section
- Format: `- [ ] T###: [Task Title] - Status: Not Started`
- Maintain alphabetical/numerical ordering
- Link to task file: `[T###](04_GENERAL_TASKS/T###_Title.md)`
- **IMPORTANT:** Preserve all existing content

### 9. Validate task alignment with architecture

**VERIFY** task compliance:

- Check task doesn't contradict architecture principles
- Ensure implementation approach uses established patterns
- Validate dependencies exist and are correct
- Confirm task scope is appropriate (not too broad/narrow)
- Technical guidance aligns with existing codebase patterns
- **CRITICAL:** Documentation is source of truth - any deviation needs justification

### 10. Perform final quality check and report

**QUALITY CHECK**:

- Task file follows template completely
- All sections properly filled including new technical guidance
- References to documentation and codebase are valid
- Task ID is sequential and unique
- Manifest updated correctly
- Technical guidance references actual files and patterns
- No scope creep or architecture violations

**OUTPUT FORMAT**:

```markdown
✅ **Created**: T###_<Title>.md
📋 **Type**: General Task
🎯 **Purpose**: [One-line summary]
📚 **References**: [Key documentation links]
🔧 **Key Integration Points**: [Main files/modules to modify]
🧪 **Test Approach**: [Testing pattern to follow]
⏭️ **Next Step**: Review task details and run `/do_task T###` to begin
```
