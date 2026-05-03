#!/bin/bash

# Webhook服务测试脚本
SERVER="116.62.114.210"
PORT="3001"
TOKEN="webhook_token_123"

echo "🧪 Webhook服务功能测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "服务器: $SERVER:$PORT"
echo "测试Token: $TOKEN"
echo ""

# 测试1: 健康检查
echo "📋 测试1: 健康检查"
echo "GET http://$SERVER:$PORT/health"
echo "执行: curl -m 5 http://$SERVER:$PORT/health"
echo "结果:"
curl -m 5 -s http://$SERVER:$PORT/health && echo "" || echo "❌ 连接失败 - 可能是安全组未开放3001端口"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 测试2: Webhook接收
echo "📋 测试2: Webhook接收"
echo "POST http://$SERVER:$PORT/webhook/$TOKEN"
echo "执行: curl -X POST http://$SERVER:$PORT/webhook/$TOKEN -d '{\"test\":\"data\"}'"
echo "结果:"
curl -m 5 -X POST http://$SERVER:$PORT/webhook/$TOKEN \
  -H "Content-Type: application/json" \
  -d '{"test":"data","message":"hello webhook"}' && echo "" || echo "❌ 连接失败"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 测试3: 无效Token
echo "📋 测试3: 无效Token测试"
echo "POST http://$SERVER:$PORT/webhook/invalid_token"
echo "执行: curl -X POST http://$SERVER:$PORT/webhook/invalid_token"
echo "结果:"
curl -m 5 -X POST http://$SERVER:$PORT/webhook/invalid_token \
  -H "Content-Type: application/json" \
  -d '{"test":"invalid"}' && echo "" || echo "❌ 连接失败"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "💡 如果以上测试全部连接失败，请检查："
echo "1. 阿里云安全组是否开放了3001端口"
echo "2. 服务器防火墙配置"
echo "3. 网络连接是否正常"
echo ""
echo "🔧 阿里云安全组配置:"
echo "- 登录阿里云控制台 > ECS > 安全组"
echo "- 添加规则: 入方向，端口3001，源地址0.0.0.0/0"
echo ""
echo "📱 微信平台配置URL:"
echo "http://$SERVER:$PORT/webhook/你的token"
echo ""
echo "📊 服务器内部状态检查:"
echo "ssh root@$SERVER"
echo "pm2 status"
echo "pm2 logs webhook-service"