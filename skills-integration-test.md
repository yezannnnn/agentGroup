# aiGroup技能集成测试

## 测试步骤

### 1. 启动各AI并测试技能
```bash
# 测试麦克斯技能
claude --project max
/skills list
/skill project-status

# 测试艾拉技能
claude --project ella
/skills list
/skill ui-design

# 测试贾维斯技能
claude --project jarvis
/skills list
/skill code-review

# 测试凯尔技能
claude --project kyle
/skills list
/skill test-automation
```

### 2. 快速启动脚本测试
```bash
# 使用麦克斯专用工具箱
~/.claude/skills/max-skills.sh
```

### 3. 验证技能可用性
- [ ] 技能命令响应正常
- [ ] 能够访问GitHub Integration
- [ ] PRD生成功能可用
- [ ] 会议记录处理正常

## 预期结果
所有技能应该在对应AI项目中正常可用，提供项目管理、设计、开发、测试的专业支持。