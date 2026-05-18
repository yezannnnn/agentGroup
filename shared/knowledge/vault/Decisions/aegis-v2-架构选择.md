# 决策: Aegis AI安全监控系统架构选择

## 决策概述
**决策日期**: 2026-05-08  
**决策者**: yezannnnn (主开发), Max (项目管理)
**状态**: ✅ 已确认并实施  
**影响范围**: 整个 Aegis AI安全监控系统

## 决策内容
选择 **Vue.js 3 + NestJS + SQLite + Socket.IO** 技术栈用于构建AI Agent安全监控工具，实现PreToolUse Hook拦截、AST命令解析、YAML规则引擎和实时审批仪表板功能。

## 项目背景
AI代理（Claude Code、Hermes等）作为黑盒系统，会自主执行shell命令链。虽然大部分情况正常，但偶尔会执行意料之外的危险操作：
- `rm -rf /` - 破坏系统
- `git push --force origin main` - 覆盖团队工作
- `chmod -R 777 /etc` - 开放系统权限  
- `cat .env | pbcopy` - 泄露密钥到剪贴板

**核心需求**: 在命令执行前拦截，而非事后日志记录。

## 备选方案对比

### 方案A: Vue.js 3 + NestJS + SQLite ⭐ 选中
**技术组合**:
- 前端: Vue.js 3 + TypeScript + Vite + Element Plus + Pinia
- 后端: NestJS + TypeScript + Socket.IO + better-sqlite3
- 部署: npm全局包，本地服务

**优势**:
- **毫秒级响应**: NestJS异步处理 + SQLite本地存储，< 50ms拦截延迟
- **实时双向通信**: Socket.IO天然支持Hook回调和仪表板推送
- **零配置部署**: SQLite无需数据库服务，npm一键安装
- **开发工具友好**: 适合个人/团队开发环境，非企业级复杂度
- **AST解析能力**: Node.js丰富的shell解析库生态

**劣势**:
- SQLite并发写入有限（但对单机开发工具足够）
- NestJS相比Express稍重（但提供结构化架构）

### 方案B: Electron桌面应用
**技术组合**: Electron + React + SQLite

**优势**:
- 原生桌面体验，更好的系统集成
- 无需Web服务器，打包简单

**劣势**:
- 资源消耗大（~200MB内存 vs ~50MB）
- 跨平台兼容性问题
- 不支持多用户协作场景
- 更新机制复杂

### 方案C: 云服务方案
**技术组合**: React + Express + PostgreSQL + 云部署

**优势**:
- 团队共享配置和规则
- 专业运维保障

**劣势**:
- **致命缺陷**: 网络延迟导致Hook响应慢，阻塞AI执行
- 隐私风险：命令内容上传云端
- 依赖网络连接，离线无法工作
- 部署配置复杂

## 决策理由详析

### 1. 性能要求 (权重: 40%)
**毫秒级拦截响应**:
- AI Agent Hook期望 < 100ms 响应，超时会放弃拦截
- 本地SQLite读写 < 5ms，网络数据库 > 50ms
- NestJS装饰器+依赖注入，减少运行时开销
- Socket.IO本地连接延迟 < 5ms

**实际测试结果** (v0.4.0):
- 命令拦截响应: ~30ms
- 规则评估速度: ~8ms per command  
- WebSocket推送延迟: ~3ms
- 支持 1000+ 命令/分钟

### 2. 部署简化 (权重: 25%)
**开发工具定位**:
- 目标用户：个人开发者和小团队
- 期望：`npm install -g` 一键安装即可
- SQLite零配置 vs PostgreSQL需要数据库服务
- 单体应用 vs 微服务架构复杂度

**npm包分发优势**:
- 自动Hook配置：`aegis setup` 自动修改 `~/.claude/settings.json`
- 跨平台兼容：Windows/macOS/Linux统一体验
- 版本管理：npm语义化版本，自动更新

### 3. 实时通信需求 (权重: 20%)
**双向实时通信场景**:
- Hook → 后端：命令拦截请求（HTTP POST）
- 后端 → 前端：实时事件推送（WebSocket）
- 前端 → 后端：审批决策传递（HTTP + WebSocket）
- 后端 → Hook：拦截结果响应（HTTP Response）

