# Analyze changes and create logical git commits with user confirmation

Follow these instructions from top to bottom.

## Create a TODO with EXACTLY these 6 items

1. Parse arguments and analyze git status
2. Review changes and group by logical commits
3. Propose commit structure and messages
4. Check if user approval is necessary
5. Execute approved commits
6. Report commit results

---

## 1 · Analyze git status and parse arguments

- Run these commands in parallel for maximum efficiency: `git status`, `git diff --staged`, `git diff`
- List all changed files with their folder structure to understand the scope

### CRITICAL: Argument Interpretation Rules

**Context Provided** (when <$ARGUMENTS> contains text):

- If YOLO is part of the <$ARGUMENTS> it is meant to skip user Approval (see Step 4 on your Todo)
- The other text in <$ARGUMENTS> represents a **task ID**, **sprint ID**, or other **contextual identifier** provided by the user
- This is NOT a file path - it's a semantic context for filtering changes
- **PRIMARY FOCUS**: Only commit files directly related to this context
- **SECONDARY CONSIDERATION**: After handling the primary context, ask if user wants to commit other unrelated changes

**Task ID Pattern** (e.g., T01_S02, TX03_S01, T003):

- Sprint Tasks: `T<NN>_S<NN>` format (e.g., T01_S02, T03_S02)
- Completed Sprint Tasks: `TX<NN>_S<NN>` format (e.g., TX01_S02, TX03_S01)
- General Tasks: `T<NNN>` format (e.g., T001, T002)
- Completed General Tasks: `TX<NNN>` format (e.g., TX001, TX002)
- Search for this task ID in:
  - `.simone/03_SPRINTS/` directory (for sprint tasks)
  - `.simone/04_GENERAL_TASKS/` directory (for general tasks)
  - Task metadata in files (look for `task_id: T01_S02` in frontmatter)
  - Git diff content (to see if code comments or commits reference the task)
- Identify ALL files that were modified as part of this task's implementation
- This includes: source code, tests, configuration, and the task documentation file itself

**Sprint ID Pattern** (e.g., S01, S02):

- When only sprint ID is provided, commit all changes related to ANY task within that sprint
- Search pattern: `T*_S<NN>` in the sprint directory
- Example: "S02" would include changes for T01_S02, T02_S02, T03_S02, etc.

**No Context Provided** (when <$ARGUMENTS> is empty):

- Analyze all changes and group them logically
- Propose separate commits for different logical units of work

### Implementation Steps

1. First, determine if <$ARGUMENTS> contains any text
2. If yes, explicitly state: "Context provided: '$ARGUMENTS' - I will focus on changes related to this context"
3. If it's a task ID pattern, find the task file and understand what was implemented
4. Filter the changed files to only those related to the identified context
5. If no files match the context, inform the user: "No changes found related to '$ARGUMENTS'"
6. If unrelated changes exist, mention them but DO NOT include in initial commit proposal

## 2 · Review changes and group by logical commits

### PRIORITY: Context Filtering

**If context provided in arguments**:

1. **FILTER FIRST**: Separate changes into two groups:
   - **Related to context**: Files that are part of the task/context implementation
   - **Unrelated to context**: Everything else
2. **FOCUS**: Only analyze the "related to context" group for the first commit
3. **DEFER**: Keep the "unrelated" group for potential later commits (only if user requests)

**Standard grouping logic** (for no-context or within-context grouping):

- **Think about** which changes belong together logically:
  - Task completion (group by task ID when applicable)
  - Feature additions (group by feature scope)
  - Configuration updates (group separately)
  - Documentation updates (group by documentation type)
  - Bug fixes (group by related functionality)
- **Think carefully** to ensure each commit represents one logical change that can be understood and potentially reverted independently
- Avoid mixing unrelated changes in the same commit
- Consider dependencies between changes when ordering commits

## 3 · Propose commit

### Context-Aware Commit Proposal

**When context was provided** (e.g., task ID):

- **FIRST COMMIT**: Must contain ONLY files related to the provided context
- State clearly: "This commit includes changes for $ARGUMENTS"
- After this commit is done, then ask: "There are also unrelated changes in [list files]. Would you like me to create additional commits for these?"

**When no context provided**:

- Propose commits based on logical grouping of all changes

For the next commit to create:

- **Context**: If applicable, which task/context this commit addresses
- **Files**: List the specific files to be included
- **Commit message**: Use conventional commit format, be clear and concise
  - **CRITICAL:** Must not contain any attribution to Claude, Anthropic, or AI assistance
  - If task-related, include task ID in message (e.g., "feat(agents): implement T01_S02 coordinator agent" or "fix(api): resolve T003 authentication issue")
- **Reasoning**: Brief explanation of why these changes belong together

## 4 · Check if user approval is necessary

If YOLO **IS** part of the <$ARGUMENTS> skip this and jump to next step.

Otherwise ask the User for approval.

- Show the complete commit plan including files and message
- Wait for explicit user confirmation before proceeding
- If user says no, ask what should be changed
- If user wants to modify the commit message or scope, make adjustments

## 5 · Execute approved commit and continue

For the approved commit:

- Stage the specified files with `git add`
- **IMPORTANT:** We are using pre-commit hooks that will likely report shortcomings. You need to fix them. Don't skip validation unless there are open tasks adressing especially these problems.
- **Create the commit** with the approved message
- Verify commit was created successfully
- **IMPORTANT:** If there are more commits remaining, return to step 3 for the next commit
- Only proceed to step 6 when all commits are completed

## 6 · Report commit results

Provide summary:

- **Commits Created**: List each commit with SHA and message
- **Files Committed**: Total count of files committed
- **Remaining Changes**: Any uncommitted changes still pending
- **Repository Status**: Current git status after commits
