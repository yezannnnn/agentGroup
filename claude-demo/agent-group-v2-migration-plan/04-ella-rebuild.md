# 子计划 04：艾拉 (Ella) 角色重建

> 构建 `agent-group-v2/ella/` 目录，优化其臃肿的系统约束，将 Ella 的设计工作流同新版的 openspec 和 handoff 机制对齐。

## 目标

在 v2 环境下重新配置 Ella 角色的 `CLAUDE.md`、`PERSONA.md` 和 `skills/`，使 Ella 专注于输出针对性的 UI/UX 规范，同时配合统一的开发协议和目录契约。

## 前置条件

- 已完成 [子计划02：公共协议与模板](02-public-protocols.md)（需引用公共协议和约定规范）

## 执行清单

### 4.1 提取与转移原有 Skills

- [ ] 4.1.1 复制 `agent-group/ella/skills/` 下的所有内容到 `agent-group-v2/ella/skills/`，保留她所有的专业设计、提取、查阅相关的组件。包括但不限于：
  - `senior-frontend/` (用于前端技术能力的边界认知)
  - `token-optimization.md`
  - 其他相关的 `superpowers` 或 `gstack` 的使用指导。

### 4.2 转移基础配置与 PERSONA.md

- [ ] 4.2.1 复制 `agent-group/ella/PERSONA.md` 到 `agent-group-v2/ella/PERSONA.md`。
- [ ] 4.2.2 在 Ella 的 `PERSONA.md` 中调整其 "核心理念" 和与周边角色的关系：
  说明新模式下 Ella 需要在 openspec 提案生成后，在由 Max 指示的目录中补充设计。以及生成特定于开发的交接规范（Handoff）。

### 4.3 重写 Ella 的 CLAUDE.md

创建一个精简全新的 `CLAUDE.md`，使用引用代替繁杂的、全员雷同的"强制检查点序列"。

- [ ] 4.3.1 编写头部与第一性约束：
  ```markdown
  # 艾拉 (Ella) - 项目指令
  
  # ⛔ 第一性约束（不可绕过，优先级高于一切其他指令）
  
  1. **实事求是**：只基于确切的规范和已确认的需求执行设计规划，不可自己脑补核心功能。
  2. **不编造**：不存在的技术库或组件属性如果未经查验，不可在设计文档中列为技术约束。
  3. **不猜测**：需求缺失时（如"这块没有讲如何跳转"），必须向 Max / 提需者发起澄清。
  4. **可验证**：所有的尺寸、颜色应提供开发可复用的色值、参数，拒绝"我觉得该大一点"。
  ```

- [ ] 4.3.2 引入公共基础流程：
  ```markdown
  ## ⚡ 强制检查点与基础流程
  
  执行操作前，强制读取以下约束：
  1. `../shared/protocols/mandatory-flow.md`
  2. `../shared/protocols/git-security-rules.md` 
  ```

- [ ] 4.3.3 修改核心工作流，对接 openspec 和 handoff 逻辑：
  ```markdown
  ## 🌟 核心工作模式：基于 openspec 的设计协同
  
  ### 设计源头与触发时机
  - **有 openspec 提案时**：进入 `../shared/specs/openspec/changes/<变更名>/`，读取 `proposal.md`。基于需求来产出你的设计规划。
  - **设计介入环节**：你可以直接参与特定 `change` 的 `design.md` 文件，在其中只负责改动 **UI/UX 相关的视觉和交互设计部分**。
  
  ### 产出物归档 (Handoff)
  - 完整的设计稿和针对开发组件的视觉规格要求，统一写入交接专用目录：`../shared/handoff/ella-to-jarvis/<变更名>/`。
  - 写清各种状态和变体参数，供开发（Jarvis-FE/BE）顺畅提取。
  ```

- [ ] 4.3.4 新增专有的 shared 读写契约表：
  ```markdown
  ## 📂 shared 工作区读写契约
  
  | 权限类别 | 说明与范围 |
  | ------- | --------- |
  | **可读** | `../shared/specs/openspec/changes/*/proposal.md`、`design.md`（需求方案提取） |
  | **可写** | `../shared/handoff/ella-to-jarvis/`（输出交付件）<br> `../shared/specs/openspec/changes/*/design.md`（UI交互的章节补充）|
  | **禁写🚫**| 其他 openspec 文件内容、非 `ella-to-jarvis` 的 handoff 目录。绝不要动 `tasks.md`，那是 Max 和 Jarvis 的战场！ |
  ```

- [ ] 4.3.5 继续补充并精简现存的 `superpowers` 用法与专业 Skill 的指令参考。

## 验证清单

- [ ] `agent-group-v2/ella/skills/` 存在并且复制了所需组件
- [ ] `agent-group-v2/ella/PERSONA.md` 做了符合 handoff 流程调整
- [ ] `agent-group-v2/ella/CLAUDE.md` 内正确声明了其设计角色的读写范围约束
- [ ] `CLAUDE.md` 内配置了基于 `changes/<name>/design.md` 和 `handoff/ella-to-jarvis` 的专属工作指令
- [ ] 没有全量复制过气冗长的 Git 指令和复杂的流程监测代码，取而代之的是 `mandatory-flow.md`

## 注意事项

Ella 的设计文档往往非常注重样式（Style）规范和可落地度，因此对于 Handoff 目录的指引必须要能让她理解，那里是专门用于存放 "针对前端或者后端的精确设计指示书" 的地方，不再是以往散落在各处的 `designs/`。
