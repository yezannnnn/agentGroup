# UmiJS/Max 4 路由、权限与插件配置

> ⚠️ 本文档为骨架，请根据你们团队实际情况填写。

---

## 项目初始化配置

> ⚠️ **待填写**：填写你们 `.umirc.ts` 或 `config/config.ts` 中实际开启的插件和配置项

```typescript
// config/config.ts 骨架
import { defineConfig } from '@umijs/max';

export default defineConfig({
  // === 基础配置 ===
  antd: {},              // Ant Design 插件
  access: {},            // 权限插件
  model: {},             // 数据模型（model 目录下的 .ts 文件）
  initialState: {},      // 全局初始状态

  // === 请求配置 ===
  request: {
    // TODO: 填写你们的 errorConfig 和 requestInterceptors
  },

  // === 路由配置 ===
  routes: [
    // TODO: 引入路由配置文件
  ],

  // === 代理配置 ===
  proxy: {
    '/api': {
      target: 'http://localhost:8080',  // TODO: 填写实际后端地址
      changeOrigin: true,
    },
  },

  // === 微前端（按需开启）===
  // qiankun: { master: {} },

  // === 其他 ===
  npmClient: 'pnpm',  // TODO: 填写你们用的包管理器
});
```

---

## 路由配置规范

> ⚠️ **待填写**：填写你们路由的实际组织方式和层级结构

### 路由字段说明

```typescript
// 路由配置字段含义
interface RouteConfig {
  path: string;           // 路由路径
  component: string;      // 页面组件路径（相对 src/pages）
  name: string;           // 菜单显示名称（也用于 i18n key）
  icon?: string;          // 菜单图标（antd icon 名称）
  access?: string;        // 权限标识（对应 access.ts 中的 key）
  hideInMenu?: boolean;   // 是否隐藏在菜单（详情页等）
  hideInBreadcrumb?: boolean;
  routes?: RouteConfig[]; // 子路由
}
```

### 典型路由结构

```typescript
// config/routes.ts 骨架（按你们实际业务填写）
export const routes = [
  { path: '/login', component: './Login', layout: false },  // 不用布局

  {
    path: '/',
    component: '@/layouts/BasicLayout',  // TODO: 填写你们的布局文件路径
    routes: [
      { path: '/', redirect: '/dashboard' },
      {
        path: '/dashboard',
        component: './Dashboard',
        name: '首页',
        icon: 'DashboardOutlined',
      },

      // TODO: 按你们实际业务填写完整路由结构
      {
        path: '/your-module',
        name: '你的模块',
        icon: 'AppstoreOutlined',
        // access: 'canViewYourModule',  // TODO: 填写权限标识
        routes: [
          {
            path: '/your-module/list',
            component: './YourModule/List',
            name: '列表',
          },
          {
            path: '/your-module/detail/:id',
            component: './YourModule/Detail',
            name: '详情',
            hideInMenu: true,  // 详情页不显示在菜单
          },
        ],
      },
    ],
  },
];
```

---

## 权限控制

### access.ts 配置

```typescript
// src/access.ts
export default (initialState: { currentUser?: API.CurrentUser }) => {
  const { currentUser } = initialState || {};

  // TODO: 填写你们的权限判断逻辑
  // 方式一：基于角色
  const isAdmin = currentUser?.roles?.includes('ROLE_ADMIN');

  // 方式二：基于权限码
  const hasPermission = (code: string) =>
    currentUser?.permissions?.includes(code) ?? false;

  return {
    // 管理员
    isAdmin,

    // 模块权限（按你们实际权限码填写）
    canViewDashboard: hasPermission('dashboard:view'),
    // TODO: 填写你们所有权限标识
  };
};
```

### 页面级权限控制

```typescript
// 路由配置中限制
{ path: '/admin', access: 'isAdmin', component: './Admin' }

// 组件内使用（精细控制按钮/操作）
import { useAccess } from '@umijs/max';

const MyPage = () => {
  const access = useAccess();

  return (
    <div>
      <Button>查看（所有人可见）</Button>
      {access.canEditModule && (
        <Button type="primary">编辑（有权限才显示）</Button>
      )}
    </div>
  );
};
```

---

## 全局初始状态（initialState）

```typescript
// src/app.ts
export async function getInitialState(): Promise<{
  currentUser?: API.CurrentUser;
  // TODO: 填写其他全局数据
}> {
  try {
    const currentUser = await fetchCurrentUser(); // TODO: 填写接口
    return { currentUser };
  } catch {
    // 未登录，跳转登录页
    history.push('/login');
    return {};
  }
}
```

---

## 运行时请求配置（@umijs/max request 插件）

> ⚠️ **待填写**：如果你们用 umi 内置 request 插件（而不是自己封装 axios），填写这里

```typescript
// src/app.ts
import type { RequestConfig } from '@umijs/max';

export const request: RequestConfig = {
  baseURL: '/api',
  timeout: 10000,

  // 错误配置
  errorConfig: {
    errorHandler(error) {
      // TODO: 填写统一错误处理逻辑
    },
    errorThrower(res) {
      const { code, message } = res as any;
      if (code !== 200) {
        throw { name: 'BusinessError', info: { code, message } };
      }
    },
  },

  // 请求拦截器（注入 token）
  requestInterceptors: [
    (config: RequestOptions) => {
      const token = localStorage.getItem('token'); // TODO: 填写 token 存储位置
      if (token) {
        config.headers = { ...config.headers, Authorization: `Bearer ${token}` };
      }
      return config;
    },
  ],
};
```

---

## 常见 UmiJS 坑

> ⚠️ **待填写**：填写你们实际踩过的坑

### 坑 1：（待填写）
**现象**：  
**解决**：

### 坑 2：动态菜单与路由权限联动
> ⚠️ **待填写**：如果你们后端返回动态菜单，填写前端如何处理

---

## TODO 待补充内容

- [ ] 完整的路由结构（你们实际的业务菜单）
- [ ] 完整的权限码列表
- [ ] 国际化配置（如果有）
- [ ] 动态菜单实现方案（如果有）
- [ ] 页面缓存（keepAlive）配置（如果有）
- [ ] 实际踩坑记录
