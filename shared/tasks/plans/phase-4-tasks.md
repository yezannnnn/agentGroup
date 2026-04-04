# Phase 4 任务拆分 - 数据字典 + 维度管理

## 基本信息

| 项目 | 内容 |
|------|------|
| 阶段 | Phase 4 |
| 日期 | 2026-03-31 |
| 目标 | M5 数据字典 + M6 维度管理 |
| 参照 | `skills/java-backend/base-crud/SKILL.md` |

---

## 关键决策

1. **g_dict 系统级数据** - 无 company_id 隔离，所有公司共享
2. **删除字典值检查业务表引用** - TODO: 待后续实现通用引用检查机制
3. **接口规格**:
   - `GET /form/dict/options/{dictType}` - 数据字典下拉选项
   - `GET /form/dim/options/{dimType}` - 维度下拉选项
   - `GET /form/dim/syncTree` - 维度下拉树

---

## M5: 数据字典 (g_dict)

### 表结构

```
g_dict
├── dict_id      varchar(32) PK  -- 字典ID
├── dict_value   varchar(200)     -- 字典值
├── dict_name    varchar(50)      -- 字典名称
├── dict_desc    varchar(200)    -- 字典描述
├── parent_id    varchar(32)     -- 父级字典ID
├── dict_type    char(1)          -- 字典分类【0系统分类/1字典类型/2字典值】
├── dict_color   varchar(10)     -- 字典颜色
├── order_num    int             -- 字典项排序号
├── enabled      char(1)          -- 是否启用【0禁用/1启用】
├── create_user  varchar(32)
├── create_time  datetime
├── update_user  varchar(32)
├── update_time  datetime
```

### 任务清单

| # | 任务 | 文件路径 | 说明 |
|---|------|----------|------|
| M5-T1 | 协议类-QVO | `protocol/form/dict/qvo/GDictQVO.java` | 入参，含dictType分类 |
| M5-T2 | 协议类-RVO | `protocol/form/dict/rvo/GDictRVO.java` | 出参 |
| M5-T3 | 协议类-树RVO | `protocol/form/dict/rvo/GDictTreeRVO.java` | 树形出参，含children |
| M5-T4 | 协议类-DTO | `protocol/form/dict/dto/GDictDTO.java` | 内部传输，复杂查询用 |
| M5-T5 | 实体类 | `module-basic-server/.../entity/GDict.java` | 主表实体 |
| M5-T6 | 历史实体 | `module-basic-server/.../entity/GDictH.java` | 历史表实体，seqno主键 |
| M5-T7 | Mapper | `module-basic-server/.../mapper/GDictMapper.java` | 含getByType等方法 |
| M5-T8 | 历史Mapper | `module-basic-server/.../mapper/GDictHMapper.java` | 历史表Mapper |
| M5-T9 | MapperXML | `resources/mapper/base/GDictMapper.xml` | 复杂查询XML |
| M5-T10 | Service接口 | `module-basic-server/.../service/IGDictService.java` | 含options接口定义 |
| M5-T11 | Service实现 | `module-basic-server/.../service/impl/GDictServiceImpl.java` | 含options实现 |
| M5-T12 | Controller | `module-basic-server/.../controller/admin/GDictController.java` | 含options/{dictType}接口 |
| M5-T13 | DDL | `sql/g_dict.sql` | 建表语句 |
| M5-T14 | 历史DDL | `sql/g_dict_h.sql` | 历史表建表语句 |

