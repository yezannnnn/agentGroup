---
name: ant-design-pro-components
user-invocable: false
description: >
  Ant Design Pro Components (@ant-design/pro-components) complete technical reference.
  Covers ProTable, ProForm, ProFormFields, ProDescriptions, ProCard, ProLayout,
  EditableProTable, ModalForm, DrawerForm, StepsForm, QueryFilter, LightFilter,
  and all ProForm field components (ProFormText, ProFormSelect, ProFormDigit,
  ProFormDatePicker, ProFormList, ProFormDependency, etc.).
  Use this skill whenever code imports from @ant-design/pro-components,
  @ant-design/pro-table, @ant-design/pro-form, @ant-design/pro-layout,
  @ant-design/pro-card, or @ant-design/pro-descriptions.
  Also use when the task involves ProTable columns definition, valueType,
  request function, ProForm submitter, form field components, convertValue,
  transform, actionRef, formRef, or any Ant Design Pro high-level component.
  This skill provides the correct API for the current stable version.
  Do NOT search the web for Pro Components docs -- use this skill instead.
---

# Ant Design Pro Components

> **Package**: `@ant-design/pro-components` | **Docs**: https://procomponents.ant.design/en-US | **GitHub**: https://github.com/ant-design/pro-components

Pro Components is a higher-level component library built on top of Ant Design. It provides opinionated, data-driven components that reduce boilerplate for CRUD-heavy admin UIs.

## Architecture Overview

All Pro Components share a **universal schema system** based on `columns` / `ProSchema`. The same column definition can drive a table, a form, and a description list -- controlled by `hideInTable`, `hideInForm`, `hideInSearch`, `hideInDescriptions`.

Core pattern: **`valueType` + `valueEnum`** determine both rendering and form input type automatically.

```tsx
import {
  ProTable, ProForm, ProFormText, ProFormSelect,
  ProFormDigit, ProFormDatePicker, ProFormDateRangePicker,
  ProDescriptions, ProCard, ModalForm, DrawerForm,
  EditableProTable, QueryFilter, LightFilter, StepsForm,
  ProFormList, ProFormDependency,
} from '@ant-design/pro-components';
```

## ProTable -- Quick Reference

ProTable wraps antd Table with built-in search form, toolbar, and data fetching.

### request (most important API)

```tsx
<ProTable<DataType, Params>
  params={params}
  request={async (
    params: T & { pageSize: number; current: number },
    sort,
    filter,
  ) => {
    const msg = await myQuery({
      page: params.current,
      pageSize: params.pageSize,
    });
    return {
      data: msg.result,
      success: boolean,  // must return true, or table stops parsing
      total: number,     // required for pagination
    };
  }}
/>
```

### Key ProTable Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `request` | `(params,sort,filter) => {data,success,total}` | - | Async data fetcher |
| `params` | `object` | - | Extra params for request; changes trigger reload |
| `postData` | `(data: T[]) => T[]` | - | Transform data after request |
| `columns` | `ProColumns<T>[]` | - | Column definitions (see Columns ref) |
| `actionRef` | `MutableRefObject<ActionType>` | - | Imperative actions (reload, reset, etc.) |
| `formRef` | `MutableRefObject<FormInstance>` | - | Query form instance |
| `toolBarRender` | `(action) => ReactNode[]` | - | Toolbar buttons |
| `search` | `false \| SearchConfig` | - | Search form config, false to hide |
| `options` | `false \| OptionConfig` | `{fullScreen:false, reload:true, density:true, setting:true}` | Toolbar options |
| `editable` | `TableRowEditable` | - | Editable table config |
| `manualRequest` | `boolean` | `false` | Skip auto first request |
| `dateFormatter` | `"string" \| "number" \| ((v,vt)=>string\|number) \| false` | `"string"` | Date format mode |
| `beforeSearchSubmit` | `(params:T)=>T` | - | Transform params before search |
| `columnEmptyText` | `string \| false` | `false` | Empty cell placeholder |
| `tableRender` | `(props,dom,{toolbar,alert,table})=>ReactNode` | - | Full custom table render |
| `toolbar` | `ListToolBarProps` | - | ListToolBar pass-through |
| `tableExtraRender` | `(props,dataSource)=>ReactNode` | - | Extra content above table |
| `cardBordered` | `boolean \| {search?,table?}` | `false` | Card borders |
| `ghost` | `boolean` | `false` | Remove content padding |
| `debounceTime` | `number` | `10` | Request debounce ms |
| `revalidateOnFocus` | `boolean` | `false` | Refetch on window focus |
| `columnsState` | `ColumnStateType` | - | Column show/hide persistence |

