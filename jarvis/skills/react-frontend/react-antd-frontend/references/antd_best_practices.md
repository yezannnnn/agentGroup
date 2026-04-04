# Ant Design 5 + Pro Components 使用规范

> ⚠️ 本文档为骨架，请根据你们团队实际情况填写。

---

## Ant Design 5 主题配置

> ⚠️ **待填写**：填写你们设计稿的主色、圆角、字体大小等 Design Token

```tsx
// src/app.ts 或根 Layout 中配置
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';

// 主题配置骨架
const themeConfig = {
  token: {
    // 主色
    colorPrimary: '#1677ff',        // TODO: 填写你们的主色（从设计稿取）
    colorSuccess: '#52c41a',
    colorWarning: '#faad14',
    colorError: '#ff4d4f',

    // 圆角
    borderRadius: 6,                // TODO: 填写全局圆角

    // 字体
    fontSize: 14,                   // TODO: 填写基础字号

    // 其他 token（待填写）
  },

  components: {
    // 组件级别覆盖（仅在通用 token 不够用时填写）
    // Table: { headerBg: '#fafafa' },
    // Button: { primaryShadow: 'none' },
  },
};

// 使用方式
<ConfigProvider theme={themeConfig} locale={zhCN}>
  <App />
</ConfigProvider>
```

---

## ProTable 使用规范

### 基础列类型速查

```tsx
import type { ProColumns } from '@ant-design/pro-components';

// 常用 valueType 速查
const columns: ProColumns<YourType>[] = [
  { title: '名称',   dataIndex: 'name',      valueType: 'text' },
  { title: '状态',   dataIndex: 'status',     valueType: 'select',    valueEnum: STATUS_ENUM },
  { title: '创建时间', dataIndex: 'createTime', valueType: 'dateTime',  search: false },
  { title: '日期范围',  dataIndex: 'dateRange',  valueType: 'dateRange', hideInTable: true },
  { title: '金额',   dataIndex: 'amount',     valueType: 'money' },
  { title: '描述',   dataIndex: 'desc',       valueType: 'textarea',  ellipsis: true },
];
```

### 枚举定义规范

```typescript
// 状态枚举（valueEnum 格式）
const STATUS_ENUM = {
  PENDING:  { text: '待处理', status: 'Processing' },
  APPROVED: { text: '已通过', status: 'Success' },
  REJECTED: { text: '已拒绝', status: 'Error' },
  // TODO: 填写你们实际的状态枚举
};
```

### 完整 ProTable 页面骨架

```tsx
import { useRef, useState } from 'react';
import { Button, Modal, message } from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import { ProTable } from '@ant-design/pro-components';
import type { ActionType, ProColumns } from '@ant-design/pro-components';

const YourListPage: React.FC = () => {
  const actionRef = useRef<ActionType>();
  const [formVisible, setFormVisible] = useState(false);
  const [editRecord, setEditRecord] = useState<YourType | undefined>();

  const columns: ProColumns<YourType>[] = [
    {
      title: '名称',
      dataIndex: 'name',
    },
    // TODO: 填写实际列
    {
      title: '操作',
      key: 'option',
      valueType: 'option',
      render: (_, record) => [
        <a key="edit" onClick={() => { setEditRecord(record); setFormVisible(true); }}>
          编辑
        </a>,
        <a
          key="delete"
          style={{ color: 'red' }}
          onClick={() => {
            Modal.confirm({
              title: '确认删除？',
              onOk: async () => {
                await deleteYourData(record.id);
                message.success('删除成功');
                actionRef.current?.reload();
              },
            });
          }}
        >
          删除
        </a>,
      ],
    },
  ];

  return (
    <>
      <ProTable<YourType>
        actionRef={actionRef}
        rowKey="id"
        columns={columns}
        request={async (params) => {
          const { current, pageSize, ...rest } = params;
          const res = await getYourList({ current, size: pageSize, ...rest });
          return { data: res.data.records, total: res.data.total, success: true };
        }}
        toolBarRender={() => [
          <Button
            key="create"
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => { setEditRecord(undefined); setFormVisible(true); }}
          >
            新增
          </Button>,
        ]}
      />

      {/* 新增/编辑弹窗 */}
      <YourFormModal
        open={formVisible}
        onOpenChange={setFormVisible}
        initialValues={editRecord}
        onSuccess={() => actionRef.current?.reload()}
      />
    </>
  );
};
```

---

