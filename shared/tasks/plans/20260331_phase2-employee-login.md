# 技术方案 - Phase 2 员工管理(含登录)

## 1. 需求概述

Phase 2 基于已完成 Phase 1（部门管理 M1、角色管理 M3），开发员工管理模块（M2），包含：
- 员工主表 (u_employee_base) CRUD + 分页查询
- 兼岗表 (u_employee_double_duty) CRUD
- 登录认证（账号+密码 → JWT Token）
- 密码重置功能

**业务规则：**
- R1: 员工账号 (account_num) 唯一
- R2: 密码加密存储 (AES+MD5)
- R3: 手机号/身份证/邮箱 SM4 加密存储，后端解密返回
- R4: 一个员工只能有一个主岗 (main_post='1')

**员工状态 (base_status)：**
- `0` - 审核中
- `1` - 正常
- `4` - 待激活
- `9` - 禁用

---

## 2. 技术选型

| 组件 | 技术 | 说明 |
|------|------|------|
| 框架 | Spring Boot 3.x | 现有项目保持一致 |
| ORM | MyBatis-Plus 3.5+ | 现有项目保持一致 |
| 数据库 | MySQL 8 | 现有项目保持一致 |
| 加密 | SM4-CBC + AES-ECB + MD5 | 使用现有 `EncryptCommon` |
| 分页 | MyBatis-Plus Page | 使用框架封装 |
| 历史表 | 手动写入 H 表 | 与 Phase 1 保持一致 |

**现有工具类复用：**
- `com.sc.cloud.common.secret.EncryptCommon` - SM4/密码加密
- `com.shengcheng.framework.springboot.core.local.GlobalHeaderThreadLocal` - 获取租户ID
- `com.shengcheng.framework.springboot.core.spring.util.DataUtil` - 对象拷贝
- `com.shengcheng.framework.springboot.core.util.TreeBuildUtil` - 树构建（如需）
- `com.shengcheng.framework.springboot.protocol.Result` - 统一响应

---

## 3. 架构设计

```
sc-cloud-module-basic
├── sc-cloud-module-basic-api
│   └── src/main/java/com/sc/cloud/basic/api/
│       └── ApiConstants.java           # 常量定义
│
└── sc-cloud-module-basic-server
    └── src/main/java/com/sc/cloud/basic/
        ├── base/
        │   ├── controller/admin/
        │   │   ├── UEmployeeController.java        # 员工管理
        │   │   └── UEmployeeDoubleDutyController.java  # 兼岗管理
        │   │
        │   ├── entity/
        │   │   ├── UEmployeeBase.java              # 员工主表
        │   │   ├── UEmployeeBaseH.java             # 员工历史表
        │   │   ├── UEmployeeDoubleDuty.java        # 兼岗表
        │   │   └── UEmployeeDoubleDutyH.java       # 兼岗历史表
        │   │
        │   ├── mapper/
        │   │   ├── UEmployeeBaseMapper.java
        │   │   ├── UEmployeeBaseHMapper.java
        │   │   ├── UEmployeeDoubleDutyMapper.java
        │   │   └── UEmployeeDoubleDutyHMapper.java
        │   │
        │   └── service/
        │       ├── IUEmployeeService.java
        │       ├── IUEmployeeDoubleDutyService.java
        │       ├── impl/UEmployeeServiceImpl.java
        │       └── impl/UEmployeeDoubleDutyServiceImpl.java
        │
        └── user/auth/
            ├── controller/admin/
            │   └── UserLoginController.java       # 登录认证
            │
            ├── service/
            │   ├── IUserLoginService.java
            │   └── impl/UserLoginServiceImpl.java
            │
            └── util/
                └── JwtUtil.java                    # JWT工具（如需自定义）

sc-cloud-protocol
└── src/main/java/com/sc/cloud/protocol/basic/base/
    ├── qvo/
    │   ├── UEmployeeQVO.java           # 员工入参
    │   ├── UEmployeePageQVO.java        # 员工分页查询入参
    │   └── UEmployeeDoubleDutyQVO.java # 兼岗入参
    │
    ├── rvo/
    │   ├── UEmployeeRVO.java            # 员工出参（脱敏）
    │   ├── UEmployeeDetailRVO.java      # 员工详情（不解密）
    │   ├── UEmployeePageRVO.java        # 员工分页出参
    │   └── UEmployeeDoubleDutyRVO.java # 兼岗出参
    │
    └── dto/
        └── UEmployeeDTO.java            # 内部数据传输
```

