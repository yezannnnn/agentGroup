#!/bin/bash

# Webhook无重试隧道服务部署脚本
SERVER="116.62.114.210"
PASSWORD="Webhook123..,@"
DEPLOY_DIR="/opt/webhooks"

echo "🚀 部署Webhook无重试隧道服务..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 上传新的无重试版本
echo "📤 上传无重试版本文件..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no webhook-tunnel-no-retry.js root@$SERVER:$DEPLOY_DIR/
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no .env.tunnel root@$SERVER:$DEPLOY_DIR/.env

# 部署和重启服务
echo "🔄 部署无重试版本并重启服务..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
    cd $DEPLOY_DIR
    echo '🔧 更新服务主文件为无重试版本...'
    cp webhook-tunnel-no-retry.js webhook-server.js
    echo '⚙️ 更新环境配置...'
    cp .env.tunnel .env
    echo '🔄 重启服务...'
    pm2 restart webhook-service
"

# 等待启动
echo "⏱️  等待启动..."
sleep 3

# 查看服务状态
echo "📊 检查服务状态..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
    pm2 status webhook-service
    echo ''
    echo '📋 服务详细信息:'
    pm2 info webhook-service
"

echo "✅ 无重试隧道服务部署完成！"
echo ""
echo "🔍 关键特性:"
echo "  - ✅ 立即返回200，防止外部重试"
echo "  - ✅ 异步转发到本地3001端口"
echo "  - ✅ 转发失败不影响外部响应"
echo "  - ✅ 短超时(5s)快速失败"