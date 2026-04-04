---
name: react-antd-frontend
description: 使用此 Skill 当用户问到「UmiJS 路由配置」「Ant Design 组件开发」「ProTable 表格」「ProForm 表单」「ProLayout 布局」「Zustand 状态管理」「qiankun 主子应用通信」「wujie 无界微前端接入」「Vite 构建配置/优化」「TypeScript 类型定义」「权限路由/菜单」「接口请求封装」「antd 主题定制」「动态表单」「复杂表格」「微前端样式隔离」「子应用注册」。适用于 React 18 + TypeScript 5 + UmiJS/Max 4 + Ant Design 5 + @ant-design/pro-components 2.8 + qiankun/wujie 微前端技术栈的前端开发。
---

# React Ant Design 前端工程师

基于 React 18 + UmiJS/Max 4 + Ant Design 5 的前端开发规范、组件使用、状态管理和微前端架构指南。

## 目录

- [技术栈版本](#技术栈版本)
- [项目结构规范](#项目结构规范)
- [UmiJS/Max 配置规范](#umijsmax-配置规范)
- [Ant Design 5 使用规范](#ant-design-5-使用规范)
- [Pro Components 使用规范](#pro-components-使用规范)
- [Zustand 状态管理规范](#zustand-状态管理规范)
- [微前端架构](#微前端架构)
- [接口请求封装](#接口请求封装)
- [TypeScript 规范](#typescript-规范)
- [常见场景工作流](#常见场景工作流)
- [参考文档](#参考文档)

---

## 技术栈版本

| 组件                          | 版本    | 备注              |
|-------------------------------|---------|-------------------|
| React                         | 18+     |                   |
| TypeScript                    | 5       |                   |
| UmiJS/Max                     | 4       | 路由/权限/布局    |
| Ant Design                    | 5       | UI 组件库         |
| @ant-design/pro-components    | 2.8     | ProTable/ProForm  |
| Zustand                       | latest  | 全局状态管理      |
| Vite                          | latest  | 构建工具          |
| qiankun                       | 2+      | 微前端框架        |
| wujie                         | latest  | 无界微前端        |

---

## 项目结构规范

> ⚠️ **待填写**：填写你们项目的实际目录结构。以下是常见结构骨架，请按实际情况修改。

```
src/
├── pages/              # 页面组件（对应路由）
│   └── YourModule/
│       ├── index.tsx   # 页面入口
│       ├── components/ # 页面私有组件
│       └── hooks/      # 页面私有 hooks
├── components/         # 全局共享组件
├── stores/             # Zustand store（全局状态）
├── services/           # 接口请求（API 调用）
├── hooks/              # 全局共享 hooks
├── utils/              # 工具函数
├── constants/          # 常量定义
├── types/              # TypeScript 类型定义
├── layouts/            # 布局组件
└── access.ts           # 权限定义（UmiJS）
```

---

## UmiJS/Max 配置规范

### 路由配置

> ⚠️ **待填写**：填写你们的路由组织方式（约定式/配置式）、路由守卫实现、权限路由配置。

```typescript
// .umirc.ts 或 config/routes.ts 骨架
export const routes: IRoute[] = [
  {
    path: '/',
    component: '@/layouts/BasicLayout',
    routes: [
      {
        path: '/dashboard',
        component: './Dashboard',
        name: '首页',
        icon: 'HomeOutlined',
        // TODO: 填写你们的权限标识方式（如 access: 'canViewDashboard'）
      },
      {
        path: '/your-module',
        name: '模块名',
        routes: [
          {
            path: '/your-module/list',
            component: './YourModule/List',
            name: '列表',
          },
        ],
      },
    ],
  },
];
```

### 权限配置（access.ts）

> ⚠️ **待填写**：填写你们的权限数据来源（接口/本地）和权限判断逻辑。

```typescript
// src/access.ts 骨架
export default (initialState: { currentUser?: API.CurrentUser }) => {
  const { currentUser } = initialState || {};

  return {
    // TODO: 填写你们实际的权限判断逻辑
    // 示例：基于角色/权限码
    canAdmin: currentUser?.roles?.includes('ADMIN'),
    canViewModule: currentUser?.permissions?.includes('module:view'),
    canEditModule: currentUser?.permissions?.includes('module:edit'),
  };
};
```

### 运行时配置（app.ts）

> ⚠️ **待填写**：填写你们的 getInitialState 内容（用户信息/权限/菜单），以及 request 配置。

```typescript
// src/app.ts 骨架

// 全局初始化数据
export async function getInitialState() {
  // TODO: 填写获取用户信息的接口调用
  const currentUser = await fetchCurrentUser();

  return {
    currentUser,
    // TODO: 填写其他需要全局共享的初始数据（权限列表/菜单/系统配置）
  };
}

// 布局配置
export const layout = ({ initialState }) => {
  return {
    // TODO: 填写你们的布局配置（logo/菜单/右上角用户信息）
    logo: '/logo.png',
    menu: {
      locale: false,
    },
  };
};
```

---

## Ant Design 5 使用规范

### 主题配置

> ⚠️ **待填写**：填写你们的主题色、圆角、字体等定制配置，以及 token 覆盖规则。

```typescript
// app.ts 或 Layout 中配置
import { ConfigProvider } from 'antd';

// 主题 token 骨架（填写你们的实际设计规范）
const theme = {
  token: {
    colorPrimary: '#1677ff',  // TODO: 填写你们的主色
    borderRadius: 6,           // TODO: 填写全局圆角
    // ...其他 token
  },
  components: {
    // TODO: 填写组件级别的覆盖
    // Table: { headerBg: '#xxx' },
  },
};
```

### 常用组件规范

> ⚠️ **待填写**：填写你们团队约定的 Modal、Form、Table 等组件的标准写法（尤其是 useModal 等 hooks 的封装）。

```tsx
// Modal 使用规范骨架（告知团队统一用哪种方式：useModal / useState 控制 / Modal.confirm）
// TODO: 填写你们团队约定的 Modal 写法

// Form 使用规范
// TODO: 填写是否统一用 ProForm，或何时用原生 Form
```

---

## Pro Components 使用规范

### ProTable 标准用法

> ⚠️ **待填写**：填写你们封装的 ProTable columns 规范、request 函数格式、工具栏配置、行选择配置。

```tsx
import { ProTable } from '@ant-design/pro-components';
import type { ProColumns } from '@ant-design/pro-components';

// columns 定义骨架
const columns: ProColumns<YourDataType>[] = [
  {
    title: '字段名',
    dataIndex: 'fieldName',
    key: 'fieldName',
    // TODO: 填写你们常用的 valueType（select/date/dateRange 等）
    // valueType: 'select',
    // valueEnum: YOUR_ENUM,
  },
  {
    title: '操作',
    key: 'action',
    valueType: 'option',
    render: (_, record) => [
      <a key="edit" onClick={() => handleEdit(record)}>编辑</a>,
      <a key="delete" onClick={() => handleDelete(record.id)}>删除</a>,
    ],
  },
];

// ProTable 使用骨架
const YourListPage: React.FC = () => {
  return (
    <ProTable<YourDataType>
      rowKey="id"
      columns={columns}
      request={async (params) => {
        // TODO: 填写 request 函数的实际参数结构和返回结构
        // 需与你们后端分页接口对应
        const res = await getYourList(params);
        return {
          data: res.data.records,
          total: res.data.total,
          success: true,
        };
      }}
      // TODO: 填写工具栏配置（新增按钮、导出按钮）
      toolBarRender={() => [
        <Button type="primary" onClick={handleCreate}>新增</Button>,
      ]}
    />
  );
};
```

### ProForm 标准用法

> ⚠️ **待填写**：填写你们 ProForm 的封装模式（DrawerForm / ModalForm / 独立页面 Form）、Submit 处理方式。

```tsx
import { ModalForm, ProFormText, ProFormSelect } from '@ant-design/pro-components';

// ModalForm 骨架（弹窗表单）
const YourFormModal: React.FC<{
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initialValues?: Partial<YourDataType>;
  onSuccess: () => void;
}> = ({ open, onOpenChange, initialValues, onSuccess }) => {
  const isEdit = !!initialValues?.id;

  return (
    <ModalForm
      title={isEdit ? '编辑' : '新增'}
      open={open}
      onOpenChange={onOpenChange}
      initialValues={initialValues}
      onFinish={async (values) => {
        // TODO: 填写提交逻辑（新增/编辑）
        await (isEdit ? updateYourData(initialValues!.id!, values) : createYourData(values));
        message.success('操作成功');
        onSuccess();
        return true; // 返回 true 关闭弹窗
      }}
    >
      <ProFormText
        name="name"
        label="名称"
        rules={[{ required: true }]}
      />
      {/* TODO: 填写其他表单字段 */}
    </ModalForm>
  );
};
```

---

## Zustand 状态管理规范

> ⚠️ **待填写**：填写你们哪些数据放全局 store（用户信息/字典/权限），哪些用组件内 state，以及 store 文件的命名规范。

```typescript
// src/stores/userStore.ts 骨架
import { create } from 'zustand';
import { persist, devtools } from 'zustand/middleware';

interface UserState {
  // State
  userInfo: API.UserInfo | null;
  permissions: string[];

  // Actions
  setUserInfo: (user: API.UserInfo) => void;
  clearUser: () => void;
  hasPermission: (permission: string) => boolean;
}

export const useUserStore = create<UserState>()(
  devtools(
    persist(
      (set, get) => ({
        userInfo: null,
        permissions: [],

        setUserInfo: (user) => set({ userInfo: user, permissions: user.permissions ?? [] }),
        clearUser: () => set({ userInfo: null, permissions: [] }),
        hasPermission: (permission) => get().permissions.includes(permission),
      }),
      {
        name: 'user-storage',  // localStorage key
        // TODO: 填写需要持久化的字段（partialize 过滤）
      }
    )
  )
);
```

**Store 拆分规范**：
```
src/stores/
├── userStore.ts        # 用户信息、权限
├── dictStore.ts        # 数据字典缓存
├── appStore.ts         # 全局 UI 状态（loading/主题）
└── ...                 # 按模块拆分，避免单个 store 过大
```

> ⚠️ **待填写**：何时用 Zustand，何时直接用 useState/useReducer？填写你们的约定。

---

## 微前端架构

### qiankun 主应用配置

> ⚠️ **待填写**：填写你们主应用的名称、子应用列表、激活规则、全局 store 共享方案。

```typescript
// src/app.ts 或 src/qiankun.ts 骨架（UmiJS qiankun 插件）

// 方式一：UmiJS @umijs/plugin-qiankun（配置式）
// config/config.ts
export default {
  qiankun: {
    master: {
      // TODO: 填写子应用注册信息
      apps: [
        {
          name: 'sub-app-1',         // TODO: 子应用标识
          entry: '//localhost:7001', // TODO: 子应用入口地址
          container: '#subapp-container',
          activeRule: '/sub-app-1',
        },
      ],
    },
  },
};

// 主应用传递给子应用的数据（props）
export const qiankun = {
  async bootstrap() {},
  async mount() {},
  async unmount() {},
};
```

**主子应用通信**：
```typescript
// 主应用推送数据给子应用（通过 props 或 initGlobalState）
import { initGlobalState } from 'qiankun';

const actions = initGlobalState({
  // TODO: 填写主子应用共享的数据（token/用户信息/主题）
  token: getToken(),
  userInfo: getUserInfo(),
});

// 监听变化
actions.onGlobalStateChange((state, prev) => {
  console.log('[主应用] 全局状态变更:', state);
});
```

### wujie（无界）子应用接入

> ⚠️ **待填写**：填写你们使用哪个微前端方案（qiankun 或 wujie），或两者共存的场景划分。

```tsx
// wujie 接入骨架（主应用加载子应用）
import WujieReact from 'wujie-react';

const SubAppContainer: React.FC<{ appName: string; url: string }> = ({ appName, url }) => {
  return (
    <WujieReact
      width="100%"
      height="100%"
      name={appName}
      url={url}
      sync={true}
      // TODO: 填写 props（传递给子应用的数据：token/共享 store 方法）
      props={{
        token: getToken(),
        onLogout: handleLogout,
      }}
      // TODO: 填写是否开启样式隔离 shadowDOM
    />
  );
};
```

**子应用（被 wujie 加载）需要的适配**：
```typescript
// 子应用 src/main.ts（Vite 项目）骨架
if (window.__POWERED_BY_WUJIE__) {
  // 在 wujie 环境中被挂载
  window.__WUJIE_MOUNT = () => {
    app.mount('#app');  // Vue 示例；React 参考对应写法
  };
  window.__WUJIE_UNMOUNT = () => {
    app.unmount();
  };
} else {
  // 独立运行
  app.mount('#app');
}
```

> ⚠️ **待填写**：填写你们子应用是否需要独立可运行，以及 Vite 配置中 base 路径的处理方式。

---

## 接口请求封装

> ⚠️ **待填写**：填写你们使用 umi-request 还是 axios，request 基础配置（baseURL/超时），以及统一的请求/响应拦截器（token 注入/错误处理/401 跳登录）。

```typescript
// src/utils/request.ts 骨架（以 axios 为例，umi-request 类似）
import axios from 'axios';

const request = axios.create({
  baseURL: process.env.API_BASE_URL,  // TODO: 填写实际 baseURL 配置方式
  timeout: 10000,                      // TODO: 填写超时时间
});

// 请求拦截器
request.interceptors.request.use((config) => {
  // TODO: 填写 token 注入方式（从 localStorage / Zustand store / umi initialState）
  const token = getToken();
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`;
  }
  return config;
});

// 响应拦截器
request.interceptors.response.use(
  (response) => {
    const { data } = response;
    // TODO: 填写你们的业务状态码判断（如 code !== 200 时抛错）
    if (data.code !== 200) {
      message.error(data.message || '请求失败');
      return Promise.reject(new Error(data.message));
    }
    return data;
  },
  (error) => {
    // TODO: 填写 HTTP 错误处理（401 跳登录页，403 无权限提示，500 系统错误）
    if (error.response?.status === 401) {
      // 跳转登录
    }
    return Promise.reject(error);
  }
);

export default request;
```

**Service 层写法规范**：
```typescript
// src/services/yourModule.ts 骨架
import request from '@/utils/request';
import type { YourDataType, YourQueryParams, PageResult } from '@/types';

export const getYourList = (params: YourQueryParams): Promise<{ data: PageResult<YourDataType> }> =>
  request.get('/api/v1/your-module', { params });

export const getYourById = (id: number): Promise<{ data: YourDataType }> =>
  request.get(`/api/v1/your-module/${id}`);

export const createYourData = (data: Partial<YourDataType>): Promise<{ data: null }> =>
  request.post('/api/v1/your-module', data);

export const updateYourData = (id: number, data: Partial<YourDataType>): Promise<{ data: null }> =>
  request.put(`/api/v1/your-module/${id}`, data);

export const deleteYourData = (id: number): Promise<{ data: null }> =>
  request.delete(`/api/v1/your-module/${id}`);
```

---

## TypeScript 规范

> ⚠️ **待填写**：填写你们的类型文件组织方式、API 类型是否自动生成（openapi-typescript）、通用工具类型的使用约定。

```typescript
// src/types/index.ts 骨架（全局类型定义）

// API 响应统一类型
export interface ApiResult<T = unknown> {
  code: number;
  message: string;
  data: T;
}

// 分页相关类型
export interface PageResult<T> {
  records: T[];
  total: number;
  current: number;
  size: number;
}

export interface PageParams {
  current?: number;
  pageSize?: number;  // ProTable 用 pageSize，后端可能叫 size，注意转换
}

// 常用工具类型
export type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
export type RequiredKeys<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;
```

---

## 常见场景工作流

### 新建标准 CRUD 页面

```
1. 在 src/types/ 定义数据类型（QueryParams / DataType / CreateDTO）
2. 在 src/services/ 添加接口函数
3. 在 src/pages/YourModule/ 创建 index.tsx
4. 使用 ProTable（列表）+ ModalForm/DrawerForm（新增/编辑）
5. 删除用 Modal.confirm 二次确认
6. 通知 ProTable 刷新用 actionRef.current?.reload()
7. 在路由配置中注册页面
8. 配置权限（access.ts + 路由 access 字段）
```

### 接入新子应用（微前端）

> ⚠️ **待填写**：填写你们接入新子应用的完整步骤（主应用注册 → 子应用适配 → 路由配置 → 联调）。

```
1. 确认使用 qiankun 还是 wujie（TODO: 填写你们的选型规则）
2. 主应用注册子应用（填写 entry/activeRule）
3. 子应用添加适配代码（src/main.ts）
4. 子应用 Vite/Webpack 添加跨域配置
5. 主子应用 token/用户信息共享配置
6. 样式隔离验证（前缀/Shadow DOM）
7. 路由跳转联调
```

### 状态管理选型规则

```
组件内局部状态         → useState / useReducer
跨组件共享（同页面）  → Context 或提升 state
全局数据（用户/权限） → Zustand store
服务端状态（列表数据）→ ProTable request / swr / react-query
```

---

## 参考文档

| 文件 | 内容 | 使用时机 |
|------|------|---------|
| `references/umijs_patterns.md` | UmiJS/Max 4 路由、布局、权限、插件配置 | 路由/权限开发 |
| `references/antd_best_practices.md` | Ant Design 5 主题/组件/Pro Components 使用规范 | 组件开发 |
| `references/micro_frontend_guide.md` | qiankun + wujie 微前端架构、通信、样式隔离 | 微前端接入 |
