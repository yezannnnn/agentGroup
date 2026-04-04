# AI 团队协作体系改造方案 v3

> 目标：在不打断现有协作的前提下，把 `agent-group` 从“角色堆叠 + 手工通知”收敛为“角色清晰 + 单一事实源 + 可渐进迁移”的体系。

---

## 0. v3 相比前版的调整原则

v3 保留前版的正确方向，但修正 4 个高风险点：

1. **不先迁移 openspec 物理目录**
   - v1/v2 里最激进的动作是把 `agent-group/openspec/` 迁到 `shared/specs/openspec/`
   - 这个动作依赖 CLI 路径解析和工具兼容性，验证成本高
   - v3 改为：**先保持 `agent-group/openspec/` 原位不动，只统一协作入口和引用方式**

2. **明确单一事实源**
   - `proposal.md / design.md / tasks.md` 是需求与验收的事实源
   - `handoff/` 是交付与协商事实源
   - `_meta.yaml` 仅做状态元数据，不承载需求正文，不替代 tasks

3. **Cross-Tag 降级为协商单，不直接成为正式任务**
   - 前后端互相标注很有价值
   - 但如果 Cross-Tag 直接等价于任务，会出现多个任务源
   - v3 规定：**Cross-Tag 是协商输入，不是正式任务清单**

4. **先做逻辑统一，再做物理迁移**
   - 先拆角色、统一协议、补 CLAUDE 规则、收敛共享目录
   - 等运行 1~2 个迭代稳定后，再决定是否迁移 openspec 目录

---

## 1. 设计目标

本方案解决 5 个问题：

1. `Jarvis` 角色过宽，前后端上下文混杂
2. `openspec` 没有真正进入角色工作流
3. `shared/` 目录缺少边界，产出物类型混杂
4. `superpowers` 与自定义 skill 的职责重叠
5. `status.json / notifications.json / 文档 / 人工口头同步` 多套信息源并存

非目标：

1. 不在 v3 中解决“完全自动化调度”
2. 不在 v3 中解决“硬权限隔离”
3. 不在 v3 中追求一步到位替换所有历史脚本与通知机制

---

## 2. 核心结论

### 2.1 角色层

保留统一的 `agent-group/` 仓库作为角色定义仓库，但把 `Jarvis` 明确拆成两个角色：

- `jarvis-fe`
- `jarvis-be`

不建议继续维持“一个全栈 Jarvis + 大量条件分支”的模式。原因很简单：

1. 前后端技能体系不同
2. 上下文噪声过大
3. 强制流程写在一个角色里，会让提示词持续膨胀

### 2.2 流程层

三层职责明确化：

1. **openspec 决定做什么**
   - 新需求
   - 设计约束
   - 任务拆分
   - 验收标准

2. **superpowers 决定怎么推进流程**
   - 方案拆解
   - 调试
   - 自查
   - 提审
   - 收审

3. **自定义 skill 决定怎么写代码**
   - 技术栈规范
   - 实现约束
   - 代码审查标准

### 2.3 数据层

v3 强制区分 3 类信息：

1. **规格信息**
   - 在 `openspec/changes/<change>/`
   - 包含 `proposal.md`、`design.md`、`tasks.md`

2. **交付/协商信息**
   - 在 `shared/handoff/`
   - 包含设计交付、提审单、审查反馈、前后端协商单

3. **状态信息**
   - 在 `openspec/changes/<change>/_meta.yaml`
   - 只记录状态，不记录需求正文

---

## 3. 单一事实源原则

这是 v3 的核心约束。

### 3.1 各类信息的唯一归属

