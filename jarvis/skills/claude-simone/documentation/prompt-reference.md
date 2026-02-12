---
sidebar_position: 4
---

# Prompt Reference

The MCP Server provides a set of built-in prompts that can be used to perform common development tasks. These prompts are defined in YAML and use Handlebars for templating, making them highly configurable.

## Available Prompts

Here is a list of the core prompts available in the MCP server, along with their descriptions, arguments, and typical usage scenarios.

### `create-task`

*   **Description:** An interactive prompt that guides the user and AI through the process of defining and creating a new task.
*   **Usage:** This prompt is designed to be used conversationally to elicit requirements, explore solutions, and generate a well-defined task specification, which can then be used to create a GitHub issue.

### `do_task`

*   **Description:** A simple prompt to instruct the AI to begin work on a specific task.
*   **Arguments:**
    *   `task_id` (required): The ID of the task to be executed.
*   **Usage:** This prompt serves as the entry point for the AI to start an implementation task, providing it with the initial context of the project and the task ID.

### `generate-changelog`

*   **Description:** A utility prompt to help with the creation of human-readable changelog entries.
*   **Usage:** It instructs the AI to run the `conventional-changelog` tool to generate raw commit messages and then rewrite them into a user-friendly format suitable for a `CHANGELOG.md` file.

### `pre-commit`

*   **Description:** Generates a pre-commit checklist for the developer or AI.
*   **Usage:** This prompt dynamically generates a checklist of quality assurance steps (like linting, testing, and formatting) based on the project's configuration in `.simone/project.yaml`. It serves as a final quality gate before code is committed.

### `summarize-activity`

*   **Description:** Generates a comprehensive summary of development activity based on the activity log.
*   **Arguments:**
    *   `period` (optional): The time period to summarize (e.g., `today`, `7d`). Defaults to `today`.
*   **Usage:** This prompt queries the activity log database and generates a report including an overview, daily breakdowns, and analysis of productivity patterns.

### `update-issue`

*   **Description:** A prompt for updating an existing GitHub issue.
*   **Usage:** This prompt can be used to close, reopen, edit, or comment on a GitHub issue, providing the necessary commands for either the GitHub CLI or the GitHub MCP server tools, depending on the project's configuration.
