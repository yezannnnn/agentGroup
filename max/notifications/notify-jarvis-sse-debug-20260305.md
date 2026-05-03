# 🐛 Bug排查通知 - 贾维斯 (Jarvis)

**来自**: Max (PM)  
**日期**: 2026-03-05  
**优先级**: P0 - 紧急  
**类型**: Bug排查

---

## 🎯 问题描述

**现象**: 登录人自己发送的消息，没有通过SSE推送到前端。

**测试步骤**:
1. 用户A在手机上发送消息给客服微信
2. 消息通过Webhook到达后端
3. **预期**: 前端应该收到SSE推送，显示这条消息
4. **实际**: 前端没有收到这条消息的SSE推送

**关键信息**:
- 收到的消息（别人发的）→ SSE推送正常 ✅
- 发出的消息（自己发的）→ SSE推送失败 ❌

---

## 🔍 后端代码分析

### Webhook处理逻辑 (`backend/routes/v1_webhook.py`)

```python
# 第157-165行：SSE推送代码
# 推送消息到前端（SSE）
try:
    from routes.v1_messages import sse_manager
    sse_manager.push_message(wx_account.tenant_id, {
        'type': 'new_message',
        'data': message.to_chat_dict()
    })
except Exception as e:
    current_app.logger.error(f"[WEBHOOK] 推送SSE失败: {e}")
```

**分析**:
- ✅ SSE推送代码在 `is_from_me` 判断之外
- ✅ 无论消息方向如何，都会执行推送
- ✅ 使用 `message.to_chat_dict()` 序列化消息

### 可能的原因

| 可能原因 | 排查方向 |
|---------|---------|
| **msg_id重复** | 自己发的消息msg_id可能在数据库已存在，导致唯一索引冲突 |
| **to_chat_dict()异常** | 消息对象序列化时出错 |
| **前端过滤** | 前端收到SSE但过滤掉了 `is_from_me=1` 的消息 |
| **tenant_id不匹配** | 推送的tenant_id和前端连接的不一致 |

---

## 📋 排查步骤

### 1. 后端日志排查

请在后端添加以下调试日志，然后测试：

```python
# 在 webhook 处理中添加日志

# 1. 保存消息前打印
print(f"[DEBUG] 准备保存消息: is_from_me={is_from_me}, msg_id={msg_id}")

# 2. 保存成功后打印  
print(f"[DEBUG] 消息已保存: id={message.id}")
print(f"[DEBUG] 消息to_chat_dict: {message.to_chat_dict()}")

# 3. SSE推送前打印
print(f"[DEBUG] 准备推送SSE: tenant_id={wx_account.tenant_id}")

# 4. SSE推送后打印
try:
    sse_manager.push_message(...)
    print(f"[DEBUG] SSE推送成功")
except Exception as e:
    print(f"[DEBUG] SSE推送失败: {e}")
```

### 2. 检查数据库唯一索引

查看 `messages` 表的唯一索引：
```sql
SHOW INDEX FROM messages;
```

如果是 `auth_key + msg_id` 的唯一索引，自己发的消息msg_id可能和之前收到的重复。

### 3. 前端排查

在 `vue-frontend/src/views/messages/index.vue` 的 `handleSSEMessage` 函数中添加日志：

```javascript
function handleSSEMessage(type, data) {
  console.log('[DEBUG] 收到SSE消息:', type, data)
  // ...
}
```

### 4. 检查过滤逻辑

前端是否有过滤 `is_from_me=1` 的逻辑？

---

## 📁 相关文件

| 文件 | 路径 |
|------|------|
| Webhook处理 | `backend/routes/v1_webhook.py` |
| 消息模型 | `backend/models/message_record.py` |
| 前端SSE处理 | `vue-frontend/src/views/messages/index.vue` |

---

## ✅ 修复要求

1. **添加调试日志**，复现问题
2. **定位根本原因**（msg_id重复 / 序列化异常 / 前端过滤）
3. **修复问题**
4. **验证修复**（自己发的消息能正常推送到前端）
5. **清理调试日志**（或改为合适的日志级别）

---

## 💡 可能的解决方案

### 如果是 msg_id 重复
```python
# 方案1: 修改唯一索引为 auth_key + msg_id + is_from_me
# 方案2: 自己发的消息使用不同的msg_id格式（如加前缀）
```

### 如果是前端过滤
```javascript
// 移除前端对 is_from_me 的过滤
```

### 如果是序列化异常
```python
# 检查 to_chat_dict() 方法
```

---

**请开始排查，找到根本原因后修复！**
