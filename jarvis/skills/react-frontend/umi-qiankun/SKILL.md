# umi-qiankun 微前端技能

## 技能概述

- **name**: umi-qiankun
- **description**: 包含 UmiJS 路由配置、UmiJS 权限路由、UmiJS 布局配置、qiankun 主子应用配置、qiankun 主子应用通信、qiankun 子应用接入、qiankun 样式隔离、子应用注册、微前端路由同步
- **技术栈**: React 18+, TypeScript 5, UmiJS/Max 4, Ant Design 5, @ant-design/pro-components 2.8, qiankun 2+
- **适用场景**: 微前端架构项目、主应用基于 UmiJS/Max 的多子应用集成场景

## 目录结构

```
umi-qiankun/
├── SKILL.md                              # 技能说明文档
└── references/
    └── umiqiankun-patterns.md            # qiankun 详细配置参考
```

## 技能详解

### 1. UmiJS 路由配置

UmiJS 的路由配置遵循约定式路由规则，支持配置式路由。

```typescript
// config/routes.ts 或 config/config.ts 中
export default [
  {
    path: '/',
    component: '@/layouts/index',
    routes: [
      { path: '/', redirect: '/dashboard' },
      { path: '/dashboard', component: '@/pages/dashboard' },
      { path: '/user', component: '@/pages/user' },
    ],
  },
];
```

### 2. UmiJS 权限路由

通过 `access.ts` 实现基于权限的路由控制。

```typescript
// src/access.ts
export default (initialState: { currentUser?: API.CurrentUser }) => {
  const { currentUser } = initialState || {};
  return {
    canAdmin: currentUser?.userType === 'admin',
    canEdit: currentUser?.roles?.includes('editor'),
    canView: !!currentUser,
  };
};
```

### 3. UmiJS 布局配置

通过 `app.tsx` 或布局组件配置应用布局。

```typescript
// src/app.tsx
export const layout: RunTimeLayoutConfig = ({ initialState }) => {
  return {
    title: '微前端主应用',
    logo: '/logo.svg',
    menu: {
      locale: false,
    },
    rightContentRender: () => <RightContent />,
  };
};
```

### 4. qiankun 主子应用配置

#### 主应用配置

```typescript
// config/config.ts
export default {
  qiankun: {
    master: {
      apps: [
        {
          name: 'sub-app-1',
          entry: process.env.NODE_ENV === 'development'
            ? '//localhost:7001'
            : '//your-domain.com/sub-app-1',
          container: '#sub-app-container',
          activeRule: '/sub-app-1',
          props: {
            token: localStorage.getItem('token'),
            userInfo: initialState?.currentUser,
          },
        },
        {
          name: 'sub-app-2',
          entry: process.env.NODE_ENV === 'development'
            ? '//localhost:7002'
            : '//your-domain.com/sub-app-2',
          container: '#sub-app-container',
          activeRule: '/sub-app-2',
        },
      ],
    },
  },
};
```

#### 子应用配置（Vite + qiankun）

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import qiankun from 'vite-plugin-qiankun';

export default defineConfig({
  plugins: [
    qiankun('sub-app-1', {
      useDevMode: true,
    }),
  ],
  server: {
    port: 7001,
    cors: true,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
});
```

### 5. qiankun 主子应用通信

#### 主应用初始化全局状态

```typescript
// src/models/globalState.ts
import { initGlobalState, MicroAppStateActions } from 'qiankun';

let actions: MicroAppStateActions;

export function setupGlobalState() {
  const initialState = {
    token: localStorage.getItem('token'),
    userInfo: null,
    theme: 'light',
  };

  actions = initGlobalState(initialState);

  // 监听全局状态变化
  actions.onGlobalStateChange((state, prev) => {
    console.log('[主应用] 全局状态变化:', state, '前一个状态:', prev);
  }, true);

  return actions;
}

export function updateGlobalState(key: string, value: any) {
  actions?.setGlobalState({ [key]: value });
}

export function getGlobalState() {
  return actions?.getGlobalState();
}
```

#### 子应用接收全局状态

```typescript
// src/main.ts
import { renderWithQiankun, qiankunWindow } from 'vite-plugin-qiankun/dist/helper';

let app: any;

function render(props: any = {}) {
  const { container } = props;
  app = ReactDOM.createRoot(container?.querySelector('#root') || document.getElementById('root'));

  app.render(<App {...props} />);
}

renderWithQiankun({
  mount(props) {
    // 监听全局状态
    props.onGlobalStateChange((state: any) => {
      console.log('[子应用] 收到全局状态:', state);
      // 处理状态更新，如刷新用户信息
    }, true);

    // 获取初始全局状态
    const initialState = props.getGlobalState?.();
    console.log('[子应用] 初始全局状态:', initialState);

    render(props);
  },
  bootstrap() {
    console.log('[子应用] bootstrap');
  },
  unmount() {
    console.log('[子应用] unmount');
    app?.unmount();
  },
});

// 独立运行时渲染
if (!qiankunWindow.__POWERED_BY_QIANKUN__) {
  render({});
}
```

### 6. 子应用 vite.config.ts 完整配置

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import qiankun from 'vite-plugin-qiankun';
import { resolve } from 'path';

export default defineConfig({
  plugins: [
    qiankun('sub-app-1', {
      useDevMode: true,
    }),
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 7001,
    cors: true,
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
  build: {
    outDir: 'dist',
    rollupOptions: {
      output: {
        // 子应用资源命名
        entryFileNames: 'js/[name]-[hash].js',
        chunkFileNames: 'js/[name]-[hash].js',
        assetFileNames: (assetInfo) => {
          const { name } = assetInfo;
          if (/\.(woff2?|eot|ttf|otf)$/i.test(name)) {
            return 'fonts/[name]-[hash][extname]';
          }
          return 'assets/[name]-[hash][extname]';
        },
      },
    },
  },
});
```

### 7. 样式隔离方案

#### 方案一：Strict 模式（Shadow DOM）

```typescript
// 主应用配置
sandbox: {
  strictStyleIsolation: true,
}
```

优点：强隔离，样式不会泄露
缺点：部分组件（如 Antd Modal/Tooltip）可能不兼容

#### 方案二：Scoped CSS（推荐）

```typescript
// 主应用配置
sandbox: {
  experimentalStyleIsolation: true,
}
```

优点：兼容性好，不影响组件功能
缺点：运行时处理略有开销

#### 方案三：手动 CSS 前缀

在子应用构建时给所有样式添加统一前缀：

```css
/* 子应用样式 */
.sub-app-1 .ant-button {
  /* 样式规则 */
}
```

### 8. 微前端路由同步

qiankun 自动处理主子应用间的路由同步：

- 子应用路由变化通过 `history.listen` 同步
- 主应用通过 `activeRule` 激活对应子应用
- 子应用内部路由无需特殊处理

```typescript
// 子应用内部路由使用 React Router
import { useNavigate, useLocation } from 'react-router-dom';

function App() {
  const navigate = useNavigate();
  const location = useLocation();

  // 路由变化会自动同步到主应用
  return (
    <div>
      <button onClick={() => navigate('/detail/1')}>跳转详情</button>
    </div>
  );
}
```

## 相关参考

- [qiankun 官方文档](https://qiankun.umijs.org/)
- [vite-plugin-qiankun](https://github.com/tengmaoqing/vite-plugin-qiankun)
- [UmiJS 微前端配置](https://umijs.org/docs/max/micro-frontends)
