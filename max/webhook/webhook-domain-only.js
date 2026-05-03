const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;
const NESTJS_URL = process.env.NESTJS_URL || 'http://localhost:3000';

// 🌐 只需要域名白名单配置
const ALLOWED_DOMAINS = (process.env.ALLOWED_DOMAINS || '').split(',').map(d => d.trim()).filter(d => d);

// 🛡️ 获取客户端真实IP（用于日志）
function getClientIP(req) {
  return req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
         req.headers['x-real-ip'] ||
         req.connection?.remoteAddress ||
         req.socket?.remoteAddress ||
         req.ip;
}

// 🌐 域名验证中间件
function domainCheckMiddleware(req, res, next) {
  const clientIP = getClientIP(req);
  const referer = req.headers.referer;
  const origin = req.headers.origin;
  const host = req.headers.host;
  const userAgent = req.get('user-agent');

  // 如果没有配置域名白名单，允许所有请求（仅用于测试）
  if (ALLOWED_DOMAINS.length === 0) {
    console.log(`⚠️ 警告: 未配置域名白名单，允许所有请求`);
    return next();
  }

  // 检查域名的函数
  const checkDomain = (url) => {
    if (!url) return false;
    try {
      const domain = new URL(url).hostname;
      return ALLOWED_DOMAINS.some(allowed => {
        // 精确匹配或子域名匹配
        return domain === allowed || domain.endsWith('.' + allowed);
      });
    } catch {
      // 如果不是完整URL，直接比较
      return ALLOWED_DOMAINS.includes(url);
    }
  };

  // 检查各种可能的域名头
  const isRefererAllowed = checkDomain(referer);
  const isOriginAllowed = checkDomain(origin);
  const isHostAllowed = ALLOWED_DOMAINS.includes(host);

  const isAllowed = isRefererAllowed || isOriginAllowed || isHostAllowed;

  // 详细日志记录
  console.log(`🔍 域名检查 [IP: ${clientIP}]:`);
  console.log(`   - Referer: ${referer} ${isRefererAllowed ? '✅' : '❌'}`);
  console.log(`   - Origin: ${origin} ${isOriginAllowed ? '✅' : '❌'}`);
  console.log(`   - Host: ${host} ${isHostAllowed ? '✅' : '❌'}`);
  console.log(`   - User-Agent: ${userAgent}`);
  console.log(`   - 最终结果: ${isAllowed ? '✅ 允许' : '❌ 拒绝'}`);

  if (!isAllowed) {
    console.log(`🚫 域名访问被拒绝: IP=${clientIP}`);

    return res.status(403).json({
      success: false,
      error: 'Access denied - Domain not allowed',
      details: {
        message: '访问被拒绝：域名不在白名单中',
        your_referer: referer || 'none',
        your_origin: origin || 'none',
        your_host: host || 'none',
        allowed_domains: ALLOWED_DOMAINS,
        client_ip: clientIP
      },
      timestamp: new Date().toISOString()
    });
  }

  console.log(`✅ 域名验证通过: IP=${clientIP}`);
  next();
}

// 中间件配置
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// 🌐 应用域名验证中间件到所有路由
app.use(domainCheckMiddleware);

// 请求日志中间件（在域名检查之后）
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
      allowed_domains: ALLOWED_DOMAINS,
      domain_security: true,
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
    security_model: 'domain-whitelist-only',
    configuration: {
      allowed_domains: ALLOWED_DOMAINS,
      domain_whitelist_enabled: ALLOWED_DOMAINS.length > 0,
      token_validation: false,
      allowed_domains_count: ALLOWED_DOMAINS.length
    },
    request_headers: {
      referer: req.headers.referer,
      origin: req.headers.origin,
      host: req.headers.host,
      user_agent: req.get('user-agent')
    }
  });
});

/**
 * 🌐 简化的Webhook接收端点（无需token）
 * POST /webhook
 */
app.post('/webhook', async (req, res) => {
  const timestamp = new Date().toISOString();
  const clientIP = getClientIP(req);

  try {
    console.log(`✅ 域名验证Webhook请求 - IP: ${clientIP}`);
    console.log(`📦 接收到webhook数据 (${JSON.stringify(req.body).length}字节):`,
      JSON.stringify(req.body).substring(0, 200));

    // 构建转发payload（无token）
    const payload = {
      data: req.body,
      receivedAt: timestamp,
      clientInfo: {
        ip: clientIP,
        userAgent: req.get('user-agent'),
        referer: req.get('referer'),
        origin: req.get('origin'),
        host: req.get('host')
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
      security_check: 'domain-verified'
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
║    🌐 域名验证Webhook服务启动成功      ║
╚════════════════════════════════════════╝
[${timestamp}]
✓ 服务器运行在端口: ${PORT}
✓ NestJS目标服务: ${NESTJS_URL}
🌐 安全模式: 纯域名白名单验证
   - 允许的域名: ${ALLOWED_DOMAINS.length > 0 ? ALLOWED_DOMAINS.join(', ') : '⚠️ 未配置(允许所有)'}
   - Token验证: ❌ 已禁用
📋 端点:
   - 健康检查: GET /health
   - 安全状态: GET /security
   - Webhook接收: POST /webhook (无需token)
🚫 访问控制:
   - 允许的域名 → ✅ 直接处理
   - 其他域名 → ❌ 403拒绝 + 详细错误信息
  `);
});