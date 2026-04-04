# AI 团队协作体系改造方案

> 基于 openspec + superpowers 的 Claude Code 团队协作模式

## 现状分析

### 当前架构

```
sc-cloud/
├── agent-group/          # AI角色定义（独立Git仓库）
│   ├── max/              # 项目经理
│   ├── ella/             # UI/UX设计师
│   ├── jarvis/           # 全栈开发（前后端合一）
│   ├── kyle/             # QA工程师
│   ├── shared/           # AI间信息传递
│   └── openspec/         # openspec 已接入但未深度使用
├── cloud-backend/        # 后端工程（Java/Spring Boot）
└── cloud-frontend/       # 前端工程（React/Vite/Wujie 微前端）
```

### 现存问题

1. **Jarvis 职责过宽**：前后端技术栈差异大（Java vs React），单一角色的 CLAUDE.md 上下文膨胀，skill 列表混杂
2. **openspec 未被角色流程引用**：`openspec/` 已存在但各角色的 CLAUDE.md 中没有使用它的指令
3. **shared 目录定位模糊**：当前 shared 下混杂了通知脚本、状态文件、设计稿等，缺少 specs 产出物的统一归口
4. **自定义 Skill 与 superpowers 的关系未理清**：CLAUDE.md 中同时引用了自定义 skill 和 superpowers，但执行优先级和组合方式不明确

---

## 一、关于你的四个问题

### 问题1：前端 Jarvis、后端 Jarvis 需要放在各自工程目录内吗？

**结论：不需要。角色定义仍然统一放在 `agent-group/` 下，但启动时通过工作目录参数指向各自工程。**

理由：
- Claude Code 的 `--project` 参数指定的是人设加载目录，与实际工作目录（cwd）无关
- 角色定义放在 `agent-group/` 便于统一管理、版本控制
- 前后端工程各自有 `.claude/project.md` 描述项目上下文，Jarvis 启动后通过读取该文件获取工程信息

推荐结构：
```
agent-group/
├── jarvis-fe/            # 前端 Jarvis 角色定义
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── react-frontend/
│       ├── senior-frontend/
│       └── superpowers-guide/
│
├── jarvis-be/            # 后端 Jarvis 角色定义
│   ├── CLAUDE.md
│   ├── PERSONA.md
│   └── skills/
│       ├── java-backend/
│       ├── code-reviewer/
│       ├── tdd-guide/
│       └── superpowers-guide/
```

启动方式：
```bash
# 前端开发 - 在 cloud-frontend 目录下，加载 jarvis-fe 人设
cd cloud-frontend
claude --project ../agent-group/jarvis-fe

# 后端开发 - 在 cloud-backend 目录下，加载 jarvis-be 人设
cd cloud-backend
claude --project ../agent-group/jarvis-be
```

> **⚠️ 重要**：前面这个启动方式是理想形态。实际上 Claude Code 的 `--project` 路径解析取决于你的 CLI 版本。如果 `--project` 不支持相对路径，可以在各工程目录下创建 `.claude/` 软链接或直接在工程目录下放 CLAUDE.md 引用 agent-group 的内容。具体方案见下文"落地方案"。

---

### 问题2：怎么定义 AI 人设，能让 AI 的产出和读取都在 shared 文件夹内

**核心思路：在 CLAUDE.md 中明确"读写契约"——每个角色声明自己的读取范围和写入范围。**

#### shared/specs 目录设计

```
agent-group/shared/
├── specs/                    # openspec + superpowers 产出物（核心）
│   ├── openspec/             # openspec 标准产出
│   │   ├── changes/          # 变更提案（proposal + design + tasks）
│   │   └── config.yaml       # openspec 配置
│   └── superpowers/          # superpowers 阶段性产出
│       ├── plans/            # writing-plans 产出的实施方案
│       ├── reviews/          # requesting-code-review 的自查报告
│       └── debug-logs/       # systematic-debugging 的调试记录
│
├── handoff/                  # 角色间交付物（替代原 designs/、reviews/ 的散落）
│   ├── ella-to-jarvis/       # 设计稿交付
│   ├── jarvis-to-kyle/       # 代码待审交付
│   └── kyle-to-jarvis/      # 审查反馈
│
├── status.json               # 团队状态（保留）
└── notifications.json        # 通知（保留）
```

#### 各角色的读写权限约定

| 角色          | 可读                                                                         | 可写                                                                        |
| ------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| **Max**       | `specs/**`（全部）, `handoff/**`（全部）, `status.json`                      | `specs/openspec/**`（proposal、tasks）, `status.json`                       |
| **Ella**      | `specs/openspec/changes/*/proposal.md`, `specs/openspec/changes/*/design.md` | `handoff/ella-to-jarvis/`, `specs/openspec/changes/*/design.md`（设计部分） |
| **Jarvis-FE** | `specs/**`, `handoff/ella-to-jarvis/`, `handoff/kyle-to-jarvis/`             | `specs/superpowers/**`, `handoff/jarvis-to-kyle/`                           |
| **Jarvis-BE** | `specs/**`, `handoff/kyle-to-jarvis/`                                        | `specs/superpowers/**`, `handoff/jarvis-to-kyle/`                           |
| **Kyle**      | `specs/**`, `handoff/jarvis-to-kyle/`                                        | `handoff/kyle-to-jarvis/`, `specs/superpowers/reviews/`                     |

#### 在 CLAUDE.md 中的写法示例

```markdown
## 📂 shared 工作区读写契约

### 读取范围（只读）
- `../shared/specs/openspec/changes/` — 阅读需求提案和任务拆分
- `../shared/handoff/ella-to-jarvis/` — 阅读设计稿
- `../shared/handoff/kyle-to-jarvis/` — 阅读审查反馈

### 写入范围（可写）
- `../shared/specs/superpowers/plans/` — 输出实施方案
- `../shared/handoff/jarvis-to-kyle/` — 提交代码待审信息

### ⛔ 禁止写入
- `../shared/specs/openspec/` — 需求提案由 Max 管理
- `../shared/handoff/ella-to-jarvis/` — 设计稿由 Ella 管理
- 其他角色的写入目录
```

---

### 问题3：怎么在人设中正确使用 openspec / superpowers，以及集成自定义 Skill

