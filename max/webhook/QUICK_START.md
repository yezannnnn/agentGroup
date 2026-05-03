# 快速开始指南

## 5分钟内启动Webhook服务

### 前置条件
- Node.js 14.0.0+
- npm 6.0.0+

### 第1步：配置环境（1分钟）

```bash
cd webhook

# 复制环境配置
cp .env.example .env

# 编辑.env（可选，已有默认配置）
# nano .env
```

**默认配置已包含：**
- 端口：3001
- NestJS服务：http://localhost:3000
- 示例Token：default_token_123, test_token_456, webhook_token_789

### 第2步：启动服务（2分钟）

```bash
# 使用启动脚本（推荐）
./start.sh

# 或者直接运行
npm install
npm start
```

### 第3步：验证服务（1分钟）

在另一个终端窗口运行：

```bash
# 检查健康状态
curl http://localhost:3001/health

# 应该返回：
# {
#   "status": "healthy",
#   "timestamp": "...",
#   "uptime": ...,
#   "environment": {...}
# }
```

### 第4步：发送测试Webhook（1分钟）

```bash
# 使用默认token发送webhook
curl -X POST http://localhost:3001/webhook/default_token_123 \
  -H "Content-Type: application/json" \
  -d '{
    "from_user": "test_user",
    "message": "Hello Webhook!",
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }'

# 成功响应：
# {
#   "success": true,
#   "message": "Webhook processed successfully",
#   "timestamp": "...",
#   "nestjs_response_status": 200
# }
```

## 常用命令

```bash
# 启动服务
./start.sh

# 安装依赖
npm install

# 生产运行
npm start

# 开发模式（需要nodemon）
npm run dev

# 健康检查
curl http://localhost:3001/health

# 发送测试webhook
curl -X POST http://localhost:3001/webhook/default_token_123 \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}'
```

## 配置说明

编辑 `.env` 文件：

```bash
# 服务端口（如需改为3002）
PORT=3002

# NestJS服务地址（如为远程服务）
NESTJS_URL=https://api.example.com:3000

# 添加新token（用逗号分隔）
VALID_TOKENS=token1,token2,token3,my_new_token

# 环境标识
NODE_ENV=production
```

## 调试

查看实时日志：

```bash
# 启动服务会自动显示日志
npm start

# 日志示例：
# [2026-03-09T10:30:45.123Z] POST /webhook/token123
# [2026-03-09T10:30:45.124Z] ✓ Token验证成功: token123
# [2026-03-09T10:30:45.250Z] ✓ 转发成功，状态码: 200
```

## 测试Webhook

### 脚本1：批量发送webhook

```bash
#!/bin/bash
# save as: test-webhook.sh

BASE_URL="http://localhost:3001"
TOKEN="default_token_123"
ITERATIONS=5

for i in $(seq 1 $ITERATIONS); do
  echo "发送webhook #$i..."
  curl -s -X POST "$BASE_URL/webhook/$TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"test_id\":$i,\"message\":\"Test webhook $i\"}" \
    | jq .
  sleep 1
done

echo "完成！发送了 $ITERATIONS 个webhook"
```

### 脚本2：压力测试

```bash
#!/bin/bash
# save as: stress-test.sh

BASE_URL="http://localhost:3001"
TOKEN="default_token_123"
CONCURRENT=10
TOTAL=100

echo "开始压力测试: $TOTAL请求，$CONCURRENT并发..."

for i in $(seq 1 $TOTAL); do
  (
    curl -s -X POST "$BASE_URL/webhook/$TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"id\":$i,\"type\":\"test\"}" > /dev/null
    echo "Request #$i completed"
  ) &

  # 每$CONCURRENT个请求暂停一下
  if (( i % CONCURRENT == 0 )); then
    wait
    echo "Batch $((i / CONCURRENT)) completed"
  fi
done

wait
echo "压力测试完成！"
```

## 故障排查

### 服务无法启动
```
❌ Error: listen EADDRINUSE: address already in use :::3001
```
**解决：** 端口已被占用，改用其他端口
```bash
PORT=3002 npm start
```

### NestJS连接失败
```
❌ Cannot reach NestJS service: http://localhost:3000
```
**解决：** 检查NestJS服务是否运行
```bash
# 检查NestJS服务是否在线
curl http://localhost:3000/api/health
```

### Token验证失败
```
❌ Invalid token
```
**解决：** 确认token已在.env中配置
```bash
# 检查配置的token
grep VALID_TOKENS .env

# 使用正确的token
curl -X POST http://localhost:3001/webhook/default_token_123 ...
```

## 下一步

- ✅ 添加HTTPS支持
- ✅ 配置PM2进程管理
- ✅ 设置日志文件轮转
- ✅ 配置请求速率限制
- ✅ 添加监控告警

详见 [完整文档](./README.md)

---

**需要帮助？** 检查 [README.md](./README.md) 或查看服务日志
