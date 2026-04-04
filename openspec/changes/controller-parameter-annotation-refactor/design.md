## Context

当前 Phase 1/2/3/4 的 Controller 代码中，`@Parameter` 注解直接写在方法参数上，违反框架规范。

**当前代码示例（违规）：**
```java
public Result<Void> delete(
        @Parameter(description = "部门ID")    // ❌ 在参数上
        @RequestParam("deptId")
        @NotBlank String deptId) { ... }
```

**目标代码示例（合规）：**
```java
@Parameter(name = "deptId", description = "部门ID", required = true)  // ✅ 在方法上
public Result<Void> delete(
        @RequestParam("deptId")
        @NotBlank String deptId) { ... }
```

## Goals / Non-Goals

**Goals:**
- 统一 10 个 Controller 的 `@Parameter` 注解使用方式
- 符合框架规范，提升代码一致性
- 为后续代码审查和新人 onboarding 提供清晰标准

**Non-Goals:**
- 不改变任何接口的 URL、参数名、返回格式
- 不改变任何功能逻辑
- 不修改 Service 层代码

## Decisions

### Decision 1: @Parameter 注解位置

**选择：@Parameter 放在方法上，参数上只保留 @RequestParam/@PathVariable 和校验注解**

```java
// ✅ 正确格式
@Operation(summary = "删除部门")
@Parameter(name = "deptId", description = "部门ID", required = true)
public Result<Void> delete(
        @RequestParam("deptId")
        @NotBlank(message = "部门ID不能为空") String deptId) {
    ...
}
```

### Decision 2: name 属性

**选择：显式指定 name 属性**

```java
@Parameter(name = "deptId", description = "部门ID", required = true)
```

虽然框架可以从参数名自动推断，但显式指定更清晰，便于维护。

### Decision 3: required 属性

**选择：必填参数显式设置 `required = true`，非必填省略**

```java
// 必填
@Parameter(name = "deptId", description = "部门ID", required = true)

// 非必填（省略 required）
@Parameter(name = "parentId", description = "上级ID")
```

判断依据：
- 有 `@NotBlank` / `@NotNull` → `required = true`
- `@RequestParam(name = "xxx", required = false)` → 省略 required

### Decision 4: @PathVariable 同样适用

**选择：@PathVariable 参数也使用相同规则**

```java
@Operation(summary = "设置启用状态")
@Parameter(name = "deptId", description = "部门ID", required = true)
@Parameter(name = "enabled", description = "启用状态【0-禁用，1-启用】", required = true)
public Result<Void> setEnabled(
        @PathVariable("deptId") String deptId,
        @PathVariable("enabled") String enabled) {
    ...
}
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| 修改过程中遗漏某些参数 | 逐个 Controller 彻底检查，确保所有 @Parameter 都已迁移 |
| 编译错误 | 修改后执行 `mvn compile` 验证 |
| Swagger 文档显示异常 | 修改后检查 OpenAPI 文档生成是否正确 |

## 受影响文件清单

| # | Controller | 路径 | @Parameter 数量 |
|---|------------|------|-----------------|
| 1 | BaseDeptController | `.../base/controller/admin/` | 6 |
| 2 | BaseOrgRoleController | `.../base/controller/admin/` | 6 |
| 3 | UEmployeeController | `.../base/controller/admin/` | 6 |
| 4 | UEmployeeDoubleDutyController | `.../base/controller/admin/` | 5 |
| 5 | UserLoginController | `.../user/auth/controller/admin/` | 1 |
| 6 | BaseCompanyJobController | `.../base/controller/admin/` | 5 |
| 7 | BaseCompanyRankLevelController | `.../base/controller/admin/` | 5 |
| 8 | BaseCompanyPostController | `.../base/controller/admin/` | 5 |
| 9 | GDictController | `.../dict/controller/admin/` | 6 |
| 10 | BeDimensionalStrandController | `.../dim/controller/admin/` | 6 |
