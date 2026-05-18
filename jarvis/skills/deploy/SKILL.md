# 租户端部署流程

## 环境信息
- **服务器**: 121.199.46.101
- **密码**: Zkeqiyun1688@,,
- **代码仓库后端**: git@gitee.com:chat-bot_1/chat-bot-tenant-node.git
- **代码仓库前端**: git@gitee.com:chat-bot_1/chatBotTenantWeb.git
- **部署目录**: `/opt/chatbot`

---

## 部署流程

### 步骤1：数据库同步检查

**检查是否有新的 Prisma Migration**：
```bash
# 服务器执行
ssh root@121.199.46.101 "docker exec chatbot-backend npx prisma migrate status"
```

**如果显示 "up to date"，无需迁移**

**如果需要执行迁移**：
```bash
ssh root@121.199.46.101 "docker exec chatbot-backend npx prisma migrate deploy"
```

**如果迁移失败（表不存在）**：
手动创建缺失的表（见附录A）

---

### 步骤2：后端部署

```bash
# 1. SSH 到服务器
ssh root@121.199.46.101

# 2. 进入后端目录
cd /opt/chatbot/backend-nestjs

# 3. 拉取最新代码
git pull origin master

# 4. 重新构建 Docker 镜像
docker build -t chatbot-backend:latest .

# 5. 停止旧容器
docker stop chatbot-backend && docker rm chatbot-backend

# 6. 启动新容器
docker run -d \
  --name chatbot-backend \
  --restart always \
  -p 127.0.0.1:3001:3001 \
  --env-file /opt/chatbot/.env \
  -e TZ=Asia/Shanghai \
  --network chatbot-network \
  chatbot-backend:latest

# 7. 查看日志确认启动成功
docker logs chatbot-backend --tail 20
```

---

### 步骤3：前端部署

```bash
# 1. SSH 到服务器
ssh root@121.199.46.101

# 2. 进入前端目录
cd /opt/chatbot/vue-frontend

# 3. 拉取最新代码
git pull origin master

# 4. 停止后端容器（需要使用后端的 node 来 build）
docker stop chatbot-backend

# 5. 构建前端（使用后端容器的 node）
docker run --rm \
  -v /opt/chatbot/vue-frontend:/app \
  -w /app \
  chatbot-backend:latest \
  sh -c 'npm install && npm run build'

# 6. 重启后端
docker start chatbot-backend

# 7. 重启前端
docker restart chatbot-frontend
```

---

### 步骤4：验证部署

```bash
# 服务器上验证
ssh root@121.199.46.101 << 'EOF'
# 检查容器状态
docker ps --format 'table {{.Names}}\t{{.Status}}'

# 检查前端页面
curl -sL http://localhost:80/ | grep -o '<title>.*</title>'

# 检查后端 API
curl -s http://localhost:3001/v1/intent-types

# 检查意图类型数据
curl -s http://localhost:3001/v1/intent-driven/configs/tenant/5
EOF
```

---

## 快速部署脚本

```bash
#!/bin/bash
set -e
SERVER="root@121.199.46.101"
PASS="Zkeqiyun1688@,,"
echo "=== 租户端部署流程 ==="

# 1. 后端部署
echo "[1/4] 后端部署..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$SERVER" "
  cd /opt/chatbot/backend-nestjs && \
  git pull origin master && \
  docker build -t chatbot-backend:latest . && \
  docker stop chatbot-backend && docker rm chatbot-backend && \
  docker run -d --name chatbot-backend --restart always -p 127.0.0.1:3001:3001 --env-file /opt/chatbot/.env -e TZ=Asia/Shanghai --network chatbot-network chatbot-backend:latest
"
echo "✅ 后端部署完成"

# 2. 前端部署
echo "[2/4] 前端部署..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$SERVER" "
  cd /opt/chatbot/vue-frontend && \
  git pull origin master
"
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$SERVER" "
  docker stop chatbot-backend && \
  docker run --rm -v /opt/chatbot/vue-frontend:/app -w /app chatbot-backend:latest sh -c 'npm install && npm run build' && \
  docker start chatbot-backend && \
  docker restart chatbot-frontend
"
echo "✅ 前端部署完成"

# 3. 验证
echo "[3/4] 验证..."
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$SERVER" "
  echo '容器状态:'
  docker ps --format 'table {{.Names}}\t{{.Status}}'
  echo '前端页面:'
  curl -sL http://localhost:80/ | grep -o '<title>.*</title>'
  echo '意图类型API:'
  curl -s http://localhost:3001/v1/intent-types | head -c 200
"

echo "=== 部署完成 ==="
```

---

## 附录A：手动创建缺失的表

如果 `prisma migrate deploy` 或 `prisma db push` 失败，需要手动创建表。

**上传 SQL 文件到服务器**：
```bash
# 本地执行
scp create_tables.sql root@121.199.46.101:/tmp/
```

