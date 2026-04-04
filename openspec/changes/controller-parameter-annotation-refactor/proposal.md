## Why

框架规范要求 `@Parameter` 注解应放在 Controller 方法上，通过 `name` 属性指向参数名，必填时加 `required = true`。当前 Phase 1/2/3/4 的 Controller 代码中，`@Parameter` 注解仍直接写在参数上，违反框架规范，影响代码一致性和可维护性。

## What Changes

- 重构 10 个 Controller 文件中的 `@Parameter` 注解
- 将 `@Parameter` 从参数位置提升到方法位置
- 使用 `@Parameter(name = "参数名", description = "描述", required = true)` 格式
- 非必填参数省略 `required` 属性

## Capabilities

### New Capabilities

- `controller-parameter-annotation`: 定义 Controller 方法参数注解规范，统一 `@Parameter` 使用方式

### Modified Capabilities

- 无现有 spec 能力被修改（此次重构不改变功能行为）

## Impact

### 受影响代码

| Phase | Controller | 文件路径 |
|-------|------------|----------|
| P1 | BaseDeptController | `sc-cloud-module-basic-server/.../base/controller/admin/` |
| P1 | BaseOrgRoleController | `sc-cloud-module-basic-server/.../base/controller/admin/` |
| P2 | UEmployeeController | `sc-cloud-module-basic-server/.../base/controller/admin/` |
| P2 | UEmployeeDoubleDutyController | `sc-cloud-module-basic-server/.../base/controller/admin/` |
| P2 | UserLoginController | `sc-cloud-module-basic-server/.../user/auth/controller/admin/` |
| P3 | BaseCompanyJobController | `sc-cloud-module-basic-server/.../base/controller/admin/` |
| P3 | BaseCompanyRankLevelController | `sc-cloud-module-basic-server/.../base/controller/admin/` |
| P3 | BaseCompanyPostController | `sc-cloud-module-basic-server/.../base/controller/admin/` |
| P4 | GDictController | `sc-cloud-module-basic-server/.../dict/controller/admin/` |
| P4 | BeDimensionalStrandController | `sc-cloud-module-basic-server/.../dim/controller/admin/` |

### 涉及文件数

- 10 个 Controller Java 文件
- 约 52 处 `@Parameter` 注解需要重构
