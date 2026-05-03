---
name: git-workflow
description: Git 工作流自动化和最佳实践指南
---

# Git Workflow Skill

Git 工作流自动化和最佳实践指南。

## 使用场景

- 团队协作的 Git 流程
- 分支管理策略
- 代码提交规范
- 发布流程自动化

## 分支策略

### Git Flow（推荐用于版本发布）

```
main/master     生产分支，始终保持可部署
  ↑
develop         开发分支，集成功能
  ↑
feature/*       功能分支，从 develop 创建
  ↑
release/*       发布分支，从 develop 创建
  ↑
hotfix/*        热修复分支，从 main 创建
```

#### 工作流程
```bash
# 1. 开始新功能
git checkout develop
git pull origin develop
git checkout -b feature/user-authentication

# 2. 开发并提交
git add .
git commit -m "feat: add user login functionality"

# 3. 完成功能，合并到 develop
git checkout develop
git merge --no-ff feature/user-authentication
git branch -d feature/user-authentication
git push origin develop
```

### GitHub Flow（推荐用于持续部署）

```
main           主分支，可直接部署
  ↑
feature/*      功能分支，通过 PR 合并
```

#### 工作流程
```bash
# 1. 创建功能分支
git checkout -b feature/add-search

# 2. 开发和提交
git commit -am "feat: implement search functionality"
git push origin feature/add-search

# 3. 创建 Pull Request，代码审查后合并到 main
# 4. 删除功能分支
```

### Trunk-Based Development（推荐用于大型团队）

```
main           主干分支，短周期分支快速合并
  ↑
short-lived/*  短期分支（<1天），直接合并
```

## 提交规范（Conventional Commits）

### 提交格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型说明
| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能）|
| `refactor` | 重构 |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具/依赖更新 |
| `ci` | CI/CD 配置 |

### 示例
```bash
# 功能提交
git commit -m "feat(auth): add JWT token validation"

# 修复提交
git commit -m "fix(api): resolve null pointer in user endpoint

The error occurred when user object was not found in cache.
Closes #123"

# 破坏性变更
git commit -m "feat(api)!: change response format for user endpoint

BREAKING CHANGE: response now wraps data in 'data' field"
```

## 常用工作流命令

### 日常开发
```bash
# 更新主分支
git checkout main
git pull origin main

# 创建并切换分支
git checkout -b feature/my-feature

# 查看状态
git status

# 查看修改
git diff

# 暂存文件
git add filename          # 特定文件
git add .                 # 所有修改
git add -p                # 交互式选择

# 提交
git commit -m "message"   # 单行消息
git commit                # 打开编辑器

# 推送
git push -u origin feature/my-feature
```

### 分支管理
```bash
# 查看分支
git branch                # 本地分支
git branch -r             # 远程分支
git branch -a             # 所有分支

# 切换分支
git checkout branch-name
git switch branch-name    # Git 2.23+

# 删除分支
git branch -d branch-name     # 已合并
git branch -D branch-name     # 强制删除

# 重命名分支
git branch -m old-name new-name
```

### 同步与合并
```bash
# 获取远程更新
git fetch origin

# 拉取并合并
git pull origin main

# 合并分支
git checkout main
git merge feature/my-feature

# 变基（保持线性历史）
git checkout feature/my-feature
git rebase main

# 解决冲突后继续
git add .
git rebase --continue
```

### 撤销操作
```bash
# 撤销工作区修改
git checkout -- filename
git restore filename      # Git 2.23+

# 撤销暂存
git reset HEAD filename
git restore --staged filename

# 修改最后一次提交
git commit --amend -m "new message"

# 撤销提交（保留修改）
git reset --soft HEAD~1

# 撤销提交（丢弃修改）
git reset --hard HEAD~1

# 查看 reflog 恢复
git reflog
git reset --hard HEAD@{2}
```

## 标签管理

```bash
# 创建标签
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送标签到远程
git push origin v1.0.0
git push origin --tags

# 删除标签
git tag -d v1.0.0
git push origin --delete v1.0.0

# 基于标签创建分支
git checkout -b hotfix/critical v1.0.0
```

## 发布流程

### 标准发布流程
```bash
# 1. 从 develop 创建 release 分支
git checkout -b release/v1.2.0 develop

# 2. 更新版本号，修复最后的问题
git commit -am "chore: bump version to 1.2.0"

# 3. 合并到 main
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"

# 4. 合并回 develop
git checkout develop
git merge --no-ff release/v1.2.0

# 5. 删除 release 分支
git branch -d release/v1.2.0
```

### 热修复流程
```bash
# 1. 从 main 创建 hotfix 分支
git checkout -b hotfix/critical-bug main

# 2. 修复问题
git commit -am "fix: resolve critical bug"

# 3. 合并到 main 和 develop
git checkout main
git merge --no-ff hotfix/critical-bug
git tag -a v1.2.1 -m "Hotfix v1.2.1"

git checkout develop
git merge --no-ff hotfix/critical-bug

# 4. 删除 hotfix 分支
git branch -d hotfix/critical-bug
```

## Pull Request 流程

### 创建 PR 前检查清单
- [ ] 代码自测通过
- [ ] 相关测试已更新/添加
- [ ] 代码符合项目规范
- [ ] 提交信息清晰规范
- [ ] 分支已更新到最新 main/develop

### PR 描述模板
```markdown
## 描述
[简要描述变更内容]

## 类型
- [ ] 新功能
- [ ] Bug 修复
- [ ] 重构
- [ ] 文档更新

## 测试
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 手动测试通过

## 相关 Issue
Closes #123
```

## 配置建议

### .gitignore 模板
```gitignore
# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
target/

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment
.env
.env.local
.env.*.local

# Testing
coverage/
.nyc_output/
```

### Git 配置
```bash
# 设置用户名和邮箱
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 设置默认编辑器
git config --global core.editor "vim"

# 设置别名
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --decorate"

# 设置换行符（Windows）
git config --global core.autocrlf true

# 设置换行符（Mac/Linux）
git config --global core.autocrlf input
```

## 最佳实践

1. **频繁提交**: 小步快跑，频繁提交小变更
2. **写清楚提交信息**: 解释"为什么"而不仅是"做了什么"
3. **一个分支一个功能**: 保持分支聚焦
4. **及时同步**: 经常拉取远程更新
5. **代码审查**: 所有代码都应该被审查
6. **保护主分支**: 禁止直接推送到 main
7. **使用 .gitignore**: 不提交生成的文件
8. **不要提交敏感信息**: 使用环境变量或密钥管理
