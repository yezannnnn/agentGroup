# 技术方案 - Phase 3 基础数据管理

## 1. 需求概述

Phase 3 开发 M4 基础数据管理，包含3个子模块：
- 职务管理 (base_company_job)
- 职级管理 (base_company_rank_level)
- 岗位管理 (base_company_post)

**业务规则：**
- R1: 编码唯一性校验（job_code / rank_level_code / post_code）

**共同特性：**
- 无树形结构，使用普通列表
- 支持 CRUD + 启用/禁用
- 每个模块有历史表（`_H`）

---

## 2. 技术选型

| 组件 | 技术 | 说明 |
|------|------|------|
| 框架 | Spring Boot 3.x | 现有项目保持一致 |
| ORM | MyBatis-Plus 3.5+ | 现有项目保持一致 |
| 数据库 | MySQL 8 | 现有项目保持一致 |
| 历史表 | 手动写入 H 表 | 与 Phase 1/2 保持一致 |

**现有工具类复用：**
- `com.shengcheng.framework.springboot.core.local.GlobalHeaderThreadLocal` - 获取租户ID
- `com.shengcheng.framework.springboot.core.spring.util.DataUtil` - 对象拷贝
- `com.shengcheng.framework.springboot.protocol.Result` - 统一响应
- `com.sc.cloud.common.secret.EncryptCommon` - 加密工具（如需）

---

## 3. 架构设计

```
sc-cloud-module-basic
└── sc-cloud-module-basic-server
    └── src/main/java/com/sc/cloud/basic/base/
        ├── controller/admin/
        │   ├── BaseCompanyJobController.java          # 职务管理
        │   ├── BaseCompanyRankLevelController.java    # 职级管理
        │   └── BaseCompanyPostController.java         # 岗位管理
        │
        ├── entity/
        │   ├── BaseCompanyJob.java                    # 职务表
        │   ├── BaseCompanyJobH.java                   # 职务历史表
        │   ├── BaseCompanyRankLevel.java              # 职级表
        │   ├── BaseCompanyRankLevelH.java             # 职级历史表
        │   ├── BaseCompanyPost.java                   # 岗位表
        │   └── BaseCompanyPostH.java                  # 岗位历史表
        │
        ├── mapper/
        │   ├── BaseCompanyJobMapper.java
        │   ├── BaseCompanyJobHMapper.java
        │   ├── BaseCompanyRankLevelMapper.java
        │   ├── BaseCompanyRankLevelHMapper.java
        │   ├── BaseCompanyPostMapper.java
        │   └── BaseCompanyPostHMapper.java
        │
        └── service/
            ├── IBaseCompanyJobService.java
            ├── IBaseCompanyRankLevelService.java
            ├── IBaseCompanyPostService.java
            └── impl/
                ├── BaseCompanyJobServiceImpl.java
                ├── BaseCompanyRankLevelServiceImpl.java
                └── BaseCompanyPostServiceImpl.java

sc-cloud-protocol
└── src/main/java/com/sc/cloud/protocol/basic/base/
    ├── qvo/
    │   ├── BaseCompanyJobQVO.java
    │   ├── BaseCompanyRankLevelQVO.java
    │   └── BaseCompanyPostQVO.java
    │
    ├── rvo/
    │   ├── BaseCompanyJobRVO.java
    │   ├── BaseCompanyRankLevelRVO.java
    │   └── BaseCompanyPostRVO.java
    │
    └── dto/
        ├── BaseCompanyJobDTO.java
        ├── BaseCompanyRankLevelDTO.java
        └── BaseCompanyPostDTO.java
```

---

## 4. 接口设计

### 4.1 职务管理接口

| 接口 | 方法 | 说明 | 优先级 |
|------|------|------|--------|
| `/basic/job/page` | POST | 分页查询职务列表 | P0 |
| `/basic/job/getById` | GET | 根据ID获取职务 | P0 |
| `/basic/job/add` | POST | 新增职务 | P0 |
| `/basic/job/update` | POST | 修改职务 | P0 |
| `/basic/job/delete` | DELETE | 删除职务 | P0 |
| `/basic/job/setEnabled/{jobId}/{enabled}` | PUT | 启用/禁用职务 | P0 |

### 4.2 职级管理接口

