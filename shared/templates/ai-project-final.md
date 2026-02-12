# AI项目适配文档模板

> 放置位置: `项目根目录/.claude/project.md`
> 提交到git，团队共享

---

# [项目名称]

## 项目简介
```yaml
名称: xxx
一句话描述: xxx
技术栈: 前端Vue3 + 后端NestJS + MySQL
仓库: git@xxx.git
负责人: xxx
```

## 模块地图

> AI开发时的导航表，快速定位代码位置

| 业务功能 | 模块路径 | 关键文件 | 说明 |
|----------|----------|----------|------|
| 用户登录 | src/modules/auth/ | auth.service.ts | JWT认证 |
| 用户管理 | src/modules/user/ | user.service.ts | CRUD |
| 订单管理 | src/modules/order/ | order.service.ts | 状态机流转 |
| 支付 | src/modules/payment/ | payment.service.ts | 对接微信/支付宝 |

## 业务概念

> AI必须理解的领域术语

| 术语 | 含义 | 示例 |
|------|------|------|
| SKU | 库存单位 | iPhone 15 黑色 128G |
| SPU | 商品单位 | iPhone 15 |

## 数据流向

```
请求 → Controller → Service → Repository → MySQL
                       ↓
                   Redis缓存
```

## 禁止事项

> AI绝对不能做的事

- ❌ 不要修改 `src/config/prod.ts` 生产配置
- ❌ 不要删除 `migrations/` 下的任何文件
- ❌ 不要直接操作数据库，必须通过Repository
- ❌ 不要在代码中硬编码密钥

## 开发规范

> AI写代码时遵循的规范

```yaml
语言: TypeScript strict模式
命名:
  - 文件: kebab-case (user-service.ts)
  - 类: PascalCase (UserService)
  - 方法: camelCase (findById)
注释: 中文，关键逻辑必须注释
错误处理: 统一抛出 BusinessException
日志: 使用 this.logger，不要用 console.log
```

## 测试验证

> 修改代码后如何验证

```bash
# 单元测试
npm run test

# E2E测试
npm run test:e2e

# 本地启动验证
npm run dev
# 访问 http://localhost:3000/api/health
```

## 常见问题

> 踩过的坑，避免AI重复踩

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 启动报错端口占用 | 上次没关干净 | `lsof -i:3000` 然后kill |
| 数据库连接失败 | 没启动MySQL | `docker-compose up -d` |

## 当前迭代

> 当前在做什么（可选，频繁更新）

```yaml
版本: v2.3.0
分支: feature/payment-refund
任务:
  - [ ] 退款功能开发
  - [ ] 退款通知对接
```

## 变更记录

> 重大变更记录（可选）

### 2024-02-01
- 新增支付模块 `src/modules/payment/`
- 订单模块增加支付状态字段

---

<!--
维护指南:
1. 模块地图、业务概念、禁止事项 → 变化少，偶尔更新
2. 当前迭代 → 每个迭代更新一次
3. 变更记录 → 重大变更时记录
4. 提交到git，团队共享
-->
