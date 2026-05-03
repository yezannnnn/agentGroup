#!/bin/bash

# IP网段白名单Webhook服务部署脚本
SERVER="116.62.114.210"
PASSWORD="Wehook123@"
DEPLOY_DIR="/opt/webhooks"

echo "🌐 部署IP网段白名单Webhook服务..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 上传文件
echo "📤 上传IP网段验证版本文件..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no webhook-ip-only.js root@$SERVER:$DEPLOY_DIR/
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no .env.ip-only root@$SERVER:$DEPLOY_DIR/.env

# 部署和重启服务
echo "🔄 部署并重启服务..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
    cd $DEPLOY_DIR
    echo '🔧 更新服务主文件...'
    cp webhook-ip-only.js webhook-server.js
    echo '⚙️ 更新环境配置...'
    cp .env.ip-only .env
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
echo "📋 测试IP网段验证..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
    cd $DEPLOY_DIR
    pm2 logs webhook-service --lines 10 --raw
"

echo ""
echo "✅ IP网段白名单版本部署完成！"
echo "🌐 允许的网段: 182.40.197.* (182.40.197.0-182.40.197.255)"
echo "🚫 其他IP将被拒绝访问"
echo ""
echo "💡 测试命令:"
echo "  curl -X POST http://116.62.114.210:3001/webhook -H 'Content-Type: application/json' -d '{\"test\":\"subnet_check\"}'"
echo ""
echo "🔍 支持的IP匹配格式:"
echo "  - 精确IP: 182.40.197.231"
echo "  - 通配符: 182.40.197.*"
echo "  - CIDR: 182.40.197.0/24"