# 子计划 03：状态层与 _meta 治理

## 1. 目标

上线 `_meta.yaml` 作为每个 change 的统一状态层，用来收敛生命周期状态、角色状态、评审状态和待固化事项，同时避免其膨胀成第二套 spec。

## 2. 本阶段要解决的问题

1. change 的当前状态容易散落在多人沟通和聚合文件中
2. `status.json` 若继续承担一线事实源，会和 change 内文档冲突
3. 没有统一状态层，Cross-Tag 与评审都缺少落点

## 3. 边界

### 允许记录

1. change 基本信息
2. 生命周期状态
3. 角色状态
4. 评审状态
5. `pending_syncs`
6. 归档状态

### 禁止记录

1. 需求正文
2. 接口设计正文
3. 长篇设计决策
4. 详细任务说明
5. 验收标准正文

## 4. 状态模型

### 生命周期建议值

1. `draft`
2. `ready`
3. `in-progress`
4. `review`
5. `done`
6. `archived`

### 评审状态建议值

1. `pending`
2. `in-review`
3. `changes-requested`
4. `approved`

### 角色状态建议值

1. `pending`
2. `active`
3. `in-progress`
4. `blocked`
5. `done`
6. `n/a`

## 5. 执行动作

### 动作 A：定义 `_meta.yaml` 模板

负责人：Max 规则维护者

动作内容：

1. 固定字段结构
2. 约束字段职责
3. 保证新 change 创建时能自动附带模板

完成标准：

1. 模板字段一致
2. 不同 change 间不会出现随意扩字段

### 动作 B：定义角色更新边界

负责人：规则维护者

动作内容：

1. Max 只负责总体状态和待固化事项
2. Jarvis-FE / Jarvis-BE 只更新自己的角色状态和提审引用
3. Kyle 只更新审查结果相关字段

完成标准：

1. 避免多人无边界修改同一文件
2. 状态字段更可信

### 动作 C：降级 `status.json`

负责人：实施者

动作内容：

1. 明确 `status.json` 只做聚合看板
2. 不再将其作为正式事实源
3. 需要聚合信息时从 `_meta.yaml` 汇总而来

完成标准：

1. `status.json` 不再与 change 内状态互相打架

## 6. 交付物

1. `_meta.yaml` 标准模板
2. 角色更新职责说明
3. `status.json` 降级说明
4. 至少一个真实 change 的 `_meta.yaml` 示例

## 7. 与其他子计划的关系

前置依赖：

1. 子计划 02 已完成角色拆分

后续支撑：

1. 子计划 04 的 `pending_syncs` 依赖 `_meta.yaml`
2. 子计划 05 的 `review_status` 依赖 `_meta.yaml`
3. 子计划 06 的归档状态依赖 `_meta.yaml`

## 8. 风险

### 风险 1：`_meta.yaml` 被写成长篇说明书

结果：

1. 与 `proposal.md / design.md / tasks.md` 冲突
2. 审查成本陡增

应对：

1. 只允许状态层字段
2. 评审时发现正文内容即要求迁出

### 风险 2：多人同时更新同一字段

结果：

1. 状态失真
2. 审查入口混乱

应对：

1. 明确字段责任人
2. 变更时只允许更新自身责任字段

## 9. 验收标准

1. 新 change 能自动带 `_meta.yaml`
2. 生命周期、角色状态、评审状态可在一个文件中查看
3. `status.json` 已明确降级为聚合看板
4. `_meta.yaml` 未承载正文设计内容

## 10. 回退方案

若 `_meta.yaml` 使用混乱：

1. 保留 `_meta.yaml`
2. 暂停将其作为主状态入口
3. 临时回到 `status.json` 聚合展示
4. 修复模板和职责后再恢复

## 11. 推荐字段结构

建议 `_meta.yaml` 至少包含以下结构：

