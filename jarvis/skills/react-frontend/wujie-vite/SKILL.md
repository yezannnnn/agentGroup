# wujie-vite 微前端技能

## 概述

wujie-vite 是基于 Vite + wujie + Zustand 的微前端技能，专为主子应用架构设计，提供完整的微前端解决方案。

## 基础信息

- **name**: wujie-vite
- **description**: 包含 wujie 主子应用配置、wujie 主子应用通信、wujie 子应用接入、wujie 样式隔离、Vite 构建配置、Vite 优化、Zustand 状态管理、axios 请求封装、React 18 最佳实践、微前端路由同步、Shadow DOM 样式隔离
- **触发关键词**: wujie, 微前端, 主子应用, 子应用接入, 样式隔离, Shadow DOM, bus 通信, 主应用配置, preloadApp, setupApp

## 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| React | 18+ | 前端框架 |
| TypeScript | 5 | 类型系统 |
| Vite | latest | 构建工具 |
| Ant Design | 5 | UI 组件库 |
| @ant-design/pro-components | 2.8 | Pro 组件 |
| Zustand | latest | 状态管理 |
| wujie | latest | 微前端框架 |

## 目录结构

```
wujie-vite/
├── SKILL.md
├── references/
│   └── wujie-patterns.md
├── vite.config.ts          # Vite 构建配置
├── store/
│   ├── userStore.ts        # 用户状态
│   └── storeIndex.ts       # store 导出
├── api/
│   └── request.ts          # axios 封装
├── components/
│   ├── WujieContainer.tsx   # wujie 容器组件
│   └── StyleProvider.tsx    # Shadow DOM 样式隔离
└── main.tsx                 # 主应用入口
```

## 核心功能

### 1. Vite 构建配置

```typescript
// vite.config.ts
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
  // 性能优化
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom', 'antd'],
    exclude: ['wujie'],
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-react': ['react', 'react-dom', 'react-router-dom'],
          'vendor-antd': ['antd', '@ant-design/icons'],
        },
      },
    },
    chunkSizeWarningLimit: 1500,
  },
  server: {
    port: 3000,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
});
```

### 2. Zustand Store 模板

```typescript
// store/userStore.ts
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface UserState {
  userInfo: Record<string, unknown> | null;
  token: string | null;
  setUserInfo: (info: Record<string, unknown> | null) => void;
  setToken: (token: string | null) => void;
  logout: () => void;
}

export const useUserStore = create<UserState>()(
  devtools(
    persist(
      (set) => ({
        userInfo: null,
        token: null,
        setUserInfo: (info) => set({ userInfo: info }),
        setToken: (token) => set({ token: token }),
        logout: () => set({ userInfo: null, token: null }),
      }),
      {
        name: 'user-storage',
        partialize: (state) => ({
          token: state.token,
          userInfo: state.userInfo,
        }),
      }
    ),
    { name: 'userStore' }
  )
);
```

**Store 拆分规范**:

```typescript
// store/storeIndex.ts
export { useUserStore } from './userStore';
export { useAppStore } from './appStore';
// 按模块拆分 store，避免集中在一个大 store
```

### 3. wujie 主应用配置

```typescript
// main.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { prefetchApp, setupApp, destroyApp } from 'wujie';

// 预加载子应用（可选，提升体验）
const apps = [
  { name: 'sub-react', url: '//localhost:8080', exec: true },
  { name: 'sub-vue', url: '//localhost:8081', exec: false },
];

apps.forEach(({ name, url, exec }) => {
  prefetchApp({ name, url, exec });
});

// 初始化 wujie
setupApp({
  id: 'wujie-root',
  errorCapture: (error, info) => {
    console.error('子应用错误:', error, info);
  },
});

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

### 4. wujie 容器组件

```typescript
// components/WujieContainer.tsx
import React, { useRef, useEffect } from 'react';
import { bus } from 'wujie';

interface WujieContainerProps {
  name: string;
  url: string;
  sync?: boolean;
  props?: Record<string, unknown>;
}

