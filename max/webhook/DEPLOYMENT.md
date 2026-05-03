# Webhook服务部署指南

## 🎯 部署清单

本文档提供从开发到生产的完整部署流程。

## 环境对比

| 阶段 | 端口 | NestJS地址 | 日志 | 自动重启 | HTTPS |
|------|------|-----------|------|---------|-------|
| **开发** | 3001 | localhost:3000 | 控制台 | ❌ | ❌ |
| **测试** | 3001 | test.api.com | 文件 | ✓ (PM2) | ❌ |
| **生产** | 3001 | api.example.com | 文件+ELK | ✓ (PM2) | ✓ |

## 部署步骤

### 第1阶段：开发环境

**环境：** 本地开发机

```bash
# 1. 克隆/下载代码
cd /path/to/webhook

# 2. 安装依赖
npm install

# 3. 启动服务
npm start

# 4. 验证
curl http://localhost:3001/health
```

**配置文件 (.env)：**
```bash
PORT=3001
NESTJS_URL=http://localhost:3000
VALID_TOKENS=dev_token_123
NODE_ENV=development
```

### 第2阶段：测试环境

**环境：** 测试服务器（可以是云服务器或局域网机器）

#### 2.1 部署代码

```bash
# 1. SSH连接到测试服务器
ssh user@test.example.com

# 2. 创建应用目录
mkdir -p /opt/webhook
cd /opt/webhook

# 3. 上传代码
scp -r /local/webhook/* user@test.example.com:/opt/webhook/

# 或使用git
git clone https://repo.example.com/webhook.git
cd webhook
```

#### 2.2 安装依赖

```bash
# 安装Node.js（如果未安装）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证版本
node -v  # 应该 >= 14
npm -v   # 应该 >= 6

# 安装项目依赖
npm install --production

# 验证
npm list express axios dotenv
```

#### 2.3 配置环境

```bash
# 复制并编辑.env
cp .env.example .env
nano .env
```

**测试环境配置：**
```bash
PORT=3001
NESTJS_URL=http://test-api.example.com:3000
VALID_TOKENS=test_token_xxx,test_token_yyy
NODE_ENV=production
```

#### 2.4 安装PM2进程管理器

```bash
# 全局安装PM2
sudo npm install -g pm2

# 验证
pm2 -v

# 启动应用
pm2 start webhook-server.js --name webhook

# 设置开机自启
pm2 startup
pm2 save

# 验证运行状态
pm2 status
pm2 logs webhook
```

#### 2.5 配置反向代理（Nginx）

```bash
# 安装Nginx（如果未安装）
sudo apt-get install nginx

# 创建配置文件
sudo nano /etc/nginx/sites-available/webhook
```

**Nginx配置（HTTP）：**
```nginx
upstream webhook {
    server localhost:3001;
}

server {
    listen 80;
    server_name webhook.test.example.com;

    location / {
        proxy_pass http://webhook;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 日志配置
    access_log /var/log/nginx/webhook_access.log;
    error_log /var/log/nginx/webhook_error.log;
}
```

**启用Nginx配置：**
```bash
# 创建符号链接
sudo ln -s /etc/nginx/sites-available/webhook /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx

# 验证
curl http://webhook.test.example.com/health
```

#### 2.6 测试验证

```bash
# 1. 检查进程状态
pm2 status

# 2. 检查健康状态
curl http://webhook.test.example.com/health

# 3. 测试webhook转发
curl -X POST http://webhook.test.example.com/webhook/test_token_xxx \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}'

# 4. 查看实时日志
pm2 logs webhook
```

### 第3阶段：生产环境

**环境：** 生产服务器（高可用部署）

#### 3.1 环境准备

```bash
# 1. 创建专用用户
sudo useradd -m -s /bin/bash webhook

# 2. 创建应用目录
sudo mkdir -p /opt/app/webhook
sudo chown -R webhook:webhook /opt/app/webhook

# 3. 以webhook用户身份部署
sudo -u webhook bash
cd /opt/app/webhook
```

#### 3.2 代码部署

```bash
# 使用Git部署（推荐）
git clone --branch main https://repo.example.com/webhook.git .
git checkout $(cat VERSION)

# 或使用CI/CD工具（GitHub Actions, GitLab CI等）
# 参考下文的CI/CD部分
```

#### 3.3 生产环境配置

```bash
# 编辑.env（严格保护此文件）
nano .env

# 设置权限（仅owner可读）
chmod 600 .env
chmod 644 .env.example
chmod 755 start.sh verify.sh
```

**生产环境配置示例：**
```bash
PORT=3001
NESTJS_URL=https://api.production.com:3000
VALID_TOKENS=prod_token_xxxxxxxxx,prod_token_yyyyyyyyy
NODE_ENV=production
LOG_LEVEL=warn
```

#### 3.4 PM2生产配置

**创建ecosystem.config.js：**
```javascript
module.exports = {
  apps: [
    {
      name: 'webhook',
      script: './webhook-server.js',
      instances: 2,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production'
      },
      // 日志输出
      out_file: '/var/log/webhook/out.log',
      error_file: '/var/log/webhook/error.log',
      log_file: '/var/log/webhook/combined.log',
      time_format: 'YYYY-MM-DD HH:mm:ss Z',
      // 自动重启
      max_memory_restart: '500M',
      watch: false,
      // 优雅关闭
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 3000,
    }
  ]
};
```

**启动应用：**
```bash
# 使用配置文件启动
pm2 start ecosystem.config.js

# 设置开机自启
pm2 startup
pm2 save

# 保存配置
pm2 save
```

#### 3.5 Nginx生产配置（HTTPS）

**安装Certbot（Let's Encrypt证书）：**
```bash
sudo apt-get install certbot python3-certbot-nginx

# 申请证书（自动配置）
sudo certbot --nginx -d webhook.example.com
```

