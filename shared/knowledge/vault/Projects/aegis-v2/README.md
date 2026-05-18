# 项目: Aegis-v2

## 基本信息
- **项目ID**: ai-aegis
- **项目类型**: AI Agent安全监控工具
- **当前版本**: v0.4.0
- **状态**: ✅ 已发布 (npm)
- **项目经理**: [[Max]]
- **主要开发**: yezannnnn
- **npm包**: [ai-aegis](https://www.npmjs.com/package/ai-aegis)
- **GitHub**: [yezannnnn/aiAegis](https://github.com/yezannnnn/aiAegis)

## 项目概述  
Aegis 是 AI Agent 的最后一道防线 —— 拦截 Claude Code、Hermes 等AI代理执行的危险命令。通过PreToolUse Hook机制在命令执行前拦截，使用AST解析器分析命令结构，结合11个内置规则集评估风险等级，高危命令弹出实时审批界面，只有人工批准后才能执行。

**核心理念**: "不能依靠希望来保证安全" —— 系统级强制执行，无法被AI绕过。

## 技术栈
- **前端**: Vue.js 3 + TypeScript + Vite + Element Plus + Pinia + Socket.IO Client
- **后端**: NestJS + TypeScript + SQLite (better-sqlite3) + Socket.IO
- **命令解析**: AST解析器 + 正则表达式引擎
- **规则引擎**: YAML配置 + 动态规则评估
- **Hook集成**: Claude Code PreToolUse + Hermes Plugin + Universal Hook
- **部署**: npm全局包，本地服务

## 核心功能

### 🛡️ 命令拦截系统
- **PreToolUse Hook**: 在AI执行命令前拦截
- **AST解析**: 结构化解析bash命令 (binary + subcommands + flags + arguments)
- **三级控制**: 
  - `block` - 直接拒绝，无法绕过
  - `review` - 弹出审批界面，等待人工决策
  - `warn` - 记录日志但允许执行

### 🧠 智能规则引擎
**11个内置规则集，100+ 安全规则**:
1. **defaults**: 系统关机/重启、fork炸弹、npm unpublish
2. **filesystem**: rm -rf、删除根目录、chmod 777
3. **git**: force push到main、git reset --hard、git clean -f
4. **docker**: --privileged容器、挂载系统目录
5. **mysql**: DROP TABLE、TRUNCATE、生产库操作
6. **prisma**: migrate reset、db push --force
7. **network**: 公网端口暴露、修改/etc/hosts
8. **development**: pip安装非PyPI源、eval执行动态代码
9. **sqlite**: 删除.db文件、覆盖生产数据库
10. **security**: cat .env/.key、curl管道到bash
11. **aegis**: Aegis配置规则

### 🖥️ 实时监控仪表板
- **Web界面**: http://localhost:3001
- **实时事件流**: 所有命令拦截事件的时间线视图
- **审批中心**: 高危命令一键批准/拒绝，60秒超时自动拒绝
- **统计面板**: 可视化拦截次数、通过/拒绝比例、规则触发频率
- **规则管理**: Web界面创建/编辑/删除YAML规则，实时生效

### 🔌 多Agent支持
| Agent | 状态 | Hook机制 | 配置方式 |
|-------|------|----------|----------|
| Claude Code | ✅ 支持 | PreToolUse hook | `aegis setup` 自动配置 |
| Hermes | ✅ 支持 | pre_tool_call plugin | `aegis setup` 自动配置 |
| OpenClaw | 🔜 即将支持 | — | — |
| Codex | 🔜 即将支持 | — | — |

## 版本历程

### v0.4.0 (2026-05-17) - 当前版本
**新功能**:
- 🎯 **Web规则管理**: 完整的规则CRUD界面，支持YAML编辑和实时预览
- 🌐 **国际化支持**: 中英文界面切换
- 📊 **状态筛选**: 按状态筛选命令事件
- 🔔 **通知持久化**: 通知跳过状态持久化存储

**Bug修复**:
- 修复多会话Agent跟踪问题
- 修复Hermes双触发问题  
- 修复SQL规则正则表达式失效导致规则静默失效
- 修复前端实时事件推送

### v0.3.2 (2026-05-11)
**主要改进**:
- 多语言支持 (中英文)
- WebSocket实时通信优化
- SQLite规则集新增
- 统计数据准确性提升

## 使用的Skills
- [[../../Skills/systematic-debugging]] - 系统化调试方法
- [[../../Skills/system-integration]] - Hook集成和多Agent支持
- [[../../Skills/security-engineering]] - 安全规则设计

## 性能指标
- **拦截响应时间**: < 50ms (毫秒级)
- **规则评估速度**: < 10ms per command
- **WebSocket延迟**: < 5ms (本地通信)
- **数据库性能**: SQLite，支持1000+ 命令/分钟
- **内存占用**: ~50MB (包含前后端)

## 部署架构
```
AI Agent (Claude Code/Hermes)
        ↓ shell command
PreToolUse Hook → HTTP POST → localhost:3000
        ↓
NestJS Backend (AST + Rules)
        ↓ WebSocket
Vue.js Dashboard (localhost:3001)
        ↓ User Decision
HTTP Response → Hook → AI Agent
```

## 安装和使用

### 快速开始
```bash
# 1. 安装
npm install -g ai-aegis

# 2. 初始化 (自动配置Hook)
aegis setup

# 3. 启动服务
aegis start

# 4. 打开仪表板
# http://localhost:3001
```

### 自定义规则
```bash
aegis rules new          # 创建规则模板
aegis rules path         # 查看规则目录
aegis rules reload       # 热重载规则
aegis rules list         # 列出所有规则
```

## 安全考虑
1. **Hook绕过防护**: 安装验证 + 篡改检测
2. **规则完整性**: YAML语法验证 + 恶意规则检测
3. **通信安全**: 本地HTTP通信，无网络暴露
4. **超时保护**: 60秒无响应自动拒绝命令

## 项目文档
- **[系统架构](./architecture/系统架构设计.md)** - 详细架构设计
- **[功能文档](./features/)** - 具体功能实现文档
- **实际项目文档**: `/Users/yuhao/Desktop/yezannnnn/aegis-v2/docs/`

## 经验总结
- **Vue.js选择**: Composition API完美适配实时状态管理，比React更适合监控场景
- **NestJS架构**: 装饰器模式便于规则引擎模块化，依赖注入支持扩展
- **SQLite选择**: 零配置部署，适合开发工具，避免复杂数据库依赖
- **Hook机制**: 统一的PreToolUse协议，支持多AI平台无缝集成
- **AST vs 正则**: 结构化解析比正则匹配更准确，减少误报和漏报

## 相关链接
- **npm包**: https://www.npmjs.com/package/ai-aegis
- **GitHub**: https://github.com/yezannnnn/aiAegis  
- **实际项目路径**: `/Users/yuhao/Desktop/yezannnnn/aegis-v2/`

---
标签: #project #aegis-v2 #security #ai-safety #vue #nestjs #published
创建: 2026-05-17 14:27
维护: Max
最后更新: 2026-05-17 16:20