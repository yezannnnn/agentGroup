# 子计划 01：目录骨架与基础设施

> 创建 `agent-group-v2/` 完整目录结构和基础配置文件

## 目标

从零搭建 `D:\git_desun\sc-cloud\agent-group-v2\` 的目录骨架，包含所有角色目录、shared 子目录、.claude 配置，以及必要的占位文件（.gitkeep）。

**这是整个迁移的第一步，不依赖任何其他子计划。**

## 前置条件

- 无

## 执行清单

### 1.1 创建顶层目录结构

```
agent-group-v2/
├── .claude/
│   ├── skills/
│   └── commands/
├── max/
│   └── skills/
├── ella/
│   └── skills/
├── jarvis-fe/
│   └── skills/
├── jarvis-be/
│   └── skills/
├── jarvis/                  # 弃用桥接，仅保留目录
├── kyle/
│   └── skills/
├── shared/
├── scripts/
└── claude-demo/             # 文档/参考目录
```

- [ ] 1.1.1 创建 `agent-group-v2/` 根目录
- [ ] 1.1.2 创建 `.claude/skills/`、`.claude/commands/` 目录
- [ ] 1.1.3 创建 5 个角色目录（max/ella/jarvis-fe/jarvis-be/kyle）及其 `skills/` 子目录
- [ ] 1.1.4 创建 `jarvis/` 弃用桥接目录（无 skills 子目录）
- [ ] 1.1.5 创建 `scripts/` 目录

### 1.2 创建 shared 目录层级

```
shared/
├── protocols/               # 公共流程协议
├── specs/
│   └── openspec/
│       ├── changes/         # openspec 变更提案
│       └── config.yaml      # openspec 配置（空，待子计划09填充）
├── handoff/
│   ├── ella-to-jarvis/      # 设计稿交付
│   ├── jarvis-to-kyle/      # 代码待审交付
│   ├── kyle-to-jarvis/      # 审查反馈
│   ├── fe-to-be/            # 前端标注后端任务
│   └── be-to-fe/            # 后端标注前端任务
├── scripts/                 # 通知检查等脚本
├── templates/               # 文档模板
├── tasks/                   # 任务记录
├── docs/                    # PRD 等文档
├── status.json              # 团队状态（空初始化）
└── notifications.json       # 通知（空初始化）
```

- [ ] 1.2.1 创建 `shared/protocols/`
- [ ] 1.2.2 创建 `shared/specs/openspec/changes/` 和 `shared/specs/openspec/config.yaml`（占位）
- [ ] 1.2.3 创建 `shared/handoff/` 下 5 个子目录
- [ ] 1.2.4 创建 `shared/scripts/`
- [ ] 1.2.5 创建 `shared/templates/`、`shared/tasks/`、`shared/docs/`
- [ ] 1.2.6 初始化 `shared/status.json` 和 `shared/notifications.json`

### 1.3 复制 .claude 基础配置

- [ ] 1.3.1 从 `agent-group/.claude/settings.local.json` 复制到 `agent-group-v2/.claude/settings.local.json`
- [ ] 1.3.2 从 `agent-group/.claude/skills/` 复制 4 个 openspec skill 目录：
  - `openspec-propose/`
  - `openspec-apply-change/`
  - `openspec-explore/`
  - `openspec-archive-change/`

### 1.4 复制项目基础文件

- [ ] 1.4.1 从 `agent-group/.gitignore` 复制
- [ ] 1.4.2 从 `agent-group/.claudeignore` 复制
- [ ] 1.4.3 创建空的 `README.md`（占位，待子计划10填充）
- [ ] 1.4.4 复制 `agent-group/scripts/check-gitignore.sh` 和 `clean-system-files.sh`

### 1.5 复制 shared 脚本

- [ ] 1.5.1 从 `agent-group/shared/scripts/check_notifications.sh` 复制
- [ ] 1.5.2 从 `agent-group/shared/scripts/check_notifications_simple.sh` 复制

### 1.6 为空目录添加 .gitkeep

- [ ] 1.6.1 为以下空目录添加 `.gitkeep`：
  - `shared/handoff/ella-to-jarvis/`
  - `shared/handoff/jarvis-to-kyle/`
  - `shared/handoff/kyle-to-jarvis/`
  - `shared/handoff/fe-to-be/`
  - `shared/handoff/be-to-fe/`
  - `shared/specs/openspec/changes/`
  - `shared/templates/`
  - `shared/tasks/`
  - `shared/docs/`
  - `shared/protocols/`

## 验证清单

完成后检查：

- [ ] `agent-group-v2/` 目录存在且包含完整子结构
- [ ] `.claude/skills/` 包含 4 个 openspec skill
- [ ] `shared/handoff/` 包含 5 个子目录
- [ ] `shared/specs/openspec/` 目录就绪
- [ ] `shared/protocols/` 目录就绪
- [ ] 5 个角色目录均包含 `skills/` 子目录
- [ ] `jarvis/` 弃用目录存在
- [ ] `status.json` 和 `notifications.json` 已初始化
- [ ] 脚本文件已复制

## 来源文件映射

| 源文件 (agent-group/) | 目标文件 (agent-group-v2/) | 操作 |
|---|---|---|
| `.claude/settings.local.json` | `.claude/settings.local.json` | 复制 |
| `.claude/skills/openspec-*` (4个) | `.claude/skills/openspec-*` | 复制 |
| `.gitignore` | `.gitignore` | 复制 |
| `.claudeignore` | `.claudeignore` | 复制 |
| `scripts/check-gitignore.sh` | `scripts/check-gitignore.sh` | 复制 |
| `scripts/clean-system-files.sh` | `scripts/clean-system-files.sh` | 复制 |
| `shared/scripts/check_notifications.sh` | `shared/scripts/check_notifications.sh` | 复制 |
| `shared/scripts/check_notifications_simple.sh` | `shared/scripts/check_notifications_simple.sh` | 复制 |
| — | `shared/status.json` | 新建(空结构) |
| — | `shared/notifications.json` | 新建(空结构) |
| — | `shared/protocols/` | 新建目录 |
| — | `shared/handoff/*` (5个) | 新建目录 |
| — | `shared/specs/openspec/` | 新建目录 |

## status.json 初始结构

```json
{
  "meta": {
    "version": "2.0.0",
    "description": "agent-group-v2 团队状态",
    "lastUpdated": ""
  },
  "projects": {},
  "tasks": {}
}
```

## notifications.json 初始结构

```json
{
  "meta": {
    "version": "2.0.0",
    "description": "仅用于非变更类通知（会议、紧急事件）"
  },
  "notifications": []
}
```

## 预计产出文件数

- 新建目录：~25 个
- 复制文件：~10 个
- 新建文件（占位/初始化）：~15 个

## 注意事项

1. **不涉及任何角色 CLAUDE.md 或 PERSONA.md 的创建**——那是子计划 03-07 的工作
2. **不涉及 openspec 内容迁移**——config.yaml 在此步骤只是占位，子计划 09 会填充实际内容
3. **shared/status.json 和 notifications.json 使用新的 v2.0.0 格式**，不复制旧版内容
