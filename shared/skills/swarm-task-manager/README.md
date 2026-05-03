# 🤖 Agent Swarm 任务管理

aiGroup 的 Agent 协作总纲，定义了多 Agent 如何高效协作完成复杂任务。

---

## 📖 文档导航

| 文档 | 说明 | 必读 |
|------|------|------|
| `SKILL.md` | 核心规范：层级控制、权限矩阵、检查点 | ⭐⭐⭐ |
| `HOW_TO_USE.md` | 使用指南：场景示例、代码模板 | ⭐⭐⭐ |
| `spawn-permissions.yaml` | 权限矩阵：谁可以 Spawn 谁 | ⭐⭐ |
| `task-lifecycle.md` | 生命周期：任务从创建到完成 | ⭐⭐ |
| `max-intervention.md` | 介入指南：何时 Max 介入如何处理 | ⭐⭐ |
| `state-templates/` | 状态模板：任务跟踪文件模板 | ⭐ |

---

## 🎯 核心设计

### 三层架构

```
Layer 0: 用户（提出需求）
    ↓
Layer 1: Max（唯一协调者，可以 Spawn 任何人）
    ↓
Layer 2: Ella/Jarvis/Kyle（执行者，有限 Spawn 权限）
    ↓
Layer 3: 子任务（终点，禁止再 Spawn）
```

### 三轮限制

```
Bug 修复最多 3 轮，第 4 轮强制 Max 介入

第1轮: 发现 → 修复 → 验证
第2轮: 详细说明 → 修复 → 验证
第3轮: 最终尝试 → 修复 → 验证
第4轮: 🚨 Max介入，汇报用户
```

### 权限控制

```
Max: 可以 Spawn 任何人（Ella/Jarvis/Kyle）
Ella: 只能 Spawn Jarvis（技术评估）
Jarvis: 只能 Spawn Kyle（代码审查）
Kyle: 禁止 Spawn 任何人（发现问题通知 Max）
```

---

## 🚀 快速开始

### 1. 每个 Agent 配置 CLAUDE.md

在各 Agent 的 `CLAUDE.md` 中添加：

```markdown
## Agent Swarm 协作规范

必须遵循: `../shared/skills/swarm-task-manager/SKILL.md`

### 我的权限
- 角色: [max/ella/jarvis/kyle]
- 层级: Layer [1/2]
- 可以 Spawn: [根据权限]
- 禁止 Spawn: [根据权限]
```

### 2. 创建任务时

```bash
# 复制模板
cp shared/skills/swarm-task-manager/state-templates/task-template.md \
   shared/tasks/current/task-001.md

# 填写并跟踪
vim shared/tasks/current/task-001.md
```

### 3. 协作流程

```
用户提出需求
    ↓
Max 创建任务，分析是否需要 Spawn
    ↓
Max Spawn 子 Agent（并行或串行）
    ↓
子 Agent 执行（可能再 Spawn 一次到 Layer 3）
    ↓
子 Agent 更新状态，通知 Max
    ↓
Max 验收或协调 Bug 修复循环（最多3轮）
    ↓
完成，汇报用户
```

---

## 📁 目录结构

```
swarm-task-manager/
├── README.md                    # 本文件
├── SKILL.md                     # 核心规范
├── HOW_TO_USE.md               # 使用指南
├── spawn-permissions.yaml      # 权限矩阵
├── task-lifecycle.md           # 任务生命周期
├── max-intervention.md         # Max 介入指南
└── state-templates/            # 状态模板
    └── task-template.md        # 任务跟踪模板
```

---

## 🔑 关键概念

| 概念 | 说明 |
|------|------|
| **Spawn** | 使用 Task 工具创建子 Agent 执行任务 |
| **Layer** | 任务层级，最大 Layer 3 |
| **Loop** | Bug 修复循环，最大 3 轮 |
| **Intervention** | Max 介入处理异常情况 |
| **Shared** | 共享工作区，所有 Agent 都能访问 |

---

## 🛡️ 防护机制

### 硬性限制（自动执行）

1. **层级限制**: 不能超过 Layer 3
2. **权限限制**: 角色只能 Spawn 允许的目标
3. **循环限制**: Bug 修复最多 3 轮
4. **成本限制**: Token 超过阈值 Max 介入

### 软性判断（Max 决策）

1. **需求变更**: 需求发生变化
2. **方向分歧**: Agent 之间有分歧
3. **质量异常**: Bug 率过高
4. **用户要求**: 用户明确要求 Max 介入

---

## 📊 监控指标

| 指标 | 说明 | 健康值 |
|------|------|--------|
| 平均 Spawn 数 | 每任务平均 Spawn 次数 | 3-5 次 |
| Bug 修复轮次 | 平均每 Bug 修复轮次 | 1.5 轮 |
| Max 介入率 | 介入任务/总任务 | <10% |
| 任务中止率 | 中止任务/总任务 | <5% |

---

## 🎓 最佳实践

1. **并行 Spawn**: 多个独立任务同时发起
2. **详细首次**: 第一轮就给足信息
3. **及时更新**: 完成后立即更新状态
4. **累积上下文**: 每轮保留历史信息
5. **适时介入**: 小问题自己解决，大问题找 Max

---

## ❓ 常见问题

**Q: Kyle 发现 Bug 能直接找 Jarvis 吗？**  
A: 不能。Kyle 禁止 Spawn，必须通知 Max，由 Max 协调。

**Q: Ella 设计时遇到技术问题怎么办？**  
A: Ella 可以 Spawn Jarvis 做技术评估（Layer 2→3），Jarvis 评估后返回 Ella。

**Q: Bug 修3轮还没好怎么办？**  
A: 第4轮强制 Max 介入，分析根因，汇报用户决策。

**Q: Max 可以同时 Spawn 多个人吗？**  
A: 可以。比如同时 Spawn Ella 设计和 Jarvis 技术评估（并行）。

**Q: 子 Agent 完成工作后怎么通知父级？**  
A: 更新 `shared/status.json` 和任务状态文件。

---

## 🔄 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 1.0 | 2026-03-02 | 初始版本，定义完整 Agent Swarm 规范 |

---

## 🤝 贡献

如需改进本 Skill：
1. 在 `shared/skills/swarm-task-manager/` 修改
2. 更新版本历史
3. 通知所有 Agent 更新 CLAUDE.md 引用

---

**维护者**: aiGroup Team  
**最后更新**: 2026-03-02
