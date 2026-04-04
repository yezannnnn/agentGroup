# AI 团队协作体系改造方案 v5

> 目标：在不打断现有协作的前提下，把 `agent-group` 收敛为一套“角色清晰、事实源单一、协作可闭环、迁移可回退”的最终方案。

---

## 1. v5 的定位

v5 不是简单拼接 v2 / v3 / v4，而是在三版基础上做最终收敛：

1. 保留 v3 的稳健原则
   - 不先迁移 `openspec` 物理目录
   - 先统一逻辑，再做物理重构
   - 先跑通最小闭环，再扩大范围

2. 吸收 v4 的关键闭环
   - Cross-Tag 不是正式任务源
   - Cross-Tag 必须有进入正式任务体系的固化路径
   - `_meta.yaml` 只做状态，不做第二套 spec
   - 代码最终只由开发角色产出

3. 降级 v2 中高风险动作
   - `openspec/` 迁移到 `shared/specs/openspec/` 不作为当前默认方案
   - “文档替代全部通知机制”不作为第一阶段目标
   - 读写契约明确为“协作约束”，不是硬权限控制

---

## 2. 最终结论

### 2.1 角色结构

保留统一的 `agent-group/` 作为角色定义仓库，但将 `Jarvis` 正式拆分为：

1. `jarvis-fe`
2. `jarvis-be`

原 `jarvis/` 保留为兼容入口，但标记弃用，不再作为长期主入口。

### 2.2 三层职责

三层能力边界最终确定如下：

1. `openspec` 管“做什么”
   - 需求背景
   - 设计约束
   - 正式任务
   - 验收标准

2. `superpowers` 管“怎么推进流程”
   - 方案拆解
   - 调试
   - 验证
   - 提审
   - 收审

3. 自定义 skill 管“怎么写代码”
   - 技术栈规范
   - 实现约束
   - 审查标准

### 2.3 代码产出责任

最终代码只由开发角色产出：

1. 前端代码由 `jarvis-fe` 产出
2. 后端代码由 `jarvis-be` 产出

`openspec`、`superpowers`、自定义 skill 都不直接替代开发角色写业务代码。

---

## 3. 单一事实源

这是 v5 的总原则。

### 3.1 正式事实源

一个 change 只允许以下 4 类正式事实源：

1. `openspec/changes/<change>/proposal.md`
   - 需求背景

2. `openspec/changes/<change>/design.md`
   - 技术设计 / UI 设计

3. `openspec/changes/<change>/tasks.md`
   - 正式任务清单
   - 角色分工
   - 验收标准

4. `openspec/changes/<change>/_meta.yaml`
   - 生命周期状态
   - 角色状态
   - 提审状态
   - 待固化事项

### 3.2 非正式事实源

以下目录只承载协作输入输出，不是正式任务源：

1. `shared/handoff/`
2. `shared/superpowers/`
3. `status.json`
4. `notifications.json`

### 3.3 强约束

1. 正式任务只认 `tasks.md`
2. 验收标准只认 `tasks.md`
3. Cross-Tag 只能作为协商输入，不能长期替代 `tasks.md`
4. `_meta.yaml` 只能做状态层，不能写成长篇 spec

---

## 4. 最终目录结构

### 4.1 当前阶段默认结构

```text
agent-group/
├── .claude/
│   ├── skills/
│   │   ├── openspec-propose/
│   │   ├── openspec-apply-change/
│   │   ├── openspec-explore/
│   │   └── openspec-archive-change/
│   └── settings.local.json
├── openspec/
│   ├── changes/
│   ├── archive/
│   └── config.yaml
├── max/
├── ella/
├── jarvis-fe/
├── jarvis-be/
├── jarvis/                         # 保留兼容入口，标记弃用
├── kyle/
└── shared/
    ├── handoff/
    │   ├── max-inbox/
    │   ├── ella-to-jarvis/
    │   ├── fe-to-be/
    │   ├── be-to-fe/
    │   ├── jarvis-to-kyle/
    │   ├── kyle-to-jarvis/
    │   └── archive/
    ├── superpowers/
    │   ├── plans/
    │   ├── reviews/
    │   └── debug-logs/
    ├── protocols/
    │   └── mandatory-flow.md
    ├── status.json
    └── notifications.json
```

