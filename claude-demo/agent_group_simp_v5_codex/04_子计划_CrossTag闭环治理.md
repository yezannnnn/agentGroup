# 子计划 04：Cross-Tag 闭环治理

## 1. 目标

让 Cross-Tag 保持“协商输入”定位，同时补上从 FE/BE 协商到 Max 固化的正式闭环，避免它演变为影子任务系统。

## 2. 本阶段要解决的问题

1. FE 与 BE 联动时，边界缺口无法被正式纳管
2. 若 Cross-Tag 只停留在 handoff，会长期漂浮
3. 若直接让 Cross-Tag 替代任务系统，会破坏 `tasks.md` 的单一事实源地位

## 3. 核心原则

1. Cross-Tag 不是正式任务
2. Cross-Tag 只承载协商输入
3. 涉及正式边界变化时，必须由 Max 固化到 `tasks.md` 或 `design.md`
4. `pending_syncs` 和 `max-inbox` 必须配套出现，不能只做其一

## 4. 适用场景

Cross-Tag 只处理以下场景：

1. 前端发现后端能力缺口
2. 后端发现前端需要适配的边界变化

不处理以下场景：

1. 正式任务编排
2. 最终验收边界定义
3. 长期需求排期

## 5. 闭环机制

### 步骤 1：发起 Cross-Tag

负责人：`jarvis-fe` 或 `jarvis-be`

要求：

1. 写明来源任务 `source_task`
2. 写明优先级
3. 写明是否需要 Max 同步
4. 写明验证方式

### 步骤 2：触发固化请求

触发条件：

只要 `requires_max_sync: true`，就必须同时执行：

1. 在 `_meta.yaml` 中新增 `pending_syncs`
2. 在 `shared/handoff/max-inbox/` 下生成 sync request

### 步骤 3：Max 处理

Max 只能做三种处理：

1. 固化到 `tasks.md`
2. 固化到 `design.md`
3. 拒绝固化并说明原因

禁止：

1. 长期挂起不处理
2. 只口头回复不落文档

### 步骤 4：回写结果

要求：

1. 更新 `_meta.yaml.pending_syncs` 状态
2. 在相关 handoff 或正式文档中保留可追溯引用
3. 相关 FE/BE 再据此继续执行

## 6. 必须固化的判定条件

只要满足以下任一项，就不能只停留在 Cross-Tag：

1. 影响验收标准
2. 改变正式交付边界
3. 新增接口、页面或数据结构约束
4. 影响 Kyle 的最终审查范围
5. 工作量超过半天

## 7. 交付物

1. Cross-Tag 模板
2. Sync Request 模板
3. `_meta.yaml.pending_syncs` 使用规范
4. 一条完整跑通的真实样例

## 8. 推进动作

### 动作 A：补齐模板

负责人：实施者

动作内容：

1. 固定 Cross-Tag 模板
2. 固定 Sync Request 模板
3. 指定存放目录

### 动作 B：绑定正式文档

负责人：Max

动作内容：

1. 约束何时更新 `tasks.md`
2. 约束何时更新 `design.md`
3. 约束拒绝时必须写原因

### 动作 C：试点验证

负责人：试点需求相关角色

动作内容：

1. 制造一次真实的 FE/BE 边界补充场景
2. 完成从发起到固化的完整链路
3. 观察是否出现长期 pending

## 9. 风险

### 风险 1：Cross-Tag 直接变成任务系统

结果：

1. `tasks.md` 失去唯一性
2. 审查依据碎裂

应对：

1. 强制“正式任务只认 `tasks.md`”
2. 审查时只接受已固化内容作为正式依据

### 风险 2：Max inbox 堆积

结果：

1. Cross-Tag 虽然提出了，但长期无法落地
2. 协作链路变慢

应对：

1. Max 启动检查时优先扫描 `max-inbox`
2. 对 pending sync 设定处理时限

## 10. 验收标准

1. FE/BE 能独立发起 Cross-Tag
2. `requires_max_sync: true` 时一定同时生成 `pending_syncs` 与 sync request
3. Max 能在正式文档中完成固化或拒绝
4. 至少一条真实联动需求跑通完整闭环
5. 没有长期悬挂的 pending sync

## 11. 回退方案

如果 Cross-Tag 机制造成大量积压：

1. 暂停新增 Cross-Tag
2. 改由 Max 直接修正 `tasks.md`
3. 清理未闭环的 `pending_syncs`
4. 修复机制后再恢复

## 12. 详细流程拆解

### 场景 A：FE 发现后端能力缺口

顺序：