**这是最核心的问题。下面给出实事求是的分析。**

#### 3.1 当前 Skill 体系的实际状态

你当前有三层 Skill：
1. **openspec**（4个 skill）：位于 `agent-group/.claude/skills/`，是 Claude Code 原生 skill 格式
   - `openspec-propose`：创建变更提案
   - `openspec-apply-change`：执行变更
   - `openspec-explore`：浏览现有 spec
   - `openspec-archive-change`：归档变更
2. **superpowers**（12个子技能）：通过 `jarvis/skills/superpowers-guide/SKILL.md` 作为决策指南引用
3. **自定义 Skill**（你自己写的）：如 `java-backend`、`react-frontend`、`java-backend-review` 等

#### 3.2 它们的关系和执行层级

```
任务到达
  │
  ├─ 这是一个新需求/变更吗？
  │     └─→ openspec-propose → 生成 proposal + design + tasks
  │         └─→ openspec-apply-change → 按 tasks 开始实施
  │               │
  │               ├─ 实施过程中（编码环节）
  │               │     ├─ 后端编码 → 使用自定义 skill: java-backend
  │               │     ├─ 前端编码 → 使用自定义 skill: react-frontend
  │               │     └─ 代码审查 → 使用自定义 skill: java-backend-review / code-reviewer
  │               │
  │               └─ 实施过程中（流程环节）
  │                     ├─ 任务复杂需拆分 → superpowers: writing-plans + executing-plans
  │                     ├─ Bug 排查 → superpowers: systematic-debugging
  │                     ├─ 准备提审 → superpowers: requesting-code-review
  │                     └─ 处理审查意见 → superpowers: receiving-code-review
  │
  └─ 这是一个直接编码任务吗？（小改动、bug修复等）
        └─→ 跳过 openspec，直接使用自定义 skill + superpowers 流程技能
```

**核心结论**：
- **openspec 管"做什么"**：需求提案 → 设计 → 任务拆分
- **superpowers 管"怎么做的流程"**：方案推敲、计划执行、调试、审查流程
- **自定义 Skill 管"怎么写代码"**：具体的编码规范、技术栈约束、代码审查标准

#### 3.3 改造后的 CLAUDE.md 中 Skill 使用指令（以 Jarvis-BE 为例）

```markdown
## 🧰 技能体系

### 第一层：需求理解（openspec）
当收到新需求或变更请求时，**必须先检查** `../shared/specs/openspec/changes/` 是否已有对应的提案：
- **有提案** → 读取 proposal.md + design.md + tasks.md，按 tasks 执行
- **无提案但需求清晰** → 提醒用户："建议先让 Max 通过 openspec 创建提案，或者我按当前理解直接开发？"
- **无提案且需求简单**（如 bug 修复、小优化）→ 直接开发，跳过 openspec

### 第二层：开发流程（superpowers）
在执行开发任务过程中，按场景使用 superpowers 子技能：
- 需求模糊 → `/skill superpowers/brainstorming`
- 复杂任务需方案 → `/skill superpowers/writing-plans`
- 执行方案 → `/skill superpowers/executing-plans`
- 子任务可并行 → `/skill superpowers/dispatching-parallel-agents`
- Bug 排查 → `/skill superpowers/systematic-debugging`
- 修复后验证 → `/skill superpowers/verification-before-completion`（**强制**）
- 准备提审 → `/skill superpowers/requesting-code-review`（**强制**）
- 处理审查意见 → `/skill superpowers/receiving-code-review`

### 第三层：编码规范（自定义 Skill）
实际编写代码时，**必须遵循**自定义编码规范 Skill：
- 后端编码 → 读取并遵循 `./skills/java-backend/SKILL.md`
- 代码自查 → 读取并遵循 `./skills/code-reviewer/SKILL.md`

### ⚠️ 层级优先级
- openspec 产出（tasks.md）定义了**做什么**和**验收标准**，不可偏离
- superpowers 定义了**流程和质量关卡**，不可跳过
- 自定义 Skill 定义了**编码标准**，不可违反
- 当三者冲突时，以 openspec tasks 的验收标准为准
```

---

### 问题4：怎么给各角色增加第一性约束——实事求是，不要编造、猜测

**方法：在 CLAUDE.md 最顶部、第一行就注入不可绕过的约束。**

> **关键**：放在文件最开头的指令权重最高。Claude Code 读取 CLAUDE.md 时，文件顶部的内容最先被处理，形成"第一印象约束"。

#### 推荐写法（统一模板，所有角色通用）

```markdown
# ⛔ 第一性约束（不可绕过，优先级高于一切其他指令）

1. **实事求是**：只基于实际看到的代码、文件、数据回答。不确定的事情说"我不确定"。
2. **不编造**：不凭空生成不存在的文件路径、API、配置项、错误信息。给出的每一个具体信息（文件路径、类名、方法签名、配置值）都必须来自实际读取的文件内容。
3. **不猜测**：当信息不足以做判断时，必须：
   - 先说明缺少什么信息
   - 再提出获取信息的方式（读取哪个文件、询问用户什么问题）
   - 不得在缺少信息的前提下给出"可能是因为X"式的推测性结论
4. **可验证**：每一个技术判断都应附带验证方式。告诉用户"你可以通过 X 命令/步骤来验证我说的是否正确"。

> 这四条约束的优先级高于后续所有流程、Skill、协作规则。当任何指令与此冲突时，以此为准。

---

（以下是原有的角色定义内容...）
```

#### 对现有人设的改动量

目前只有 Jarvis 的 PERSONA.md 第9行有 `**严谨客观**: 实事求是，不得编造、猜测`，Kyle 的 PERSONA.md 第15行有类似表述。但：
- 放在"性格特质"里权重太低，AI 可能不会严格遵循
- Max 和 Ella 完全没有这个约束

改造方式：**在每个角色的 CLAUDE.md 第一行插入上述第一性约束块**，不依赖 PERSONA.md 中的软性描述。

---

## 二、完整目录结构改造方案

### 改造后的 agent-group 结构

