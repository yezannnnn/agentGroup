# agentGroup 项目使用指南

> 基于对项目结构、配置文件及技能体系的全面分析，回答以下四个核心问题。

---

## 一、这个项目是做什么的？

`agentGroup` 是一个 **多AI角色协作框架**，基于 Claude Code（claude.ai 的终端客户端）构建。

它将一个 AI 助手拆分成四个**职责明确、互相独立**的专属角色，每个角色配备独立的指令、人设、技能集和工作目录，实现"专业分工、协同落地"。

### 四个成员

| 角色   | 中文名 | 职责定位            | 核心能力                       |
| ------ | ------ | ------------------- | ------------------------------ |
| Max    | 麦克斯 | 项目经理 & 产品顾问 | 项目管理、需求分析、待办事项   |
| Ella   | 艾拉   | UI/UX 设计师        | 界面设计、组件规范、响应式设计 |
| Jarvis | 贾维斯 | 全栈开发工程师      | 前端/后端/数据库/部署          |
| Kyle   | 凯尔   | 质量保证工程师      | 代码审查、测试验收、质量报告   |

### 核心特性

1. **严格的职责边界**：每个 AI 只处理专属领域，避免能力重叠。
2. **Token 优化策略**：通过模型智能选择、任务分解，实现 67–85% 的 Token 成本削减。
3. **强制流程机制**：每个 AI 收到消息都必须执行 7 个强制检查点（任务确认 → 优化读取 → 通知检查 → 分解评估 → Skill 检查 → 执行路径 → Git 安全检测）。
4. **技能库（Skills）**：每个 AI 都有挂载的 `skills/` 目录，支持调用专业化技能执行复杂任务。
5. **共享工作区（shared/）**：AI 间通过 `shared/status.json`、`shared/notifications.json` 等文件进行状态同步和任务传递。

### 使用场景举例

- 需求来了 → **麦克斯**分析拆解，分配给对应成员
- UI 原型 → **艾拉**负责设计规范和组件定义
- 功能开发 → **贾维斯**负责代码实现
- 上线前 → **凯尔**做代码审查和功能验收

---

## 二、如何将后端规范添加到 Jarvis 或 Kyle 的 Skill 中？

> 规范来源：`claude-demo/backend-review.md`，内容为后端 Java 代码检查规则、触发描述和输出格式。

### 核心区别：同一份规范，两种视角

虽然底层规则相同，但 **Jarvis 和 Kyle 的角色定位不同**，导致 Skill 的内容侧重、触发时机、行为目标完全不一样：

| 维度           | Jarvis（贾维斯）— 开发规范    | Kyle（凯尔）— 代码审查验收   |
| -------------- | ----------------------------- | ---------------------------- |
| **角色定位**   | 写代码的人                    | 审查代码的人                 |
| **Skill 定位** | 编码约束 + 自检清单           | 审查检查表 + 验收标准        |
| **触发时机**   | 写完模块/提交前，**主动**执行 | 接到审查任务后，**被动**介入 |
| **行为目标**   | "我写的代码符合规范吗？"      | "他写的代码有哪些问题？"     |
| **输出侧重**   | 自检通过 / 标记需修复项       | 结构化问题清单 + 严重等级    |

---

### Jarvis 的 Skill：`backend-coding-standards`（后端编码规范）

**定位**：贾维斯开发时的编码约束手册，写代码时参考，写完后主动自检。

**触发场景**：
- 开始写一个新的 ServiceImpl / Controller / Entity 时
- 写完一个模块，提交前做自检
- 用户问"这段代码规不规范"

**Skill 文件路径**：`jarvis/skills/backend-coding-standards/SKILL.md`

**SKILL.md frontmatter**（需在原规范基础上修改）：

```yaml
---
name: backend-coding-standards
description: >
  后端 Java 开发编码规范，贾维斯在编写后端代码时必须遵守，写完模块后主动自检。
  触发场景：开始编写 Controller / ServiceImpl / Mapper / Entity / QVO/RVO 时；
  写完代码准备提交前；用户要求按规范实现某功能时。
  规范覆盖：依赖注入方式、事务注解、历史表写入、异常处理、日志规范、
  对象转换、工具类使用、VO设计、DDL规范等。
  重要：代码写完后必须主动按此规范做自检，发现问题立即修复再提交。
---
```

