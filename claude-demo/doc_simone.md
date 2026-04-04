# Claude Simone 详细使用手册

> **Simone** 是专为 Claude Code 设计的 AI 辅助开发项目管理框架，通过结构化的上下文管理和任务系统，帮助 AI 在复杂的软件工程项目中高效工作。

---

## 目录

1. [概述与核心理念](#1-概述与核心理念)
2. [版本选择](#2-版本选择)
3. [Legacy 系统（稳定版）](#3-legacy-系统稳定版)
   - [安装](#31-安装)
   - [目录结构](#32-目录结构)
   - [核心组件说明](#33-核心组件说明)
   - [快速入门流程](#34-快速入门流程)
   - [完整命令参考](#35-完整命令参考)
   - [日常工作流最佳实践](#36-日常工作流最佳实践)
4. [MCP Server 版本（新一代）](#4-mcp-server-版本新一代)
   - [安装与配置](#41-安装与配置)
   - [架构说明](#42-架构说明)
   - [可用 Prompts 参考](#43-可用-prompts-参考)
   - [开发工作流](#44-开发工作流)
5. [注意事项与进阶技巧](#5-注意事项与进阶技巧)

---

## 1. 概述与核心理念

### 解决的核心问题：上下文衰减（Context Decay）

AI 编码工具面临一个根本性挑战：**有限的上下文窗口**。在长时间的编码 session 中，关键的项目知识（架构决策、需求细节、已完成的实现）会随着对话的推进悄悄"滑出"上下文窗口，导致：

- AI 遗忘项目规范，产生不一致的代码
- 需要频繁重复解释项目背景
- 错误到很晚才被发现

### Simone 的解决方案

Simone 的核心哲学是：

> **每个任务都以全新、完整、精准相关的上下文开始。**

不依赖 AI 在长会话中保留知识，而是在每个任务开始时系统性地向 AI 注入项目的"权威真相"——精心组织的文档、需求和架构蓝图。

**结果**：

- 每个任务在开始时都拥有恰好所需的项目上下文
- 关键知识不会在长会话中丢失
- AI 始终能以完整的需求感知进行工作
- 周围的上下文指导开发，而不仅仅是任务描述本身

---

## 2. 版本选择

| 特性 | Legacy 系统 | MCP Server |
|------|------------|------------|
| 稳定性 | ✅ 生产就绪 | ⚠️ 早期开发 |
| 安装方式 | `npx hello-simone` | `npm install -g simone-mcp` |
| 工作方式 | 目录+Markdown 命令文件 | Model Context Protocol |
| 功能完整性 | 完整 | 尚未完整 |
| 活动日志 | 无 | ✅ SQLite 持久化 |
| 配置方式 | 目录结构 | `.simone/project.yaml` |
| **推荐场景** | **实际项目管理** | **早期体验者** |

**推荐使用 Legacy 系统**，除非你是愿意接受不稳定性的早期体验者。

---

## 3. Legacy 系统（稳定版）

### 3.1 安装

```bash
npx hello-simone
```

这条命令会：
- 在项目根目录创建 `.simone/` 文件夹结构
- 安装命令文件到 `.claude/commands/simone/`
- 已有安装时会自动备份原有命令文件再更新

### 3.2 目录结构

安装完成后，项目中会出现以下结构：

```plaintext
.simone/
├── 00_PROJECT_MANIFEST.md          # 项目核心文档（必须以此命名）
├── 01_PROJECT_DOCS/                # 通用项目文档（技术规范、API文档等）
├── 02_REQUIREMENTS/                # 按里程碑组织的需求文档
│   ├── M01_Backend_Setup/          # 里程碑文件夹（必须 M##_ 前缀）
│   │   ├── M01_PRD.md              # 产品需求文档
│   │   └── M01_Database_Schema.md # 可选补充文档
│   └── M02_Frontend_Setup/
├── 03_SPRINTS/                     # Sprint 计划与任务定义
│   ├── S01_M01_Initial_API/        # Sprint 文件夹
│   └── S02_M01_Database_Schema/
├── 04_GENERAL_TASKS/               # 非 Sprint 的独立任务
│   ├── T002_API_Rate_Limiting.md   # 待处理任务（T 前缀）
│   └── TX001_Refactor_Logging.md   # 已完成任务（TX 前缀）
├── 05_ARCHITECTURAL_DECISIONS/     # 架构决策记录（ADR）
│   └── ADR001_Database_Selection.md
├── 10_STATE_OF_PROJECT/            # 项目评审快照（由命令生成）
└── 99_TEMPLATES/                   # 标准化模板
    ├── task_template.md
    ├── sprint_meta_template.md
    └── milestone_meta_template.md

.claude/
└── commands/simone/                # Simone 命令文件（自动安装）
    ├── initialize.md
    ├── do_task.md
    ├── create_sprint_tasks.md
    └── ...（共 15 个命令）
```

### 3.3 核心组件说明

#### `00_PROJECT_MANIFEST.md`

**最重要的文件。** 包含项目愿景、目标和高层概述。是 Claude 理解项目的起点。

> ⚠️ 文件名必须精确为 `00_PROJECT_MANIFEST.md`，不能是 `MANIFEST.md`。

#### `02_REQUIREMENTS/` — 需求目录

按里程碑组织，存储 PRD 及其补充说明。里程碑文件夹命名规范：

```
M##_Milestone_Name/   例如：M01_Backend_Setup/
```

每个里程碑至少要有一个 `M##_PRD.md` 文件。

#### `03_SPRINTS/` — Sprint 目录

包含按里程碑和 Sprint 序号组织的 Sprint 计划及任务文件。每个 Sprint 文件夹内包含独立的任务文件，每个任务对应 Claude 的一次工作 session。

#### `04_GENERAL_TASKS/` — 通用任务

存储不属于特定 Sprint 的任务定义：
- `T###_任务名.md` — 待处理任务
- `TX###_任务名.md` — 已完成任务（TX 前缀方便 Claude 识别进度）

#### `05_ARCHITECTURAL_DECISIONS/` — ADR

使用结构化的架构决策记录（Architecture Decision Records）格式，记录：决策背景、考虑的选项、选择理由。为 Claude 做技术决策时提供关键上下文。

#### `99_TEMPLATES/` — 模板

为任务、Sprint 元数据、里程碑元数据提供标准化模板，确保人类和 Claude 的一致性。日期格式统一为 `YYYY-MM-DD HH:MM`。

---

### 3.4 快速入门流程

下面是从零开始使用 Simone 的完整步骤：

#### 第 1 步：安装

```bash
npx hello-simone
```

#### 第 2 步：在 Claude Code 中初始化项目

打开 Claude Code，运行：

```
/simone:initialize
```

Claude 会引导你完成：
1. 扫描分析项目（自动检测语言、框架等）
2. 确认项目特征
3. 处理已有文档（导入或从头创建）
4. 引导创建第一个里程碑
5. 生成 `00_PROJECT_MANIFEST.md`

> ℹ️ 该命令只需在项目接入 Simone 时运行**一次**。

#### 第 3 步：设置第一个里程碑

在 `.simone/02_REQUIREMENTS/` 下创建里程碑文件夹（可在第 2 步的对话中让 Claude 完成）：

```
M01_Your_Milestone_Name/
└── M01_PRD.md
```

#### 第 4 步：拆分 Sprint

```
/simone:create_sprints_from_milestone
```

Claude 会分析里程碑需求，将其分解为约 1 周的 Sprint，创建 Sprint 文件夹和元数据文件，并更新 manifest。

#### 第 5 步：创建任务

```
/simone:create_sprint_tasks
```

Claude 会深度分析 Sprint 内容、研究必要信息，为当前 Sprint 创建详细、可执行的任务文件。

> ⚠️ **重要**：只为**下一个** Sprint 创建任务，不要一次性为所有 Sprint 创建。完成 Sprint 1 后，再为 Sprint 2 创建任务。这样系统能引用已有代码库，将完成的工作纳入后续任务规划。

#### 第 6 步：开始工作

```
/simone:do_task
# 自动选择下一个任务

# 或指定任务 ID：
/simone:do_task T01_S01
```

---

### 3.5 完整命令参考

所有命令格式：`/simone:<命令名> [参数]`

#### 📦 安装与初始化

---

##### `/simone:initialize`
**初始化项目**

```
/simone:initialize
```

执行步骤：
1. 扫描分析项目
2. 请求用户确认项目类型
3. 检查已有 Simone 文档
4. 引导完成文档创建
5. 创建第一个里程碑
6. 生成项目 Manifest

**使用时机**：首次在项目中设置 Simone

---

#### 🧭 上下文命令

---

##### `/simone:prime`
**加载项目上下文**

```
/simone:prime
```

执行内容：
- 读取项目 Manifest
- 加载当前里程碑和 Sprint 信息
- 识别活跃任务
- 提供快速状态概览

**使用时机**：每次编码 session 开始时，用于快速定位当前状态

---

#### 📅 规划命令

---

##### `/simone:create_sprints_from_milestone`
**将里程碑拆分为 Sprint**

```
/simone:create_sprints_from_milestone 001_MVP_FOUNDATION
```

执行步骤：
1. 分析里程碑需求
2. 将相关需求分组为约 1 周的 Sprint
3. 创建 Sprint 文件夹和 META 文件
4. 更新 Manifest

**使用时机**：创建新里程碑后

---

##### `/simone:create_sprint_tasks`
**为 Sprint 创建详细任务**

```
/simone:create_sprint_tasks S01
# 或指定特定 Sprint：
/simone:create_sprint_tasks S02_001_MVP_FOUNDATION
```

执行步骤：
1. 分析 Sprint 需求
2. 拆解为具体、可执行的任务
3. 创建带有明确目标的任务文件
4. 处理任务间依赖关系

**使用时机**：每个 Sprint 开始前

---

##### `/simone:create_general_task`
**创建独立任务（非 Sprint）**

```
/simone:create_general_task
# 按提示描述你的任务
```

常用场景举例：
- "修复物理引擎中的内存泄漏"
- "更新 API 变更文档"
- "重构数据库连接池"

**使用时机**：处理维护、Bug 修复或 Sprint 范围外的工作

---

##### `/simone:plan_milestone`
**规划里程碑**

帮助定义和规划新里程碑，引导确定里程碑目标、范围和成功标准。

---

#### 💻 开发命令

---

##### `/simone:do_task`
**执行任务**

```
/simone:do_task
# 列出可用任务并提示选择

# 或直接指定：
/simone:do_task T001_S01_setup_tauri
```

执行步骤：
1. **任务识别与分析**：找到任务文件，读取描述、目标、验收标准
2. **上下文验证**：确认任务属于当前 Sprint，依赖已满足，与项目需求一致
3. **状态更新**：将任务状态更新为 `in_progress`
4. **执行工作**：按任务文件中的实现计划，逐步完成代码修改
5. **质量保证**：完成后自动进行代码审查和测试
6. **最终化**：将任务标记为 `completed`，文件重命名为 `TX...` 前缀

**使用时机**：准备开始某个具体任务时

---

##### `/simone:commit`
**创建规范的 git 提交**

```
/simone:commit
# 审查变更并创建提交

# 针对特定任务：
/simone:commit T001_S01_setup_tauri

# YOLO 模式（跳过确认）：
/simone:commit YOLO
```

执行步骤：
1. 分析已做的变更
2. 将相关变更分组
3. 创建有意义的提交信息
4. 将提交与任务/需求关联
5. 可选先进行代码审查

**使用时机**：完成工作想保存时

---

##### `/simone:test`
**运行测试并修复常见问题**

```
/simone:test
# 运行所有测试

/simone:test unit
# 运行特定测试套件
```

执行步骤：
1. 从 package.json 识别测试命令
2. 运行合适的测试
3. 修复常见问题（缺失依赖、配置问题）
4. 清晰报告结果

**使用时机**：提交前或测试失败时

---

##### `/simone:yolo`
**自主任务执行（自动化模式）**

```
/simone:yolo
# 处理所有未完成任务

/simone:yolo S02
# 处理特定 Sprint
```

执行步骤：
1. 识别未完成任务
2. 按顺序执行
3. 处理依赖关系
4. 提交已完成的工作
5. 更新进度

内置安全机制：
- 不会在未确认的情况下修改 Schema
- 跳过危险操作
- 维持代码质量标准
- 创建增量提交

> ⚠️ 使用时要谨慎，适合处理常规、直接的功能实现

**使用时机**：需要自主推进进度时

---

#### 🔍 审查命令

---

##### `/simone:code_review`
**代码审查**

```
/simone:code_review
# 审查未提交的变更

/simone:code_review src/app/components/GameCanvas.tsx
# 审查特定文件
```

执行步骤：
1. 对照需求检查代码
2. 验证模式和规范
3. 识别 Bug 和问题
4. 提出改进建议
5. 确保规范合规性

**使用时机**：提交重要变更前

---

##### `/simone:project_review`
**项目综合健康检查**

```
/simone:project_review
```

执行步骤：
1. 审查整体架构
2. 检查技术债务
3. 分析进度与时间线
4. 识别风险和阻塞点
5. 提出改进建议

**使用时机**：每周或 Sprint 边界时

---

##### `/simone:testing_review`
**测试覆盖率与质量分析**

```
/simone:testing_review
```

执行步骤：
1. 审查测试覆盖率
2. 识别缺失的测试用例
3. 检查测试质量
4. 提出改进建议

**使用时机**：实现新功能后

---

##### `/simone:discuss_review`
**深入讨论审查结果**

```
/simone:discuss_review
# 在运行其他审查命令后使用
```

提供：
- 详细解释
- 权衡分析
- 解决方案建议
- 问题解答

**使用时机**：需要更好地理解审查反馈时

---

##### `/simone:mermaid`
**创建和维护架构图**

```
/simone:mermaid CREATE
# 生成新的架构图

/simone:mermaid UPDATE
# 根据代码变更更新现有图

/simone:mermaid MAINTAIN
# 检查并刷新图的准确性

/simone:mermaid UPDATE authentication
# 更新特定组件的图
```

执行步骤：
1. 分析项目结构
2. 创建/更新 Mermaid 图表
3. 在 `/docs/architecture/` 生成架构文档
4. 验证图表语法
5. 保持图表间一致性

**使用时机**：可视化记录架构时

---

### 3.6 日常工作流最佳实践

#### 🌅 每日工作流

```
# 早上开始
/simone:prime

# 开发工作
/simone:do_task
/simone:test
/simone:commit

# 收尾（可选）
/simone:project_review
```

#### 🏃 Sprint 工作流

```
# Sprint 规划
/simone:create_sprint_tasks S02

# Sprint 执行
/simone:do_task T001_S02_first_task
/simone:do_task T002_S02_second_task
/simone:commit

# Sprint 回顾
/simone:project_review
```

#### 🐛 Bug 修复工作流

```
# 创建 Bug 任务
/simone:create_general_task
# 描述：修复 /src/foo.bar 中的内存泄漏

# 修复
/simone:do_task T003

# 验证与提交
/simone:test
/simone:commit T003
```

#### 技巧总结

1. **常规任务用 YOLO**：实现直接、明确的功能非常适合
2. **先 prime 再工作**：确保命令有正确的上下文
3. **重要提交前先审查**：早发现问题
4. **用通用任务追踪 Bug**：保持可追溯性
5. **用任务关联的提交**：更好的可追溯性

---

### 3.7 并行任务执行配置（可选）

若要启用多任务并行执行以提升效率：

```bash
# 设置并行任务数（示例：3个）
claude config set --global "parallelTasksCount" 3

# 查看当前配置
claude config list -g
```

> ⚠️ 注意：并行执行会显著增加 API 使用量，某些任务并行运行时可能产生冲突。建议从 2-3 个开始，根据实际情况调整。

---

## 4. MCP Server 版本（新一代）

> ⚠️ **早期开发版本**，尚未推荐用于生产环境。代表 Simone 项目的未来方向。

### 4.1 安装与配置

#### 安装

```bash
# 全局安装（推荐频繁使用者）
npm install -g simone-mcp

# 或直接使用无需安装
npx simone-mcp
```

#### 配置项目连接

在项目根目录创建 `.mcp.json`：

```json
{
  "mcpServers": {
    "simone": {
      "command": "npx",
      "args": ["--yes", "simone-mcp@latest"],
      "env": {
        "PROJECT_PATH": "/path/to/your/project"
      }
    }
  }
}
```

**关键配置说明**：
- `command`：使用 `npx` 执行服务器
- `args`：`--yes` 跳过确认，`@latest` 确保使用最新版本
- `env.PROJECT_PATH`：**必填**，项目根目录的绝对路径

配置完成后，AI 工具将能自动发现并使用 Simone MCP 服务器暴露的 Prompts 和工具。

---

### 4.2 架构说明

MCP Server 采用模块化、可扩展的架构，作为持久后台进程运行，通过标准输入输出（Stdio）与 AI 客户端通信。

```mermaid
graph TD
    subgraph AI客户端
        A[AI开发工具] <-->|MCP over Stdio| B(Simone MCP Server)
    end

    subgraph 项目文件
        C[/.simone/project.yaml]
        D[/.simone/prompts/]
        E[/.simone/simone.db]
        F[项目源代码]
    end

    subgraph 服务器内部
        G[Prompt Handler]
        H[Tool Registry]
        I[Config Loader]
        J[Activity Logger]
    end

    B --> I
    I --> C
    B --> G
    G --> D
    B --> H
    H --> J
    J --> E
    A -->|执行工作| F
```

**架构组件**：

| 组件 | 职责 |
|------|------|
| **Server Core** | 主入口（`index.ts`），初始化 MCP 服务器，设置请求处理器，连接传输层 |
| **Config Loader** | 从 `.simone/project.yaml` 加载和验证项目配置 |
| **Prompt Handler** | 使用 Handlebars 模板引擎加载、缓存和渲染 Prompts，支持内置和项目自定义 Prompts |
| **Tool Registry** | 所有可用 MCP 工具的中央注册表，当前主要工具为 ActivityLogger |
| **Activity Logger** | 提供 `log_activity` 工具，与 SQLite 数据库交互，持久记录开发活动 |
| **Transport Layer** | 使用 `StdioServerTransport` 通过标准输入输出与 AI 客户端通信 |

---

### 4.3 可用 Prompts 参考

#### `create-task`
**交互式创建任务**

引导用户和 AI 完成新任务的定义和创建过程。通过对话方式收集需求、探索方案，生成结构良好的任务规范，可进一步创建 GitHub Issue。

---

#### `do_task`
**执行任务**

| 参数 | 必填 | 说明 |
|------|------|------|
| `task_id` | ✅ | 要执行的任务 ID |

作为 AI 开始实现任务的入口，为 AI 提供项目初始上下文和任务 ID。

---

#### `generate-changelog`
**生成 Changelog**

指导 AI 运行 `conventional-changelog` 工具生成原始提交信息，并将其改写为适合 `CHANGELOG.md` 的用户友好格式。

---

#### `pre-commit`
**提交前检查清单**

根据 `.simone/project.yaml` 中的项目配置，动态生成质量保证步骤清单（代码检查、测试、格式化等），作为提交前的最终质量门禁。

---

#### `summarize-activity`
**生成活动摘要**

| 参数 | 必填 | 说明 |
|------|------|------|
| `period` | ❌ | 时间周期（如 `today`、`7d`），默认 `today` |

查询活动日志数据库，生成包含概览、每日分解和效率分析的报告。

---

#### `update-issue`
**更新 GitHub Issue**

可用于关闭、重新打开、编辑或评论 GitHub Issue，根据项目配置提供适合 GitHub CLI 或 GitHub MCP 服务器工具的命令。

---

### 4.4 开发工作流

MCP Server 的工作流比 Legacy 系统更直接和工具导向：

#### 第 1 步：定义项目配置

创建或更新 `.simone/project.yaml`：

```yaml
# 示例 project.yaml 结构
project:
  name: "我的项目"
  stack:
    - "Node.js"
    - "TypeScript"
  tooling:
    testing: "jest"
    linting: "eslint"
```

#### 第 2 步：通过 Prompts 发起操作

调用 Prompt（如 `create-task`、`summarize-activity`），服务器使用 Handlebars 模板引擎渲染基于项目配置的详细上下文感知 Prompt。

#### 第 3 步：工具交互

AI 使用服务器暴露的工具（如 `log_activity`），以结构化方式与项目交互。

#### 第 4 步：持续记录活动日志

整个开发过程中，所有重要操作通过 `log_activity` 记录。这创建了持久的、可查询的开发历史，供其他 Prompts（如 `summarize-activity`）使用。

#### 典型场景示例

```
1. 开发者想新增功能 → 调用 `create-task` prompt
2. Simone MCP 返回详细交互式 prompt，引导定义任务
3. AI 和开发者共同定义任务规范
4. AI 调用 log_activity 记录"新任务已创建"
5. 开发者开始实现 → 调用 `do_task` prompt
6. 完成后再次调用 log_activity 记录完成状态
```

---

## 5. 注意事项与进阶技巧

### 系统复杂性提醒

> ⚠️ Simone 是一个复杂的系统，需要时间来正确理解。它不是简单的即插即用方案，而是一个框架，在你花时间了解其运作方式并将其适配到你的工作流后，才能发挥最大效果。

### 命令安全机制

Simone 命令包含内置安全特性：
- 不会删除关键文件
- Schema 变更前会请求确认
- 对照规范验证变更
- 维持代码质量标准
- 创建增量式提交

### 获取帮助

如果某个命令遇到问题：
1. 不带参数运行命令，查看使用说明
2. 查阅本手册
3. 查看 `.simone/` 中的任务示例
4. 查看 `.claude/commands/simone/` 中的命令源文件

### 与现有项目集成

`/simone:initialize` 对新旧代码库均有效，可以：
- 导入已有项目文档到 Simone 结构
- 或从零开始创建文档（Claude 会深度分析代码库生成草稿）

### 里程碑命名规范

- ✅ 正确：`M01_Backend_Setup/`
- ❌ 错误：`Backend_Setup/` 或 `01_Backend_Setup/`

前缀 `M##_` 是必须的，下划线不能用空格替代。

---

## 附录：参考资源

- **GitHub 仓库**：[github.com/Helmi/claude-simone](https://github.com/Helmi/claude-simone)
- **Awesome Claude Code**：已收录 Simone
- **社区**：Anthropic Discord，找 @helmi 交流
- **许可证**：MIT License

---

*本手册基于 `agent-group/jarvis/skills/claude-simone` 目录内容整理生成，涵盖 Legacy 系统和 MCP Server 两种实现版本的完整使用说明。*
