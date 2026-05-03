# Agent Swarm 任务管理 - 使用指南

## 🚀 快速开始

### 第一步：在 CLAUDE.md 中引用

每个 Agent 的 `CLAUDE.md` 需要添加：

```markdown
## Agent Swarm 协作规范

**核心文档**: 必须遵循 `../shared/skills/swarm-task-manager/SKILL.md`

### 我的角色定位
- **我是谁**: [Max/Ella/Jarvis/Kyle]
- **我在哪一层**: Layer [1/2]
- **我可以 Spawn**: [根据权限]
- **我禁止 Spawn**: [根据权限]

### 任务执行前检查清单
- [ ] 检查了当前层级吗？会超过 Layer 3 吗？
- [ ] 检查了我的 Spawn 权限吗？
- [ ] 如果是 Bug 修复，这是第几轮？会超过 3 轮吗？
- [ ] 创建了 Task 状态文件吗？
- [ ] 预估了 Token 消耗吗？
- [ ] 定义了完成标准吗？
```

---

## 📋 场景示例

### 场景1: Max 发起新任务

```
[用户] "做一个登录页面"
    ↓
[Max] 1. 创建任务状态文件
      $ vim shared/tasks/current/task-001.md
      (使用 task-template.md 模板)
      
      2. 分析需求
      - 需要UI设计 → 需要 Ella
      - 需要前端开发 → 需要 Jarvis
      - 可以并行
      
      3. 并行 Spawn (使用 Task 工具)
      
      Task 1: Ella
      ---
      任务: 设计登录页面
      需求: ...
      约束: ...
      完成后: 更新 task-001.md 和 status.json
      
      Task 2: Jarvis  
      ---
      任务: 评估登录页技术方案
      需求: ...
      约束: ...
      完成后: 更新 task-001.md 和 status.json
      
      4. 等待结果
      - 监控 status.json
      - 收集交付物
      
      5. 整合决策
      - 设计方案 + 技术方案 = 执行计划
      
      6. Spawn Jarvis 开发
      
      7. Spawn Kyle 测试
      
      8. 验收通过，汇报用户
```

### 场景2: Bug 修复循环（重点）

```
[Kyle] 测试发现 Bug
    ↓
    1. 记录 Bug
       $ vim shared/bugs/bug-001.md
       
    2. 更新任务状态
       # 在 task-001.md 中添加第1轮记录
       
    3. 通知 Max
       # 更新 shared/status.json
       {
         "notifications": [{
           "to": "max",
           "from": "kyle", 
           "type": "bug_found",
           "task_id": "task-001",
           "message": "发现登录按钮无效",
           "bug_id": "bug-001"
         }]
       }
    ↓
[Max] 收到通知
    ↓
    1. 读取 Bug 详情
    2. 判断复杂度 → 简单 Bug
    3. Spawn Jarvis 修复 (第1轮)
    
       Task: Jarvis
       ---
       任务: 修复 Bug bug-001
       Bug详情: 登录按钮点击无反应
       复现步骤: ...
       期望结果: ...
       当前代码: ...
       修复后: 更新 bug-001.md 和 status.json
    ↓
[Jarvis] 修复完成
    ↓
    1. 修复代码
    2. 更新 bug-001.md (修复记录)
    3. 更新 task-001.md (第1轮修复记录)
    4. 通知 Kyle
       # 更新 status.json
    ↓
[Kyle] 验证 (第1轮)
    ↓
    ❌ 未通过 (Bug仍存在)
    ↓
    1. 更新 task-001.md (第1轮验证结果)
    2. 添加详细信息 (错误日志、截图)
    3. 通知 Max (第2轮)
    ↓
[Max] Spawn Jarvis 修复 (第2轮)
    ↓
[Jarvis] 修复
    ↓
[Kyle] 验证 (第2轮)
    ↓
    ❌ 未通过
    ↓
    通知 Max (第3轮)
    ↓
[Max] Spawn Jarvis 修复 (第3轮 - 最后一轮)
    ↓
[Jarvis] 修复
    ↓
[Kyle] 验证 (第3轮)
    ↓
    ❌ 未通过
    ↓
    通知 Max (第4轮请求)
    ↓
[Max] 🚨 介入！
    ↓
    1. 停止所有 Spawn
    2. 分析根因 (使用 5 Whys)
    3. 发现: 是设计缺陷，不是代码问题
    4. 汇报用户
       "Bug3轮未修复，根因是设计缺陷，建议重新设计"
    5. 等待用户决策
```

### 场景3: Ella 需要技术评估

```
[Ella] 设计用户中心页面
    ↓
    设计过程中遇到:
    "这个实时数据展示，技术上能实现吗？"
    ↓
    1. 检查权限: 我可以 Spawn Jarvis 吗？
       查 spawn-permissions.yaml → 可以（设计阶段技术评估）
    2. 检查层级: 我在 Layer 2，Spawn Jarvis → Layer 3 ✓
    3. Spawn Jarvis
       
       Task: Jarvis
       ---
       任务: 评估实时数据展示的技术可行性
       设计稿: [attach]
       具体问题:
       1. WebSocket实时推送是否可行？
       2. 预计开发成本？
       3. 有没有更简单的替代方案？
       约束: Jarvis评估后返回给我，不要再Spawn
       
    4. Jarvis 评估完成，返回结果
    5. Ella 根据评估调整设计
    6. 完成设计，通知 Max
```

### 场景4: Kyle 发现 Bug（正确处理）