| 接口 | 方法 | 说明 | 优先级 |
|------|------|------|--------|
| `/basic/rankLevel/page` | POST | 分页查询职级列表 | P0 |
| `/basic/rankLevel/getById` | GET | 根据ID获取职级 | P0 |
| `/basic/rankLevel/add` | POST | 新增职级 | P0 |
| `/basic/rankLevel/update` | POST | 修改职级 | P0 |
| `/basic/rankLevel/delete` | DELETE | 删除职级 | P0 |
| `/basic/rankLevel/setEnabled/{rankLevelId}/{enabled}` | PUT | 启用/禁用职级 | P0 |

### 4.3 岗位管理接口

| 接口 | 方法 | 说明 | 优先级 |
|------|------|------|--------|
| `/basic/post/page` | POST | 分页查询岗位列表 | P0 |
| `/basic/post/getById` | GET | 根据ID获取岗位 | P0 |
| `/basic/post/add` | POST | 新增岗位 | P0 |
| `/basic/post/update` | POST | 修改岗位 | P0 |
| `/basic/post/delete` | DELETE | 删除岗位 | P0 |
| `/basic/post/setEnabled/{postId}/{enabled}` | PUT | 启用/禁用岗位 | P0 |

---

## 5. 数据结构

### 5.1 Entity 定义

#### BaseCompanyJob（职务表）
```java
@TableName("base_company_job")
public class BaseCompanyJob extends BaseEntity {
    @TableId("job_id")
    private String jobId;              // 职务ID

    @TableField("company_id")
    private String companyId;          // 公司ID

    @TableField("job_name")
    private String jobName;            // 职务名称

    @TableField("job_code")
    private String jobCode;            // 职务代码（唯一）

    @TableField("dept_id")
    private String deptId;             // 所属部门

    @TableField("job_category")
    private String jobCategory;        // 职务类别【字典-JobCategory】

    @TableField("remark")
    private String remark;             // 描述

    @TableField("sortno")
    private Integer sortno;            // 排序号

    @TableField("enabled")
    private String enabled;            // 是否启用: 0/1
}
```

#### BaseCompanyRankLevel（职级表）
```java
@TableName("base_company_rank_level")
public class BaseCompanyRankLevel extends BaseEntity {
    @TableId("rank_level_id")
    private String rankLevelId;        // 职级ID

    @TableField("company_id")
    private String companyId;           // 公司ID

    @TableField("rank_level_name")
    private String rankLevelName;      // 职级名称

    @TableField("rank_level_code")
    private String rankLevelCode;     // 职级代码（唯一）

    @TableField("rank_level_category")
    private String rankLevelCategory;  // 职级类别【字典-RankLevelCategory】

    @TableField("mapper_group")
    private String mapperGroup;        // 集团级别映射

    @TableField("remark")
    private String remark;              // 描述

    @TableField("sortno")
    private Integer sortno;            // 排序号

    @TableField("enabled")
    private String enabled;            // 是否启用: 0/1
}
```

#### BaseCompanyPost（岗位表）
```java
@TableName("base_company_post")
public class BaseCompanyPost extends BaseEntity {
    @TableId("post_id")
    private String postId;              // 岗位ID

    @TableField("company_id")
    private String companyId;           // 公司ID

    @TableField("post_name")
    private String postName;           // 岗位名称

    @TableField("post_code")
    private String postCode;           // 岗位代码（唯一）

    @TableField("post_category")
    private String postCategory;       // 岗位类别【字典-PostCategory】

    @TableField("remark")
    private String remark;              // 描述

    @TableField("sortno")
    private Integer sortno;            // 排序号

    @TableField("enabled")
    private String enabled;             // 是否启用: 0/1
}
```

---

## 6. 实现步骤

### Step 1: 创建 Entity + History 类（3组 × 2 = 6个）
```
T3-1: Entity类创建
├── BaseCompanyJob.java
├── BaseCompanyJobH.java
├── BaseCompanyRankLevel.java
├── BaseCompanyRankLevelH.java
├── BaseCompanyPost.java
└── BaseCompanyPostH.java
```

