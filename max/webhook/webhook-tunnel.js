const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// 🌐 IP白名单配置 - 支持网段匹配
const ALLOWED_IPS = (process.env.ALLOWED_IPS || '182.40.197.*,182.40.196.*,182.40.195.*,182.40.198.*').split(',').map(ip => ip.trim()).filter(ip => ip);

// 🔗 本地隧道配置
const LOCAL_TUNNEL_URL = process.env.LOCAL_TUNNEL_URL || 'http://localhost:8080'; // 您的本地端口
const TUNNEL_ENABLED = process.env.TUNNEL_ENABLED === 'true' || false;

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
    tunnel_config: {
      enabled: TUNNEL_ENABLED,
      target_url: TUNNEL_ENABLED ? LOCAL_TUNNEL_URL : 'disabled',
      allowed_ips: ALLOWED_IPS
    }
  });
});

/**
 * 🔧 隧道配置查看端点
 */
app.get('/tunnel-status', (req, res) => {
  const clientIP = getClientIP(req);
  res.json({
    status: 'tunnel_info',
    timestamp: new Date().toISOString(),
    client_ip: clientIP,
    tunnel: {
      enabled: TUNNEL_ENABLED,
      target_url: LOCAL_TUNNEL_URL,
      mode: TUNNEL_ENABLED ? 'forwarding' : 'local-processing'
    },
    security: {
      ip_whitelist_enabled: ALLOWED_IPS.length > 0,
      allowed_patterns: ALLOWED_IPS,
      total_allowed_ips: ALLOWED_IPS.reduce((acc, pattern) => {
        return acc + (pattern.includes('*') ? 256 : 1);
      }, 0)
    }
  });
});

/**
 * 🌐 Webhook隧道端点 - 支持转发到本地
 */
app.post('/webhook', async (req, res) => {
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);

  try {
    console.log(`✅ 收到Webhook请求 - IP: ${clientIP}`);
    console.log(`📦 数据大小: ${JSON.stringify(req.body).length}字节`);
    console.log(`📦 数据内容:`, JSON.stringify(req.body).substring(0, 200));

    let response;
    let forwardUrl;

    if (TUNNEL_ENABLED) {
      // 🔗 隧道模式：转发到本地
      forwardUrl = `${LOCAL_TUNNEL_URL}/webhook`;
      console.log(`🔗 隧道模式：转发到本地 ${forwardUrl}`);

      response = await axios.post(forwardUrl, req.body, {
        timeout: 15000,
        headers: {
          'Content-Type': 'application/json',
          'X-Forwarded-For': clientIP,
          'X-Original-Host': req.get('host'),
          'X-Tunnel-Source': 'webhook-tunnel'
        }
      });

      console.log(`✅ 本地隧道转发成功，状态码: ${response.status}`);

      // 返回本地服务的响应
      res.status(response.status).json(response.data);

    } else {
      // 🏠 本地模式：直接处理
      console.log(`🏠 本地模式：直接处理请求`);

      // 这里可以添加您的本地处理逻辑
      const processedData = {
        success: true,
        message: 'Webhook processed locally',
        timestamp,
        data: req.body,
        client_ip: clientIP,
        processing_mode: 'local'
      };

      console.log(`✅ 本地处理完成`);
      res.json(processedData);
    }

  } catch (error) {
    const errorTimestamp = new Date().toISOString();
    console.error(`❌ Webhook处理失败 IP: ${clientIP}:`, error.message);

    if (TUNNEL_ENABLED) {
      if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
        console.error(`🔗 无法连接到本地服务: ${LOCAL_TUNNEL_URL}`);
        console.error(`💡 请确保本地服务正在运行，并且端口可访问`);

        return res.status(503).json({
          success: false,
          error: 'Local tunnel service unavailable',
          details: {
            message: '无法连接到本地隧道服务',
            target_url: LOCAL_TUNNEL_URL,
            suggestion: '请检查本地服务是否正在运行',
            error_code: error.code
          },
          timestamp: errorTimestamp
        });
      }

      if (error.response) {
        console.error(`🔗 本地服务返回错误: ${error.response.status}`);
        return res.status(error.response.status).json({
          success: false,
          error: 'Local service error',
          details: error.response.data,
          timestamp: errorTimestamp
        });
      }
    }

    res.status(500).json({
      success: false,
      error: 'Webhook processing failed',
      message: error.message,
      timestamp: errorTimestamp
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
      'GET /tunnel-status - 隧道状态',
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

  res.status(500).json({
    success: false,
    error: 'Server error',
    message: err.message,
    timestamp
  });
});

// 启动服务器
app.listen(PORT, '0.0.0.0', () => {
  const timestamp = new Date().toISOString();
  console.log(`
╔════════════════════════════════════════╗
║      🔗 Webhook隧道服务启动成功        ║
╚════════════════════════════════════════╝
[${timestamp}]
✓ 服务器运行在端口: ${PORT}
🔗 隧道模式: ${TUNNEL_ENABLED ? '✅ 已启用' : '❌ 已禁用'}
${TUNNEL_ENABLED ? `🎯 本地目标: ${LOCAL_TUNNEL_URL}` : '🏠 本地处理模式'}
🔒 安全模式: 纯IP白名单验证（支持网段）
   - 允许的IP/网段: ${ALLOWED_IPS.join(', ')}
📋 端点:
   - 健康检查: GET /health
   - 隧道状态: GET /tunnel-status
   - Webhook接收: POST /webhook ${TUNNEL_ENABLED ? '(转发到本地)' : '(本地处理)'}
🚫 访问控制:
   - 白名单IP → ✅ 直接处理
   - 其他IP → ❌ 403拒绝
  `);
});