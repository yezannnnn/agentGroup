# AI 团队协作体系改造执行总计划 (基于 v5)

## 改造核心思想与最终定位
> **“角色清晰、事实源单一、协作可闭环、迁移可回退”**
> 不打断现有协作流程，在 v3 的稳健原则与 v4 的闭环概念基础上做最终收敛。
> 核心原则：正式任务只认 `tasks.md`，协商补充通过 Cross-Tag 发起并由 Max 固化，系统状态统一收敛到单个 `_meta.yaml`。最终代码由 `jarvis-fe / jarvis-be` 分端产出，不再由大一统角色负责，代码的统合审查（Kyle）按同一 change （而非单端提交）做一致性验收。

## 核心架构原则说明

### 1. 三层架构职责隔离
- **`openspec` 层**（管“做什么”）：完全聚焦于需求背景、设计约束、验收标准及拆解后的正式任务，作为第一事实源。
- **`superpowers` 层**（管“怎么推进流程”）：负责执行各阶段（拆分、开发、调试、提审、复审）的流转和状态监控。
- **自定义 `skills` 层**（管“怎么写代码”）：如针对项目定制的代码约束、技术栈偏好和特定的审查规范，仅作辅助不提供最终代码。

### 2. 代码产出唯一责任制
- 任何需求拆解后的代码落地最终只由专门的开发角色（`jarvis-fe`, `jarvis-be`）产出。`openspec`, `superpowers`, 或自定义 skill **绝不**直接越俎代庖去写代码。

### 3. 单一正式事实源（强约束）
在任何变更（Change）中：
- `proposal.md` 仅包含背景。
- `design.md` 仅包含宏观架构和 UI 设计。
- `tasks.md` 是**唯一**正规任务分配和验收标准的载体！
- `_meta.yaml` 只负责全局生命周期和状态挂载，杜绝长篇大论。
- 注意：如 `status.json`，`notifications.json`，和 `handoff/*` 等辅助目录，绝对不可充当正式任务系统的源。

## 角色协作关系图谱
以 `budget-export` 为例的完整协作链路：
1. **Max (产品/经理)**：接受新需求 -> 创建 `proposal.md` / `_meta.yaml` -> 结合设计生成具体的 `tasks.md`。负责处理开发端抛出的跨端缺口(Cross-Tag)合并回正式体系。
2. **Ella (设计)**：只修补 `design.md` 与生成素材，丢入 `ella-to-jarvis/` 给前端，不碰 `tasks.md` 与代码。
3. **Jarvis-FE (前端)** & **Jarvis-BE (后端)**：从 `tasks.md` 提取指定任务域。发现联调缺口互丢 `Cross-Tag` (需 Max 介入则创建 sync)。写完代码提交 `jarvis-to-kyle/`。
4. **Kyle (审查员)**：以 Change 宏观维度同时读取 `tasks.md` 及上方的提审书，判定代码合法性与任务达标率，并将结论输出给 `kyle-to-jarvis/`。

## 详细实施子计划清单
计划切分为严格的前后依赖阶段（Phase 0 ~ Phase 5），各阶段相互独立，方便灰度实施及执行回退策略。
详细动作指引、目录结构搭建和执行避坑参见各子文件：
* **[Phase 0: 准备期](./01_phase_0_preparation.md)** （基建目录建立与公共约束抽离）
* **[Phase 1: 角色拆分上线](./02_phase_1_role_split.md)** （由单一 Jarvis 切换为前端、后端独立开发模型）
* **[Phase 2: 引入状态层与聚合降级](./03_phase_2_meta_yaml.md)** （推广 `_meta.yaml` 与削弱 `status.json` 的主导权）
* **[Phase 3: Cross-Tag 闭环治理](./04_phase_3_cross_tag.md)** （跨端协商、依赖补报与 Max 强制固化流）
* **[Phase 4: 统一提审验收体系](./05_phase_4_unified_review.md)** （Kyle 基于 Change 的联合收审）
* **[Phase 5: 历史归档与检索性能治理](./06_phase_5_archive_and_perf.md)** （处理无限堆积的协作记录）