**内容组织建议**（相比原文调整）：
- 将"检查规则"改写为"**编码要求**"语气（从"检查是否有X"改为"必须做X"）
- 突出"**正确示例**"，让贾维斯照着写，而不只是列错误
- 去掉"输出结构化 Review 报告"部分（那是凯尔的事）
- 保留"自检清单"：写完后过一遍，确认关键项已满足

---

### Kyle 的 Skill：`backend-review`（后端代码审查）

**定位**：凯尔对贾维斯提交的后端代码进行独立评审，输出结构化报告。

**触发场景**：
- 用户给出 Java 文件路径，要求 Review
- 贾维斯提交代码后，凯尔介入做验收
- 上线前的代码质量把关

**Skill 文件路径**：`kyle/skills/backend-review/SKILL.md`

**SKILL.md frontmatter**（可直接沿用原文）：

```yaml
---
name: backend-review
description: >
  对后端 Java 代码做 Code Review，输出结构化问题清单，并按严重程度分级。
  触发方式：用户给出文件路径或目录路径，Agent 自动读取代码并 Review。
  只要涉及后端代码审查、提交前检查、生成 Review 报告、发现规范违规、
  命名问题、事务缺失、历史表遗漏、NPE 风险、VO 混用等场景，必须使用此 Skill。
---
```

**内容可直接使用** `claude-demo/backend-review.md` 原文，结构完整、视角正确。

---

### 步骤：创建两个 Skill 文件

**Step 1：为 Kyle 创建审查 Skill（直接复制原文）**

```powershell
cd D:\git_desun\sc-cloud\agent-group

# Kyle：直接使用原文，视角和格式已对齐
New-Item -ItemType Directory -Force -Path "kyle\skills\backend-review"
Copy-Item "claude-demo\backend-review.md" "kyle\skills\backend-review\SKILL.md"
```

**Step 2：为 Jarvis 创建编码规范 Skill（需要调整视角）**

```powershell
# Jarvis：创建目录，然后手动编辑 SKILL.md 修改视角
New-Item -ItemType Directory -Force -Path "jarvis\skills\backend-coding-standards"

# 先复制原文作为基础
Copy-Item "claude-demo\backend-review.md" "jarvis\skills\backend-coding-standards\SKILL.md"

# 然后打开编辑，修改 frontmatter 的 name/description，并将规则语气调整为"编码要求"视角
```

**Step 3：在各自的 CLAUDE.md 中注册（推荐）**

在 `jarvis/CLAUDE.md` 的第4检查点中补充：
```
- backend-coding-standards：编写后端 Java 代码时必须遵守，写完主动自检
```

在 `kyle/CLAUDE.md` 的第4检查点中补充：
```
- backend-review：对后端 Java 代码做 Code Review，输出结构化问题清单
```

---

### 日常使用示例

**Jarvis（开发时）**：
```
# 开始写代码前
> 我要实现用户权限模块的 ServiceImpl，请按后端编码规范指导我

# 写完后自检
> 帮我检查这段代码是否符合后端编码规范：[粘贴代码]
```

**Kyle（审查时）**：
```
# 对文件做 Review
> 请 Review 这个文件：src/main/java/.../UserServiceImpl.java

# 对整个模块做 Review
> 请 Review 整个模块：sc-cloud-form-server/src/main/java
```

---

## 三、在 Windows 11 + PowerShell 下的日常使用方式

> 项目的启动脚本（`.sh`）是 Bash 脚本，需要 WSL 或 Git Bash 执行。以下提供两种方案。

### 前提：安装 Claude Code

```powershell
# 安装 Claude Code（需要 Node.js 18+）
npm install -g @anthropic-ai/claude-code

# 验证安装
claude --version
```

---

### 方案 A：使用 Git Bash 执行 .sh 脚本（推荐）

