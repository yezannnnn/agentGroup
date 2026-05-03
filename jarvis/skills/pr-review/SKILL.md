---
name: pr-review
description: GitHub PR代码审查技能 - 使用gh CLI进行专业、批量、安全的PR审查
argument-hint: <PR_URL>
---

# GitHub PR Review Skill

使用 `gh` CLI 进行专业、批量且安全的 GitHub Pull Request 审查。

## 工作流程

### 1. 检查前置条件
- 验证 `gh` CLI 已安装且已认证
- 确认可以访问目标仓库

### 2. 草拟审查
- 分析 PR 的代码变更
- 准备所有评论和代码建议
- 使用统一的审查格式

### 3. 向用户展示审查内容
在使用 AskUserQuestion 工具发布前，展示以下内容：
- 文件路径
- 行号
- 评论文本
- 代码建议（如有）

### 4. 获取明确批准
等待用户确认后再发布任何公开评论。

### 5. 使用 Pending Review 模式发布
- 首先创建待处理的审查
- 批量添加所有评论
- 使用适当的事件类型提交：
  - `APPROVE` - 批准
  - `REQUEST_CHANGES` - 请求更改
  - `COMMENT` - 仅评论

## API 调用示例

### 创建 Pending Review
```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  -f commit_id={sha} \
  -f event=COMMENT
```

### 添加评论到 Review
```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews/{review_id}/comments \
  -f path={file_path} \
  -f position={line_number} \
  -f body={comment_text}
```

### 提交 Review
```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews/{review_id}/events \
  -f event={APPROVE|REQUEST_CHANGES|COMMENT}
```

## 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| 参数格式错误 | 未正确引用 `comments[][]` | 使用 `-f` 或 `-F` 标志 |
| 提交失败 | 未获取 commit SHA | 先获取 PR 的最新 commit |
| 权限错误 | 未认证或权限不足 | 运行 `gh auth login` |

## 🚩 红旗警告

不要跳过以下步骤：
- 用户说"尽快"就跳过 pending review
- 只有一条评论就直接发布
- 先发布再告诉用户发布了什么

## 输出格式

审查报告应包含：
1. 变更摘要
2. 发现的问题分类（严重/警告/建议）
3. 具体评论列表
4. 最终建议（批准/请求更改）
