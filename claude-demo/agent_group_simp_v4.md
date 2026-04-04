# AI 团队协作体系改造方案 v4

> 本版针对 4 个未闭环问题重写：  
> 1. Cross-Tag 如何进入正式任务体系  
> 2. `_meta.yaml` 如何归档和清理  
> 3. openspec / superpowers / 自定义 skill 的分工下，最终代码由谁产出  
> 4. 多阶段迁移如何具体规划、如何验收

---

## 1. 方案目标

本方案的目标不是“把所有机制都做出来”，而是建立一套可持续运行的协作闭环：

1. 新需求有统一入口
2. 前后端协作有补充机制
3. 状态信息有统一载体
4. 审查有明确输入输出
5. 迁移有阶段、有验收标准、有回退策略

---

## 2. 核心原则

### 2.1 单一事实源

正式协作中只允许 4 类核心事实源：

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
   - 负责人状态
   - 提审状态

其他目录只做“协作输入 / 协作输出”，不作为正式任务源。

### 2.2 Cross-Tag 是“补充输入”，不是“并行任务系统”

Cross-Tag 的定位必须明确：

1. 它用于前后端协商补充
2. 它用于暴露 Max 初始拆分未覆盖的边界
3. 它不是正式任务表
4. 它不能长期替代 `tasks.md`

### 2.3 代码最终必须由开发角色产出

规范类机制不产出代码，只有开发角色产出代码：

1. `openspec` 不写代码
2. `superpowers` 不写业务代码
3. 自定义 skill 不直接等于代码产出
4. **最终代码由 `jarvis-fe` / `jarvis-be` 编写**

---

## 3. 角色与职责

### 3.1 Max

职责：

1. 创建和维护 change
2. 维护 `tasks.md` 为正式任务事实源
3. 接收 Cross-Tag 固化请求
4. 决定是否把协商内容升格为正式任务
5. 维护 `_meta.yaml` 的总体状态

不负责：

1. 不负责前端代码实现
   - 建议找：`jarvis-fe`
2. 不负责后端代码实现
   - 建议找：`jarvis-be`
3. 不负责 UI 设计稿、页面视觉稿、交互稿产出
   - 建议找：`ella`
4. 不负责替 FE / BE 完成接口细节、字段映射、联调细节协商
   - 建议先由：`jarvis-fe` 与 `jarvis-be` 通过 Cross-Tag 协商
5. 不负责代码验收结论、质量放行结论
   - 建议找：`kyle`

### 3.2 Ella

职责：

1. 设计交付
2. 维护 `design.md` 的 UI 部分
3. 将设计产出写入 `shared/handoff/ella-to-jarvis/`

不负责：

1. 不负责编写任何前端业务代码、组件代码、页面代码
   - 建议找：`jarvis-fe`
2. 不负责编写任何后端接口、服务、数据库代码
   - 建议找：`jarvis-be`
3. 不允许修改 `tasks.md` 的正式任务拆分
   - 建议找：`max`
4. 不允许做代码验收、缺陷判定、是否通过审查的结论
   - 建议找：`kyle`
5. 不允许以“设计建议”的名义直接改动开发实现
   - 正确做法：更新 `design.md` 或输出到 `ella-to-jarvis/`
   - 落地实现仍由：`jarvis-fe` / `jarvis-be`

### 3.3 Jarvis-FE

职责：

1. 依据 `tasks.md` 执行前端正式任务
2. 必要时发起 `fe-to-be` Cross-Tag
3. 提交前端代码
4. 生成前端提审材料

不负责：

1. 不负责后端接口实现、服务逻辑、数据库结构变更
   - 建议找：`jarvis-be`
2. 不允许最终 UI / UX 设计决策
   - 建议找：`ella`
3. 不允许正式任务拆分、优先级调整、验收边界定义
   - 建议找：`max`
4. 不允许最终审查结论和质量放行
   - 建议找：`kyle`
5. 不允许绕过 `tasks.md` 自行把 Cross-Tag 升格为正式任务
   - 正确做法：发起 sync request 给 `max`

### 3.4 Jarvis-BE

职责：

1. 依据 `tasks.md` 执行后端正式任务
2. 必要时发起 `be-to-fe` Cross-Tag
3. 提交后端代码
4. 生成后端提审材料

不负责：

1. 不负责前端页面实现、组件实现、样式调整
   - 建议找：`jarvis-fe`
2. 不允许最终 UI / UX 设计决策
   - 建议找：`ella`
3. 不允许正式任务拆分、优先级调整、验收边界定义
   - 建议找：`max`
