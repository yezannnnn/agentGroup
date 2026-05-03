const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const NESTJS_URL = process.env.NESTJS_URL || 'http://localhost:3000';
const VALID_TOKENS = (process.env.VALID_TOKENS || '').split(',').map(t => t.trim()).filter(t => t);

// 🛡️ 安全配置
const ALLOWED_IPS = (process.env.ALLOWED_IPS || '').split(',').map(ip => ip.trim()).filter(ip => ip);
const ALLOWED_DOMAINS = (process.env.ALLOWED_DOMAINS || '').split(',').map(d => d.trim()).filter(d => d);
const RATE_LIMIT_WINDOW = parseInt(process.env.RATE_LIMIT_WINDOW) || 60000; // 1分钟
const RATE_LIMIT_MAX = parseInt(process.env.RATE_LIMIT_MAX) || 10; // 每分钟最多10次

// 🕐 请求频率限制记录
const requestCounts = new Map();

// 🛡️ 获取客户端真实IP（支持代理）
function getClientIP(req) {
  return req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
         req.headers['x-real-ip'] ||
         req.connection?.remoteAddress ||
         req.socket?.remoteAddress ||
         req.ip;
}

// 🛡️ IP白名单验证中间件
function ipWhitelistMiddleware(req, res, next) {
  // 如果没有配置IP白名单，跳过检查
  if (ALLOWED_IPS.length === 0) {
    return next();
  }

  const clientIP = getClientIP(req);
  const isAllowed = ALLOWED_IPS.some(allowedIP => {
    // 支持CIDR格式，简单处理
    if (allowedIP.includes('/')) {
      // 简化的CIDR检查，生产环境建议使用专业库
      const [network, prefix] = allowedIP.split('/');
      return clientIP.startsWith(network.split('.').slice(0, Math.floor(prefix / 8)).join('.'));
    }
    return clientIP === allowedIP || clientIP.includes(allowedIP);
  });

  if (!isAllowed) {
    console.log(`🚫 IP访问被拒绝: ${clientIP}`);
    return res.status(403).json({
      success: false,
      error: 'Access denied - IP not allowed',
      timestamp: new Date().toISOString()
    });
  }

  next();
}

// 🛡️ 域名白名单验证中间件
function domainWhitelistMiddleware(req, res, next) {
  // 如果没有配置域名白名单，跳过检查
  if (ALLOWED_DOMAINS.length === 0) {
    return next();
  }

  const referer = req.headers.referer;
  const origin = req.headers.origin;
  const host = req.headers.host;

  let isAllowed = false;

  // 检查Referer、Origin或Host头
  const checkDomain = (url) => {
    if (!url) return false;
    try {
      const domain = new URL(url).hostname;
      return ALLOWED_DOMAINS.some(allowed =>
        domain === allowed || domain.endsWith('.' + allowed)
      );
    } catch {
      return ALLOWED_DOMAINS.includes(url);
    }
  };

  isAllowed = checkDomain(referer) || checkDomain(origin) || ALLOWED_DOMAINS.includes(host);

  if (!isAllowed) {
    console.log(`🚫 域名访问被拒绝: referer=${referer}, origin=${origin}, host=${host}`);
    return res.status(403).json({
      success: false,
      error: 'Access denied - Domain not allowed',
      timestamp: new Date().toISOString()
    });
  }

  next();
}

// 🛡️ 请求频率限制中间件
function rateLimitMiddleware(req, res, next) {
  const clientIP = getClientIP(req);
  const now = Date.now();
  const windowStart = now - RATE_LIMIT_WINDOW;

  // 清理过期记录
  for (const [ip, timestamps] of requestCounts.entries()) {
    const validTimestamps = timestamps.filter(ts => ts > windowStart);
    if (validTimestamps.length === 0) {
      requestCounts.delete(ip);
    } else {
      requestCounts.set(ip, validTimestamps);
    }
  }

  // 检查当前IP请求频率
  const ipRequests = requestCounts.get(clientIP) || [];
  const recentRequests = ipRequests.filter(ts => ts > windowStart);

  if (recentRequests.length >= RATE_LIMIT_MAX) {
    console.log(`🚫 请求频率超限: ${clientIP} (${recentRequests.length}/${RATE_LIMIT_MAX})`);
    return res.status(429).json({
      success: false,
      error: 'Rate limit exceeded',
      retryAfter: Math.ceil(RATE_LIMIT_WINDOW / 1000),
      timestamp: new Date().toISOString()
    });
  }

  // 记录当前请求
  recentRequests.push(now);
  requestCounts.set(clientIP, recentRequests);

  next();
}

