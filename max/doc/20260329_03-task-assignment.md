# 任务分配文档 - 基础模块开发

> 日期: 2026-03-29
> 版本: v1.2（含表结构）
> 状态: 待分配

---

## 一、模块汇总

| 序号 | 模块 | 表 | 前端应用 | 负责人 | 优先级 | 依赖 |
|------|------|-----|----------|--------|--------|------|
| M1 | 部门管理 | base_department | cloud-base | | P0 | 无 |
| M2 | 员工管理 | u_employee_base, u_employee_double_duty | cloud-base | | P0 | M1 |
| M3 | 角色管理 | base_org_role | cloud-base | | P0 | 无 |
| M4 | 基础数据 | base_company_job, base_company_rank_level, base_company_post | cloud-base | | P1 | 无 |
| M5 | 数据字典 | g_dict | cloud-form | | P1 | 无 |
| M6 | 维度管理 | be_dimensional_strand | cloud-form | | P1 | 无 |
| M7 | 流水号 | be_serial_number | cloud-form | | P2 | 无 |
| M8 | 项目管理 | base_project | cloud-form | | P2 | 无 |

---

## 二、M1 - 部门管理

**表**: base_department

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| dept_id | varchar(32) PK | 部门ID |
| company_id | varchar(32) | 公司ID |
| dept_code | varchar(20) | 部门代码 |
| dept_name | varchar(30) | 部门名称 |
| parent_dept_id | varchar(32) | 上级部门ID |
| dept_type | varchar(20) | 组织类型【字典】 |
| dept_level | varchar(2) | 组织级别【字典】 |
| dept_nature | varchar(2) | 组织属性【字典】 |
| dept_manager | varchar(32) | 组织负责人 |
| dept_leadership | varchar(32) | 组织分管领导 |
| sortno | int | 排序号，默认1 |
| enabled | char(1) | 是否启用，默认1 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**:
- 部门树形展示（支持多级）
- 部门列表（按父部门筛选）
- 新增/编辑/删除部门
- 启用/禁用

**前端页面**: cloud-base/pages/dept/

**后端模块**: sc-cloud-module-basic

**验收标准**:
- [ ] 部门树正常显示，支持4级以上层级
- [ ] 删除时有子部门时提示先删除子部门
- [ ] 部门名称+公司ID唯一性校验

---

## 三、M2 - 员工管理

**主表**: u_employee_base

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| user_base_id | varchar(32) PK | 员工ID |
| user_id | varchar(32) | 用户ID |
| company_id | varchar(32) | 所属公司 |
| user_name | varchar(50) | 用户名称 |
| account_num | varchar(32) | 登录账号 |
| account_pwd | varchar(128) | 登录密码 |
| idcard_number | varchar(256) | 身份证号【SM4加密】 |
| phone_number | varchar(128) | 手机号【SM4加密】 |
| email_addr | varchar(100) | 邮箱地址【SM4加密】 |
| dept_id | varchar(32) | 所属部门(主) |
| first_dept_id | varchar(32) | 一级部门(主) |
| job_num | varchar(32) | 工号 |
| base_status | char(1) | 员工状态【0审核中/1正常/4待激活/9禁用】 |
| data_level | int | 数据级别，0-100 |
| pwd_valid_day | int | 密码有效天数，默认90 |
| last_change_date | datetime | 最后修改密码日期 |
| use_external | char(1) | 是否外部单位，默认0 |
| is_default_pwd | char(1) | 是否默认密码，默认1 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**唯一索引**: user_id + company_id

---

**从表**: u_employee_double_duty（员工兼岗）

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| duty_id | varchar(32) PK | 记录ID |
| user_base_id | varchar(32) | 员工ID |
| user_id | varchar(32) | 用户ID |
| company_id | varchar(32) | 所属公司 |
| dept_org_id | varchar(32) | 组织公司 |
| dept_id | varchar(32) | 组织部门 |
| first_dept_id | varchar(32) | 一级部门 |
| base_post_id | varchar(32) | 岗位 |
| base_job_id | varchar(32) | 职务 |
| rank_level_id | varchar(32) | 职级 |
| main_post | char(1) | 是否主岗，默认0【0否/1是】 |
| enabled | char(1) | 是否启用，默认1 |
| remarks | varchar(300) | 备注 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**:
- 员工列表（分页、筛选）
- 新增/编辑/删除员工
- 启用/禁用
- 重置密码
- 员工详情（含兼岗管理Tab）
- 登录认证（账号+密码 → JWT Token）
- 兼岗CRUD（一个员工只能有一个主岗）

**前端页面**: cloud-base/pages/employee/

**后端模块**: sc-cloud-module-basic

**验收标准**:
- [ ] 员工账号唯一性校验
- [ ] 密码加密存储
- [ ] 手机号/身份证/邮箱后端解密返回
- [ ] 登录返回 JWT Token
- [ ] Token无效时返回401

---

## 四、M3 - 角色管理

