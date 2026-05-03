# 微信Webhook服务部署完成报告

## 🎉 部署状态：成功

### 📋 服务信息
- **服务器IP**: 116.62.114.210
- **服务端口**: 3001
- **部署目录**: /opt/webhooks
- **服务名称**: webhook-service (PM2管理)
- **当前状态**: ✅ 在线运行

### 🔧 配置信息
- **有效Token**: webhook_token_123, test_token_456, wechat_token_789
- **NestJS转发地址**: http://localhost:3000/api/wechat/process
- **健康检查URL**: http://116.62.114.210:3001/health (需配置安全组)

### 🚨 重要提醒：安全组配置

**⚠️ 当前外网无法访问，需要配置阿里云安全组：**

1. 登录阿里云控制台
2. 进入 ECS > 安全组
3. 选择对应安全组，点击"配置规则"
4. 添加入方向规则：
   - 授权策略：允许
   - 优先级：1
   - 协议类型：TCP
   - 端口范围：3001/3001
   - 授权对象：0.0.0.0/0
   - 描述：Webhook服务端口

## 📊 日志查看功能

### 🔧 日志查看工具：./log-viewer.sh

**基础命令：**
```bash
# 查看最新日志
./log-viewer.sh

# 查看最新100行日志
./log-viewer.sh tail 100

# 实时查看日志 (Ctrl+C退出)
./log-viewer.sh live

# 查看服务状态
./log-viewer.sh status

# 清空日志
./log-viewer.sh clear

# 搜索关键词
./log-viewer.sh search token

# 查看webhook相关日志
./log-viewer.sh webhook

# 显示帮助
./log-viewer.sh help
```

### 📋 日志类型说明

**标准输出日志**：
- 服务启动信息
- 请求处理记录
- Token验证结果
- 转发状态

**错误日志**：
- 启动错误
- 请求处理异常
- 网络连接问题

### 🔍 实际日志示例

**服务启动日志：**
```
╔════════════════════════════════════════╗
║     Webhook服务启动成功               ║
╚════════════════════════════════════════╝
[2026-03-09T15:18:19.579Z]
✓ 服务器运行在端口: 3001
✓ NestJS目标服务: http://localhost:3000
✓ 配置的Token数量: 3
✓ 健康检查: GET http://localhost:3001/health
✓ Webhook接收: POST http://localhost:3001/webhook/:token
```

**请求处理日志：**
```
[时间戳] GET /health
[时间戳] ✓ Token验证成功: webhook_token_123
[时间戳] 📦 接收到webhook数据: {...}
[时间戳] 📤 转发到: http://localhost:3000/api/wechat/process
[时间戳] ✓ 转发成功，状态码: 200
```

## 🧪 测试验证

### 内部测试（服务器内）
```bash
# SSH到服务器
ssh root@116.62.114.210

# 测试健康检查
curl http://localhost:3001/health

# 测试webhook接收
curl -X POST http://localhost:3001/webhook/webhook_token_123 \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}'
```

### 外网测试（配置安全组后）
```bash
# 本地测试脚本
./test-webhook.sh
```

## 📱 微信平台配置

**Webhook URL配置：**
```
http://116.62.114.210:3001/webhook/webhook_token_123
```

**可用Token：**
- webhook_token_123
- test_token_456
- wechat_token_789

## 🔄 服务管理命令

**PM2管理：**
```bash
# 查看状态
pm2 status

# 查看日志
pm2 logs webhook-service

# 重启服务
pm2 restart webhook-service

# 停止服务
pm2 stop webhook-service

# 查看实时日志
pm2 logs webhook-service --lines 0
```

**服务配置：**
```bash
# 查看配置
cat /opt/webhooks/.env

# 修改配置后重启
pm2 restart webhook-service
```

## 📈 监控信息

### 服务监控
- PM2提供进程监控和自动重启
- 系统开机自启动已配置
- 内存使用约60-70MB

### 日志监控
- 标准输出和错误分离记录
- 支持实时查看和历史查询
- 可按关键词搜索日志内容

## 🚀 下一步

1. **立即需要**：配置阿里云安全组开放3001端口
2. **可选优化**：
   - 配置nginx反向代理和SSL证书
   - 设置日志轮转和清理策略
   - 添加监控告警机制

## 📞 故障排查

**服务无法启动**：
```bash
# 查看错误日志
pm2 logs webhook-service --err

# 检查配置文件
cat /opt/webhooks/.env

# 手动启动测试
cd /opt/webhooks
node webhook-server.js
```

**外网无法访问**：
1. 检查安全组配置
2. 确认服务监听0.0.0.0:3001
3. 测试服务器内部访问

**日志查看异常**：
```bash
# 使用SSH直接查看
ssh root@116.62.114.210 "pm2 logs webhook-service --lines 50"

# 或使用本地工具
./log-viewer.sh tail 50
```