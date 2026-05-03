# Webhook服务安装和配置指南

## 📦 已创建的文件清单

```
webhook/
├── webhook-server.js      (4.9 KB) - 核心服务文件
├── package.json           (681 B)  - 项目配置和依赖
├── .env                   (470 B)  - 环境变量（生产）
├── .env.example          (353 B)  - 环境配置示例
├── .gitignore            (309 B)  - Git忽略规则
├── start.sh              (2.1 KB) - 启动脚本
├── verify.sh             (4.5 KB) - 验证脚本
├── README.md             (5.0 KB) - 完整文档
├── QUICK_START.md        (3.5 KB) - 快速开始
└── SETUP.md              (本文件) - 安装指南
```

## 🚀 一句话启动

```bash
cd /Users/yuhao/Desktop/yezannnnn/aiGroup/max/webhook
./start.sh
```

## 📋 详细安装步骤

### 步骤1：验证环境

```bash
# 进入webhook目录
cd /Users/yuhao/Desktop/yezannnnn/aiGroup/max/webhook

# 运行验证脚本
./verify.sh
```

**预期输出：**
- ✓ Node.js 14.0.0+
- ✓ npm 6.0.0+
- ✓ .env 文件存在
- ✓ 所有必要文件就绪

### 步骤2：安装依赖

```bash
# 使用start.sh自动安装（推荐）
./start.sh

# 或手动安装
npm install
```

**安装的依赖：**
- `express@^4.18.2` - Web框架
- `axios@^1.6.0` - HTTP客户端
- `dotenv@^16.3.1` - 环境变量管理

### 步骤3：配置环境变量

编辑 `.env` 文件：

```bash
# 打开编辑器
nano .env
```

**配置项说明：**

| 配置项 | 说明 | 默认值 | 例子 |
|--------|------|--------|------|
| `PORT` | 服务监听端口 | 3001 | 3001, 8080 |
| `NESTJS_URL` | NestJS服务地址 | http://localhost:3000 | http://api.example.com:3000 |
| `VALID_TOKENS` | 有效的Webhook令牌 | 见文件 | token1,token2,token3 |
| `NODE_ENV` | 运行环境 | development | development, production |

**示例配置（生产）：**

```bash
PORT=3001
NESTJS_URL=https://api.production.com:3000
VALID_TOKENS=prod_token_xxxxx,prod_token_yyyyy
NODE_ENV=production
```

### 步骤4：启动服务

**方式1：使用启动脚本（推荐）**
```bash
./start.sh
```

**方式2：直接运行**
```bash
npm start
```

**方式3：开发模式**
```bash
npm run dev
```

**预期输出：**
```
╔════════════════════════════════════════╗
║     Webhook服务启动成功               ║
╚════════════════════════════════════════╝
[2026-03-09T10:30:45.123Z]
✓ 服务器运行在端口: 3001
✓ NestJS目标服务: http://localhost:3000
✓ 配置的Token数量: 3
✓ 健康检查: GET http://localhost:3001/health
✓ Webhook接收: POST http://localhost:3001/webhook/:token
```

### 步骤5：验证服务

**打开新的终端窗口：**

```bash
# 检查健康状态
curl http://localhost:3001/health

# 预期响应：
# {
#   "status": "healthy",
#   "timestamp": "2026-03-09T10:30:45.123Z",
#   "uptime": 5.234,
#   "environment": {
#     "port": 3001,
#     "nestjs_url": "http://localhost:3000",
#     "valid_tokens_count": 3
#   }
# }
```

## 🧪 测试Webhook

### 基本测试

```bash
# 使用默认token发送测试webhook
curl -X POST http://localhost:3001/webhook/default_token_123 \
  -H "Content-Type: application/json" \
  -d '{
    "from_user": "test",
    "message": "Hello Webhook!",
    "timestamp": "2026-03-09T10:30:45.123Z"
  }'
```

**成功响应：**
```json
{
  "success": true,
  "message": "Webhook processed successfully",
  "timestamp": "2026-03-09T10:30:45.123Z",
  "nestjs_response_status": 200
}
```

### 无效token测试

```bash
curl -X POST http://localhost:3001/webhook/invalid_token \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}'
```

**错误响应：**
```json
{
  "success": false,
  "error": "Invalid token",
  "timestamp": "2026-03-09T10:30:45.123Z"
}
```

## 🔧 常见配置场景

### 场景1：在同一台机器上测试

**NestJS运行在3000端口：**
```bash
# .env配置
PORT=3001
NESTJS_URL=http://localhost:3000
VALID_TOKENS=test_token_123
```

### 场景2：连接到远程NestJS服务

**NestJS在远程服务器：**
```bash
# .env配置
PORT=3001
NESTJS_URL=https://api.example.com:3000
VALID_TOKENS=remote_token_xxxxx,remote_token_yyyyy
NODE_ENV=production
```

### 场景3：负载均衡后的NestJS