4. 不允许最终审查结论和质量放行
   - 建议找：`kyle`
5. 不允许绕过 `tasks.md` 自行把 Cross-Tag 升格为正式任务
   - 正确做法：发起 sync request 给 `max`

### 3.5 Kyle

职责：

1. 依据 `tasks.md` 做验收审查
2. 读取 `jarvis-to-kyle` 的提审单
3. 输出 `kyle-to-jarvis` 反馈
4. 更新审查结果相关状态

不负责：

1. 不负责 UI / UX 设计稿、交互稿、视觉方案设计
   - 建议找：`ella`
2. 不负责前端业务代码实现
   - 建议找：`jarvis-fe`
3. 不负责后端业务代码实现
   - 建议找：`jarvis-be`
4. 不负责正式任务拆分、需求边界定义、优先级决策
   - 建议找：`max`
5. 不负责以审查意见替代正式设计或正式任务
   - 如果发现设计缺失：建议回给 `ella`
   - 如果发现任务边界缺失：建议回给 `max`

---

## 4. 三层能力体系与“代码到底谁写”

这是必须彻底讲清楚的。

### 4.1 openspec 的作用

`openspec` 管“需求到任务”的过程，不管代码实现：

1. 定义 change
2. 生成 proposal / design / tasks
3. 给出验收标准

它解决的是：

1. 做什么
2. 为什么做
3. 做到什么算完成

它不解决：

1. 代码怎么写
2. 具体调试怎么做
3. 如何提审

### 4.2 superpowers 的作用

`superpowers` 管“执行流程质量”，不负责变成正式任务事实源。

适用场景：

1. 复杂任务先拆方案
2. 排查 Bug
3. 修复后验证
4. 提审前自查
5. 收到审查意见后修正

它可能产出：

1. `shared/superpowers/plans/`
2. `shared/superpowers/reviews/`
3. `shared/superpowers/debug-logs/`

这些产物是执行辅助材料，不是正式需求事实源。

### 4.3 自定义 skill 的作用

自定义 skill 负责“编码规范 / 技术栈约束 / 审查规则”。

例如：

1. `react-frontend`
2. `senior-frontend`
3. `java-backend`
4. `code-reviewer`
5. `tdd-guide`

它定义的是：

1. 采用什么技术写法
2. 遵循什么工程规范
3. 审查时看什么

### 4.4 最终代码由谁产出

最终代码只由下面两类角色产出：

1. `jarvis-fe`
   - 前端代码
   - 前端测试
   - 前端提审材料

2. `jarvis-be`
   - 后端代码
   - 后端测试
   - 后端提审材料

因此可以把职责关系写成一句话：

> `openspec` 定义目标，`superpowers` 规范流程，自定义 skill 约束写法，`jarvis-fe / jarvis-be` 产出代码。

---

## 5. Cross-Tag 的完整闭环

这是本版重点。

### 5.1 Cross-Tag 何时创建

只有在以下情况才允许创建 Cross-Tag：

1. 前端发现后端接口能力不足
2. 后端发现前端需要适配结构变更
3. Max 当前 `tasks.md` 没覆盖到实际联动边界
4. 当前 change 内出现额外依赖，但还不能直接修改 `tasks.md`

### 5.2 Cross-Tag 存放位置

```text
shared/handoff/
├── fe-to-be/
└── be-to-fe/
```

### 5.3 Cross-Tag 模板

```markdown
# Cross-Tag: <标题>

- change: <change-name>
- from: jarvis-fe | jarvis-be
- to: jarvis-be | jarvis-fe
- source_task: <task-id>
- priority: P0 | P1 | P2
- status: pending
- requires_max_sync: true

## 背景
<为什么需要对方配合>

## 具体诉求
<要对方补什么能力>

## 建议固化方式
<是否建议补到 tasks.md / design.md>

## 验证方式
<补完后怎么验证>
```

### 5.4 Cross-Tag 如何通知 Max

这是强制闭环。

创建 Cross-Tag 后，必须同步做两件事：

1. 在对应 change 的 `_meta.yaml` 里记录一条 `pending_syncs`
2. 在 `shared/handoff/max-inbox/` 下生成一条“固化请求”

推荐目录新增：

```text
shared/handoff/
├── max-inbox/
├── fe-to-be/
└── be-to-fe/
```

### 5.5 `max-inbox` 固化请求模板

```markdown
# Sync Request: <change-name> / <cross-tag-title>

- change: <change-name>
- source: shared/handoff/fe-to-be/<file>.md
- requested_by: jarvis-fe
- requested_action:
  - update_tasks
  - update_design
- urgency: P0 | P1 | P2

## 需要 Max 决策的内容
<哪些内容需要正式固化>
```