### 4.2 明确不做的事

当前默认不做以下动作：

1. 不迁移 `agent-group/openspec/` 到 `shared/specs/openspec/`
2. 不删除 `status.json`
3. 不删除 `notifications.json`
4. 不把 handoff 目录当成正式任务系统

---

## 5. 角色职责最终版

### 5.1 Max

负责：

1. 接收新需求
2. 创建和维护 `openspec change`
3. 维护 `tasks.md` 为正式任务清单
4. 处理 Cross-Tag 的固化请求
5. 维护 `_meta.yaml` 的总体状态

不负责：

1. 不写任何代码
2. 不代替 FE / BE 做细节联调协商
3. 不做最终代码验收结论

### 5.2 Ella

负责：

1. 补充设计稿
2. 补充 `design.md` 的 UI 部分
3. 向 `shared/handoff/ella-to-jarvis/` 交付 UI 设计

不负责：

1. 不修改 `tasks.md` 正式任务拆分
2. 不写任何代码
3. 不做最终代码验收

### 5.3 Jarvis-FE

负责：

1. 按 `tasks.md` 执行前端正式任务
2. 读取设计交付
3. 必要时发起 `fe-to-be` Cross-Tag
4. 提交前端代码与提审材料

不负责：

1. 不写任何后端代码
2. 不决定正式任务边界
3. 不绕过 Max 把 Cross-Tag 直接升格为正式任务
4. 不做最终审查放行

### 5.4 Jarvis-BE

负责：

1. 按 `tasks.md` 执行后端正式任务
2. 必要时发起 `be-to-fe` Cross-Tag
3. 提交后端代码与提审材料

不负责：

1. 不写任何前端代码
2. 不决定正式任务边界
3. 不绕过 Max 把 Cross-Tag 直接升格为正式任务
4. 不做最终审查放行

### 5.5 Kyle

负责：

1. 依据 `tasks.md` 验收标准进行审查
2. 读取 `jarvis-to-kyle/` 提审单
3. 输出 `kyle-to-jarvis/` 反馈
4. 更新审查相关状态

不负责：

1. 不替 Max 维护正式任务清单
2. 不以 Cross-Tag 作为正式验收依据
3. 不写任何代码

---

## 6. Cross-Tag 的最终定义

### 6.1 定位

Cross-Tag 是“协商输入”，不是“正式任务”。

它只解决两类问题：

1. 前端发现后端能力缺口
2. 后端发现前端需要适配的边界变化

它不直接解决：

1. 正式任务编排
2. 最终验收边界定义

### 6.2 存放目录

```text
shared/handoff/
├── fe-to-be/
└── be-to-fe/
```

### 6.3 模板

```markdown
# Cross-Tag: <标题>

- change: <change-name>
- from: jarvis-fe | jarvis-be
- to: jarvis-be | jarvis-fe
- source_task: <task-id>
- priority: P0 | P1 | P2
- status: pending（待处理）
- requires_max_sync: true | false

## 背景
<为什么需要对方配合>

## 具体诉求
<希望对方补充什么>

## 建议固化方式
<是否建议补到 tasks.md / design.md>

## 验证方式
<完成后如何验证>
```

### 6.4 处理结果

Cross-Tag 只能有以下 3 种结果：

1. 直接处理
   - 适用于小范围实现细节
   - 不改变正式验收边界

2. 固化进正式体系
   - 由 Max 回填到 `tasks.md` 或 `design.md`

3. 拒绝或要求澄清
   - 原因需要写回

### 6.5 必须固化的条件

出现以下任一条件，Cross-Tag 必须走 Max 固化：

1. 影响验收标准
2. 改变正式交付边界
3. 新增接口 / 页面 / 数据结构约束
4. 影响 Kyle 的最终审查范围
5. 工作量超过半天

---

## 7. Cross-Tag 到正式任务的闭环

这是 v5 最关键的闭环。

### 7.1 固化请求机制

当 `jarvis-fe` 或 `jarvis-be` 创建 Cross-Tag 后，如果 `requires_max_sync: true`，必须同步做两件事：

1. 在对应 change 的 `_meta.yaml` 中新增一条 `pending_syncs`
2. 在 `shared/handoff/max-inbox/` 下生成一条 sync request

### 7.2 `max-inbox` 模板

