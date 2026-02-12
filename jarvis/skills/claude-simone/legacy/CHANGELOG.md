# Changelog

## 2025-05-30

### Added

- `npx hello-simone` quick start command for easy Simone installation
- Interactive, adaptive initialize command that:
  - Auto-detects project type and framework
  - Guides users through conversational setup
  - Creates documentation through Q&A process
  - Adapts to existing vs new projects

### Changed

- initialize command completely rewritten for better user experience
- Removed complex branching logic in favor of adaptive process
- Focus on conversational interaction rather than rigid steps

### Improved

- Better handling of existing documentation during setup
- Smart project detection (Node.js, Python, PHP, etc.)
- Milestone creation now interactive and context-aware

## 2025-05-29

### Added

- ADR template for architecture decision records
- Task ID filtering in commit command (T01_S02, TX003 patterns)
- YOLO mode in commit command to skip user approval
- Code review results now write to task Output Log sections
- create_general_task command for structured task creation
- create_sprint_tasks command for detailed sprint planning
- create_sprints_from_milestone command for milestone-based sprint planning
- prime command for quick project context loading
- yolo command for autonomous task execution without user interaction

### Changed

- Date format simplified to YYYY-MM-DD HH:MM in templates
- Milestone template heading structure updated
- do_task command now uses parallel subagents and updates project manifest
- project_review command removes timeline pressure and focuses on current state

### Removed

- create_sprint, create_task, plan_milestone commands (replaced by new workflow)

## Developer Notes

This update represents a significant evolution based on real-world usage and user feedback. The command architecture has been substantially enhanced with better use of parallel agents, loops, and conditionals, which work surprisingly well in practice.

**Command Complexity**: The enhanced commands may behave differently between Claude Opus and Sonnet models. While the complexity might be challenging for Sonnet, testing suggests it should handle the workflows effectively.

**Task Quality Improvements**: The new `create_sprint_tasks` and `create_general_task` commands now provide much better context and codebase references, resulting in notably higher quality task generation with specific implementation guidance.

**YOLO Mode Warning**: The standalone `yolo` command requires extreme caution. It should only be used:

- Within isolated development environments
- With Claude Code's permission-skipping mode enabled (`claude --dangerously-skip-permissions`)
- Never on production systems or systems with important data

The YOLO mode can potentially modify or delete files outside your project directory. Use at your own risk and only in completely isolated environments.

**Feedback Welcome**: Submit issues or pull requests on GitHub. This framework continues to evolve based on real-world usage patterns.

## 2025-05-23

Initial release of Simone framework
