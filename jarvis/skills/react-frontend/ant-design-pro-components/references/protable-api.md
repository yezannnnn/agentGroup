# ProTable Complete API Reference

> Source: https://procomponents.ant.design/en-US/components/table

## Table of Contents

- [ProTable Props](#protable-props)
- [request API](#request-api)
- [Columns (ProColumns)](#columns-procolumns)
- [valueType](#valuetype)
- [valueEnum](#valueenum)
- [ActionType (actionRef)](#actiontype-actionref)
- [SearchConfig](#searchconfig)
- [ColConfig](#colconfig)
- [ColumnStateType](#columnstatetype)
- [Batch Operations](#batch-operations)
- [ListToolBarProps](#listtoolbarprops)
- [ListToolBarMenu](#listtoolbarmenu)
- [ListToolBarTabs](#listtoolbartabs)
- [Setting](#setting)
- [TableDropdown](#tabledropdown)
- [RecordCreator](#recordcreator)
- [OptionConfig / SettingOptionType](#optionconfig)
- [EditableProTable](#editableprotable)
- [ProDescriptions](#prodescriptions)

---

## ProTable Props

ProTable extends all antd Table props. Only additional/different props are listed.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `request` | Async data fetcher, returns `{data, success, total}` | `(params?: {pageSize,current}, sort, filter) => {data,success,total}` | - |
| `params` | Extra params for request; changes trigger reload | `object` | - |
| `postData` | Transform data after request | `(data: T[]) => T[]` | - |
| `defaultData` | Default data | `T[]` | - |
| `dataSource` | Static table data (prefer request) | `T[]` | - |
| `onDataSourceChange` | Callback when data changes | `(dataSource: T[]) => void` | - |
| `actionRef` | Imperative action handle | `MutableRefObject<ActionType>` | - |
| `formRef` | Query form instance | `MutableRefObject<FormInstance>` | - |
| `toolBarRender` | Render toolbar buttons | `(action) => ReactNode[]` | - |
| `onLoad` | After data loaded (fires multiple times) | `(dataSource: T[]) => void` | - |
| `onLoadingChange` | Loading state changed | `(loading: boolean) => void` | - |
| `onRequestError` | Data load failed | `(error) => void` | - |
| `tableClassName` | Table wrapper className | `string` | - |
| `tableStyle` | Table wrapper style | `CSSProperties` | - |
| `options` | Toolbar options (density/fullscreen/reload/settings) | `false \| OptionConfig` | `{fullScreen:false, reload:true, density:true, setting:true}` |
| `search` | Search form config, false to hide | `false \| SearchConfig` | - |
| `dateFormatter` | Date format mode | `"string" \| "number" \| ((value: Moment, valueType: string) => string \| number) \| false` | `"string"` |
| `defaultSize` | Default table size | `SizeType` | - |
| `beforeSearchSubmit` | Transform params before search | `(params: T) => T` | - |
| `onSizeChange` | Table size changed | `(size: 'default' \| 'middle' \| 'small') => void` | - |
| `type` | ProTable type | `"form"` | - |
| `form` | antd Form config | `FormProps` | - |
| `onSubmit` | Form submitted | `(params: U) => void` | - |
| `onReset` | Form reset | `() => void` | - |
| `columnEmptyText` | Empty cell text, false to disable | `string \| false` | `false` |
| `tableRender` | Full custom table render | `(props, dom, domList: {toolbar, alert, table}) => ReactNode` | - |
| `toolbar` | ListToolBar config pass-through | `ListToolBarProps` | - |
| `tableExtraRender` | Extra content above table | `(props: ProTableProps<T,U>, dataSource: T[]) => ReactNode` | - |
| `manualRequest` | Skip auto first request | `boolean` | `false` |
| `editable` | Editable table config | `TableRowEditable` | - |
| `cardBordered` | Card borders | `boolean \| {search?: boolean, table?: boolean}` | `false` |
| `ghost` | Remove content padding | `boolean` | `false` |
| `debounceTime` | Request debounce ms | `number` | `10` |
| `revalidateOnFocus` | Re-request on window focus | `boolean` | `false` |
| `columnsState` | Column show/hide persistence | `ColumnStateType` | - |

---

## request API

```tsx
<ProTable<DataType, Params>
  params={params}
  request={async (
    params: T & {
      pageSize: number;
      current: number;
    },
    sort,
    filter,
  ) => {
    const msg = await myQuery({
      page: params.current,
      pageSize: params.pageSize,
    });
    return {
      data: msg.result,      // T[]
      success: boolean,       // MUST be true or table stops
      total: number,          // required for pagination
    };
  }}
/>
```

- `params` first parameter = query form values merged with `params` prop
- `params` always contains `pageSize` and `current`
- `sort` contains column sort info
- `filter` contains column filter info
- `request` auto-manages `loading` state
- Re-executes when query form submits or `params` prop changes

---

## Columns (ProColumns)

Extends antd ColumnType with additional fields.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `title` | Column header (supports function) | `ReactNode \| ((config: ProColumnType<T>, type: ProTableTypes) => ReactNode)` | - |
| `tooltip` | Info icon + hover tooltip after title | `string` | - |
| `ellipsis` | Auto text overflow ellipsis | `boolean` | - |
| `copyable` | Show copy button | `boolean` | - |
| `valueEnum` | Enum mapping for display | `valueEnum` | - |
| `valueType` | Determines render + form input | `valueType` | `"text"` |
| `order` | Search form field order (higher = first) | `number` | - |
| `fieldProps` | Props pass-through to input component | `(form, config) => Record \| Record` | - |
| `formItemProps` | Props pass-through to Form.Item | `(form, config) => formItemProps \| formItemProps` | - |
| `renderText` | Custom text render (must return string) | `(text, record, index, action) => string` | - |
| `render` | Custom cell render | `(text: ReactNode, record, index, action) => ReactNode \| ReactNode[]` | - |
| `renderFormItem` | Custom search form input | `(item, {type, defaultRender, formItemProps, fieldProps, ...}, form) => ReactNode` | - |
| `search` | Search config, false to hide | `false \| { transform: (value: any) => any }` | `true` |
| `search.transform` | Transform search value (e.g., date range split) | `(value: any) => any` | - |
| `editable` | Editable in EditableProTable | `false \| (text, record, index) => boolean` | `true` |
| `colSize` | Search form grid columns (proportion = colSize * span) | `number` | - |
| `hideInSearch` | Hide from search form | `boolean` | - |
| `hideInTable` | Hide from table | `boolean` | - |
| `hideInForm` | Hide from form | `boolean` | - |
| `hideInDescriptions` | Hide from descriptions | `boolean` | - |
| `filters` | Column filter menu (true = auto from valueEnum) | `boolean \| object[]` | `false` |
| `onFilter` | Local filter fn, false to disable | `(value, record) => boolean \| false` | `false` |
| `request` | Remote valueEnum fetch | `request` | - |
| `initialValue` | Search form field initial value | `any` | - |

---

## valueType

Determines how values are rendered in table/descriptions AND what input component is used in forms.

| valueType | Table Display | Form Component |
|-----------|--------------|----------------|
| `text` | Plain text | Input |
| `password` | `***` masked | Input.Password |
| `money` | `$ 1,000.00` formatted | InputNumber |
| `textarea` | Multiline text | Input.TextArea |
| `option` | Action links/buttons | (not in form) |
| `date` | `YYYY-MM-DD` | DatePicker |
| `dateWeek` | `YYYY-Wth` | DatePicker(week) |
| `dateMonth` | `YYYY-MM` | DatePicker(month) |
| `dateQuarter` | `YYYY-Q#` | DatePicker(quarter) |
| `dateYear` | `YYYY` | DatePicker(year) |
| `dateRange` | Two dates | RangePicker |
| `dateTime` | `YYYY-MM-DD HH:mm:ss` | DateTimePicker |
| `dateTimeRange` | Two datetimes | DateTimeRangePicker |
| `time` | `HH:mm:ss` | TimePicker |
| `timeRange` | Two times | TimeRangePicker |
| `select` | Tag or text | Select |
| `checkbox` | Checkbox tag | Checkbox.Group |
| `rate` | Star rating | Rate |
| `radio` | Radio text | Radio.Group |
| `radioButton` | Button style radio | Radio.Button |
| `progress` | Progress bar | InputNumber |
| `percent` | `XX%` | InputNumber |
| `digit` | Formatted number | InputNumber |
| `digitRange` | Number range | InputNumber x 2 |
| `switch` | Switch toggle | Switch |
| `code` | Code block | Input.TextArea |
| `jsonCode` | Formatted JSON | Input.TextArea |
| `avatar` | Avatar image | (not in form) |
| `image` | Image thumbnail | Upload |
| `color` | Color swatch | (not in form) |
| `cascader` | Cascader path | Cascader |
| `treeSelect` | Tree node | TreeSelect |
| `index` | Auto row index | (not in form/search) |
| `indexBorder` | Bordered row index | (not in form/search) |

---

## valueEnum

```tsx
const valueEnum = {
  open: 'Processing',
  // or with status badge:
  open: {
    text: 'Processing',
    status: 'Processing',  // 'Success' | 'Error' | 'Processing' | 'Warning' | 'Default'
  },
  closed: {
    text: 'Resolved',
    status: 'Success',
    disabled: true,  // disable in form select
  },
};
```

---

## ActionType (actionRef)

```tsx
interface ActionType {
  reload: (resetPageIndex?: boolean) => void;
  reloadAndRest: () => void;     // reload + reset to page 1 (excludes form)
  reset: () => void;             // reset form + reload
  clearSelected?: () => void;    // clear row selection
  startEditable: (rowKey: Key) => boolean;
  cancelEditable: (rowKey: Key) => boolean;
}

const actionRef = useRef<ActionType>();
<ProTable actionRef={actionRef} />;

actionRef.current?.reload();
actionRef.current?.reloadAndRest();
actionRef.current?.reset();
actionRef.current?.clearSelected();
actionRef.current?.startEditable(rowKey);
actionRef.current?.cancelEditable(rowKey);
```

---

## SearchConfig

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `filterType` | Filter form type | `'query' \| 'light'` | `'query'` |
| `searchText` | Search button text | `string` | `"Search"` |
| `resetText` | Reset button text | `string` | `"reset"` |
| `submitText` | Submit button text | `string` | `"Submit"` |
| `labelWidth` | Label width | `number \| 'auto'` | `80` |
| `span` | Columns in query form | `number \| ColConfig` | `defaultColConfig` |
| `className` | Search form className | `string` | - |
| `collapseRender` | Collapse button render | `((collapsed: boolean, showCollapseButton?: boolean) => ReactNode) \| false` | - |
| `defaultCollapsed` | Default collapsed state | `boolean` | `true` |
| `collapsed` | Controlled collapsed | `boolean` | - |
| `onCollapse` | Collapse event | `(collapsed: boolean) => void` | - |
| `optionRender` | Custom action bar | `((searchConfig, formProps, dom) => ReactNode[]) \| false` | - |
| `showHiddenNum` | Show hidden fields count | `boolean` | `false` |

---

## ColConfig

Default responsive column config for search form:

```tsx
const defaultColConfig = {
  xs: 24,
  sm: 24,
  md: 12,
  lg: 12,
  xl: 8,
  xxl: 6,
};
```

---

## ColumnStateType

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `defaultValue` | Default column states (first time only, used for reset) | `Record<string, ColumnsState>` | - |
| `value` | Controlled column states | `Record<string, ColumnsState>` | - |
| `onChange` | Column state changed | `(value: Record<string, ColumnsState>) => void` | - |
| `persistenceKey` | Storage key for persistence | `string \| number` | - |
| `persistenceType` | Storage type | `'localStorage' \| 'sessionStorage'` | - |

---

## Batch Operations

Enable via `rowSelection` prop (same as antd). ProTable adds alert bar.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `alwaysShowAlert` | Always show alert bar | `boolean` | - |
| `tableAlertRender` | Custom alert left side | `({selectedRowKeys, selectedRows, onCleanSelected}) => ReactNode \| false` | - |
| `tableAlertOptionRender` | Custom alert right side | `({selectedRowKeys, selectedRows, onCleanSelected}) => ReactNode \| false` | - |

---

## ListToolBarProps

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `title` | Title | `ReactNode` | - |
| `subTitle` | Subtitle | `ReactNode` | - |
| `tooltip` | Tooltip text | `string` | - |
| `search` | Search input | `ReactNode \| SearchProps` | - |
| `actions` | Action buttons area | `ReactNode[]` | - |
| `settings` | Settings area | `(ReactNode \| Setting)[]` | - |
| `filter` | Filter area (usually LightFilter) | `ReactNode` | - |
| `multipleLine` | Multi-line mode | `boolean` | `false` |
| `menu` | Menu config | `ListToolBarMenu` | - |
| `tabs` | Tabs (only if multipleLine=true) | `ListToolBarTabs` | - |

---

## ListToolBarMenu

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `type` | Menu display type | `'inline' \| 'dropdown' \| 'tab'` | `'dropdown'` |
| `activeKey` | Current active key | `string` | - |
| `items` | Menu items | `{key: string; label: ReactNode}[]` | - |
| `onChange` | Menu switch callback | `(activeKey) => void` | - |

---

## ListToolBarTabs

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `activeKey` | Currently selected item | `string` | - |
| `items` | Tab items | `{key: string; tab: ReactNode}[]` | - |
| `onChange` | Tab switch callback | `(activeKey) => void` | - |

---

## Setting

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `icon` | Setting icon | `ReactNode` | - |
| `tooltip` | Tooltip text | `string` | - |
| `key` | Unique identifier | `string` | - |
| `onClick` | Click handler | `(key: string) => void` | - |

---

## TableDropdown

Helper component for action column dropdowns.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `key` | Unique identifier | `string` | - |
| `name` | Display content | `ReactNode` | - |
| `(...Menu.Item)` | antd Menu.Item props | `Menu.Item` | - |

---

## RecordCreator

Used in EditableProTable to add new rows.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `record` | Row data to add (should contain unique key) | `T` | `{}` |
| `position` | Insert position | `'top' \| 'bottom'` | `'bottom'` |
| `(...buttonProps)` | antd Button props | `ButtonProps` | - |

---

## OptionConfig

```tsx
export type OptionsType =
  | ((e: React.MouseEvent<HTMLSpanElement>, action?: ActionType) => void)
  | boolean;

export type OptionConfig = {
  density?: boolean;
  fullScreen?: OptionsType;
  reload?: OptionsType;
  setting?: boolean;
  search?: (SearchProps & { name?: string }) | boolean;
  reloadIcon?: React.ReactNode;
  densityIcon?: React.ReactNode;
};

export type SettingOptionType = {
  draggable?: boolean;
  checkable?: boolean;
  showListItemOption?: boolean;
  checkedReset?: boolean;
  listsHeight?: number;
  extra?: React.ReactNode;
  children?: React.ReactNode;
  settingIcon?: React.ReactNode;
};
```

---

## EditableProTable

EditableProTable inherits all ProTable props plus:

- `editable` prop for row-level edit configuration (see `TableRowEditable`)
- `controlled` and `recordCreatorProps` for new row creation
- Use `actionRef.current.startEditable(rowKey)` / `cancelEditable(rowKey)` to control editing

Detailed docs: https://procomponents.ant.design/en-US/components/editable-table

---

## ProDescriptions

ProDescriptions is the description-list counterpart of ProTable. It shares the same `columns` schema.

```tsx
import { ProDescriptions } from '@ant-design/pro-components';

<ProDescriptions
  columns={columns}       // same ProColumns definition
  request={async () => ({ data: record, success: true })}
  // or
  dataSource={record}
  column={2}              // antd Descriptions column count
  editable={{             // inline editing support
    onSave: async (key, record) => { ... },
  }}
/>
```

Key props: `columns`, `request`, `dataSource`, `column`, `editable`, `actionRef`.

Uses the same `valueType`, `valueEnum`, `render`, `renderText` as ProTable columns. Fields with `hideInDescriptions: true` are excluded.

Detailed docs: https://procomponents.ant.design/en-US/components/descriptions