```markdown
# Sync Request: <change-name> / <cross-tag-title>

- change: <change-name>
- source: <cross-tag-file>
- requested_by: jarvis-fe | jarvis-be
- requested_action: update_tasks | update_design
- urgency: P0 | P1 | P2

## 需要 Max 决策的内容
<说明要固化什么>
```

### 7.3 `_meta.yaml` 示例

```yaml
change: budget-export
created_by: max
created_at: 2026-04-04T09:00:00Z
updated_at: 2026-04-04T14:30:00Z
priority: P1
status: in-progress # 进行中
review_status: pending # 待评审
roles:
  max: active # 活跃
  ella: n/a # 不参与
  jarvis-fe: in-progress # 进行中
  jarvis-be: pending # 待处理
  kyle: pending # 待处理
pending_syncs:
  - id: sync-001
    source: shared/handoff/fe-to-be/budget-export-api.md
    requested_by: jarvis-fe
    action: update_tasks
    status: pending # 待处理
review:
  request_file: null
  feedback_file: null
archive:
  archived: false # 未归档
  archived_at: null
  archive_reason: null
```

### 7.4 Max 的处理动作

Max 必须对每个 `pending（待处理）` sync 做三选一处理：

1. 固化到 `tasks.md`
2. 固化到 `design.md`
3. 拒绝固化并写明原因

禁止长期保留 `pending（待处理）` 不处理。

---

## 8. `_meta.yaml` 的最终边界

### 8.1 允许承载

`_meta.yaml` 只允许记录：

1. change 基本信息
2. 生命周期状态
3. 角色状态
4. 提审状态
5. 待固化事项
6. 归档状态

### 8.2 禁止承载

`_meta.yaml` 不允许写入：

1. 需求正文
2. 接口设计正文
3. 长篇设计决策
4. 详细任务描述
5. 验收标准正文

### 8.3 生命周期

统一状态建议为：

1. `draft`（草稿）
2. `ready`（就绪）
3. `in-progress`（进行中）
4. `review`（评审中）
5. `done`（已完成）
6. `archived`（已归档）

### 8.4 更新职责

为避免多人无规则改同一文件，职责固定如下：

1. Max
   - 创建 `_meta.yaml`
   - 更新总体状态
   - 处理 `pending_syncs`
   - 标记归档

2. Jarvis-FE / Jarvis-BE
   - 只更新自己的角色状态
   - 写入提审引用
   - 不修改其他角色字段

3. Kyle
   - 更新审查结果相关字段
   - 不修改需求类字段

---

## 9. 审查闭环

### 9.1 提审输入

Kyle 审查时至少读取两类内容：

1. `tasks.md`
2. `shared/handoff/jarvis-to-kyle/<change>.md`

必要时补充读取：

1. `design.md`
2. 相关 Cross-Tag
3. 自查报告

### 9.2 提审单模板

```markdown
# 审查请求: <change-name>

- 提交者: jarvis-fe | jarvis-be
- 关联 change: <change-name>
- 自查报告: <shared/superpowers/reviews/...>

## 变更范围
<本次提交修改了什么>

## 关联任务
<tasks.md 中对应 task>

## 验收基准
<引用 tasks.md 的验收标准>
```

### 9.3 审查输出

Kyle 输出到：

`shared/handoff/kyle-to-jarvis/<change>.md`

内容至少包括：

1. 审查范围
2. 问题清单
3. 阻塞项 / 非阻塞项
4. 建议回归项

### 9.4 联合审查规则

同一 change 如果同时涉及 FE / BE：

1. 允许前后端分别开发
2. 但尽量以同一 change 为统一提审入口
3. Kyle 以同一 change 为最小审查单元

---

## 10. CLAUDE.md 统一规范

### 10.1 通用第一性约束

所有角色的 `CLAUDE.md` 顶部必须统一加入：

```markdown
# 第一性约束

1. 只根据实际读取到的代码、文件、命令结果回答。
2. 不编造接口、路径、配置、错误信息。
3. 信息不足时先说明缺口，再说明如何获取，不做推测性结论。
4. 涉及结论必须可验证。
```

### 10.2 通用结构

每个角色 `CLAUDE.md` 建议固定为 6 段：