## ProForm 使用规范

### 常用表单组件速查

```tsx
import {
  ProFormText,        // 文本输入
  ProFormTextArea,    // 多行文本
  ProFormSelect,      // 下拉选择
  ProFormDatePicker,  // 日期选择
  ProFormDateRangePicker, // 日期范围
  ProFormDigit,       // 数字输入
  ProFormRadio,       // 单选
  ProFormCheckbox,    // 多选
  ProFormSwitch,      // 开关
  ProFormUploadButton, // 文件上传
} from '@ant-design/pro-components';
```

### ModalForm 骨架（推荐用于新增/编辑）

```tsx
import { ModalForm, ProFormText, ProFormSelect } from '@ant-design/pro-components';
import { message } from 'antd';

interface YourFormProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initialValues?: Partial<YourType>;
  onSuccess: () => void;
}

const YourFormModal: React.FC<YourFormProps> = ({
  open, onOpenChange, initialValues, onSuccess
}) => {
  const isEdit = !!initialValues?.id;

  return (
    <ModalForm<YourType>
      title={isEdit ? '编辑' : '新增'}
      open={open}
      onOpenChange={onOpenChange}
      initialValues={initialValues}
      modalProps={{ destroyOnClose: true }}  // 关闭时销毁，防止旧数据残留
      onFinish={async (values) => {
        try {
          if (isEdit) {
            await updateYourData(initialValues!.id!, values);
          } else {
            await createYourData(values);
          }
          message.success('操作成功');
          onSuccess();
          return true; // 返回 true 关闭弹窗
        } catch {
          return false; // 返回 false 保持弹窗打开
        }
      }}
    >
      <ProFormText
        name="name"
        label="名称"
        rules={[{ required: true, message: '请输入名称' }]}
      />
      <ProFormSelect
        name="status"
        label="状态"
        valueEnum={STATUS_ENUM}
        rules={[{ required: true }]}
      />
      {/* TODO: 添加更多表单字段 */}
    </ModalForm>
  );
};
```

### DrawerForm 骨架（复杂表单推荐）

```tsx
// 复杂表单（字段多）用 DrawerForm
import { DrawerForm } from '@ant-design/pro-components';

<DrawerForm
  title="编辑详情"
  open={open}
  onOpenChange={onOpenChange}
  drawerProps={{ destroyOnClose: true, width: 600 }}
  onFinish={async (values) => { /* ... */ return true; }}
>
  {/* 表单内容 */}
</DrawerForm>
```

---

## 表单验证规范

> ⚠️ **待填写**：填写你们常用的自定义验证规则

```tsx
// 常用验证规则骨架
const rules = {
  required: { required: true, message: '此项为必填' },
  phone: { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号' },
  // TODO: 填写你们业务中需要的自定义校验规则
};
```

---

## 组件封装规范

> ⚠️ **待填写**：填写你们封装的公共业务组件规范（如：字典下拉选择器、用户选择器、部门选择器等）

```tsx
// 示例：通用字典下拉组件骨架
// src/components/DictSelect/index.tsx
interface DictSelectProps {
  dictCode: string;       // 字典编码
  onChange?: (value: string) => void;
  value?: string;
}

const DictSelect: React.FC<DictSelectProps> = ({ dictCode, ...rest }) => {
  // TODO: 实现从字典 store/接口获取选项
  const options = useDictOptions(dictCode);
  return <Select options={options} {...rest} />;
};
```

---

## 常见 Ant Design 5 坑

> ⚠️ **待填写**：填写你们遇到的实际问题

### 坑 1：Form 弹窗关闭后数据残留
**现象**：关闭弹窗再打开，旧数据还在  
**解决**：`<Modal destroyOnClose>` 或 `form.resetFields()`（ModalForm 用 `modalProps={{ destroyOnClose: true }}`）

### 坑 2：ProTable request 参数与后端不一致
**现象**：ProTable 传 `pageSize`，后端接收 `size`  
**解决**：在 request 函数中转换参数名

### 坑 3：（待填写）
**现象**：  
**解决**：

---

## TODO 待补充内容

- [ ] 你们的主题配置（实际 token 值）
- [ ] 常用业务组件列表（字典选择/用户选择等）
- [ ] 上传组件封装规范（OSS/MinIO）
- [ ] 富文本编辑器接入（如果有）
- [ ] 图表组件（ECharts/AntV）接入规范（如果有）
- [ ] 实际踩坑记录
