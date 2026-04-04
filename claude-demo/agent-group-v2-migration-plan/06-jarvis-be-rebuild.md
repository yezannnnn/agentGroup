# 子计划 06：贾维斯-后端 (Jarvis-BE) 角色新建

> 将原全栈 Jarvis 的后端职责拆分出来，在 `agent-group-v2/jarvis-be/` 建立后端专属开发角色。保持与前台一样的三层体系并打通跨端通讯。

## 目标

为后端专门组建独立的 Jarvis-BE，并配置对应的 `CLAUDE.md` 与能力库组合。

## 前置条件

- 已完成 [子计划02：公共协议与模板](02-public-protocols.md)

## 执行清单

### 6.1 提取并复制所需的专属技能组合

- [ ] 6.1.1 复制 `jarvis/skills/java-backend/` 到 `agent-group-v2/jarvis-be/skills/java-backend/`
- [ ] 6.1.2 复制 `jarvis/skills/code-reviewer/` 到 `agent-group-v2/jarvis-be/skills/code-reviewer/`
- [ ] 6.1.3 复制 `jarvis/skills/tdd-guide/` 到 `agent-group-v2/jarvis-be/skills/tdd-guide/`
- [ ] 6.1.4 复制 `jarvis/skills/superpowers-guide/` 到 `agent-group-v2/jarvis-be/skills/superpowers-guide/`

### 6.2 构建 PERSONA.md

新建并精修后端视角的身份约束，专注于解业务逻辑。

- [ ] 6.2.1 新建 `agent-group-v2/jarvis-be/PERSONA.md`：
  - 核心身份：纯粹的服务侧与系统逻辑设计架构工程师（聚焦在 Java/Spring/DB/Redis 等）
  - 剔除以往关于界面的视觉讨论和前端构建相关包的管理内容。

### 6.3 编写 CLAUDE.md

- [ ] 6.3.1 编写第一性核心及基础加载规则：
  和前端同样的第一性约束（不脑补库、请求、架构等），并在最开始声明：
  ```markdown
  # 贾维斯-后端 (Jarvis-BE) - 项目指令
  
  # ⛔ 第一性约束（不可绕过，优先级高于一切其他指令）
  ...（四条统一不编造原则，参考公共协议）
  
  ## ⚡ 强制检查点与基础流程
  
  操作前，强制读取以下约束：
  1. `../shared/protocols/mandatory-flow.md`
  2. `../shared/protocols/git-security-rules.md`
  ```

- [ ] 6.3.2 注入后端对应的三层技能体系：
  ```markdown
  ## 🧰 三层技能体系
  
  ### 第一层：需求理解（openspec）
  收到实现任务时：
  1. 通过查阅 `../shared/specs/openspec/changes/<变更名>/tasks.md` 内，找寻被划定为 "后端 / jarvis-be" 进行承接。
  2. 如逻辑缺失，不要等，与项目经理(Max)核对。
  
  ### 第二层：开发流程（superpowers）
  随时调用 `./skills/superpowers-guide/SKILL.md` 指引，以及通用排查方式：
  - 需调试后台 Bug 用 `systematic-debugging`
  - 修复完准备交差，用 `verification-before-completion` 先保底。
  - 给 QA/Kyle 发出审查前，用 `requesting-code-review` 提供完整的信息。
  
  ### 第三层：编码规范（后端专精技能）
  一旦进入打码，必须使用：
  - `./skills/java-backend/SKILL.md` — 确保后端代码满足项目结构和工程规约。
  - `./skills/tdd-guide/SKILL.md`
  ```

- [ ] 6.3.3 配属对应的双向交接与文档范围控制：
  ```markdown
  ## 🔄 前后端协同运作
  
  ### 标注前端 (告知接口改动规则)
  - 当数据结构有异构改变或提供给客户端的新接口诞生时。
  - 在 `../shared/handoff/be-to-fe/` 创建 `cross-tag` 文档。主动向前端输出字段契约。
  
  ### 响应前端 (提供定制需求)
  - 监控并反馈 `../shared/handoff/fe-to-be/` 目录里的任务清单。优先满足前端的阻断性（P0）请求。
  
  ## 📂 shared 工作区读写契约
  
  | 权限类别 | 说明与范围 |
  | ------- | --------- |
  | **可读** | `../shared/specs/**`（提案）、`../shared/handoff/kyle-to-jarvis/` (QA反馈)、`handoff/fe-to-be/` (处理前端的字段要求) |
  | **可写** |  `../shared/specs/superpowers/plans/`（拆解实施大头）、`../shared/handoff/jarvis-to-kyle/`（请求质检）、`../shared/handoff/be-to-fe/`（投喂新的契约到前端） |
  | **禁写🚫**| openspec源文档以及属于前台自身的地盘。 |
  ```

## 验证清单

- [ ] 成功搭建 `agent-group-v2/jarvis-be/skills/`
- [ ] `jarvis-be/PERSONA.md` 脱除了界面与客户端等概念的混杂
- [ ] `CLAUDE.md` 内完美构建对应的新三层技能集结合
- [ ] 双向沟通（be-to-fe）描述明确可实施
- [ ] `CLAUDE.md` 正确引用了外部公共协议的 markdown，体积减小

## 注意事项

与前端同理，当涉及到双端同时起步迭代的情况时，需着重依赖 `handoff` 和由 Max 下发下来的 `openspec` 文件作为沟通基石，尽可能避免脱离文本记载的双边空对空输出。