1. 第一性约束
2. 角色身份
3. 任务入口规则
4. 技能使用规则
5. 读写契约
6. 项目上下文获取方式

### 10.3 公共流程抽离

公共强制流程统一抽到：

`shared/protocols/mandatory-flow.md`

各角色只保留一条引用：

```markdown
读取并遵循 `../shared/protocols/mandatory-flow.md`
```

这样可以避免 `CLAUDE.md` 再次膨胀。

---

## 11. 读写契约最终版

读写契约的性质必须说明清楚：

1. 它是协作约束
2. 它不是硬权限控制
3. 它用于降低误写和边界混乱
4. 真正的硬隔离如果需要，后续再用工具层补

推荐约定如下：

| 角色      | 可读                                                                                                          | 可写                                                                                  |
| --------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Max       | `openspec/**`, `shared/handoff/**`, `shared/status.json`, `shared/notifications.json`                         | `openspec/**`, `shared/status.json`                                                   |
| Ella      | `openspec/changes/*/proposal.md`, `openspec/changes/*/design.md`                                              | `shared/handoff/ella-to-jarvis/`, `openspec/changes/*/design.md`                      |
| Jarvis-FE | `openspec/**`, `shared/handoff/ella-to-jarvis/`, `shared/handoff/kyle-to-jarvis/`, `shared/handoff/be-to-fe/` | `shared/handoff/fe-to-be/`, `shared/handoff/jarvis-to-kyle/`, `shared/superpowers/**` |
| Jarvis-BE | `openspec/**`, `shared/handoff/kyle-to-jarvis/`, `shared/handoff/fe-to-be/`                                   | `shared/handoff/be-to-fe/`, `shared/handoff/jarvis-to-kyle/`, `shared/superpowers/**` |
| Kyle      | `openspec/**`, `shared/handoff/jarvis-to-kyle/`, `shared/handoff/fe-to-be/`, `shared/handoff/be-to-fe/`       | `shared/handoff/kyle-to-jarvis/`, `shared/superpowers/reviews/`                       |

---

## 12. `status.json` 与 `notifications.json` 的最终处理

### 12.1 `status.json`

保留，但降级为聚合看板，不再作为正式一线事实源。

### 12.2 `notifications.json`

保留，但只保留两类通知：

1. 日常通告
2. 紧急临时事件

不再承载：

1. 正常任务分配
2. 正常提审通知

这些信息由：

1. `tasks.md`
2. `handoff/`
3. `_meta.yaml`

承载。

---

## 13. 启动检查顺序

### 13.1 Max

1. 扫描 `openspec/changes/*/_meta.yaml`
2. 扫描 `shared/handoff/max-inbox/`
3. 处理待固化事项
4. 再决定是否更新 `tasks.md / design.md`

### 13.2 Ella

1. 扫描 `proposal.md`
2. 扫描 `design.md` 中待补充部分
3. 输出设计交付到 `ella-to-jarvis/`

### 13.3 Jarvis-FE / Jarvis-BE

1. 读取 `tasks.md`
2. 读取 `_meta.yaml`
3. 读取与自己相关的 handoff
4. 如发现边界缺口，创建 Cross-Tag
5. 如影响正式边界，同步发起 sync request 给 Max

### 13.4 Kyle

1. 扫描 `_meta.yaml.review_status`
2. 读取 `jarvis-to-kyle/`
3. 回到 `tasks.md` 做审查

---

## 14. 迁移路径最终版

### Phase 0：准备期

目标：

1. 不打断现有流程
2. 先把目录和模板备齐

动作：

1. 新建 `jarvis-fe/`、`jarvis-be/`
2. 新建 `shared/handoff/max-inbox/`
3. 新建 `openspec/archive/`
4. 新建 `shared/handoff/archive/`
5. 抽离 `shared/protocols/mandatory-flow.md`

验收标准：

1. 现有流程不受影响
2. 新结构可访问
3. 模板可直接使用

### Phase 1：角色拆分上线

目标：

1. 用 `jarvis-fe / jarvis-be` 替代全栈 `jarvis`
2. 先跑通基础开发链路

动作：

1. `jarvis/` 标记弃用
2. 前后端分别切到新角色
3. 更新各自 `CLAUDE.md`

验收标准：

1. 单个需求可由 FE / BE 分别执行
2. 没有因拆分导致任务丢失

