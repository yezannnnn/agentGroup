---
name: cypress
description: Cypress E2E 测试自动化
---

# Cypress Testing Skill

Cypress端到端(E2E)测试框架的使用指南和最佳实践。

## 简介

Cypress是一个现代的前端测试工具，专为Web应用E2E测试设计。它提供了快速、可靠且易于调试的测试体验。

## 安装

```bash
# npm安装
npm install cypress --save-dev

# yarn安装
yarn add cypress --dev

# pnpm安装
pnpm add cypress --save-dev
```

## 启动Cypress

```bash
# 打开Cypress Test Runner
npx cypress open

# 运行所有测试(无头模式)
npx cypress run
```

## 项目结构

```
cypress/
├── e2e/                    # E2E测试文件
│   └── *.cy.js
├── fixtures/               # 测试数据
│   └── *.json
├── support/                # 支持文件
│   ├── commands.js         # 自定义命令
│   └── e2e.js              # 全局配置
└── downloads/              # 下载文件
```

## 基础用法

### 编写测试

```javascript
// cypress/e2e/example.cy.js
describe('示例测试套件', () => {
  beforeEach(() => {
    cy.visit('https://example.com')
  })

  it('应该正确加载首页', () => {
    cy.contains('欢迎')
    cy.url().should('include', '/home')
  })

  it('应该能够登录', () => {
    cy.get('[data-testid="username"]').type('testuser')
    cy.get('[data-testid="password"]').type('password123')
    cy.get('[data-testid="login-btn"]').click()
    cy.contains('登录成功')
  })
})
```

### 常用命令

| 命令 | 描述 |
|------|------|
| `cy.visit(url)` | 访问URL |
| `cy.get(selector)` | 获取DOM元素 |
| `cy.find(selector)` | 在元素内查找 |
| `cy.contains(text)` | 查找包含文本的元素 |
| `cy.type(text)` | 输入文本 |
| `cy.click()` | 点击元素 |
| `cy.wait(ms)` | 等待指定时间 |
| `cy.intercept()` | 拦截网络请求 |

### 断言

```javascript
// 可见性断言
cy.get('.element').should('be.visible')

// 内容断言
cy.get('.title').should('contain', '预期文本')

// URL断言
cy.url().should('eq', 'https://example.com/dashboard')

// 状态码断言
cy.request('/api/users').its('status').should('eq', 200)
```

## 高级特性

### 自定义命令

```javascript
// cypress/support/commands.js
Cypress.Commands.add('login', (username, password) => {
  cy.session([username, password], () => {
    cy.visit('/login')
    cy.get('#username').type(username)
    cy.get('#password').type(password)
    cy.get('button[type="submit"]').click()
    cy.url().should('include', '/dashboard')
  })
})

// 使用自定义命令
cy.login('testuser', 'password123')
```

### 网络请求拦截

```javascript
// 拦截API请求
cy.intercept('GET', '/api/users', {
  statusCode: 200,
  body: { users: [{ id: 1, name: 'Test' }] }
}).as('getUsers')

// 等待请求完成
cy.wait('@getUsers')
```

### 文件上传

```javascript
cy.get('input[type="file"]').selectFile('cypress/fixtures/upload.pdf', {
  force: true
})
```

## 配置

### cypress.config.js

```javascript
const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: true,
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 10000,
    setupNodeEvents(on, config) {
      // 实现node事件监听器
    }
  }
})
```

## CI/CD集成

### GitHub Actions

```yaml
name: E2E Tests
on: [push]
jobs:
  cypress-run:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cypress-io/github-action@v5
        with:
          build: npm run build
          start: npm start
          wait-on: 'http://localhost:3000'
```

## 最佳实践

1. **使用data-testid属性**：避免使用不稳定的CSS选择器
2. **使用cy.session()**：缓存登录状态，提高测试速度
3. **避免使用cy.wait()固定等待**：使用cy.intercept()等待网络请求
4. **保持测试独立**：每个测试都应该能够独立运行
5. **使用Page Object模式**：组织页面元素和操作方法
