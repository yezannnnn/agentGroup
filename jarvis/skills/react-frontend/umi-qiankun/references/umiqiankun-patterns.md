# qiankun 微前端配置详解

> 本文档详细说明 qiankun 主子应用的完整配置、通信机制和最佳实践。

---

## 1. 主应用配置（UmiJS + @umijs/plugin-qiankun）

### 基础配置

```typescript
// config/config.ts
export default {
  qiankun: {
    master: {
      apps: [
        {
          name: 'sub-app-1',                    // 子应用唯一标识（必须与子应用 registerMicroApps 中的一致）
          entry: process.env.NODE_ENV === 'development'
            ? '//localhost:7001'                // 开发环境子应用地址
            : '//your-domain.com/sub-app-1',    // 生产环境子应用地址
          container: '#sub-app-container',      // 子应用挂载的 DOM 节点选择器
          activeRule: '/sub-app-1',             // 激活子应用的路由规则
          props: {
            // 传给子应用的初始属性
            token: localStorage.getItem('token'),
            userInfo: getCurrentUser(),
            baseRoute: '/sub-app-1',
          },
        },
        // 可以配置多个子应用
        {
          name: 'sub-app-2',
          entry: process.env.NODE_ENV === 'development'
            ? '//localhost:7002'
            : '//your-domain.com/sub-app-2',
          container: '#sub-app-container',
          activeRule: '/sub-app-2',
          props: {
            token: localStorage.getItem('token'),
          },
        },
      ],
      // 手动加载模式（可选，默认 false）
      // true: 通过 manualRegisterApp 手动注册子应用
      // false: 自动从 apps 配置加载
      defer: false,
    },
  },
};
```

### 主应用 Layout 组件

```tsx
// src/layouts/index.tsx
import { Outlet } from 'umi';

export default function Layout() {
  return (
    <div>
      <header>主应用头部</header>
      <div id="sub-app-container">
        {/* 子应用将挂载到这里 */}
        <Outlet />
      </div>
      <footer>主应用底部</footer>
    </div>
  );
}
```

---

## 2. 子应用配置（Vite + qiankun）

### vite.config.ts 完整配置

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import qiankun from 'vite-plugin-qiankun';
import { resolve } from 'path';

export default defineConfig({
  plugins: [
    qiankun('sub-app-1', {  // 必须与主应用 apps[].name 一致
      useDevMode: true,      // 开发模式，开启后支持热更新
    }),
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 7001,              // 子应用端口
    cors: true,              // 允许跨域
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
    origin: 'http://localhost:7001',  // 设置 origin 避免跨域问题
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    rollupOptions: {
      output: {
        // 生产环境资源路径
        // 子应用必须使用相对路径，否则在主应用中加载会有问题
        entryFileNames: 'js/[name]-[hash].js',
        chunkFileNames: 'js/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash][extname]',
        // 重要：手动指定 publicPath
        manualChunks: undefined,
      },
    },
  },
});
```

### 子应用入口 main.ts

```typescript
// src/main.ts
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, HashRouter } from 'react-router-dom';
import App from './App';
import { renderWithQiankun, qiankunWindow } from 'vite-plugin-qiankun/dist/helper';

// 判断是否在 qiankun 环境中运行
const isQiankun = qiankunWindow.__POWERED_BY_QIANKUN__;

function render(props: any = {}) {
  const { container } = props;

  // 使用 HashRouter 避免子应用路由与主应用路由冲突
  const root = container
    ? container.querySelector('#root')
    : document.getElementById('root');

  if (!root) return;

  const app = ReactDOM.createRoot(root);

  app.render(
    <BrowserRouter basename={isQiankun ? '/sub-app-1' : '/'}>
      <App {...props} />
    </BrowserRouter>
  );
}

// qiankun 环境下的生命周期钩子
renderWithQiankun({
  // 应用挂载前调用
  bootstrap() {
    console.log('[sub-app-1] bootstrap');
  },

  // 应用挂载时调用
  mount(props) {
    console.log('[sub-app-1] mount', props);
    render(props);
  },

  // 应用更新时调用（当 props 变化时）
  update(props) {
    console.log('[sub-app-1] update', props);
  },

  // 应用卸载时调用
  unmount(props) {
    console.log('[sub-app-1] unmount', props);
    // 销毁 React 应用
    // ReactDOM.unmountComponentAtNode(document.getElementById('root')!);
  },
});

