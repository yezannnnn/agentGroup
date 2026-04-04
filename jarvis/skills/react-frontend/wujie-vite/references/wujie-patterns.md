# wujie 微前端实践指南

## 目录

- [wujie 主应用完整配置](#wujie-主应用完整配置)
- [子应用完整配置（Vite + wujie）](#子应用完整配置vite--wujie)
- [主子应用通信详解](#主子应用通信详解)
- [样式隔离详解](#样式隔离详解)
- [常见坑和解决方案](#常见坑和解决方案)

---

## wujie 主应用完整配置

### 基础配置

```typescript
// main.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { setupApp, preloadApp, destroyApp, bus } from 'wujie';

// 主应用配置
const wujieConfig = {
  // 必填：微前端根节点 ID
  id: 'wujie-root',

  // 错误捕获回调
  errorCapture: (error: Error, info: { componentStack?: string }) => {
    console.error('子应用错误:', error);
    console.error('错误信息:', info);
    // 上报错误到监控系统
    reportError(error, info);
  },

  // 子应用运行时配置
  props: {
    // 主应用传递给子应用的数据
    mainData: {
      apiBase: import.meta.env.VITE_API_BASE_URL,
    },
  },

  // 是否启用 Shadow DOM 样式隔离
  shadow: true,

  // 子应用保活模式，设置为 true 时子应用不会重新渲染
  alive: false,

  // 生命周期钩子
  beforeLoad: async (appWindow: Window) => {
    console.log(`子应用 ${appWindow.__WUJIE?.id} 开始加载`);
  },

  beforeMount: async (appWindow: Window) => {
    console.log(`子应用 ${appWindow.__WUJIE?.id} 即将挂载`);
  },

  afterMount: async (appWindow: Window) => {
    console.log(`子应用 ${appWindow.__WUJIE?.id} 挂载完成`);
  },

  beforeUnmount: async (appWindow: Window) => {
    console.log(`子应用 ${appWindow.__WUJIE?.id} 即将卸载`);
  },

  afterUnmount: async (appWindow: Window) => {
    console.log(`子应用 ${appWindow.__WUJIE?.id} 卸载完成`);
  },
};

// 初始化 wujie
setupApp(wujieConfig);

// 预加载子应用（可选）
// 推荐在首屏使用子应用时预加载，提升用户体验
const preloadConfigs = [
  {
    name: 'sub-app-1',
    url: '//localhost:8080',
    exec: true,  // 是否直接执行，false 则只预加载不执行
  },
  {
    name: 'sub-app-2',
    url: '//localhost:8081',
    exec: false,
  },
];

preloadConfigs.forEach((config) => {
  preloadApp(config);
});

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

### 预加载子应用详解

```typescript
// 预加载 API 详解
preloadApp({
  name: string;           // 子应用名称（必填）
  url: string;            // 子应用地址（必填）
  exec?: boolean;         // 是否立即执行，默认 false
  props?: Record<string, unknown>;  // 传递给子应用的属性
});

// exec: true 的场景
// - 首屏需要立即展示的子应用
// - 用户频繁切换的子应用

// exec: false 的场景
// - 用户操作后才需要显示的子应用
// - 降低首屏加载压力
```

---

## 子应用完整配置（Vite + wujie）

### 子应用 main.ts

```typescript
// 子应用入口文件
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { bus } from 'wujie';

// wujie 生命周期 - 必须导出
export async function mount(props: { container?: HTMLElement; mainData?: Record<string, unknown> }) {
  console.log('子应用收到主应用数据:', props.mainData);

  const container = props.container || document.getElementById('root');

  ReactDOM.createRoot(container).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>
  );
}

// 卸载生命周期
export async function unmount() {
  console.log('子应用卸载');
}

// 可选：URL 修补（用于处理子应用路由）
export async function patchUrlQuery(url: string): Promise<string> {
  return url;
}

// 可选：单例模式配置
// 当 alive: true 时有效，控制子应用实例管理
export const lifecycle = {
  init: () => {
    console.log('子应用初始化');
  },
};
```

### 子应用 vite.config.ts

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],

  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },

  server: {
    port: 8080,
    headers: {
      // 跨域配置 - 关键！
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  },

  build: {
    // 子应用必须使用 umd 格式
    lib: {
      entry: resolve(__dirname, 'src/main.ts'),
      name: 'subApp',  // 子应用名称，需与主应用配置一致
      formats: ['umd'],
      fileName: () => 'index.js',
    },

    rollupOptions: {
      // 外部化依赖，避免重复打包
      external: [
        'react',
        'react-dom',
        'react-router-dom',
        'antd',
        '@ant-design/icons',
      ],

      output: {
        // UMD 格式必须指定全局变量
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
          'react-router-dom': 'ReactRouterDOM',
          antd: 'antd',
          '@ant-design/icons': 'Icons',
        },

        // 禁用代码分割，确保单文件输出
        inlineDynamicImport: false,

        // 输出目录
        dir: 'dist',

        // 静态资源目录
        assetsDir: 'assets',

        // chunk 文件名
        chunkFileNames: 'chunks/[name]-[hash].js',

        // 入口文件命名
        entryFileNames: '[name].js',

        // 静态资源命名
        assetFileNames: 'assets/[name]-[hash][extname]',
      },
    },

    // 关闭 sourcemap 生产
    sourcemap: false,

    // chunk 大小警告
    chunkSizeWarningLimit: 1500,

    // 压缩配置
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true,
      },
    },
  },

  // 开发环境优化
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom'],
    exclude: ['wujie'],
  },
});
```

### 子应用 package.json

```json
{
  "name": "sub-app",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.x"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.x",
    "vite": "^5.x"
  }
}
```

---

## 主子应用通信详解

### bus 事件通信机制

wujie 的 `bus` 是一个基于事件的通信桥梁，支持主子应用之间的双向通信。

### 核心 API

```typescript
import { bus } from 'wujie';

// 发送事件（同步）
bus.$emit(eventName: string, data?: unknown, appName?: string): void;

// 监听事件
bus.$on(eventName: string, listener: (data: unknown) => void): void;

// 一次性监听
bus.$once(eventName: string, listener: (data: unknown) => void): void;

// 取消监听
bus.$off(eventName: string, listener?: (data: unknown) => void): void;
```

### 主应用 -> 子应用通信

```typescript
// 主应用发送消息
function sendToSubApp() {
  const data = { type: 'login', token: 'xxx' };

  // 发送到所有子应用
  bus.$emit('main-to-sub', data);

  // 发送到指定子应用
  bus.$emit('main-to-sub', data, 'sub-app-1');
}
```

```typescript
// 子应用监听主应用消息
// main.ts
import { bus } from 'wujie';

export async function mount(props) {
  // 监听主应用消息
  bus.$on('main-to-sub', (data) => {
    console.log('收到主应用消息:', data);
    if (data.type === 'login') {
      // 处理登录逻辑
    }
  });
}

export async function unmount() {
  // 清理监听
  bus.$off('main-to-sub');
}
```

### 子应用 -> 主应用通信

```typescript
// 子应用发送消息
import { bus } from 'wujie';

function notifyMainApp() {
  const data = { type: 'user-action', action: 'click', timestamp: Date.now() };
  bus.$emit('sub-to-main', data);
}
```

```typescript
// 主应用监听子应用消息
// main.tsx 或组件中
import { bus } from 'wujie';

function setupBusListeners() {
  bus.$on('sub-to-main', (data) => {
    console.log('收到子应用消息:', data);
    if (data.type === 'user-action') {
      // 处理子应用用户行为
    }
  });

  // 清理函数
  return () => {
    bus.$off('sub-to-main');
  };
}
```

### props 方式通信

除了 bus 事件，还可以通过 props 传递数据：

```typescript
// 主应用配置
setupApp({
  props: {
    // 传递给所有子应用的数据
    sharedData: {
      token: 'xxx',
      userInfo: {},
    },

    // 传递给指定子应用的函数
    onLogin: (userData) => {
      console.log('子应用登录回调', userData);
    },
  },
});
```

```typescript
// 子应用接收
export async function mount(props) {
  console.log('主应用传递的数据:', props.sharedData);
  console.log('主应用回调函数:', props.onLogin);

  // 调用主应用函数
  props.onLogin?.({ name: 'sub-user' });
}
```

### 通信最佳实践

```typescript
// 1. 定义通信协议
const BusEvents = {
  // 用户相关
  USER_LOGIN: 'user:login',
  USER_LOGOUT: 'user:logout',
  USER_INFO_UPDATE: 'user:info-update',

  // 路由相关
  ROUTE_CHANGE: 'route:change',

  // 业务相关
  ORDER_CREATE: 'order:create',
  ORDER_CANCEL: 'order:cancel',
} as const;

// 2. 类型化通信数据
interface UserLoginData {
  type: 'user:login';
  payload: {
    token: string;
    userId: string;
  };
}

// 3. 使用统一的事件发送函数
function emitMainToSub(event: string, data?: unknown) {
  bus.$emit(event, data);
}
```

---

## 样式隔离详解

### Shadow DOM 样式隔离

wujie 支持两种样式隔离方式：

1. **Shadow DOM 模式**（推荐）：完全隔离，样式互不影响
2. **样式匹配模式**：通过 CSS 选择器匹配实现隔离

### Shadow DOM 配置

```typescript
// 主应用配置
setupApp({
  id: 'wujie-root',
  shadow: true,  // 启用 Shadow DOM 样式隔离
});
```

### 样式冲突处理

当子应用样式与主应用冲突时：

```typescript
// 方案 1：使用 Shadow DOM
setupApp({
  shadow: true,
});

// 方案 2：手动处理样式前缀
// 子应用中为所有样式添加统一前缀
.sub-app {
  .button {
    color: blue;
  }
}

// 方案 3：使用 CSS Modules
// vite.config.ts
export default defineConfig({
  css: {
    modules: {
      localsConvention: 'camelCase',
      generateScopedName: '[name]__[local]___[hash:base64:5]',
    },
  },
});
```

### 全局样式穿透

有时需要子应用样式穿透到主应用：

```typescript
// 主应用配置
setupApp({
  // 全局样式选择器（不会被 Shadow DOM 隔离）
  globalStyle: `
    .ant-btn {
      /* 共享按钮样式 */
    }
  `,
});
```

### 动态样式加载

```typescript
// 子应用动态加载外部样式
function loadExternalStyles() {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = '//example.com/styles.css';
  document.head.appendChild(link);
}
```

---

## 常见坑和解决方案

### 1. 子应用加载失败

**错误信息**: `Failed to load sub application`

**可能原因**:
- CORS 配置缺失
- 子应用 URL 不正确
- 子应用构建产物路径错误

**解决方案**:

```typescript
// 检查 CORS 配置（子应用 vite.config.ts）
server: {
  headers: {
    'Access-Control-Allow-Origin': '*',
  },
}

// 检查子应用 URL
const apps = [
  { name: 'sub-app', url: '//localhost:8080' },  // 使用双斜杠
];
```

### 2. 样式污染

**问题描述**: 子应用样式影响主应用，或主应用样式影响子应用

**解决方案**:

```typescript
// 方案 1：启用 Shadow DOM
setupApp({
  shadow: true,
});

// 方案 2：使用 CSS Modules
// 子应用组件样式
import styles from './Component.module.css';

// 方案 3：使用唯一前缀
.button-sub-app {
  /* 唯一前缀避免冲突 */
}
```

### 3. 状态管理冲突

**问题描述**: 子应用使用了和主应用相同的状态管理库，导致状态混乱

**解决方案**:

```typescript
// 子应用使用独立的 store
// store/userStore.ts
import { create } from 'zustand';

// 创建独立的 store 实例
const userStore = create<UserState>((set) => ({
  // ...
}));

export { userStore };
```

### 4. 路由同步问题

**问题描述**: 子应用路由变化后，主应用不知道

**解决方案**:

```typescript
// 主应用监听子应用路由变化
import { bus } from 'wujie';
import { useLocation, useNavigate } from 'react-router-dom';

function useSubAppRouteSync() {
  const navigate = useNavigate();

  React.useEffect(() => {
    bus.$on('route-change', (path: string) => {
      navigate(path);
    });

    return () => {
      bus.$off('route-change');
    };
  }, [navigate]);
}
```

### 5. 子应用热更新失效

**问题描述**: 子应用修改后浏览器没有热更新

**解决方案**:

```typescript
// vite.config.ts (子应用)
export default defineConfig({
  server: {
    port: 8080,
    hmr: {
      port: 8080,
    },
  },
});
```

### 6. 内存泄漏

**问题描述**: 子应用卸载后定时器、事件监听器未清理

**解决方案**:

```typescript
// main.ts (子应用)
export async function unmount() {
  // 清理定时器
  clearInterval(timerId);
  clearTimeout(timeoutId);

  // 清理事件监听
  window.removeEventListener('resize', handleResize);

  // 清理 bus 监听
  bus.$off('main-to-sub');

  // 清理 Redux/Zustand store
  store.reset();
}
```

### 7. 依赖版本冲突

**问题描述**: 主应用和子应用使用不同版本的 React

**解决方案**:

```typescript
// 子应用 package.json 锁定依赖版本
{
  "dependencies": {
    "react": "18.2.0",
    "react-dom": "18.2.0"
  }
}

// 或使用 peerDependencies 声明兼容版本
{
  "peerDependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
```

### 8. 请求携带 cookie 失败

**问题描述**: 子应用请求没有携带主应用的 cookie

**解决方案**:

```typescript
// 子应用 axios 配置
const request = axios.create({
  withCredentials: true,  // 关键配置
});

// 或在 fetch 中配置
fetch(url, {
  credentials: 'include',
});
```

---

## 最佳实践清单

- [ ] CORS 配置完整
- [ ] 启用 Shadow DOM 样式隔离
- [ ] 子应用生命周期函数正确导出
- [ ] 卸载时清理所有监听器和定时器
- [ ] 使用统一的事件名称常量
- [ ] 依赖版本与主应用兼容
- [ ] axios 配置 withCredentials
- [ ] 预加载高频访问的子应用
- [ ] 错误边界捕获子应用异常
- [ ] 路由同步配置完整