### 5.6 `_meta.yaml` 中如何体现待固化事项

示例：

```yaml
change: budget-export
status: in-progress
review_status: pending
roles:
  jarvis-fe: in-progress
  jarvis-be: pending
  kyle: pending
pending_syncs:
  - id: sync-001
    source: shared/handoff/fe-to-be/budget-export-api.md
    requested_by: jarvis-fe
    action: update_tasks
    status: pending
```

### 5.7 Max 如何处理 Cross-Tag

Max 每次进入 change 时，必须检查：

1. `shared/handoff/max-inbox/`
2. `_meta.yaml.pending_syncs`

然后做三选一决策：

1. **固化到 `tasks.md`**
   - 增加正式任务项
   - 补依赖关系
   - 可能调整验收标准

2. **固化到 `design.md`**
   - 如果本质是设计约束变化

3. **拒绝固化**
   - 原因写回 sync request
   - 同时更新 `pending_syncs.status: rejected`

### 5.8 什么时候必须固化

出现以下情况，Cross-Tag 不能只停留在 handoff，必须固化：

1. 影响验收标准
2. 会改变正式交付边界
3. 会新增接口 / 页面 / 数据结构约束
4. 会影响 Kyle 的最终审查范围
5. 工作量超过半天

### 5.9 什么时候可以不固化

只有以下情况可以不固化到 `tasks.md`：

1. 小范围实现细节
2. 不改变验收标准
3. 不新增正式交付项
4. 双方已经明确且不需要 Kyle 单独验收

此时 Max 仍需将该项标记为：

- `pending_syncs.status: acknowledged-no-task-update`

这表示“已确认，但不进入正式任务表”。

---

## 6. `_meta.yaml` 的职责、归档和清理

### 6.1 `_meta.yaml` 的定位

`_meta.yaml` 是 change 的状态封面，不是第二套设计文档。

允许记录：

1. change 基本信息
2. 生命周期状态
3. 角色进度状态
4. 提审状态
5. 待固化事项
6. 归档信息

不允许记录：

1. 大段需求正文
2. 接口协议细节
3. 设计决策正文
4. 详细任务说明

### 6.2 推荐格式

```yaml
change: budget-export
created_by: max
created_at: 2026-04-04T09:00:00Z
updated_at: 2026-04-04T14:30:00Z
priority: P1
status: in-progress
review_status: pending
roles:
  max: active
  ella: n/a
  jarvis-fe: in-progress
  jarvis-be: pending
  kyle: pending
pending_syncs: []
review:
  request_file: null
  feedback_file: null
archive:
  archived: false
  archived_at: null
  archive_reason: null
```

### 6.3 生命周期

建议统一生命周期：

1. `draft`
2. `ready`
3. `in-progress`
4. `review`
5. `done`
6. `archived`

### 6.4 谁更新 `_meta.yaml`

必须避免多人无规则改同一个文件。

建议分工：

1. `Max`
   - 创建 `_meta.yaml`
   - 更新总体状态
   - 处理 `pending_syncs`
   - 标记归档

2. `Jarvis-FE / Jarvis-BE`
   - 只更新自己角色状态字段
   - 写入 review request 引用
   - 不修改其他角色状态

3. `Kyle`
   - 更新 review 结果相关字段
   - 不修改需求类字段

### 6.5 归档策略

`_meta.yaml` 不单独归档，它跟着整个 change 一起归档。

归档条件：

1. change 已完成
2. 审查反馈已处理
3. 没有 `pending_syncs`
4. 没有未完成的 handoff

归档动作：

1. 把 `_meta.yaml.status` 改为 `archived`
2. 设置：
   - `archive.archived: true`
   - `archive.archived_at`
   - `archive.archive_reason`

### 6.6 归档目录

采用物理归档目录：

```text
openspec/
├── changes/
└── archive/
    └── <change-name>/
        ├── proposal.md
        ├── design.md
        ├── tasks.md
        └── _meta.yaml
```

归档时，整个 change 目录一起移动，不做 `_meta.yaml` 单文件清理。

### 6.7 清理策略

清理分两层：

#### 第一层：活跃目录清理

目标：减少扫描成本。

规则：

1. `openspec/changes/` 仅保留活跃 change
2. 完成后尽快移入 `openspec/archive/`

#### 第二层：历史归档清理

目标：减少长期冗余。

规则：

1. 最近 2 个迭代的归档保留完整
2. 更老归档按版本周期清理
3. 清理前必须保证 Git 历史可追溯