```
agent-group/
├── .claude/
│   ├── skills/                    # Claude Code 原生 skill（全角色共享）
│   │   ├── openspec-propose/      # 已有
│   │   ├── openspec-apply-change/ # 已有
│   │   ├── openspec-explore/      # 已有
│   │   └── openspec-archive-change/ # 已有
│   └── settings.local.json
│
├── max/                           # Max - 项目经理
│   ├── CLAUDE.md                  # 含第一性约束 + openspec 流程
│   ├── PERSONA.md
│   └── skills/
│
├── ella/                          # Ella - UI/UX设计师
│   ├── CLAUDE.md                  # 含第一性约束 + handoff 契约
│   ├── PERSONA.md
│   └── skills/
│
├── jarvis-fe/                     # Jarvis 前端【新增】
│   ├── CLAUDE.md                  # 含第一性约束 + 前端专属流程 + skill集成
│   ├── PERSONA.md
│   └── skills/
│       ├── react-frontend/        # 从 jarvis/skills 迁移
│       ├── senior-frontend/       # 从 jarvis/skills 迁移
│       └── superpowers-guide/     # 从 jarvis/skills 复制
│
├── jarvis-be/                     # Jarvis 后端【新增】
│   ├── CLAUDE.md                  # 含第一性约束 + 后端专属流程 + skill集成
│   ├── PERSONA.md
│   └── skills/
│       ├── java-backend/          # 从 jarvis/skills 迁移
│       ├── code-reviewer/         # 从 jarvis/skills 迁移（通用代码审查）
│       ├── tdd-guide/             # 从 jarvis/skills 迁移
│       └── superpowers-guide/     # 从 jarvis/skills 复制
│
├── jarvis/                        # 【保留但标记弃用，过渡期兼容】
│   └── CLAUDE.md                  # 内容改为："请使用 jarvis-fe 或 jarvis-be"
│
├── kyle/                          # Kyle - QA工程师
│   ├── CLAUDE.md                  # 含第一性约束 + 审查流程
│   ├── PERSONA.md
│   └── skills/
│       ├── java-backend-review/   # 保留
│       ├── code-reviewer/         # 保留
│       ├── senior-qa/             # 保留
│       └── tdd-guide/             # 保留
│
├── shared/
│   ├── specs/                     #【核心改造】统一 spec 产出
│   │   └── openspec/              # openspec 产出物移至此处
│   │       ├── changes/           # 变更提案
│   │       └── config.yaml
│   ├── handoff/                   #【新增】角色间交付物
│   │   ├── ella-to-jarvis/
│   │   ├── jarvis-to-kyle/
│   │   └── kyle-to-jarvis/
│   ├── status.json                # 保留
│   └── notifications.json         # 保留
│
└── openspec/                      # 原位置保留为兼容，逐步迁移到 shared/specs/openspec
```

---

## 三、各角色 CLAUDE.md 改造模板

> 以下只展示**改造部分的结构骨架**，不重复现有的 Git 安全规则、Token 统计等不变内容。

### 3.1 通用头部（所有角色必须包含）

```markdown
# ⛔ 第一性约束（不可绕过，优先级高于一切其他指令）

1. **实事求是**：只基于实际看到的代码、文件、数据回答。不确定的事情说"我不确定"。
2. **不编造**：不凭空生成不存在的文件路径、API、配置项、错误信息。
3. **不猜测**：信息不足时，先说明缺少什么，再提出获取方式，不做推测性结论。
4. **可验证**：每一个技术判断附带验证方式。

> 此约束优先级高于后续所有流程、Skill、协作规则。

---
```

### 3.2 Max 改造要点

```markdown
# 麦克斯 (Max) - 项目指令

（通用头部 — 第一性约束）

## 核心变更：openspec 驱动的需求管理

### Max 是 openspec 的主要操作者
- 用户提出新需求时，**默认使用 openspec 创建提案**
- 执行 `/opsx:propose` 生成 proposal.md + design.md + tasks.md
- 产出物路径：`../shared/specs/openspec/changes/<变更名>/`
- 需要 Ella 介入设计时，将 design.md 的设计部分标记为"待 Ella 补充"
- 任务拆分后，通知对应 Jarvis（前端/后端）查看 tasks.md

### 何时不使用 openspec
- 简单问答、状态查询、会议记录等日常事务
- 用户明确表示"直接告诉 Jarvis 做"的小改动

### 📂 shared 读写契约
- **读取**: `shared/specs/**`, `shared/handoff/**`, `shared/status.json`
- **写入**: `shared/specs/openspec/**`, `shared/status.json`
- **禁写**: `shared/handoff/`（交付物由实际产出角色管理）

（保留原有：初始化步骤、可用技能、Token监控等）
```

### 3.3 Ella 改造要点

```markdown
# 艾拉 (Ella) - 项目指令

（通用头部 — 第一性约束）

## 核心变更：基于 openspec 提案的设计工作

### 设计任务的触发
- **有 openspec 提案时**：读取 `../shared/specs/openspec/changes/<变更名>/proposal.md`
  理解需求后，产出设计稿到 `../shared/handoff/ella-to-jarvis/<变更名>/`
- **用户直接下达设计任务时**：产出到同一目录

### 设计与 openspec 的协作
- 如果 proposal.md 中需求不清晰，使用 AskUserQuestion 澄清，**不要自行猜测**
- 可以补充 openspec 变更中的 design.md 的 UI 部分
- 设计完成后通知 Max 更新状态

### 📂 shared 读写契约
- **读取**: `shared/specs/openspec/changes/*/proposal.md`, `shared/specs/openspec/changes/*/design.md`
- **写入**: `shared/handoff/ella-to-jarvis/`, `shared/specs/openspec/changes/*/design.md`（仅 UI 部分）
- **禁写**: `shared/specs/openspec/changes/*/proposal.md`, `shared/specs/openspec/changes/*/tasks.md`

（保留原有：设计规范、UI/UX Pro Max Skill、图标资源等）
```

### 3.4 Jarvis-FE 改造要点