// 独立运行（不在 qiankun 环境）
if (!isQiankun) {
  console.log('[sub-app-1] 独立运行模式');
  render({});
}
```

---

## 3. 主子应用通信

### 3.1 initGlobalState 全局状态

#### 主应用端

```typescript
// src/models/globalState.ts
import { initGlobalState, MicroAppStateActions } from 'qiankun';

export interface GlobalState {
  token: string | null;
  userInfo: any;
  theme: 'light' | 'dark';
  // 可以添加更多全局状态
}

let actions: MicroAppStateActions;

export function setupGlobalState() {
  // 初始化全局状态
  actions = initGlobalState<GlobalState>({
    token: localStorage.getItem('token'),
    userInfo: null,
    theme: 'light',
  });

  // 监听全局状态变化（可监听所有子应用和主应用的状态变更）
  actions.onGlobalStateChange<GlobalState>(
    (state, prev) => {
      console.log('[主应用] 全局状态变化:', state, '前一个状态:', prev);

      // 当 token 变化时，更新本地存储和请求头
      if (state.token !== prev.token) {
        if (state.token) {
          localStorage.setItem('token', state.token);
        } else {
          localStorage.removeItem('token');
        }
      }
    },
    true  // true: 立即触发一次，拿到当前状态
  );

  return actions;
}

// 设置全局状态
export function setGlobalState<T = any>(state: Partial<T>) {
  if (actions) {
    actions.setGlobalState(state);
  }
}

// 获取当前全局状态
export function getGlobalState<T = any>(): T | undefined {
  if (actions) {
    return actions.getGlobalState();
  }
  return undefined;
}

// 清除全局状态监听
export function offGlobalStateChange() {
  if (actions) {
    actions.offGlobalStateChange?.();
  }
}
```

#### 子应用端

```typescript
// src/main.ts
import { renderWithQiankun, qiankunWindow } from 'vite-plugin-qiankun/dist/helper';

let globalProps: any = {};

renderWithQiankun({
  mount(props) {
    globalProps = props;

    // 1. 监听全局状态变化
    props.onGlobalStateChange(
      (state: any, prev: any) => {
        console.log('[子应用] 全局状态变化:', state, '前一个状态:', prev);

        // 根据全局状态更新子应用（如用户信息、主题等）
        if (state.userInfo !== prev.userInfo) {
          // 处理用户信息更新
          console.log('[子应用] 用户信息已更新:', state.userInfo);
        }
      },
      true  // 立即触发一次
    );

    // 2. 获取初始全局状态
    const initialState = props.getGlobalState?.();
    console.log('[子应用] 初始全局状态:', initialState);

    // 3. 修改全局状态（子应用 -> 主应用 -> 其他子应用）
    // props.setGlobalState({ userInfo: { name: '子应用更新' } });

    render(props);
  },
  unmount() {
    // 卸载时清除引用
    globalProps = {};
  },
});
```

### 3.2 父子应用通信流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                          主应用                                  │
│  ┌─────────────────┐    ┌──────────────────────────────────┐   │
│  │ initGlobalState  │───>│ onGlobalStateChange 监听变化     │   │
│  │ (初始化全局状态)  │    └──────────────────────────────────┘   │
│  └─────────────────┘                      ▲                     │
│           │                               │                     │
│           ▼                               │                     │
│  ┌─────────────────┐    setGlobalState ──┘                     │
│  │ setGlobalState  │<──────────────────────────────────────────│
│  │ (主动设置状态)   │                                         │
│  └─────────────────┘                                         │
└─────────────────────────────────────────────────────────────────┘
                              │ ▲
                    props    │ │    props
                              ▼ │
┌─────────────────────────────────────────────────────────────────┐
│                          子应用                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ onGlobalStateChange 监听变化                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              ▲                                  │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ setGlobalState 修改全局状态（可同步到主应用和其他子应用）  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. 样式隔离方案

### 4.1 Strict Style Isolation（Shadow DOM）

```typescript
// 主应用配置
sandbox: {
  strictStyleIsolation: true,
}
```

**原理**：使用 Web Shadow DOM 特性，将子应用样式完全隔离在 Shadow Root 中。

**优点**：
- 样式完全隔离，不会污染主应用
- 子应用 CSS 完全独立

**缺点**：
- 一些 UI 库（如 Antd）依赖 Portal 的组件（Modal、Tooltip、Popover）样式会丢失
- 需要额外配置 StyleProvider

**Antd 组件兼容处理**：

```tsx
// 子应用入口文件中配置
import { StyleProvider } from '@ant-design/cssinjs';

