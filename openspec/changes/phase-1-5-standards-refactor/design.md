# Phase 1-5 编码规范重构设计方案

## 概述

本文档描述 Phase 1-5 代码重构的具体实施方案。

---

## 一、🔴 必须修复问题

### 1. GDictServiceImpl - LambdaQueryWrapperX 违规导入

**修复**: 移除 `import com.shengcheng.framework.springboot.core.query.LambdaQueryWrapperX;`

---

### 2. update方法重复调用 addHistory()

**修复**: 移除第79行 `addHistory(exist)`，只保留 `addHistory(entity)`

---

### 3. GDictServiceImpl - 缺少租户上下文认证

**修复**: 在所有方法开头添加 `GlobalHeaderThreadLocal.getOrException();`

---

### 4. GDictServiceImpl - 分页查询未实现

**修复**: 实现 pageByQo() 返回 `PageRVO<GDictRVO>`

---

### 5. SerialNumberServiceImpl - 缺少 delete 方法

**修复**: 添加 delete(String serialId) 方法实现

---

### 6. BaseProject - 备案名字段缺失

**修复**: 添加 projectFiling 字段到 Entity/QVO/RVO/SQL

---

## 二、🟡 应当修复问题

### 7. 类级别缺少 @Transactional(readOnly = true)

**修复**: 在 SerialNumberServiceImpl 和 BaseProjectServiceImpl 添加类级别注解

---

### 8. SysResult 包路径不一致

**修复**: 统一使用 `com.sc.cloud.common.consts.SysResult`

---

### 9. GlobalHeaderThreadLocal 调用统一

**修复**: 所有方法添加身份认证

---

## 三、方法命名重构 (SKILL.md L92)

### 10. 重命名规则

**原则**:
1. **接口方法名** 按 `addXxxXxx`/`updateXxxXxx`/`deleteXxxXxx`/`setXxxXxxEnable` 模式
2. **Controller方法名** 与Service保持一致
3. **树查询** 统一为 `getXxxTreeByAll`/`getXxxTreeByParent`
4. **详情查询** 统一为 `getDetailById`
5. **分页查询** 统一为 `getByPage`

### 各模块重命名对照表

#### 部门管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IBaseDeptService | getSyncDeptTree | getDeptTreeByAll |
| IBaseDeptService | getDeptById | getDetailById |
| IBaseDeptService | addDept | addDept |
| IBaseDeptService | updateDept | updateDept |
| IBaseDeptService | deleteDept | deleteDept |
| IBaseDeptService | setDeptEnabled | setDeptEnabled |

#### 角色管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IBaseRoleService | getSyncRoleTree | getRoleTreeByAll |
| IBaseRoleService | getRoleById | getDetailById |
| IBaseRoleService | addRole | addRole |
| IBaseRoleService | updateRole | updateRole |
| IBaseRoleService | deleteRole | deleteRole |
| IBaseRoleService | setRoleEnabled | setRoleEnabled |
| IBaseRoleService | addRoleGroup | addRoleGroup |
| IBaseRoleService | updateRoleGroup | updateRoleGroup |
| IBaseRoleService | deleteRoleGroup | deleteRoleGroup |

#### 员工管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IUEmployeeService | getByPage | getByPage |
| IUEmployeeService | getEmployeeDetail | getDetailById |
| IUEmployeeService | addEmployee | addEmployee |
| IUEmployeeService | updateEmployee | updateEmployee |
| IUEmployeeService | deleteEmployee | deleteEmployee |
| IUEmployeeService | setEmployeeEnabled | setEmployeeEnabled |
| IUEmployeeService | resetPassword | resetPassword |

#### 职务管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IBaseCompanyJobService | pageByQo | getByPage |
| IBaseCompanyJobService | getById | getDetailById |
| IBaseCompanyJobService | add | addJob |
| IBaseCompanyJobService | update | updateJob |
| IBaseCompanyJobService | delete | deleteJob |
| IBaseCompanyJobService | setEnabled | setJobEnabled |

#### 职级管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IBaseCompanyRankLevelService | pageByQo | getByPage |
| IBaseCompanyRankLevelService | getById | getDetailById |
| IBaseCompanyRankLevelService | add | addRankLevel |
| IBaseCompanyRankLevelService | update | updateRankLevel |
| IBaseCompanyRankLevelService | delete | deleteRankLevel |
| IBaseCompanyRankLevelService | setEnabled | setRankLevelEnabled |