export const WujieContainer: React.FC<WujieContainerProps> = ({
  name,
  url,
  sync = true,
  props = {},
}) => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // 主子应用通信示例
    bus.$on('main-to-sub', (data: unknown) => {
      console.log('收到子应用消息:', data);
    });

    return () => {
      bus.$off('main-to-sub');
    };
  }, []);

  return (
    <div ref={containerRef} style={{ width: '100%', height: '100%' }}>
      <div id={`wujie-${name}`} />
    </div>
  );
};
```

### 5. 主子应用通信

**主应用发送消息到子应用**:

```typescript
import { bus } from 'wujie';

// 发送到所有子应用
bus.$emit('sub-to-main', data);

// 发送到指定子应用
bus.$emit('sub-to-main', data, 'sub-react');
```

**主应用接收子应用消息**:

```typescript
import { bus } from 'wujie';

bus.$on('main-to-sub', (data: unknown) => {
  console.log('收到子应用消息:', data);
});

// 只监听一次
bus.$once('main-to-sub', (data: unknown) => {
  console.log('一次性消息:', data);
});
```

**子应用接收主应用消息**:

```typescript
import { bus } from 'wujie';

bus.$on('main-to-sub', (data: unknown) => {
  console.log('收到主应用消息:', data);
});

// 子应用发送消息到主应用
bus.$emit('sub-to-main', { type: 'login-success', data: userInfo });
```

### 6. 子应用配置

**子应用 main.ts**:

```typescript
// 子应用 main.ts
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { bus } from 'wujie';

// wujie 生命周期钩子
export async function mount(props: { container?: HTMLElement }) {
  // 接收主应用传递的数据
  if (props.container) {
    ReactDOM.createRoot(props.container).render(
      <React.StrictMode>
        <App />
      </React.StrictMode>
    );
  }
}

export async function unmount() {
  // 清理工作
}

export async function patchUrlQuery(url: string) {
  return url;
}

// 监听主应用消息
bus.$on('main-to-sub', (data: unknown) => {
  console.log('子应用收到主应用消息:', data);
});
```

**子应用 vite.config.ts**:

```typescript
// 子应用 vite.config.ts
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [
    // 根据框架选择插件
    react(), // 或 vue()
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 8080,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
  build: {
    // 子应用必须使用 umd 格式
    lib: {
      entry: resolve(__dirname, 'src/main.ts'),
      name: 'sub-react',
      formats: ['umd'],
      fileName: () => 'index.js',
    },
    rollupOptions: {
      external: ['react', 'react-dom', 'react-router-dom'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
          'react-router-dom': 'ReactRouterDOM',
        },
      },
    },
  },
});
```

### 7. Shadow DOM 样式隔离

```typescript
// components/StyleProvider.tsx
import React, { createContext, useContext, useMemo } from 'react';

interface StyleContextValue {
  mode: 'shadow' | 'plugin';
}

const StyleContext = createContext<StyleContextValue>({ mode: 'shadow' });

export const useStyleMode = () => useContext(StyleContext);

interface StyleProviderProps {
  children: React.ReactNode;
  mode?: 'shadow' | 'plugin';
}

export const StyleProvider: React.FC<StyleProviderProps> = ({
  children,
  mode = 'shadow',
}) => {
  const value = useMemo(() => ({ mode }), [mode]);

  return (
    <StyleContext.Provider value={value}>
      {children}
    </StyleContext.Provider>
  );
};
```

**Shadow DOM 样式隔离配置**:

```typescript
// 在 wujie 配置中启用 Shadow DOM
setupApp({
  id: 'wujie-root',
  shadow: true, // 启用 Shadow DOM 样式隔离
});
```

### 8. axios 请求封装

```typescript
// api/request.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { message } from 'antd';

interface RequestOptions extends AxiosRequestConfig {
  skipErrorHandler?: boolean;
}

class Request {
  private instance: AxiosInstance;