| 信息类型     | 唯一事实源                                             | 说明                                |
| ------------ | ------------------------------------------------------ | ----------------------------------- |
| 需求背景     | `proposal.md`                                          | 不允许写到 `_meta.yaml`             |
| 技术设计     | `design.md`                                            | 不允许散落到 handoff 里成为正式设计 |
| 任务清单     | `tasks.md`                                             | 正式执行和验收以此为准              |
| 协商请求     | `shared/handoff/fe-to-be/`、`shared/handoff/be-to-fe/` | 不是正式任务                        |
| 提审请求     | `shared/handoff/jarvis-to-kyle/`                       | 审查入口                            |
| 审查反馈     | `shared/handoff/kyle-to-jarvis/`                       | 审查输出                            |
| 生命周期状态 | `_meta.yaml`                                           | 只做状态追踪                        |

### 3.2 关键约束

1. `tasks.md` 才是正式任务源
2. Cross-Tag 只能提出协商，不直接替代 `tasks.md`
3. Kyle 以 `tasks.md` 的验收标准为主，不以 Cross-Tag 自身作为验收标准
4. `_meta.yaml` 不能长成第二套 specs

---

## 4. 目录结构 v3

### 4.1 第一阶段推荐结构

```text
agent-group/
├── .claude/
│   ├── skills/
│   │   ├── openspec-propose/
│   │   ├── openspec-apply-change/
│   │   ├── openspec-explore/
│   │   └── openspec-archive-change/
│   └── settings.local.json
├── openspec/                      # 保持原位，不在 v3 第一阶段迁移
│   ├── changes/
│   └── config.yaml
├── max/
├── ella/
├── jarvis-fe/
├── jarvis-be/
├── jarvis/                        # 仅保留兼容入口，标记弃用
├── kyle/
└── shared/
    ├── handoff/
    │   ├── ella-to-jarvis/
    │   ├── jarvis-to-kyle/
    │   ├── kyle-to-jarvis/
    │   ├── fe-to-be/
    │   └── be-to-fe/
    ├── superpowers/
    │   ├── plans/
    │   ├── reviews/
    │   └── debug-logs/
    ├── protocols/
    │   └── mandatory-flow.md
    ├── status.json
    └── notifications.json
```

### 4.2 第二阶段才考虑的结构

如果后续验证通过，再考虑把：

- `agent-group/openspec/`

迁到：

- `agent-group/shared/specs/openspec/`

该动作不属于 v3 第一阶段默认动作。

---

## 5. 角色职责定义

### 5.1 Max

职责：

1. 接收新需求
2. 创建和维护 `openspec change`
3. 维护 `tasks.md` 为正式任务清单
4. 处理 Cross-Tag 升格为正式任务的决策
5. 维护整体状态视图

不负责：

1. 具体编码
2. 代替 FE/BE 进行细节协商
3. 代替 Kyle 做审查

### 5.2 Ella

职责：

1. 补充设计稿
2. 补充 `design.md` 的 UI/UX 部分
3. 通过 `ella-to-jarvis/` 向开发角色交付设计材料

不负责：

1. 改写 `proposal.md`
2. 接管 `tasks.md`
3. 具体编码

### 5.3 Jarvis-FE

职责：

1. 负责前端实现
2. 依据 `tasks.md` 执行前端任务
3. 读取设计交付
4. 在需要后端配合时创建 `fe-to-be` 协商单
5. 提交待审材料给 Kyle

### 5.4 Jarvis-BE

职责：

1. 负责后端实现
2. 依据 `tasks.md` 执行后端任务
3. 在需要前端配合时创建 `be-to-fe` 协商单
4. 提交待审材料给 Kyle

### 5.5 Kyle

职责：

1. 依据 `tasks.md` 的验收标准审查
2. 读取 `jarvis-to-kyle` 提审单
3. 输出 `kyle-to-jarvis` 反馈
4. 更新审查结果状态

不负责：

1. 替 Max 维护正式任务清单
2. 以 Cross-Tag 作为唯一验收依据
3. 具体编码

---

## 6. 角色启动与工程定位

### 6.1 结论

角色定义继续统一放在 `agent-group/`，但工作目录位于对应工程。

