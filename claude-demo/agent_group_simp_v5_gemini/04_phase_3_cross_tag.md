# Phase 3: Cross-Tag 闭环与向上固化治理核心框架

## 3.1 阶段目标
彻底根治前后端互相发 Tag 时，经常脱离正式管控变为“影子任务”或者遗漏追踪的乱象。本阶段将使所有影响系统边界和接口改动的 Cross-Tag 拥有一个确定的向上“请求立案”与 Max “审批入库并固化为正式任务”的标准化流程闭环。

## 3.2 Cross-Tag 模板规约与定位
Cross-Tag（放在 `handoff/fe-to-be/` 或 `handoff/be-to-fe/`）本质上**只是“协商输入诉求”**而**非“正式任务单”**。
小的问题能私自调解完成，但在以下情况下要求必须挂载 `requires_max_sync: true` 进行向上请示并进行正式固化：
1. 涉及改变了原来任务的验收边界标准。
2. 带来大体积的架构接口和数据模型新增约束。
3. 工作量影响预估时间超过半天。
4. 有可能影响 Kyle 后续审查的。

**强制执行标准 Cross-Tag 模板：**
```markdown
# Cross-Tag: <自定简明标题>
- change: <change-name>
- from: jarvis-fe | jarvis-be
- to: jarvis-be | jarvis-fe
- source_task: <task-id>
- priority: P0 | P1 | P2
- status: pending （待处理）
- requires_max_sync: true | false  # 【重点】是否由于影响范围须要 Max 转正入册

## 背景
<详细阐述为什么需要对方配合，或者对方暴露了什么缺口>

## 具体诉求
<希望对方怎么改或者补充什么能力>

## 建议固化方式
<是否建议回填补到 tasks.md 中对应某条 / 还是补到 design.md>

## 验证方式
<完工后如何证明达标>
```

## 3.3 向上触发固化事件的闭环链路 (The Sync Loop)
这是整个 V5 版本里最为重要的交互流。主要分发起触发，提醒落盘以及收口批准三步走。

**步骤一：关联记录登记**
当且仅当一个 Cross-Tag 的 `requires_max_sync` 为 `true`， 发起该操作的 FE 或者 BE 必须去对应的 `_meta.yaml` 的 `pending_syncs` 清单里增加一条悬挂项。

**步骤二：分发待办处理案卷**
发起方在此基础上，同时生成一个标准的提醒说明案卷并投放丢到 `shared/handoff/max-inbox/` 队列中强行引起 Max 的关注：
```markdown
# Sync Request: <change-name> / <cross-tag-title>
- change: <change-name>
- source: <对应的跨域 cross-tag 文件路径>
- requested_by: jarvis-fe | jarvis-be
- requested_action: update_tasks | update_design
- urgency: P0 | P1 | P2

## 提请 Max 决策并固化的内容
<阐明为什么要由项目经手处理，它对全局有什么影响，希望能修改哪一部分代码正式规范>
```

**步骤三：Max 收盘裁决与固化 (绝不允许无限期挂起)**
作为规则维护者的 Max，需要以清空 inbox 为常规任务，看到以上文件必须做出处理，处理方式只允许三选一并回档对应状态闭环：
1. **批准改 `tasks.md`**：评估合理，Max 动手往 `tasks.md` 内对应的子任务填入缺口的详细说明。并在 YAML 与原 Inbox 单标完结。
2. **批准上报 `design.md`**：如果是设计架构调整影响前端展示也如上操作。
3. **退回拒绝**：判断不合常理或者超出版本边界，直接连带正经拒绝驳回理由写还给 FE/BE 不予立项，此路在 YAML 里状态改为打回。

## 3.4 回退策略 (Rollback)
最主要风险即开发者大量堆积琐碎无效的 Cross-Tag 发回给 Max 将 Max 的信箱爆掉，且未等闭环就继续开发。如果出现此类事件：
- 马上暂停使用新的 `max-inbox/` 下发功能。
- 直接回到 Max 自行扫描 `fe-to-be/` 去硬性更新 `tasks.md` 的原始低级手工方式兜底。
- 人工干预清零并强校验那些 pending。