```yaml
change: <change-name>
created_by: max
created_at: <ISO8601>
updated_at: <ISO8601>
priority: P0 | P1 | P2
status: draft | ready | in-progress | review | done | archived
review_status: pending | in-review | changes-requested | approved
roles:
  max: active | done
  ella: pending | active | done | n/a
  jarvis-fe: pending | in-progress | blocked | done | n/a
  jarvis-be: pending | in-progress | blocked | done | n/a
  kyle: pending | in-review | done | n/a
pending_syncs: []
review:
  request_file: null
  feedback_file: null
archive:
  archived: false
  archived_at: null
  archive_reason: null
```

这个结构不是要求一字不差，但建议固定主骨架，不要每个 change 自由发挥。

## 12. 详细执行步骤

### Step 1：确定字段最小集合

执行内容：

1. 只保留运行真正需要的状态字段
2. 删除会与正文文档重复的字段
3. 明确哪些字段是必填，哪些是可空

输出物：

1. `_meta.yaml` 模板草案

### Step 2：给字段绑定责任人

执行内容：

1. 每个字段都定义谁能改
2. 写出禁止跨角色修改的部分
3. 补充更新时间规则

输出物：

1. 一份字段责任矩阵

### Step 3：为新 change 接入模板

执行内容：

1. 确保创建新 change 时就带 `_meta.yaml`
2. 用 1 到 2 个真实 change 做试填
3. 观察是否有字段难以使用或经常为空

输出物：

1. 已接入的样例 change

### Step 4：降级聚合文件

执行内容：

1. 明确 `status.json` 只用于看板聚合
2. 若有状态冲突，以 `_meta.yaml` 为准
3. 后续聚合逻辑由 `_meta.yaml` 派生

输出物：

1. 一份聚合文件口径说明

## 13. 字段责任矩阵建议

```markdown
| 字段 | Max | Ella | Jarvis-FE | Jarvis-BE | Kyle |
| --- | --- | --- | --- | --- | --- |
| status | 可改 | 不改 | 不改 | 不改 | 不改 |
| review_status | 可改 | 不改 | 可触发更新 | 可触发更新 | 可改 |
| roles.max | 可改 | 不改 | 不改 | 不改 | 不改 |
| roles.ella | 可改 | 可更新自身 | 不改 | 不改 | 不改 |
| roles.jarvis-fe | 不改 | 不改 | 可更新自身 | 不改 | 不改 |
| roles.jarvis-be | 不改 | 不改 | 不改 | 可更新自身 | 不改 |
| roles.kyle | 不改 | 不改 | 不改 | 不改 | 可更新自身 |
| pending_syncs | 可改 | 不改 | 可新增自身请求 | 可新增自身请求 | 不改 |
| review.request_file | 不改 | 不改 | 可写 | 可写 | 不改 |
| review.feedback_file | 不改 | 不改 | 不改 | 不改 | 可写 |
| archive.* | 可改 | 不改 | 不改 | 不改 | 不改 |
```

## 14. 更新规则建议

1. 更新 `_meta.yaml` 时，必须同步刷新 `updated_at`
2. 角色只更新自己负责的最小字段集
3. 任何人都不应把“临时说明文字”塞进 `_meta.yaml`
4. 对 `pending_syncs` 的处理必须有状态变化，不允许一直是 `pending`

## 15. 检查清单

每接入一个新 change，检查：

1. 是否已包含 `_meta.yaml`
2. `status` 是否与当前阶段一致
3. `review_status` 是否与提审状态一致
4. `roles` 是否都有合理默认值
5. `pending_syncs` 是否为空或可解释
6. 是否混入长段正文说明

## 16. 常见失败模式

### 失败模式 1：字段过多

问题：

1. 使用者不愿维护

修正：

1. 只保留真实会被读取的字段

### 失败模式 2：字段过少

问题：

1. 无法支撑评审与 sync 闭环

修正：

1. 至少保留生命周期、角色状态、review、pending_syncs、archive

### 失败模式 3：把 `_meta.yaml` 当日志本

问题：

1. 文件膨胀

修正：

1. 细节日志写到 handoff 或 reviews，状态只留结果