**使用Nginx代理的NestJS：**
```bash
# .env配置
PORT=3001
NESTJS_URL=http://localhost:8080
VALID_TOKENS=lb_token_1,lb_token_2
```

## 📊 性能考虑

### 默认配置性能

- **最大并发连接**: 受Node.js限制（通常>1000）
- **响应时间**: 平均 50-200ms（取决于NestJS性能）
- **内存占用**: ~50MB

### 优化建议

**高负载场景：**
1. 增加Node.js内存：`node --max-old-space-size=1024 webhook-server.js`
2. 使用PM2进程管理器（参考下文）
3. 配置Nginx反向代理

## 🔒 安全建议

### 1. Token安全

```bash
# ❌ 不要在代码中硬编码token
VALID_TOKENS=weak_token_123

# ✓ 使用强随机token
# 可以使用以下方式生成：
openssl rand -hex 32

# 示例输出：
# a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
```

### 2. HTTPS配置（生产环境）

**在Nginx中配置HTTPS：**
```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:3001;
    }
}
```

### 3. 请求验证（可选）

**在webhook-server.js中添加签名验证：**
```javascript
// 添加HMAC验证
const crypto = require('crypto');
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET;

function verifySignature(payload, signature) {
  const hash = crypto
    .createHmac('sha256', WEBHOOK_SECRET)
    .update(JSON.stringify(payload))
    .digest('hex');
  return hash === signature;
}
```

## 🚨 故障排查

### 问题1：端口被占用

```
❌ Error: listen EADDRINUSE: address already in use :::3001
```

**解决方案：**
```bash
# 查找占用端口的进程
lsof -i :3001

# 杀死进程
kill -9 <PID>

# 或改用其他端口
PORT=3002 npm start
```

### 问题2：NestJS连接失败

```
❌ Cannot reach NestJS service: http://localhost:3000
```

**排查步骤：**
```bash
# 1. 检查NestJS是否运行
curl http://localhost:3000/health

# 2. 检查防火墙
# macOS:
sudo lsof -i :3000

# Linux:
netstat -tlnp | grep 3000

# 3. 验证配置
cat .env | grep NESTJS_URL
```

### 问题3：Token验证失败

```
❌ Invalid token
```

**排查步骤：**
```bash
# 1. 检查配置的token
grep VALID_TOKENS .env

# 2. 使用正确的token
TOKEN="default_token_123"
curl -X POST http://localhost:3001/webhook/$TOKEN \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}'

# 3. 检查token中是否有空格
echo "VALID_TOKENS=token1, token2" # ❌ 有空格
echo "VALID_TOKENS=token1,token2"  # ✓ 正确
```

### 问题4：日志太多/找不到日志

**调整日志：**
```bash
# 保存日志到文件
npm start > webhook.log 2>&1 &

# 实时查看日志
tail -f webhook.log

# 过滤特定内容
tail -f webhook.log | grep "ERROR"
```

## 📈 监控和维护

### 1. 定期检查日志

```bash
# 查看最近100行日志
tail -100 webhook.log

# 查看错误统计
grep "❌" webhook.log | wc -l
```

### 2. 定期验证服务

```bash
# 创建监控脚本
cat > check-health.sh << 'EOF'
#!/bin/bash
response=$(curl -s http://localhost:3001/health)
if echo $response | grep -q "healthy"; then
  echo "✓ Webhook服务正常"
else
  echo "❌ Webhook服务异常"
  echo $response
fi
EOF

chmod +x check-health.sh

# 添加到cron定时任务（每5分钟检查一次）
crontab -e
# 添加: */5 * * * * /path/to/check-health.sh
```

## 🔄 升级和更新

### 更新依赖

```bash
# 检查过时的依赖
npm outdated

# 更新所有依赖
npm update

# 更新特定包
npm update express
```

### 生成新的.env

```bash
# 保存当前配置
cp .env .env.backup

# 使用新的示例
cp .env.example .env

# 恢复生产配置
cp .env.backup .env
```

## 📚 相关文档

- [快速开始](./QUICK_START.md) - 5分钟上手
- [README.md](./README.md) - 完整功能文档
- [API文档](./README.md#api端点) - 端点详情

## ✅ 安装检查清单

- [ ] Node.js 14+已安装
- [ ] npm 6+已安装
- [ ] .env文件已配置
- [ ] NESTJS_URL配置正确
- [ ] VALID_TOKENS已设置
- [ ] npm install已运行
- [ ] 服务已启动（./start.sh）
- [ ] 健康检查返回200
- [ ] 测试webhook成功
- [ ] 日志输出正常

## 🆘 获取帮助

1. **查看日志** - 大多数问题都有详细日志记录
2. **验证配置** - 运行 `./verify.sh`
3. **阅读文档** - 查看 README.md 和 QUICK_START.md
4. **检查NestJS** - 确认NestJS服务在运行

---

**安装日期**: 2026-03-09
**服务版本**: 1.0.0
**最后更新**: 2026-03-09
