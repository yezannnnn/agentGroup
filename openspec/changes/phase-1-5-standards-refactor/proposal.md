# Phase 1-5 编码规范全面重构提案

## 概述

根据 `skills/java-backend/coding-standards/SKILL.md` 规范，对 Phase 1-5 所有已完成代码进行全面重构，修复规范违规问题，统一方法命名，确保代码质量。

## 背景

Phase 1-5 开发过程中，代码存在若干规范违规问题：

- **Phase 4 复审反馈**: GDictServiceImpl LambdaQueryWrapperX 违规导入、update方法重复调用addHistory
- **Phase 5 审查反馈**: 流水号删除接口缺失、项目备案名字段缺失
- **规范检查发现**: 类级别缺少 `@Transactional(readOnly = true)`、SysResult包路径不一致、**方法命名非标准**

## 目标

1. **修复所有 🔴 必须修复问题** - 架构违规、安全漏洞、功能缺失
2. **修复所有 🟡 应当修复问题** - 提升代码质量和一致性
3. **统一方法命名** - 按 SKILL.md L92 规范重命名所有模块
4. **建立规范执行基线** - 确保后续开发遵循规范

## 范围

### 涉及模块

| Phase | 模块 | 文件数 | 主要问题 |
|-------|------|--------|----------|
| Phase 1 | 部门管理、角色管理 | 6 | 类级别@Transactional、方法命名非标准 |
| Phase 2 | 员工管理(含登录) | 8 | 类级别@Transactional、方法命名非标准 |
| Phase 3 | 职务/职级/岗位 | 6 | 类级别@Transactional |
| Phase 4 | 数据字典、维度管理 | 4 | LambdaQueryWrapperX违规、addHistory重复 |
| Phase 5 | 流水号、项目管理 | 4 | delete方法缺失、备案名字段 |

### 代码目录

```
D:\git_desun\sc-cloud\cloud-backend\sc-cloud-module-basic\
├── sc-cloud-module-basic-server\src\main\java\com\sc\cloud\basic\
│   ├── base\service\           (部门、角色、员工服务接口)
│   ├── base\service\impl\     (部门、角色、员工服务实现)
│   ├── base\controller\admin\ (部门、角色、员工控制器)
│   ├── dict\service\impl\     (数据字典服务)
│   ├── dim\service\impl\      (维度管理服务)
│   ├── serial\service\impl\   (流水号服务)
│   └── project\service\impl\  (项目管理服务)
└── sc-cloud-protocol\          (项目管理QVO/RVO)
```

## 问题清单

### 🔴 必须修复 (6项)

| # | 问题 | 影响 | 文件 |
|---|------|------|------|
| 1 | LambdaQueryWrapperX 未使用导入 | 架构违规 | GDictServiceImpl.java |
| 2 | update方法重复调用addHistory() | 数据错误 | GDictServiceImpl, BeDimensionalStrandServiceImpl |
| 3 | 缺少租户上下文认证 | 安全漏洞 | GDictServiceImpl |
| 4 | 分页查询返回null | 功能缺失 | GDictServiceImpl |
| 5 | delete方法缺失 | 编译失败 | SerialNumberServiceImpl |
| 6 | 备案名字段缺失 | 功能缺失 | BaseProject Entity |

### 🟡 应当修复 (5项)

| # | 问题 | 影响 | 文件 |
|---|------|------|------|
| 7 | 类级别缺少@Transactional(readOnly=true) | 事务边界 | SerialNumberService, BaseProjectService |
| 8 | SysResult包路径不一致 | 维护性 | GDictServiceImpl |
| 9 | GlobalHeaderThreadLocal调用不一致 | 一致性 | 多个Service |
| 10 | 方法命名非标准 | 一致性 | 所有Service/Controller |

### 📋 方法命名重构 (SKILL.md L92 规范)

