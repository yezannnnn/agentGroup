# Phase 1-5 编码规范重构任务清单

## 执行前提

- [x] 已阅读规范文档: `skills/java-backend/coding-standards/SKILL.md`
- [x] 已阅读审查反馈: `shared/reviews/2026-04-01-phase5-review.md`
- [x] 已阅读设计文档: `design.md`

---

## 第一部分：🔴 必须修复问题

### 任务 1: 修复 GDictServiceImpl.java

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\dict\service\impl\GDictServiceImpl.java
```

**任务内容**:

- [ ] **T1.1** 移除违规导入 `LambdaQueryWrapperX`
- [ ] **T1.2** 修复 update() 方法 - 移除重复 `addHistory(exist)` 调用
- [ ] **T1.3** 在 add() 方法添加 `GlobalHeaderThreadLocal.getOrException();`
- [ ] **T1.4** 在 update() 方法添加 `GlobalHeaderThreadLocal.getOrException();`
- [ ] **T1.5** 在 delete() 方法添加 `GlobalHeaderThreadLocal.getOrException();`
- [ ] **T1.6** 在 setEnabled() 方法添加 `GlobalHeaderThreadLocal.getOrException();`
- [ ] **T1.7** 在 getById() 方法添加 `GlobalHeaderThreadLocal.getOrException();`
- [ ] **T1.8** 在 getOptions() 方法添加 `GlobalHeaderThreadLocal.getOrException();`
- [ ] **T1.9** 实现 pageByQo() 方法 - 返回 `PageRVO<GDictRVO>` 而非 null
- [ ] **T1.10** 统一 SysResult 包路径为 `com.sc.cloud.common.consts.SysResult`

**验收标准**:
- [ ] 无 LambdaQueryWrapperX 导入
- [ ] update() 只调用一次 addHistory
- [ ] 所有方法有 GlobalHeader 认证
- [ ] pageByQo 返回有效分页结果

---

### 任务 2: 修复 BeDimensionalStrandServiceImpl.java

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\dim\service\impl\BeDimensionalStrandServiceImpl.java
```

**任务内容**:

- [ ] **T2.1** 修复 update() 方法 - 移除重复 `addHistory(exist)` 调用

**验收标准**:
- [ ] update() 只调用一次 addHistory

---

### 任务 3: 修复 SerialNumberServiceImpl.java

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\serial\service\impl\SerialNumberServiceImpl.java
```

**任务内容**:

- [ ] **T3.1** 在类级别添加 `@Transactional(readOnly = true)` 注解
- [ ] **T3.2** 添加 delete(String serialId) 方法实现

**验收标准**:
- [ ] 类级别有 @Transactional(readOnly = true)
- [ ] 有 delete 方法实现

---

### 任务 4: 修复 BaseProjectServiceImpl.java + 字段

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\project\
```

**任务内容**:

**BaseProjectServiceImpl.java**:
- [ ] **T4.1** 在类级别添加 `@Transactional(readOnly = true)` 注解

**BaseProject.java**:
- [ ] **T4.2** 添加 `projectFiling` 字段

**BaseProjectH.java**:
- [ ] **T4.3** 添加 `projectFiling` 字段

**BaseProjectQVO.java** (sc-cloud-protocol):
- [ ] **T4.4** 添加 `projectFiling` 字段（带 @JsonIgnore）

**BaseProjectRVO.java** (sc-cloud-protocol):
- [ ] **T4.5** 添加 `projectFiling` 字段

**SQL脚本**:
- [ ] **T4.6** base_project.sql 添加 `project_filing` 字段
- [ ] **T4.7** base_project_h.sql 添加 `project_filing` 字段

**验收标准**:
- [ ] 类级别有 @Transactional(readOnly = true)
- [ ] BaseProject/BaseProjectH 有 projectFiling 字段
- [ ] QVO/RVO 有 projectFiling 字段
- [ ] SQL脚本已更新

---

## 第二部分：📋 方法命名重构 (SKILL.md L92)

### 任务 5: 部门管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\base\
```

**IBaseDeptService.java**:
- [ ] **T5.1** `getSyncDeptTree` → `getDeptTreeByAll`
- [ ] **T5.2** `getDeptById` → `getDetailById`

**BaseDeptServiceImpl.java**:
- [ ] **T5.3** 同步修改方法名

**BaseDeptController.java**:
- [ ] **T5.4** 同步修改Java方法名（URL保持 `/getSyncDeptTree`、`/getDeptById` 等）

**验收标准**:
- [ ] Service方法名符合规范
- [ ] Controller方法名与Service一致
- [ ] URL保持兼容

---

### 任务 6: 角色管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\base\
```

