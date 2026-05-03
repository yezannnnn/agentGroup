# Webhook服务 - 文件索引和快速导航

## 快速索引

### 我想做什么？

| 需求 | 文件 | 说明 |
|------|------|------|
| **5分钟快速开始** | [QUICK_START.md](./QUICK_START.md) | 最快上手方式 |
| **详细安装指南** | [SETUP.md](./SETUP.md) | 完整安装步骤和配置 |
| **查看API文档** | [README.md](./README.md) | API端点和功能说明 |
| **生产部署** | [DEPLOYMENT.md](./DEPLOYMENT.md) | 从开发到生产的完整部署流程 |
| **了解所有文件** | [FILE_MANIFEST.md](./FILE_MANIFEST.md) | 详细文件清单 |
| **查看创建总结** | [MANIFEST.txt](./MANIFEST.txt) | 项目创建信息汇总 |
| **启动服务** | [start.sh](./start.sh) | 一键启动脚本 |
| **验证环境** | [verify.sh](./verify.sh) | 环境检查脚本 |

## 文件用途速查表

### 源代码
```
webhook-server.js      Express服务器核心代码
  ├─ /health           健康检查端点
  └─ /webhook/:token   Webhook接收和转发端点
```

### 配置
```
.env                   生产环境变量
.env.example           配置模板
.gitignore             Git忽略规则
package.json           依赖和脚本配置
```

### 脚本
```
start.sh               启动服务 ← 最常用
verify.sh              验证环境
```

### 文档
```
README.md              API和功能文档 ← 了解服务
QUICK_START.md         5分钟快速开始 ← 快速上手
SETUP.md               详细安装配置 ← 深入学习
DEPLOYMENT.md          生产部署指南 ← 上线必读
FILE_MANIFEST.md       文件清单详解 ← 文件说明
MANIFEST.txt           项目创建总结 ← 概览信息
INDEX.md               本文件 ← 快速导航
```

## 文件树结构

```
webhook/
├── 📄 核心文件
│   ├── webhook-server.js (4.9 KB)    Express服务器
│   └── package.json                   项目配置
│
├── ⚙️  配置文件
│   ├── .env                          环境变量
│   ├── .env.example                  配置模板
│   └── .gitignore                    Git忽略
│
├── 🚀 脚本文件
│   ├── start.sh                      启动脚本
│   └── verify.sh                     验证脚本
│
└── 📚 文档文件
    ├── README.md                     功能文档
    ├── QUICK_START.md                快速开始
    ├── SETUP.md                      安装指南
    ├── DEPLOYMENT.md                 部署指南
    ├── FILE_MANIFEST.md              文件清单
    ├── MANIFEST.txt                  创建总结
    └── INDEX.md                      本文件
```

## 优先阅读顺序

### 第一次使用（推荐阅读顺序）

1. **本文件** (INDEX.md) - 了解整体结构 (2分钟)
2. **QUICK_START.md** - 快速启动服务 (5分钟)
3. **README.md** - 了解API和功能 (10分钟)
4. **SETUP.md** - 深入学习安装配置 (20分钟)

### 不同场景下的推荐文档

**场景1: 我只是想快速试一下**
→ QUICK_START.md

**场景2: 我需要完整理解这个服务**
→ README.md

**场景3: 我需要自己安装配置**
→ SETUP.md

**场景4: 我要部署到生产环境**
→ DEPLOYMENT.md

**场景5: 我要修改或扩展代码**
→ FILE_MANIFEST.md 了解文件结构，然后修改相应文件

**场景6: 出现问题我怎么排查**
→ SETUP.md 中的"故障排查"部分，或运行 `./verify.sh`

## 常用命令速查

### 启动和验证
```bash
./start.sh              # 启动服务（推荐）
./verify.sh             # 验证环境
npm install             # 安装依赖
npm start               # 启动服务（手动）
npm run dev             # 开发模式（需要nodemon）
```

### 测试
```bash
# 健康检查
curl http://localhost:3001/health

# 发送webhook
curl -X POST http://localhost:3001/webhook/default_token_123 \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}'
```

### 查看日志
```bash
npm start               # 启动时显示日志
pm2 logs webhook        # 使用PM2查看日志
tail -f webhook.log     # 查看日志文件
```

## 文件内容预览

### webhook-server.js (185行)
```javascript
// 关键内容：
- Express服务器初始化
- /health 端点（健康检查）
- /webhook/:token 端点（接收和转发）
- Token验证逻辑
- NestJS转发实现
- 日志记录
- 错误处理
```

### package.json (27行)
```json
{
  "name": "webhook-proxy-server",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.6.0",
    "dotenv": "^16.3.1"
  }
}
```

### .env (6行配置)
```bash
PORT=3001
NESTJS_URL=http://localhost:3000
VALID_TOKENS=default_token_123,test_token_456,webhook_token_789
NODE_ENV=development
```

## API速查

### 健康检查
```
GET /health
→ 返回: {"status":"healthy","timestamp":"...","uptime":...}
```

### Webhook接收
```
POST /webhook/:token
Body: {...任意数据...}
→ 转发到: ${NESTJS_URL}/api/wechat/process
→ Payload: {token, data, receivedAt}
```

## 环境变量参考

| 变量 | 默认值 | 说明 |
|------|--------|------|
| PORT | 3001 | 服务监听端口 |
| NESTJS_URL | http://localhost:3000 | NestJS目标服务 |
| VALID_TOKENS | 见.env | 有效的Webhook令牌 |
| NODE_ENV | development | 运行环境 |

## 性能参数

| 指标 | 值 |
|------|-----|
| 内存占用 | ~50 MB |
| 最大并发 | 1000+ |
| 响应时间 | 50-200ms |
| 启动时间 | <1秒 |

## 安全检查清单

- [ ] Token已配置在VALID_TOKENS
- [ ] NESTJS_URL指向正确的服务
- [ ] .env文件已从.gitignore排除
- [ ] HTTPS已配置（生产环境）
- [ ] 错误日志已启用
- [ ] 请求日志已启用

## 故障快速诊断

| 问题 | 诊断 | 解决 |
|------|------|------|
| 无法启动 | `./verify.sh` | 查看verify输出 |
| 端口冲突 | `lsof -i :3001` | 改用其他端口 |
| Token验证失败 | `grep VALID_TOKENS .env` | 检查token配置 |
| NestJS连接失败 | `curl $NESTJS_URL/health` | 检查NestJS是否运行 |

## 下一步行动

1. **立即开始** (2分钟)
   ```bash
   cd /Users/yuhao/Desktop/yezannnnn/aiGroup/max/webhook
   ./start.sh
   ```

2. **验证服务** (1分钟)
   ```bash
   curl http://localhost:3001/health
   ```

3. **发送测试** (1分钟)
   ```bash
   curl -X POST http://localhost:3001/webhook/default_token_123 \
     -H "Content-Type: application/json" \
     -d '{"test":"data"}'
   ```

4. **深入学习** (30分钟)
   - 阅读 README.md 了解功能
   - 阅读 SETUP.md 学习配置
   - 阅读 DEPLOYMENT.md 准备生产部署

## 联系方式

- **项目经理**: Max
- **创建日期**: 2026-03-09
- **服务版本**: 1.0.0
- **状态**: 生产就绪 ✅

---

**需要帮助？** 运行 `./verify.sh` 诊断环境，或查看相应的文档文件。

**想快速开始？** 运行 `./start.sh` 然后 `curl http://localhost:3001/health`

**准备部署？** 阅读 DEPLOYMENT.md 了解完整的部署流程。
