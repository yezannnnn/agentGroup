# Phase 2: `_meta.yaml` 全局主态管理与旧状视图降级

## 2.1 阶段目标
将所有参与者的精力聚拢在一个变更(Change)的最短快照（`_meta.yaml`）中，形成秒查全景链路。终结过往依赖多人散落式口头汇报进度的问题，并且对曾经处于核心地位容易形成冲突瓶颈的 `status.json` 等做看板化闲置降级。

## 2.2 `_meta.yaml` 的边界约束 (严禁过载)
必须杜绝将 `_meta.yaml` 变成另一套详尽的需求规格书或者第二套 `tasks.md`，所以有严格内容边界：
* **必须填的**：整体状态字串、分发角色各自处于哪个环节、以及关联进来的待决议事项(pending_syncs)。
* **绝对严禁填写的**：业务背景细节、接口协议报文、设计逻辑长文、详细每个 function 的任务拆解验收记录。

**建议标准的生命周期流转 (status 字段规范)**:
- `draft` (草稿) -> `ready` (就绪可以开发) -> `in-progress` (开发与处理中) -> `review` (进入统合审查区) -> `done` (开发完成上线) -> `archived` (归档)

## 2.3 `_meta.yaml` 标准模板与职责落入
以下是一个完整标准的落地参考样例，必须保证每个子层级的执行权明晰：

```yaml
change: budget-export         # Max填写
created_by: max               
created_at: 2026-04-04T09:00:00Z
updated_at: 2026-04-04T14:30:00Z  
priority: P1                  # Max维护
status: in-progress           # 【总体系统状态，仅 Max 有权更新及决策】
review_status: pending        # 【送审流的宏观状态，由 Kyle 更新结论或 Max 挂起】
roles:  # 【角色自维护区】各角色执行完自己阶段任务时主动修改
  max: active 
  ella: n/a                   # 表示该需求不涉设计
  jarvis-fe: in-progress      # FE 更新自己环节
  jarvis-be: pending          # BE 更新自己环节
  kyle: pending               
pending_syncs: # 【同步队列区】(见Phase 3, 需固化的Cross-Tag关联于此)
  - id: sync-001
    source: shared/handoff/fe-to-be/budget-export-api.md
    requested_by: jarvis-fe
    action: update_tasks
    status: pending           # 【Max处理标记】 pending 或 closed
review:
  request_file: null          # 记录具体的提审案卷索引路径
  feedback_file: null         # 记录反馈驳回的案件索引路径
archive:
  archived: false             # (见Phase 5, Max 主导修改)
  archived_at: null
  archive_reason: null
```

## 2.4 旧视图资源降级行动
- 对 `shared/status.json` 进行系统性认知剥离，在文档中声明其仅做全局扫描面板供管理员(人员)查阅全局，不做决策主权文件源头。
- 对 `notifications.json` 功能瘦身：只允许保留纯广播类通知(比如系统异常通告、临时维护事件)。开发任务委派和送审等节点动作的通知不再落入 `notifications.json`，因为这些已经在 `tasks.md/handoff/_meta.yaml` 中完全可被感知。

## 2.5 阶段启动检查顺序（按新模型执行测试）
- **Max** 首要扫描目标变为扫 `_meta.yaml` 统筹整体和 `max-inbox/` 检视阻塞。
- **Kyle** 首要扫 `_meta.yaml.review_status` 判断有没有活干，而不是在通知池里苦等。
- **FE/BE** 读 `tasks.md`，并通过 `_meta.yaml` 找寻合作方目前所在的进度标记。

## 2.6 回退策略 (Rollback)
如果发现多智能体并发导致 `_meta.yaml` 内容长期混乱不一致，则暂停以其作为协同基石，退回将 `status.json` 作为协同源泉供 AI 查询操作。
