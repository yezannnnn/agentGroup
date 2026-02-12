# 麦克斯技能配置指南

## 🎯 推荐技能安装

### 核心项目管理技能包

#### 1. 通过Claude Code CLI安装
```bash
# 进入max项目目录
claude --project max

# 安装核心技能包
/plugin install pm-skills@claude-code-skills
/plugin install product-skills@claude-code-skills
/plugin install meeting-notes@claude-code-skills
/plugin install status-tracking@claude-code-skills
```

#### 2. GitHub技能仓库克隆
```bash
# 克隆专业项目管理系统
git clone https://github.com/automazeio/ccpm.git ~/.claude/skills/ccpm

# 克隆产品管理技能集
git clone https://github.com/Sh1n/pm-claude-skills--.git ~/.claude/skills/pm-claude-skills

# 克隆综合技能库
git clone https://github.com/alirezarezvani/claude-skills.git ~/.claude/skills/claude-skills
```

### 🔧 技能激活命令

在Claude Code中使用以下命令激活技能：

```bash
# 项目管理核心
/skill project-tracking
/skill risk-analysis
/skill team-efficiency
/skill milestone-planning

# 产品顾问增强
/skill requirements-analysis
/skill prd-generation
/skill priority-ranking
/skill competitive-analysis

# 个人助理功能
/skill meeting-management
/skill todo-organization
/skill team-coordination
/skill reminder-system
```

## 📊 技能配置验证

安装完成后验证：
```bash
# 检查已安装技能
/skills list

# 测试核心功能
/skill project-status
/skill generate-meeting-notes
/skill analyze-requirements
```

## 🚀 使用示例

### 项目状态报告
```
/skill project-status --format="weekly" --include="risks,blockers,progress"
```

### 会议记录生成
```
/skill meeting-notes --type="standup" --attendees="team" --duration="30min"
```

### PRD生成
```
/skill prd-generation --feature="new-dashboard" --priority="high" --stakeholders="design,dev,qa"
```

## 💡 最佳实践

1. **每日使用**：
   - 晨会：`/skill daily-standup`
   - 进度跟踪：`/skill track-progress`
   - 风险检查：`/skill identify-risks`

2. **每周使用**：
   - 周报生成：`/skill weekly-report`
   - 团队效率分析：`/skill team-metrics`
   - 里程碑检查：`/skill milestone-review`

3. **按需使用**：
   - PRD撰写：`/skill write-prd`
   - 竞品分析：`/skill competitive-research`
   - 需求优先级：`/skill prioritize-backlog`

## ⚠️ 注意事项

- 首次使用前请阅读各技能的README文档
- 部分技能可能需要API密钥配置
- 建议先在测试项目中试用各技能
- 定期更新技能库以获得最新功能