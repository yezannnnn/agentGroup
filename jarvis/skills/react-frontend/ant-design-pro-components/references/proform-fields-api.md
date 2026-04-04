# ProForm & ProForm Fields Complete API Reference

> Source: https://procomponents.ant.design/en-US/components/form
> Source: https://procomponents.ant.design/en-US/components/field-set

## Table of Contents

- [ProForm Props](#proform-props)
- [ProFormInstance](#proforminstance)
- [ProForm.Group](#proformgroup)
- [Submitter](#submitter)
- [Data Conversion (convertValue / transform)](#data-conversion)
- [Generic Field Properties](#generic-field-properties)
- [Width Presets](#width-presets)
- [ProFormText](#proformtext)
- [ProFormText.Password](#proformtextpassword)
- [ProFormTextArea](#proformtextarea)
- [ProFormDigit](#proformdigit)
- [ProFormMoney](#proformmoney)
- [ProFormSelect](#proformselect)
- [ProFormTreeSelect](#proformtreeselect)
- [ProFormCheckbox](#proformcheckbox)
- [ProFormRadio.Group](#proformradiogroup)
- [ProFormSwitch](#proformswitch)
- [ProFormRate](#proformrate)
- [ProFormSlider](#proformslider)
- [ProFormDatePicker](#proformdatepicker)
- [ProFormDateTimePicker](#proformdatetimepicker)
- [ProFormDateRangePicker](#proformdaterangepicker)
- [ProFormDateTimeRangePicker](#proformdatetimerangepicker)
- [ProFormTimePicker](#proformtimepicker)
- [ProFormUploadButton](#proformuploadbutton)
- [ProFormUploadDragger](#proformuploaddragger)
- [ProFormCaptcha](#proformcaptcha)
- [ProFormList](#proformlist)
- [ProFormDependency](#proformdependency)
- [ModalForm / DrawerForm](#modalform--drawerform)
- [StepsForm](#stepsform)
- [QueryFilter / LightFilter](#queryfilter--lightfilter)
- [ProCard](#procard)

---

## ProForm Props

ProForm extends antd Form. Additional props beyond `wrapperCol`, `labelCol`, `layout`:

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `onFinish` | Submit callback (auto sets loading on button) | `(values) => Promise<void>` | - |
| `onReset` | Reset callback | `(e) => void` | - |
| `submitter` | Submit/reset button config | `boolean \| SubmitterProps` | `true` |
| `dateFormatter` | Auto-format date values | `string \| number \| ((value: Moment, valueType: string) => string \| number) \| false` | `"string"` |
| `syncToUrl` | Sync form values to URL params | `true \| (values, type) => values` | - |
| `omitNil` | Remove null/undefined on submit | `boolean` | `true` |
| `formRef` | Enhanced form instance ref | `MutableRefObject<ProFormInstance<T>>` | - |
| `params` | Params for request | `Record` | - |
| `request` | Load initial values from API | `(params) => Promise<data>` | - |
| `isKeyPressSubmit` | Submit on Enter key | `boolean` | - |
| `autoFocusFirstInput` | Auto focus first input | `boolean` | `true` |
| `grid` | Enable grid layout mode | `boolean` | - |
| `rowProps` | Row props in grid mode | `RowProps` | `{gutter: 8}` |
| `(...)` | All other antd Form props | `FormProps` | - |

---

## ProFormInstance

ProFormInstance extends antd FormInstance with additional methods:

```tsx
/** Get all data formatted by ProForm (with transform applied) */
getFieldsFormatValue?: (nameList?: true) => T;
// nameList=true returns all data, even fields not managed by form

/** Get single field's formatted value */
getFieldFormatValue?: (nameList?: NamePath) => T;

/** Get single field's formatted value with name path preserved */
getFieldFormatValueObject?: (nameList?: NamePath) => T;
// {a:{b:value}} -> getFieldFormatValueObject(['a','b']) -> {a:{b:value}}

/** Validate fields then return all formatted data */
validateFieldsReturnFormatValue?: (nameList?: NamePath[]) => Promise<T>;
```

Usage:
```tsx
const formRef = useRef<ProFormInstance>();

<ProForm formRef={formRef} onFinish={async (values) => {
  // values already have transform applied
  // or use formRef for manual access:
  const formatted = formRef.current?.getFieldsFormatValue();
}}>
```

---

## ProForm.Group

Groups form fields with an optional title.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `title` | Group title | `string` | - |
| `children` | Form controls | `React.ReactNode` | - |

---

## Submitter

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `onSubmit` | Submit handler | `() => void` | - |
| `onReset` | Reset handler | `() => void` | - |
| `searchConfig` | Button text config | `{resetText, submitText}` | - |
| `submitButtonProps` | Submit button props | `ButtonProps` | - |
| `resetButtonProps` | Reset button props | `ButtonProps` | - |
| `render` | Custom render | `false \| (props, dom: JSX[]) => ReactNode[]` | - |

`render` callback: `dom[0]` = submit button, `dom[1]` = reset button.

```tsx
<ProForm
  submitter={{
    searchConfig: { resetText: 'Reset', submitText: 'Save' },
    resetButtonProps: { style: { display: 'none' } },  // hide reset
    render: (props, doms) => [
      <button key="reset" onClick={() => props.form?.resetFields()}>Reset</button>,
      <button key="submit" onClick={() => props.form?.submit?.()}>Submit</button>,
    ],
  }}
/>
```

---

## Data Conversion

### convertValue (pre-conversion, before display)

```tsx
export type SearchConvertKeyFn = (value: any, field: NamePath) => string | boolean | Record<string, any>;

// Examples:
convertValue: (value, namePath) => value.split(",")           // "a,b" => ["a","b"]
convertValue: (value, namePath) => JSON.parse(value)          // string => object
convertValue: (value, namePath) => Moment(value)              // number => Moment
convertValue: (value, namePath) => Moment(value, "YYYY-MM-DD") // string => Moment
convertValue: (value, namePath) => ({ value, label: value })  // string => {value,label}
```

### transform (on submit, before sending to backend)

```tsx
export type SearchTransformKeyFn = (
  value: any,
  namePath: string,
  allValues: any,
) => string | Record<string, any>;

// Examples:
transform: (value, namePath, allValues) => value.join(",")           // [a,b] => "a,b"
transform: (value, namePath, allValues) => ({ newName: value })      // rename field
transform: (value, namePath, allValues) => value.format("YYYY-MM-DD") // Moment => string
transform: (value, namePath, allValues) => value.valueOf()           // Moment => timestamp
transform: (value, namePath, allValues) => value.value               // {value,label} => value
transform: (value, namePath, allValues) => ({                        // split object
  valueName: value.value,
  labelName: value.label,
})
```

Both `ProFormDependency` and `formRef` support reading transformed values.

---

## Generic Field Properties

All ProForm field components share these props:

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `name` | Field name (Form.Item name) | `NamePath` | - |
| `label` | Field label | `ReactNode` | - |
| `width` | Field width preset or number | `number \| "xs" \| "s" \| "m" \| "l" \| "x"` | - |
| `tooltip` | Icon + hover info next to label | `string \| tooltipProps` | - |
| `fieldProps` | Pass-through to underlying antd component | `Record` | - |
| `formItemProps` | Pass-through to Form.Item | `Record` | - |
| `rules` | Validation rules (shorthand for formItemProps.rules) | `Rule[]` | - |
| `initialValue` | Initial value | `any` | - |
| `convertValue` | Pre-convert value before display | `SearchConvertKeyFn` | - |
| `transform` | Transform value on submit | `SearchTransformKeyFn` | - |
| `colProps` | Grid Col props (when grid mode enabled) | `ColProps` | `{xs: 24}` |
| `rowProps` | Grid Row props (ProFormGroup/List/FieldSet only) | `RowProps` | `{gutter: 8}` |
| `secondary` | Secondary control (LightFilter only) | `boolean` | `false` |
| `allowClear` | Clear button (LightFilter, also forwarded to fieldProps) | `boolean` | `true` |

The `fieldProps` pattern: Props you set on the ProForm field go to `Form.Item`. Props you set on `fieldProps` go to the underlying input component (Input, Select, DatePicker, etc.).

```tsx
// Example: ProFormText wraps Form.Item + Input
<ProFormText
  name="name"           // -> Form.Item name
  label="Name"          // -> Form.Item label
  rules={[{required:true}]}  // -> Form.Item rules
  fieldProps={{          // -> Input props
    placeholder: "Enter name",
    allowClear: true,
    onChange: (e) => console.log(e.target.value),
  }}
/>
// Equivalent to:
<Form.Item name="name" label="Name" rules={[{required:true}]}>
  <Input placeholder="Enter name" allowClear onChange={...} />
</Form.Item>
```

---

## Width Presets

| Width | Pixels | Use Case |
|-------|--------|----------|
| `"xs"` | 104px | Short numbers, short codes |
| `"s"` | 216px | Name, phone, ID |
| `"m"` | 328px | Standard width, most fields |
| `"l"` | 440px | Long URLs, tag groups, file paths |
| `"x"` | 552px | Long text, descriptions, notes |

---

## ProFormText

Wraps antd `Input`. All Input props go through `fieldProps`.

```tsx
import { ProFormText } from '@ant-design/pro-components';

<ProFormText
  name="text"
  label="Name"
  placeholder="Please enter a name"
  fieldProps={inputProps}
/>
```

---

## ProFormText.Password

Wraps antd `Input.Password`.

```tsx
<ProFormText.Password label="Password" name="password" />
```

---

## ProFormTextArea

Wraps antd `Input.TextArea`.

```tsx
<ProFormTextArea
  name="text"
  label="Description"
  placeholder="Please enter"
  fieldProps={inputTextAreaProps}
/>
```

---

## ProFormDigit

Wraps antd `InputNumber`. Auto-formats to 2 decimal places, min=0 by default.

```tsx
<ProFormDigit label="Amount" name="amount" min={1} max={10} />

// Change decimal precision:
<ProFormDigit
  label="Count"
  name="count"
  min={1}
  max={10}
  fieldProps={{ precision: 0 }}  // integer only
/>
```

---

## ProFormMoney

Amount input with currency symbol support.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `locale` | Currency locale (determines symbol) | `string` | `"zh-Hans-CN"` |
| `customSymbol` | Custom currency symbol | `string` | - |
| `numberPopoverRender` | Custom popover or false to disable | `((props, defaultText) => ReactNode) \| boolean` | `false` |
| `numberFormatOptions` | Intl.NumberFormat options | `NumberFormatOptions` | - |
| `min` | Minimum value | `number` | - |
| `max` | Maximum value | `number` | - |

Currency symbol map:
```
zh-CN: "Y", en-US: "$", en-GB: "GBP", ja-JP: "Y", ko-KR: "W",
es-ES/it-IT/fr-FR/de-DE: "EUR", ru-RU: "RUB", pt-BR: "R$",
zh-TW: "NT$", vi-VN: "VND", tr-TR: "TRY", pl-PL: "PLN"
```

```tsx
<ProFormMoney label="Amount" name="amount" locale="en-US" initialValue={22.22} min={0} />
<ProFormMoney label="Custom" name="custom" customSymbol="TWD" initialValue={100} />
```

---

## ProFormSelect

Wraps antd `Select`. Supports `options`, `valueEnum`, and `request` for option sources.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `options` | Static options | `{label, value}[]` | - |
| `valueEnum` | Enum object for options | `Record` | - |
| `request` | Async options loader | `() => Promise<{[key:string\|number]:any}>` | - |
| `fieldProps.optionItemRender` | Custom option item render | `(item) => ReactNode` | - |

```tsx
// With valueEnum:
<ProFormSelect
  name="status"
  label="Status"
  valueEnum={{ open: 'Open', closed: 'Closed' }}
/>

// With request:
<ProFormSelect
  name="status"
  label="Status"
  request={async () => [
    { label: 'Open', value: 'open' },
    { label: 'Closed', value: 'closed' },
  ]}
/>

// With options + custom render:
<ProFormSelect
  name="status"
  label="Status"
  options={[{ label: 'Open', value: 'open' }]}
  fieldProps={{
    optionItemRender(item) {
      return item.label + ' - ' + item.value;
    },
  }}
/>
```

---

## ProFormTreeSelect

Wraps antd `TreeSelect`. Supports `request` and `valueEnum`.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `valueEnum` | Enum object | `Record` | - |
| `request` | Async tree data loader | `() => Promise<{[key:string\|number]:any}>` | - |

```tsx
<ProFormTreeSelect
  name="category"
  placeholder="Select"
  allowClear
  width={330}
  request={async () => [
    {
      title: 'Node1', value: '0-0',
      children: [{ title: 'Child', value: '0-0-0' }],
    },
  ]}
  fieldProps={{
    showSearch: true,
    filterTreeNode: true,
    multiple: true,
    treeNodeFilterProp: 'title',
    fieldNames: { label: 'title' },
  }}
/>
```

---

## ProFormCheckbox

Wraps antd `Checkbox.Group`. Supports `options` and `layout`.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `options` | Checkbox options | `string[] \| {label: ReactNode, value: string}[]` | - |
| `layout` | Display direction | `"horizontal" \| "vertical"` | - |

```tsx
<ProFormCheckbox.Group
  name="checkbox"
  layout="vertical"
  label="Categories"
  options={['Agriculture', 'Manufacturing', 'Internet']}
/>
```

---

## ProFormRadio.Group

Wraps antd `Radio.Group`. Supports `options` and `radioType`.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `options` | Radio options | `string[] \| {label: ReactNode, value: string}[]` | - |
| `radioType` | Display style | `"default" \| "button"` | `"default"` |

```tsx
<ProFormRadio.Group
  name="radio"
  label="Type"
  radioType="button"
  options={[
    { label: 'Item 1', value: 'a' },
    { label: 'Item 2', value: 'b' },
  ]}
/>
```

---

## ProFormSwitch

Wraps antd `Switch`.

```tsx
<ProFormSwitch name="enabled" label="Enable" />
```

---

## ProFormRate

Wraps antd `Rate`.

```tsx
<ProFormRate name="rating" label="Rating" />
```

---

## ProFormSlider

Wraps antd `Slider`.

```tsx
<ProFormSlider
  name="slider"
  label="Value"
  marks={{ 0: 'A', 20: 'B', 40: 'C', 60: 'D', 80: 'E', 100: 'F' }}
/>
```

---

## ProFormDatePicker

Wraps antd `DatePicker`.

```tsx
<ProFormDatePicker name="date" label="Date" />
```

---

## ProFormDateTimePicker

Wraps antd `DatePicker` with showTime.

```tsx
<ProFormDateTimePicker name="datetime" label="DateTime" />
```

---

## ProFormDateRangePicker

Wraps antd `DatePicker.RangePicker`.

```tsx
<ProFormDateRangePicker name="dateRange" label="Date Range" />
```

---

## ProFormDateTimeRangePicker

Wraps antd `DatePicker.RangePicker` with showTime.

```tsx
<ProFormDateTimeRangePicker name="datetimeRange" label="DateTime Range" />
```

---

## ProFormTimePicker

Wraps antd `TimePicker`.

```tsx
<ProFormTimePicker name="time" label="Time" />
```

---

## ProFormUploadButton

Wraps antd `Upload` with button style preset.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `icon` | Button icon | `ReactNode` | `UploadOutlined` |
| `title` | Button text | `ReactNode` | `"Click to upload"` |

```tsx
<ProFormUploadButton label="Upload" name="file" action="upload.do" />
```

---

## ProFormUploadDragger

Wraps antd `Upload.Dragger`.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `icon` | Dragger icon | `ReactNode` | `InboxOutlined` |
| `title` | Dragger title | `ReactNode` | `"Click or drag files to this area to upload"` |
| `description` | Dragger description | `ReactNode` | `"Support single or bulk uploads"` |

```tsx
<ProFormUploadDragger label="Upload" name="file" action="upload.do" />
```

---

## ProFormCaptcha

CAPTCHA input with countdown button.

| Property | Description | Type | Default |
|----------|-------------|------|---------|
| `onGetCaptcha` | Get captcha handler (throw error to abort) | `(phone) => Promise<any>` | - |
| `captchaProps` | Button props | `ButtonProps` | - |
| `countDown` | Countdown seconds | `number` | `60` |
| `captchaTextRender` | Custom timer text | `(timing: boolean, count: number) => ReactNode` | - |
| `phoneName` | Phone field name (auto-inject phone value) | `string` | - |

```tsx
<ProFormCaptcha
  fieldProps={{ size: 'large', prefix: <MailTwoTone /> }}
  captchaProps={{ size: 'large' }}
  phoneName="phone"
  name="captcha"
  rules={[{ required: true, message: 'Enter captcha' }]}
  onGetCaptcha={async (phone) => {
    await sendCaptcha(phone);
    message.success(`Captcha sent to ${phone}`);
  }}
/>
```

---

## ProFormList

Dynamic form list (add/remove rows). See: https://procomponents.ant.design/en-US/components/group

Key props: `name`, `label`, `initialValue`, `creatorButtonProps`, `creatorRecord`, `actionRender`, `itemRender`, `min`, `max`, `copyIconProps`, `deleteIconProps`.

```tsx
<ProFormList name="users" label="Users" creatorButtonProps={{ creatorButtonText: 'Add User' }}>
  <ProFormText name="name" label="Name" />
  <ProFormText name="email" label="Email" />
</ProFormList>
```

---

## ProFormDependency

Conditional rendering based on other field values. See: https://procomponents.ant.design/en-US/components/dependency

```tsx
<ProFormDependency name={['name']}>
  {({ name }) => {
    return (
      <ProFormSelect
        label={`Contract with ${name}`}
        name="type"
        options={[{ label: 'Option A', value: 'a' }]}
      />
    );
  }}
</ProFormDependency>
```

Values received are already transformed (via `transform`). Use `form` (second param) to get raw values.

---

## ModalForm / DrawerForm

Form in a Modal or Drawer. See: https://procomponents.ant.design/en-US/components/modal-form

```tsx
import { ModalForm, DrawerForm } from '@ant-design/pro-components';

<ModalForm
  title="New Item"
  trigger={<Button type="primary">New</Button>}
  onFinish={async (values) => {
    await saveData(values);
    return true;  // close modal
  }}
  modalProps={{ destroyOnClose: true }}
>
  <ProFormText name="name" label="Name" />
</ModalForm>

<DrawerForm
  title="Edit"
  trigger={<Button>Edit</Button>}
  drawerProps={{ destroyOnClose: true }}
  onFinish={async (values) => { ... return true; }}
>
  <ProFormText name="name" label="Name" />
</DrawerForm>
```

Key ModalForm props: `trigger`, `open`, `onOpenChange`, `modalProps`, `submitTimeout`, `width`.
Key DrawerForm props: `trigger`, `open`, `onOpenChange`, `drawerProps`, `width`.
Both return `true` from `onFinish` to close, `false` to keep open.

---

## StepsForm

Multi-step form. See: https://procomponents.ant.design/en-US/components/steps-form

```tsx
import { StepsForm } from '@ant-design/pro-components';

<StepsForm
  onFinish={async (values) => {
    // values = merged values from all steps
    await saveData(values);
  }}
>
  <StepsForm.StepForm name="step1" title="Step 1">
    <ProFormText name="name" label="Name" />
  </StepsForm.StepForm>
  <StepsForm.StepForm name="step2" title="Step 2">
    <ProFormSelect name="type" label="Type" options={[...]} />
  </StepsForm.StepForm>
</StepsForm>
```

---

## QueryFilter / LightFilter

Compact filter forms. See: https://procomponents.ant.design/en-US/components/query-filter

```tsx
import { QueryFilter, LightFilter } from '@ant-design/pro-components';

// Query filter (horizontal search bar):
<QueryFilter onFinish={async (values) => { ... }}>
  <ProFormText name="name" label="Name" />
  <ProFormSelect name="status" label="Status" options={[...]} />
</QueryFilter>

// Light filter (popover-style compact):
<LightFilter onFinish={async (values) => { ... }}>
  <ProFormText name="name" label="Name" />
  <ProFormSelect name="status" label="Status" options={[...]} />
</LightFilter>
```

QueryFilter key props: `defaultCollapsed`, `collapsed`, `onCollapse`, `split`, `span`, `labelWidth`, `searchGutter`.

---

## ProCard

Card layout component. See: https://procomponents.ant.design/en-US/components/card

```tsx
import { ProCard } from '@ant-design/pro-components';

// Basic:
<ProCard title="Title" bordered headerBordered>Content</ProCard>

// Tabs:
<ProCard tabs={{ type: 'card' }}>
  <ProCard.TabPane key="tab1" tab="Tab 1">Content 1</ProCard.TabPane>
  <ProCard.TabPane key="tab2" tab="Tab 2">Content 2</ProCard.TabPane>
</ProCard>

// Split layout:
<ProCard split="vertical">
  <ProCard colSpan="30%">Left</ProCard>
  <ProCard>Right</ProCard>
</ProCard>

// Grid layout:
<ProCard gutter={[16, 16]} wrap>
  <ProCard colSpan={8}>1</ProCard>
  <ProCard colSpan={8}>2</ProCard>
  <ProCard colSpan={8}>3</ProCard>
</ProCard>

// Collapsible:
<ProCard title="Collapsible" collapsible defaultCollapsed>Content</ProCard>
```

Key props: `title`, `subTitle`, `extra`, `bordered`, `headerBordered`, `ghost`, `gutter`, `wrap`, `colSpan`, `split`, `tabs`, `collapsible`, `defaultCollapsed`, `loading`, `hoverable`, `direction`, `actions`.
