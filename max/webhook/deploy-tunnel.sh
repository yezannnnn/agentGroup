#!/bin/bash

# Webhook隧道服务部署脚本
SERVER="116.62.114.210"
PASSWORD="Wehook123@"
DEPLOY_DIR="/opt/webhooks"

echo "🔗 部署Webhook隧道服务..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 上传文件
echo "📤 上传隧道版本文件..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no webhook-tunnel.js root@$SERVER:$DEPLOY_DIR/
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no .env.tunnel root@$SERVER:$DEPLOY_DIR/.env

# 部署和重启服务
echo "🔄 部署并重启服务..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
    cd $DEPLOY_DIR
    echo '🔧 更新服务主文件...'
    cp webhook-tunnel.js webhook-server.js
    echo '⚙️ 更新环境配置...'
    cp .env.tunnel .env
    echo '🔄 重启服务...'
    pm2 restart webhook-service
"

# 等待启动
echo "⏱️  等待启动..."
sleep 3

# 检查状态
echo "📊 检查状态..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
    cd $DEPLOY_DIR
    pm2 status
"

echo ""
echo "📋 查看隧道配置..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
    cd $DEPLOY_DIR
    pm2 logs webhook-service --lines 15 --raw
"

echo ""
echo "✅ Webhook隧道服务部署完成！"
echo ""
echo "🔗 隧道配置:"
echo "  - 服务器端点: http://116.62.114.210:3001/webhook"
echo "  - 本地目标: http://localhost:3000/webhook"
echo "  - 允许IP网段: 182.40.197.*,182.40.196.*,182.40.195.*,182.40.198.*"
echo ""
echo "📋 下一步操作:"
echo "  1. 在本地启动接收服务: node local-webhook-receiver.js"
echo "  2. 测试隧道状态: curl http://116.62.114.210:3001/tunnel-status"
echo "  3. 发送测试请求验证隧道功能"
echo ""
echo "⚠️ 重要提醒:"
echo "  - 确保本地端口3000可访问"
echo "  - 确保网络连接稳定"
echo "  - 建议使用内网穿透工具(如ngrok)提供公网访问"