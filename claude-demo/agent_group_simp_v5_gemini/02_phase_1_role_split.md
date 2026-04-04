# Phase 1: 角色职责拆分与强读写契约上线

## 1.1 阶段目标
将长期承担全栈职能且职能臃肿边界模糊的 `jarvis` 彻底废弃，分为两套独立的单专业系统（`jarvis-fe` 和 `jarvis-be`）。彻底明确整个系统里 5 个主要角色的权责以及他们的软隔离（读权写权）界限。

## 1.2 角色职责重塑清单

### 1. Max（产品管理者）
- **核心职能**：接收需求、拟定 `openspec` 内的 `proposal.md`, 根据设计完成最终 `tasks.md` 分拆；拍板通过/拒绝合并底层开发向上拉起的“Cross-Tag Sync Request”。
- **绝对禁忌**：绝不写任何业务代码；绝不替开发者敲定接口协议的底层细节实现；绝不代替 Kyle 做代码合并验收。

### 2. Ella（UI设计者）
- **核心职能**：产出视觉、更新 `design.md`。并将素材交接到 `ella-to-jarvis/`。
- **绝对禁忌**：不干扰 `tasks.md` 排期；不碰业务代码库。

### 3. Jarvis-FE（前端执行者）
- **核心职能**：接收 `tasks.md` 中属于前端域的任务；读取 `ella-to-jarvis/` 设计稿产出前端工程代码；通过 `fe-to-be/` 发布与后端的协商议程；最终生成上报至 Kyle 的提审材料。
- **绝对禁忌**：不写后端代码；禁止绕开 Max 直接把自己的缺口补充改入 `tasks.md`，只能提申请；严禁越权给自己通过最终审查。

### 4. Jarvis-BE（后端执行者）
- **核心职能**：接收 `tasks.md` 中属于后端域的任务开发代码；通过 `be-to-fe/` 请求前端配合对接，并产出提交给 Kyle 的材料。
- **绝对禁忌**：不写前端代码；也不允许篡改全局任务树和提审通关。

### 5. Kyle（架构审查员）
- **核心职能**：依据 `tasks.md`（源头标准），读取前后的提审申请(`jarvis-to-kyle/xxx.md`)进行代码核验。将漏洞与缺陷落库给 `kyle-to-jarvis/yyy.md` 以打回。
- **绝对禁忌**：不替产品做需求和任务分发，不直接修改工程的业务代码和直接对 Cross-tag 结论定生死。

## 1.3 读写契约协议建立（协作约束非硬性阻断）
为防止跨域误操作并简化模型操作边界指引，建立如下访问指引并刷入新角色的 `CLAUDE.md` 内去规范行为：

| 角色角色 | 核心读取范围 (作为信息依据但无权修改) | 核心修改范围 (自身有权覆写生成的位置) |
| --- | --- | --- |
| **Max** | `openspec/**`, `handoff/**`, 所有 `.json` 状态表 | `openspec/**` (如 `tasks.md`, `_meta.yaml`), `status.json` |
| **Ella** | `openspec/changes/*/proposal.md`, `design.md` | `handoff/ella-to-jarvis/`, `openspec/changes/*/design.md` |
| **Jarvis-FE** | `openspec/**`(含设计与任务), 后端发来的 `handoff/be-to-fe/`, Kyle发来的 `kyle-to-jarvis/` | 发给后端的 `handoff/fe-to-be/`, 提交给总审的 `handoff/jarvis-to-kyle/`, `superpowers/**` (开发轨迹) |
| **Jarvis-BE** | `openspec/**`(含任务), `kyle-to-jarvis/`, `fe-to-be/` | `handoff/be-to-fe/`, `handoff/jarvis-to-kyle/`, `superpowers/**` |
| **Kyle** | `openspec/**`(特别是验收标准), 所有的交接池 `handoff/xxx-to-xxx` 和提审案卷 | 审查报告输出至 `handoff/kyle-to-jarvis/`, 打分表 `shared/superpowers/reviews/` |

## 1.4 回退策略 (Rollback)
如果角色剥离引发项目卡死（比如因为提示词不够长或者识别不准导致前端不管后端接口调用错误）：
- 先在原 `jarvis/` 角色移除弃用警告。
- 将任务临时导回交由一个全栈 agent 解决问题。
- 然后再行盘点 FE 与 BE 的接口约定。