**表**: base_org_role

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| role_id | varchar(32) PK | 角色ID |
| role_name | varchar(32) | 角色名称 |
| company_id | varchar(32) | 公司ID |
| role_type | char(1) | 角色类型【0角色组/1实际角色】 |
| parent_id | varchar(32) | 上级ID |
| role_desc | varchar(300) | 描述 |
| sortno | int | 排序号，默认1 |
| enabled | char(1) | 是否启用，默认1 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**:
- 角色树（角色组 + 实际角色，两级）
- 角色列表（按角色组筛选）
- 新增/编辑/删除角色/角色组
- 启用/禁用

**前端页面**: cloud-base/pages/role/

**后端模块**: sc-cloud-module-basic

**验收标准**:
- [ ] 角色组和实际角色用图标区分
- [ ] 删除时有子角色时提示先删除子角色
- [ ] 角色名称+公司ID唯一性校验

---

## 五、M4 - 基础数据管理

**表1**: base_company_job（职务）
| 字段 | 类型 | 说明 |
|------|------|------|
| job_id | varchar(32) PK | 职务ID |
| company_id | varchar(32) | 公司ID |
| job_name | varchar(30) | 职务名称 |
| job_code | varchar(20) | 职务代码 |
| dept_id | varchar(32) | 所属部门 |
| job_category | varchar(20) | 职务类别【字典-JobCategory】 |
| remark | varchar(300) | 描述 |
| sortno | int | 排序号，默认1 |
| enabled | char(1) | 是否启用，默认1 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**表2**: base_company_rank_level（职级）
| 字段 | 类型 | 说明 |
|------|------|------|
| rank_level_id | varchar(32) PK | 职级ID |
| company_id | varchar(32) | 公司ID |
| rank_level_name | varchar(30) | 职级名称 |
| rank_level_code | varchar(20) | 职级代码 |
| rank_level_category | varchar(20) | 职级类别【字典-RankLevelCategory】 |
| mapper_group | varchar(20) | 集团级别映射 |
| remark | varchar(300) | 描述 |
| sortno | int | 排序号，默认1 |
| enabled | char(1) | 是否启用，默认1 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**表3**: base_company_post（岗位）
| 字段 | 类型 | 说明 |
|------|------|------|
| post_id | varchar(32) PK | 岗位ID |
| company_id | varchar(32) | 公司ID |
| post_name | varchar(30) | 岗位名称 |
| post_code | varchar(20) | 岗位代码 |
| post_category | varchar(20) | 岗位类别【字典-PostCategory】 |
| remark | varchar(300) | 描述 |
| sortno | int | 排序号，默认1 |
| enabled | char(1) | 是否启用，默认1 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**: 三者各自独立实现相同功能
- 列表（分页、筛选）
- 新增/编辑/删除
- 启用/禁用
- 编码唯一性校验

**前端页面**:
- cloud-base/pages/job/
- cloud-base/pages/rank-level/
- cloud-base/pages/post/

**后端模块**: sc-cloud-module-basic

---

## 六、M5 - 数据字典

**表**: g_dict

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| dict_id | varchar(32) PK | 字典ID |
| dict_value | varchar(200) | 字典值 |
| dict_name | varchar(50) | 字典名称 |
| dict_desc | varchar(200) | 字典描述 |
| parent_id | varchar(32) | 父级字典ID |
| dict_type | char(1) | 字典分类【0系统分类/1字典类型/2字典值】 |
| dict_color | varchar(10) | 字典颜色 |
| order_num | int | 字典项排序号，默认1 |
| enabled | char(1) | 是否启用，默认1 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**:
- 字典类型列表（dict_type=1）
- 字典值列表（按类型筛选，dict_type=2）
- 新增/编辑/删除字典类型/字典值
- 启用/禁用
- 提供下拉选项接口（给表单组件用）

**前端页面**: cloud-form/pages/dict/

**后端模块**: sc-cloud-module-form

**验收标准**:
- [ ] 字典值删除前检查业务表引用

---

## 七、M6 - 维度管理

**表**: be_dimensional_strand

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| dim_id | varchar(32) PK | 维度ID |
| company_id | varchar(32) | 公司ID |
| dim_name | varchar(100) | 维度分类名称 |
| dim_code | varchar(32) | 维度分类编码 |
| parent_id | varchar(32) | 上级维度 |
| define_type | char(1) | 数据类型【0分组/1维度分类/2维度数据】 |
| use_system | char(1) | 是否系统维度，默认0【0否/1是】 |
| dim_color | varchar(32) | 维度颜色代码 |
| sortno | int | 排序号 |
| enabled | char(1) | 是否启用，默认1【0禁用/1启用】 |
| remarks | varchar(300) | 备注 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**:
- 维度树（分组→分类→数据，三级树形）
- 维度列表（按父节点筛选）
- 新增分组/分类/维度数据
- 编辑/删除
- 启用/禁用
- 提供下拉选项接口（给表单组件用）

**前端页面**: cloud-form/pages/dim/

**后端模块**: sc-cloud-module-form

