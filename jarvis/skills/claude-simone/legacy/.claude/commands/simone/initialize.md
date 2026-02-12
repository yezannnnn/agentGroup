# Initialize Simone Framework

Initialize the Simone project management framework through an adaptive, interactive process.

## Create a TODO with EXACTLY these items

1. Scan and analyze the project
2. Interactive confirmation with user
3. Check for existing Simone documents
4. Guide document creation process
5. Create first milestone for Simone
6. Generate project manifest
7. Provide next steps

## DETAILS on every TODO item

### 1. Scan and analyze the project

**Detect project characteristics:**

- Check for package.json, requirements.txt, composer.json, etc.
- Identify project type (Node.js, Python, PHP, etc.)
- Scan overall project structure
- Check if this is a new or existing project
- Look for existing documentation (README, docs/, etc.)

**Keep findings brief** - Just identify the essentials

### 2. Interactive confirmation with user

**Present findings conversationally:**

```
I found this to be a [project type] project named [detected name].
Is this correct? Should I proceed with Simone setup?
```

**Get user confirmation before continuing**

### 3. Check for existing Simone documents

**Scan .simone/ directory for:**

- Any documents in 01_PROJECT_DOCS/
- Any milestones in 02_REQUIREMENTS/
- Any existing sprints or tasks
- Current manifest status

**Interactive decision:**

- If documents found: "I found existing documents: [list]. Should we work with these or extend them?"
- If no documents: "No Simone documents found yet. Do you have any existing project documentation you'd like to copy in before we continue?"

**Allow user to:**

- Use existing documents
- Add new documents
- Start fresh
- Cancel to add documents manually first

### 4. Guide document creation process

**Based on user's choice:**

**If starting fresh or extending:**

- Perform deep analysis of the codebase
- Identify key components and architecture patterns
- Create draft ARCHITECTURE.md based on analysis
- Use Q&A style to refine and complete:
  - "What's the main purpose of this project?"
  - "What are the key technical decisions?"
  - "Any important constraints or requirements?"

**If using existing docs:**

- Import and adapt existing documentation
- Fill in any Simone-specific sections
- Ensure compatibility with framework structure

**Keep it conversational and adaptive**

### 5. Create first milestone for Simone

**Determine appropriate first milestone:**

- If new project: Start with setup/foundation milestone
- If existing project: Identify current phase and create appropriate milestone

**Interactive milestone creation:**

- "Based on the project state, I suggest creating milestone: [name]"
- "What would you like to focus on in this milestone?"
- Create milestone structure with initial requirements
- Keep scope realistic and focused

### 6. Generate project manifest

**Automatically generate manifest using:**

- Information gathered during setup
- Created/imported documentation
- Current milestone details
- Project metadata

**No user interaction needed** - Just inform when complete

### 7. Provide next steps

**Customized guidance based on setup:**

```
✅ Simone initialized for [project name]!

Current setup:
- Project type: [type]
- Current milestone: [milestone]
- Documents: [created/imported]

Next steps:
- Review your architecture: 01_PROJECT_DOCS/ARCHITECTURE.md
- Check milestone requirements: 02_REQUIREMENTS/[milestone]/
- Start first task: /simone:create_general_task

Ready to begin development!
```

## ADAPTIVE PROCESS NOTES

- **Stay conversational** - Ask questions naturally, not like a form
- **Be smart** - Use AI to understand context and make intelligent suggestions
- **Allow flexibility** - User can skip, cancel, or modify at any point
- **Focus on value** - Only create what's useful for the specific project
- **Keep it simple** - Don't overwhelm with options or details
