const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const LOCAL_TUNNEL_URL = process.env.LOCAL_TUNNEL_URL || 'http://localhost:3001';

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

  if (ALLOWED_IPS.length === 0) {
    console.log(`⚠️ 警告: 未配置IP白名单，允许所有请求`);
    return next();
  }

  const isIPAllowed = isIPInWhitelist(clientIP, ALLOWED_IPS);

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
        allowed_ips: ALLOWED_IPS
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
app.use(ipCheckMiddleware);

// 请求日志中间件
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
    tunnel_config: {
      enabled: true,
      target_url: LOCAL_TUNNEL_URL,
      no_retry_mode: true,
      allowed_ips: ALLOWED_IPS
    }
  });
});

/**
 * 🔗 智能隧道Webhook端点 - 转发但不重试
 */
app.post('/webhook', async (req, res) => {
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);

  console.log(`✅ 收到Webhook请求 - IP: ${clientIP}`);
  console.log(`📦 数据大小: ${JSON.stringify(req.body).length}字节`);
  console.log(`📦 数据内容:`, JSON.stringify(req.body).substring(0, 200));

  // 🚀 关键策略：无论转发成功或失败，都立即返回200给外部
  // 这样外部系统认为处理成功，不会重试
  const successResponse = {
    success: true,
    message: 'Webhook已接收',
    timestamp,
    client_ip: clientIP,
    tunnel_target: LOCAL_TUNNEL_URL,
    no_retry: true
  };

  // 立即返回成功响应，防止外部重试
  res.status(200).json(successResponse);

  // 🔗 异步尝试转发到本地，不影响上面的响应
  try {
    const forwardUrl = `${LOCAL_TUNNEL_URL}/webhook`;
    console.log(`🔗 异步转发到本地: ${forwardUrl}`);

    const response = await axios.post(forwardUrl, req.body, {
      timeout: 5000, // 短超时，快速失败
      headers: {
        'Content-Type': 'application/json',
        'X-Forwarded-For': clientIP,
        'X-Original-Host': req.get('host'),
        'X-Tunnel-Source': 'webhook-tunnel-no-retry'
      }
    });

    console.log(`✅ 本地转发成功，状态码: ${response.status}`);

  } catch (error) {
    // 转发失败，但不影响外部响应（已经返回200了）
    console.log(`⚠️ 本地转发失败 (不影响外部响应): ${error.message}`);

    if (error.code === 'ECONNREFUSED') {
      console.log(`💡 本地服务未启动: ${LOCAL_TUNNEL_URL}`);
    } else if (error.code === 'ETIMEDOUT') {
      console.log(`⏱️ 本地服务响应超时: ${LOCAL_TUNNEL_URL}`);
    } else {
      console.log(`🔍 其他转发错误: ${error.code || 'unknown'}`);
    }
  }
});

/**
 * 隧道状态查看端点
 */
app.get('/tunnel-status', (req, res) => {
  const clientIP = getClientIP(req);
  res.json({
    status: 'tunnel_active',
    timestamp: new Date().toISOString(),
    client_ip: clientIP,
    tunnel: {
      enabled: true,
      target_url: LOCAL_TUNNEL_URL,
      mode: 'async-forward-no-retry',
      timeout: '5000ms',
      strategy: 'immediate_200_response'
    },
    security: {
      ip_whitelist_enabled: ALLOWED_IPS.length > 0,
      allowed_patterns: ALLOWED_IPS
    }
  });
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
      'GET /tunnel-status - 隧道状态',
      'POST /webhook - 智能隧道Webhook'
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
    success: true,
    message: 'Webhook已接收，处理时发生异常',
    error: err.message,
    timestamp,
    no_retry: true
  });
});

// 启动服务器
app.listen(PORT, '0.0.0.0', () => {
  const timestamp = new Date().toISOString();
  console.log(`
╔════════════════════════════════════════╗
║     🔗 智能隧道Webhook服务启动         ║
╚════════════════════════════════════════╝
[${timestamp}]
✓ 服务器运行在端口: ${PORT}
🔗 隧道目标: ${LOCAL_TUNNEL_URL}
🚀 核心特性:
   - ✅ 立即返回200，防止外部重试
   - ✅ 异步转发到本地3001端口
   - ✅ 转发失败不影响外部响应
   - ✅ 短超时(5s)快速失败
🔒 安全模式: 纯IP白名单验证（支持网段）
   - 允许的IP/网段: ${ALLOWED_IPS.join(', ')}
📋 端点:
   - 健康检查: GET /health
   - 隧道状态: GET /tunnel-status
   - 智能隧道: POST /webhook
  `);
});