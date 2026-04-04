## ADDED Requirements

### Requirement: @Parameter 注解必须放在方法上

Controller 中的 `@Parameter` 注解 SHALL 放在方法级别，通过 `name` 属性指向参数名。

#### Scenario: @RequestParam 参数使用 @Parameter 注解
- **WHEN** Controller 方法有 `@RequestParam` 参数
- **THEN** `@Parameter` 注解应放在方法上，使用 `name` 属性指向参数名

#### Scenario: @PathVariable 参数使用 @Parameter 注解
- **WHEN** Controller 方法有 `@PathVariable` 参数
- **THEN** `@Parameter` 注解应放在方法上，使用 `name` 属性指向参数名

### Requirement: required 属性用于标识必填参数

`@Parameter` 的 `required` 属性 SHALL 用于标识参数是否为必填。

#### Scenario: 必填参数设置 required = true
- **WHEN** 参数有 `@NotBlank` 或 `@NotNull` 校验
- **THEN** `@Parameter` SHALL 设置 `required = true`

#### Scenario: 非必填参数省略 required
- **WHEN** 参数标记为 `required = false`
- **THEN** `@Parameter` SHALL 省略 `required` 属性

### Requirement: @Parameter 注解格式规范

`@Parameter` 注解 SHALL 只包含 `name`、`description`、`required` 三个属性。

#### Scenario: 完整格式示例
```java
@Parameter(name = "deptId", description = "部门ID", required = true)
public Result<Void> delete(
        @RequestParam("deptId")
        @NotBlank(message = "部门ID不能为空") String deptId) {
```

#### Scenario: 非必填参数示例
```java
@Parameter(name = "parentId", description = "上级部门ID")
public Result<List> getTree(
        @RequestParam(name = "parentId", required = false) String parentId) {
```

### Requirement: @Operation 和 @Parameter 注解顺序

`@Parameter` 注解 SHALL 紧跟在 `@Operation` 注解之后。

#### Scenario: 注解顺序
- **WHEN** Controller 方法有多个注解
- **THEN** 注解顺序 SHALL 是：`@Operation` → `@Parameter` → 方法签名
