# 子计划 09：Openspec 配置及内容迁移

> 正式将项目原本的独立 `openspec` 纳入 `agent-group-v2/shared/specs/openspec/` 作为统一协作底座规范。

## 目标

迁移原项目 `agent-group/openspec/` 目录结构，并更新 openspec 自身的 `config.yaml` 使得其符合拆分后的四系团队流转特性。

## 前置条件

- 已完成 [子计划01：目录骨架与基础设施](01-directory-scaffold.md)

## 执行清单

### 9.1 更新 config.yaml 基本约束

修改 `shared/specs/openspec/config.yaml` ，在 context 和 rules 里面补加明确针对前端、后端的职责指向和跨界任务分解指示：

- [ ] 9.1.1 将内容改写为：
  ```yaml
  schema: spec-driven
  
  context: |
    语言：中文（简体）
    所有产出物必须用简体中文撰写。
    
    项目结构：
    - 后端: cloud-backend (Java/Spring Boot)
    - 前端: cloud-frontend (React 18/TypeScript/Ant Design 6/Wujie 微前端)
    
    团队角色：
    - Max: 项目经理，负责创建和管理 openspec 提案
    - Ella: UI/UX 设计师，负责补充 design.md 的 UI 部分
    - Jarvis-FE: 前端开发，执行 tasks.md 中的前端任务
    - Jarvis-BE: 后端开发，执行 tasks.md 中的后端任务
    - Kyle: QA 工程师，基于 tasks.md 验收标准做审查代码
  
  rules:
    proposal:
      - 需求描述必须明确，不允许模糊表述。
      - 必须包含严密的"验收标准"章节。
    design:
      - 技术设计部分区分前端和后端交互逻辑。
      - 当出现 UI/UX 的诉求时，要在文件的显眼处直接标注 [待 Ella 补充视觉]
    tasks:
      - 明确界定：任务必须分配归属到 jarvis-fe 还是 jarvis-be 头上。如果是纯混合难以分担的需求应当标记交由前端与后端双方后续内部沟通(利用 Cross-Tag)。
      - 每个 task 项必须包含详细但可被验收的条目，这是留给日后 Kyle 用来质检和核销的命脉。
      - 推荐保持一个拆单的最小周期为 15~30 分钟即可产出的代码颗粒度。
  ```

### 9.2 转移已有的需求变更源文件

原本可能已经进行过了几次历史 openspec 命令的生成，必须将其数据完整迁移。

- [ ] 9.2.1 完整并原封不动地剪切或复制 `agent-group/openspec/changes/` 下辖的所有业务与需求目录及附属文件，搬迁放入到 `agent-group-v2/shared/specs/openspec/changes/` 里面。
- [ ] 9.2.2 验证原本的 markdown 和需求目录层级在新路径里完全正常。

### 9.3 建立 Phase A：状态层（_meta.yaml）追踪

这是将传统 `notifications.json` 等轮询系统逐步引导到文档系统的基石操作。（在过渡期间使用双写，新版架构首推使用 `_meta`）

- [ ] 9.3.1 为现存的活跃的几个重要 `changes/<特定业务>` 文件内打入一个初始化的 `_meta.yaml` 进行测试，内容格式示范点：
  ```yaml
  change: the-current-change-name
  created_by: max
  created_at: 2026-04-XXTXX:XX:XXZ
  priority: P1
  status: in-progress          # proposed/in-progress/review/done/archived
  assigned_to:
    - role: jarvis-be
      tasks: [T1, T2]
      status: in-progress
  notify:                      # 谁应当优先关注此事件
    - jarvis-be
  ```
- [ ] 9.3.2 这个试点的文件日后通过 Max 创建的话需要默认通过新系统补入。这里仅仅作为手工预演铺垫。

## 验证清单

- [ ] `agent-group-v2/shared/specs/openspec/config.yaml` 已经被成功刷新，规则囊括入了 FE 与 BE 及四重角色的约束。
- [ ] 原来的所有的 changes 下的实际项目和过往的测试文档在新目录内全量出现。
- [ ] 确认没有散落在原目录树外的游离需求文件未能纳入此结构。

## 注意事项

通过这番改造，**openspec 成为了一切跨系统调度的单一真相来源表（SSOT）**。所有的任务发布者（不管有没有 AI 的辅助）写在这个区域内的约定，后续将被前端、后端、QA的执行流程一键作为强制最高指令吸入阅读。