### ActionType (actionRef methods)

```tsx
interface ActionType {
  reload: (resetPageIndex?: boolean) => void;
  reloadAndRest: () => void;     // reload + reset page to 1
  reset: () => void;             // reset form + reload
  clearSelected?: () => void;
  startEditable: (rowKey: Key) => boolean;
  cancelEditable: (rowKey: Key) => boolean;
}
const ref = useRef<ActionType>();
<ProTable actionRef={ref} />;
ref.current.reload();
```

### Columns (ProColumns) Key Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | `ReactNode \| ((config,type)=>ReactNode)` | - | Column header |
| `dataIndex` | `string \| string[]` | - | Data field path |
| `valueType` | `valueType` | `"text"` | Rendering + form input type |
| `valueEnum` | `Record<string, {text,status}>` | - | Enum mapping |
| `fieldProps` | `(form,config)=>Record \| Record` | - | Pass-through to input component |
| `formItemProps` | `(form,config)=>formItemProps \| formItemProps` | - | Pass-through to Form.Item |
| `render` | `(text,record,index,action)=>ReactNode` | - | Custom cell render |
| `renderText` | `(text,record,index,action)=>string` | - | Custom text render |
| `renderFormItem` | `(item,{type,defaultRender,...},form)=>ReactNode` | - | Custom search input |
| `search` | `false \| {transform:(v)=>any}` | `true` | Search config, false to hide |
| `hideInSearch` | `boolean` | - | Hide from search form |
| `hideInTable` | `boolean` | - | Hide from table |
| `hideInForm` | `boolean` | - | Hide from form |
| `hideInDescriptions` | `boolean` | - | Hide from descriptions |
| `ellipsis` | `boolean` | - | Text overflow ellipsis |
| `copyable` | `boolean` | - | Copy button |
| `tooltip` | `string` | - | Header tooltip |
| `order` | `number` | - | Search form field order |
| `colSize` | `number` | - | Search form grid size |
| `filters` | `boolean \| object[]` | `false` | Column filters |
| `editable` | `false \| (text,record,index)=>boolean` | `true` | Editable cell config |
| `request` | See schema docs | - | Remote valueEnum |
| `initialValue` | `any` | - | Search form initial value |

### valueType Quick Reference

| valueType | Display | Form Input |
|-----------|---------|------------|
| `text` | plain text | Input |
| `password` | `***` | Input.Password |
| `money` | `$ 1,000.00` | InputNumber |
| `textarea` | long text | TextArea |
| `option` | action buttons | - |
| `date` | `2024-01-01` | DatePicker |
| `dateWeek` | `2024-1st` | DatePicker week |
| `dateMonth` | `2024-01` | DatePicker month |
| `dateQuarter` | `2024-Q1` | DatePicker quarter |
| `dateYear` | `2024` | DatePicker year |
| `dateRange` | date range | RangePicker |
| `dateTime` | date + time | DateTimePicker |
| `dateTimeRange` | datetime range | DateTimeRangePicker |
| `time` | time only | TimePicker |
| `timeRange` | time range | TimeRangePicker |
| `select` | tag/text | Select |
| `checkbox` | checkbox text | Checkbox |
| `rate` | stars | Rate |
| `radio` | radio text | Radio |
| `radioButton` | radio button | Radio.Button |
| `progress` | progress bar | InputNumber |
| `percent` | `10%` | InputNumber |
| `digit` | number | InputNumber |
| `digitRange` | number range | InputNumber range |
| `switch` | Switch | Switch |
| `code` | code block | TextArea |
| `jsonCode` | JSON formatted | TextArea |
| `avatar` | avatar image | - |
| `image` | image | Upload |
| `color` | color swatch | - |
| `cascader` | cascader | Cascader |
| `treeSelect` | tree select | TreeSelect |
| `index` | row index (auto) | - |
| `indexBorder` | bordered index | - |