renderWithQiankun({
  mount(props) {
    const shadowRoot = props.container?.querySelector('#root')?.attachShadow?.() || document.head;

    app.render(
      <StyleProvider container={shadowRoot as any}>
        <ConfigProvider>
          <App {...props} />
        </ConfigProvider>
      </StyleProvider>
    );
  },
});
```

### 4.2 Experimental Style Isolation（推荐）

```typescript
// 主应用配置
sandbox: {
  experimentalStyleIsolation: true,
}
```

**原理**：给子应用的根元素添加一个唯一的 data-xxx 属性选择器，自动给子应用所有 CSS 规则添加前缀。

**转换示例**：

```css
/* 子应用原始 CSS */
.ant-button { color: red; }

/* 转换后 */
.ant-button[data-micro-app-id="sub-app-1"] { color: red; }
```

**优点**：
- 兼容性好，不影响组件功能
- Antd 等 UI 库正常工作

**缺点**：
- 需要运行时处理，性能略有开销
- 第三方库的动态样式可能需要额外处理

### 4.3 手动 CSS 前缀

通过构建工具或人工给子应用所有 CSS 添加统一前缀。

**方式一：Webpack CSS Loader**

```javascript
// webpack 配置
{
  test: /\.css$/,
  use: [
    {
      loader: 'css-loader',
      options: {
        importLoaders: 1,
        modules: {
          generateScopedName: '[name]__[local]___[hash:base64:5]',
        },
      },
    },
  ],
}
```

**方式二：手动命名规范**

```css
/* 所有子应用 CSS 都以子应用 ID 为前缀 */
.sub-app-1 .ant-button {
  color: red;
}

.sub-app-1 .ant-table {
  font-size: 14px;
}
```

**优点**：
- 完全可控，无运行时开销
- 适合样式规范严格的团队

**缺点**：
- 需要改造现有 CSS
- 第三方库样式需要额外处理

---

## 5. 常见坑和解决方案

### 坑 1：子应用样式污染主应用

**现象**：子应用的全局样式（如 CSS Reset、Ant Design 样式）影响了主应用的组件样式。

**原因**：子应用 CSS 没有正确隔离。

**解决**：
1. 使用 `experimentalStyleIsolation: true` 配置
2. 或给子应用配置 `strictStyleIsolation: true` + StyleProvider

### 坑 2：Antd Modal/Tooltip 样式丢失

**现象**：在 `strictStyleIsolation` 模式下，Antd 的 Modal、Tooltip、Popover、Select dropdown 等组件样式丢失或显示异常。

**原因**：这些组件使用 Portal 将元素挂载到 body，而 Shadow DOM 的样式无法穿透。

**解决**：

```tsx
// 子应用入口配置
import { StyleProvider, createCache } from '@ant-design/cssinjs';
import { ConfigProvider } from 'antd';

const cache = createCache();