### 接口列表

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/form/dict/page` | 分页查询字典 |
| GET | `/form/dict/getById` | 根据ID获取 |
| POST | `/form/dict/add` | 新增字典 |
| POST | `/form/dict/update` | 修改字典 |
| DELETE | `/form/dict/delete` | 删除字典 |
| PUT | `/form/dict/setEnabled/{dictId}/{enabled}` | 启用/禁用 |
| GET | `/form/dict/options/{dictType}` | 下拉选项接口 |

---

## M6: 维度管理 (be_dimensional_strand)

### 表结构

```
be_dimensional_strand
├── dim_id        varchar(32) PK  -- 维度ID
├── company_id    varchar(32)     -- 公司ID
├── dim_name      varchar(100)    -- 维度名称
├── dim_code      varchar(32)    -- 维度编码
├── parent_id     varchar(32)    -- 上级维度
├── define_type   char(1)        -- 数据类型【0分组/1维度分类/2维度数据】
├── use_system    char(1)        -- 是否系统维度【0否/1是】
├── dim_color     varchar(32)    -- 维度颜色代码
├── sortno        int            -- 排序号
├── enabled       char(1)        -- 是否启用【0禁用/1启用】
├── remarks       varchar(300)   -- 备注
├── create_user   varchar(32)
├── create_time   datetime
├── update_user   varchar(32)
├── update_time   datetime
```

### 任务清单

| # | 任务 | 文件路径 | 说明 |
|---|------|----------|------|
| M6-T1 | 协议类-QVO | `protocol/form/dim/qvo/BeDimensionalStrandQVO.java` | 入参 |
| M6-T2 | 协议类-RVO | `protocol/form/dim/rvo/BeDimensionalStrandRVO.java` | 出参 |
| M6-T3 | 协议类-树RVO | `protocol/form/dim/rvo/BeDimensionalStrandTreeRVO.java` | 树形出附，含childrenCount |
| M6-T4 | 协议类-DTO | `protocol/form/dim/dto/BeDimensionalStrandDTO.java` | 内部传输 |
| M6-T5 | 实体类 | `module-basic-server/.../entity/BeDimensionalStrand.java` | 主表实体，有companyId |
| M6-T6 | 历史实体 | `module-basic-server/.../entity/BeDimensionalStrandH.java` | 历史表实体 |
| M6-T7 | Mapper | `module-basic-server/.../mapper/BeDimensionalStrandMapper.java` | 含getByCompany/getByParent |
| M6-T8 | 历史Mapper | `module-basic-server/.../mapper/BeDimensionalStrandHMapper.java` | 历史表Mapper |
| M6-T9 | MapperXML | `resources/mapper/base/BeDimensionalStrandMapper.xml` | 复杂查询XML |
| M6-T10 | Service接口 | `module-basic-server/.../service/IBeDimensionalStrandService.java` | 含tree/options接口 |
| M6-T11 | Service实现 | `module-basic-server/.../service/impl/BeDimensionalStrandServiceImpl.java` | 含tree构建逻辑 |
| M6-T12 | Controller | `module-basic-server/.../controller/admin/BeDimensionalStrandController.java` | 含syncTree/options接口 |
| M6-T13 | DDL | `sql/be_dimensional_strand.sql` | 建表语句 |
| M6-T14 | 历史DDL | `sql/be_dimensional_strand_h.sql` | 历史表建表语句 |

### 接口列表

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/form/dim/page` | 分页查询维度 |
| GET | `/form/dim/getById` | 根据ID获取 |
| POST | `/form/dim/add` | 新增维度 |
| POST | `/form/dim/update` | 修改维度 |
| DELETE | `/form/dim/delete` | 删除维度(检查子节点/系统维度) |
| PUT | `/form/dim/setEnabled/{dimId}/{enabled}` | 启用/禁用 |
| GET | `/form/dim/syncTree` | 异步获取维度树 |
| GET | `/form/dim/options` | 下拉选项接口 |

---

## 完整任务汇总 (28项)

