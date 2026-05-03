const express = require('express');
const app = express();
const PORT = process.env.PORT || 3001;

// 中间件配置
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// 请求日志中间件
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path}`);
  console.log(`Headers:`, req.headers);
  next();
});

/**
 * 🎯 本地Webhook接收端点
 */
app.post('/webhook', (req, res) => {
  const timestamp = new Date().toISOString();

  console.log(`\n🎯 本地收到Webhook请求:`);
  console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
  console.log(`⏰ 时间: ${timestamp}`);
  console.log(`📦 数据大小: ${JSON.stringify(req.body).length}字节`);
  console.log(`🌐 来源IP: ${req.get('x-forwarded-for') || req.ip}`);
  console.log(`🏠 原始Host: ${req.get('x-original-host')}`);
  console.log(`🔗 隧道来源: ${req.get('x-tunnel-source')}`);
  console.log(`📋 完整数据:`);
  console.log(JSON.stringify(req.body, null, 2));
  console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`);

  // 这里添加您的业务逻辑
  const responseData = {
    success: true,
    message: '本地服务处理成功！',
    timestamp,
    received_data: req.body,
    processing_info: {
      server: 'local-webhook-receiver',
      version: '1.0.0',
      processed_at: timestamp
    }
  };

  res.json(responseData);
});

/**
 * 健康检查
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'local-webhook-receiver',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

/**
 * 根路径
 */
app.get('/', (req, res) => {
  res.json({
    service: 'Local Webhook Receiver',
    status: 'running',
    endpoints: {
      webhook: 'POST /webhook',
      health: 'GET /health'
    },
    timestamp: new Date().toISOString()
  });
});

// 启动服务
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║      🎯 本地Webhook接收服务启动        ║
╚════════════════════════════════════════╝
🌐 监听端口: ${PORT}
📍 本地地址: http://localhost:${PORT}
📋 Webhook端点: http://localhost:${PORT}/webhook
✅ 准备接收隧道转发的请求...

💡 使用说明:
1. 确保此服务正在运行
2. 在服务器上启用隧道模式 (TUNNEL_ENABLED=true)
3. 设置目标URL为: http://localhost:${PORT}
  `);
});