**Socket.IO选择理由**:
- 自动降级：WebSocket → Long Polling → JSONP
- 房间和命名空间：支持多会话隔离
- 成熟稳定：生产环境验证，丰富的客户端库

### 4. 扩展性考虑 (权重: 15%)
**多AI Agent支持**:
- 统一的PreToolUse协议：Claude Code/Hermes/未来AI工具
- Hook标准化：JavaScript/Python/其他语言Hook脚本
- 规则引擎模块化：YAML配置 + TypeScript规则类

**NestJS架构优势**:
```typescript
@Module({
  providers: [
    FileSystemRuleSet,    // 文件系统安全规则
    GitSecurityRuleSet,   // Git操作安全规则  
    NetworkRuleSet,       // 网络安全规则
    CustomRuleSet,        // 用户自定义规则
  ]
})
export class RuleEngineModule {
  // 依赖注入支持规则集扩展
}
```

## 技术风险评估与缓解

### 🔴 高风险
**SQLite并发写入瓶颈**
- **现象**: 多个Hook同时写入时可能锁定
- **缓解**: 写入队列 + 批量提交机制
- **监控**: 写入延迟告警（> 50ms）
- **实际影响**: 单机场景下，AI Agent通常串行执行命令，并发有限

### 🟡 中风险  
**WebSocket连接稳定性**
- **现象**: 网络抖动或浏览器切换可能断连
- **缓解**: 心跳检测 + 指数退避重连
- **监控**: 连接状态实时显示
- **实际影响**: 断连时审批请求会超时拒绝，偏向安全

### 🟢 低风险
**Hook安装失败**
- **现象**: `~/.claude/settings.json` 文件权限或格式问题
- **缓解**: 备份原文件 + 增量修改 + 回滚机制
- **监控**: 安装状态验证
- **实际影响**: 安装失败时命令直接执行，用户手动配置

## 实施结果验证

### 成功指标达成情况 (v0.4.0)
- ✅ 命令拦截响应时间 < 50ms (实际 ~30ms)
- ✅ WebSocket连接成功率 > 99.5% (实际 99.8%)
- ✅ AST解析准确率 > 95% (实际 97%+)
- ✅ 单机支持 1000+ 命令/分钟 (实际测试通过)

### 用户采用情况
- **npm下载量**: 持续增长
- **GitHub Star**: 用户反馈积极
- **支持的AI工具**: Claude Code ✅, Hermes ✅
- **规则集覆盖**: 11个规则集，100+ 安全规则

### 架构演进
```
v0.1.0: 基础Hook拦截机制
v0.2.0: 加入Web仪表板和实时通知
v0.3.0: YAML规则引擎 + 多语言支持
v0.4.0: Web规则管理界面 + 状态筛选
```

## 经验总结

### ✅ 正确决策
1. **Vue.js Composition API**: 完美适配实时状态管理，比React更直观
2. **SQLite选择**: 零配置是开发工具的关键优势，比PostgreSQL更适合
3. **本地优先**: 避免云服务延迟和隐私问题，是正确的产品方向
4. **npm分发**: 比Docker或二进制分发更符合开发者习惯

### 🔄 可以改进
1. **规则热重载**: 当前需要手动reload，可以改为文件监听自动重载
2. **Hook协议**: 可以考虑gRPC替代HTTP，进一步降低延迟
3. **规则编辑器**: 可以加入可视化规则构建器，降低YAML学习成本

### 🚀 未来演进方向
1. **Plugin生态**: 开放插件接口，支持社区贡献规则集
2. **ML增强**: 基于历史数据的智能风险评估
3. **企业版**: 团队共享规则库 + 集中审计日志

---
**相关决策**:
- 本决策为架构核心决策，其他技术选择均基于此方案

**参考文档**:
- [系统架构设计](../Projects/aegis-v2/architecture/系统架构设计.md)
- [实际项目代码](file:///Users/yuhao/Desktop/yezannnnn/aegis-v2/)

**标签**: #decision #architecture #aegis-v2 #vue #nestjs #ai-security
**创建**: 2026-05-08  
**更新**: 2026-05-17 16:30