// 中间件配置
app.use(express.json({ limit: '1mb' })); // 限制请求体大小
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// 🛡️ 安全中间件应用顺序很重要
app.use(rateLimitMiddleware);      // 1. 频率限制
app.use(ipWhitelistMiddleware);    // 2. IP白名单
app.use(domainWhitelistMiddleware); // 3. 域名白名单

// 请求日志中间件（在安全检查之后）
app.use((req, _res, next) => {
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);
  console.log(`[${timestamp}] ${req.method} ${req.path} - IP: ${clientIP}`);
  next();
});

/**
 * 🔍 安全状态检查端点
 * GET /security
 */
app.get('/security', (req, res) => {
  const clientIP = getClientIP(req);
  const securityInfo = {
    status: 'security_info',
    timestamp: new Date().toISOString(),
    client_ip: clientIP,
    security_features: {
      token_validation: true,
      ip_whitelist: ALLOWED_IPS.length > 0,
      domain_whitelist: ALLOWED_DOMAINS.length > 0,
      rate_limiting: true
    },
    configuration: {
      allowed_ips_count: ALLOWED_IPS.length,
      allowed_domains_count: ALLOWED_DOMAINS.length,
      rate_limit: `${RATE_LIMIT_MAX}/${RATE_LIMIT_WINDOW/1000}s`,
      valid_tokens_count: VALID_TOKENS.length
    }
  };

  res.json(securityInfo);
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
      valid_tokens_count: VALID_TOKENS.length,
      security_enabled: true
    }
  });
});

/**
 * 🛡️ 安全增强的Webhook接收端点
 * POST /webhook/:token
 */
app.post('/webhook/:token', async (req, res) => {
  const { token } = req.params;
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);

  try {
    // Token验证
    if (!VALID_TOKENS.includes(token)) {
      console.log(`🚫 无效Token尝试: ${token} - IP: ${clientIP}`);
      return res.status(401).json({
        success: false,
        error: 'Invalid token',
        timestamp
      });
    }

    console.log(`✅ Token验证成功: ${token} - IP: ${clientIP}`);
    console.log(`📦 接收到webhook数据 (${JSON.stringify(req.body).length}字节):`,
      JSON.stringify(req.body).substring(0, 200));

    // 构建转发payload
    const payload = {
      token: token,
      data: req.body,
      receivedAt: timestamp,
      clientInfo: {
        ip: clientIP,
        userAgent: req.get('user-agent'),
        referer: req.get('referer'),
        origin: req.get('origin')
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
      nestjs_response_status: response.status
    });

  } catch (error) {
    const errorTimestamp = new Date().toISOString();
    console.error(`❌ 处理webhook失败 [${token}] IP: ${clientIP}:`, error.message);

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
║    🛡️ 安全增强Webhook服务启动成功      ║
╚════════════════════════════════════════╝
[${timestamp}]
✓ 服务器运行在端口: ${PORT}
✓ NestJS目标服务: ${NESTJS_URL}
✓ 配置的Token数量: ${VALID_TOKENS.length}
🛡️ 安全功能:
  - Token验证: ✅
  - IP白名单: ${ALLOWED_IPS.length > 0 ? `✅ (${ALLOWED_IPS.length}个)` : '❌ 未配置'}
  - 域名白名单: ${ALLOWED_DOMAINS.length > 0 ? `✅ (${ALLOWED_DOMAINS.length}个)` : '❌ 未配置'}
  - 请求频率限制: ✅ (${RATE_LIMIT_MAX}次/${RATE_LIMIT_WINDOW/1000}秒)
  - 请求体大小限制: ✅ (1MB)
📋 端点:
  - 健康检查: GET /health
  - 安全状态: GET /security
  - Webhook接收: POST /webhook/:token
  `);
});