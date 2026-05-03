# 📋 开发任务通知 - 贾维斯 (Jarvis)

**来自**: Max (PM)  
**日期**: 2026-03-05  
**优先级**: P0 - 高优先级  
**任务类型**: AI消息模块优化

---

## 🎯 任务概述

根据最新PRD修改，需要优化**AI消息模块的好友列表功能**。

**涉及文档**: `PRD/03-AI消息模块-PRD.md` 第3.3章节  
**预计工期**: 0.5天  
**截止日期**: 2026-03-05 (今天)

---

## 📦 具体开发内容

### 1. 后端API修改

**接口**: `GET /api/v1/messages/friends`

**现有位置**: `backend/routes/v1_messages.py` 中 `get_message_friends` 函数

**需要修改的功能**:

| 功能 | 说明 | 状态 |
|------|------|------|
| 分页支持 | 支持 `page` 和 `page_size` 参数（默认page=1, page_size=20） | ⏳ 待开发 |
| 搜索支持 | 支持 `keyword` 参数，搜索昵称/备注/微信号（本地数据库LIKE查询） | ⏳ 待开发 |
| 智能排序 | 有`last_chat_at`的排前面 → 按时间倒序 → 无消息的按id倒序 | ⏳ 待开发 |

**排序SQL参考**:
```sql
SELECT * FROM wx_friends 
WHERE tenant_id = ? AND status = 1
  AND (nickname LIKE '%keyword%' OR remark LIKE '%keyword%' OR wx_id LIKE '%keyword%')
ORDER BY 
  CASE WHEN last_chat_at IS NOT NULL THEN 0 ELSE 1 END,
  last_chat_at DESC,
  id DESC
LIMIT ? OFFSET ?
```

---

### 2. 前端修改

**文件**: `vue-frontend/src/views/messages/index.vue`

**需要修改的功能**:

| 功能 | 说明 | 状态 |
|------|------|------|
| 下拉加载更多 | 滚动到底部自动加载下一页 | ⏳ 待开发 |
| 加载状态 | 底部显示"加载中..."或"没有更多了" | ⏳ 待开发 |
| 搜索优化 | 搜索时调用API（带keyword参数），不走前端过滤 | ⏳ 待开发 |

**已有功能（无需修改）**:
- ✅ 同步按钮（已完成）
- ✅ 好友AI开关（已完成）
- ✅ SSE实时消息（已完成）

---

## 📋 API规范

### 请求
```
GET /api/v1/messages/friends?
  wx_account_id=1&        // 可选
  keyword=张三&            // 新增：搜索关键词
  page=1&                  // 新增：页码，默认1
  page_size=20             // 新增：每页数量，默认20
```

### 响应（已有格式，保持不变）
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 156,
    "page": 1,
    "page_size": 20,
    "has_more": true,
    "list": [
      {
        "id": 1,
        "wx_id": "wxid_xxx",
        "nickname": "张三",
        "remark": "客户-张三",
        "display_name": "客户-张三",
        "avatar": "https://...",
        "ai_enabled": true,
        "last_message": "好的，谢谢",
        "last_time": "2026-03-05T14:30:00",
        "unread_count": 0
      }
    ]
  }
}
```

---

## ⚠️ 重要注意事项

1. **搜索必须走数据库**: 使用SQL LIKE查询，不要从前端过滤
2. **排序逻辑严格**: 必须按PRD的排序规则（最近消息优先）
3. **向后兼容**: 不传分页参数时要有默认值（page=1, page_size=20）
4. **性能考虑**: 确保搜索和排序都走数据库索引
5. **数据库索引**: 可能需要为 `last_chat_at` 添加索引
6. **不要修坏其他逻辑**: 保持现有SSE、AI开关、同步功能正常运行
7. **保证可扩展**: 代码要有良好的结构和注释

---

## 📁 相关文件

| 文件 | 路径 | 操作 |
|------|------|------|
| PRD文档 | `/Users/yuhao/Desktop/yezannnnn/chatBotBinary/PRD/03-AI消息模块-PRD.md` | 阅读第3.3章节 |
| 后端路由 | `backend/routes/v1_messages.py` | 修改 `get_message_friends` |
| 前端页面 | `vue-frontend/src/views/messages/index.vue` | 修改好友列表加载逻辑 |
| 前端API | `vue-frontend/src/services/messageApi.js` | 可能需要更新参数 |

---

## ✅ 验收标准

- [ ] 分页功能正常，首次加载20条，下拉加载更多
- [ ] 搜索功能正常，输入关键词实时调用API搜索
- [ ] 排序正确：有最近消息的好友排在最前面
- [ ] 加载状态显示正常（"加载中..."/"没有更多了"）
- [ ] 向后兼容，不传参数时也能正常工作
- [ ] 现有功能（SSE、AI开关、同步）不受影响

---

**有任何问题立即联系Max！**
