---
name: swarm-task-manager
description: Agent Swarm 协作规范 - 多Agent任务分配、层级控制、通知协议
---
# 🤖 Agent Swarm 任务管理规范

**技能名称**: `swarm-task-manager`  
**版本**: 1.0  
**适用范围**: aiGroup 所有成员 (Max/Ella/Jarvis/Kyle)

---

## 📋 核心原则

### 1. 层级控制（硬性限制）

```
最大递归深度: 2层 (即最多3个实体参与一条链)

✅ 允许的链:
Layer 0: 用户
Layer 1: Max (协调者) → spawn →
Layer 2: Ella/Jarvis/Kyle (执行者) → spawn →
Layer 3: 子任务代理 (终点，禁止再spawn)

❌ 禁止的链:
Max → Jarvis → Kyle → 其他人 (超过3层)
Kyle → Jarvis (反向，除非Max介入)
```

### 2. 循环控制（Bug修复场景）

```
同一任务最多3轮往返

第1轮: 发现问题 → 修复 → 验证
第2轮: 详细说明 → 修复 → 验证
第3轮: 最终尝试 → 修复 → 验证
第4轮+: 🚨 Max必须介入，中止spawn，汇报用户
```

### 3. 权限矩阵

| 角色 | 可以 Spawn | 禁止 Spawn | 特殊权限 |
|------|-----------|-----------|---------|
| **Max** | 任何人 (Ella/Jarvis/Kyle) | 无 | 可随时介入任何任务 |
| **Ella** | ❌ 禁止 | Jarvis, Kyle, Max, 自己 | 专注设计，问题通知 Max |
| **Jarvis** | ❌ 禁止 | Ella, Kyle, Max, 自己 | 专注开发，Bug由Kyle spawn修复 |
| **Kyle** | Jarvis (Bug修复) | Ella, Max, 自己 | 可主动 spawn Jarvis 修复Bug |

**特别说明**: Kyle 可以直接 spawn Jarvis 进行 Bug 修复，加快循环速度。但 Jarvis 修复前必须检查轮次，超过3轮必须拒绝并通知 Max 介入。

---

## 🔄 标准任务流程

### 流程1: 新产品设计开发

```
[启动] 用户提出需求
    ↓
[Layer 1] Max 分析需求
    ├─ 需要设计 → spawn Ella
    └─ 纯技术 → spawn Jarvis
    ↓
[Layer 2 - 并行] 
    ├─ Ella: UI/UX设计
    └─ Jarvis: 技术可行性评估
    ↓
[汇总] Max 整合设计方案
    ↓
[Layer 2] spawn Jarvis 开发
    ↓
[Layer 2] spawn Kyle 测试
    ↓
[判断]
    ├─ 通过 → [完成] 汇报用户
    └─ Bug → [进入 Bug修复循环]
```

### 流程2: Bug修复循环（受控）

**新流程**: Kyle 可以直接 spawn Jarvis 修复 Bug，提高效率

```
[发现] Kyle 发现 Bug
    ↓
[记录] Kyle 写入 shared/bugs/bug-{id}.md
    - 问题描述
    - 复现步骤
    - 期望/实际结果
    - 严重程度
    - 截图/日志
    ↓
[记录] Kyle 更新任务状态文件 (第N轮)
    ↓
[Spawn - Layer 2] Kyle spawn Jarvis (Bug修复专用)
    - 传递完整的 Bug 信息
    - Jarvis 位于 Layer 3
    ↓
[修复 - Layer 3] Jarvis 修复
    - 检查当前轮次
    - IF 轮次 > 3 → 🚨 拒绝修复，通知 Max 介入
    - 修改内容
    - 修改原因
    - 自测结果
    - 更新 bug 状态
    ↓
[验证 - Layer 2] Kyle 验证
    ↓
[判断]
    ├─ 通过 → 关闭 Bug，通知 Max
    ├─ 未通过(第1-2轮) → 累计信息，Kyle继续spawn Jarvis修复
    └─ 未通过(第3轮) → Kyle尝试spawn Jarvis
        ↓
    [Jarvis检查]
        └─ 发现是第4轮 → 🚨 拒绝修复，通知 Max 介入
            ↓
        [Max介入]
            ├─ 分析根因
            ├─ 判断：需求问题/设计问题/实现问题/测试误解
            ├─ 汇报用户，等待决策
            └─ 用户决策后重新规划
```