  constructor() {
    this.instance = axios.create({
      baseURL: import.meta.env.VITE_API_BASE_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // 请求拦截器
    this.instance.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // 响应拦截器
    this.instance.interceptors.response.use(
      (response: AxiosResponse) => response.data,
      (error) => {
        const { response } = error;
        if (response?.status === 401) {
          message.error('登录已过期，请重新登录');
          localStorage.clear();
          window.location.href = '/login';
        } else if (response?.status === 403) {
          message.error('没有权限访问');
        } else if (response?.status >= 500) {
          message.error('服务器错误');
        }
        return Promise.reject(error);
      }
    );
  }

  public get<T = unknown>(url: string, config?: RequestOptions): Promise<T> {
    return this.instance.get(url, config);
  }

  public post<T = unknown>(url: string, data?: unknown, config?: RequestOptions): Promise<T> {
    return this.instance.post(url, data, config);
  }

  public put<T = unknown>(url: string, data?: unknown, config?: RequestOptions): Promise<T> {
    return this.instance.put(url, data, config);
  }

  public delete<T = unknown>(url: string, config?: RequestOptions): Promise<T> {
    return this.instance.delete(url, config);
  }
}

export const request = new Request();
```

## React 18 最佳实践

### 1. 使用 Concurrent Features

```typescript
import { useTransition, useDeferredValue } from 'react';

// useTransition 用于非紧急更新
function SearchComponent() {
  const [isPending, startTransition] = useTransition();
  const [query, setQuery] = useState('');
  const [deferredQuery] = useDeferredValue(query);

  const handleSearch = (value: string) => {
    startTransition(() => {
      setQuery(value);
    });
  };

  return (
    <div>
      <input onChange={(e) => handleSearch(e.target.value)} />
      {isPending && <Spin />}
      <SearchResults query={deferredQuery} />
    </div>
  );
}
```

### 2. 正确使用 useEffect 清理函数

```typescript
useEffect(() => {
  const subscription = subscribe();

  return () => {
    subscription.unsubscribe();
  };
}, []);
```

### 3. React 18 + TypeScript 类型定义

```typescript
import React, { FC, useState, useCallback } from 'react';

interface Props {
  title: string;
  onAction: (value: string) => void;
}

export const MyComponent: FC<Props> = ({ title, onAction }) => {
  const [value, setValue] = useState<string>('');

  const handleClick = useCallback(() => {
    onAction(value);
  }, [value, onAction]);

  return (
    <div>
      <h1>{title}</h1>
      <input value={value} onChange={(e) => setValue(e.target.value)} />
      <button onClick={handleClick}>提交</button>
    </div>
  );
};
```

## 微前端路由同步

```typescript
// 路由同步配置
import { useLocation, useNavigate } from 'react-router-dom';
import { bus } from 'wujie';

function useRouteSync() {
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    // 监听子应用路由变化
    bus.$on('route-change', (path: string) => {
      navigate(path);
    });

    return () => {
      bus.$off('route-change');
    };
  }, [navigate]);

  const syncRoute = (path: string) => {
    bus.$emit('route-change', path);
  };

  return { syncRoute };
}
```

## 常见问题

### 1. 子应用样式污染

**解决方案**: 启用 Shadow DOM 样式隔离

```typescript
setupApp({
  id: 'wujie-root',
  shadow: true,
});
```

### 2. 主子应用通信失败

**检查项**:
- 确认 bus 事件名称一致
- 确认子应用已正确挂载
- 检查事件监听是否在组件内部正确注册

### 3. 子应用热更新失效

**解决方案**: 配置正确的 inlineDynamicImport

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        inlineDynamicImport: false,
      },
    },
  },
});
```

### 4. 跨域问题

**解决方案**: 配置 CORS headers

```typescript
// 主应用 vite.config.ts
server: {
  headers: {
    'Access-Control-Allow-Origin': '*',
  },
},
```

## 相关文档

- [wujie 官方文档](https://wujie-micro.github.io/doc/)
- [wujie-patterns](./references/wujie-patterns.md)
