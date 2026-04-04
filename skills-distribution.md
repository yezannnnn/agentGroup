# aiGroup技能分发配置

> **声明**：本项目集成的技能包来自多个开源社区和SkillsMP技能市场，我们感谢所有原作者的贡献。所有技能均标注了来源、作者和许可证信息，请遵守相应的使用条款。

## 🎯 技能分配策略

### 👨‍💼 麦克斯 (Max) - 项目管理技能
**技能目录**: `max/skills/`

#### 📦 CCPM项目管理系统
- **路径**: `max/skills/ccpm/`
- **功能**: GitHub Issues集成、项目跟踪
- **使用**: `claude --project max → /skill ccpm-status`

#### 🎨 PM Claude技能集
- **路径**: `max/skills/pm-claude-skills/`
- **功能**: PRD生成、会议记录、需求分析
- **时间节省**: 8-9小时/周
- **使用**: `claude --project max → /skill generate-prd`

#### 🦸 Superpowers（新增）
- **适用场景**: 复杂多步骤项目协调自动化、跨工具批量操作、全局风险扫描
- **触发关键词**: "帮我做项目启动准备"、"扫描所有风险"、"全量同步团队状态"
- **使用**: `/skill superpowers`

#### 📦 Gstack（新增）
- **适用场景**: 技术选型建议、PRD技术可行性评估、架构方案对比报告
- **触发关键词**: "这个项目用什么技术栈"、"评估一下技术方案"、"PRD技术可行性"
- **使用**: `/skill gstack`

#### 📜 快速工具
- **路径**: `max/skills/max-skills.sh`
- **功能**: 交互式技能选择菜单
- **使用**: `./max/skills/max-skills.sh`

---

### 🎨 艾拉 (Ella) - 设计技能
**技能目录**: `ella/skills/`

#### 🖼️ 高级前端技能
- **路径**: `ella/skills/senior-frontend/`
- **功能**: UI/UX设计、前端开发指导
- **特长**: React/Vue组件设计、响应式布局
- **使用**: `claude --project ella → /skill ui-design`

#### 🦸 Superpowers
- **适用场景**: 完整设计系统一次性生成、多端适配批量输出、全局风格迁移
- **触发关键词**: "生成完整设计系统"、"多端适配设计"、"批量生成页面规范"
- **使用**: `/superpowers:[技能名称] `


---

### ⚡ 贾维斯 (Jarvis) - 开发技能
**技能目录**: `jarvis/skills/`

#### 🏗️ Claude Simone框架
- **路径**: `jarvis/skills/claude-simone/`
- **功能**: AI辅助开发项目管理
- **特长**: 开发流程优化、团队协作

#### 👥 工程团队技能集
- **路径**: `jarvis/skills/engineering-team/`
- **包含技能**:
  - senior-backend (后端开发)
  - senior-fullstack (全栈开发)
  - senior-architect (系统架构)
  - code-reviewer (代码审查)
  - senior-devops (运维部署)
  - tech-stack-evaluator (技术选型)
- **使用**: `claude --project jarvis → /skill code-review`

#### 🦸 Superpowers
- **适用场景**: 全栈功能链路一次性开发（前端+API+数据库）、项目脚手架搭建、大规模代码重构
- **触发关键词**: "帮我实现完整的XXX模块"、"搭建项目框架"、"5个以上文件同时修改"
- **使用**: `/superpowers:[技能名称] `

---

### 🔍 凯尔 (Kyle) - 测试技能
**技能目录**: `kyle/skills/`

#### 🧪 高级QA技能
- **路径**: `kyle/skills/senior-qa/`
- **功能**: 测试策略、质量保证、验收测试
- **特长**: 自动化测试、性能测试

#### 📋 TDD指导
- **路径**: `kyle/skills/tdd-guide/`
- **功能**: 测试驱动开发指导
- **特长**: 单元测试、集成测试设计
- **使用**: `claude --project kyle → /skill tdd-testing`

#### 🦸 Superpowers（新增）
- **适用场景**: 完整测试套件批量生成（单元+集成+E2E）、整个PR全面审查、完整质量报告一次输出
- **触发关键词**: "帮我生成完整测试"、"全面审查这个PR"、"生成完整质量报告"
- **使用**: `/superpowers:[技能名称] `

---

## 🚀 使用方式

