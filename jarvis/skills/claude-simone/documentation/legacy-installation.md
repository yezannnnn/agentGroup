---
sidebar_position: 1
---

# Legacy System: Installation

The legacy Simone system is the current, stable version and is the recommended way to start managing your project with AI.

## Quick Start

For the fastest setup, you can use the `hello-simone` installer. This command will create the necessary `.simone` and `.claude` directories in your project and populate them with the required templates and commands.

From the root of your project, run:

```bash
npx hello-simone
```

This command can also be used to safely update an existing Simone installation; your existing command files will be backed up automatically.

## Initializing Your Project

Once the files are in place, you need to initialize the project. This allows Simone to analyze your codebase and create the initial set of project documents.

In your AI chat interface (e.g., Claude Code), run:

```
/simone:initialize
```

The AI will guide you through a conversational setup process. It can work with new or existing codebases and can help you create project documentation (like architecture overviews) or import documents you already have.

## Next Steps: Defining Your Project Work

After initialization, your next step is to define the work to be done within Simone. This typically follows a structured planning process:

### 1. Plan a Milestone

*   **Action:** Manually create a new milestone directory and documents in `.simone/02_REQUIREMENTS/`.
*   **Purpose:** To define the high-level goals and requirements for a major feature or project phase. This sets the overall direction for the work to come.

### 2. Break Down into Sprints

*   **Command:** `/simone:create_sprints_from_milestone`
*   **Purpose:** To analyze a milestone's requirements and break them down into smaller, logical sprints.

### 3. Create Tasks for the Current Sprint

*   **Command:** `/simone:create_sprint_tasks`
*   **Purpose:** To generate detailed, actionable tasks for your *current* sprint. This is done one sprint at a time to ensure tasks are based on the most recent state of the codebase.

Once tasks are created, you are ready to begin development with the `/simone:do_task` command.