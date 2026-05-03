#!/bin/bash

# 模拟微信Webhook请求测试脚本
SERVER="116.62.114.210"
PORT="3001"
TOKEN="webhook_token_123"

echo "🚀 微信Webhook模拟测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "服务器: $SERVER:$PORT"
echo "Token: $TOKEN"
echo ""

# 模拟微信消息格式
echo "📱 模拟微信文本消息"
echo "执行中..."
curl -X POST http://$SERVER:$PORT/webhook/$TOKEN \
  -H "Content-Type: application/json" \
  -d '{
    "msgType": "text",
    "content": "你好，这是一条测试消息",
    "fromUser": "test_user_001",
    "toUser": "webhook_bot",
    "timestamp": "'$(date +%s)'",
    "msgId": "'$(date +%s%N | cut -b1-13)'"
  }' && echo ""

sleep 1

echo ""
echo "🖼️ 模拟微信图片消息"
echo "执行中..."
curl -X POST http://$SERVER:$PORT/webhook/$TOKEN \
  -H "Content-Type: application/json" \
  -d '{
    "msgType": "image",
    "mediaId": "test_media_12345",
    "picUrl": "https://example.com/image.jpg",
    "fromUser": "test_user_002",
    "toUser": "webhook_bot",
    "timestamp": "'$(date +%s)'"
  }' && echo ""

sleep 1

echo ""
echo "🔗 模拟微信链接消息"
echo "执行中..."
curl -X POST http://$SERVER:$PORT/webhook/$TOKEN \
  -H "Content-Type: application/json" \
  -d '{
    "msgType": "link",
    "title": "测试链接标题",
    "description": "这是一个测试链接的描述信息",
    "url": "https://example.com/test",
    "fromUser": "test_user_003",
    "toUser": "webhook_bot",
    "timestamp": "'$(date +%s)'"
  }' && echo ""

sleep 1

echo ""
echo "❌ 测试无效Token"
echo "执行中..."
curl -X POST http://$SERVER:$PORT/webhook/invalid_token_test \
  -H "Content-Type: application/json" \
  -d '{
    "msgType": "text",
    "content": "这个请求应该失败",
    "fromUser": "test_user_004",
    "toUser": "webhook_bot",
    "timestamp": "'$(date +%s)'"
  }' && echo ""

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 测试完成！"
echo ""
echo "📋 查看服务器日志:"
echo "./log-viewer.sh webhook"
echo ""
echo "📋 查看最新日志:"
echo "./log-viewer.sh tail 20"
echo ""
echo "📋 实时监控:"
echo "./log-viewer.sh live"