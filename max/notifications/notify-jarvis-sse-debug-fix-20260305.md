# 🐛 Bug修复报告 - SSE推送问题

**来自**: Jarvis (全栈开发工程师)  
**日期**: 2026-03-05  
**状态**: 已修复  

---

## 🎯 问题总结

**现象**: 登录人自己发送的消息，没有通过SSE推送到前端。

**根本原因**: 
数据库唯一索引 `uk_auth_key_msg_id` (auth_key + msg_id) 导致同一 msg_id 的消息只能保存一条。

微信消息的 msg_id 是全局唯一的，无论消息是发出还是收到，msg_id 相同：
- 场景：用户A在手机上发送消息给用户B
- 消息发出时：msg_id = "12345", is_from_me = 1
- 如果此 msg_id 已存在（可能之前有重复推送），则新消息保存失败
- SSE推送代码在异常处理之后，保存失败时不会执行推送

---

## 🔧 修复内容

### 1. 后端代码修复

#### 文件: `backend/routes/v1_webhook.py`

**修改点**:
- 添加详细调试日志（[DEBUG] 标记），便于追踪消息处理流程
- 在唯一索引冲突时，查询已存在的消息并继续推送SSE
- 无论消息是否为新插入，都确保SSE推送被执行

**关键代码**:
```python
# 保存消息时...
except Exception as e:
    if 'Duplicate entry' in str(e) or 'uk_auth_key_msg_id' in str(e):
        db.session.rollback()
        is_duplicate = True
        # 查询已存在的消息
        message = MessageRecord.query.filter_by(
            auth_key=wx_account.auth_key,
            msg_id=str(msg_id)
        ).first()
    
# 无论是否重复，都推送SSE
if message:
    sse_manager.push_message(tenant_id, {...})
```

#### 文件: `backend/models/message_record.py`

**修改点**:
- 修改唯一索引，将 `is_from_me` 加入索引

**变更**:
```python
# 旧索引（导致问题）
__table_args__ = (
    db.UniqueConstraint('auth_key', 'msg_id', name='uk_auth_key_msg_id'),
)

# 新索引（修复后）
__table_args__ = (
    db.UniqueConstraint('auth_key', 'msg_id', 'is_from_me', name='uk_auth_key_msg_id_direction'),
)
```

**解释**: 新索引允许同一 msg_id 的发出消息(is_from_me=1)和收到消息(is_from_me=0)共存。

### 2. 数据库迁移脚本

**文件**: `sql/05_fix_message_unique_index.sql`

```sql
-- 删除旧索引
ALTER TABLE messages DROP INDEX IF EXISTS uk_auth_key_msg_id;

-- 添加新索引
ALTER TABLE messages ADD UNIQUE INDEX uk_auth_key_msg_id_direction (auth_key, msg_id, is_from_me);
```

---

## 📋 测试步骤

1. **执行数据库迁移**:
   ```bash
   mysql -u root -p weixin < sql/05_fix_message_unique_index.sql
   ```

2. **重启后端服务**

3. **测试场景**:
   - 在手机上发送消息给好友
   - 观察后端日志，确认有 `[DEBUG] SSE推送成功` 日志
   - 观察前端，确认消息能实时显示

---

## 📝 调试日志说明

修复后，后端会输出以下调试日志：

```
[DEBUG] 准备保存消息: is_from_me=1, msg_id=12345, auth_key=xxx
[DEBUG] 消息已保存: id=100, msg_id=12345
[DEBUG] to_chat_dict: {...}
[DEBUG] 准备推送SSE: tenant_id=1, is_duplicate=False
[DEBUG] SSE推送成功: msg_id=12345, is_from_me=1
```

如果发生唯一索引冲突：

```
[DEBUG] 准备保存消息: is_from_me=1, msg_id=12345, auth_key=xxx
[DEBUG] 唯一索引冲突: msg_id=12345, is_from_me=1
[DEBUG] 找到已存在的消息: id=99, is_from_me=0
[DEBUG] 准备推送SSE: tenant_id=1, is_duplicate=True
[DEBUG] SSE推送成功: msg_id=12345, is_from_me=0
```

---

## ✅ 修复验证清单

- [ ] 数据库迁移已执行
- [ ] 后端服务已重启
- [ ] 收到的消息 SSE推送正常
- [ ] 发出的消息 SSE推送正常
- [ ] 前端能正确显示自己发送的消息
- [ ] 调试日志正常输出

---

## 📁 修改的文件列表

| 文件 | 修改类型 | 说明 |
|------|----------|------|
| `backend/routes/v1_webhook.py` | 修改 | 添加调试日志，修复SSE推送逻辑 |
| `backend/models/message_record.py` | 修改 | 更新唯一索引定义 |
| `sql/05_fix_message_unique_index.sql` | 新增 | 数据库迁移脚本 |

---

## 💡 后续建议

1. **监控日志**: 观察生产环境日志，确保没有大量唯一索引冲突
2. **清理调试日志**: 确认修复稳定后，可以将 `[DEBUG]` 日志改为 DEBUG 级别
3. **前端优化**: 前端已包含充分的调试日志，便于排查问题

---

**修复完成，请执行数据库迁移并测试！**