**IBaseRoleService.java**:
- [ ] **T6.1** `getSyncRoleTree` → `getRoleTreeByAll`
- [ ] **T6.2** `getRoleById` → `getDetailById`

**BaseRoleServiceImpl.java**:
- [ ] **T6.3** 同步修改方法名

**BaseOrgRoleController.java**:
- [ ] **T6.4** 同步修改Java方法名（URL保持）

**验收标准**:
- [ ] Service方法名符合规范
- [ ] 角色组方法(addRoleGroup等)保持不变

---

### 任务 7: 员工管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\base\
```

**IUEmployeeService.java**:
- [ ] **T7.1** `getEmployeeDetail` → `getDetailById`
- [ ] **T7.2** `addEmployee` → `addEmployee` (保持)
- [ ] **T7.3** `updateEmployee` → `updateEmployee` (保持)
- [ ] **T7.4** `deleteEmployee` → `deleteEmployee` (保持)
- [ ] **T7.5** `setEmployeeEnabled` → `setEmployeeEnabled` (保持)

**UEmployeeServiceImpl.java**:
- [ ] **T7.6** 同步修改方法名

**UEmployeeController.java**:
- [ ] **T7.7** 同步修改Java方法名

**验收标准**:
- [ ] getEmployeeDetail → getDetailById
- [ ] 分页和重置密码方法保持不变

---

### 任务 8: 职务管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\base\
```

**IBaseCompanyJobService.java**:
- [ ] **T8.1** `pageByQo` → `getByPage`
- [ ] **T8.2** `getById` → `getDetailById`
- [ ] **T8.3** `add` → `addJob`
- [ ] **T8.4** `update` → `updateJob`
- [ ] **T8.5** `delete` → `deleteJob`
- [ ] **T8.6** `setEnabled` → `setJobEnabled`

**BaseCompanyJobServiceImpl.java**:
- [ ] **T8.7** 同步修改方法名

**BaseCompanyJobController.java**:
- [ ] **T8.8** 同步修改Java方法名

**验收标准**:
- [ ] 所有方法名符合 addJob/updateJob/deleteJob/setJobEnabled 模式

---

### 任务 9: 职级管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\base\
```

**IBaseCompanyRankLevelService.java**:
- [ ] **T9.1** `pageByQo` → `getByPage`
- [ ] **T9.2** `getById` → `getDetailById`
- [ ] **T9.3** `add` → `addRankLevel`
- [ ] **T9.4** `update` → `updateRankLevel`
- [ ] **T9.5** `delete` → `deleteRankLevel`
- [ ] **T9.6** `setEnabled` → `setRankLevelEnabled`

**BaseCompanyRankLevelServiceImpl.java**:
- [ ] **T9.7** 同步修改方法名

**BaseCompanyRankLevelController.java**:
- [ ] **T9.8** 同步修改Java方法名

**验收标准**:
- [ ] 所有方法名符合 addRankLevel/updateRankLevel/deleteRankLevel/setRankLevelEnabled 模式

---

### 任务 10: 岗位管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\base\
```

**IBaseCompanyPostService.java**:
- [ ] **T10.1** `pageByQo` → `getByPage`
- [ ] **T10.2** `getById` → `getDetailById`
- [ ] **T10.3** `add` → `addPost`
- [ ] **T10.4** `update` → `updatePost`
- [ ] **T10.5** `delete` → `deletePost`
- [ ] **T10.6** `setEnabled` → `setPostEnabled`

**BaseCompanyPostServiceImpl.java**:
- [ ] **T10.7** 同步修改方法名

**BaseCompanyPostController.java**:
- [ ] **T10.8** 同步修改Java方法名

**验收标准**:
- [ ] 所有方法名符合 addPost/updatePost/deletePost/setPostEnabled 模式

---

### 任务 11: 字典管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\dict\
```

**IGDictService.java**:
- [ ] **T11.1** `pageByQo` → `getByPage`
- [ ] **T11.2** `getById` → `getDetailById`
- [ ] **T11.3** `add` → `addDict`
- [ ] **T11.4** `update` → `updateDict`
- [ ] **T11.5** `delete` → `deleteDict`
- [ ] **T11.6** `setEnabled` → `setDictEnabled`
- [ ] **T11.7** `getOptions` → `getDictOptions`

**GDictServiceImpl.java**:
- [ ] **T11.8** 同步修改方法名

**GDictController.java**:
- [ ] **T11.9** 同步修改Java方法名

**验收标准**:
- [ ] 所有方法名符合 addDict/updateDict/deleteDict/setDictEnabled 模式

---

### 任务 12: 维度管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\dim\
```

