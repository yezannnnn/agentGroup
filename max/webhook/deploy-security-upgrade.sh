#!/bin/bash

# 🛡️ Webhook安全升级部署脚本
SERVER="116.62.114.210"
PASSWORD="Wehook123@"

echo "🛡️ 开始安全增强升级..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 上传安全增强版本
echo "📤 上传安全增强版webhook服务..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no webhook-security-enhanced.js root@$SERVER:/opt/webhooks/

echo "📤 上传安全配置模板..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no .env.security root@$SERVER:/opt/webhooks/

# 2. 远程部署
echo "🚀 执行远程安全升级..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER "
cd /opt/webhooks

echo '📋 备份当前版本...'
cp webhook-server.js webhook-server-basic.js.bak
cp .env .env.basic.bak

echo '🛡️ 应用安全增强版本...'
cp webhook-security-enhanced.js webhook-server.js

echo '⚙️  配置安全参数...'
cat .env.security >> .env
echo '' >> .env

echo '📝 当前安全配置:'
echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
cat .env | grep -E '(ALLOWED_|RATE_LIMIT_|VALID_TOKENS)'

echo ''
echo '🔄 重启服务应用安全设置...'
pm2 restart webhook-service

echo '⏱️  等待服务启动...'
sleep 5

echo '📊 检查服务状态...'
pm2 status

echo ''
echo '🛡️ 测试安全功能...'
echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

echo '1. 测试健康检查:'
curl -s http://localhost:3001/health | head -3

echo ''
echo '2. 测试安全状态:'
curl -s http://localhost:3001/security | head -3

echo ''
echo '✅ 安全升级完成！'
"

echo ""
echo "🎉 安全升级部署完成！"
echo ""
echo "📋 接下来需要您手动配置："
echo "1. SSH到服务器: ssh root@$SERVER"
echo "2. 编辑安全配置: cd /opt/webhooks && nano .env"
echo "3. 配置您的真实IP白名单和域名白名单"
echo "4. 重新生成强随机Token"
echo "5. 重启服务: pm2 restart webhook-service"
echo ""
echo "🔍 查看新的安全功能:"
echo "curl http://$SERVER:3001/security"