### Phase 2：引入 `_meta.yaml`

目标：

1. 建立统一状态层
2. 降低对 `status.json` 的依赖

动作：

1. 新 change 自动带 `_meta.yaml`
2. 各角色按权限更新状态字段
3. `status.json` 开始降级为聚合视图

验收标准：

1. 一个 change 的状态可从 `_meta.yaml` 直接看清
2. 待审状态不再依赖多人手工口头同步

### Phase 3：引入 Cross-Tag 固化闭环

目标：

1. 允许 FE / BE 补充边界
2. 确保补充内容能进入正式任务体系

动作：

1. 建 `fe-to-be/`、`be-to-fe/`
2. 建 `max-inbox/`
3. Cross-Tag 创建后同步发起 sync request
4. Max 处理并回填 `tasks.md / design.md / _meta.yaml`

验收标准：

1. 至少一条联动需求跑通“发现缺口 -> 发起协商 -> Max 固化 -> 正式执行”
2. 没有长期悬挂的 `pending（待处理）` sync

### Phase 4：统一提审与联合审查

目标：

1. Kyle 基于统一 change 审查
2. FE / BE 联动改动可一并验收

动作：

1. 规范 `jarvis-to-kyle/`
2. 规范 `kyle-to-jarvis/`
3. 使用 `_meta.yaml.review_status` 作为待审入口

验收标准：

1. Kyle 能从同一 change 看到完整上下文
2. FE / BE 联动改动不再形成割裂审查入口

### Phase 5：归档与性能治理

目标：

1. 控制活跃目录膨胀
2. 保证历史可追溯

动作：

1. 完成 `openspec/archive/` 归档机制
2. 完成 `shared/handoff/archive/` 归档机制
3. 控制活跃 change 扫描范围

验收标准：

1. 活跃目录保持精简
2. 历史 change 可追溯
3. 启动扫描成本可控

---

## 15. 回退策略

### Phase 1 回退

如果角色拆分不稳定：

1. 保留旧 `jarvis` 入口
2. 暂时回到单角色执行
3. 不删除已新增目录

### Phase 2 回退

如果 `_meta.yaml` 使用混乱：

1. 保留文件
2. 暂停把它作为主状态入口
3. 临时回到 `status.json` 聚合视图

### Phase 3 回退

如果 Cross-Tag 大量堆积：

1. 暂停新增 Cross-Tag
2. 改由 Max 直接修正 `tasks.md`
3. 清理未闭环的 `pending（待处理）` sync

### Phase 4 回退

如果联合提审复杂度过高：

1. 保留同一 change
2. 暂时按前后端分批提审
3. 由 Kyle 在反馈中手工汇总

---

## 16. 风险与对策

### 风险 1：`--project` 路径行为不稳定

对策：

1. 先小范围验证
2. 准备工程本地 `.claude/` 兼容入口

### 风险 2：`_meta.yaml` 膨胀成第二套 spec

对策：

1. 只允许状态字段
2. 审查时禁止写入正文内容

### 风险 3：Cross-Tag 变成影子任务系统

对策：

1. 明确它只是协商输入
2. 需要正式纳管时必须回填 `tasks.md` 或 `design.md`

### 风险 4：CLAUDE.md 再次膨胀

对策：

1. 公共流程抽离
2. 各角色只保留差异规则

### 风险 5：用户误以为读写契约等于权限隔离

对策：

1. 文档明确说明它只是协作约束
2. 真正的硬隔离后续再补工具层方案

---

## 17. 最终实施建议

v5 的实施顺序只保留 5 条最关键建议：

1. 先拆 `jarvis-fe / jarvis-be`，不先迁 `openspec`
2. 先确定 `proposal / design / tasks / _meta` 四类事实源
3. 先让 Cross-Tag 具备“发起协商 + Max 固化”的闭环
4. 先把审查统一到同一 change 维度
5. 先用一个中等复杂度的前后端联动需求试点，再扩面

如果只保留一句话，v5 的核心就是：

> 正式任务只认 `tasks.md`，协商补充通过 Cross-Tag 发起、由 Max 固化，状态统一收敛到 `_meta.yaml`，最终代码由 `jarvis-fe / jarvis-be` 产出，Kyle 按同一 change 做统一审查。