## ProForm -- Quick Reference

ProForm wraps antd Form with auto-loading submitter, layout presets, and data conversion.

### Key ProForm Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `onFinish` | `(values)=>Promise<void>` | - | Submit handler (auto sets loading) |
| `onReset` | `(e)=>void` | - | Reset callback |
| `submitter` | `boolean \| SubmitterProps` | `true` | Submit/reset buttons config |
| `formRef` | `MutableRefObject<ProFormInstance>` | - | Enhanced form instance |
| `request` | `(params)=>Promise<data>` | - | Load initial values from API |
| `params` | `Record` | - | Params for request |
| `dateFormatter` | `string \| number \| fn \| false` | `"string"` | Date format |
| `syncToUrl` | `true \| (values,type)=>values` | - | Sync form to URL params |
| `omitNil` | `boolean` | `true` | Auto remove null/undefined |
| `autoFocusFirstInput` | `boolean` | `true` | Focus first input |
| `isKeyPressSubmit` | `boolean` | - | Submit on Enter |
| `grid` | `boolean` | - | Enable grid layout mode |
| `rowProps` | `RowProps` | `{gutter:8}` | Grid Row props |

### ProFormInstance (formRef methods)

```tsx
getFieldsFormatValue?: (nameList?: true) => T;
getFieldFormatValue?: (nameList?: NamePath) => T;
getFieldFormatValueObject?: (nameList?: NamePath) => T;
validateFieldsReturnFormatValue?: (nameList?: NamePath[]) => Promise<T>;
```

### Data Conversion

**convertValue** -- transform data FROM backend BEFORE component displays it:
```tsx
<ProFormText convertValue={(value, namePath) => value.split(",")} />
```

**transform** -- transform data FROM component BEFORE submitting to backend:
```tsx
<ProFormDatePicker
  transform={(value, namePath, allValues) => ({
    startDate: value.format("YYYY-MM-DD"),
  })}
/>
```

### submitter Config

| Prop | Type | Description |
|------|------|-------------|
| `onSubmit` | `()=>void` | Submit handler |
| `onReset` | `()=>void` | Reset handler |
| `searchConfig` | `{resetText,submitText}` | Button text |
| `submitButtonProps` | `ButtonProps` | Submit button props |
| `resetButtonProps` | `ButtonProps` | Reset button props |
| `render` | `false \| (props,dom:JSX[])=>ReactNode[]` | Custom render (dom[0]=submit, dom[1]=reset) |

## ProForm Field Components -- Quick Reference

All field components share: `name`, `label`, `width`, `tooltip`, `fieldProps`, `formItemProps`, `rules`, `initialValue`, `convertValue`, `transform`, `colProps`, `rowProps`.

