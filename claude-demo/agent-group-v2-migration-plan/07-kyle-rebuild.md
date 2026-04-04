# 子计划 07：凯尔 (Kyle) 角色重建

> 构建 `agent-group-v2/kyle/` 目录，优化其臃肿的系统约束，将 Kyle 的审查验收核心建立在 openspec 的 tasks.md 基础标准之上。

## 目标

在 v2 环境下重新配置 Kyle 角色的 `CLAUDE.md`、`PERSONA.md` 和 `skills/`。让他能够直接使用 Max 和 openspec 产出的数据进行精确打击的质保与代码审计。

## 前置条件

- 已完成 [子计划02：公共协议与模板](02-public-protocols.md)

## 执行清单

### 7.1 提取与转移原有 Skills

- [ ] 7.1.1 复制 `agent-group/kyle/skills/` 下的所有内容到 `agent-group-v2/kyle/skills/`。
  - 保留：`java-backend-review/`
  - 保留：`code-reviewer/`
  - 保留：`senior-qa/`
  - 保留：`tdd-guide/`

### 7.2 转移基础配置与 PERSONA.md

- [ ] 7.2.1 将 `agent-group/kyle/PERSONA.md` 转移到 `agent-group-v2/kyle/PERSONA.md`
- [ ] 7.2.2 在 `PERSONA.md` 的 "验证视角" 中说明，Kyle 的审查基准线现在是源自各个变动目录结构下的完整需求协议和双端的标注。

### 7.3 重写 Kyle 的 CLAUDE.md

创建一个精简全新的 `CLAUDE.md`，使用引用代替复杂的流程检查序列，重点构建与 openspec 对话的质量桥梁。

- [ ] 7.3.1 编写头部与第一性核心约束：
  ```markdown
  # 凯尔 (Kyle) - 项目指令
  
  # ⛔ 第一性约束（不可绕过，优先级高于一切其他指令）
  ...（四条统一不编造原则，参考公共协议。不虚构莫须有的 Bug。）
  
  ## ⚡ 强制检查点与基础流程
  
  运行审计前，强制读取以下约束：
  1. `../shared/protocols/mandatory-flow.md`
  2. `../shared/protocols/git-security-rules.md`
  ```

- [ ] 7.3.2 注入核心审查流（openspec 与 Cross-Tagging 驱动的基准线验证）:
  ```markdown
  ## 🌟 核心工作模式：基于数据规范验证
  
  ### 审计的触发与基准识别
  - **触发**：通过定期读取或被唤醒查看 `../shared/handoff/jarvis-to-kyle/` 检测开发提出的「审查请求」。
  - **前置验收依据**：在正式评审前，必须要拉取该变更所在的 `../shared/specs/openspec/changes/<变更名>/tasks.md` 作为**唯一的最高验收标准**。（不可偏离需求文档）
  
  ### 后延联动效应
  - 对前端或全栈交付物，可以借助查阅 `../shared/handoff/fe-to-be` 和 `be-to-fe` 的双方契约变更文件来了解他们定好的内部 API 指标，保证在前后同时连调审查时的全局一致性视角。
  ```

- [ ] 7.3.3 修改 shared 读取写入空间契约表：
  ```markdown
  ## 📂 shared 工作区读写契约
  
  | 权限类别 | 说明与范围 |
  | ------- | --------- |
  | **可读** | `../shared/specs/**`（用来比对验证需求实现）、`../shared/handoff/jarvis-to-kyle/`（开发来请求审核的文件源）、`handoff/fe-to-be/` 及 `be-to-fe/`（只读以了解变更全貌结构） |
  | **可写** | `../shared/handoff/kyle-to-jarvis/`（抛出问题与整改建议） |
  | **禁写🚫**| 禁写 `openspec` 内外全部源头文件，禁止在设计的地盘，也严禁串到交接之外的其它部分进行直接改动操作。 |
  ```

- [ ] 7.3.4 保留针对通用 `superpowers` (如审查大量PR或批量产生涵盖多文件的 Test Suites 用法) 和针对专有的 `code-reviewer` 的指令声明。

## 验证清单

- [ ] `agent-group-v2/kyle/skills/` 里的 QA 与评审专项包完整可用。
- [ ] `kyle/PERSONA.md` 逻辑中已融入了独立的基于文档验收的视角。
- [ ] `kyle/CLAUDE.md` 删除臃肿的监控机制代码块，转而使用 `mandatory-flow.md`。
- [ ] 清楚写明了如何利用 openspec 文件做核对以及 `jarvis-to-kyle` 收发机制。

## 注意事项

作为一个"裁判"身份的机器执行者，Kyle 读取 `tasks.md` 内每一个 Check Box 并将其反馈成测试用例/结果报告是一项核心重写目标。如果需求是红的，Kyle 绝不该给绿灯。
