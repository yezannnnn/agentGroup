# qiankun + wujie 微前端架构指南

> ⚠️ 本文档为骨架，请根据你们团队实际情况填写。

---

## 技术选型说明

> ⚠️ **待填写**：填写你们的微前端选型决策，以及不同场景使用哪个框架

| 场景 | 使用框架 | 原因 |
|------|---------|------|
| （待填写） | qiankun | |
| （待填写） | wujie   | |

---

## 整体架构

> ⚠️ **待填写**：画出你们的微前端应用拓扑（主应用名称、子应用列表、各自负责的功能模块）

```
主应用（main-app）
├── 子应用 1：sub-app-name        路由前缀：/sub-1/
├── 子应用 2：sub-app-name        路由前缀：/sub-2/
└── ...
```

---

## qiankun 方案

### 主应用配置（UmiJS + @umijs/plugin-qiankun）

```typescript
// config/config.ts
export default {
  qiankun: {
    master: {
      apps: [
        {
          name: 'sub-app-1',          // TODO: 子应用唯一标识
          entry: process.env.NODE_ENV === 'development'
            ? '//localhost:7001'      // TODO: 子应用开发地址
            : '//your-domain.com/sub-app-1',  // TODO: 生产地址
          container: '#sub-app-container',    // 子应用挂载 DOM
          activeRule: '/sub-app-1',           // TODO: 激活路由规则
          props: {                            // 传给子应用的 props
            // TODO: 填写传递的数据
          },
        },
        // TODO: 其他子应用
      ],
    },
  },
};
```

### 主子应用通信

```typescript
// 主应用：初始化全局状态
import { initGlobalState, MicroAppStateActions } from 'qiankun';

let actions: MicroAppStateActions;

export function setupGlobalState() {
  actions = initGlobalState({
    // TODO: 填写主子应用共享的数据
    token: getToken(),
    userInfo: getCurrentUser(),
    theme: 'light',
  });

  // 监听子应用修改（主应用也监听）
  actions.onGlobalStateChange((state, prev) => {
    console.log('[主应用] 全局状态变化:', state);
  });
}

// 更新全局状态（主应用修改）
export function updateGlobalState(key: string, value: any) {
  actions.setGlobalState({ [key]: value });
}
```

```typescript
// 子应用：接收主应用传来的 props 和全局状态
export function mount(props: any) {
  const { onGlobalStateChange, setGlobalState, token } = props;

  // 监听全局状态
  onGlobalStateChange((state: any) => {
    // TODO: 处理来自主应用的状态变化
    console.log('[子应用] 收到全局状态:', state);
  }, true); // true: 立即触发一次

  // 修改全局状态（子应用 → 主应用）
  // setGlobalState({ someKey: newValue });

  ReactDOM.render(<App token={token} />, document.getElementById('root'));
}
```

### 子应用适配（Vite 项目）

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import qiankun from 'vite-plugin-qiankun';