推荐目标：

```bash
cd cloud-frontend
claude --project ../agent-group/jarvis-fe

cd cloud-backend
claude --project ../agent-group/jarvis-be
```

### 6.2 风险说明

这依赖 Claude Code 对 `--project` 的路径解析能力。v3 不把这件事当既成事实，而是做两套方案：

#### 方案 A：优先方案

直接使用：

```bash
claude --project ../agent-group/jarvis-fe
claude --project ../agent-group/jarvis-be
```

#### 方案 B：兼容方案

若 A 不稳定，则在 `cloud-frontend/.claude/` 与 `cloud-backend/.claude/` 下放本地入口文件，再引用 `agent-group` 中的角色规范。

v3 要求先验证，再批量推广。

---

## 7. CLAUDE.md 结构规范

### 7.1 通用头部

每个角色的 `CLAUDE.md` 顶部都放统一的第一性约束：

```markdown
# 第一性约束

1. 只基于实际读取到的代码、文件、命令结果回答。
2. 不编造路径、接口、配置、错误信息。
3. 信息不足时先说明缺口，再说明获取方式，不做推测性结论。
4. 每个关键判断都提供可验证方式。
```

### 7.2 通用结构

每个角色的 `CLAUDE.md` 建议固定为 6 段：

1. 第一性约束
2. 角色身份
3. 任务入口规则
4. 技能使用规则
5. shared / openspec 读写契约
6. 项目上下文获取方式

### 7.3 公共强制流程抽离

各角色不要重复粘贴长篇强制流程。统一抽到：

- `shared/protocols/mandatory-flow.md`

角色内只保留一句：

```markdown
读取并遵循 `../shared/protocols/mandatory-flow.md`
```

这样可以减少提示词体积和维护成本。

---

## 8. Skill 分层规则

### 8.1 openspec 的职责

适用场景：

1. 新需求
2. 中大型改动
3. 需要明确验收标准的功能开发

输出：

1. `proposal.md`
2. `design.md`
3. `tasks.md`
4. `_meta.yaml`

### 8.2 superpowers 的职责

适用场景：

1. 任务拆解
2. 调试
3. 提审准备
4. 审查意见处理

输出目录：

- `shared/superpowers/plans/`
- `shared/superpowers/reviews/`
- `shared/superpowers/debug-logs/`

### 8.3 自定义 skill 的职责

适用场景：

1. 技术栈规范
2. 代码实现
3. 代码审查标准

### 8.4 冲突优先级

优先级从高到低：

1. `tasks.md` 的验收标准
2. 强制流程协议
3. 自定义 skill 的技术规范
4. 角色性格或表达层说明

---

## 9. `_meta.yaml` 设计

### 9.1 作用范围

`_meta.yaml` 只做状态层，不做内容层。

允许承载：

1. change 名称
2. 创建时间
3. 优先级
4. 总体状态
5. 分角色状态
6. 提审状态

不允许承载：

1. 需求正文
2. 接口详细设计
3. 任务说明
4. 验收标准

### 9.2 推荐格式

```yaml
change: budget-export
created_by: max
created_at: 2026-04-04T09:00:00Z
priority: P1
status: in-progress
review_status: pending
roles:
  jarvis-fe: in-progress
  jarvis-be: pending
  kyle: pending
handoff:
  design: shared/handoff/ella-to-jarvis/budget-export/
  review_request: null
```

### 9.3 状态机

建议只保留少量状态，避免复杂化：

- `draft`
- `in-progress`
- `review`
- `done`
- `archived`

不要把 `_meta.yaml` 做成一个复杂工作流引擎。

---

## 10. Cross-Tag 协商机制

### 10.1 定位

Cross-Tag 是协商机制，不是任务源。

它解决的问题是：

1. 前端最先发现接口缺口
2. 后端最先发现数据结构变更
3. Max 不可能在一开始把所有边界拆到完美