**在服务器容器中执行 SQL**：
```bash
ssh root@121.199.46.101 "docker exec chatbot-backend sh -c 'node -e \"
const { PrismaClient } = require(\\\"@prisma/client\\\");
const prisma = new PrismaClient();
const fs = require(\\\"fs\\\");
const sql = fs.readFileSync(\\\"/tmp/tables.sql\\\", \\\"utf8\\\");
const statements = sql.split(\\\";\\\").filter(s => s.trim());
async function run() {
  for (const stmt of statements) {
    if (stmt.trim()) {
      try {
        await prisma.\\\$executeRawUnsafe(stmt);
        console.log(\\\"OK: \\\" + stmt.substring(0, 50));
      } catch (e) {
        console.error(\\\"ERR: \\\" + e.message);
      }
    }
  }
  await prisma.\\\$disconnect();
}
run();
\"'"
```

**插入默认意图类型数据**：
```bash
ssh root@121.199.46.101 "docker exec chatbot-backend sh -c 'node -e \"
const { PrismaClient } = require(\\\"@prisma/client\\\");
const prisma = new PrismaClient();
async function run() {
  const types = [
    [\\\"time_booking\\\", \\\"时间约定\\\", \\\"示例：明天下午2点开会\\\", \\\"#1E90FF\\\", 1],
    [\\\"phone_booking\\\", \\\"电话约定\\\", \\\"示例：打我电话\\\", \\\"#2ECC71\\\", 2],
    [\\\"price_negotiate\\\", \\\"价格谈判\\\", \\\"示例：便宜点\\\", \\\"#F39C12\\\", 3],
    [\\\"visit_meeting\\\", \\\"见面拜访\\\", \\\"示例：来公司看看\\\", \\\"#9B59B6\\\", 4],
    [\\\"urgent_request\\\", \\\"紧急加急\\\", \\\"示例：很急\\\", \\\"#E74C3C\\\", 5],
    [\\\"sample_trial\\\", \\\"样品试用\\\", \\\"示例：寄样品\\\", \\\"#1ABC9C\\\", 6],
    [\\\"customize\\\", \\\"定制需求\\\", \\\"示例：需要定制\\\", \\\"#3498DB\\\", 7],
    [\\\"offline_payment\\\", \\\"线下交易\\\", \\\"示例：转账给你\\\", \\\"#E67E22\\\", 8],
    [\\\"install_service\\\", \\\"安装服务\\\", \\\"示例：上门安装\\\", \\\"#95A5A6\\\", 9],
    [\\\"document_request\\\", \\\"资料文件\\\", \\\"示例：发资料\\\", \\\"#16A085\\\", 10],
    [\\\"price\\\", \\\"价格咨询\\\", \\\"示例：多少钱\\\", \\\"#D35400\\\", 11],
    [\\\"registration\\\", \\\"参加报名\\\", \\\"示例：我要报名\\\", \\\"#27AE60\\\", 12],
    [\\\"payment_inquiry\\\", \\\"咨询付款\\\", \\\"示例：怎么付款\\\", \\\"#7F8C8D\\\", 13],
    [\\\"negation\\\", \\\"否定\\\", \\\"示例：不要了\\\", \\\"#8E44AD\\\", 14],
    [\\\"interest\\\", \\\"兴趣表达\\\", \\\"示例：不错\\\", \\\"#2980B9\\\", 15],
    [\\\"budget\\\", \\\"价格顾虑\\\", \\\"示例：有点贵\\\", \\\"#C0392B\\\", 16],
    [\\\"objection\\\", \\\"拒绝\\\", \\\"示例：不需要了\\\", \\\"#BDC3C7\\\", 17],
    [\\\"timeline\\\", \\\"时间咨询\\\", \\\"示例：多久到\\\", \\\"#1F77B4\\\", 18],
    [\\\"comparison\\\", \\\"竞品对比\\\", \\\"示例：别家便宜\\\", \\\"#FF7F0E\\\", 19]
  ];
  for (const t of types) {
    try {
      await prisma.\\\$executeRawUnsafe(\\\`INSERT IGNORE INTO intent_types (type_code, type_name, type_desc, type_color, type_order) VALUES (?, ?, ?, ?, ?)\\\`, ...t);
      console.log(\\\"Inserted: \\\" + t[0]);
    } catch (e) {
      console.log(\\\"Skip: \\\" + t[0] + \\\" - \\\" + e.message);
    }
  }
  await prisma.\\\$disconnect();
}
run();
\"'"
```

---

## 附录B：常用检查命令

```bash
# 查看所有容器状态
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# 查看后端日志
docker logs chatbot-backend --tail 100 -f

# 查看前端日志
docker logs chatbot-frontend --tail 50

# 检查数据库迁移状态
docker exec chatbot-backend npx prisma migrate status

# 进入后端容器
docker exec -it chatbot-backend sh

# 重启所有服务
docker restart chatbot-backend chatbot-frontend chatbot-nginx
```

---

## 常见问题

### Q: git pull 失败 403
```bash
# 切换到 SSH 方式
git remote set-url origin git@gitee.com:chat-bot_1/chat-bot-tenant-node.git
```

### Q: /login 返回 500
前端 dist 为空，重新部署前端

### Q: API 404
检查后端是否启动成功，查看日志

### Q: 数据库表不存在
执行附录A的手动创建表步骤

### Q: docker-compose segfault
使用 docker 命令直接操作，不使用 docker-compose
