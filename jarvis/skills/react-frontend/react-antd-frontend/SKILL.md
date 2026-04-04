---
name: react-antd-frontend
description: >
  使用此 Skill 当用户问到「Ant Design 5 主题定制」「Ant Design 组件使用」
  「ProTable 表格」「ProForm 表单」「ProLayout 布局」「动态表单」「复杂表格」
  「TypeScript 类型定义」「接口请求封装」「权限路由/菜单」「状态管理选型」。
  适用于 React 18 + TypeScript 5 + Ant Design 5 + @ant-design/pro-components 2.8 技术栈。
---

# React Ant Design 前端工程师

基于 React 18 + Ant Design 5 的前端开发规范、组件使用和 Pro Components 使用指南。

## 目录

- [技术栈版本](#技术栈版本)
- [项目结构规范](#项目结构规范)
- [Ant Design 5 使用规范](#ant-design-5-使用规范)
- [Pro Components 使用规范](#pro-components-使用规范)
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
| Ant Design                    | 5       | UI 组件库         |
| @ant-design/pro-components    | 2.8     | ProTable/ProForm  |

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
| `references/antd_best_practices.md` | Ant Design 5 主题/组件/Pro Components 使用规范 | 组件开发 |