它不解决的问题是：

1. 正式任务编排
2. 最终验收规则定义

### 10.2 目录

```text
shared/handoff/
├── fe-to-be/
└── be-to-fe/
```

### 10.3 协议

Cross-Tag 文件创建后，允许 3 种处理结果：

1. **直接处理**
   - 对方接受并执行
   - 适用于小范围补充，不改变正式验收边界

2. **回填 tasks**
   - Max 将其升格为 `tasks.md` 的正式任务项
   - 适用于影响验收范围、工作量明显增加、涉及多方依赖

3. **拒绝或澄清**
   - 信息不完整
   - 边界不合理
   - 与现有设计冲突

### 10.4 升格规则

出现以下任一条件时，Cross-Tag 必须由 Max 回填到 `tasks.md`：

1. 影响验收标准
2. 新增接口或字段会影响多个页面/模块
3. 工作量超过半天
4. 需要 Kyle 在最终审查中显式关注

---

## 11. 读写契约

### 11.1 原则

读写契约是提示词约束，不是硬权限。

它的作用：

1. 明确协作边界
2. 降低误写概率
3. 帮助角色聚焦

它不能保证：

1. 绝对禁止访问
2. 完整替代工具层权限控制

### 11.2 推荐约定

| 角色      | 可读                                                                                                          | 可写                                                                                  |
| --------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Max       | `openspec/**`, `shared/handoff/**`, `shared/status.json`, `shared/notifications.json`                         | `openspec/**`, `shared/status.json`                                                   |
| Ella      | `openspec/changes/*/proposal.md`, `openspec/changes/*/design.md`                                              | `shared/handoff/ella-to-jarvis/`, `openspec/changes/*/design.md`                      |
| Jarvis-FE | `openspec/**`, `shared/handoff/ella-to-jarvis/`, `shared/handoff/kyle-to-jarvis/`, `shared/handoff/be-to-fe/` | `shared/handoff/fe-to-be/`, `shared/handoff/jarvis-to-kyle/`, `shared/superpowers/**` |
| Jarvis-BE | `openspec/**`, `shared/handoff/kyle-to-jarvis/`, `shared/handoff/fe-to-be/`                                   | `shared/handoff/be-to-fe/`, `shared/handoff/jarvis-to-kyle/`, `shared/superpowers/**` |
| Kyle      | `openspec/**`, `shared/handoff/jarvis-to-kyle/`, `shared/handoff/fe-to-be/`, `shared/handoff/be-to-fe/`       | `shared/handoff/kyle-to-jarvis/`, `shared/superpowers/reviews/`                       |

---

## 12. 审查机制

### 12.1 审查输入

Kyle 的审查输入必须包含两类内容：

1. `tasks.md` 中对应任务与验收标准
2. `jarvis-to-kyle/<change>.md` 提审单

必要时再读取：

1. 相关 Cross-Tag
2. 设计交付
3. 自查报告

### 12.2 审查输出

Kyle 输出到：

- `shared/handoff/kyle-to-jarvis/<change>.md`

内容至少包括：

1. 审查范围
2. 问题清单
3. 阻塞项 / 非阻塞项
4. 建议回归验证项

### 12.3 联合提审

一个功能同时涉及 FE / BE 时：

1. 允许双方分别开发
2. 但在提审时尽量汇总为一个 change 的统一提审入口
3. Kyle 以同一 change 为最小审查单元

---

## 13. `status.json` 与 `notifications.json` 的处理

### 13.1 v3 立场

不建议第一阶段直接删除它们。

### 13.2 处理方式

#### `status.json`

保留，但降级为聚合看板，不再作为一线事实源。

#### `notifications.json`

保留，但只保留两类：

1. 日常通知
2. 临时紧急事件

不再新增：

1. 正常任务分配通知
2. 正常提审通知

这些信息改由：

1. `tasks.md`
2. `handoff/`
3. `_meta.yaml`

