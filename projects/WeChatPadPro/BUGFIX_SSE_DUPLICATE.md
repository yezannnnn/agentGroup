# SSE消息重复推送Bug修复文档

## 问题描述
用户自己发送的消息，SSE推送到前端时出现2次重复。

## 根本原因
1238服务在网络抖动或超时重试时，可能重复发送相同的webhook请求，导致：
1. 后端重复处理相同消息
2. 向SSE推送2次相同消息
3. 前端显示2条重复消息

## 修复方案

### 方案1: Redis分布式去重锁（主要方案）
在webhook处理开始时，使用Redis SET NX EX原子操作获取锁：
- 锁键：`webhook:{auth_key}:{msg_id}:{is_from_me}`
- 过期时间：60秒
- 获取锁失败 = 重复请求，直接返回

### 方案2: 前端去重加固（辅助方案）
前端维护一个Set记录已接收的消息ID（msg_id + is_from_me组合），重复消息直接丢弃。

## 修改文件
- `backend/routes/v1_webhook.py` - 添加Redis去重锁和详细日志
- `backend/redis_client.py` - Redis客户端配置（新增）
- `vue-frontend/src/views/messages/index.vue` - 添加前端去重

## 测试验证
1. 发送1条消息
2. 后端日志应显示：处理1次，忽略0次
3. 前端应显示：收到1次消息
4. 数据库应有：1条记录

## 排查工具
```bash
# 检查数据库重复
mysql -u user -p wechat_pad_pro < backend/scripts/check_duplicate_messages.sql

# 检查Redis锁
redis-cli keys "webhook:*"
```

## 修复时间
2026-03-05
