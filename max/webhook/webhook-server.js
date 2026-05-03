const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const NESTJS_URL = process.env.NESTJS_URL || 'http://localhost:3000';
const VALID_TOKENS = (process.env.VALID_TOKENS || '').split(',').map(t => t.trim()).filter(t => t);

// 中间件
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 请求日志中间件
app.use((req, _res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path}`);
  next();
});

/**
 * 健康检查端点
 * GET /health
 */
app.get('/health', (_req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: {
      port: PORT,
      nestjs_url: NESTJS_URL,
      valid_tokens_count: VALID_TOKENS.length
    }
  });
});

/**
 * Webhook接收端点
 * POST /webhook/:token
 */
app.post('/webhook/:token', async (req, res) => {
  const { token } = req.params;
  const timestamp = new Date().toISOString();

  try {
    // 验证token
    if (!VALID_TOKENS.includes(token)) {
      console.error(`[${timestamp}] ❌ 无效的token: ${token}`);
      return res.status(401).json({
        success: false,
        error: 'Invalid token',
        timestamp
      });
    }

    console.log(`[${timestamp}] ✓ Token验证成功: ${token}`);
    console.log(`[${timestamp}] 📦 接收到webhook数据:`, JSON.stringify(req.body).substring(0, 200));

    // 构建转发payload
    const payload = {
      token: token,
      data: req.body,
      receivedAt: timestamp
    };

    // 转发到NestJS服务
    const forwardUrl = `${NESTJS_URL}/api/wechat/process`;
    console.log(`[${timestamp}] 📤 转发到: ${forwardUrl}`);

    const response = await axios.post(forwardUrl, payload, {
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log(`[${timestamp}] ✓ 转发成功，状态码: ${response.status}`);

    // 返回成功响应
    res.json({
      success: true,
      message: 'Webhook processed successfully',
      timestamp,
      nestjs_response_status: response.status
    });

  } catch (error) {
    const timestamp = new Date().toISOString();
    console.error(`[${timestamp}] ❌ 处理webhook失败:`, error.message);

    if (error.response) {
      // NestJS服务返回了错误响应
      console.error(`[${timestamp}] NestJS错误状态码: ${error.response.status}`);
      console.error(`[${timestamp}] NestJS错误详情:`, error.response.data);

      return res.status(error.response.status).json({
        success: false,
        error: 'Failed to process webhook at NestJS service',
        details: error.response.data,
        timestamp
      });
    } else if (error.request) {
      // 请求已发送但没有收到响应
      console.error(`[${timestamp}] 无法连接到NestJS服务: ${NESTJS_URL}`);

      return res.status(503).json({
        success: false,
        error: 'Cannot reach NestJS service',
        nestjs_url: NESTJS_URL,
        timestamp
      });
    } else {
      // 其他错误
      console.error(`[${timestamp}] 未知错误:`, error);

      return res.status(500).json({
        success: false,
        error: 'Internal server error',
        timestamp
      });
    }
  }
});

/**
 * 404处理
 */
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.path,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

/**
 * 错误处理中间件
 */
app.use((err, _req, res, _next) => {
  const timestamp = new Date().toISOString();
  console.error(`[${timestamp}] ❌ 未捕获的错误:`, err);

  res.status(500).json({
    success: false,
    error: 'Server error',
    message: err.message,
    timestamp
  });
});

// 启动服务器
app.listen(PORT, () => {
  const timestamp = new Date().toISOString();
  console.log(`
╔════════════════════════════════════════╗
║     Webhook服务启动成功               ║
╚════════════════════════════════════════╝
[${timestamp}]
✓ 服务器运行在端口: ${PORT}
✓ NestJS目标服务: ${NESTJS_URL}
✓ 配置的Token数量: ${VALID_TOKENS.length}
✓ 健康检查: GET http://localhost:${PORT}/health
✓ Webhook接收: POST http://localhost:${PORT}/webhook/:token
  `);
});

// 优雅关闭
process.on('SIGTERM', () => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] 📌 收到SIGTERM信号，关闭服务器...`);
  process.exit(0);
});

process.on('SIGINT', () => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] 📌 收到SIGINT信号，关闭服务器...`);
  process.exit(0);
});

module.exports = app;
