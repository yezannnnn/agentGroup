#!/bin/bash

# Webhook服务验证脚本

echo "╔════════════════════════════════════════╗"
echo "║     Webhook服务验证脚本               ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 检查Node.js
echo "🔍 检查Node.js..."
if command -v node &> /dev/null; then
  NODE_VERSION=$(node -v)
  echo "✓ Node.js: $NODE_VERSION"
else
  echo "❌ 未安装Node.js"
  exit 1
fi

# 检查npm
echo "🔍 检查npm..."
if command -v npm &> /dev/null; then
  NPM_VERSION=$(npm -v)
  echo "✓ npm: $NPM_VERSION"
else
  echo "❌ 未安装npm"
  exit 1
fi

# 检查.env文件
echo "🔍 检查.env配置文件..."
if [ -f .env ]; then
  echo "✓ .env 文件存在"

  # 检查必要的环境变量
  if grep -q "NESTJS_URL" .env; then
    NESTJS_URL=$(grep "NESTJS_URL" .env | cut -d '=' -f 2 | xargs)
    echo "  ├─ NESTJS_URL: $NESTJS_URL"
  fi

  if grep -q "PORT" .env; then
    PORT=$(grep "^PORT=" .env | cut -d '=' -f 2 | xargs)
    echo "  ├─ PORT: $PORT"
  fi

  if grep -q "VALID_TOKENS" .env; then
    TOKEN_COUNT=$(grep "VALID_TOKENS" .env | cut -d '=' -f 2 | tr ',' '\n' | wc -l)
    echo "  └─ VALID_TOKENS数量: $TOKEN_COUNT"
  fi
else
  echo "❌ .env 文件不存在"
  echo "💡 提示: 请运行: cp .env.example .env"
  exit 1
fi

# 检查依赖
echo ""
echo "🔍 检查依赖..."
if [ -d node_modules ]; then
  echo "✓ node_modules 目录存在"

  if [ -f node_modules/express/package.json ]; then
    EXPRESS_VERSION=$(grep '"version"' node_modules/express/package.json | head -1 | cut -d '"' -f 4)
    echo "  ├─ express: $EXPRESS_VERSION"
  fi

  if [ -f node_modules/axios/package.json ]; then
    AXIOS_VERSION=$(grep '"version"' node_modules/axios/package.json | head -1 | cut -d '"' -f 4)
    echo "  ├─ axios: $AXIOS_VERSION"
  fi

  if [ -f node_modules/dotenv/package.json ]; then
    DOTENV_VERSION=$(grep '"version"' node_modules/dotenv/package.json | head -1 | cut -d '"' -f 4)
    echo "  └─ dotenv: $DOTENV_VERSION"
  fi
else
  echo "⚠️  node_modules 目录不存在"
  echo "💡 提示: 需要运行: npm install"
fi

# 检查主服务文件
echo ""
echo "🔍 检查服务文件..."
if [ -f webhook-server.js ]; then
  echo "✓ webhook-server.js 存在"

  # 检查关键函数
  if grep -q "app.get.*health" webhook-server.js; then
    echo "  ├─ /health 端点: ✓"
  fi

  if grep -q "app.post.*webhook" webhook-server.js; then
    echo "  ├─ /webhook/:token 端点: ✓"
  fi

  if grep -q "axios.post" webhook-server.js; then
    echo "  └─ NestJS转发功能: ✓"
  fi
else
  echo "❌ webhook-server.js 不存在"
  exit 1
fi

# 检查启动脚本
echo ""
echo "🔍 检查启动脚本..."
if [ -f start.sh ]; then
  if [ -x start.sh ]; then
    echo "✓ start.sh 存在且可执行"
  else
    echo "⚠️  start.sh 存在但不可执行"
    echo "💡 提示: 运行: chmod +x start.sh"
  fi
else
  echo "❌ start.sh 不存在"
  exit 1
fi

# 检查package.json
echo ""
echo "🔍 检查package.json..."
if [ -f package.json ]; then
  echo "✓ package.json 存在"

  if grep -q '"main".*webhook-server.js' package.json; then
    echo "  ├─ 入口文件: ✓"
  fi

  if grep -q '"start".*npm' package.json; then
    echo "  └─ start脚本: ✓"
  fi
else
  echo "❌ package.json 不存在"
  exit 1
fi

# 最终检查
echo ""
echo "╔════════════════════════════════════════╗"
echo "║           验证结果                    ║"
echo "╚════════════════════════════════════════╝"

MISSING=false

if [ ! -f .env ]; then
  MISSING=true
fi

if [ ! -d node_modules ]; then
  MISSING=true
fi

if $MISSING; then
  echo "⚠️  部分配置缺失"
  echo ""
  echo "修复步骤："
  [ ! -f .env ] && echo "  1. 运行: cp .env.example .env"
  [ ! -d node_modules ] && echo "  2. 运行: npm install"
  echo ""
  exit 1
else
  echo "✅ 所有检查通过！"
  echo ""
  echo "📚 下一步："
  echo "  1. 启动服务: ./start.sh"
  echo "  2. 验证服务: curl http://localhost:3001/health"
  echo "  3. 测试webhook: curl -X POST http://localhost:3001/webhook/default_token_123 \\"
  echo "       -H 'Content-Type: application/json' \\"
  echo "       -d '{\"test\":\"data\"}'"
  echo ""
  exit 0
fi
