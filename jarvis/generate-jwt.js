#!/usr/bin/env node
/**
 * JWT Webhook Token Generator
 * 为GEWE配置生成JWT token
 * 
 * 使用方法:
 * node generate-jwt.js <auth_key> <tenant_id>
 * 
 * 示例:
 * node generate-jwt.js fc86f522-e60c-46ef-8d69-67444dfb75cf 1
 */

const crypto = require('crypto');

// 密钥（与后端一致）
const SECRET = 'wh2026_secure_webhook_key_change_me_in_production';

// Base64URL 编码
function base64UrlEncode(str) {
    return Buffer.from(str)
        .toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
}

// 生成JWT
function generateJWT(authKey, tenantId) {
    // Header
    const header = {
        alg: 'HS256',
        typ: 'JWT'
    };
    
    // Payload
    const payload = {
        ak: authKey,
        tid: parseInt(tenantId, 10)
    };
    
    // 编码header和payload
    const encodedHeader = base64UrlEncode(JSON.stringify(header));
    const encodedPayload = base64UrlEncode(JSON.stringify(payload));
    
    // 创建签名
    const signatureInput = `${encodedHeader}.${encodedPayload}`;
    const signature = crypto
        .createHmac('sha256', SECRET)
        .update(signatureInput)
        .digest('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');
    
    // 组合JWT
    return `${encodedHeader}.${encodedPayload}.${signature}`;
}

// 主程序
function main() {
    const args = process.argv.slice(2);
    
    if (args.length < 2) {
        console.log('\n========================================');
        console.log('  JWT Webhook Token 生成器');
        console.log('========================================\n');
        console.log('用法: node generate-jwt.js <auth_key> <tenant_id>');
        console.log('\n示例:');
        console.log('  node generate-jwt.js fc86f522-e60c-46ef-8d69-67444dfb75cf 1');
        console.log('  node generate-jwt.js 1128b942-a48e-4d23-bd85-cb3b898f28f2 1\n');
        console.log('========================================\n');
        process.exit(1);
    }
    
    const authKey = args[0];
    const tenantId = args[1];
    
    console.log('\n========================================');
    console.log('  正在生成 JWT Token...');
    console.log('========================================\n');
    
    console.log(`Auth Key:  ${authKey}`);
    console.log(`Tenant ID: ${tenantId}\n`);
    
    const token = generateJWT(authKey, tenantId);
    const webhookUrl = `https://twittercloud.cn/webhook/${token}`;
    
    console.log('----------------------------------------');
    console.log('JWT Token:');
    console.log('----------------------------------------');
    console.log(token);
    console.log('\n----------------------------------------');
    console.log('Webhook URL (用于GEWE配置):');
    console.log('----------------------------------------');
    console.log(webhookUrl);
    console.log('\n========================================');
    console.log('  生成完成！');
    console.log('========================================\n');
}

main();