1. `jarvis-fe` 根据 `tasks.md` 执行前端任务
2. 发现后端接口、字段或行为不足
3. 判断该问题是否影响正式边界
4. 若只是很小的实现细节，可直接发 `fe-to-be` 处理
5. 若影响正式边界，则：
   - 写 Cross-Tag
   - 写 `_meta.yaml.pending_syncs`
   - 写 `max-inbox` sync request
6. Max 判定是否更新 `tasks.md` 或 `design.md`
7. `jarvis-be` 按固化后的正式文档执行

### 场景 B：BE 发现前端需要同步适配

顺序：

1. `jarvis-be` 根据 `tasks.md` 执行后端任务
2. 发现前端页面、交互、字段展示需同步调整
3. 判断是否触及正式交付边界
4. 若触及，则发 `be-to-fe` 并同步请求 Max 固化
5. Max 更新正式文档
6. `jarvis-fe` 按最新正式文档执行

## 13. 推荐处理时限

为避免 pending 堆积，建议设定以下处理时限：

1. P0 sync request
   - 当日进入 Max 处理队列
2. P1 sync request
   - 1 个工作日内处理
3. P2 sync request
   - 2 个工作日内处理

这不是系统强制，而是执行纪律。若没有处理时限，闭环一定会变松。

## 14. Cross-Tag 模板增强版

```markdown
# Cross-Tag: <标题>

- change: <change-name>
- from: jarvis-fe | jarvis-be
- to: jarvis-be | jarvis-fe
- source_task: <tasks.md 中的 task-id>
- priority: P0 | P1 | P2
- status: pending
- requires_max_sync: true | false
- created_at: <ISO8601>

## 背景
<当前遇到的问题是什么>

## 已确认事实
<只写已经从代码、文档、联调结果中确认的事实>

## 具体诉求
<希望对方补什么，尽量写成可执行动作>

## 是否影响正式边界
<影响 / 不影响，为什么>

## 建议固化方式
<建议更新 tasks.md / design.md / 无需固化>

## 验证方式
<联调、页面验证、接口验证、回归方式>
```

## 15. Sync Request 模板增强版

```markdown
# Sync Request: <change-name> / <cross-tag-title>

- change: <change-name>
- source: <cross-tag-file>
- requested_by: jarvis-fe | jarvis-be
- requested_action: update_tasks | update_design
- urgency: P0 | P1 | P2
- created_at: <ISO8601>

## 需要 Max 决策的内容
<具体要纳管进正式体系的内容>

## 原因
<为什么不能只停留在 handoff>

## 建议落点
<希望回填到 tasks.md 的哪一部分，或 design.md 的哪一部分>
```

## 16. Max 处理清单

Max 处理 sync request 时，建议按以下顺序：

1. 确认 source change 是否存在
2. 确认 `source_task` 是否真实存在于 `tasks.md`
3. 判断该请求是否影响正式边界
4. 选择更新 `tasks.md`、更新 `design.md` 或拒绝
5. 更新 `_meta.yaml.pending_syncs` 状态
6. 在必要处补充引用，确保可追溯

## 17. 必须拒绝的情况

以下情况建议 Max 直接拒绝固化，并要求补充信息：

1. Cross-Tag 没有对应 `source_task`
2. 诉求只是模糊愿望，没有明确变更点
3. 与已有正式任务明显冲突，但未解释冲突原因
4. 仅是实现偏好，不影响正式边界
5. 没有写清验证方式

## 18. 样例闭环

### 样例

change：`budget-export`

流程：

1. FE 正在做“导出按钮 + 导出状态提示”
2. FE 发现后端没有导出任务查询接口
3. FE 发起 `fe-to-be/budget-export-status-api.md`
4. 因为新增接口且影响验收，`requires_max_sync: true`
5. FE 同步在 `_meta.yaml.pending_syncs` 中增加 `sync-001`
6. FE 同步在 `max-inbox/` 下写 sync request
7. Max 更新 `tasks.md`，新增后端接口任务和验收标准
8. Max 更新 `_meta.yaml.pending_syncs.sync-001.status=resolved`
9. BE 按新任务实现接口
10. FE 完成联调并进入提审

这个样例的意义是说明：Cross-Tag 可以提出问题，但正式任务边界的变更一定由 Max 固化。

## 19. 检查清单

1. Cross-Tag 是否写明来源任务
2. 是否写明当前问题是事实还是猜测
3. 是否判断了是否影响正式边界
4. 若要求固化，是否已同步写 `pending_syncs`
5. 是否已生成 `max-inbox` 请求
6. Max 是否已做出明确处理结果
7. 结果是否已回写正式文档和状态文件