### Step 2: 创建 Mapper 接口（6个）
```
T3-2: Mapper接口
├── BaseCompanyJobMapper.java
├── BaseCompanyJobHMapper.java
├── BaseCompanyRankLevelMapper.java
├── BaseCompanyRankLevelHMapper.java
├── BaseCompanyPostMapper.java
└── BaseCompanyPostHMapper.java
```

### Step 3: 创建 Mapper XML（3个）
```
T3-3: Mapper XML配置
├── BaseCompanyJobMapper.xml
├── BaseCompanyRankLevelMapper.xml
└── BaseCompanyPostMapper.xml
```

### Step 4: 创建 Protocol 类（15个）
```
T3-4: 协议类创建
├── qvo/BaseCompanyJobQVO.java
├── qvo/BaseCompanyJobPageQVO.java        # 分页查询入参
├── qvo/BaseCompanyRankLevelQVO.java
├── qvo/BaseCompanyRankLevelPageQVO.java   # 分页查询入参
├── qvo/BaseCompanyPostQVO.java
├── qvo/BaseCompanyPostPageQVO.java        # 分页查询入参
├── rvo/BaseCompanyJobRVO.java
├── rvo/BaseCompanyJobPageRVO.java         # 分页查询出参
├── rvo/BaseCompanyRankLevelRVO.java
├── rvo/BaseCompanyRankLevelPageRVO.java   # 分页查询出参
├── rvo/BaseCompanyPostRVO.java
├── rvo/BaseCompanyPostPageRVO.java        # 分页查询出参
├── dto/BaseCompanyJobDTO.java
├── dto/BaseCompanyRankLevelDTO.java
└── dto/BaseCompanyPostDTO.java
```

### Step 5: 创建 Service 层（3对接口+实现）
```
T3-5: Service层
├── IBaseCompanyJobService.java
├── IBaseCompanyRankLevelService.java
├── IBaseCompanyPostService.java
├── impl/BaseCompanyJobServiceImpl.java
├── impl/BaseCompanyRankLevelServiceImpl.java
└── impl/BaseCompanyPostServiceImpl.java
```

### Step 6: 创建 Controller 层（3个）
```
T3-6: Controller层
├── BaseCompanyJobController.java
├── BaseCompanyRankLevelController.java
└── BaseCompanyPostController.java
```

---

## 7. 风险评估

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 编码重复 | 数据一致性 | 数据库唯一索引 + Service层校验 |
| 关联数据存在 | 无法删除 | 删除前检查业务表引用 |

---

## 8. 文件清单

| 序号 | 文件路径 | 说明 |
|------|----------|------|
| 1 | `sc-cloud-protocol/.../qvo/BaseCompanyJobQVO.java` | 职务入参 |
| 2 | `sc-cloud-protocol/.../qvo/BaseCompanyJobPageQVO.java` | 职务分页入参 |
| 3 | `sc-cloud-protocol/.../qvo/BaseCompanyRankLevelQVO.java` | 职级入参 |
| 4 | `sc-cloud-protocol/.../qvo/BaseCompanyRankLevelPageQVO.java` | 职级分页入参 |
| 5 | `sc-cloud-protocol/.../qvo/BaseCompanyPostQVO.java` | 岗位入参 |
| 6 | `sc-cloud-protocol/.../qvo/BaseCompanyPostPageQVO.java` | 岗位分页入参 |
| 7 | `sc-cloud-protocol/.../rvo/BaseCompanyJobRVO.java` | 职务出参 |
| 8 | `sc-cloud-protocol/.../rvo/BaseCompanyJobPageRVO.java` | 职务分页出参 |
| 9 | `sc-cloud-protocol/.../rvo/BaseCompanyRankLevelRVO.java` | 职级出参 |
| 10 | `sc-cloud-protocol/.../rvo/BaseCompanyRankLevelPageRVO.java` | 职级分页出参 |
| 11 | `sc-cloud-protocol/.../rvo/BaseCompanyPostRVO.java` | 岗位出参 |
| 12 | `sc-cloud-protocol/.../rvo/BaseCompanyPostPageRVO.java` | 岗位分页出参 |
| 25 | `sc-cloud-module-basic-server/.../mapper/BaseCompanyRankLevelHMapper.java` | 职级历史Mapper |
| 26 | `sc-cloud-module-basic-server/.../mapper/BaseCompanyPostMapper.java` | 岗位Mapper |
| 27 | `sc-cloud-module-basic-server/.../mapper/BaseCompanyPostHMapper.java` | 岗位历史Mapper |
| 28 | `sc-cloud-module-basic-server/.../mapper/BaseCompanyJobMapper.xml` | 职务Mapper XML |
| 29 | `sc-cloud-module-basic-server/.../mapper/BaseCompanyRankLevelMapper.xml` | 职级Mapper XML |
| 30 | `sc-cloud-module-basic-server/.../mapper/BaseCompanyPostMapper.xml` | 岗位Mapper XML |
| 31 | `sc-cloud-module-basic-server/.../service/IBaseCompanyJobService.java` | 职务服务接口 |
| 32 | `sc-cloud-module-basic-server/.../service/IBaseCompanyRankLevelService.java` | 职级服务接口 |
| 33 | `sc-cloud-module-basic-server/.../service/IBaseCompanyPostService.java` | 岗位服务接口 |
| 34 | `sc-cloud-module-basic-server/.../service/impl/BaseCompanyJobServiceImpl.java` | 职务服务实现 |
| 35 | `sc-cloud-module-basic-server/.../service/impl/BaseCompanyRankLevelServiceImpl.java` | 职级服务实现 |
| 36 | `sc-cloud-module-basic-server/.../service/impl/BaseCompanyPostServiceImpl.java` | 岗位服务实现 |
| 37 | `sc-cloud-module-basic-server/.../controller/admin/BaseCompanyJobController.java` | 职务控制器 |
| 38 | `sc-cloud-module-basic-server/.../controller/admin/BaseCompanyRankLevelController.java` | 职级控制器 |
| 39 | `sc-cloud-module-basic-server/.../controller/admin/BaseCompanyPostController.java` | 岗位控制器 |