```markdown
# 贾维斯-前端 (Jarvis-FE) - 项目指令

（通用头部 — 第一性约束）

## 身份
你是 **贾维斯-前端 (Jarvis-FE)**，专注于前端开发的工程师。
你只负责前端代码（React/TypeScript/CSS），后端开发由 Jarvis-BE 负责。

## 🧰 三层技能体系

### 第一层：需求理解（openspec）
1. 收到开发任务时，先检查 `../shared/specs/openspec/changes/` 是否有对应提案
2. 有提案 → 读取 tasks.md 中标记为"前端"的任务项
3. 有设计稿 → 读取 `../shared/handoff/ella-to-jarvis/` 中的设计文件
4. 无提案且需求简单 → 直接开发

### 第二层：开发流程（superpowers）
按场景调用，详见 `./skills/superpowers-guide/SKILL.md`
- **强制使用**：
  - 修复后 → `verification-before-completion`
  - 提审前 → `requesting-code-review`
  - 收到审查意见 → `receiving-code-review`

### 第三层：编码规范（自定义 Skill）
编写前端代码时 **必须遵循**：
- `./skills/react-frontend/SKILL.md` — React 编码规范
- `./skills/senior-frontend/SKILL.md` — 高级前端实践

### 技能使用示例：openspec 任务执行完整流程

1. 读取 ../shared/specs/openspec/changes/xxx/tasks.md（了解任务）
2. 读取 ../shared/handoff/ella-to-jarvis/xxx/（了解设计）
3. [如果任务复杂] /skill superpowers/writing-plans → 输出方案到 ../shared/specs/superpowers/plans/
4. 编码（遵循 react-frontend SKILL.md）
5. /skill superpowers/verification-before-completion
6. /skill superpowers/requesting-code-review
7. 将待审信息写入 ../shared/handoff/jarvis-to-kyle/


### 📂 shared 读写契约
- **读取**: `shared/specs/**`, `shared/handoff/ella-to-jarvis/`, `shared/handoff/kyle-to-jarvis/`
- **写入**: `shared/specs/superpowers/plans/`, `shared/handoff/jarvis-to-kyle/`
- **禁写**: `shared/specs/openspec/`, `shared/handoff/ella-to-jarvis/`

## 项目上下文
- 工作目录：`cloud-frontend/`
- 项目说明：读取 `cloud-frontend/.claude/project.md`
- 技术栈：React 18 + TypeScript + Ant Design 6 + Zustand + Vite 6 + Wujie 微前端

（保留原有的 Token 监控、Git 安全规则等）

### 3.5 Jarvis-BE 改造要点

```markdown
# 贾维斯-后端 (Jarvis-BE) - 项目指令

（通用头部 — 第一性约束）

## 身份
你是 **贾维斯-后端 (Jarvis-BE)**，专注于后端开发的工程师。
你只负责后端代码（Java/Spring Boot/SQL），前端开发由 Jarvis-FE 负责。

## 🧰 三层技能体系

### 第一层：需求理解（openspec）
（同 Jarvis-FE 结构，但关注 tasks.md 中的"后端"任务项）

### 第二层：开发流程（superpowers）
（同 Jarvis-FE 结构）

### 第三层：编码规范（自定义 Skill）
编写后端代码时 **必须遵循**：
- `./skills/java-backend/SKILL.md` — Java 后端编码规范
- `./skills/code-reviewer/SKILL.md` — 代码审查标准

### 📂 shared 读写契约
- **读取**: `shared/specs/**`, `shared/handoff/kyle-to-jarvis/`
- **写入**: `shared/specs/superpowers/plans/`, `shared/handoff/jarvis-to-kyle/`
- **禁写**: `shared/specs/openspec/`, `shared/handoff/ella-to-jarvis/`

## 项目上下文
- 工作目录：`cloud-backend/`
- 项目说明：读取 `cloud-backend/.claude/project.md`（如不存在则建议创建）
- 技术栈：Java + Spring Boot + MyBatis + MySQL

（保留原有的 Token 监控、Git 安全规则等）
```

### 3.6 Kyle 改造要点

```markdown
# 凯尔 (Kyle) - 项目指令

（通用头部 — 第一性约束）

## 核心变更：基于 openspec 提案的验收审查

### 审查任务的触发
1. 收到 Jarvis 的审查请求 → 读取 `../shared/handoff/jarvis-to-kyle/`
2. 同时读取对应的 openspec tasks.md 作为**验收基准**
3. 产出审查报告到 `../shared/handoff/kyle-to-jarvis/`

### 审查规范 Skill 的使用
- 后端代码审查 → 使用 `./skills/java-backend-review/SKILL.md`
- 通用代码审查 → 使用 `./skills/code-reviewer/SKILL.md`
- 使用 superpowers 中的审查流程：
  - 收到代码时 → 执行 `code-reviewer` 或 `java-backend-review` Skill 中的审查标准
  - 审查完成 → 将结果写入 handoff，通知 Jarvis

### 📂 shared 读写契约
- **读取**: `shared/specs/**`, `shared/handoff/jarvis-to-kyle/`
- **写入**: `shared/handoff/kyle-to-jarvis/`
- **禁写**: `shared/specs/openspec/`, `shared/handoff/ella-to-jarvis/`, `shared/handoff/jarvis-to-kyle/`

（保留原有：验收规范、审查清单、Token 监控等）
```

---

## 四、openspec 配置迁移

将 `agent-group/openspec/` 迁移到 `agent-group/shared/specs/openspec/`，同时更新 config.yaml：

```yaml
schema: spec-driven

context: |
  语言：中文（简体）
  所有产出物必须用简体中文撰写。
  
  项目结构：
  - 后端: cloud-backend (Java/Spring Boot)
  - 前端: cloud-frontend (React 18/TypeScript/Ant Design 6/Wujie 微前端)
  
  团队角色：
  - Max: 项目经理，负责创建和管理 openspec 提案
  - Ella: UI/UX 设计师，负责补充 design.md 的 UI 部分
  - Jarvis-FE: 前端开发，执行 tasks.md 中的前端任务
  - Jarvis-BE: 后端开发，执行 tasks.md 中的后端任务
  - Kyle: QA 工程师，基于 tasks.md 验收标准做代码审查

rules:
  proposal:
    - 需求描述必须明确，不允许模糊表述
    - 必须包含"验收标准"章节
  design:
    - 技术设计部分区分前端和后端
    - UI/UX 设计部分由 Ella 补充
  tasks:
    - 每个 task 必须标记归属角色（jarvis-fe / jarvis-be）
    - 每个 task 必须有明确的验收条件
    - 单个 task 工作量不超过 15 分钟
```

---

## 五、关于"铁律强制流程"的精简建议

> **⚠️ 注意**：这一节是额外建议。你现有的"7个强制检查点"在每个角色的 CLAUDE.md 中占了约200行，且四个角色**几乎完全重复**。这带来两个问题：
> 1. 上下文膨胀：每次对话都要处理大量重复指令，消耗 Token
> 2. 维护困难：改一处要改四处

**建议**：将公共流程提取到 `agent-group/shared/protocols/mandatory-flow.md`，各角色 CLAUDE.md 改为：

```markdown
## ⚡ 强制流程
读取并严格遵循 `../shared/protocols/mandatory-flow.md` 中的强制检查点序列。
```

这样公共流程只维护一份，且减少每个 CLAUDE.md 的体积约 40%。

---

## 六、落地实施步骤

### Phase 1: 基础结构改造（建议立刻做）

- [ ] 1.1 在 `shared/` 下创建 `specs/openspec/`、`handoff/` 目录结构
- [ ] 1.2 将 `agent-group/openspec/` 的内容移动到 `shared/specs/openspec/`
- [ ] 1.3 创建 `jarvis-fe/` 和 `jarvis-be/` 目录
- [ ] 1.4 将 Jarvis 的 skills 按前后端分拆到两个目录
- [ ] 1.5 给原 `jarvis/CLAUDE.md` 添加弃用提示

### Phase 2: CLAUDE.md 改造（建议紧接着做）

- [ ] 2.1 为所有 5 个角色的 CLAUDE.md 添加"第一性约束"头部
- [ ] 2.2 为 Max 的 CLAUDE.md 添加 openspec 驱动的需求管理流程
- [ ] 2.3 编写 Jarvis-FE 的完整 CLAUDE.md（从原 Jarvis 裁剪后端部分）
- [ ] 2.4 编写 Jarvis-BE 的完整 CLAUDE.md（从原 Jarvis 裁剪前端部分）
- [ ] 2.5 为所有角色添加 shared 读写契约

### Phase 3: Skill 集成验证（做完 Phase 2 后测试）

- [ ] 3.1 用 Max 执行一次 `/opsx:propose`，验证提案产出到 `shared/specs/openspec/changes/`
- [ ] 3.2 用 Jarvis-BE 基于提案执行一个后端任务，验证三层 Skill 串联
- [ ] 3.3 用 Jarvis-FE 基于提案执行一个前端任务，验证设计稿读取 + 编码规范
- [ ] 3.4 用 Kyle 基于 handoff 做一次代码审查，验证审查规范 Skill 集成

### Phase 4: 优化与清理（验证通过后）

- [ ] 4.1 提取公共流程到 `shared/protocols/mandatory-flow.md`
- [ ] 4.2 更新启动脚本 `start-jarvis-fe.sh`、`start-jarvis-be.sh`
- [ ] 4.3 更新 README.md 反映新架构
- [ ] 4.4 清理原 `jarvis/` 目录（确认迁移完成后）
- [ ] 4.5 更新 `skills-distribution.md`

---

## 七、风险提示

> **⚠️ 以下是实事求是的风险点，不要忽视：**

1. **Claude Code `--project` 路径限制**：当前 Claude Code 的 `--project` 参数是否支持指向 `agent-group/jarvis-fe` 同时在 `cloud-frontend/` 工作？需要实际测试。如果不行，备选方案是在 `cloud-frontend/.claude/` 下创建 CLAUDE.md 并 `include` agent-group 的内容。

2. **openspec CLI 的工作目录**：openspec 命令（如 `openspec new change`）要求在包含 `openspec/` 目录的路径下执行。迁移到 `shared/specs/openspec/` 后需要验证 CLI 是否仍然正常工作。

3. **CLAUDE.md 体积问题**：即使精简了强制流程，加上三层 Skill 说明 + 读写契约，单个 CLAUDE.md 可能仍有 300+ 行。需要在实践中验证 Claude Code 是否能稳定遵循长指令。

4. **角色间实际通信**：当前的通信机制（status.json + notifications.json）是手动式的。openspec 的产出物天然就是"可被多角色读取的文档"，可以逐步替代部分通知机制，但过渡期两者需要共存。

5. **Jarvis 拆分后的协作边界**：某些任务（如"表单提交接口联调"）需要前后端同时改动。此时需要 Max 在 tasks.md 中明确拆分为前端 task + 后端 task，并标注依赖关系。如果 Max 拆分不到位，Jarvis-FE/BE 会遇到职责模糊的情况。

   **✅ 解决方案：双向标注（Cross-Tagging）协作机制**

   不能仅依赖 Max 做完美的前后端拆分。实际开发中，**前端最了解自己需要什么接口，后端最了解自己提供的数据结构**。因此引入"双向标注"机制：

   - **Jarvis-FE 可以标注后端任务**：在开发过程中发现需要新接口或接口变更时，在 `shared/handoff/fe-to-be/` 下创建标注文件
   - **Jarvis-BE 可以标注前端任务**：在开发过程中发现接口返回结构变更、新增字段等前端需要适配的情况时，在 `shared/handoff/be-to-fe/` 下创建标注文件
   - **联合提审**：当一个功能涉及前后端联动时，双方各自完成开发后，**统一提交给 Kyle 审查**，Kyle 可以在同一个审查周期中看到完整的前后端变更

   > 这样两个角色可以真正联动开发，而非"等 Max 拆完才能动"。

---

## 八、前后端双向标注（Cross-Tagging）协作协议

> **核心理念**：让最了解业务细节的角色来补充任务，而非全部压给 Max。

### 8.1 新增 handoff 目录

```
agent-group/shared/
├── handoff/
│   ├── ella-to-jarvis/       # 已有 — 设计稿交付
│   ├── jarvis-to-kyle/       # 已有 — 代码待审交付
│   ├── kyle-to-jarvis/       # 已有 — 审查反馈
│   ├── fe-to-be/             # 【新增】前端标注后端任务
│   └── be-to-fe/             # 【新增】后端标注前端任务
```

### 8.2 标注文件格式

前后端互标的文件遵循统一格式，存放在对应 handoff 目录下：

```markdown
# Cross-Tag: <简要标题>

- **来源**: jarvis-fe / jarvis-be
- **关联变更**: <openspec change name>（如适用）
- **关联 task**: <原 tasks.md 中的 task ID>（如适用）
- **优先级**: P0（阻塞） / P1（重要） / P2（建议）
- **状态**: pending / accepted / done

## 需求描述

<描述对方需要做什么，越具体越好>

## 接口/数据契约

<如涉及接口，给出具体的 URL、请求参数、返回结构>

## 验收标准

<对方完成后如何验证>
```

**示例 — 前端标注后端任务** (`shared/handoff/fe-to-be/budget-export-api.md`)：

```markdown
# Cross-Tag: 预算执行导出接口

- **来源**: jarvis-fe
- **关联变更**: budget-execution-query
- **关联 task**: FE-003
- **优先级**: P0（阻塞）
- **状态**: pending

## 需求描述

前端查询页面需要新增"导出Excel"功能，需要后端提供一个导出接口。

## 接口/数据契约

- URL: `POST /api/budget/execution/export`
- 请求体: 与查询接口 `/api/budget/execution/query` 一致
- 返回: 文件流（application/octet-stream），文件名格式 `预算执行_{yyyyMMdd}.xlsx`

## 验收标准

- [ ] 接口可正常返回 Excel 文件
- [ ] 返回数据与查询接口结果一致
- [ ] 文件名包含导出日期
```

### 8.3 协作流程

```
 Max 拆分 tasks.md（标注 jarvis-fe / jarvis-be）
      │
      ├──→ Jarvis-FE 开始前端开发
      │        │
      │        ├─ 发现需要新接口 → 在 fe-to-be/ 创建标注文件
      │        ├─ 收到 be-to-fe/ 标注 → 适配后端变更
      │        └─ 完成 → 写入 jarvis-to-kyle/ 待审
      │
      └──→ Jarvis-BE 开始后端开发
               │
               ├─ 发现接口结构变更 → 在 be-to-fe/ 创建标注文件
               ├─ 收到 fe-to-be/ 标注 → 实现前端需要的接口
               └─ 完成 → 写入 jarvis-to-kyle/ 待审
                          │
                          ▼
              Kyle 统一审查（同一功能的前后端变更一起审）
```

### 8.4 读写契约更新

在原有权限表基础上新增：

| 角色          | 新增可读                                 | 新增可写                    |
| ------------- | ---------------------------------------- | --------------------------- |
| **Jarvis-FE** | `handoff/be-to-fe/`                      | `handoff/fe-to-be/`         |
| **Jarvis-BE** | `handoff/fe-to-be/`                      | `handoff/be-to-fe/`         |
| **Kyle**      | `handoff/fe-to-be/`, `handoff/be-to-fe/` | —（只读，用于理解变更全貌） |
| **Max**       | `handoff/fe-to-be/`, `handoff/be-to-fe/` | —（只读，用于跟踪任务补充） |

### 8.5 CLAUDE.md 中的补充指令

**Jarvis-FE CLAUDE.md 中新增：**

```markdown
## 🔄 前后端联动协作

### 标注后端任务
当你在开发过程中发现需要后端接口支持时：
1. **不要等待 Max 拆分** — 直接在 `../shared/handoff/fe-to-be/` 下创建标注文件
2. 遵循 Cross-Tag 模板格式，重点写清楚接口契约
3. 优先级为 P0 的标注应同时通知 Jarvis-BE

### 响应后端标注
定期检查 `../shared/handoff/be-to-fe/`：
- 有新标注 → 评估影响、安排适配
- 标记为 P0 → 优先处理

### 联合提审
当一个功能涉及前后端联动时：
- 等双方都 done 后，在 `../shared/handoff/jarvis-to-kyle/` 中创建联合审查请求
- 联合审查请求需引用所有相关的 cross-tag 文件和前后端变更清单
```

**Jarvis-BE CLAUDE.md 中新增（对称结构，方向互换）：**

```markdown
## 🔄 前后端联动协作

### 标注前端任务
当接口结构、返回字段等发生变更时：
1. **主动通知前端** — 在 `../shared/handoff/be-to-fe/` 下创建标注文件
2. 遵循 Cross-Tag 模板格式，重点写清楚数据结构变更
3. 优先级为 P0 的标注应同时通知 Jarvis-FE

### 响应前端标注
定期检查 `../shared/handoff/fe-to-be/`：
- 有新标注 → 评估可行性、确认接口设计
- 标记为 P0 → 优先实现

### 联合提审
（同 Jarvis-FE 规则）
```

### 8.6 与 Max 的协作补充

Max 在 tasks.md 中拆分任务时，可以：
- 对于**边界清晰**的任务：直接分配给 jarvis-fe 或 jarvis-be
- 对于**边界模糊**的任务：标记为 `需前后端协商`，由 Jarvis-FE/BE 通过 cross-tag 机制自行细化
- 定期查看 `fe-to-be/` 和 `be-to-fe/` 中的标注，将成熟的标注**回填到 tasks.md** 保持任务列表完整

> **效果**：Max 负责宏观拆分，Jarvis-FE/BE 负责微观补充，Kyle 负责整体验收。三层职责清晰，不存在"等某个人拆完才能动"的瓶颈。

---

## 九、openspec 产出物逐步替代通知机制

> **注意**：本阶段暂不涉及通知机制的替代，后续阶段再进行讨论。

> **背景**：第七节风险点4指出"openspec 的产出物天然就是'可被多角色读取的文档'，可以逐步替代部分通知机制"，但缺失**怎么替代**的具体方案。以下是基于当前实际文件结构的实事求是的分析和迁移路线。

### 9.1 现状诊断：当前通知机制的实际用途

通过实际读取 `shared/notifications.json` 和 `shared/status.json`，当前通知可归为 **5 种用途**：

| 序号 | 通知类型              | 典型例子                    | 当前载体           | 能否被 openspec 替代 |
| ---- | --------------------- | --------------------------- | ------------------ | -------------------- |
| ①    | **任务分配**          | Max 给 Jarvis 分配 bug 修复 | notifications.json | ✅ 可以               |
| ②    | **审查请求**          | Jarvis 请 Kyle 代码审查     | notifications.json | ✅ 可以               |
| ③    | **任务进度/状态**     | Phase 1-5 各阶段的 status   | status.json        | ✅ 可以               |
| ④    | **日常通告**          | 每周会议提醒、一般性信息    | notifications.json | ❌ 不适合             |
| ⑤    | **紧急事件/即时通信** | 紧急 bug、阻塞性问题        | notifications.json | ❌ 不适合             |

#### 9.1.1 能替代的原因

- **①②③** 的信息本质是"某个变更的某个阶段产生了某个产出物，需要某个角色来处理"。openspec 的 `changes/<变更名>/` 目录结构（proposal.md → design.md → tasks.md）+ handoff 目录天然承载了这些信息。
- openspec 产出物是**自描述的文档**，比 JSON 通知条目包含更丰富的上下文（需求背景、验收标准、设计决策等）。

#### 9.1.2 不能替代的原因

- **④⑤** 的信息与特定变更无关（会议通知），或者需要**即时性**（紧急 bug），不适合用文档形式承载。
- 即使 openspec 能替代任务分配，在紧急场景下角色不一定会主动去轮询 `changes/` 目录，仍然需要一个"推送"机制。

### 9.2 替代映射：每种通知类型的具体迁移方式

#### ① 任务分配 → openspec change + handoff

**当前方式（notifications.json）**：
```json
{
  "type": "task_assignment",
  "from": "max",
  "to": "jarvis",
  "subject": "紧急Bug修复任务",
  "content": { "task_id": "...", "file": "...", "issue": "..." }
}
```

**替代方式**：
```
openspec/changes/login-bug-fix/
├── proposal.md    ← 包含 issue 描述、影响范围（替代 content 字段）
├── tasks.md       ← 包含具体任务项+归属角色（替代 to 字段）
└── _meta.yaml     ← 【新增】状态追踪元数据（见下文）
```

**`_meta.yaml` 格式**（每个 change 目录下新增）：
```yaml
change: login-bug-fix
created_by: max
created_at: 2026-04-04T09:00:00Z
priority: P0
status: in-progress          # proposed → in-progress → review → done → archived
assigned_to:
  - role: jarvis-be
    tasks: [T1, T2]
    status: in-progress
  - role: jarvis-fe
    tasks: [T3]
    status: pending
# 谁需要关注这个变更
notify:
  - jarvis-be    # 有新任务
  - jarvis-fe    # 有新任务
  - kyle         # 后续需要审查
```

> **关键点**：`_meta.yaml` 是 openspec 产出物的**结构化状态层**，替代 notifications.json 中的 `to`、`priority`、`actions` 字段。角色启动后扫描所有 `changes/*/meta.yaml`，根据 `notify` 和 `assigned_to` 判断自己是否需要关注。

#### ② 审查请求 → handoff + _meta.yaml 状态流转

**当前方式（notifications.json）**：
```json
{
  "type": "review_request",
  "from": "jarvis",
  "to": "kyle",
  "content": { "review_report": "shared/reviews/xxx.md", "modified_files": [...] }
}
```

**替代方式**：
1. Jarvis 在 `shared/handoff/jarvis-to-kyle/<变更名>.md` 写入审查请求（包含修改文件清单、自查报告引用）
2. 同时更新 `openspec/changes/<变更名>/_meta.yaml` 的 status 为 `review`
3. Kyle 启动后扫描 `_meta.yaml` 中 status=review 的变更 → 自动知道有审查任务

**handoff/jarvis-to-kyle/<变更名>.md 模板**：
```markdown
# 审查请求: <变更名>

