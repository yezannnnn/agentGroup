# Project Config Schema Audit

## Purpose

Define exactly what each field in the project.yaml configuration does and how it affects the MCP server behavior.

## Schema Analysis

### 1. ProjectMetadata

```yaml
project:
  name: string        # USED: Shows in prompts as {{project.name}}
  description: string # USED: Shows in prompts for context
  type: single|monorepo # NOT USED: Informational only (keep for future)
  version: string     # REMOVED: Confusing in monorepo context
```

**Action Items:**

- ✅ Remove version field
- ❓ Should type affect how contexts are presented in prompts?

### 2. ProjectContext

```yaml
contexts:
  - name: string      # USED: Context identifier in prompts
    path: string      # USED: Relative path for file operations
    stack:            # PARTIALLY USED
    tooling:          # USED: Commands in prompts
    methodology:      # NOT USED: Future planning features
```

**What each field should do:**

- `name`: Identify context in multi-project setups
- `path`: Root for all file operations in that context
- `stack`: Inform AI about tech stack for better suggestions
- `tooling`: Provide actual commands to run
- `methodology`: Guide development approach suggestions

### 3. StackConfig

```yaml
stack:
  language: string    # Should inform syntax highlighting, file extensions
  framework:          # Should affect boilerplate suggestions
    name: string
    version: string
    enabled: boolean
  database:           # Should inform query examples, migrations
    type: string
    orm: string
    enabled: boolean
  styling:            # Should affect component examples
    system: string
    enabled: boolean
```

**Current Usage:** Only checked for enabled/disabled
**Should Do:** Provide context-aware code examples

### 4. ToolingConfig

```yaml
tooling:
  lint:
    enabled: boolean
    command: string   # USED: Shown in prompts
    autofix: string   # USED: Alternative command
    config: string    # NOT USED: Could point to config file
  test:
    enabled: boolean
    command: string   # USED: Test execution
    coverage: string  # USED: Coverage command
    watch: string     # USED: Watch mode
  format:
    enabled: boolean
    command: string   # USED: Format command
    check: string     # USED: Check-only mode
  commit:
    enabled: boolean
    command: string   # USED: How to commit
```

**Well Defined:** Commands are used in prompts via partials

### 5. MethodologyConfig

```yaml
methodology:
  development: tdd|bdd|none  # Should guide test-first suggestions
  architecture: clean|mvc|microservices|none  # Should affect structure suggestions
  workflow: gitflow|github-flow|trunk-based|none  # Should affect branch strategies
```

**Current Usage:** NOT USED
**Potential:** Could customize task creation, PR workflows

### 6. GitHubConfig

```yaml
github:
  repository: owner/repo  # USED: For issue/PR creation
  tool: mcp|cli          # USED: Which tool to use (gh CLI vs GitHub MCP)
  defaultLabels: []      # USED: Auto-apply to new issues
```

**Well Defined:** Clear purpose and usage

## Questions to Resolve

1. **Loose typing with `[key: string]: any`** - Should we restrict this?
2. **Feature enablement pattern** - Is `enabled: boolean` on everything useful?
3. **Stack information** - How should prompts use language/framework info?
4. **Methodology** - Worth keeping if not used?
5. **Custom properties** - What valid use cases exist?

## Recommendations

### Keep As-Is

- ProjectContext structure
- ToolingConfig with commands
- GitHubConfig

### Enhance

- Stack config should actively inform code generation
- Add validation for command existence
- Document which fields affect which prompts

### Consider Removing

- Methodology (unless we build features for it)
- Custom properties `[key: string]: any` (or document use cases)

### Add

- Schema version field (for migration support)
- Validation rules for paths
- Required vs optional field documentation
