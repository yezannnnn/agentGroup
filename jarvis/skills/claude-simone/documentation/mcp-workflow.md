---
sidebar_position: 3
---

# Recommended Workflow

The workflow for the MCP Server is more direct and tool-oriented than the legacy system. Instead of using high-level commands that guide the AI through a long process, the MCP server exposes a set of focused prompts and tools that the AI can use as needed.

## The Development Cycle

### 1. Configuration: Defining Your Project

*   **Action:** Create or update the `.simone/project.yaml` file.
*   **Purpose:** To define the project's structure, stack, and tooling. This configuration is loaded by the server and can be used to dynamically adjust the behavior of prompts and tools.

### 2. Prompt-Driven Interaction: Initiating Actions

*   **Action:** The user or AI invokes a prompt by name (e.g., `create-task`, `summarize-activity`).
*   **Purpose:** The server uses its Handlebars templating engine to render a detailed, context-rich prompt based on the project's configuration and the arguments provided. This is the primary way to initiate complex actions.

### 3. Tool Usage: Structured Project Interaction

*   **Action:** The AI uses the tools exposed by the server, such as `log_activity`.
*   **Purpose:** To interact with the project in a structured way. For example, after completing a piece of work, the AI would use `log_activity` to record what it did. This is a more explicit and reliable way of tracking progress than parsing AI chat history.

### 4. Continuous Logging: Building Project History

*   **Tool:** `log_activity`
*   **Purpose:** Throughout the development process, all significant actions should be logged. This creates a persistent, queryable history of the project's development, which can then be used by other prompts (like `summarize-activity`).

## Example Scenario

A typical interaction might look like this:

1.  A developer wants to create a new feature. They invoke the `create-task` prompt.
2.  The Simone MCP server returns a detailed, interactive prompt that guides the AI through the process of defining the task, based on the project's configured workflow.
3.  The AI and the developer work through the prompt, defining the task's specification.
4.  Once the task is defined, the AI might use a (future) `github_create_issue` tool to create an issue on GitHub.
5.  The AI would then immediately call the `log_activity` tool to record that a new task was created.
6.  When a developer starts working on the task, they would use the `do_task` prompt, and upon completion, another `log_activity` call would be made.

This workflow is more granular and tool-centric, which is a more robust and extensible model for AI-assisted development.