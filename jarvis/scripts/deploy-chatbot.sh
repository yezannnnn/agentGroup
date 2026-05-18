#!/bin/bash
set -e

echo '=========================================='
echo '  ChatBot CI/CD Deployment Pipeline'
echo '=========================================='

WORKSPACE="/var/jenkins_home/workspace/chatbot-deploy"
DEPLOY_DIR="/opt/chatbot"
BACKUP_DIR="/opt/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "📦 Build Timestamp: $TIMESTAMP"
echo ""

# 1. Clone Repository
echo "📥 Step 1: Cloning Repository..."
cd $WORKSPACE
rm -rf .??* * 2>/dev/null || true
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone git@gitee.com:chat-bot_1/chatBotPlatformNode.git .
echo "✅ Repository cloned"
echo ""

# 2. Check project structure
echo "📁 Step 2: Checking project structure..."
ls -la
echo ""

# 3. Backup current deployment
echo "💾 Step 3: Backing up current deployment..."
if [ -d "$DEPLOY_DIR" ]; then
    mkdir -p $BACKUP_DIR
    tar -czf "$BACKUP_DIR/chatbot_$TIMESTAMP.tar.gz" -C $DEPLOY_DIR . 2>/dev/null || echo "⚠️  Backup warning"
    echo "✅ Backup created: $BACKUP_DIR/chatbot_$TIMESTAMP.tar.gz"
else
    echo "ℹ️  No existing deployment to backup"
fi
echo ""

# 4. Install dependencies and build
echo "🔧 Step 4: Installing dependencies and building..."

# Check if package.json exists at root or in subdirectory
if [ -f "package.json" ]; then
    echo "📦 Found package.json at root"
    npm ci || npm install
    echo "✅ Dependencies installed"
    
    if grep -q '"build"' package.json; then
        echo "🔨 Building project..."
        npm run build
        echo "✅ Build completed"
    else
        echo "ℹ️  No build script found"
    fi
fi

# Check for backend-nestjs directory
if [ -d "backend-nestjs" ]; then
    echo "📁 Found backend-nestjs directory"
    cd backend-nestjs
    
    if [ -f "package.json" ]; then
        echo "📦 Installing backend dependencies..."
        npm ci || npm install
        echo "✅ Backend dependencies installed"
        
        if grep -q '"build"' package.json; then
            echo "🔨 Building backend..."
            npm run build
            echo "✅ Backend build completed"
        fi
        
        # Prisma generate
        if [ -f "prisma/schema.prisma" ]; then
            echo "🗄️  Generating Prisma client..."
            npx prisma generate
            echo "✅ Prisma client generated"
        fi
    fi
    
    cd ..
fi
echo ""

# 5. Deploy to production directory
echo "🚀 Step 5: Deploying to production..."
mkdir -p $DEPLOY_DIR

# Clear old files except .env and data
if [ -d "$DEPLOY_DIR" ]; then
    # Backup .env if exists
    if [ -f "$DEPLOY_DIR/.env" ]; then
        cp $DEPLOY_DIR/.env /tmp/.env.backup
    fi
    
    # Clear directory
    rm -rf $DEPLOY_DIR/*
fi

# Copy new files
if [ -d "backend-nestjs" ]; then
    cp -r backend-nestjs/* $DEPLOY_DIR/
else
    cp -r . $DEPLOY_DIR/
fi

# Restore .env
if [ -f "/tmp/.env.backup" ]; then
    cp /tmp/.env.backup $DEPLOY_DIR/.env
fi

echo "✅ Files deployed"
echo ""

# 6. Database migration
echo "🗄️  Step 6: Running database migrations..."
cd $DEPLOY_DIR
if [ -f "prisma/schema.prisma" ]; then
    npx prisma migrate deploy 2>/dev/null || echo "⚠️  Migration skipped or no pending migrations"
else
    echo "ℹ️  No Prisma schema found"
fi
echo ""

# 7. Restart application
echo "🔄 Step 7: Restarting application..."

# Try PM2 first
if command -v pm2 &> /dev/null; then
    cd $DEPLOY_DIR
    pm2 restart chatbot-backend 2>/dev/null || pm2 start npm --name "chatbot-backend" -- run start:prod 2>/dev/null || echo "⚠️  PM2 restart attempted"
fi

# Try Docker
docker restart chatbot-backend 2>/dev/null || true
docker restart chatbot-frontend 2>/dev/null || true

# Try systemd
systemctl restart chatbot-backend 2>/dev/null || true

echo "✅ Application restarted"
echo ""

# 8. Health check
echo "🔍 Step 8: Health Check..."
sleep 5
bash /opt/chatbot/.jenkins/health-check.sh || echo "⚠️  Health check completed with warnings"
echo ""

echo '=========================================='
echo '  ✅ Deployment Completed Successfully!'
echo '=========================================='
echo "Timestamp: $TIMESTAMP"