承载。

---

## 14. 落地步骤

### Phase 1：角色与协议收敛

目标：先让体系跑起来，不动核心工具路径。

步骤：

1. 新增 `jarvis-fe/` 与 `jarvis-be/`
2. 保留 `jarvis/`，但标记弃用
3. 在 `shared/` 下建立 `handoff/`、`superpowers/`、`protocols/`
4. 抽离公共强制流程到 `shared/protocols/mandatory-flow.md`
5. 给所有角色补统一的第一性约束

完成标准：

1. 新老角色入口并存
2. 不改 `openspec` 物理位置
3. 至少有一条任务能走通“提案 -> 开发 -> 提审 -> 审查”

### Phase 2：引入状态层

目标：让状态信息从散乱脚本转到 change 目录下。

步骤：

1. 为新建 change 增加 `_meta.yaml`
2. 角色启动时优先读取 change 目录和 handoff
3. `status.json` 仅保留汇总用途

完成标准：

1. 新增任务不再依赖 `notifications.json` 发正常分配消息
2. Kyle 可通过 `_meta.yaml + handoff` 找到待审 change

### Phase 3：引入 Cross-Tag 协商机制

目标：让 FE / BE 联动不再依赖 Max 完美拆分。

步骤：

1. 建立 `fe-to-be/` 与 `be-to-fe/`
2. 发布 Cross-Tag 模板
3. 明确“何时直接处理，何时必须回填 tasks”

完成标准：

1. 至少完成一个前后端联动需求的协商闭环
2. 没有出现 Cross-Tag 与 `tasks.md` 长期不一致

### Phase 4：评估是否迁移 openspec 目录

前提：

1. `--project` 方案稳定
2. openspec CLI 路径行为验证通过
3. 现有 change 流程至少稳定运行 1~2 个迭代

只有满足前提，才进入物理迁移评估。

---

## 15. 风险与对策

### 风险 1：`--project` 行为不稳定

对策：

1. 先做小范围验证
2. 准备工程本地 `.claude/` 兼容入口

### 风险 2：`_meta.yaml` 膨胀成第二套 spec

对策：

1. 只保留状态字段
2. 评审时禁止把需求正文写进 `_meta.yaml`

### 风险 3：Cross-Tag 变成影子任务系统

对策：

1. 明确它只是协商单
2. 需要正式纳管时回填 `tasks.md`

### 风险 4：CLAUDE.md 再次膨胀

对策：

1. 公共协议抽离
2. 各角色只保留本角色差异规则

### 风险 5：用户以为“读写契约 = 权限控制”

对策：

1. 文档中明确说明它只是约束，不是隔离
2. 若要硬限制，后续补工具层方案

---

## 16. 最终建议

v3 的实施建议只有三条：

1. **先拆角色，不先迁 openspec**
2. **先确定单一事实源，再引入协商机制**
3. **先让一个最小闭环跑通，再扩到所有角色**

具体来说，最先落地的不是“目录重构”，而是下面 4 件事：

1. 建 `jarvis-fe / jarvis-be`
2. 抽公共强制流程
3. 给所有角色补统一第一性约束
4. 定义 `tasks.md / handoff / _meta.yaml` 的边界

只要这 4 件事做对，后面的物理迁移、通知替换、状态聚合都只是增量问题。

---

## 17. 建议的最小试点范围

不要一开始全量切换。建议用一个“有前后端联动、但范围可控”的需求试点。

试点标准：

1. 有明确页面改动
2. 有明确接口变更
3. 不跨多个大模块
4. 一周内可以完成

试点通过标准：

1. Max 能产出可执行的 `tasks.md`
2. FE / BE 能通过 Cross-Tag 完成一次协商
3. Kyle 能依据 `tasks.md` 完成一次联合审查
4. 没有因为多信息源导致结论冲突

达到这个标准，再进入下一步扩面。