| Component | Based On | Extra Props |
|-----------|----------|-------------|
| `ProFormText` | Input | Standard Input props via fieldProps |
| `ProFormText.Password` | Input.Password | Standard Input.Password props |
| `ProFormTextArea` | Input.TextArea | Standard TextArea props |
| `ProFormDigit` | InputNumber | Auto formats 2 decimals, min=0 |
| `ProFormMoney` | InputNumber | `locale`, `customSymbol`, `min`, `max`, `numberFormatOptions`, `numberPopoverRender` |
| `ProFormSelect` | Select | `options`, `valueEnum`, `request`, `fieldProps.optionItemRender` |
| `ProFormTreeSelect` | TreeSelect | `valueEnum`, `request` |
| `ProFormCheckbox` | Checkbox.Group | `options`, `layout: "horizontal"\|"vertical"` |
| `ProFormRadio.Group` | Radio.Group | `options`, `radioType: "default"\|"button"` |
| `ProFormSwitch` | Switch | Standard Switch props |
| `ProFormRate` | Rate | Standard Rate props |
| `ProFormSlider` | Slider | `marks`, `range` via fieldProps |
| `ProFormDatePicker` | DatePicker | Standard DatePicker props |
| `ProFormDateTimePicker` | DatePicker (showTime) | Datetime picker |
| `ProFormDateRangePicker` | RangePicker | Date range |
| `ProFormDateTimeRangePicker` | RangePicker (showTime) | Datetime range |
| `ProFormTimePicker` | TimePicker | Time only |
| `ProFormUploadButton` | Upload | `icon`, `title` (default "Click to upload") |
| `ProFormUploadDragger` | Upload.Dragger | `icon`, `title`, `description` |
| `ProFormCaptcha` | Input + Button | `onGetCaptcha`, `captchaProps`, `countDown`, `captchaTextRender`, `phoneName` |

### Width Presets

| Value | Pixels | Use Case |
|-------|--------|----------|
| `"xs"` | 104px | Short numbers, codes |
| `"s"` | 216px | Name, phone, ID |
| `"m"` | 328px | Standard fields |
| `"l"` | 440px | Long URLs, tags |
| `"x"` | 552px | Long text, descriptions |

### Search Form (SearchConfig)

| Prop | Type | Default |
|------|------|---------|
| `filterType` | `"query" \| "light"` | `"query"` |
| `searchText` | `string` | `"Search"` |
| `resetText` | `string` | `"reset"` |
| `submitText` | `string` | `"Submit"` |
| `labelWidth` | `number \| "auto"` | `80` |
| `span` | `number \| ColConfig` | `defaultColConfig` |
| `defaultCollapsed` | `boolean` | `true` |
| `collapsed` / `onCollapse` | controlled collapse | - |
| `collapseRender` | `((collapsed,showBtn?)=>ReactNode) \| false` | - |
| `optionRender` | `((config,formProps,dom)=>ReactNode[]) \| false` | - |
| `showHiddenNum` | `boolean` | `false` |

## Pitfalls and Common Mistakes

1. **request must return `{data, success, total}`** -- if `success` is not `true`, ProTable stops processing data even if data exists.
2. **Do NOT use `value`/`onChange` directly on ProForm fields** -- use `initialValues` on the form or `initialValue` on the field. Direct value binding causes form state conflicts.
3. **ProForm's `onFinish` returns a Promise** -- unlike antd Form, returning the promise auto-manages loading state on the submit button.
4. **`params` changes trigger re-request** -- any change to the `params` object causes ProTable to re-fetch data. Use `useMemo` to prevent unnecessary re-renders.
5. **`dateFormatter` defaults to `"string"`** -- moment/dayjs objects are auto-converted to strings. Set to `false` if you need raw date objects.
6. **`omitNil` defaults to `true`** -- null/undefined values are stripped from form submission. Set to `false` if nil has semantic meaning.
7. **Columns with `valueType` of `index`, `indexBorder`, or `option` without `dataIndex`/`key` are ignored** in the search form.
8. **`formItemProps.rules` don't work in query forms by default** -- you need to configure `ignoreRules` for them to take effect.

## References Guide

| Need | File |
|------|------|
| Complete ProTable API (all props, Columns, ActionType, Toolbar, Batch ops) | `references/protable-api.md` |
| All ProForm field components with detailed props | `references/proform-fields-api.md` |
| Common usage patterns and code examples | `references/examples.md` |
