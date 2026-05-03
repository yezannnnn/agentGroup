# Webhook代理服务

Express.js Webhook接收和转发服务，用于接收webhook请求并转发到NestJS后端服务。

## 功能特性

- ✅ Express服务器，提供Webhook接收端点
- ✅ Token验证机制，确保请求合法性
- ✅ 自动转发到NestJS服务（`/api/wechat/process`）
- ✅ 完整的日志记录和错误处理
- ✅ 健康检查端点
- ✅ 环境变量配置

## 快速开始

### 1. 环境准备

```bash
# 复制环境配置文件
cp .env.example .env

# 编辑.env文件，配置以下信息：
# - PORT: 服务监听端口（默认3001）
# - NESTJS_URL: NestJS服务地址（默认http://localhost:3000）
# - VALID_TOKENS: 有效的Webhook令牌（逗号分隔）
```

### 2. 安装依赖

```bash
npm install
```

### 3. 启动服务

**方式一：使用启动脚本（推荐）**
```bash
./start.sh
```

**方式二：直接运行**
```bash
npm start
```

**方式三：开发模式（需要nodemon）**
```bash
npm run dev
```

## API端点

### 健康检查
```
GET /health
```

**响应示例：**
```json
{
  "status": "healthy",
  "timestamp": "2026-03-09T10:30:45.123Z",
  "uptime": 123.456,
  "environment": {
    "port": 3001,
    "nestjs_url": "http://localhost:3000",
    "valid_tokens_count": 3
  }
}
```

### Webhook接收
```
POST /webhook/:token
Content-Type: application/json

{
  "message": "webhook data",
  "...": "any data structure"
}
```

**参数说明：**
- `token` (URL参数): Webhook令牌，必须在VALID_TOKENS中配置

**响应示例（成功）：**
```json
{
  "success": true,
  "message": "Webhook processed successfully",
  "timestamp": "2026-03-09T10:30:45.123Z",
  "nestjs_response_status": 200
}
```

**响应示例（失败）：**
```json
{
  "success": false,
  "error": "Invalid token",
  "timestamp": "2026-03-09T10:30:45.123Z"
}
```

## 环境变量配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `PORT` | 3001 | 服务监听端口 |
| `NESTJS_URL` | http://localhost:3000 | NestJS服务地址 |
| `VALID_TOKENS` | 见.env | 有效的Webhook令牌（逗号分隔） |
| `NODE_ENV` | development | 运行环境 |

## 工作流程

```
1. 接收 POST /webhook/:token 请求
   ↓
2. 验证:token是否在VALID_TOKENS中
   ↓
3. 构建转发Payload:
   {
     "token": ":token值",
     "data": "请求体内容",
     "receivedAt": "时间戳"
   }
   ↓
4. POST到 ${NESTJS_URL}/api/wechat/process
   ↓
5. 返回结果到客户端
```

## 日志记录

服务会自动记录：
- ✓ 所有请求的时间戳、方法、路径
- ✓ Token验证结果
- ✓ 接收的webhook数据摘要
- ✓ 转发到NestJS的详情
- ✓ 所有错误信息

**日志示例：**
```
[2026-03-09T10:30:45.123Z] POST /webhook/token123
[2026-03-09T10:30:45.124Z] ✓ Token验证成功: token123
[2026-03-09T10:30:45.125Z] 📦 接收到webhook数据: {"message":"test"}...
[2026-03-09T10:30:45.126Z] 📤 转发到: http://localhost:3000/api/wechat/process
[2026-03-09T10:30:45.250Z] ✓ 转发成功，状态码: 200
```

## 错误处理

服务包含多层错误处理：

1. **Token验证失败** → 返回401
2. **NestJS服务返回错误** → 返回相同的状态码
3. **无法连接到NestJS** → 返回503
4. **其他服务器错误** → 返回500

## 故障排查

### 问题1：找不到.env文件
```
❌ 错误: 找不到 .env 配置文件
```
**解决：** 复制.env.example为.env
```bash
cp .env.example .env
```

### 问题2：无法连接到NestJS服务
```
❌ Cannot reach NestJS service
```
**解决：**
- 确保NestJS服务正在运行
- 检查NESTJS_URL配置是否正确
- 验证网络连接

### 问题3：Token验证失败
```
❌ Invalid token
```
**解决：**
- 确认请求中的token在.env的VALID_TOKENS中
- 检查token是否有多余的空格

## 文件结构

```
webhook/
├── webhook-server.js      # 主服务文件
├── package.json           # 项目配置
├── .env                   # 环境配置（生产环境）
├── .env.example          # 环境配置示例
├── start.sh              # 启动脚本
├── README.md             # 本文件
└── node_modules/         # 依赖包（npm install后生成）
```

## 开发要点

### 修改webhook处理逻辑
编辑 `webhook-server.js` 中的 `/webhook/:token` 路由处理函数

### 添加新的API端点
在 `webhook-server.js` 中使用 `app.get()` 或 `app.post()` 添加路由

### 修改转发地址
编辑 `webhook-server.js` 中的 `forwardUrl` 变量或在.env中修改 `NESTJS_URL`

## 生产部署建议

1. **环境变量安全**
   - 使用强随机的VALID_TOKENS
   - 不要将.env提交到版本控制系统
   - 在生产环境使用单独的.env文件

2. **监控和日志**
   - 考虑使用日志服务（如Winston、Pino）
   - 定期检查服务日志
   - 监控错误率

3. **性能优化**
   - 配置反向代理（如Nginx）
   - 使用PM2进程管理器
   - 考虑加入消息队列处理高并发

4. **安全性**
   - 启用HTTPS
   - 实施请求速率限制
   - 验证webhook签名（如使用HMAC）

## 许可证

MIT

## 作者

Max (项目经理)

---

**最后更新**: 2026-03-09
