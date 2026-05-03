#!/bin/bash

# Webhook服务远程部署脚本
# 目标服务器: 116.62.114.210
# 部署目录: /opt/webhooks

set -e  # 遇到错误立即退出

SERVER="116.62.114.210"
USER="root"
PASSWORD="Wehook123@"
DEPLOY_DIR="/opt/webhooks"
LOCAL_PACKAGE="webhook-service.tar.gz"

echo "🚀 开始部署Webhook服务到服务器..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查本地打包文件
if [ ! -f "$LOCAL_PACKAGE" ]; then
    echo "❌ 错误: 找不到打包文件 $LOCAL_PACKAGE"
    exit 1
fi

echo "✅ 找到本地打包文件: $LOCAL_PACKAGE"

# 使用sshpass进行自动化SSH连接和文件传输
# 注意：sshpass需要先安装，如果没有会提示安装

echo "📁 创建远程目录和上传文件..."

# 创建远程目录
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$SERVER" "
    mkdir -p $DEPLOY_DIR
    echo '✅ 远程目录已创建: $DEPLOY_DIR'
"

# 上传打包文件
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no "$LOCAL_PACKAGE" "$USER@$SERVER:$DEPLOY_DIR/"

echo "✅ 文件上传完成"

# 远程部署脚本
echo "🔧 执行远程部署..."

sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$SERVER" "
    cd $DEPLOY_DIR

    echo '📦 解压代码包...'
    tar -xzf webhook-service.tar.gz
    rm webhook-service.tar.gz

    echo '🔍 检查Node.js和npm...'
    if ! command -v node &> /dev/null; then
        echo '⚠️  Node.js未安装，正在安装...'
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        apt-get install -y nodejs
    fi

    echo '📋 Node.js版本:'
    node --version
    npm --version

    echo '📦 安装项目依赖...'
    npm install

    echo '🔧 安装和配置pm2...'
    npm install -g pm2

    echo '⚙️  配置环境变量...'
    if [ ! -f .env ]; then
        cp .env.example .env
        echo '✅ 已创建.env文件，请检查配置'
    fi

    echo '🔄 停止可能运行的webhook服务...'
    pm2 delete webhook-service 2>/dev/null || true

    echo '🚀 启动webhook服务...'
    pm2 start webhook-server.js --name webhook-service

    echo '💾 保存pm2配置...'
    pm2 save
    pm2 startup

    echo '📊 显示服务状态...'
    pm2 status

    echo '🔍 显示服务日志...'
    pm2 logs webhook-service --lines 10

    echo '✅ 部署完成！'
    echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
    echo '📋 服务信息:'
    echo '   - 服务名称: webhook-service'
    echo '   - 部署目录: $DEPLOY_DIR'
    echo '   - 端口: 3001 (可在.env中修改)'
    echo '   - 健康检查: http://$SERVER:3001/health'
    echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
    echo '📖 常用管理命令:'
    echo '   pm2 status                    # 查看服务状态'
    echo '   pm2 logs webhook-service      # 查看日志'
    echo '   pm2 restart webhook-service   # 重启服务'
    echo '   pm2 stop webhook-service      # 停止服务'
    echo '   pm2 delete webhook-service    # 删除服务'
"

echo ""
echo "🎉 部署脚本执行完成！"
echo ""
echo "🔗 测试连接:"
echo "curl http://$SERVER:3001/health"
echo ""
echo "📝 请确保:"
echo "1. 检查服务器的.env文件配置"
echo "2. 确保端口3001在防火墙中开放"
echo "3. 根据需要配置HTTPS(nginx反向代理)"