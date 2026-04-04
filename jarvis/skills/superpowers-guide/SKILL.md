---
name: superpowers-guide
description: 决策指南：何时以及如何选择 superpowers 技能库中的具体技能。当贾维斯面临复杂开发任务、需要调试根因、准备代码审查、进行分支管理、或不确定该用哪个 superpowers 子技能时，必须使用此指南做出决策，而不是凭感觉猜测。涵盖全部技能的触发场景、选择流程和常见组合工作流。
---

# Superpowers 技能选择指南

Superpowers 是一套专业技能库，通过 `/skill superpowers/<技能名>` 调用。
本文件帮助贾维斯在正确的时机选择正确的技能。

**技能库来源**：GitHub superpowers 仓库（使用前确认最新列表）

---

## 完整技能列表

### 🧪 Testing

**`test-driven-development`**
RED-GREEN-REFACTOR 循环，含测试反模式参考文档。

| 触发                      | 不触发                       |
| ------------------------- | ---------------------------- |
| 新功能开发前要求先写测试  | 已有代码补测试（直接写即可） |
| 修复 Bug 需要先写复现用例 | 快速验证性脚本               |
| 用户明确要求 TDD 流程     |                              |

---

### 🔍 Debugging

**`systematic-debugging`**
4 阶段根因分析，含根因追踪、纵深防御、条件等待技术。

| 触发                       | 不触发                    |
| -------------------------- | ------------------------- |
| Bug 原因不明，初步排查无果 | 明显语法错误              |
| 问题涉及多模块交互         | 简单逻辑 Bug 一眼看出原因 |
| 偶现、难以复现的问题       |                           |

**`verification-before-completion`**
确认修复真正生效，而非表面通过测试。

| 触发                           | 不触发                   |
| ------------------------------ | ------------------------ |
| 修复完成，声明"搞定"之前       | 新功能开发（非修复场景） |
| 凯尔验收不通过，本次再次修复后 |                          |

> ⚠️ 规则：每次修复后必须经过此技能验证，再通知凯尔审查。

---

### 🤝 Collaboration

**`brainstorming`**
苏格拉底式设计方案推敲，通过提问帮助明确需求和方案。

| 触发                 | 不触发               |
| -------------------- | -------------------- |
| 需求模糊，方向不清晰 | 需求已明确，直接执行 |
| 多个设计方案难以抉择 |                      |
| 用户说"你觉得怎么做" |                      |

---

**`writing-plans`**
输出详细实施计划，供用户确认后再执行。

| 触发                   | 不触发                         |
| ---------------------- | ------------------------------ |
| 复杂任务需要先对齐方案 | 简单任务（< 3 步，< 3 个文件） |
| 用户要求"先看方案再做" | 用户明说"直接做"               |
| 多人协作需要书面计划   |                                |

---

**`executing-plans`**
带检查点的批量执行，每阶段完成后暂停确认再继续。

| 触发                                            | 不触发                            |
| ----------------------------------------------- | --------------------------------- |
| 已有明确计划（来自 `writing-plans` 或用户提供） | 方案尚未确定 → 先 `writing-plans` |
| 多步骤任务需要阶段性确认                        | 单步简单任务                      |

---

**`dispatching-parallel-agents`**
并发子 Agent 工作流，多个独立子任务同时执行。

| 触发                           | 不触发                 |
| ------------------------------ | ---------------------- |
| 子任务相互独立，无执行顺序依赖 | 步骤间有强依赖必须串行 |
| 任务可拆分且分拆后能明显提速   | 子任务数量 < 3 个      |

---

**`requesting-code-review`**
提交审查前的自查清单，确保代码达到可审查质量。

| 触发                           | 不触发       |
| ------------------------------ | ------------ |
| 代码写完，准备通知凯尔审查之前 | 开发尚未完成 |
| 每次——无例外                   |              |

---

**`receiving-code-review`**
规范响应审查反馈的处理流程。

| 触发                             | 不触发           |
| -------------------------------- | ---------------- |
| 收到凯尔的审查报告，开始处理意见 | 尚未收到审查意见 |

---

**`using-git-worktrees`**
并行开发分支管理，同时维护多条分支而不互相干扰。

| 触发                       | 不触发               |
| -------------------------- | -------------------- |
| 需要同时维护多个功能分支   | 单线开发，无并行需求 |
| 主分支不能动但要开发新功能 |                      |

---

**`finishing-a-development-branch`**
功能完成后的合并/PR 决策工作流。

| 触发                          | 不触发       |
| ----------------------------- | ------------ |
| 功能开发完毕，准备合并或提 PR | 开发尚未完成 |

---

**`subagent-driven-development`**
快速迭代 + 二阶段审查（规范合规 → 代码质量）。

| 触发                           | 不触发                   |
| ------------------------------ | ------------------------ |
| 需要快速出结果的迭代型开发     | 简单改动，一次性完成即可 |
| 复杂功能需要分两个维度独立审查 |                          |

---

### 🧠 Meta

**`using-superpowers`**
技能系统入门介绍。不确定用哪个技能时，先调用此技能获取引导。

**`writing-skills`**
按最佳实践为团队创建新技能。

---

## 选择流程

```
收到任务
   │
   ├─ 需求模糊？
   │     └─→ brainstorming
   │
   ├─ 需求清晰但复杂，需先出方案？
   │     └─→ writing-plans
   │           └─ 用户确认后 →  executing-plans
   │                              └─ 子任务可并行？→ dispatching-parallel-agents
   │
   ├─ 已有明确方案，直接执行？
   │     ├─ 子任务可并行 →  dispatching-parallel-agents
   │     └─ 需串行执行   →  executing-plans
   │
   ├─ 新功能，要求高质量 / TDD？
   │     └─→ test-driven-development
   │
   ├─ 快速迭代但不降低质量？
   │     └─→ subagent-driven-development
   │
   ├─ Bug 排查，原因不明？
   │     └─→ systematic-debugging
   │           └─ 修复后 → verification-before-completion
   │
   ├─ Bug 已修复，确认真正好了？
   │     └─→ verification-before-completion
   │
   ├─ 代码写完，准备让凯尔审查？
   │     └─→ requesting-code-review（先自查）→ 通知凯尔
   │
   ├─ 收到凯尔的审查意见？
   │     └─→ receiving-code-review
   │
   ├─ 需要并行维护多条分支？
   │     └─→ using-git-worktrees
   │
   ├─ 功能完成，要合并 / 提 PR？
   │     └─→ finishing-a-development-branch
   │
   └─ 不确定用哪个？
         └─→ using-superpowers（入门引导）
```

---

## 常见组合工作流

### 新功能标准流程
```
brainstorming（需求澄清，按需）
  → writing-plans（输出方案）
  → [用户确认]
  → executing-plans（分步执行）
  → verification-before-completion（确认无误）
  → requesting-code-review（自查）
  → [通知凯尔]
  → receiving-code-review（处理意见）
  → finishing-a-development-branch（合并）
```

### TDD 流程
```
writing-plans（方案拆分）
  → test-driven-development（红绿重构循环）
  → verification-before-completion
  → requesting-code-review
```

### 复杂并行开发
```
writing-plans（拆分为独立子任务）
  → dispatching-parallel-agents（并行执行）
  → verification-before-completion
  → finishing-a-development-branch
```

### Bug 修复流程
```
systematic-debugging（定位根因）
  → writing-plans（修复方案，复杂时）
  → executing-plans（执行修复）
  → verification-before-completion（确认修复）
  → requesting-code-review
```