#### 岗位管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IBaseCompanyPostService | pageByQo | getByPage |
| IBaseCompanyPostService | getById | getDetailById |
| IBaseCompanyPostService | add | addPost |
| IBaseCompanyPostService | update | updatePost |
| IBaseCompanyPostService | delete | deletePost |
| IBaseCompanyPostService | setEnabled | setPostEnabled |

#### 字典管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IGDictService | pageByQo | getByPage |
| IGDictService | getById | getDetailById |
| IGDictService | add | addDict |
| IGDictService | update | updateDict |
| IGDictService | delete | deleteDict |
| IGDictService | setEnabled | setDictEnabled |
| IGDictService | getOptions | getDictOptions |

#### 维度管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IBeDimensionalStrandService | pageByQo | getByPage |
| IBeDimensionalStrandService | getById | getDetailById |
| IBeDimensionalStrandService | add | addDim |
| IBeDimensionalStrandService | update | updateDim |
| IBeDimensionalStrandService | delete | deleteDim |
| IBeDimensionalStrandService | setEnabled | setDimEnabled |
| IBeDimensionalStrandService | getSyncTree | getDimTreeByAll |

#### 流水号管理

| 位置 | 当前 | 改为 |
|------|------|------|
| ISerialNumberService | getPage | getByPage |
| ISerialNumberService | getById | getDetailById |
| ISerialNumberService | add | addSerial |
| ISerialNumberService | update | updateSerial |
| ISerialNumberService | setEnabled | setSerialEnabled |

#### 项目管理

| 位置 | 当前 | 改为 |
|------|------|------|
| IBaseProjectService | getPage | getByPage |
| IBaseProjectService | getById | getDetailById |
| IBaseProjectService | add | addProject |
| IBaseProjectService | update | updateProject |
| IBaseProjectService | delete | deleteProject |
| IBaseProjectService | setEnabled | setProjectEnabled |

---

## 四、重构执行顺序

```
阶段一: Bug修复 (6项)
├── T1: GDictServiceImpl - LambdaQueryWrapperX + addHistory + 租户认证 + 分页
├── T2: BeDimensionalStrandServiceImpl - addHistory重复
├── T3: SerialNumberServiceImpl - delete方法 + @Transactional
└── T4: BaseProject - projectFiling字段 + @Transactional

阶段二: 命名重构 (10个模块)
├── T5: 部门管理 - 6个方法重命名
├── T6: 角色管理 - 6个方法重命名
├── T7: 员工管理 - 5个方法重命名
├── T8: 职务管理 - 6个方法重命名
├── T9: 职级管理 - 6个方法重命名
├── T10: 岗位管理 - 6个方法重命名
├── T11: 字典管理 - 7个方法重命名
├── T12: 维度管理 - 7个方法重命名
├── T13: 流水号管理 - 5个方法重命名
└── T14: 项目管理 - 6个方法重命名
```

---

## 五、验收标准

### 🔴 必须通过

- [ ] GDictServiceImpl 不包含 LambdaQueryWrapperX 导入
- [ ] update 方法只调用一次 addHistory
- [ ] 所有写操作方法有 GlobalHeader 认证
- [ ] 分页查询返回 PageRVO 而非 null
- [ ] SerialNumberServiceImpl 有 delete 方法
- [ ] BaseProject 有 projectFiling 字段

### 🟡 应当通过

- [ ] SerialNumberServiceImpl 和 BaseProjectServiceImpl 有类级别 @Transactional
- [ ] 所有 Service 使用统一的 SysResult 包

### 📋 命名规范通过

- [ ] 所有 Service/Controller 方法名符合 SKILL.md L92 规范
- [ ] addXxxXxx/updateXxxXxx/deleteXxxXxx 模式统一
- [ ] setXxxXxxEnable 模式统一
- [ ] 分页查询 getByPage 统一
- [ ] 详情查询 getDetailById 统一

---

## 六、注意事项

1. **事务边界**: 类级别 `@Transactional(readOnly = true)` 只影响读操作
2. **历史记录**: addHistory 只记录修改后的状态
3. **租户隔离**: g_dict 是系统级数据，但仍需身份认证
4. **Redis清理**: 删除流水号规则时同步清理缓存
5. **API兼容性**: Controller URL保持不变，只改Java方法名
