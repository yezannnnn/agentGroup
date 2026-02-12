# AI项目说明模板

> 放置在项目根目录 `.claude/project.md`，AI启动时自动读取

---

# [项目名称]

## META
```yaml
名称: xxx
版本: x.x.x
更新: YYYY-MM-DD
维护者: xxx
```

## 一句话描述
[20字以内描述项目是什么]

## 技术栈
```yaml
前端: Vue3 / React / ...
后端: NestJS / Express / ...
数据库: MySQL / MongoDB / ...
部署: Docker / PM2 / ...
```

## 目录结构
```
项目根目录/
├── src/
│   ├── modules/       # [说明]
│   ├── services/      # [说明]
│   └── utils/         # [说明]
├── tests/             # [说明]
└── config/            # [说明]
```

## 关键文件
<!-- AI需要重点关注的文件 -->

| 文件 | 作用 | 修改频率 |
|------|------|----------|
| src/main.ts | 入口文件 | 低 |
| src/config.ts | 配置中心 | 中 |
| src/modules/user/ | 用户模块 | 高 |

## 核心概念
<!-- 项目特有的业务概念，AI必须理解 -->

| 概念 | 说明 |
|------|------|
| xxx | xxx |

## 数据流
<!-- 简述数据如何流转 -->
```
用户请求 → Controller → Service → Repository → DB
                ↓
            返回响应
```

## 开发规范
```yaml
命名: 小驼峰 / 大驼峰 / 下划线
缩进: 2空格 / 4空格
分支: feature/xxx, fix/xxx
提交: feat: / fix: / docs:
```

## 常用命令
```bash
npm run dev      # 启动开发
npm run build    # 构建
npm run test     # 测试
```

## 当前状态
```yaml
阶段: 开发中 / 测试中 / 已上线
分支: main / develop
最近变更: [简述]
```

## 进行中的任务
- [ ] 任务1
- [ ] 任务2

## 已知问题
- 问题1: [描述]
- 问题2: [描述]

## 变更记录
### YYYY-MM-DD
- 变更内容

---

<!--
使用说明：
1. 复制此模板到项目 .claude/project.md
2. 填写各项内容
3. 代码变动时更新"当前状态"和"变更记录"
4. AI启动时会自动读取此文件
-->
