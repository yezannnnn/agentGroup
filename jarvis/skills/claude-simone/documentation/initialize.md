---
sidebar_position: 1
---

# initialize

The `initialize` command sets up the Simone framework in a new or existing project.

## Usage

```
/simone:initialize
```

## Description

This is the first command you should run when setting up Simone. It performs the following actions through an interactive, conversational process:

### 1. Project Analysis

*   **Scans and Analyzes:** It inspects your project to detect its characteristics, such as the programming language (Node.js, Python, etc.) and existing documentation.
*   **Confirms with User:** It presents its findings and asks for your confirmation before proceeding.

### 2. Document Handling

*   **Handles Existing Documents:** It checks for any existing Simone documents. If found, it will ask whether to use them or start fresh. It can also help you import your own existing project documentation into the Simone structure.
*   **Guides Document Creation:** If you are starting fresh, it will perform a deeper analysis of your codebase to create draft versions of key documents, like an `ARCHITECTURE.md`.

### 3. Initial Project Setup

*   **Creates First Milestone:** It helps you define and create your first milestone, ensuring it is realistic and well-scoped for the current state of your project.
*   **Generates Manifest:** Finally, it generates the `00_PROJECT_MANIFEST.md` file based on all the information gathered.

## When to Use

:::info
This command should typically only be run **once** at the very beginning of integrating a project with Simone.
:::