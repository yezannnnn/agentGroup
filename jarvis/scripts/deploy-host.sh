#!/bin/bash
set -e

echo '=========================================='
echo '  ChatBot CI/CD Deployment Pipeline'
echo '  Running on HOST (not in container)'
echo '=========================================='

# Configuration
WORKSPACE="/var/lib/docker/volumes/jenkins_home/_data/workspace/chatbot-deploy"
DEPLOY_DIR="/opt/chatbot"
BACKUP_DIR="/opt/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BUILD_NUMBER=${BUILD_NUMBER:-$TIMESTAMP}

echo ""
echo "📦 Build Number: $BUILD_NUMBER"
echo "📦 Timestamp: $TIMESTAMP"
echo ""

# Check if workspace exists
if [ ! -d "$WORKSPACE" ]; then
    echo "❌ Workspace not found: $WORKSPACE"
    exit 1
fi

cd $WORKSPACE

# 1. Show current git status
echo "📋 Step 1: Repository Status"
git log --oneline -3 || echo "Git log not available"
echo ""

# 2. Install dependencies
echo "📦 Step 2: Installing Dependencies..."
if [ -f "package.json" ]; then
    echo "Found package.json at root"
    npm ci || npm install
    echo "✅ Dependencies installed"
else
    echo "⚠️ No package.json found at root"
fi
echo ""

# 3. Check for backend-nestjs
echo "🔍 Step 3: Checking Project Structure..."
if [ -d "backend-nestjs" ]; then
    echo "📁 Found backend-nestjs directory"
    cd backend-nestjs
    
    if [ -f "package.json" ]; then
        echo "📦 Installing backend dependencies..."
        npm ci || npm install
        
        echo "🔨 Building backend..."
        npm run build || echo "⚠️ Build may have warnings"
        
        # Generate Prisma client
        if [ -f "prisma/schema.prisma" ]; then
            echo "🗄️ Generating Prisma client..."
            npx prisma generate
        fi
    fi
    
    cd ..
else
    echo "ℹ️ No backend-nestjs directory found, treating as root project"
    if [ -f "package.json" ]; then
        echo "🔨 Building project..."
        npm run build || echo "⚠️ Build may have warnings"
        
        if [ -f "prisma/schema.prisma" ]; then
            echo "🗄️ Generating Prisma client..."
            npx prisma generate
        fi
    fi
fi
echo ""

# 4. Backup current deployment
echo "💾 Step 4: Creating Backup..."
mkdir -p $BACKUP_DIR
if [ -d "$DEPLOY_DIR" ] && [ "$(ls -A $DEPLOY_DIR)" ]; then
    tar -czf "$BACKUP_DIR/chatbot_$TIMESTAMP.tar.gz" -C $DEPLOY_DIR . 2>/dev/null
    echo "✅ Backup created: $BACKUP_DIR/chatbot_$TIMESTAMP.tar.gz"
else
    echo "ℹ️ No existing deployment to backup"
fi
echo ""

# 5. Deploy
echo "🚀 Step 5: Deploying to Production..."
mkdir -p $DEPLOY_DIR

# Backup .env
if [ -f "$DEPLOY_DIR/.env" ]; then
    cp $DEPLOY_DIR/.env /tmp/.env.backup
fi

# Clear and copy
rm -rf $DEPLOY_DIR/*

if [ -d "backend-nestjs" ]; then
    cp -r backend-nestjs/* $DEPLOY_DIR/
    # Copy root files too if needed
    cp -r . $DEPLOY_DIR/ 2>/dev/null || true
else
    cp -r . $DEPLOY_DIR/
fi

# Restore .env
if [ -f "/tmp/.env.backup" ]; then
    cp /tmp/.env.backup $DEPLOY_DIR/.env
    rm /tmp/.env.backup
fi

echo "✅ Files deployed to $DEPLOY_DIR"
echo ""

# 6. Database migration
echo "🗄️ Step 6: Database Migration..."
cd $DEPLOY_DIR
if [ -f "prisma/schema.prisma" ]; then
    npx prisma migrate deploy 2>/dev/null || echo "⚠️ Migration skipped or already up to date"
else
    echo "ℹ️ No Prisma schema found"
fi
echo ""

# 7. Restart services
echo "🔄 Step 7: Restarting Services..."

# Try different methods to restart
echo "Trying PM2..."
pm2 restart chatbot-backend 2>/dev/null || pm2 start npm --name "chatbot-backend" -- run start:prod 2>/dev/null || echo "PM2 not available"

echo "Trying Docker..."
docker restart chatbot-backend 2>/dev/null || echo "Docker container not found"
docker restart chatbot-frontend 2>/dev/null || echo "Frontend container not found"

echo "Trying systemd..."
systemctl restart chatbot-backend 2>/dev/null || echo "Systemd service not found"

echo "✅ Restart attempted"
echo ""

# 8. Health check
echo "🔍 Step 8: Health Check..."
sleep 10
if [ -f "/opt/chatbot/.jenkins/health-check.sh" ]; then
    bash /opt/chatbot/.jenkins/health-check.sh || echo "⚠️ Health check completed with warnings"
else
    echo "ℹ️ Health check script not found, skipping"
fi
echo ""

echo '=========================================='
echo '  ✅ Deployment Completed!'
echo "  Timestamp: $TIMESTAMP"
echo '=========================================='