| 序号 | 任务ID | 模块 | 类型 | 文件 |
|------|--------|------|------|------|
| 1 | M5-T1 | M5字典 | 协议-QVO | `protocol/form/dict/qvo/GDictQVO.java` |
| 2 | M5-T2 | M5字典 | 协议-RVO | `protocol/form/dict/rvo/GDictRVO.java` |
| 3 | M5-T3 | M5字典 | 协议-树RVO | `protocol/form/dict/rvo/GDictTreeRVO.java` |
| 4 | M5-T4 | M5字典 | 协议-DTO | `protocol/form/dict/dto/GDictDTO.java` |
| 5 | M5-T5 | M5字典 | 实体 | `module-basic-server/.../entity/GDict.java` |
| 6 | M5-T6 | M5字典 | 历史实体 | `module-basic-server/.../entity/GDictH.java` |
| 7 | M5-T7 | M5字典 | Mapper | `module-basic-server/.../mapper/GDictMapper.java` |
| 8 | M5-T8 | M5字典 | 历史Mapper | `module-basic-server/.../mapper/GDictHMapper.java` |
| 9 | M5-T9 | M5字典 | MapperXML | `resources/mapper/base/GDictMapper.xml` |
| 10 | M5-T10 | M5字典 | Service接口 | `module-basic-server/.../service/IGDictService.java` |
| 11 | M5-T11 | M5字典 | Service实现 | `module-basic-server/.../service/impl/GDictServiceImpl.java` |
| 12 | M5-T12 | M5字典 | Controller | `module-basic-server/.../controller/admin/GDictController.java` |
| 13 | M5-T13 | M5字典 | DDL | `sql/g_dict.sql` |
| 14 | M5-T14 | M5字典 | 历史DDL | `sql/g_dict_h.sql` |
| 15 | M6-T1 | M6维度 | 协议-QVO | `protocol/form/dim/qvo/BeDimensionalStrandQVO.java` |
| 16 | M6-T2 | M6维度 | 协议-RVO | `protocol/form/dim/rvo/BeDimensionalStrandRVO.java` |
| 17 | M6-T3 | M6维度 | 协议-树RVO | `protocol/form/dim/rvo/BeDimensionalStrandTreeRVO.java` |
| 18 | M6-T4 | M6维度 | 协议-DTO | `protocol/form/dim/dto/BeDimensionalStrandDTO.java` |
| 19 | M6-T5 | M6维度 | 实体 | `module-basic-server/.../entity/BeDimensionalStrand.java` |
| 20 | M6-T6 | M6维度 | 历史实体 | `module-basic-server/.../entity/BeDimensionalStrandH.java` |
| 21 | M6-T7 | M6维度 | Mapper | `module-basic-server/.../mapper/BeDimensionalStrandMapper.java` |
| 22 | M6-T8 | M6维度 | 历史Mapper | `module-basic-server/.../mapper/BeDimensionalStrandHMapper.java` |
| 23 | M6-T9 | M6维度 | MapperXML | `resources/mapper/base/BeDimensionalStrandMapper.xml` |
| 24 | M6-T10 | M6维度 | Service接口 | `module-basic-server/.../service/IBeDimensionalStrandService.java` |
| 25 | M6-T11 | M6维度 | Service实现 | `module-basic-server/.../service/impl/BeDimensionalStrandServiceImpl.java` |
| 26 | M6-T12 | M6维度 | Controller | `module-basic-server/.../controller/admin/BeDimensionalStrandController.java` |
| 27 | M6-T13 | M6维度 | DDL | `sql/be_dimensional_strand.sql` |
| 28 | M6-T14 | M6维度 | 历史DDL | `sql/be_dimensional_strand_h.sql` |

---

## TODO 项

- [ ] **Q2-TODO**: 删除字典值前检查业务表引用 - 待实现通用引用检查机制 (后续阶段)

---

## 完整文件路径参考

### Protocol 模块 (sc-cloud-protocol)

```
sc-cloud-protocol/src/main/java/com/sc/cloud/protocol/form/
├── dict/
│   ├── qvo/
│   │   └── GDictQVO.java
│   ├── rvo/
│   │   ├── GDictRVO.java
│   │   └── GDictTreeRVO.java
│   └── dto/
│       └── GDictDTO.java
└── dim/
    ├── qvo/
    │   └── BeDimensionalStrandQVO.java
    ├── rvo/
    │   ├── BeDimensionalStrandRVO.java
    │   └── BeDimensionalStrandTreeRVO.java
    └── dto/
        └── BeDimensionalStrandDTO.java
```

### Basic Server 模块 (sc-cloud-module-basic-server)

```
sc-cloud-module-basic-server/src/main/java/com/sc/cloud/basic/
├── dict/
│   ├── controller/admin/GDictController.java
│   ├── entity/
│   │   ├── GDict.java
│   │   └── GDictH.java
│   ├── mapper/
│   │   ├── GDictMapper.java
│   │   └── GDictHMapper.java
│   └── service/
│       ├── IGDictService.java
│       └── impl/GDictServiceImpl.java
└── dim/
    ├── controller/admin/BeDimensionalStrandController.java
    ├── entity/
    │   ├── BeDimensionalStrand.java
    │   └── BeDimensionalStrandH.java
    ├── mapper/
    │   ├── BeDimensionalStrandMapper.java
    │   └── BeDimensionalStrandHMapper.java
    └── service/
        ├── IBeDimensionalStrandService.java
        └── impl/BeDimensionalStrandServiceImpl.java
```

### Resources Mapper XML

```
sc-cloud-module-basic-server/src/main/resources/mapper/base/
├── GDictMapper.xml
└── BeDimensionalStrandMapper.xml
```
