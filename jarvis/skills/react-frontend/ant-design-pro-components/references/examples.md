# Ant Design Pro Components -- Usage Examples

> All examples use `@ant-design/pro-components` unified import.

## Table of Contents

- [ProTable with request](#protable-with-request)
- [ProTable with columns + valueType + valueEnum](#protable-columns)
- [ProTable with search form transform](#protable-search-transform)
- [ProTable with toolbar and batch operations](#protable-toolbar-batch)
- [ProTable with actionRef](#protable-actionref)
- [ProForm basic submission](#proform-basic)
- [ProForm with grid layout](#proform-grid)
- [ProForm with formRef and transform](#proform-formref)
- [ProForm with dependency](#proform-dependency)
- [ProFormSelect with request](#proformselect-request)
- [ModalForm / DrawerForm](#modalform-drawerform)
- [EditableProTable](#editableprotable)
- [Shared columns for Table + Form + Descriptions](#shared-columns)

---

## ProTable with request

```tsx
import { ProTable } from '@ant-design/pro-components';
import type { ProColumns } from '@ant-design/pro-components';

type DataItem = {
  id: number;
  name: string;
  status: string;
  createdAt: string;
};

const columns: ProColumns<DataItem>[] = [
  { title: 'ID', dataIndex: 'id', valueType: 'indexBorder', width: 48 },
  { title: 'Name', dataIndex: 'name', valueType: 'text' },
  {
    title: 'Status',
    dataIndex: 'status',
    valueType: 'select',
    valueEnum: {
      draft: { text: 'Draft', status: 'Default' },
      published: { text: 'Published', status: 'Success' },
      archived: { text: 'Archived', status: 'Warning' },
    },
  },
  { title: 'Created', dataIndex: 'createdAt', valueType: 'dateTime', hideInSearch: true },
  {
    title: 'Actions',
    valueType: 'option',
    render: (_, record, __, action) => [
      <a key="edit" onClick={() => console.log('edit', record)}>Edit</a>,
      <a key="delete" onClick={() => console.log('delete', record)}>Delete</a>,
    ],
  },
];

const MyTable = () => (
  <ProTable<DataItem>
    columns={columns}
    rowKey="id"
    request={async (params, sort, filter) => {
      const { current, pageSize, ...searchParams } = params;
      const response = await fetch(`/api/items?page=${current}&size=${pageSize}`);
      const data = await response.json();
      return {
        data: data.items,
        success: true,
        total: data.total,
      };
    }}
    search={{ labelWidth: 'auto' }}
    toolBarRender={() => [
      <Button key="add" type="primary">New Item</Button>,
    ]}
    pagination={{ defaultPageSize: 10 }}
  />
);
```

---

## ProTable columns

```tsx
const columns: ProColumns<DataItem>[] = [
  // Auto row index
  { title: '#', valueType: 'indexBorder', width: 48 },

  // Text with tooltip and ellipsis
  {
    title: 'Title',
    dataIndex: 'title',
    tooltip: 'The item title',
    ellipsis: true,
    copyable: true,
    formItemProps: { rules: [{ required: true, message: 'Required' }] },
  },

  // Money
  { title: 'Price', dataIndex: 'price', valueType: 'money', width: 120 },

  // Date range in search form, date in table
  {
    title: 'Created',
    dataIndex: 'createdAt',
    valueType: 'date',
    hideInSearch: true,
  },
  {
    title: 'Created',
    dataIndex: 'createdAt',
    valueType: 'dateRange',
    hideInTable: true,
    search: {
      transform: (value) => ({
        startDate: value[0],
        endDate: value[1],
      }),
    },
  },

  // Select with valueEnum
  {
    title: 'Status',
    dataIndex: 'status',
    valueEnum: {
      0: { text: 'Inactive', status: 'Default' },
      1: { text: 'Active', status: 'Success' },
      2: { text: 'Error', status: 'Error' },
    },
    // auto generates: Select in search, tag in table
  },

  // Custom render + search form input
  {
    title: 'Progress',
    dataIndex: 'progress',
    valueType: 'progress',
    hideInSearch: true,
  },

  // Actions column (never in search)
  {
    title: 'Actions',
    valueType: 'option',
    width: 200,
    render: (text, record, _, action) => [
      <a key="view">View</a>,
      <a key="edit">Edit</a>,
      <TableDropdown
        key="more"
        menus={[
          { key: 'copy', name: 'Copy' },
          { key: 'delete', name: 'Delete' },
        ]}
      />,
    ],
  },
];
```

---

## ProTable search transform

```tsx
// Transform date range into two separate params for backend
{
  title: 'Date Range',
  dataIndex: 'dateRange',
  valueType: 'dateRange',
  hideInTable: true,
  search: {
    transform: (value) => ({
      startDate: value[0],
      endDate: value[1],
    }),
  },
}

// Use beforeSearchSubmit for global transform
<ProTable
  beforeSearchSubmit={(params) => ({
    ...params,
    startDate: params.dateRange?.[0],
    endDate: params.dateRange?.[1],
    dateRange: undefined,
  })}
/>
```

---

## ProTable toolbar and batch operations

```tsx
<ProTable
  rowSelection={{}}
  tableAlertRender={({ selectedRowKeys, onCleanSelected }) => (
    <span>
      Selected {selectedRowKeys.length} items
      <a style={{ marginInlineStart: 8 }} onClick={onCleanSelected}>Clear</a>
    </span>
  )}
  tableAlertOptionRender={({ selectedRowKeys }) => (
    <Space>
      <Button onClick={() => batchApprove(selectedRowKeys)}>Batch Approve</Button>
      <Button danger onClick={() => batchDelete(selectedRowKeys)}>Batch Delete</Button>
    </Space>
  )}
  toolBarRender={() => [
    <Button key="export" onClick={handleExport}>Export</Button>,
    <Button key="add" type="primary" onClick={handleAdd}>Add</Button>,
  ]}
/>
```

---

## ProTable actionRef

```tsx
import { useRef } from 'react';
import type { ActionType } from '@ant-design/pro-components';

const MyTable = () => {
  const actionRef = useRef<ActionType>();

  return (
    <>
      <Button onClick={() => actionRef.current?.reload()}>Refresh</Button>
      <Button onClick={() => actionRef.current?.reloadAndRest()}>Refresh & Reset</Button>
      <Button onClick={() => actionRef.current?.reset()}>Reset All</Button>

      <ProTable
        actionRef={actionRef}
        columns={columns}
        request={fetchData}
      />
    </>
  );
};
```

---

## ProForm basic

```tsx
import { ProForm, ProFormText, ProFormSelect, ProFormDatePicker } from '@ant-design/pro-components';

<ProForm
  onFinish={async (values) => {
    console.log('Submitted:', values);
    await saveData(values);
    message.success('Saved');
  }}
  initialValues={{ name: 'Default Name' }}
>
  <ProFormText
    name="name"
    label="Name"
    tooltip="Customer name"
    placeholder="Enter name"
    rules={[{ required: true, message: 'Name is required' }]}
  />
  <ProFormText name="company" label="Company" placeholder="Enter company" />
  <ProFormSelect
    name="type"
    label="Type"
    valueEnum={{ a: 'Type A', b: 'Type B', c: 'Type C' }}
  />
  <ProFormDatePicker name="date" label="Date" />
</ProForm>
```

---

## ProForm grid layout

```tsx
<ProForm grid rowProps={{ gutter: [16, 0] }}>
  <ProFormText colProps={{ xl: 8, md: 12 }} name="name" label="Name" />
  <ProFormText colProps={{ xl: 8, md: 12 }} name="phone" label="Phone" />
  <ProFormDigit colProps={{ xl: 8, md: 12 }} name="age" label="Age" />
  <ProFormTextArea colProps={{ span: 24 }} name="description" label="Description" />
</ProForm>
```

---

## ProForm formRef and transform

```tsx
import { useRef } from 'react';
import type { ProFormInstance } from '@ant-design/pro-components';

const MyForm = () => {
  const formRef = useRef<ProFormInstance>();

  const handleCustomSubmit = async () => {
    // Get all values with transform applied
    const values = formRef.current?.getFieldsFormatValue();
    console.log('Formatted values:', values);
  };

  return (
    <ProForm formRef={formRef} onFinish={async (values) => { /* ... */ }}>
      <ProFormDateRangePicker
        name="dateRange"
        label="Date Range"
        transform={(value) => ({
          startDate: value[0],
          endDate: value[1],
        })}
      />
      <ProFormText
        name="tags"
        label="Tags"
        convertValue={(value) => value?.join(', ')}
        transform={(value) => value?.split(', ').map((s: string) => s.trim())}
      />
    </ProForm>
  );
};
```

---

## ProForm dependency

```tsx
<ProForm>
  <ProFormText name="customerName" label="Customer" initialValue="Acme Corp" />
  <ProFormDependency name={['customerName']}>
    {({ customerName }) => (
      <ProFormSelect
        name="contractType"
        label={`Contract with ${customerName}`}
        options={[
          { label: 'Standard', value: 'standard' },
          { label: 'Premium', value: 'premium' },
        ]}
      />
    )}
  </ProFormDependency>
</ProForm>

{/* Alternative: ProForm.Item render props */}
<ProForm>
  <ProFormText name="name" label="Name" />
  <ProForm.Item noStyle shouldUpdate>
    {(form) => (
      <ProFormSelect
        label={`Type for ${form.getFieldValue('name')}`}
        name="type"
        options={[{ label: 'A', value: 'a' }]}
      />
    )}
  </ProForm.Item>
</ProForm>
```

---

## ProFormSelect request

```tsx
// Remote options (auto-cached, auto-loading):
<ProFormSelect
  name="city"
  label="City"
  request={async () => {
    const res = await fetch('/api/cities');
    const data = await res.json();
    return data.map((item: any) => ({
      label: item.name,
      value: item.id,
    }));
  }}
  placeholder="Select city"
/>

// With dependencies (params trigger re-request):
<ProFormSelect
  name="district"
  label="District"
  dependencies={['city']}
  request={async (params) => {
    const res = await fetch(`/api/districts?city=${params.city}`);
    return res.json();
  }}
/>
```

---

## ModalForm / DrawerForm

```tsx
import { ModalForm, ProFormText, ProFormSelect } from '@ant-design/pro-components';
import { Button, message } from 'antd';

<ModalForm
  title="Create Item"
  trigger={<Button type="primary">New Item</Button>}
  width={600}
  modalProps={{ destroyOnClose: true, maskClosable: false }}
  onFinish={async (values) => {
    await createItem(values);
    message.success('Created!');
    return true;  // returning true closes the modal
  }}
>
  <ProFormText name="name" label="Name" rules={[{ required: true }]} />
  <ProFormSelect name="type" label="Type" valueEnum={{ a: 'A', b: 'B' }} />
</ModalForm>
```

For DrawerForm, replace `ModalForm` with `DrawerForm` and `modalProps` with `drawerProps`.

---

## EditableProTable

```tsx
import { EditableProTable } from '@ant-design/pro-components';
import { useState } from 'react';

type DataSourceType = { id: string; name: string; status: string };

const MyEditableTable = () => {
  const [editableKeys, setEditableKeys] = useState<React.Key[]>([]);
  const [dataSource, setDataSource] = useState<DataSourceType[]>([]);

  const columns: ProColumns<DataSourceType>[] = [
    { title: 'Name', dataIndex: 'name' },
    {
      title: 'Status',
      dataIndex: 'status',
      valueType: 'select',
      valueEnum: { open: 'Open', closed: 'Closed' },
    },
    {
      title: 'Actions',
      valueType: 'option',
      render: (text, record, _, action) => [
        <a key="edit" onClick={() => action?.startEditable?.(record.id)}>Edit</a>,
      ],
    },
  ];

  return (
    <EditableProTable<DataSourceType>
      rowKey="id"
      columns={columns}
      value={dataSource}
      onChange={setDataSource}
      recordCreatorProps={{
        position: 'bottom',
        record: () => ({ id: Date.now().toString(), name: '', status: 'open' }),
      }}
      editable={{
        type: 'multiple',
        editableKeys,
        onSave: async (rowKey, data) => {
          console.log('Save:', rowKey, data);
        },
        onChange: setEditableKeys,
      }}
    />
  );
};
```

---

## Shared columns for Table + Form + Descriptions

The power of Pro Components: one column definition drives all three views.

```tsx
import { ProTable, ProForm, ProDescriptions } from '@ant-design/pro-components';
import type { ProColumns } from '@ant-design/pro-components';

type Item = { id: number; name: string; status: string; price: number; date: string };

// Single column definition used everywhere:
const columns: ProColumns<Item>[] = [
  { title: 'ID', dataIndex: 'id', hideInForm: true },
  {
    title: 'Name',
    dataIndex: 'name',
    formItemProps: { rules: [{ required: true }] },
  },
  {
    title: 'Status',
    dataIndex: 'status',
    valueType: 'select',
    valueEnum: { active: 'Active', inactive: 'Inactive' },
  },
  {
    title: 'Price',
    dataIndex: 'price',
    valueType: 'money',
    hideInSearch: true,
  },
  {
    title: 'Date',
    dataIndex: 'date',
    valueType: 'date',
    hideInSearch: true,
  },
  {
    title: 'Actions',
    valueType: 'option',
    hideInForm: true,
    hideInDescriptions: true,
    render: (_, record) => [<a key="edit">Edit</a>],
  },
];

// Table view:
<ProTable<Item> columns={columns} request={fetchList} rowKey="id" />

// Description view:
<ProDescriptions<Item> columns={columns} dataSource={record} column={2} />

// Form view (ProTable type="form"):
<ProTable<Item> columns={columns} type="form" onSubmit={handleSubmit} />
```