安装 [Git for Windows](https://git-scm.com/) 后，在 Git Bash 中：

```bash
cd /d/git_repo/agentGroup

# 启动各 AI（Git Bash 中可直接运行 .sh）
./start-jarvis.sh      # 贾维斯（开发任务）
./start-kyle.sh        # 凯尔（测试审查）
./start-max.sh         # 麦克斯（项目管理）
./start-ella.sh        # 艾拉（设计任务）
```

---

### 方案 B：在 PowerShell 中直接使用 claude 命令（更常用）

**启动特定 AI 的等效命令**（不依赖 .sh 脚本）：

```powershell
cd D:\git_repo\agentGroup

# 启动 Jarvis（贾维斯）
claude --project .\jarvis

# 启动 Kyle（凯尔）
claude --project .\kyle

# 启动 Max（麦克斯）
claude --project .\max

# 启动 Ella（艾拉）
claude --project .\ella
```

> `--project` 参数指定项目目录，Claude Code 会自动读取该目录下的 `CLAUDE.md` 和 `skills/` 完成 AI 角色初始化。

---

### 日常开发工作流（PowerShell 示例）

#### 场景 1：开发新功能

```powershell
# 1. 启动贾维斯
cd D:\git_repo\agentGroup
claude --project .\jarvis

# 2. 在 Claude 对话中
> /dev 实现用户权限模块的后端接口

# 3. 开发完成（贾维斯不会自动 commit，需要你授权）
> 可以提交，commit message: feat: 实现用户权限模块
```

#### 场景 2：代码审查

```powershell
# 启动凯尔
claude --project .\kyle

# 在对话中触发后端 Review（Skill 已添加）
> 请 Review 这个模块：src/main/java/com/xxx/service/UserServiceImpl.java
```

#### 场景 3：查看团队状态

```powershell
# 启动麦克斯
claude --project .\max

# 使用命令查看状态
> /status
> /todo
```

---

### PowerShell 实用技巧

```powershell
# 创建 PowerShell Profile 快捷函数（可选）
notepad $PROFILE

# 在 Profile 中添加：
function Start-Jarvis { claude --project D:\git_repo\agentGroup\jarvis }
function Start-Kyle   { claude --project D:\git_repo\agentGroup\kyle }
function Start-Max    { claude --project D:\git_repo\agentGroup\max }
function Start-Ella   { claude --project D:\git_repo\agentGroup\ella }
```

之后就可以直接在任意目录执行：

```powershell
Start-Jarvis    # 启动贾维斯
Start-Kyle      # 启动凯尔
```

---

### 注意事项

| 注意点     | 说明                                                  |
| ---------- | ----------------------------------------------------- |
| `.sh` 脚本 | 推荐用 Git Bash 运行，PowerShell 不支持直接执行       |
| Git 操作   | AI 不会自动 commit/push，需要用户在对话中明确授权     |
| 路径分隔符 | PowerShell 中 `.\jarvis` 和 `./jarvis` 均可           |
| 模型选择   | 默认使用 Sonnet，如需 Opus 在启动后告知 AI 并获取授权 |

---

## 四、项目目录结构

> 背景：前端和后端分别是独立的 Git 仓库，`agentGroup` 是第三个 Git 仓库，专门存放 AI 协作配置。

### 整体关系示意

```
工作空间/
├── frontend-repo/          # 前端 Git 仓库（独立）
│   └── .git/
│
├── backend-repo/           # 后端 Java Git 仓库（独立）
│   └── .git/
│
└── agentGroup/             # AI 团队配置仓库（本项目）
    └── .git/
```

三个仓库**互相独立**，各自维护自己的 git 历史。`agentGroup` 只存放 AI 行为指令和技能，不包含业务代码。

---

### agentGroup 目录结构详解

```
agentGroup/
│
├── README.md                    # 项目总览文档
├── LICENSE                      # MIT 开源协议
├── .gitignore                   # Git 忽略规则
├── skills-distribution.md       # 技能分配总览与来源说明
├── skills-integration-test.md   # 技能集成测试说明
│
├── panel.sh                     # 多 AI 控制面板（Bash）
├── start-max.sh                 # 启动麦克斯脚本
├── start-ella.sh                # 启动艾拉脚本
├── start-jarvis.sh              # 启动贾维斯脚本
├── start-kyle.sh                # 启动凯尔脚本
│
├── scripts/                     # 公共工具脚本
│   ├── check-gitignore.sh       # .gitignore 规则验证
│   └── clean-system-files.sh    # 清理系统文件
│
│
├── max/                         # 麦克斯（项目经理）配置
│   ├── CLAUDE.md                # 行为指令（强制流程 + 职责定义）
│   ├── PERSONA.md               # 人格设定
│   ├── .claude/                 # Claude Code 项目配置
│   │   └── commands/            # 自定义命令（/todo、/status 等）
│   └── skills/                  # 专属技能
│       ├── ccpm/                # CCPM 项目管理系统
│       ├── pm-claude-skills/    # PM 技能集（PRD、会议记录等）
│       └── token-optimization.md
│
├── ella/                        # 艾拉（UI/UX 设计师）配置
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   ├── .claude/
│   └── skills/
│       └── senior-frontend/     # 前端/UI 设计技能集
│
├── jarvis/                      # 贾维斯（全栈开发）配置
│   ├── CLAUDE.md                # 行为指令（开发流程 + 强制检查点）
│   ├── PERSONA.md
│   ├── .claude/
│   └── skills/
│       ├── token-optimization.md
│       ├── claude-simone/       # AI 辅助开发框架
│       └── engineering-team/    # 工程师技能集合
│           ├── CLAUDE.md        # 技能集说明
│           ├── senior-backend/  # 后端开发技能
│           ├── senior-fullstack/# 全栈开发技能
│           ├── senior-architect/# 架构设计技能
│           ├── code-reviewer/   # 代码审查技能
│           ├── senior-devops/   # DevOps 技能
│           └── ...（共 18 个工程技能）
│
├── kyle/                        # 凯尔（质量保证）配置
│   ├── CLAUDE.md                # 行为指令（审查流程 + 验收规范）
│   ├── PERSONA.md
│   ├── .claude/
│   └── skills/
│       ├── token-optimization.md
│       ├── senior-qa/           # QA 技能（测试生成、覆盖率分析）
│       │   ├── SKILL.md         # 技能入口文件
│       │   ├── references/      # 参考文档
│       │   └── scripts/         # 自动化测试脚本
│       └── tdd-guide/           # TDD 测试驱动开发指导
│
├── shared/                      # 共享工作区（AI 间协作通道）
│   ├── status.json              # 团队实时状态（AI 间通信）
│   ├── notifications.json       # 跨 AI 通知消息
│   ├── tasks/                   # 任务文档
│   │   └── meetings.md          # 会议记录
│   ├── docs/                    # 结构化文档库
│   ├── designs/                 # 设计资源（艾拉产出）
│   ├── reviews/                 # 审查报告（凯尔产出）
│   ├── templates/               # 文档模板
│   ├── token-simple.md          # Token 使用监控指南
│   └── scripts/
│       └── check_notifications_simple.sh  # 通知时间戳检查脚本
│
└── claude-demo/                 # 示例和规范文件（本目录）
    ├── backend-review.md        # 后端 Java Code Review 规范
    └── claude.md                # 本文档
```

---

### 关键目录说明

| 目录                     | 作用                            | 谁管理         |
| ------------------------ | ------------------------------- | -------------- |
| `{ai}/CLAUDE.md`         | AI 行为指令，定义强制流程和职责 | 人工维护       |
| `{ai}/PERSONA.md`        | AI 人格设定（性格、说话风格）   | 人工维护       |
| `{ai}/skills/`           | 专业技能包，AI 自动检测并调用   | 人工 + AI 配合 |
| `{ai}/.claude/commands/` | 自定义斜杠命令（`/todo` 等）    | 人工维护       |
| `shared/status.json`     | AI 间实时状态同步               | 各 AI 写入     |
| `shared/reviews/`        | 凯尔输出审查报告的存放位置      | 凯尔写入       |

---

### 与业务仓库的协作方式

```
业务开发流程示意：

前端仓库（你在写代码） → 启动艾拉/贾维斯 → AI 读取你指定的业务代码路径 → 执行开发/审查
后端仓库（你在写代码） → 启动贾维斯/凯尔 → AI 读取 Java 代码路径 → 执行 Review（backend-review Skill）
```

> AI 可以读取任意路径的文件，不局限于 `agentGroup` 仓库内。
> 日常使用时，告知 AI 你的业务仓库中的具体文件路径即可。