### 启动特定AI并使用技能
```bash
# 麦克斯项目管理
claude --project max
/skills list
/skill project-status
/skill superpowers   # 复杂协调任务
/skill gstack        # 技术方案评估

# 艾拉UI设计
claude --project ella
/skills list
/skill ui-design
/skill superpowers   # 批量设计资产生成
/skill gstack        # 前端技术边界咨询

# 贾维斯开发
claude --project jarvis
/skills list
/skill code-review
/skill superpowers   # 全栈功能一次性开发
/skill gstack        # 技术选型决策

# 凯尔测试
claude --project kyle
/skills list
/skill qa-testing
/skill superpowers   # 完整测试套件生成
/skill gstack        # 测试框架选型
```

---

## 📊 技能分配统计

| AI成员 | 原有技能                   | 新增技能             | 主要领域           | 预期效益             |
| ------ | -------------------------- | -------------------- | ------------------ | -------------------- |
| 麦克斯 | CCPM + PM技能集            | superpowers + gstack | 项目管理、产品规划 | 复杂协调任务自动化   |
| 艾拉   | senior-frontend            | superpowers + gstack | UI/UX设计          | 批量设计资产生成     |
| 贾维斯 | 工程技能集 + claude-simone | superpowers + gstack | 全栈开发           | 全链路功能一次交付   |
| 凯尔   | senior-qa + tdd-guide      | superpowers + gstack | 质量保证           | 完整测试套件自动生成 |

---

## 🗺️ Superpowers vs Gstack 使用场景速查

| 情况                 | 应用技能    | 应由谁使用    |
| -------------------- | ----------- | ------------- |
| 项目启动需要完整规划 | superpowers | 麦克斯        |
| 需要选择项目技术栈   | gstack      | 麦克斯/贾维斯 |
| 多文件功能开发       | superpowers | 贾维斯        |
| 框架对比决策         | gstack      | 贾维斯        |
| 批量设计组件生成     | superpowers | 艾拉          |
| 了解前端能力边界     | gstack      | 艾拉          |
| 生成完整测试套件     | superpowers | 凯尔          |
| 测试框架选型         | gstack      | 凯尔          |

---

## 📝 技能来源与引用

### 麦克斯技能来源
- **CCPM项目管理系统**
  - 来源：[automazeio/ccpm](https://github.com/automazeio/ccpm)
  - 作者：automaze.io
  - 许可证：MIT License

- **PM Claude技能集**
  - 来源：[mohitagw15856/pm-claude-skills](https://github.com/mohitagw15856/pm-claude-skills)
  - 作者：mohitagw15856
  - 许可证：MIT License

- **Superpowers**
  - 来源：用户配置集成
  - 使用场景：复杂多步骤自动化任务

- **Gstack**
  - 来源：用户配置集成
  - 使用场景：技术栈评估与选型

### 艾拉技能来源
- **Senior Frontend技能包**
  - 来源：SkillsMP技能市场 - 前端开发专家技能包
  - 作者：aiGroup团队定制
  - 许可证：MIT License

- **Superpowers / Gstack**
  - 来源：用户配置集成

### 贾维斯技能来源
- **Claude Simone框架**
  - 来源：[Helmi/claude-simone](https://github.com/Helmi/claude-simone)
  - 作者：Helmi
  - 许可证：查看原仓库

- **工程团队技能集**
  - 来源：[alirezarezvani/claude-skills/engineering-team](https://github.com/alirezarezvani/claude-skills/engineering-team)
  - 作者：alirezarezvani
  - 许可证：查看原仓库

- **Superpowers / Gstack**
  - 来源：用户配置集成

### 凯尔技能来源
- **Senior QA技能包**
  - 来源：SkillsMP技能市场 - 高级QA工程师技能包
  - 作者：aiGroup团队定制
  - 许可证：MIT License

- **TDD指导技能包**
  - 来源：SkillsMP技能市场 - TDD测试驱动开发指南
  - 作者：aiGroup团队定制
  - 许可证：MIT License

- **Superpowers / Gstack**
  - 来源：用户配置集成

---

## 🔧 维护说明

- 各AI的技能独立管理，不会相互干扰
- 技能更新只影响对应AI
- 可以独立为每个AI添加新技能
- 符合职责边界原则
- 所有技能均标注了来源和许可证信息

## ⚠️ 注意事项

- 技能仅在对应AI项目中可用
- 跨AI使用技能需要切换项目
- 确保技能与AI职责匹配
- 定期更新和维护技能库
- 遵守各技能的许可证要求
- 引用外部技能时保持来源标注