**关键变化**:
- Kyle 可以直接 spawn Jarvis，无需等待 Max 协调
- Jarvis 修复前必须检查轮次，超过3轮自动触发 Max 介入
- 保持3轮限制，防止无限循环

---

## 🛡️ 强制检查点（每个Spawn前必须执行）

### Spawn前7检查点

```
✅ 检查点1: 当前层级检查
   - 我当前在Layer几？
   - 再spawn会超过Layer 3吗？
   - IF 会超过 → 拒绝spawn，通知Max

✅ 检查点2: 权限检查
   - 我的角色允许spawn目标角色吗？
   - 查看 spawn-permissions.yaml
   - IF 不允许 → 拒绝spawn，通知Max

✅ 检查点3: 循环轮次检查（Bug修复场景）
   - 这是第几轮修复？
   - IF 第4轮+ → 拒绝spawn，通知Max介入

✅ 检查点4: 上下文完整性检查
   - 我给子代理的信息足够吗？
   - 包含：任务目标、背景信息、完成标准、约束条件

✅ 检查点5: Token预估检查
   - 预估这次spawn需要多少token？
   - IF >5000 → 考虑进一步分解

✅ 检查点6: 状态记录检查
   - 是否已创建/更新任务状态文件？
   - 路径：shared/tasks/current/{task-id}.md

✅ 检查点7: 退出条件检查
   - 子代理完成后如何通知我？
   - 什么情况下应该停止spawn？
```

---

## 📝 状态跟踪规范

### 任务状态文件模板

每个进行中的任务必须在 `shared/tasks/current/{task-id}.md` 维护：

```markdown
# Task: {task-id}

## 基本信息
- **任务名称**: 
- **发起者**: (用户/Max/Ella/Jarvis/Kyle)
- **当前负责人**: 
- **创建时间**: 
- **最后更新**: 

## 任务层级
- **当前层级**: Layer 1/2/3
- **父任务**: (如有)
- **子任务**: (如有)

## 进度状态
- [ ] 需求分析
- [ ] 设计阶段
- [ ] 开发阶段
- [ ] 测试阶段
- [ ] 完成交付

## Bug修复循环（如适用）
| 轮次 | 发现者 | 修复者 | 状态 | 备注 |
|------|--------|--------|------|------|
| 1 | Kyle | Jarvis | ✅通过/❌未通过 | |
| 2 | Kyle | Jarvis | ✅通过/❌未通过 | |
| 3 | Kyle | Jarvis | ✅通过/❌未通过/🚨Max介入 | |

## 上下文记录
### 第1轮
- 问题：
- 修复：
- 结果：

### 第2轮
- 问题：
- 修复：
- 结果：

### 第3轮
- 问题：
- 修复：
- 结果：

## 阻塞点
- [ ] 问题描述 → 处理人

## 下一步行动
- 
```

---

## 🚨 Max介入触发条件

以下情况必须停止spawn，通知Max介入：

### 自动触发
1. **层级超限**: 尝试spawn会导致Layer > 3
2. **权限违规**: 当前角色不允许spawn目标角色
3. **循环超限**: Bug修复达到第4轮
4. **成本告警**: 单任务累计token > 10,000
5. **上下文丢失**: 无法确定原始需求

### 人工触发
1. **需求变更**: 原始需求发生变化
2. **范围蔓延**: 任务范围不断扩大
3. **方向分歧**: 团队成员对方案有分歧
4. **外部依赖**: 需要外部资源/信息
5. **用户明确要求**: 用户说"让Max看看"

---

## 📁 共享区使用规范

### 目录结构

```
shared/
├── tasks/
│   ├── current/          # 进行中任务
│   │   └── task-{id}.md
│   ├── completed/        # 已完成任务
│   └── archived/         # 已归档任务
├── bugs/                 # Bug跟踪
│   └── bug-{id}.md
├── status.json           # 实时状态&通知
├── docs/                 # PRD/设计文档
└── reviews/              # 审查报告
```

