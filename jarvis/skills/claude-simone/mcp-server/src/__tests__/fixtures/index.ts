export const fixtures = {
  config: {
    yaml: `name: test-project
description: Test project for unit tests
version: 1.0.0

repo:
  owner: testuser
  name: test-repo

tasks:
  sources:
    - type: github-issues
      labels: ['test', 'todo']
    - type: markdown
      path: docs/tasks.md
      pattern: '- \\[ \\] (.+)'

settings:
  auto_track: true
  log_level: debug`,
    path: '/test/fixtures/config.yaml',
  },
  prompt: {
    yaml: `name: test_prompt
description: Test prompt for unit tests
template: test-template
arguments:
  - name: testArg
    description: Test argument
    required: true
  - name: optionalArg
    description: Optional test argument
    required: false`,
    path: '/test/fixtures/test-prompt.yaml',
  },
  template: {
    content: `# Test Template

{{#if testArg}}
Test argument: {{testArg}}
{{/if}}

{{#if optionalArg}}
Optional argument: {{optionalArg}}
{{/if}}

## Project Info
- Name: {{project.name}}
- Description: {{project.description}}

{{> test-partial}}`,
    path: '/test/fixtures/test-template.hbs',
  },
  partial: {
    content: `## Test Partial
This is a test partial content.`,
    path: '/test/fixtures/test-partial.hbs',
  },
};

export const mockProjectConfig = {
  name: 'test-project',
  description: 'Test project for unit tests',
  version: '1.0.0',
  repo: {
    owner: 'testuser',
    name: 'test-repo',
  },
  tasks: {
    sources: [
      {
        type: 'github-issues',
        labels: ['test', 'todo'],
      },
      {
        type: 'markdown',
        path: 'docs/tasks.md',
        pattern: '- \\[ \\] (.+)',
      },
    ],
  },
  settings: {
    auto_track: true,
    log_level: 'debug',
  },
};