# Contributing to Simone

## Branch Protection

The `master` branch is protected. All changes must go through pull requests.

## Workflow

1. Create a feature or fix branch:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. Make your changes and commit using conventional commits:
   ```bash
   git commit -m "feat: add new feature"
   git commit -m "fix: resolve issue with X"
   ```

3. Push your branch:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a pull request on GitHub

5. Wait for automated checks:
   - Claude review must pass
   - All PR conversations must be resolved

## Branch Protection Rules

The following rules are enforced on `master`:

- ✅ **No direct pushes** - All changes via PR
- ✅ **Required status checks** - Claude review must pass
- ✅ **Strict status checks** - Branch must be up to date
- ✅ **Dismiss stale reviews** - Reviews dismissed on new pushes
- ✅ **Conversation resolution** - All PR comments must be resolved
- ✅ **Enforce for admins** - Rules apply to everyone
- ❌ **Force pushes** - Not allowed
- ❌ **Branch deletion** - Not allowed

## Simone Prompts

Use these prompts in Claude Code to help with the PR workflow:

- `/create_issue` - Create a GitHub issue
- `/work_issue` - Start working on an issue with proper branch
- `/create_pr` - Create a pull request with proper formatting
- `/create_commit` - Create well-formatted commits