export default defineConfig({
  plugins: [
    qiankun('sub-app-1', {  // TODO: 填写子应用名称
      useDevMode: true,
    }),
  ],
  server: {
    port: 7001,  // TODO: 填写子应用端口
    cors: true,  // 允许主应用跨域访问
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
});
```

```typescript
// src/main.ts（子应用入口）
import { renderWithQiankun, qiankunWindow } from 'vite-plugin-qiankun/dist/helper';

renderWithQiankun({
  mount(props) {
    render(props);
  },
  bootstrap() {},
  unmount() {
    ReactDOM.unmountComponentAtNode(document.getElementById('root')!);
  },
});

// 独立运行（不在 qiankun 环境）
if (!qiankunWindow.__POWERED_BY_QIANKUN__) {
  render({});
}
```

### 样式隔离方案

> ⚠️ **待填写**：填写你们选择的样式隔离策略

```typescript
// 方案一：Strict 模式（Shadow DOM，强隔离，但部分组件不兼容）
sandbox: { strictStyleIsolation: true }

// 方案二：Scoped CSS（推荐，兼容性好）
sandbox: { experimentalStyleIsolation: true }

// 方案三：手动添加 CSS 前缀（完全兼容，但需改造 CSS）
// 给子应用所有 CSS 加前缀，如：.sub-app-1 .ant-button { ... }
```

---

## wujie（无界）方案

### 主应用接入

```tsx
// 安装：pnpm add wujie-react
import WujieReact from 'wujie-react';
import { setupApp, preloadApp } from 'wujie';

// 在应用初始化时配置子应用（可选，用于预加载）
setupApp({
  name: 'sub-app-1',
  url: 'http://localhost:7001',
  // TODO: 按需填写 alive（保活）/ degrade（降级）模式
  alive: true,  // 保活模式：切换时不销毁，性能好
});

// 预加载（可选，提升首次打开速度）
preloadApp({ name: 'sub-app-1', url: 'http://localhost:7001' });
```

```tsx
// 子应用容器组件
const SubAppContainer: React.FC<{ name: string; url: string }> = ({ name, url }) => {
  return (
    <WujieReact
      width="100%"
      height="100%"
      name={name}
      url={url}
      sync={true}           // URL 同步：子应用路由变化同步到主应用 URL
      // TODO: 填写 props（传给子应用的数据）
      props={{
        userInfo: getCurrentUser(),
        token: getToken(),
        // TODO: 填写其他共享数据
      }}
      // TODO: 填写 bus 事件（主子应用事件通信）
    />
  );
};
```

### wujie 主子应用通信（EventBus）

```typescript
// 主应用发消息给子应用
import { bus } from 'wujie';
bus.$emit('main-to-sub', { action: 'refresh', payload: { id: '123' } });

// 主应用监听子应用消息
bus.$on('sub-to-main', (data: any) => {
  console.log('[主应用] 收到子应用消息:', data);
});

// 子应用发消息给主应用（子应用代码）
window.$wujie?.bus.$emit('sub-to-main', { type: 'logout' });

// 子应用监听主应用消息
window.$wujie?.bus.$on('main-to-sub', (data: any) => {
  console.log('[子应用] 收到主应用消息:', data);
});
```

### 子应用适配（Vite 项目）

```typescript
// src/main.ts（子应用）
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

function render() {
  const container = document.getElementById('app');
  ReactDOM.createRoot(container!).render(<App />);
}

// wujie 环境
if (window.__POWERED_BY_WUJIE__) {
  window.__WUJIE_MOUNT = () => render();
  window.__WUJIE_UNMOUNT = () => {
    // ReactDOM.unmountComponentAtNode(container!); // 按需处理
  };
  // 触发首次挂载
  window.__WUJIE?.mount();
} else {
  // 独立运行
  render();
}
```

```typescript
// vite.config.ts（子应用的跨域配置）
export default defineConfig({
  server: {
    port: 7001,  // TODO: 填写端口
    cors: true,
    origin: 'http://localhost:7001',  // TODO: 填写子应用访问地址
  },
  base: process.env.NODE_ENV === 'development' ? '/' : '/sub-app-1/',  // TODO: 生产环境路径
});
```

---

## 公共资源共享

> ⚠️ **待填写**：填写你们在主子应用之间共享的内容（token/用户信息/字典数据/样式变量）

```typescript
// 方案：主应用通过 props/bus 传入，子应用通过 window 访问
// 或：子应用直接调用主应用提供的接口（共用 Auth）

// TODO: 填写你们的共享方案
```

---

## 微前端常见坑

> ⚠️ **待填写**：填写你们遇到的实际问题

### 坑 1：子应用样式污染主应用
**现象**：子应用的 CSS Reset 影响主应用样式  
**解决**：根据选型填写（strictStyleIsolation / scopedCSS / 手动前缀）

### 坑 2：子应用 Antd 弹窗不在 Shadow DOM 内
**现象**：strictStyleIsolation 模式下，Modal/Tooltip 样式丢失  
**解决**：
```tsx
// 设置 Modal/Notification 等组件的挂载节点在 Shadow DOM 内
import { StyleProvider } from '@ant-design/cssinjs';

<StyleProvider container={shadowRoot}>
  <ConfigProvider>
    <App />
  </ConfigProvider>
</StyleProvider>
```

### 坑 3：（待填写）
**现象**：  
**解决**：

---

## 本地开发联调方式

> ⚠️ **待填写**：填写你们本地同时跑多个应用的方式

```bash
# 同时启动主应用和子应用（推荐用 concurrently）
# package.json scripts 示例（待填写实际命令）
"dev:all": "concurrently \"npm run dev\" \"cd ../sub-app-1 && npm run dev\""

# 或分别在不同终端启动
# 主应用: npm run dev (port: 8000)
# 子应用1: npm run dev (port: 7001)
# 子应用2: npm run dev (port: 7002)
```

---

## TODO 待补充内容

- [ ] 完整的子应用列表（名称/端口/路由前缀/负责团队）
- [ ] 生产环境部署方案（nginx 配置）
- [ ] CI/CD 各子应用独立发布流程
- [ ] 主子应用版本兼容规则
- [ ] 实际踩坑记录
