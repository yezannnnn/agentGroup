# /notify-kyle - 通知凯尔

向凯尔发送通知（需用户确认）

## 使用方式
/notify-kyle [消息内容]

## 执行步骤

1. 先询问用户确认："确定要通知凯尔吗？"

2. 用户确认后，更新 `../shared/status.json`:
```json
{
  "notifications": [
    {
      "from": "jarvis",
      "to": "kyle",
      "type": "message|review_request|bug_report",
      "task": "任务名称",
      "files": ["相关文件"],
      "message": "消息内容",
      "timestamp": "ISO时间戳",
      "read": false
    }
  ],
  "current_task": "当前任务",
  "last_updated": "ISO时间戳"
}
```

3. 告知用户："已通知凯尔，请让他查看 /status"