- **提交者**: jarvis-be
- **提交时间**: 2026-04-04T10:00:00Z
- **关联变更**: openspec/changes/<变更名>/
- **自查报告**: shared/specs/superpowers/reviews/<变更名>-self-review.md

## 变更文件清单
- `cloud-backend/.../XxxService.java` — 新增 xxx 方法
- `cloud-backend/.../XxxController.java` — 新增 xxx 端点

## 自查结果摘要
（引用 superpowers requesting-code-review 的产出）

## 验收基准
参见 openspec/changes/<变更名>/tasks.md 中的验收标准
```

#### ③ 任务进度/状态 → _meta.yaml 聚合替代 status.json

**当前方式（status.json）**：
```json
{
  "tasks": {
    "backend-basic-modules": {
      "phases": [
        { "phase": "Phase 1", "status": "复审通过", "completedDate": "..." },
        { "phase": "Phase 2", "status": "复审通过", ... }
      ]
    }
  }
}
```

**替代方式**：每个 openspec change 的 `_meta.yaml` 自带 status，不需要在 `status.json` 中重复维护。

**聚合视图**：如果 Max 需要全局视角，可以通过扫描所有 `changes/*/meta.yaml` 汇总：
```
# 等价于 status.json 的信息，但分布式存储在各 change 目录中
openspec/changes/
├── phase-1-dept-role/         _meta.yaml → status: done
├── phase-2-employee/          _meta.yaml → status: done
├── phase-3-basic-data/        _meta.yaml → status: done
├── phase-4-dict-dim/          _meta.yaml → status: done
├── phase-5-serial-project/    _meta.yaml → status: done
├── phase-1-5-standards/       _meta.yaml → status: review
└── new-feature-xxx/           _meta.yaml → status: in-progress
```

> **优势**：状态与变更内容（proposal/design/tasks）在一起，不会出现 status.json 和实际文档不一致的问题。

#### ④⑤ 不可替代的部分 — 保留精简版 notifications.json

日常通告和紧急事件仍保留 `notifications.json`，但**大幅精简**——只保留**非变更相关**的通知：

```json
{
  "meta": { "version": "2.0.0", "description": "仅用于非变更类通知" },
  "notifications": [
    {
      "id": "notif_100",
      "type": "meeting",
      "from": "max",
      "to": "all",
      "subject": "每周团队会议提醒",
      "content": { "meeting_time": "...", "agenda": [...] },
      "expires_at": "..."
    },
    {
      "id": "notif_101",
      "type": "urgent_adhoc",
      "from": "max",
      "to": "jarvis-be",
      "subject": "🚨 生产环境紧急问题",
      "content": { "description": "...", "impact": "..." },
      "expires_at": "..."
    }
  ]
}
```

> **⚠️ 注意**：紧急 bug 如果已有 openspec 提案，则走 `_meta.yaml` 的 `priority: P0` 机制；只有**没来得及创建提案的临时紧急事件**才用 notifications.json。

### 9.3 角色启动时的自动扫描协议

过渡完成后，每个角色启动时的检查流程变为：

```markdown
## 启动检查序列（写入各角色 CLAUDE.md）

### 第一步：扫描 openspec 变更状态（替代原通知检查）
1. 读取 `../shared/specs/openspec/changes/` 下所有 `_meta.yaml`
2. 筛选与自己相关的变更：
   - `assigned_to` 中包含自己角色名的
   - `notify` 中包含自己角色名的
   - `status` 为自己需要响应的状态（如 Kyle 关注 status=review）
3. 按 priority 排序，报告给用户

### 第二步：扫描 handoff 目录（检查角色间交付物）
1. 读取自己的"收件箱"目录：
   - Jarvis-FE: `handoff/ella-to-jarvis/`, `handoff/kyle-to-jarvis/`, `handoff/be-to-fe/`
   - Jarvis-BE: `handoff/kyle-to-jarvis/`, `handoff/fe-to-be/`
   - Kyle: `handoff/jarvis-to-kyle/`
2. 检查是否有新的未处理文件

### 第三步：检查残留通知（过渡期兼容）
1. 读取 `../shared/notifications.json`
2. 只关注 type=meeting 或 type=urgent_adhoc 的条目
```

### 9.4 分阶段迁移路线

#### Phase A：引入 _meta.yaml（与现有通知共存）

> **目标**：给现有的 openspec change 加上结构化状态，不删除任何现有机制。

- [ ] A.1 为现有的每个 `openspec/changes/<变更名>/` 目录添加 `_meta.yaml`
- [ ] A.2 在 Max 的 CLAUDE.md 中添加指令：创建新提案时**同时生成** `_meta.yaml`
- [ ] A.3 在 Jarvis 的 CLAUDE.md 中添加指令：任务状态变更时**同时更新** `_meta.yaml` 和 `status.json`（双写）
- [ ] A.4 在 Kyle 的 CLAUDE.md 中添加指令：审查完成时**同时更新** `_meta.yaml` 和 notifications.json（双写）

> **效果**：新旧机制双写、双可读。任何角色都可以从任一渠道获取信息。

#### Phase B：角色启动优先读取 _meta.yaml

> **目标**：验证 openspec 产出物作为信息源的可靠性。

- [ ] B.1 修改各角色的启动检查序列，**优先**从 `_meta.yaml` 获取任务和状态信息
- [ ] B.2 `status.json` 降级为"聚合仪表盘"——只由 Max 定期从 `_meta.yaml` 汇总生成，不再是各角色的主要信息源
- [ ] B.3 `notifications.json` 中的 `task_assignment` 和 `review_request` 类型不再新增，但保留现存条目

> **效果**：信息流以 openspec 为主、旧机制为辅。如果发现 _meta.yaml 信息不全，可以随时 fallback 到 status.json。

#### Phase C：清理旧机制（确认无问题后）

> **目标**：移除冗余的信息载体。

- [ ] C.1 `status.json` 精简为仅保留 `projects` 级别的概要信息，移除 `tasks.phases` 明细（已由 `_meta.yaml` 承载）
- [ ] C.2 `notifications.json` 精简为仅保留 `meeting` 和 `urgent_adhoc` 类型
- [ ] C.3 停止所有角色的 `status.json.tasks` 双写
- [ ] C.4 更新 `shared/scripts/check_notifications.sh`，使其同时扫描 `_meta.yaml` + `notifications.json`
- [ ] C.5 更新 `shared/.notification_cache.json` 和缓存逻辑适配新机制

### 9.5 信息流对比：迁移前 vs 迁移后

```
=== 迁移前 ===

Max 创建任务
  → 手动写 notifications.json (task_assignment)
  → 手动写 status.json (新 phase)
  → 可能也用 openspec 创建 proposal/tasks

Jarvis 查看任务
  → 读 notifications.json 找自己的通知
  → 读 status.json 看当前进度
  → 可能还要读 openspec changes

Jarvis 提审
  → 手动写 notifications.json (review_request)
  → 手动更新 status.json

Kyle 收到审查
  → 读 notifications.json 找 review_request
  → 读 status.json 了解上下文

《问题》：同一件事的信息分散在 3 处，容易不一致


=== 迁移后 ===

Max 创建任务
  → openspec propose → 自动生成 proposal.md + tasks.md + _meta.yaml
  （一个操作，信息集中在一个目录）

Jarvis 查看任务
  → 扫描 changes/*/_meta.yaml，找 assigned_to 包含自己的
  → 原地读取同目录的 tasks.md 了解具体任务
  （一个目录包含全部上下文）