**总计: 39 个文件**

---

## 9. 遵循规范

本方案严格遵循 `skills/java-backend/base-crud/SKILL.md` V2 版本规范：

- [x] 包名统一为 `com.sc.cloud`
- [x] Controller 放在 `controller/admin/` 子目录
- [x] Controller 继承 `BaseController`，类上有 `@Validated`
- [x] 入参 QVO 的 `companyId` 加 `@JsonIgnore`
- [x] Service 类级 `@Transactional(readOnly = true)`，写操作方法覆盖
- [x] Mapper 查询方法使用 `default` 方法，复杂查询走 XML + `@Param`
- [x] 每个写操作后都调用 `addHistory()`
- [x] 历史表主键字段名为 `seqno`，类型为 `String`
- [x] Entity 继承 `BaseEntity`，使用 `@EqualsAndHashCode(callSuper = false)`
- [x] DDL 同时创建了历史表（`_H`）
- [x] QVO/RVO/DTO 只用 `@Data` 注解即可
- [x] 分页查询使用 MyBatis-Plus Page
- [x] Mapper 必须提供 `getByCode()` 方法校验编码唯一性
- [x] **跳过树形结构处理**（TreeBuildUtil）- 本模块为扁平列表结构
- [x] **跳过子级检查**（hasChildren）- 本模块无层级关系

---

## 10. DDL 参考

### 职务表
```sql
CREATE TABLE `base_company_job` (
  `job_id`      varchar(32)  NOT NULL COMMENT '职务ID',
  `company_id`  varchar(32)  NOT NULL COMMENT '公司ID',
  `job_name`    varchar(30)  NOT NULL COMMENT '职务名称',
  `job_code`    varchar(20)           COMMENT '职务代码',
  `dept_id`     varchar(32)           COMMENT '所属部门',
  `job_category` varchar(20)           COMMENT '职务类别【字典-JobCategory】',
  `remark`      varchar(300)           COMMENT '描述',
  `sortno`      int                   COMMENT '排序号',
  `enabled`     char(1)      NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_user` varchar(32)           COMMENT '创建人',
  `create_time` datetime             COMMENT '创建时间',
  `update_user` varchar(32)           COMMENT '最后操作人',
  `update_time` datetime             COMMENT '最后操作时间',
  PRIMARY KEY (`job_id`)
) ENGINE=InnoDB CHARSET=utf8mb4 COMMENT='职务表';