---

## 4. 接口设计

### 4.1 员工管理接口

| 接口 | 方法 | 说明 | 优先级 |
|------|------|------|--------|
| `/basic/employee/page` | POST | 分页查询员工列表 | P0 |
| `/basic/employee/getById` | GET | 根据ID获取员工 | P0 |
| `/basic/employee/add` | POST | 新增员工 | P0 |
| `/basic/employee/update` | POST | 修改员工 | P0 |
| `/basic/employee/delete` | DELETE | 删除员工 | P0 |
| `/basic/employee/setEnabled/{userBaseId}/{enabled}` | PUT | 启用/禁用员工 | P0 |
| `/basic/employee/resetPassword/{userBaseId}` | POST | 重置密码 | P0 |

### 4.2 兼岗管理接口

| 接口 | 方法 | 说明 | 优先级 |
|------|------|------|--------|
| `/basic/employee/duty/list/{userBaseId}` | GET | 获取员工兼岗列表 | P0 |
| `/basic/employee/duty/add` | POST | 新增兼岗 | P0 |
| `/basic/employee/duty/update` | POST | 修改兼岗 | P0 |
| `/basic/employee/duty/delete/{dutyId}` | DELETE | 删除兼岗 | P0 |
| `/basic/employee/duty/setEnabled/{dutyId}/{enabled}` | PUT | 启用/禁用兼岗 | P0 |

### 4.3 登录认证接口

| 接口 | 方法 | 说明 | 优先级 |
|------|------|------|--------|
| `/basic/employee/login` | POST | 员工登录 | P0 |
| `/basic/employee/refreshToken` | POST | 刷新Token | P0 |

### 4.4 接口详情

#### 4.4.1 员工登录
```
POST /basic/employee/login

请求体:
{
  "accountNum": "admin",      // 登录账号
  "password": "加密后的密码"    // 前端AES加密
}

响应:
{
  "code": 0,
  "data": {
    "token": "JWT Token",
    "expireTime": "2026-04-01 12:00:00",
    "userInfo": {
      "userBaseId": "xxx",
      "userName": "张三",
      "accountNum": "admin",
      "companyId": "xxx",
      "companyName": "xxx公司"
    }
  }
}
```

#### 4.4.2 员工分页查询
```
POST /basic/employee/page

请求体:
{
  "accountNum": "admin",      // 可选，账号模糊查询
  "userName": "张",           // 可选，姓名模糊查询
  "deptId": "xxx",           // 可选，部门筛选
  "baseStatus": "1",         // 可选，员工状态
  "pageNum": 1,
  "pageSize": 10
}

响应:
{
  "code": 0,
  "data": {
    "records": [
      {
        "userBaseId": "xxx",
        "userName": "张三",
        "accountNum": "admin",
        "deptName": "技术部",
        "baseStatus": "1",
        "baseStatusName": "正常",
        "phoneNumber": "138****1234",   // 解密后脱敏
        "createTime": "2026-03-01"
      }
    ],
    "total": 100,
    "pageNum": 1,
    "pageSize": 10
  }
}
```

---

## 5. 数据结构

### 5.1 Entity 定义

#### UEmployeeBase（员工主表）
```java
@TableName("u_employee_base")
public class UEmployeeBase extends BaseEntity {
    @TableId("user_base_id")
    private String userBaseId;      // 员工ID

    @TableField("user_id")
    private String userId;          // 用户ID

    @TableField("company_id")
    private String companyId;       // 公司ID

    @TableField("user_name")
    private String userName;        // 用户名称

    @TableField("account_num")
    private String accountNum;      // 登录账号（唯一）

    @TableField("account_pwd")
    private String accountPwd;      // 登录密码（加密）

    @TableField("idcard_number")
    private String idcardNumber;    // 身份证号（SM4加密）

    @TableField("phone_number")
    private String phoneNumber;     // 手机号（SM4加密）

    @TableField("email_addr")
    private String emailAddr;       // 邮箱（SM4加密）

    @TableField("dept_id")
    private String deptId;          // 主部门ID

    @TableField("first_dept_id")
    private String firstDeptId;     // 一级部门ID

    @TableField("job_num")
    private String jobNum;          // 工号

    @TableField("base_status")
    private String baseStatus;      // 员工状态: 0/1/4/9

    @TableField("data_level")
    private Integer dataLevel;      // 数据级别

    @TableField("pwd_valid_day")
    private Integer pwdValidDay;   // 密码有效天数

    @TableField("last_change_date")
    private LocalDateTime lastChangeDate;  // 最后修改密码日期

    @TableField("use_external")
    private String useExternal;      // 是否外部单位

    @TableField("is_default_pwd")
    private String isDefaultPwd;    // 是否默认密码

    // ... create_time, update_time 等公共字段继承自 BaseEntity
}
```

