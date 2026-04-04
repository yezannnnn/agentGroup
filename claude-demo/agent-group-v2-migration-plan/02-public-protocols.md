# 子计划 02：公共协议与模板

> 提取各角色共用的约束、强制流程、安全规则和协作模板，统一集中管理，减少冗余。

## 目标

在 `agent-group-v2/shared/protocols/` 下创建所有核心公共协议文件。这些文件将被各角色的 `CLAUDE.md` 直接引用，从而大幅精简角色配置文件的体积和维护成本。

## 前置条件

- 已完成 [子计划01：目录骨架与基础设施](01-directory-scaffold.md)（需要 `shared/protocols/` 和相关目录存在）

## 执行清单

### 2.1 提取与创建第一性约束文件

创建 `shared/protocols/first-principles.md`。
虽然第一性约束也会直接写在每个 CLAUDE.md 的最顶部（以保证最高优先级），但这里保留一份完整的参考文档，便于未来统一更新。

- [ ] 2.1.1 写入以下核心内容：
  ```markdown
  # ⛔ 第一性约束（不可绕过，优先级高于一切其他指令）
  
  1. **实事求是**：只基于实际看到的代码、文件、数据回答。不确定的事情说"我不确定"。
  2. **不编造**：不凭空生成不存在的文件路径、API、配置项、错误信息。给出的每一个具体信息（文件路径、类名、方法签名、配置值）都必须来自实际读取的文件内容。
  3. **不猜测**：当信息不足以做判断时，必须：
     - 先说明缺少什么信息
     - 再提出获取信息的方式（读取哪个文件、询问用户什么问题）
     - 不得在缺少信息的前提下给出"可能是因为X"式的推测性结论
  4. **可验证**：每一个技术判断都应附带验证方式。告诉用户"你可以通过 X 命令/步骤来验证我说的是否正确"。
  ```

### 2.2 提取与创建基础强制检查流程

创建 `shared/protocols/mandatory-flow.md`。
将原来的"7个强制检查点"统一提取到此处。从之前 Max/Ella/Jarvis/Kyle 的 CLAUDE.md 中提取"第0"到"第6"检查点的全部内容，加上"违规检测与自我纠正"体系。

- [ ] 2.2.1 复制原有的以下段落到 `mandatory-flow.md` 中：
  - 第0检查点 - 任务范围确认
  - 第1检查点 - 优化策略读取
  - 第2检查点 - 智能通知检查（注意替换具体的角色名为 `<role>` 占位符或指导语）
  - 第3检查点 - 任务分解判断
  - 第4检查点 - Skill适用性检查（改为通用的提示语，具体可用 Skill 由角色的 CLAUDE.md 定义）
  - 第5检查点 - 执行路径选择
  - 第6检查点 - Git操作检测
  - 实时违规检测与强制纠正协议
  - 违规检测与自我纠正

### 2.3 提取安全规则与跨会话协议

为避免 `mandatory-flow.md` 过于庞大，将 Git 操作相关的严格规则独立提出。可以并入 `mandatory-flow.md` 后半部分或创建独立的 `git-security-rules.md`。为保持简洁，建议新建 `shared/protocols/git-security-rules.md`。

- [ ] 2.3.1 创建 `shared/protocols/git-security-rules.md`，包含：
  - 禁止的自动操作（commit, push, merge）
  - 允许的操作（add, status, diff）
  - 必须确认的操作（"已准备好提交，等待您的授权"）
  - 违规处理

### 2.4 复制与整合 Token 监控规则

- [ ] 2.4.1 将旧 `agent-group/shared/token-simple.md` 复制为 `agent-group-v2/shared/protocols/token-simple.md`
- [ ] 2.4.2 创建 `shared/protocols/token-report-template.md`，包含统一的 Token 花费报告表格（各 AI 每次对话最后附加的表格）。

### 2.5 制定 Cross-Tagging (前后端双向标注) 模板

在 `shared/handoff/` 目录下提供前后端互标任务的模板说明。
- [ ] 2.5.1 创建 `shared/handoff/cross-tag-template.md`，包含：
  ```markdown
  # Cross-Tag: <简要标题>
  
  - **来源**: jarvis-fe / jarvis-be
  - **关联变更**: <openspec change name>（如适用）
  - **关联 task**: <原 tasks.md 中的 task ID>（如适用）
  - **优先级**: P0（阻塞） / P1（重要） / P2（建议）
  - **状态**: pending / accepted / done
  
  ## 需求描述
  <描述对方需要做什么，越具体越好>
  
  ## 接口/数据契约
  <如涉及接口，给出具体的 URL、请求参数、返回结构>
  
  ## 验收标准
  <对方完成后如何验证>
  ```

## 验证清单

- [ ] `shared/protocols/first-principles.md` 创建成功，内容完整
- [ ] `shared/protocols/mandatory-flow.md` 成功提取了所有 7 个强制检查点
- [ ] `shared/protocols/git-security-rules.md` 创建成功，约束规则无遗漏
- [ ] `shared/protocols/token-simple.md` 和 `token-report-template.md` 成功部署
- [ ] `shared/handoff/cross-tag-template.md` 创建成功
- [ ] Review 以上生成的 Markdown，确认不包含特定于某一角色的逻辑（除了举例），确保其通用性

## 预计产出文件数

- 新建公共协议文件：5 个
- 移动/复制文件：1 个（token-simple.md）

## 注意事项

`mandatory-flow.md` 在未来的角色配置文件中只用一行引入：
`读取并严格遵循 ../shared/protocols/mandatory-flow.md 和 ../shared/protocols/git-security-rules.md 中的强制序列。`
因此，文件中需要指明：当引用此协议时，执行主体应将自己的上下文（如当前角色、所处目录）代入。