### 6.8 `max-inbox` 和 handoff 的清理

与 change 关联的 handoff 文件也要跟随清理。

建议：

1. change 归档时，相关 handoff 目录一起移动到对应 archive 子目录
2. `max-inbox` 中已经处理完的 sync request 移到：
   - `shared/handoff/archive/max-inbox/<change>/`

否则活跃目录会持续膨胀。

---

## 7. 目录结构 v4

```text
agent-group/
├── .claude/
│   └── skills/
├── openspec/
│   ├── changes/
│   ├── archive/
│   └── config.yaml
├── max/
├── ella/
├── jarvis-fe/
├── jarvis-be/
├── jarvis/                          # 兼容入口，标记弃用
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

说明：

1. v4 仍然不先迁 `openspec` 物理目录
2. 新增 `shared/handoff/max-inbox/`
3. 新增 `openspec/archive/`
4. 新增 `shared/handoff/archive/`

---

## 8. 角色启动检查顺序

所有角色启动后统一按以下顺序检查：

### 8.1 Max

1. 扫描 `openspec/changes/*/_meta.yaml`
2. 扫描 `shared/handoff/max-inbox/`
3. 处理待固化的 Cross-Tag
4. 再决定是否修改 `tasks.md / design.md`

### 8.2 Ella

1. 扫描 `openspec/changes/*/proposal.md`
2. 扫描 `design.md` 中待补充部分
3. 输出设计交付到 `ella-to-jarvis/`

### 8.3 Jarvis-FE / Jarvis-BE

1. 读取 `tasks.md`
2. 读取 `_meta.yaml`
3. 读取与自己相关的 handoff
4. 如发现边界缺口，创建 Cross-Tag
5. 如发现会影响验收范围，发起 sync request 给 Max

### 8.4 Kyle

1. 扫描 `_meta.yaml.review_status`
2. 读取 `jarvis-to-kyle/`
3. 回到 `tasks.md` 做审查

---

## 9. CLAUDE.md 的推荐写法

### 9.1 通用第一性约束

```markdown
# 第一性约束

1. 只根据实际读取到的代码、文件、命令结果回答。
2. 不编造接口、路径、配置、错误信息。
3. 信息不足时先说明缺口，再说明如何获取，不做推测性结论。
4. 涉及结论必须可验证。
```

### 9.2 Max 必须补充的规则

```markdown
## Cross-Tag 固化规则

当 `shared/handoff/max-inbox/` 中存在 sync request 时，必须先处理：

1. 判断是否需要固化到 `tasks.md`
2. 判断是否需要固化到 `design.md`
3. 更新对应 change 的 `_meta.yaml.pending_syncs`

不得长期保留 pending 的 sync request 不处理。
```

### 9.3 Jarvis-FE / Jarvis-BE 必须补充的规则

```markdown
## Cross-Tag 发起规则

当发现正式任务边界不足以支持实现时：

1. 创建 Cross-Tag
2. 如果该问题影响验收范围或新增正式交付项，必须同步创建给 Max 的 sync request
3. 不得把 Cross-Tag 当作长期正式任务替代
```

### 9.4 Kyle 必须补充的规则

```markdown
## 审查依据