#### UEmployeeDoubleDuty（兼岗表）
```java
@TableName("u_employee_double_duty")
public class UEmployeeDoubleDuty extends BaseEntity {
    @TableId("duty_id")
    private String dutyId;          // 兼岗ID

    @TableField("user_base_id")
    private String userBaseId;      // 员工ID

    @TableField("user_id")
    private String userId;          // 用户ID

    @TableField("company_id")
    private String companyId;       // 公司ID

    @TableField("dept_org_id")
    private String deptOrgId;       // 组织公司ID

    @TableField("dept_id")
    private String deptId;          // 组织部门ID

    @TableField("first_dept_id")
    private String firstDeptId;     // 一级部门ID

    @TableField("base_post_id")
    private String basePostId;      // 岗位ID

    @TableField("base_job_id")
    private String baseJobId;       // 职务ID

    @TableField("rank_level_id")
    private String rankLevelId;     // 职级ID

    @TableField("main_post")
    private String mainPost;         // 是否主岗: 0/1

    @TableField("enabled")
    private String enabled;          // 是否启用: 0/1

    @TableField("remarks")
    private String remarks;         // 备注
}
```

### 5.2 敏感字段处理策略

| 字段 | 存储 | 返回前端 | 说明 |
|------|------|---------|------|
| account_pwd | AES+MD5加密 | 不返回 | 登录时验证 |
| idcard_number | SM4-CBC加密 | 脱敏显示 (后4位) | 前端展示 |
| phone_number | SM4-CBC加密 | 脱敏显示 (中间4位) | 前端展示 |
| email_addr | SM4-CBC加密 | 脱敏显示 (@前3位+***+@+域名) | 前端展示 |

---

## 6. 实现步骤

### Step 1: 创建 Protocol 类
```
T2-2: 协议类创建
├── UEmployeeQVO.java
├── UEmployeePageQVO.java
├── UEmployeeDoubleDutyQVO.java
├── UEmployeeRVO.java
├── UEmployeeDetailRVO.java
├── UEmployeePageRVO.java
└── UEmployeeDoubleDutyRVO.java
```

### Step 2: 创建 Entity 类
```
T2-1: 实体类创建
├── UEmployeeBase.java
├── UEmployeeBaseH.java
├── UEmployeeDoubleDuty.java
└── UEmployeeDoubleDutyH.java
```

### Step 3: 创建 Mapper 接口
```
T2-1: Mapper接口
├── UEmployeeBaseMapper.java
├── UEmployeeBaseHMapper.java
├── UEmployeeDoubleDutyMapper.java
└── UEmployeeDoubleDutyHMapper.java
```

### Step 4: 创建 Mapper XML
```
T2-7: Mapper XML配置
├── UEmployeeBaseMapper.xml
└── UEmployeeDoubleDutyMapper.xml
```

### Step 5: 创建 Service 层
```
T2-3: Service层
├── IUEmployeeService.java
├── IUEmployeeDoubleDutyService.java
├── UEmployeeServiceImpl.java
└── UEmployeeDoubleDutyServiceImpl.java
```

### Step 6: 创建 Controller 层
```
T2-4: Controller层
├── UEmployeeController.java
└── UEmployeeDoubleDutyController.java
```

### Step 7: 登录认证模块
```
T2-6: 登录认证
├── UserLoginController.java
├── IUserLoginService.java
├── UserLoginServiceImpl.java
└── (复用框架JWT能力或自定义JwtUtil)
```

### Step 8: 更新状态
- 更新 `shared/status.json` Phase 2 → 开发中

---

## 7. 风险评估

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| SM4密钥未配置 | 加密解密失败 | 启动检查配置文件 |
| JWT Token过期 | 前端需处理401 | 提供refreshToken接口 |
| 员工账号重复 | 数据一致性 | 数据库唯一索引 + Service层校验 |
| 兼岗主岗冲突 | 业务逻辑错误 | 校验逻辑：一个员工只能有一个main_post='1' |
| 敏感字段泄露 | 安全风险 | 出参统一脱敏，不在日志打印 |