```
[Kyle] 测试登录功能
    ↓
    ❌ 发现 Bug: 密码错误提示不友好
    ↓
    ❌ 错误做法: "我自己联系 Jarvis 修"
    
    ✅ 正确做法:
    1. 记录 Bug: shared/bugs/bug-002.md
    2. 更新 Task: task-001.md (Bug修复循环表)
    3. 通知 Max: 更新 status.json
    4. 等待 Max 协调
    
    为什么?
    - 这是为了防止无限循环
    - Max 可以判断是设计问题还是实现问题
    - 统一入口，便于跟踪统计
```

---

## 🛠️ 工具使用

### 创建任务状态文件

```bash
# 1. 复制模板
cp shared/skills/swarm-task-manager/state-templates/task-template.md \
   shared/tasks/current/task-001.md

# 2. 填写信息
vim shared/tasks/current/task-001.md

# 3. 更新状态
# 编辑 shared/status.json 添加任务
```

### 更新共享状态

```json
// shared/status.json
{
  "last_updated": "2026-03-02T20:00:00Z",
  "agents": {
    "max": { "status": "working", "current_task": "task-001" },
    "ella": { "status": "idle", "current_task": null },
    "jarvis": { "status": "working", "current_task": "task-001" },
    "kyle": { "status": "blocked", "current_task": "task-001" }
  },
  "tasks": {
    "task-001": {
      "status": "running",
      "layer": 2,
      "assigned_to": "jarvis",
      "progress": "60%"
    }
  },
  "notifications": [
    {
      "id": "notif-001",
      "to": "max",
      "from": "kyle",
      "type": "bug_found",
      "task_id": "task-001",
      "message": "发现2个bug需要修复",
      "timestamp": "2026-03-02T19:55:00Z",
      "read": false
    }
  ]
}
```

### Spawn 子 Agent

```python
# 使用 Task 工具
# 注意：在 Kimi 中使用 subagent_name 参数

task_spawn_context = """
## 父任务信息
- 父任务ID: task-001
- 我在层级: Layer 2 (Jarvis)
- 你将位于: Layer 3

## 你的任务
[具体任务描述]

## 背景信息
[必要上下文]

## 完成标准
- [ ] 标准1
- [ ] 标准2

## 约束条件
- 禁止继续 Spawn (你是终点)
- 完成后必须通知我
- 更新 shared/tasks/current/task-001.md

## 共享文件
- 任务状态: shared/tasks/current/task-001.md
- 状态通知: shared/status.json
"""
```

---

## ⚠️ 常见错误

### 错误1: 层级超限

```
❌ Max → Jarvis → Kyle → 尝试 Spawn Ella

问题: Kyle 是 Layer 3，不能再 Spawn
解决: 
- Kyle 应该通知 Max
- Max 决定是否 Spawn Ella
```

### 错误2: 权限违规

```
❌ Kyle 直接联系 Jarvis 修 Bug

问题: Kyle 禁止 Spawn Jarvis
解决:
- Kyle 记录 Bug，通知 Max
- Max Spawn Jarvis 修复
```

### 错误3: Bug循环无限制

```
❌ Bug 修5轮还在修

问题: 没有3轮限制
解决:
- 第4轮强制 Max 介入
- 分析根因，汇报用户
```

### 错误4: 不更新状态

```
❌ 完成了但不更新 shared/status.json

问题: Max 不知道进度，可能重复 Spawn
解决:
- 每次完成必须更新状态
- 通知相关方
```

### 错误5: 上下文丢失

```
❌ Spawn 时不提供背景信息

问题: 子 Agent 重复问已回答的问题
解决:
- Spawn 时提供完整上下文
- 引用共享文件路径
```

---

## 📊 监控检查清单

### Max 每日检查

- [ ] 查看 status.json 是否有 BLOCKED 任务
- [ ] 检查是否有超过3轮的Bug修复
- [ ] 统计昨日 Spawn 次数
- [ ] 确认所有进行中的任务有负责人

### 每周回顾

- [ ] 分析介入原因分布
- [ ] 统计各 Agent 的 Spawn 效率
- [ ] 识别流程改进点
- [ ] 更新本 Skill 文档

---

## 🎓 进阶技巧

### 技巧1: 批量 Spawn

```
需要同时设计和开发?

Max 同时 Spawn:
├── Ella: 设计任务
├── Jarvis: 技术预研
└── 等两者都完成后，再 Spawn Jarvis 开发
```

### 技巧2: 预判式 Spawn

```
看到复杂功能，预判会有Bug

Max:
1. Spawn Jarvis 开发
2. 同时 Spawn Kyle 准备测试用例（并行）

节省等待时间
```

### 技巧3: 子任务分解

```
Jarvis 开发时遇到:
"需要同时修改前端、后端、数据库"

Jarvis (Layer 2) 可以:
├── 自己完成全部（如果简单）
└─ 或分解为子任务（如果复杂）
   但注意: Jarvis 不能再 Spawn
   所以应该:
   - 记录需要多个文件修改
   - 依次完成
   - 统一测试
```

---

## 📚 相关文档

| 文档 | 用途 |
|------|------|
| `SKILL.md` | 核心规范，必须阅读 |
| `spawn-permissions.yaml` | 查询谁可以 Spawn 谁 |
| `task-lifecycle.md` | 理解任务生命周期 |
| `max-intervention.md` | Max 介入处理指南 |
| `state-templates/task-template.md` | 任务状态文件模板 |

---

## 💡 遇到问题?

1. **不确定能否 Spawn?** → 查 `spawn-permissions.yaml`
2. **不确定流程?** → 查 `task-lifecycle.md`
3. **需要 Max 介入?** → 参考 `max-intervention.md`
4. **模板不知道怎么填?** → 看 `state-templates/`

---

**最后更新**: 2026-03-02  
**维护者**: aiGroup Team