**SKILL.md L92 规范方法命名**:
```
getXxxByPage | getDetailById | getXxx2Xxx | getXxxByXxxId |
processXxxXxxByXxx | transferXxx2Xxx |
getXxxXxxTreeByParent(异步树) | getXxxXxxTreeByAll(同步树) |
addXxxXxx | updateXxxXxx | deleteXxxXxx | saveXxxXxxByAaaXxx | setXxxXxxEnable
```

**当前非标准命名 vs 规范命名对照**:

| 模块 | 当前命名 | 规范命名 |
|------|----------|----------|
| **部门** | getSyncDeptTree | getDeptTreeByAll |
| | getDeptById | getDetailById |
| | addDept | addDept |
| | updateDept | updateDept |
| | deleteDept | deleteDept |
| | setDeptEnabled | setDeptEnabled |
| **角色** | getSyncRoleTree | getRoleTreeByAll |
| | getRoleById | getDetailById |
| | addRole | addRole |
| | updateRole | updateRole |
| | deleteRole | deleteRole |
| | setRoleEnabled | setRoleEnabled |
| | addRoleGroup | addRoleGroup |
| | updateRoleGroup | updateRoleGroup |
| | deleteRoleGroup | deleteRoleGroup |
| **员工** | getByPage | getByPage ✅ |
| | getEmployeeDetail | getDetailById |
| | addEmployee | addEmployee |
| | updateEmployee | updateEmployee |
| | deleteEmployee | deleteEmployee |
| | setEmployeeEnabled | setEmployeeEnabled |
| | resetPassword | resetPassword ✅ |
| **职务** | pageByQo | getByPage ✅ |
| | getById | getDetailById ✅ |
| | add | addJob |
| | update | updateJob |
| | delete | deleteJob |
| | setEnabled | setJobEnabled |
| **职级** | pageByQo | getByPage ✅ |
| | getById | getDetailById ✅ |
| | add | addRankLevel |
| | update | updateRankLevel |
| | delete | deleteRankLevel |
| | setEnabled | setRankLevelEnabled |
| **岗位** | pageByQo | getByPage ✅ |
| | getById | getDetailById ✅ |
| | add | addPost |
| | update | updatePost |
| | delete | deletePost |
| | setEnabled | setPostEnabled |
| **字典** | getById | getDetailById ✅ |
| | add | addDict |
| | update | updateDict |
| | delete | deleteDict |
| | setEnabled | setDictEnabled |
| | getOptions | getDictOptions |
| **维度** | getById | getDetailById ✅ |
| | add | addDim |
| | update | updateDim |
| | delete | deleteDim |
| | setEnabled | setDimEnabled |
| | getSyncTree | getDimTreeByAll |
| **流水号** | getPage | getByPage ✅ |
| | getById | getDetailById ✅ |
| | add | addSerial |
| | update | updateSerial |
| | setEnabled | setSerialEnabled |
| **项目** | getPage | getByPage ✅ |
| | getById | getDetailById ✅ |
| | add | addProject |
| | update | updateProject |
| | delete | deleteProject |
| | setEnabled | setProjectEnabled |

## 变更类型

- [x] 修复Bug
- [ ] 新功能
- [x] 重构
- [ ] 文档更新

## 优先级

**P0** - 必须完成才能通过审查

## 风险评估

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 修改Service影响现有功能 | 中 | 先备份git分支，review验证 |
| addHistory语义变更 | 高 | 确认原意后修改，review验证 |
| 类级别事务注解影响 | 中 | 确保无嵌套事务问题 |
| 方法重命名影响API | 高 | Controller URL保持不变，只改Java方法名 |

## 依赖项

- 依赖规范文档: `skills/java-backend/coding-standards/SKILL.md`
- 依赖审查反馈: `shared/reviews/2026-04-01-phase5-review.md`

## 审核人

- 凯尔 (代码审查)

## 状态

- [x] 已提案
- [ ] 已设计
- [ ] 已实现
- [ ] 已审查
- [ ] 已合并
