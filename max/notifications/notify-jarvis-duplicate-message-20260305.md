# 🐛 Bug修复通知 - 贾维斯 (Jarvis)

**来自**: Max (PM)  
**日期**: 2026-03-05  
**优先级**: P0 - 紧急  
**类型**: Bug修复

---

## 🎯 问题描述

**现象**: 用户自己发送的消息，SSE推送到前端时出现了**2次重复**。

**用户反馈**:
> "自己的消息sse推送了2次重复的"

**预期**:
- 发送1条消息 → 前端收到1次SSE推送 → 显示1条消息

**实际**:
- 发送1条消息 → 前端收到**2次**SSE推送 → 显示**2条重复**消息

---

## 🔍 可能原因

| 可能原因 | 说明 | 排查方向 |
|---------|------|---------|
| **1. Webhook重复推送** | 1238服务可能重复发送相同webhook | 检查msg_id是否重复收到 |
| **2. 唯一索引失效** | 消息被插入了2次到数据库 | 检查数据库是否有重复记录 |
| **3. SSE重复推送** | 代码中调用了2次push_message | 检查webhook处理逻辑 |
| **4. 多端登录** | 多个设备同时登录同一微信 | 检查wx_account匹配逻辑 |

---

## 📋 排查步骤

### 步骤1: 添加详细日志

在 `backend/routes/v1_webhook.py` 的 `handle_message_event` 函数中添加：

```python
# 函数开头添加
import uuid
request_id = uuid.uuid4().hex[:8]
print(f"[DEBUG-{request_id}] ====== Webhook处理开始 ======")
print(f"[DEBUG-{request_id}] msg_id={msg_id}, from={from_user}, to={to_user}")

# 在保存消息前
print(f"[DEBUG-{request_id}] 准备保存消息到数据库")

# 在保存消息后（成功或失败都打印）
print(f"[DEBUG-{request_id}] 消息保存结果: success={success}, message.id={message.id if message else None}")

# 在SSE推送前
print(f"[DEBUG-{request_id}] 准备推送SSE, tenant_id={wx_account.tenant_id}")

# 在SSE推送后
print(f"[DEBUG-{request_id}] SSE推送完成")
print(f"[DEBUG-{request_id}] ====== Webhook处理结束 ======")
```

### 步骤2: 检查数据库重复

执行SQL查看是否有重复消息：
```sql
-- 检查最近的消息是否有重复
SELECT msg_id, auth_key, is_from_me, COUNT(*) as cnt
FROM messages
WHERE created_at > DATE_SUB(NOW(), INTERVAL 10 MINUTE)
GROUP BY msg_id, auth_key, is_from_me
HAVING cnt > 1;
```

### 步骤3: 测试复现

1. 在后端添加日志后重启服务
2. 在手机发送1条测试消息
3. 观察后端日志，看是否：
   - 收到2次相同的Webhook（request_id不同，msg_id相同）
   - 还是只收到1次Webhook，但推送了2次SSE

### 步骤4: 前端验证

在 `vue-frontend/src/views/messages/index.vue` 添加日志：

```javascript
function handleNewMessage(msgData) {
  console.log('[DEBUG] 收到新消息:', msgData.msg_id, msgData.content)
  // ...
}
```

---

## 🔎 根据现象判断原因

| 现象 | 原因 |
|------|------|
| 2个不同的request_id，相同msg_id | Webhook被1238推送了2次 |
| 1个request_id，但SSE推送2次 | 代码中调用了2次push_message |
| 数据库查询有2条相同msg_id | 唯一索引没生效，插入了2次 |

---

## 💡 可能的解决方案

### 如果是 Webhook 重复推送
```python
# 在消息处理前添加去重锁（Redis）
lock_key = f"webhook:{msg_id}"
if redis_client.get(lock_key):
    print(f"[DEBUG] 重复webhook已忽略: msg_id={msg_id}")
    return
redis_client.setex(lock_key, 60, "1")  # 60秒过期
```

### 如果是代码调用了2次 push_message
```python
# 检查代码中是否有重复的SSE推送调用
# 确保只在保存成功后推送一次
```

### 如果是唯一索引失效
```python
# 检查数据库唯一索引是否正确创建
# 或者添加数据库层面的去重
```

---

## 📁 相关文件

- Webhook处理: `backend/routes/v1_webhook.py`
- 消息模型: `backend/models/message_record.py`
- 前端SSE处理: `vue-frontend/src/views/messages/index.vue`

---

## ✅ 修复要求

1. **添加日志**，复现问题
2. **定位根本原因**（Webhook重复 / 代码重复推送 / 索引失效）
3. **修复问题**
4. **验证修复**（发送1条消息只收到1次推送）
5. **清理日志**

---

**请开始排查！找到根本原因后修复并通知Max！**
