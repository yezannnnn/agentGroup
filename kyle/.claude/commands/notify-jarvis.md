# /notify-jarvis - 通知贾维斯

向贾维斯发送通知（需用户确认）

## 使用方式
/notify-jarvis [消息内容]

## 执行步骤

1. 先询问用户确认："确定要通知贾维斯吗？"

2. 用户确认后，更新 `../shared/status.json`:
```json
{
  "notifications": [
    {
      "from": "kyle",
      "to": "jarvis",
      "type": "review_result|bug_report|message",
      "task": "任务名称",
      "files": ["审查报告路径"],
      "message": "消息内容",
      "timestamp": "ISO时间戳",
      "read": false
    }
  ],
  "current_task": "当前任务",
  "last_updated": "ISO时间戳"
}
```

3. 告知用户："已通知贾维斯，请让他查看 /status"