**验收标准**:
- [ ] 系统维度不可删除
- [ ] 有子节点时不可删除

---

## 八、M7 - 流水号管理

**表**: be_serial_number

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| serial_id | varchar(32) PK | 序列ID |
| company_id | varchar(32) | 公司ID |
| serial_name | varchar(50) | 业务名称 |
| serial_code | varchar(50) | 业务CODE |
| serial_prefix | varchar(10) | 流水号前缀 |
| date_format | varchar(30) | 日期格式【空则不使用日期】 |
| cur_date | varchar(30) | 当前日期 |
| serial_len | int | 流水号长度 |
| join_symbol | char(1) | 连接符号 |
| cur_value | int | 当前值，默认0【自动+1】 |
| reset_strategy | varchar(10) | 重置策略【每日-day/每月-month/每年-year】 |
| sortno | int | 排序号 |
| enabled | char(1) | 是否启用，默认1【0禁用/1启用】 |
| remarks | varchar(300) | 备注 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**:
- 流水号规则列表
- 新增/编辑/删除规则
- 启用/禁用
- 预览格式
- 业务接口获取下一个流水号（支持并发，Redis锁）

**前端页面**: cloud-form/pages/serial/

**后端模块**: sc-cloud-module-form

**验收标准**:
- [ ] 并发获取流水号时数字不重复
- [ ] 支持每日/每月/每年重置

---

## 八、M8 - 项目管理

**表**: base_project

**表结构**:
| 字段 | 类型 | 说明 |
|------|------|------|
| project_id | varchar(32) PK | 项目ID |
| company_id | varchar(32) | 公司ID |
| project_name | varchar(50) | 项目名称 |
| project_record_name | varchar(50) | 项目备案名 |
| project_num | varchar(30) | 项目编号 |
| build_type | varchar(30) | 建筑形态【字典-ProjectBuildType】 |
| business_type | varchar(30) | 业务类别【字典-ProjectBusinessType】 |
| addr | varchar(200) | 项目地址 |
| longitude | decimal(6,6) | 经度 |
| latitude | decimal(6,6) | 纬度 |
| area_code | varchar(10) | 所在地区代码 |
| project_rematk | varchar(500) | 项目介绍 |
| sortno | int | 排序号 |
| enabled | char(1) | 是否启用，默认1【0禁用/1启用】 |
| create_user | varchar(32) | 创建人 |
| create_time | datetime | 创建时间 |
| update_user | varchar(32) | 最后操作人 |
| update_time | datetime | 最后操作时间 |

**功能清单**:
- 项目列表（分页、地区筛选）
- 新增/编辑/删除项目
- 启用/禁用
- 项目详情查看

**前端页面**: cloud-form/pages/project/

**后端模块**: sc-cloud-module-basic

**验收标准**:
- [ ] 项目编号唯一性校验

---

## 九、开发顺序

```
Phase 1 (P0) - 核心框架
├── M1 部门管理
└── M3 角色管理

Phase 2 (P0) - 认证与员工
└── M2 员工管理（依赖M1）

Phase 3 (P1) - 基础数据
└── M4 基础数据（职务/职级/岗位）

Phase 4 (P1) - 表单数据
├── M5 数据字典
└── M6 维度管理

Phase 5 (P2) - 扩展功能
├── M7 流水号
└── M8 项目管理
```

---

## 十、任务分配表

| 模块 | 后端开发 | 前端开发 | 验收测试 |
|------|----------|----------|----------|
| M1 部门管理 | | | |
| M2 员工管理 | | | |
| M3 角色管理 | | | |
| M4 基础数据 | | | |
| M5 数据字典 | | | |
| M6 维度管理 | | | |
| M7 流水号 | | | |
| M8 项目管理 | | | |

---

## 十一、公共需求

**后端**:
- SM4加密工具（密码/身份证/手机号/邮箱）
- JWT Token工具
- 密码加密工具
- 统一响应格式
- 实体基类（含审计字段）

**前端**:
- 字典/维度下拉选项接口调用
- 树形表格组件

---

## 十二、数据库准备

| 序号 | 表名 | 状态 | 备注 |
|------|------|------|------|
| 1 | base_department | 待创建 | |
| 2 | u_employee_base | 待创建 | |
| 3 | u_employee_double_duty | 待创建 | |
| 4 | base_org_role | 待创建 | |
| 5 | base_company_job | 待创建 | |
| 6 | base_company_rank_level | 待创建 | |
| 7 | base_company_post | 待创建 | |
| 8 | g_dict | 待创建 | |
| 9 | be_dimensional_strand | 待创建 | |
| 10 | be_serial_number | 待创建 | |
| 11 | base_project | 待创建 | |

---

## 文档更新记录

| 版本 | 日期 | 修改内容 |
|------|------|----------|
| v1.0 | 2026-03-29 | 初始版本（包含代码设计） |
| v1.1 | 2026-03-29 | 精简版，移除代码和设计内容 |
| v1.2 | 2026-03-29 | 补充完整表结构信息 |