---

## 8. 文件清单

| 序号 | 文件路径 | 说明 |
|------|----------|------|
| 1 | `sc-cloud-protocol/.../qvo/UEmployeeQVO.java` | 员工入参 |
| 2 | `sc-cloud-protocol/.../qvo/UEmployeePageQVO.java` | 分页查询入参 |
| 3 | `sc-cloud-protocol/.../qvo/UEmployeeDoubleDutyQVO.java` | 兼岗入参 |
| 4 | `sc-cloud-protocol/.../rvo/UEmployeeRVO.java` | 员工出参(脱敏) |
| 5 | `sc-cloud-protocol/.../rvo/UEmployeeDetailRVO.java` | 员工详情 |
| 6 | `sc-cloud-protocol/.../rvo/UEmployeePageRVO.java` | 分页出参 |
| 7 | `sc-cloud-protocol/.../rvo/UEmployeeDoubleDutyRVO.java` | 兼岗出参 |
| 8 | `sc-cloud-protocol/.../dto/UEmployeeDTO.java` | 数据传输对象 |
| 9 | `sc-cloud-module-basic-server/.../entity/UEmployeeBase.java` | 员工实体 |
| 10 | `sc-cloud-module-basic-server/.../entity/UEmployeeBaseH.java` | 员工历史表 |
| 11 | `sc-cloud-module-basic-server/.../entity/UEmployeeDoubleDuty.java` | 兼岗实体 |
| 12 | `sc-cloud-module-basic-server/.../entity/UEmployeeDoubleDutyH.java` | 兼岗历史表 |
| 13 | `sc-cloud-module-basic-server/.../mapper/UEmployeeBaseMapper.java` | 员工Mapper |
| 14 | `sc-cloud-module-basic-server/.../mapper/UEmployeeBaseHMapper.java` | 员工历史Mapper |
| 15 | `sc-cloud-module-basic-server/.../mapper/UEmployeeDoubleDutyMapper.java` | 兼岗Mapper |
| 16 | `sc-cloud-module-basic-server/.../mapper/UEmployeeDoubleDutyHMapper.java` | 兼岗历史Mapper |
| 17 | `sc-cloud-module-basic-server/.../mapper/UEmployeeBaseMapper.xml` | 员工Mapper XML |
| 18 | `sc-cloud-module-basic-server/.../mapper/UEmployeeDoubleDutyMapper.xml` | 兼岗Mapper XML |
| 19 | `sc-cloud-module-basic-server/.../service/IUEmployeeService.java` | 员工服务接口 |
| 20 | `sc-cloud-module-basic-server/.../service/UEmployeeServiceImpl.java` | 员工服务实现 |
| 21 | `sc-cloud-module-basic-server/.../service/IUEmployeeDoubleDutyService.java` | 兼岗服务接口 |
| 22 | `sc-cloud-module-basic-server/.../service/UEmployeeDoubleDutyServiceImpl.java` | 兼岗服务实现 |
| 23 | `sc-cloud-module-basic-server/.../controller/admin/UEmployeeController.java` | 员工控制器 |
| 24 | `sc-cloud-module-basic-server/.../controller/admin/UEmployeeDoubleDutyController.java` | 兼岗控制器 |
| 25 | `sc-cloud-module-basic-server/.../user/auth/controller/admin/UserLoginController.java` | 登录控制器 |
| 26 | `sc-cloud-module-basic-server/.../user/auth/service/IUserLoginService.java` | 登录服务接口 |
| 27 | `sc-cloud-module-basic-server/.../user/auth/service/impl/UserLoginServiceImpl.java` | 登录服务实现 |

**总计: 27 个文件**

---

## 9. 遵循规范

本方案严格遵循 `skills/java-backend/base-crud/SKILL.md` V2 版本规范：

- [x] 包名统一为 `com.sc.cloud`
- [x] Controller 放在 `controller/admin/` 子目录
- [x] Service 类级 `@Transactional(readOnly = true)`，写操作方法覆盖
- [x] Mapper 查询方法使用 `default` 方法，复杂查询走 XML + `@Param`
- [x] 历史表写入使用 `addHistory()` 方法
- [x] Entity 继承 `BaseEntity`，使用 `@EqualsAndHashCode(callSuper = false)`
- [x] QVO 的 `companyId` 加 `@JsonIgnore`
- [x] 树形查询（如有）使用 `TreeBuildUtil.buildTree()`