**IBeDimensionalStrandService.java**:
- [ ] **T12.1** `pageByQo` → `getByPage`
- [ ] **T12.2** `getById` → `getDetailById`
- [ ] **T12.3** `add` → `addDim`
- [ ] **T12.4** `update` → `updateDim`
- [ ] **T12.5** `delete` → `deleteDim`
- [ ] **T12.6** `setEnabled` → `setDimEnabled`
- [ ] **T12.7** `getSyncTree` → `getDimTreeByAll`

**BeDimensionalStrandServiceImpl.java**:
- [ ] **T12.8** 同步修改方法名

**BeDimensionalStrandController.java**:
- [ ] **T12.9** 同步修改Java方法名

**验收标准**:
- [ ] 所有方法名符合 addDim/updateDim/deleteDim/setDimEnabled 模式
- [ ] 树查询方法为 getDimTreeByAll

---

### 任务 13: 流水号管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\serial\
```

**ISerialNumberService.java**:
- [ ] **T13.1** `getPage` → `getByPage`
- [ ] **T13.2** `getById` → `getDetailById`
- [ ] **T13.3** `add` → `addSerial`
- [ ] **T13.4** `update` → `updateSerial`
- [ ] **T13.5** `setEnabled` → `setSerialEnabled`

**SerialNumberServiceImpl.java**:
- [ ] **T13.6** 同步修改方法名

**SerialNumberController.java**:
- [ ] **T13.7** 同步修改Java方法名

**验收标准**:
- [ ] 所有方法名符合 addSerial/updateSerial/setSerialEnabled 模式

---

### 任务 14: 项目管理方法重命名

**文件路径**:
```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\project\
```

**IBaseProjectService.java**:
- [ ] **T14.1** `getPage` → `getByPage`
- [ ] **T14.2** `getById` → `getDetailById`
- [ ] **T14.3** `add` → `addProject`
- [ ] **T14.4** `update` → `updateProject`
- [ ] **T14.5** `delete` → `deleteProject`
- [ ] **T14.6** `setEnabled` → `setProjectEnabled`

**BaseProjectServiceImpl.java**:
- [ ] **T14.7** 同步修改方法名

**BaseProjectController.java**:
- [ ] **T14.8** 同步修改Java方法名

**验收标准**:
- [ ] 所有方法名符合 addProject/updateProject/deleteProject/setProjectEnabled 模式

---

## 任务依赖关系

```
阶段一 (Bug修复)
├── T1: GDictServiceImpl ────────────────────────────┐
├── T2: BeDimensionalStrandServiceImpl               │
├── T3: SerialNumberServiceImpl                      │
└── T4: BaseProject + 字段                           │

阶段二 (命名重构)
├── T5: 部门管理      ──────────────────────────────┐
├── T6: 角色管理      ──────────────────────────────┤
├── T7: 员工管理      ──────────────────────────────┤
├── T8: 职务管理      ──────────────────────────────┤
├── T9: 职级管理      ──────────────────────────────┤
├── T10: 岗位管理     ──────────────────────────────┤
├── T11: 字典管理     ──────────────────────────────┤
├── T12: 维度管理     ──────────────────────────────┤
├── T13: 流水号管理   ──────────────────────────────┤
└── T14: 项目管理    ───────────────────────────────┘
```

**建议执行顺序**:
1. 先执行 T1-T4 (Bug修复)
2. 再执行 T5-T14 (命名重构)

---

## 验收流程

1. 每个任务完成后执行自检清单 (参照规范 SKILL.md 第十五节)
2. 提交前运行 `git diff` 检查变更
3. 请求凯尔进行代码审查
4. 合并后更新 status.json 状态

---

## 回滚方案

如遇问题，执行以下命令回滚:
```bash
git checkout -- <文件路径>
```

---

## 任务统计

| 阶段 | 任务 | 子任务数 | 主要内容 |
|------|------|----------|----------|
| Bug修复 | T1-T4 | ~16 | LambdaQueryWrapperX、addHistory、delete方法、字段 |
| 命名重构 | T5-T14 | ~70 | 10个模块方法重命名 |
| **总计** | **14** | **~86** | **全面规范重构** |