### 状态更新协议

#### Spawn 任务通知流程

**1. Spawn 发起时（父Agent → 子Agent）**

父 Agent Spawn 子 Agent 时，必须添加通知记录：

```json
{
  "notifications": [
    {
      "id": "spawn-{timestamp}-{random}",
      "type": "spawn_assigned",
      "from": "max",           // 发起者
      "to": "jarvis",          // 被Spawn者
      "task_id": "task-001",
      "parent_task_id": null,  // 如有父任务
      "layer": 2,              // 被Spawn者所在层级
      "status": "assigned",    // assigned / completed / failed
      "message": "开发登录页面功能",
      "context_file": "shared/tasks/current/task-001.md",
      "timestamp": "2026-03-02T20:00:00Z",
      "read": false
    }
  ]
}
```

**2. Spawn 完成时（子Agent → 父Agent）**

子 Agent 完成任务后，必须更新通知状态：

```json
{
  "notifications": [
    {
      "id": "spawn-{timestamp}-{random}",
      "type": "spawn_completed",
      "from": "jarvis",        // 完成者
      "to": "max",             // 原发起者
      "task_id": "task-001",
      "parent_task_id": null,
      "layer": 2,
      "status": "completed",   // assigned → completed
      "message": "登录页面开发完成，已通过自测",
      "deliverables": [
        "shared/designs/login-page.html",
        "shared/docs/login-spec.md"
      ],
      "token_consumed": 2500,
      "timestamp": "2026-03-02T21:30:00Z",
      "read": false
    }
  ]
}
```

**3. Bug修复 Spawn 特殊通知**

Kyle Spawn Jarvis 修复 Bug 时：

```json
{
  "notifications": [
    {
      "id": "spawn-{timestamp}-{random}",
      "type": "bug_fix_assigned",
      "from": "kyle",
      "to": "jarvis",
      "task_id": "task-001",
      "bug_id": "bug-003",
      "round": 2,              // 第几轮修复
      "layer": 3,
      "status": "assigned",
      "message": "修复登录按钮无效问题（第2轮）",
      "timestamp": "2026-03-02T20:00:00Z",
      "read": false
    }
  ]
}
```

修复完成后：

```json
{
  "notifications": [
    {
      "id": "spawn-{timestamp}-{random}",
      "type": "bug_fix_completed",
      "from": "jarvis",
      "to": "kyle",
      "task_id": "task-001",
      "bug_id": "bug-003",
      "round": 2,
      "layer": 3,
      "status": "completed",
      "message": "已修复，修改了事件绑定逻辑",
      "fix_summary": "修复内容摘要...",
      "timestamp": "2026-03-02T20:30:00Z",
      "read": false
    }
  ]
}
```

#### 标准状态更新流程

**任何agent完成工作后必须**：
1. **更新任务状态文件** - `shared/tasks/current/task-{id}.md`
2. **添加完成通知** - `shared/status.json` 添加 `spawn_completed` 通知
3. **标记原通知为已读** - 将对应的 `spawn_assigned` 通知标记为 `read: true`
4. **如有阻塞** - 添加 `blocked` 通知，立即通知Max

#### 完整 status.json 示例