Jarvis 提审
  → 更新 _meta.yaml status 为 review
  → 在 handoff/jarvis-to-kyle/ 写审查请求
  （两步操作，信息有明确关联）

Kyle 收到审查
  → 扫描 _meta.yaml status=review 的变更
  → 读取 handoff/jarvis-to-kyle/ 中的审查请求
  → 读取同变更目录的 tasks.md 作为验收基准
  （所有信息自动关联）

《效果》：同一件事的信息集中在 openspec change 目录中，不易不一致
```

### 9.6 风险和注意事项

1. **_meta.yaml 不是银弹**：它解决的是"变更相关的角色间通信"问题。团队层面的非结构化沟通（如讨论技术选型、确认需求疑问）仍然需要通过用户在各角色间转达，这不是文件系统能自动化的。

2. **扫描性能**：随着 changes 目录増多，全量扫描 `_meta.yaml` 可能变慢。建议 Phase C 中引入一个 `changes/_index.yaml`（由 Max 维护的活跃变更索引），避免每次都 glob 扫描所有子目录。

3. **并发写入风险**：如果 Jarvis-FE 和 Jarvis-BE 同时更新同一个 `_meta.yaml`（它们可能负责同一个变更的不同 task），可能产生写冲突。建议每个角色只更新自己在 `assigned_to` 中的 `status` 字段，不修改其他角色的条目。

4. **过渡期的"双写"成本**：Phase A/B 期间各角色需要同时写 `_meta.yaml` 和 `status.json`/`notifications.json`，增加了指令复杂度。建议 Phase A 持续时间不超过 2 个迭代周期，尽快推进到 Phase B。
