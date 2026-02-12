# Create Tasks for Sprint - Execute top to bottom

Create detailed tasks for an existing sprint with integrated implementation guidance.

## Create a TODO with EXACTLY these 8 Items

1. Identify target sprint and verify it exists
2. Load sprint context and related documentation
3. Check for existing ADRs and technical guidance
4. Analyze sprint deliverables for task breakdown
5. Create individual task files with implementation guidance
6. Link ADRs to relevant tasks
7. Update sprint meta with task references
8. Check quality of your work

Follow step by step and adhere closely to the following instructions for each step.

## DETAILS on every TODO item

### 1. Identify target sprint and verify it exists

Check: <$ARGUMENTS>

**REQUIRED:** Sprint ID must be provided (e.g., S02). If empty, ask user to specify which sprint to detail.

- VERIFY sprint directory exists in `.simone/03_SPRINTS/`
- CHECK sprint meta file exists (e.g., `S02_sprint_meta.md`)
- VERIFY sprint status is not already "completed"
- If tasks already exist, ask user if they want to recreate them or any other guidance

### 2. Load sprint context and related documentation

Use PARALLEL SUBAGENTS to READ and UNDERSTAND the project's context:

- READ `.simone/00_PROJECT_MANIFEST.md` for project context
- READ sprint meta file completely to understand goals and deliverables
- READ parent milestone requirements from `.simone/02_REQUIREMENTS/`
- READ `.simone/01_PROJECT_DOCS/ARCHITECTURE.md` for technical context and decisions

**IMPORTANT:** Sprint tasks must align with documented sprint goals, not expand scope.

### 3. Check for existing ADRs and technical guidance

**USE PARALLEL SUBAGENTS** to execute these commands:

- SEARCH `.simone/05_ARCHITECTURE_DECISIONS/` for ADRs matching sprint ID (e.g., `ADR*_S02_*.md`)
- READ all found ADRs to understand technical decisions
- CHECK sprint meta for ADR references section
- NOTE which technical decisions will affect task implementation
- BUILD RELATIONSHIP in task and subtasks and make clear what to implement

**If conflict in Scope** Between ADR and Sprint goal, try to think about it and ask the user to resolve the conflict.

**If no ADRs found:** Proceed but note that tasks may need clarification during implementation.

### 4. Analyze sprint deliverables for task breakdown

Based on sprint goals and deliverables (execute in Parallel Subagents):

- BREAK DOWN high-level deliverables into concrete, implementable tasks
- ENSURE each task represents a coherent feature or component
- CONSIDER logical dependencies between tasks
- MAP tasks to relevant ADRs for technical guidance
- DEFER complexity assessment until after tasks are fully created with subtasks

### 5. Create individual task files with implementation guidance

**NOW** For each identified Task spin up a Parallel Subagent with these Instructions:

    #### Create a TODO for EACH task

    1. Create basic task structure
    2. Research codebase interfaces
    3. Add technical guidance
    4. Validate task completeness

    ### 1. Create basic task structure

    - ALL TASK FILES must to be created in the Sprint Directory (where the sprint meta file is)
    - CREATE file with naming: `T<NN>_S<NN>_<Descriptive_Name>.md`
    - USE sequential numbering starting from T01
    - FOLLOW task template structure exactly from `.simone/99_TEMPLATES/task_template.md`
    - ADD basic description and objectives from sprint goals

    ### 2. Research codebase interfaces

    - EXAMINE existing codebase for similar patterns and interfaces
    - IDENTIFY specific classes, functions, and imports that will be needed
    - FIND integration points with existing modules
    - NOTE database models, API endpoints, or services to interface with
    - CHECK existing error handling and logging patterns

    ### 3. Add technical guidance

    Add these sections to the task file (add to template if not present):

    **Technical Guidance section:**

    - Key interfaces and integration points in the codebase
    - Specific imports and module references
    - Existing patterns to follow
    - Database models or API contracts to work with
    - Error handling approach used in similar code

    **Implementation Notes section:**

    - Step-by-step implementation approach
    - Key architectural decisions to respect
    - Testing approach based on existing test patterns
    - Performance considerations if relevant

    **IMPORTANT:** Do NOT include code examples. Provide structural guidance and references only.

    #### 4. Validate task completeness

    - ENSURE task has clear implementation path
    - VERIFY all integration points are documented
    - CHECK that guidance references actual codebase elements
    - CONFIRM task is self-contained and actionable

    **REPEAT** `### 5. Create individual task files with implementation guidance` for every Task

### 6. Link ADRs to relevant tasks

- IF relevant ADRs exist
- REFERENCE ADRs that are related
- ADD explanation in Technical Guidance section for how each ADR applies
- ENSURE tasks ONLY reference ADRs that affect their implementation

### 7. Update sprint meta with task references

- EDIT sprint meta file to add/update task list
- ORGANIZE tasks by logical grouping or dependency order
- ADD brief description for each task

### 8. Check quality of your work

Review all created tasks for complexity and split any High complexity tasks:

**Complexity Assessment Process:**

- READ each task file completely including description, goals, acceptance criteria, and subtasks
- ASSESS complexity using your judgment about the overall scope and challenge
- DO NOT base complexity on simple metrics like file counts or estimated hours
- CONSIDER the conceptual difficulty, integration challenges, and unknowns
- MARK complexity as Low, Medium, or High in the task frontmatter

**If ANY task is marked as High complexity:**

- SPLIT the task into 2-3 smaller tasks of Low or Medium complexity
- CREATE new task files with proper sequential numbering
- UPDATE the original high-complexity task file or DELETE it
- ENSURE the split tasks together achieve the original goal
- MAINTAIN logical grouping and dependencies

**After all tasks are finalized:**

- VERIFY all tasks are Low or Medium complexity only
- CHECK task numbering is sequential (T01, T02, T03...)
- UPDATE sprint meta file with final task list
- UPDATE project manifest sprint section to reflect actual tasks created
- GENERATE completion report

**Output format:**

    ```Markdown
    ## Sprint Detailed - [YYYY-MM-DD HH:MM]

    **Sprint:** [Sprint ID] - [Sprint Name]
    **Status:** Planning Complete

    **Tasks Created:** [final count after any splits]
    - Medium Complexity: [count]
    - Low Complexity: [count]

    **Task Splitting Summary:**
    - [Original T03 split into T03 and T04 due to scope]
    - [No other splits needed]

    **Final Task List:**
    1. T01_S02 - [Title] (Complexity: [Level])
    2. T02_S02 - [Title] (Complexity: [Level])
    [Continue for all tasks]

    **Next Steps:**
    - Review tasks for completeness
    - Run `/do_task [FIRST_TASK_IN_SPRINT]` to begin implementation
    ```
