# Bug修复任务: 003

## Bug描述
**接口**: `GET http://localhost:3000/api/v1/messages/chat/28?limit=20`

**错误信息**:
```
Entity namespace for "wx_accounts" has no property "id"
```

**分析**:
- SQLAlchemy/ORM 实体映射错误
- `wx_accounts` 模型缺少 `id` 属性定义
- 可能是查询语句中引用了 `wx_accounts.id` 但模型未定义

**涉及文件推测**:
- `backend/models/wx_account.py` - wx_accounts模型定义
- `backend/routes/v1_messages.py` - 消息接口路由
- 相关查询可能使用了 `join` 或 `filter_by`

## 复现步骤
1. 登录系统
2. 进入消息页面
3. 打开与好友ID=28的聊天记录
4. 接口报错

## 期望结果
正常返回聊天记录列表

## 实际结果
500错误，提示Entity namespace错误

## 修复要求
- [x] 检查 `wx_accounts` 模型定义，确认是否有 `id` 字段
- [x] 检查 `v1_messages.py` 中 `/chat/<id>` 接口的查询语句
- [x] 修复模型定义或查询语句
- [x] 测试验证修复结果

## 修复结果
**修复时间**: 2026-03-04
**修复人**: Max (Spawn模式)
**修复文件**: `backend/routes/v1_messages.py` 第449行
**修复内容**: 将 `id=friend.auth_key` 改为 `auth_key=friend.auth_key`
**原因**: WxAccount模型使用 `auth_key` 作为主键，没有 `id` 字段
**状态**: ✅ 已完成

## 参考信息
- 项目路径: ~/Desktop/yezannnnn/chatBot/
- 数据库表: wx_accounts (已有数据)
- 关联模块: AI消息模块 (03)

---
**创建人**: Max  
**创建时间**: 2026-03-04  
**优先级**: 高  
**状态**: 待分配