```json
{
  "last_updated": "2026-03-02T21:30:00Z",
  "agents": {
    "max": { 
      "status": "working", 
      "current_task": "task-001",
      "spawned_to": ["jarvis", "ella"] 
    },
    "ella": { 
      "status": "completed", 
      "current_task": null,
      "last_completed": "task-001-design"
    },
    "jarvis": { 
      "status": "completed", 
      "current_task": null,
      "last_completed": "task-001-dev"
    },
    "kyle": { 
      "status": "blocked", 
      "current_task": "task-001",
      "block_reason": "waiting-fix-round-3",
      "spawned_to": ["jarvis"]
    }
  },
  "notifications": [
    {
      "id": "spawn-001",
      "type": "spawn_assigned",
      "from": "max",
      "to": "ella",
      "task_id": "task-001",
      "layer": 2,
      "status": "completed",
      "message": "设计登录页面",
      "timestamp": "2026-03-02T20:00:00Z",
      "read": true
    },
    {
      "id": "spawn-001-complete",
      "type": "spawn_completed",
      "from": "ella",
      "to": "max",
      "task_id": "task-001",
      "layer": 2,
      "status": "completed",
      "message": "登录页面设计完成",
      "deliverables": ["shared/designs/login-design.md"],
      "timestamp": "2026-03-02T20:30:00Z",
      "read": true
    },
    {
      "id": "spawn-002",
      "type": "spawn_assigned",
      "from": "max",
      "to": "jarvis",
      "task_id": "task-001",
      "layer": 2,
      "status": "completed",
      "message": "开发登录页面",
      "timestamp": "2026-03-02T20:35:00Z",
      "read": true
    },
    {
      "id": "spawn-002-complete",
      "type": "spawn_completed",
      "from": "jarvis",
      "to": "max",
      "task_id": "task-001",
      "layer": 2,
      "status": "completed",
      "message": "登录页面开发完成",
      "deliverables": ["shared/code/login.html"],
      "timestamp": "2026-03-02T21:00:00Z",
      "read": true
    },
    {
      "id": "spawn-003",
      "type": "bug_fix_assigned",
      "from": "kyle",
      "to": "jarvis",
      "task_id": "task-001",
      "bug_id": "bug-001",
      "round": 3,
      "layer": 3,
      "status": "completed",
      "message": "修复登录按钮问题（第3轮）",
      "timestamp": "2026-03-02T21:10:00Z",
      "read": true
    },
    {
      "id": "spawn-003-complete",
      "type": "bug_fix_completed",
      "from": "jarvis",
      "to": "kyle",
      "task_id": "task-001",
      "bug_id": "bug-001",
      "round": 3,
      "layer": 3,
      "status": "completed",
      "message": "已修复，但仍有问题",
      "timestamp": "2026-03-02T21:25:00Z",
      "read": false
    },
    {
      "id": "spawn-004",
      "type": "bug_fix_rejected",
      "from": "jarvis",
      "to": "max",
      "task_id": "task-001",
      "bug_id": "bug-001",
      "round": 4,
      "layer": 3,
      "status": "blocked",
      "message": "已达3轮修复上限，需要介入",
      "timestamp": "2026-03-02T21:30:00Z",
      "read": false
    }
  ]
}
```

---

## 🎓 最佳实践

### Do's ✅
- 并行spawn：多个独立任务同时发起
- 批量处理：一个spawn处理多个小任务
- 详细首次：第一轮就给足信息
- 及时通知：完成后立即更新状态
- 累积上下文：每轮保留历史信息

### Don'ts ❌
- 串行等待：一个完成再spawn下一个
- 碎片spawn：每个小操作都spawn
- 模糊描述："做个东西"式的任务
- 静默失败：不报告直接放弃
- 重复spawn：同一任务反复spawn无进展

---

## 🔧 工具集成

### 在 CLAUDE.md 中引用

各agent的CLAUDE.md应添加：

```markdown
## Agent Swarm 任务管理

**必须遵循**: `../shared/skills/swarm-task-manager/SKILL.md`

### 我的Spawn权限
- 可以spawn: [根据角色填写]
- 禁止spawn: [根据角色填写]
- 最大层级: Layer 2 (我) → Layer 3 (子代理)

### 执行流程
1. 任务分解判断 → 是否需要spawn？
2. 权限检查 → 我可以spawn谁？
3. 层级检查 → 会超过Layer 3吗？
4. 创建状态文件 → shared/tasks/current/{task-id}.md
5. 执行spawn → 使用Task工具
6. 等待结果 → 子代理完成后通知我
7. 更新状态 → 写入shared/status.json
8. 循环检查 → 是否需要下一轮？是否超过3轮？
```

---

## 📊 监控指标

Max应定期监控：

| 指标 | 健康值 | 告警值 |
|------|--------|--------|
| 平均任务spawn数 | 3-5次 | >8次 |
| Bug修复平均轮次 | 1.5轮 | >2.5轮 |
| Layer 3触发次数 | <10% | >30% |
| Max介入率 | <5% | >15% |
| 平均任务耗时 | <30分钟 | >2小时 |

---

**最后更新**: 2026-03-02  
**维护者**: aiGroup Team
