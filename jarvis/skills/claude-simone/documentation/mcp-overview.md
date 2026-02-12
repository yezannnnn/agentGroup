---
sidebar_position: 1
---

# Overview

The MCP (Model Context Protocol) Server is the next-generation implementation of the Simone framework. It replaces the file-based command system of the legacy version with a robust, standardized server architecture.

## What is MCP?

The Model Context Protocol is a specification that defines a standard way for AI models to interact with external tools and data sources (i.e., the project's context). By implementing an MCP server, Simone can provide prompts and tools to any compatible AI client in a structured and discoverable way.

:::info
This shift to a protocol-based approach enhances reliability and reduces misinterpretation compared to traditional file-based command systems.
:::

## Key Features

### Protocol-Based Interaction

*   Instead of relying on the AI to read and interpret Markdown command files, the MCP server communicates over a formal protocol. This is more reliable and less prone to misinterpretation.

### Modern Tech Stack

*   Built with TypeScript and Node.js, the server benefits from static typing, a robust ecosystem, and excellent performance.

### Advanced Templating

*   It uses Handlebars for its prompt templating system, allowing for more complex logic, partials, and helpers. This makes the prompts more dynamic and adaptable to the project's state.

### Centralized Configuration

*   Project configuration is managed through a central `.simone/project.yaml` file, providing a clear and structured way to define the project's stack, tooling, and methodology.

### Activity Logging

*   A new, core feature of the MCP server is the built-in activity logger. It uses an SQLite database to keep a persistent record of all development activities, which can be used for progress tracking, analysis, and generating summaries.

## Current Status

:::warning
The MCP server is currently in the early stages of development. While it implements many core features, it is not yet feature-complete compared to the legacy system and is not recommended for production use. It represents the future direction of the Simone project.
:::