renderWithQiankun({
  mount(props) {
    // 获取 Shadow DOM 或 document head 作为样式容器
    const styleContainer = props.container?.querySelector('#root')?.attachShadow?.()
      || document.head;

    app.render(
      <ConfigProvider
        theme={{ token: { colorPrimary: '#1890ff' } }}
      >
        <StyleProvider cache={cache} container={styleContainer as any}>
          <App {...props} />
        </StyleProvider>
      </ConfigProvider>
    );
  },
});
```

### 坑 3：子应用资源 404

**现象**：子应用独立运行时正常，但在主应用中加载时出现资源 404。

**原因**：
1. 子应用 `base` 配置不正确
2. 子应用 `publicPath` 配置为绝对路径

**解决**：

```typescript
// vite.config.ts
export default defineConfig({
  base: process.env.NODE_ENV === 'production' ? '/sub-app-1/' : '/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // 确保 publicPath 正确
    assetsInlineLimit: 0,
  },
});
```

### 坑 4：子应用路由与主应用路由冲突

**现象**：刷新页面时，子应用路由没有正确匹配到子应用，而是被主应用捕获。

**原因**：子应用路由 `basename` 配置不正确。

**解决**：

```tsx
// 子应用路由配置
function render(props: any) {
  const isQiankun = qiankunWindow.__POWERED_BY_QIANKUN__;

  const root = container?.querySelector('#root') || document.getElementById('root');

  ReactDOM.createRoot(root!).render(
    <BrowserRouter basename={isQiankun ? '/sub-app-1' : '/'}>
      <App {...props} />
    </BrowserRouter>
  );
}
```

### 坑 5：主子应用通信状态丢失

**现象**：切换子应用后，子应用设置的全局状态丢失。

**原因**：
1. 子应用被卸载时没有正确保存状态
2. 主应用状态没有持久化

**解决**：

```typescript
// 子应用卸载前保存状态
unmount(props) {
  // 通过 props 将状态回传给主应用
  props.setGlobalState?.({
    subAppState: this.state,
  });
  ReactDOM.unmountComponentAtNode(document.getElementById('root')!);
}

// 主应用监听状态并持久化
actions.onGlobalStateChange((state) => {
  localStorage.setItem('globalState', JSON.stringify(state));
}, true);
```

### 坑 6：热更新失效

**现象**：开发模式下，子应用代码修改后浏览器没有自动刷新。

**原因**：
1. `useDevMode` 没有开启
2. 子应用和主应用端口冲突

**解决**：

```typescript
// vite.config.ts
plugins: [
  qiankun('sub-app-1', {
    useDevMode: true,  // 开启开发模式
  }),
],
```

### 坑 7：子应用体积过大

**现象**：子应用加载时间过长。

**解决**：
1. 使用动态 import 懒加载路由组件
2. 提取公共依赖到主应用
3. 开启 gzip 压缩
4. 使用预加载策略 `prefetchApps`

---

## 6. 完整示例

### 主应用完整配置

```typescript
// config/config.ts
import { defineConfig } from 'umi';

export default defineConfig({
  qiankun: {
    master: {
      apps: [
        {
          name: 'sub-app-1',
          entry: '//localhost:7001',
          container: '#sub-app-container',
          activeRule: '/sub-app-1',
          props: {
            token: localStorage.getItem('token'),
          },
        },
        {
          name: 'sub-app-2',
          entry: '//localhost:7002',
          container: '#sub-app-container',
          activeRule: '/sub-app-2',
          props: {
            token: localStorage.getItem('token'),
          },
        },
      ],
      // prefetch: true,  // 预加载子应用资源
      // defer: true,     // 手动注册模式
    },
  },
  routes: [
    {
      path: '/',
      component: '@/layouts/index',
      routes: [
        { path: '/', redirect: '/dashboard' },
        { path: '/dashboard', component: '@/pages/dashboard' },
        { path: '/sub-app-1/*', component: '@/pages/sub-app-1' },
        { path: '/sub-app-2/*', component: '@/pages/sub-app-2' },
      ],
    },
  ],
});
```

### 子应用完整入口

```typescript
// src/main.ts
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, HashRouter } from 'react-router-dom';
import App from './App';
import { renderWithQiankun, qiankunWindow } from 'vite-plugin-qiankun/dist/helper';
import { StyleProvider, createCache } from '@ant-design/cssinjs';
import { ConfigProvider } from 'antd';

const isQiankun = qiankunWindow.__POWERED_BY_QIANKUN__;
const cache = createCache();

function render(props: any = {}) {
  const { container } = props;
  const root = container?.querySelector('#root') || document.getElementById('root');

  if (!root) return;

  const app = ReactDOM.createRoot(root);

  app.render(
    <HashRouter>
      <StyleProvider cache={cache}>
        <ConfigProvider>
          <App {...props} />
        </ConfigProvider>
      </StyleProvider>
    </HashRouter>
  );
}

renderWithQiankun({
  bootstrap() {
    console.log('[sub-app-1] bootstrap');
  },
  mount(props) {
    console.log('[sub-app-1] mount', props);
    render(props);
  },
  update(props) {
    console.log('[sub-app-1] update', props);
  },
  unmount(props) {
    console.log('[sub-app-1] unmount', props);
  },
});

if (!isQiankun) {
  render({});
}
```
