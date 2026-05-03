#!/bin/bash

# 🌐 部署纯域名验证版本
SERVER="116.62.114.210"
PASSWORD="Wehook123@"

echo "🌐 部署纯域名验证Webhook服务..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 上传文件
echo "📤 上传域名验证版本..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no webhook-domain-only.js root@$SERVER:/opt/webhooks/
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no .env.domain-only root@$SERVER:/opt/webhooks/

# 远程部署
echo "🚀 执行远程部署..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
cd /opt/webhooks

echo '📋 备份当前版本...'
cp webhook-server.js webhook-server-backup.js
cp .env .env.backup

echo '🌐 应用域名验证版本...'
cp webhook-domain-only.js webhook-server.js

echo '⚙️  更新配置...'
# 清空现有配置
> .env
# 添加域名验证配置
cat .env.domain-only > .env

echo '📝 当前配置:'
echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
cat .env

echo ''
echo '🔄 重启服务...'
pm2 restart webhook-service

echo '⏱️  等待启动...'
sleep 5

echo '📊 服务状态:'
pm2 status

echo ''
echo '🧪 测试配置:'
echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

echo '1. 健康检查:'
curl -s http://localhost:3001/health | head -3

echo ''
echo '2. 安全配置:'
curl -s http://localhost:3001/security | head -5
"

echo ""
echo "✅ 部署完成！"
echo ""
echo "🌐 访问控制规则:"
echo "✅ api.geweapi.com → 允许访问"
echo "❌ 其他任何域名 → 403拒绝"
echo ""
echo "📝 新的Webhook URL (无需token):"
echo "http://$SERVER:3001/webhook"