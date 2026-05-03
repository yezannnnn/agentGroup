const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// 🌐 IP白名单配置 - 支持网段匹配
const ALLOWED_IPS = (process.env.ALLOWED_IPS || '182.40.197.*,182.40.196.*,182.40.195.*,182.40.198.*').split(',').map(ip => ip.trim()).filter(ip => ip);

// 🔍 IP网段匹配函数
function isIPInWhitelist(clientIP, allowedPatterns) {
  for (const pattern of allowedPatterns) {
    // 精确匹配
    if (pattern === clientIP) {
      return true;
    }

    // 通配符匹配 (例如: 182.40.197.*)
    if (pattern.includes('*')) {
      const regexPattern = pattern.replace(/\./g, '\\.').replace(/\*/g, '\\d+');
      const regex = new RegExp(`^${regexPattern}$`);
      if (regex.test(clientIP)) {
        return true;
      }
    }

    // CIDR匹配 (例如: 182.40.197.0/24)
    if (pattern.includes('/')) {
      const [networkAddr, prefixLength] = pattern.split('/');
      const prefix = parseInt(prefixLength);

      const clientParts = clientIP.split('.').map(Number);
      const networkParts = networkAddr.split('.').map(Number);

      if (clientParts.length === 4 && networkParts.length === 4) {
        let bitsToCheck = prefix;
        for (let i = 0; i < 4 && bitsToCheck > 0; i++) {
          const bitsInThisOctet = Math.min(8, bitsToCheck);
          const mask = (0xFF << (8 - bitsInThisOctet)) & 0xFF;

          if ((clientParts[i] & mask) !== (networkParts[i] & mask)) {
            break;
          }

          if (i === 3 || bitsToCheck <= 8) {
            return true;
          }
          bitsToCheck -= 8;
        }
      }
    }
  }
  return false;
}

// 🛡️ 获取客户端真实IP
function getClientIP(req) {
  return req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
         req.headers['x-real-ip'] ||
         req.connection?.remoteAddress ||
         req.socket?.remoteAddress ||
         req.ip;
}

// 🔒 IP验证中间件
function ipCheckMiddleware(req, res, next) {
  const clientIP = getClientIP(req);
  const userAgent = req.get('user-agent');

  // 如果没有配置IP白名单，允许所有请求（仅用于测试）
  if (ALLOWED_IPS.length === 0) {
    console.log(`⚠️ 警告: 未配置IP白名单，允许所有请求`);
    return next();
  }

  // 检查IP是否在白名单中（支持网段匹配）
  const isIPAllowed = isIPInWhitelist(clientIP, ALLOWED_IPS);

  // 详细日志记录
  console.log(`🔍 IP网段检查 [客户端IP: ${clientIP}]:`);
  console.log(`   - 客户端IP: ${clientIP} ${isIPAllowed ? '✅' : '❌'}`);
  console.log(`   - User-Agent: ${userAgent}`);
  console.log(`   - 白名单规则: ${ALLOWED_IPS.join(', ')}`);
  console.log(`   - 最终结果: ${isIPAllowed ? '✅ 允许' : '❌ 拒绝'}`);

  if (!isIPAllowed) {
    console.log(`🚫 IP访问被拒绝: ${clientIP}`);

    return res.status(403).json({
      success: false,
      error: 'Access denied - IP not allowed',
      details: {
        message: '访问被拒绝：IP不在白名单中',
        your_ip: clientIP,
        allowed_ips: ALLOWED_IPS,
        help: '请联系管理员将您的IP加入白名单'
      },
      timestamp: new Date().toISOString()
    });
  }

  console.log(`✅ IP验证通过: ${clientIP}`);
  next();
}

// 中间件配置
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// 🔒 应用IP验证中间件到所有路由
app.use(ipCheckMiddleware);

// 请求日志中间件（在IP检查之后）
app.use((req, _res, next) => {
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);
  console.log(`[${timestamp}] ${req.method} ${req.path} - IP: ${clientIP}`);
  next();
});

/**
 * 健康检查端点
 */
app.get('/health', (req, res) => {
  const clientIP = getClientIP(req);
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    client_ip: clientIP,
    environment: {
      port: PORT,
      allowed_ips: ALLOWED_IPS,
      mode: 'local-processing-no-retry',
      tunnel_enabled: false
    }
  });
});

/**
 * 🎯 本地Webhook处理端点 - 快速响应不重试
 */
app.post('/webhook', (req, res) => {
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);

  try {
    console.log(`✅ 本地处理Webhook请求 - IP: ${clientIP}`);
    console.log(`📦 数据大小: ${JSON.stringify(req.body).length}字节`);
    console.log(`📦 数据内容:`, JSON.stringify(req.body).substring(0, 200));

    // 🚀 立即返回成功响应，避免外部重试
    const responseData = {
      success: true,
      message: 'Webhook接收成功',
      timestamp,
      received_data: req.body,
      processing_info: {
        mode: 'local-processing',
        server_ip: clientIP,
        no_retry: true
      }
    };

    console.log(`✅ 本地处理完成，立即响应`);

    // 立即返回200，告诉外部系统处理成功
    res.status(200).json(responseData);

  } catch (error) {
    const errorTimestamp = new Date().toISOString();
    console.error(`❌ Webhook处理异常 IP: ${clientIP}:`, error.message);

    // 即使发生错误，也快速返回避免重试
    res.status(200).json({
      success: false,
      message: 'Webhook已接收，处理时发生异常',
      error: error.message,
      timestamp: errorTimestamp,
      no_retry: true
    });
  }
});

/**
 * 404处理
 */
app.use((req, res) => {
  const clientIP = getClientIP(req);
  console.log(`🚫 404访问尝试: ${req.method} ${req.path} - IP: ${clientIP}`);

  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    available_endpoints: [
      'GET /health - 健康检查',
      'POST /webhook - Webhook接收'
    ],
    timestamp: new Date().toISOString()
  });
});

/**
 * 错误处理中间件
 */
app.use((err, _req, res, _next) => {
  const timestamp = new Date().toISOString();
  console.error(`❌ 未捕获的错误:`, err);

  // 即使是未捕获错误，也返回200避免重试
  res.status(200).json({
    success: false,
    error: 'Server handled error gracefully',
    message: err.message,
    timestamp,
    no_retry: true
  });
});

// 启动服务器
app.listen(PORT, '0.0.0.0', () => {
  const timestamp = new Date().toISOString();
  console.log(`
╔════════════════════════════════════════╗
║    🎯 本地Webhook服务启动成功          ║
╚════════════════════════════════════════╝
[${timestamp}]
✓ 服务器运行在端口: ${PORT}
🎯 处理模式: 本地处理，快速响应
🔒 安全模式: 纯IP白名单验证（支持网段）
   - 允许的IP/网段: ${ALLOWED_IPS.join(', ')}
📋 端点:
   - 健康检查: GET /health
   - Webhook接收: POST /webhook (本地处理)
🚀 特性:
   - ✅ 立即响应，防止外部重试
   - ✅ 即使异常也返回200状态码
   - ✅ 详细日志记录
  `);
});