---
sidebar_position: 2
---

# do_task

The `do_task` command is the primary command for executing development work. It instructs the AI to pick up a specific task and implement it.

## Usage

To let the AI select the next available task:
```
/simone:do_task
```

To specify a task directly:
```
/simone:do_task T01_S01
```

## Arguments

*   **`task_id`** (optional): The ID of the task to execute (e.g., `T01_S01`, `T003`). If not provided, the AI will select the next open task from the current sprint or the general task list.

## Description: The Core Development Loop

This command orchestrates the core development loop, ensuring the AI works with full context and performs necessary quality checks:

### 1. Task Identification & Analysis

*   **Identifies Task:** It finds the specified task file (or the next available one) in the `.simone/03_SPRINTS/` or `.simone/04_GENERAL_TASKS/` directories.
*   **Analyzes Task:** It reads the task description, goals, acceptance criteria, and any technical guidance provided within the task file.

### 2. Context Validation

*   **Validates Context:** Before starting, it performs a critical context validation to ensure the task belongs to the current sprint, its dependencies are met, and it aligns with the project's overall requirements.

### 3. Execution & Status Update

*   **Sets Status:** It updates the task's status to `in_progress` in both the task file and the project manifest.
*   **Executes Work:** It follows the implementation plan outlined in the task file, iterating through the subtasks and making the required code changes in the project codebase.

### 4. Quality Assurance & Finalization

*   **Performs Quality Checks:** After the implementation is complete, it automatically runs a code review and the project's test suite to ensure the changes are high-quality and don't introduce regressions.
*   **Finalizes Status:** Upon successful review and testing, it marks the task as `completed` and renames the task file to reflect this (e.g., `TX01_S01...`).

## When to Use

:::info
Use this command whenever you are ready to start development work on a planned and detailed task.
:::