CREATE TABLE `base_company_job_h` (
  `seqno`       varchar(32)  NOT NULL COMMENT '历史流水号',
  `job_id`      varchar(32)  NOT NULL COMMENT '职务ID',
  `company_id`  varchar(32)  NOT NULL COMMENT '公司ID',
  `job_name`    varchar(30)  NOT NULL COMMENT '职务名称',
  `job_code`    varchar(20)           COMMENT '职务代码',
  `enabled`     char(1)      NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` varchar(32)           COMMENT '创建人',
  `update_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` varchar(32)           COMMENT '更新人',
  PRIMARY KEY (`seqno`)
) ENGINE=InnoDB COMMENT='职务历史表';
```

### 职级表
```sql
CREATE TABLE `base_company_rank_level` (
  `rank_level_id`    varchar(32)  NOT NULL COMMENT '职级ID',
  `company_id`       varchar(32)  NOT NULL COMMENT '公司ID',
  `rank_level_name`  varchar(30)  NOT NULL COMMENT '职级名称',
  `rank_level_code`  varchar(20)           COMMENT '职级代码',
  `rank_level_category` varchar(20)         COMMENT '职级类别【字典-RankLevelCategory】',
  `mapper_group`     varchar(20)           COMMENT '集团级别映射',
  `remark`           varchar(300)           COMMENT '描述',
  `sortno`           int                   COMMENT '排序号',
  `enabled`          char(1)     NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_user`      varchar(32)           COMMENT '创建人',
  `create_time`      datetime              COMMENT '创建时间',
  `update_user`      varchar(32)           COMMENT '最后操作人',
  `update_time`      datetime              COMMENT '最后操作时间',
  PRIMARY KEY (`rank_level_id`)
) ENGINE=InnoDB CHARSET=utf8mb4 COMMENT='职级表';

CREATE TABLE `base_company_rank_level_h` (
  `seqno`            varchar(32)  NOT NULL COMMENT '历史流水号',
  `rank_level_id`   varchar(32)  NOT NULL COMMENT '职级ID',
  `company_id`       varchar(32)  NOT NULL COMMENT '公司ID',
  `rank_level_name` varchar(30)  NOT NULL COMMENT '职级名称',
  `rank_level_code` varchar(20)           COMMENT '职级代码',
  `enabled`         char(1)     NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_time`     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user`     varchar(32)           COMMENT '创建人',
  `update_time`     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user`     varchar(32)           COMMENT '更新人',
  PRIMARY KEY (`seqno`)
) ENGINE=InnoDB COMMENT='职级历史表';
```

### 岗位表
```sql
CREATE TABLE `base_company_post` (
  `post_id`      varchar(32)  NOT NULL COMMENT '岗位ID',
  `company_id`   varchar(32)  NOT NULL COMMENT '公司ID',
  `post_name`   varchar(30)  NOT NULL COMMENT '岗位名称',
  `post_code`   varchar(20)           COMMENT '岗位代码',
  `post_category` varchar(20)          COMMENT '岗位类别【字典-PostCategory】',
  `remark`      varchar(300)          COMMENT '描述',
  `sortno`      int                  COMMENT '排序号',
  `enabled`     char(1)     NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_user` varchar(32)          COMMENT '创建人',
  `create_time` datetime             COMMENT '创建时间',
  `update_user` varchar(32)          COMMENT '最后操作人',
  `update_time` datetime             COMMENT '最后操作时间',
  PRIMARY KEY (`post_id`)
) ENGINE=InnoDB CHARSET=utf8mb4 COMMENT='岗位表';

CREATE TABLE `base_company_post_h` (
  `seqno`       varchar(32)  NOT NULL COMMENT '历史流水号',
  `post_id`    varchar(32)  NOT NULL COMMENT '岗位ID',
  `company_id` varchar(32)  NOT NULL COMMENT '公司ID',
  `post_name`  varchar(30) NOT NULL COMMENT '岗位名称',
  `post_code`  varchar(20)          COMMENT '岗位代码',
  `enabled`   char(1)     NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user` varchar(32)          COMMENT '创建人',
  `update_time` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user` varchar(32)          COMMENT '更新人',
  PRIMARY KEY (`seqno`)
) ENGINE=InnoDB COMMENT='岗位历史表';
```