1. 以 `tasks.md` 验收标准为主
2. 以 `jarvis-to-kyle` 提审单为范围补充
3. Cross-Tag 仅作为协作背景，不直接替代正式验收标准
```

---

## 10. 迁移规划

前版最大的问题是“有阶段，没有实施计划细节”。本版补齐。

### Phase 0：准备期

目标：

1. 不改线上协作方式
2. 先把结构准备好

动作：

1. 建立 `jarvis-fe/` 和 `jarvis-be/`
2. 建立 `shared/handoff/max-inbox/`
3. 建立 `openspec/archive/`
4. 建立 `shared/handoff/archive/`
5. 抽离 `shared/protocols/mandatory-flow.md`

交付物：

1. 新目录结构
2. 新模板文件
3. 各角色 CLAUDE 草案

验收标准：

1. 不影响现有流程
2. 目录可访问
3. 模板可用

### Phase 1：角色拆分上线

目标：

1. 把全栈 Jarvis 拆成 FE / BE
2. 不引入 Cross-Tag 固化闭环
3. 先让基本开发链路跑通

动作：

1. `jarvis` 标记弃用
2. `jarvis-fe` 与 `jarvis-be` 分别接管前后端
3. 更新各自 `CLAUDE.md`
4. 先按现有 `tasks.md` 执行

交付物：

1. `jarvis-fe/CLAUDE.md`
2. `jarvis-be/CLAUDE.md`
3. 技能目录拆分

验收标准：

1. 单个需求可由 FE / BE 分别执行
2. 没有因为角色拆分导致任务丢失

### Phase 2：引入 `_meta.yaml`

目标：

1. 建立统一状态层
2. 降低对 `status.json` 的依赖

动作：

1. 新建 change 时自动带 `_meta.yaml`
2. 各角色按权限更新相关字段
3. `status.json` 开始降级为聚合视图

交付物：

1. `_meta.yaml` 模板
2. 状态字段约定
3. 角色更新规则

验收标准：

1. change 能通过 `_meta.yaml` 看出当前阶段
2. 不需要查多个文件才能知道是否待审

### Phase 3：引入 Cross-Tag + Max 固化闭环

目标：

1. 允许 FE / BE 补充边界
2. 让补充内容能够正式进入任务体系

动作：

1. 建 `fe-to-be/`、`be-to-fe/`
2. 建 `max-inbox/`
3. Cross-Tag 创建后同步发起 sync request
4. Max 处理 sync request，并更新 `tasks.md / design.md / _meta.yaml`

交付物：

1. Cross-Tag 模板
2. Sync Request 模板
3. 固化决策流程

验收标准：

1. 至少一个联动需求完成“发现缺口 -> 提交协商 -> Max 固化 -> 正式执行”的闭环
2. 没有长期悬挂的 pending sync

### Phase 4：引入统一提审和联合审查

目标：

1. 让 Kyle 基于统一 change 审查
2. 让 FE / BE 联动改动能一起验收

动作：

1. 规范 `jarvis-to-kyle/`
2. 规范 `kyle-to-jarvis/`
3. `_meta.yaml.review_status` 作为待审入口

交付物：

1. 提审单模板
2. 反馈单模板
3. 审查状态流转规则

验收标准：

1. Kyle 能从一个 change 看到完整审查上下文
2. FE / BE 联动改动不再拆成多个彼此无关的审查入口

### Phase 5：归档与性能优化

目标：

1. 解决扫描膨胀问题
2. 完成历史目录治理

动作：

1. 完成 `openspec/archive/` 归档机制
2. 完成 `shared/handoff/archive/` 归档机制
3. 对活跃 change 建立扫描约束

交付物：

1. 归档规则
2. 清理规则
3. 可选的活跃 change 索引文件

验收标准：

1. 活跃目录保持精简
2. 历史 change 可追溯
3. 启动扫描时间可控

---

## 11. 每阶段的回退策略

### Phase 1 回退

如果角色拆分不稳定：

1. 保留旧 `jarvis` 入口
2. 暂时回到单角色执行
3. 不删除新目录

### Phase 2 回退

如果 `_meta.yaml` 管理混乱：

1. 保留文件
2. 暂停依赖它作为主状态入口
3. 暂时回到 `status.json` 聚合状态

### Phase 3 回退

如果 Cross-Tag 大量堆积：

1. 暂停新建 Cross-Tag
2. 要求由 Max 直接修正 `tasks.md`
3. 清空未闭环的 pending sync

### Phase 4 回退

如果联合提审复杂度过高：

1. 保留统一 change
2. 先分前后端分批提审
3. Kyle 在反馈单中手工汇总

---

## 12. 建议的试点方式

不要全量切换。建议选一个中等复杂度需求试点，要求：

1. 同时有前端和后端改动
2. 存在接口协同
3. 一周内可以完成
4. 验收标准明确

试点必须验证 4 件事：

1. `jarvis-fe / jarvis-be` 是否能稳定分工
2. Cross-Tag 是否真的触发 Max 固化
3. `_meta.yaml` 是否足够表达状态而不过度膨胀
4. Kyle 是否能依据同一 change 做完整审查

---

## 13. 最终建议

v4 的核心不是加更多机制，而是把机制之间的关系定清楚：

1. **正式任务只认 `tasks.md`**
2. **Cross-Tag 只是协商输入，但必须有进入 `tasks.md` 的固化闭环**
3. **`_meta.yaml` 只做状态，不做第二套 spec**
4. **代码最终只由 `jarvis-fe / jarvis-be` 产出**
5. **迁移必须按 Phase 推进，每个阶段都要有验收标准和回退策略**

如果只做一件最关键的事，那就是：

> 先把 `Cross-Tag -> Max 固化 -> tasks.md 更新 -> Kyle 按 tasks 审查` 这条链路跑通。

这条链路一旦跑通，整个体系才真正闭环。
