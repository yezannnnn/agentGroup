const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const NESTJS_URL = process.env.NESTJS_URL || 'http://localhost:3000';

// 🌐 IP白名单配置 - 支持网段匹配
const ALLOWED_IPS = (process.env.ALLOWED_IPS || '182.40.197.*').split(',').map(ip => ip.trim()).filter(ip => ip);

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

      // 简单的CIDR匹配实现
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
 * GET /health
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
      nestjs_url: NESTJS_URL,
      allowed_ips: ALLOWED_IPS,
      ip_security: true,
      domain_security: false,
      token_security: false
    }
  });
});

/**
 * 🔍 安全配置查看端点
 * GET /security
 */
app.get('/security', (req, res) => {
  const clientIP = getClientIP(req);
  res.json({
    status: 'security_info',
    timestamp: new Date().toISOString(),
    client_ip: clientIP,
    security_model: 'ip-whitelist-only',
    configuration: {
      allowed_ips: ALLOWED_IPS,
      ip_whitelist_enabled: ALLOWED_IPS.length > 0,
      domain_validation: false,
      token_validation: false,
      allowed_ips_count: ALLOWED_IPS.length
    },
    request_info: {
      your_ip: clientIP,
      user_agent: req.get('user-agent'),
      headers_forwarded_for: req.headers['x-forwarded-for'],
      headers_real_ip: req.headers['x-real-ip']
    }
  });
});

/**
 * 🔒 IP验证Webhook接收端点
 * POST /webhook
 */
app.post('/webhook', async (req, res) => {
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);

  try {
    console.log(`✅ IP验证Webhook请求 - IP: ${clientIP}`);
    console.log(`📦 接收到webhook数据 (${JSON.stringify(req.body).length}字节):`,
      JSON.stringify(req.body).substring(0, 200));

    // 构建转发payload
    const payload = {
      data: req.body,
      receivedAt: timestamp,
      clientInfo: {
        ip: clientIP,
        userAgent: req.get('user-agent'),
        securityMethod: 'ip-whitelist',
        ipAllowed: true
      }
    };

    // 转发到NestJS服务
    const forwardUrl = `${NESTJS_URL}/api/wechat/process`;
    console.log(`📤 转发到: ${forwardUrl}`);

    const response = await axios.post(forwardUrl, payload, {
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log(`✅ 转发成功，状态码: ${response.status}`);

    // 返回成功响应
    res.json({
      success: true,
      message: 'Webhook processed successfully',
      timestamp,
      nestjs_response_status: response.status,
      security_check: 'ip-verified',
      client_ip: clientIP
    });

  } catch (error) {
    const errorTimestamp = new Date().toISOString();
    console.error(`❌ 处理webhook失败 IP: ${clientIP}:`, error.message);

    if (error.response) {
      // NestJS服务返回了错误响应
      console.error(`NestJS错误状态码: ${error.response.status}`);

      return res.status(error.response.status).json({
        success: false,
        error: 'Failed to process webhook at NestJS service',
        details: error.response.data,
        timestamp: errorTimestamp
      });
    } else if (error.request) {
      // 请求已发送但没有收到响应
      console.error(`无法连接到NestJS服务: ${NESTJS_URL}`);

      return res.status(503).json({
        success: false,
        error: 'Cannot reach NestJS service',
        nestjs_url: NESTJS_URL,
        timestamp: errorTimestamp
      });
    } else {
      // 其他错误
      console.error(`未知错误:`, error);

      return res.status(500).json({
        success: false,
        error: 'Internal server error',
        timestamp: errorTimestamp
      });
    }
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
    path: req.path,
    method: req.method,
    note: '提示：Webhook端点是 POST /webhook',
    client_ip: clientIP,
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
║     🔒 IP验证Webhook服务启动成功       ║
╚════════════════════════════════════════╝
[${timestamp}]
✓ 服务器运行在端口: ${PORT}
✓ NestJS目标服务: ${NESTJS_URL}
🔒 安全模式: 纯IP白名单验证（支持网段）
   - 允许的IP/网段: ${ALLOWED_IPS.length > 0 ? ALLOWED_IPS.join(', ') : '⚠️ 未配置(允许所有)'}
   - 域名验证: ❌ 已禁用
   - Token验证: ❌ 已禁用
📋 端点:
   - 健康检查: GET /health
   - 安全状态: GET /security
   - Webhook接收: POST /webhook (无需token)
🚫 访问控制:
   - 白名单IP → ✅ 直接处理
   - 其他IP → ❌ 403拒绝 + 详细错误信息
  `);
});