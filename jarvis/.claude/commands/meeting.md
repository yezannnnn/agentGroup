# /meeting - 记录会议

记录会议安排到 `../shared/tasks/meetings.md`

## 使用方式
/meeting [会议信息]

## 执行步骤

1. 解析会议信息，提取：
   - 时间
   - 类型/主题
   - 参与人（如有）
   - 地点/链接（如有）

2. 追加到 `../shared/tasks/meetings.md`，格式：
```markdown
## YYYY-MM-DD HH:mm - [会议主题]
- **类型**: xxx
- **参与人**: xxx
- **地点**: xxx
- **备注**: xxx
- **状态**: 待开
```

3. 确认记录并询问是否需要提醒