**Nginx配置（HTTPS + 反向代理）：**
```nginx
# HTTP重定向到HTTPS
server {
    listen 80;
    server_name webhook.example.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS配置
server {
    listen 443 ssl http2;
    server_name webhook.example.com;

    # SSL证书
    ssl_certificate /etc/letsencrypt/live/webhook.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/webhook.example.com/privkey.pem;

    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # 安全头
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # 反向代理
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket支持
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # 超时配置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 日志配置
    access_log /var/log/nginx/webhook_access.log combined;
    error_log /var/log/nginx/webhook_error.log warn;

    # 速率限制
    limit_req_zone $binary_remote_addr zone=webhook:10m rate=100r/s;
    limit_req zone=webhook burst=200;
}
```

**启用配置：**
```bash
sudo ln -s /etc/nginx/sites-available/webhook /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 3.6 日志管理

**配置logrotate：**
```bash
sudo nano /etc/logrotate.d/webhook
```

```
/var/log/webhook/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 webhook webhook
    sharedscripts
    postrotate
        systemctl reload webhook > /dev/null 2>&1 || true
    endscript
}
```

**验证logrotate：**
```bash
sudo logrotate -f /etc/logrotate.d/webhook
ls -lh /var/log/webhook/
```

#### 3.7 监控告警

**使用PM2 Plus（可选）：**
```bash
# 链接到PM2账户（免费）
pm2 link <secret_key> <public_key>

# 启用PM2 Plus功能
pm2 monitor
```

**自定义监控脚本：**
```bash
# 创建监控脚本
cat > /opt/webhook/monitor.sh << 'EOF'
#!/bin/bash
# 检查webhook服务健康状况

WEBHOOK_URL="https://webhook.example.com/health"
ALERT_EMAIL="admin@example.com"

response=$(curl -s -o /dev/null -w "%{http_code}" $WEBHOOK_URL)

if [ "$response" != "200" ]; then
    echo "Alert: Webhook service unhealthy (HTTP $response)" | \
    mail -s "Webhook Alert" $ALERT_EMAIL
fi
EOF

chmod +x /opt/webhook/monitor.sh

# 添加到cron（每5分钟检查）
crontab -e
# */5 * * * * /opt/webhook/monitor.sh
```

#### 3.8 备份策略

```bash
# 创建备份脚本
cat > /opt/webhook/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/webhook"
mkdir -p $BACKUP_DIR
DATE=$(date +%Y%m%d_%H%M%S)

# 备份代码
tar -czf $BACKUP_DIR/webhook_$DATE.tar.gz \
  --exclude=node_modules \
  --exclude=.git \
  /opt/app/webhook

# 备份.env
cp /opt/app/webhook/.env $BACKUP_DIR/.env_$DATE

# 清理旧备份（保留最近30天）
find $BACKUP_DIR -type f -mtime +30 -delete

echo "Backup completed: webhook_$DATE"
EOF

chmod +x /opt/webhook/backup.sh

# 每天凌晨2点执行备份
# 0 2 * * * /opt/webhook/backup.sh
```

## CI/CD集成

### GitHub Actions配置

**创建 `.github/workflows/deploy.yml`：**
```yaml
name: Deploy Webhook Service

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test

    - name: Deploy to production
      if: github.ref == 'refs/heads/main'
      run: |
        # 部署脚本
        ./scripts/deploy.sh
      env:
        DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

## 故障恢复

### 快速回滚

```bash
# 查看部署历史
pm2 logs webhook

# 停止当前版本
pm2 stop webhook

# 切换到上个版本
git checkout HEAD~1

# 重启服务
pm2 start ecosystem.config.js

# 验证
curl https://webhook.example.com/health
```

### 数据恢复

```bash
# 从备份恢复
tar -xzf /opt/backups/webhook/webhook_YYYYMMDD_HHMMSS.tar.gz -C /opt/app/

# 恢复.env
cp /opt/backups/webhook/.env_YYYYMMDD_HHMMSS /opt/app/webhook/.env

# 重启服务
pm2 restart webhook
```

## 性能优化

### 参数调优

**修改webhook-server.js中的值：**
```javascript
// 增加超时时间
const timeout = 30000; // 30秒

// 连接池配置
const axiosConfig = {
  timeout: 30000,
  httpAgent: new http.Agent({ keepAlive: true }),
  httpsAgent: new https.Agent({ keepAlive: true })
};
```

### 负载均衡

**多实例配置（ecosystem.config.js）：**
```javascript
{
  instances: 4,  // 根据CPU核心数调整
  exec_mode: 'cluster'
}
```

## 安全加固

### 防火墙规则

```bash
# 仅允许来自特定IP的访问
sudo ufw allow from 192.168.1.0/24 to any port 3001
sudo ufw allow from 10.0.0.0/8 to any port 3001

# 仅允许Nginx访问
sudo ufw allow from localhost to any port 3001
```

### 定期安全更新

```bash
# 检查依赖安全漏洞
npm audit

# 自动修复
npm audit fix

# 更新依赖
npm update
```

## 检查清单

### 部署前检查
- [ ] 代码审查通过
- [ ] 所有测试通过
- [ ] 环境变量已配置
- [ ] 日志路径已创建
- [ ] 备份已执行

### 部署后检查
- [ ] 服务启动成功
- [ ] 健康检查返回200
- [ ] HTTPS证书有效
- [ ] 日志记录正常
- [ ] 监控告警就位

## 相关文件

- [SETUP.md](./SETUP.md) - 安装指南
- [README.md](./README.md) - 功能文档
- [QUICK_START.md](./QUICK_START.md) - 快速开始

---

**部署版本**: 1.0.0
**最后更新**: 2026-03-09
