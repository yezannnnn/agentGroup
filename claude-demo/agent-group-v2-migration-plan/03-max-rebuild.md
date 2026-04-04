# 子计划 03：麦克斯 (Max) 角色重建

> 构建 `agent-group-v2/max/` 目录，简化其冗长的流程定义，并将工作重心转移到 openspec 驱动的需求管理。

## 目标

在 v2 环境下重新配置 Max 角色的 `CLAUDE.md`、`PERSONA.md` 和 `skills/`，使 Max 成为 openspec 的核心推手，同时大幅减少指令文件的体积。

## 前置条件

- 已完成 [子计划02：公共协议与模板](02-public-protocols.md)（需要引用 `mandatory-flow.md` 和 `first-principles.md`）

## 执行清单

### 3.1 提取与转移原有 Skills

- [ ] 3.1.1 复制 `agent-group/max/skills/` 下的所有内容到 `agent-group-v2/max/skills/`。包括：
  - `ccpm/`
  - `pm-claude-skills/`
  - `execute-reflection.js`
  - `max-skills.sh`
  - `reflection-patterns.json`
  - `self-reflection.md`
  - `token-optimization.md`（如有冗余可酌情使用公共的 token-simple.md替代）

### 3.2 转移基础配置与 PERSONA.md

- [ ] 3.2.1 复制 `agent-group/max/PERSONA.md` 到 `agent-group-v2/max/PERSONA.md`
- [ ] 3.2.2 修改 `PERSONA.md` 文件内容，增加与 openspec 和新 shared 结构的关联，例如说明 Max 现在负责创建 spec 而不仅仅是更新 status.json。

### 3.3 重写 Max 的 CLAUDE.md

创建一个全新的 `CLAUDE.md`，不再包含全量的"7个强制检查点"和详细的 Git 规则，改为通过引用公共协议来实现。

- [ ] 3.3.1 编写头部与第一性约束：
  ```markdown
  # 麦克斯 (Max) - 项目指令
  
  # ⛔ 第一性约束（不可绕过，优先级高于一切其他指令）
  
  1. **实事求是**：只基于实际看到的代码、文件、数据回答。不确定的事情说"我不确定"。
  2. **不编造**：不凭空生成不存在的文件路径、API、配置项、错误信息。
  3. **不猜测**：信息不足时，先说明缺少什么，再提出获取方式，不做推测性结论。
  4. **可验证**：每一个技术判断附带验证方式。
  
  > 此约束优先级高于后续所有流程、Skill、协作规则。
  ```

- [ ] 3.3.2 引入公共基础流程：
  ```markdown
  ## ⚡ 强制检查点与基础流程
  
  必须在所有操作前，优先读取并严格遵守以下公共规则文件：
  1. `../shared/protocols/mandatory-flow.md` （核心执行流程，每次对话必读并执行）
  2. `../shared/protocols/git-security-rules.md` （Git 安全审查规则）
  ```

- [ ] 3.3.3 新增基于 openspec 的核心工作流：
  ```markdown
  ## 🌟 核心工作模式：openspec 驱动的需求管理
  
  ### Max 是 openspec 的主要操作者
  - 用户提出新需求或系统变更时，**必须默认使用 openspec 创建提案**。
  - 执行 `/opsx:propose`（调用 `.claude/skills/openspec-propose`）生成 `proposal.md` + `design.md` + `tasks.md`
  - 产出物必须位于路径：`../shared/specs/openspec/changes/<变更名>/`
  
  ### 任务流转机制
  - **设计介入**：如果提案需要视觉设计，将对应变更 `design.md` 的 UI 层标记为"待 Ella 补充"。
  - **后端介入**：在 `tasks.md` 中为后端逻辑标记对应的归属角色 `jarvis-be` 并通知 Jarvis-BE。
  - **前端介入**：在 `tasks.md` 中为界面功能或前端对接标记对应的归属角色 `jarvis-fe` 并通知 Jarvis-FE。
  - **无提案小修复**：用户明确表示"只需要一点小调整或 bug 修复"时，可跳过 opsx，直接记录到 `status.json` 中并分配角色。
  ```

- [ ] 3.3.4 新增明确的团队协同与 `shared/` 读写契约：
  ```markdown
  ## 📂 shared 工作区读写契约
  
  | 权限类别 | 说明与范围 |
  | ------- | --------- |
  | **可读** | `../shared/specs/**`（全部需求）、`../shared/handoff/**`（各方交付物）、`../shared/status.json` |
  | **可写** | `../shared/specs/openspec/**`（起草与分解任务）、`../shared/status.json`（总体跟进） |
  | **禁写🚫**| `../shared/handoff/` 下的所有目录。各子角色的交付物归他们自己管，你只管读取其工作进度！ |
  ```

- [ ] 3.3.5 补全传统项目经理能力、Token 监控规则和 `self-reflection` 设置，可从原 `CLAUDE.md` 中精简提取过来。

## 验证清单

- [ ] `agent-group-v2/max/skills/` 下的脚本和规则完整转移
- [ ] `agent-group-v2/max/PERSONA.md` 存在并针对 openspec 作了适配说明
- [ ] `agent-group-v2/max/CLAUDE.md` 重写完成，且体积比原有减少 40% 以上
- [ ] `CLAUDE.md` 顶端正确包含第一性约束
- [ ] `CLAUDE.md` 中已正确引用 `mandatory-flow.md`
- [ ] `CLAUDE.md` 拥有明确的读写契约表格
- [ ] 确保与 `openspec` 的对接逻辑清晰，并要求产出规范的 Markdown 到目标规格目录

## 注意事项

通过这样重建之后，未来的 Max 不再需要承担所有事务的状态派发负担。很多信息将转由 openspec 的 `_meta.yaml` 以及对应的 spec 文档自行记录，Max 逐渐向 "引导框架规范制订者" 和 "项目大盘总监控" 的方向转移。
