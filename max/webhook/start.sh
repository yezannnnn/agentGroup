#!/bin/bash

# Webhook服务启动脚本

set -e

echo "╔════════════════════════════════════════╗"
echo "║   Webhook代理服务启动脚本             ║"
echo "╚════════════════════════════════════════╝"

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "📁 工作目录: $SCRIPT_DIR"

# 检查.env文件
if [ ! -f .env ]; then
  echo "❌ 错误: 找不到 .env 配置文件"
  echo "💡 提示: 请复制 .env.example 为 .env 并修改配置"
  exit 1
fi

echo "✓ 找到 .env 配置文件"

# 读取配置
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# 检查Node.js
if ! command -v node &> /dev/null; then
  echo "❌ 错误: 未找到 Node.js"
  echo "💡 提示: 请先安装 Node.js (https://nodejs.org/)"
  exit 1
fi

NODE_VERSION=$(node -v)
echo "✓ Node.js版本: $NODE_VERSION"

# 检查npm
if ! command -v npm &> /dev/null; then
  echo "❌ 错误: 未找到 npm"
  exit 1
fi

echo "✓ npm已安装"

# 安装依赖
if [ ! -d node_modules ]; then
  echo "📦 安装依赖包..."
  npm install
  echo "✓ 依赖安装完成"
else
  echo "✓ 依赖已存在，跳过安装"
fi

# 显示配置信息
echo ""
echo "╔════════════════════════════════════════╗"
echo "║        当前配置信息                  ║"
echo "╚════════════════════════════════════════╝"
echo "🔌 监听端口: ${PORT:-3001}"
echo "🎯 NestJS服务: ${NESTJS_URL:-http://localhost:3000}"
echo "🔐 配置的Token数: $(echo ${VALID_TOKENS} | tr ',' '\n' | wc -l)"
echo "🌍 环境: ${NODE_ENV:-development}"
echo ""

# 启动服务
echo "🚀 启动Webhook服务..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
npm start
