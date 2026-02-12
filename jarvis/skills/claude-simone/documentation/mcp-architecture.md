---
sidebar_position: 2
---

# Architecture

The MCP Server is designed with a modular and extensible architecture, built on modern TypeScript and Node.js principles. It is intended to run as a persistent background process that serves context to a connected AI client.

## System Diagram: Component Interaction

This diagram shows the high-level architecture of the MCP Server and its interaction with the AI client and the project.

```mermaid
graph TD
    subgraph AI Client
        A[AI Development Tool] <-->|MCP over Stdio| B(Simone MCP Server)
    end

    subgraph Project
        C[/.simone/project.yaml]
        D[/.simone/prompts/]
        E[/.simone/simone.db]
        F[Project Source Code]
    end

    subgraph Server Internals
        G[Prompt Handler]
        H[Tool Registry]
        I[Config Loader]
        J[Activity Logger]
    end

    B --> I
    I --> C

    B --> G
    G --> D

    B --> H
    H --> J
    J --> E

    A -->|Performs Work| F

    style A fill:#ccf,stroke:#333,stroke-width:2px
    style B fill:#cfc,stroke:#333,stroke-width:2px
    style F fill:#f9f,stroke:#333,stroke-width:2px
```

### Architectural Components

1.  **Server Core:** The main entry point of the application (`index.ts`). It initializes the MCP server from the `@modelcontextprotocol/sdk`, sets up request handlers, and connects to the transport layer (currently Stdio).

2.  **Config Loader:** Responsible for loading and validating the project's configuration from `.simone/project.yaml`. It provides a structured way to access project metadata, context paths, and tooling information.

3.  **Prompt Handler:** Manages the loading, caching, and rendering of prompts. It uses Handlebars for templating, allowing for dynamic prompts that can react to the project's configuration. It supports both built-in and project-specific prompts.

4.  **Tool Registry:** A central registry for all available MCP tools. The primary tool currently implemented is the `ActivityLogger`.

5.  **Activity Logger:** A key service that provides the `log_activity` tool. It interacts with an SQLite database (`.simone/simone.db`) to provide a persistent log of all development activities.

6.  **Transport Layer:** Communication with the AI client is handled via a transport layer. The default implementation uses `StdioServerTransport`, meaning the server communicates over standard input and output, which is a common pattern for development tools.