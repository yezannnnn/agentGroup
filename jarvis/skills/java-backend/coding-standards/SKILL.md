---
name: skill-backend-standards
description: >
  后端 Java 开发完整规范，覆盖技术栈、模块结构、分层设计、编码约束与提交自检。
  触发场景：开始编写任何后端代码（Controller / ServiceImpl / Mapper / Entity / QVO / RVO / DTO / Component）时；
  设计数据库表结构或写 DDL 时；写完代码准备提交前；用户要求按规范实现某功能时。
  规范覆盖：Spring Cloud Alibaba 技术栈、双模块结构、Skills/Workflows 分层理念、
  依赖注入方式、事务注解、历史表写入、异常处理、日志规范、对象转换、VO 设计、DDL 规范等。
  重要：代码写完后必须主动按「提交前自检清单」做自检，发现问题立即修复再提交。
---

# 后端 Java 开发规范（完整版）

> **严重程度说明**
>
> - 🔴 **必须**：违反会导致 bug、数据错误、安全问题，**不允许提交**
> - 🟡 **应当**：违反团队规范，影响可维护性，**必须遵守**
> - 🔵 **建议**：代码质量优化，**尽量遵守**

---

## 一、技术栈

| 职责          | 技术选型                              |
| ------------- | ------------------------------------- |
| 核心框架      | Spring Cloud Alibaba                  |
| 注册/配置中心 | Nacos                                 |
| 服务调用      | OpenFeign + Spring Cloud LoadBalancer |
| 持久层        | MyBatis-Plus                          |
| 数据库        | MySQL 8.0                             |
| 缓存          | Redis                                 |
| 消息队列      | Kafka                                 |

---

## 二、核心理念：Skills / Workflows 分层

| 层级                      | 类型                         | 职责                                       | 落地位置                |
| ------------------------- | ---------------------------- | ------------------------------------------ | ----------------------- |
| **Skills**（原子能力）    | 单一职责、无副作用、高复用   | 完成一件独立的事，不感知业务流程           | `component` / `mapper`  |
| **Workflows**（业务编排） | 组合多个 Skills 完成业务用例 | 事务控制、流程分叉、事件发布，不含复杂计算 | `service` (ServiceImpl) |

---

## 三、模块目录结构

🔴 **必须严格遵守目录结构**，如果你不清楚代码放在哪个模块，请先询问。

```tree
cloud-backend/doc/sql_script/{date-yyyyMMdd}/
    ├── {MySQL/Doris/PostgreSQL}-{xxxxxxx_xxx}.sql  ← 数据库表DDL脚本
    └── {MySQL/Doris/PostgreSQL}-{xxxxxxx_xxx}.sql  ← 数据库表DDL脚本

cloud-backend/sc-cloud-platform-module-{module}
├── sc-cloud-{module}-api                        ← Feign 接口
│   └── src/main/java/com/sc/cloud/{module}/{domain}/
│       └── XxXxxXxxDataApi                      ← Feign 接口定义
└── sc-cloud-{module}-server                     ← 业务实现
    ├── src/main/java/com/sc/cloud/{module}/{domain}/
    │   ├── api/                                 ← XxXxxXxxDataApi 的 RPC 实现
    │   ├── controller/
    │   │   ├── admin/                           ← PC 端入口（仅参数转换，不写业务）
    │   │   └── app/                             ← 移动端入口（仅参数转换，不写业务）
    │   ├── service/
    │   │   └── impl/                            ← 业务逻辑实现
    │   ├── component/                           ← Skills: 三方封装、复杂计算、多表聚合
    │   ├── mapper/
    │   │   ├── XxXxxXxxMapper                   ← 业务表 Mapper
    │   │   └── XxXxxXxxMapperH                  ← 历史表 Mapper
    │   ├── entity/
    │   │   ├── XxXxxXxx                         ← 业务实体
    │   │   └── XxXxxXxxH                        ← 历史实体（主键字段名 seqno, String）
    │   └── util/                                ← 纯工具类
    └── src/resources/mapper/{module}/{domain}/
        ├── XxXxxXxxMapper.xml
        └── XxXxxXxxMapperH.xml

cloud-backend/sc-cloud-protocol
└── src/main/java/com/sc/cloud/protocol/{module}/{domain}/
    ├── qvo/    ← 入参
    ├── rvo/    ← 出参
    └── dto/    ← 内部中转（微服务间传输）
```

---

## 四、通用规范（所有层适用）

| 级别 | 规范要求                                                    | 正确写法                                    |
| ---- | ----------------------------------------------------------- | ------------------------------------------- |
| 🟡    | 依赖注入使用 `@Resource`，禁止 `@Autowired`                 | `@Resource private XxxService xxxService;`  |
| 🟡    | 禁止使用 `FastJSON`；使用项目基于`Jackson`封装的 `JsonUtil` | 参考 `references/framework-json-utill.md`   |
| 🔵    | 命名语义清晰，禁止拼音缩写                                  | `String expenseTypeCode`（✗ `String spbm`） |
| 🔵    | 不保留无意义注释（复制粘贴遗留、已注释大段代码）            | 删除或处理，不留超过1周的 `// TODO`         |

**方法命名风格**：`getXxxByPage` `getDetailById` `getXxx2Xxx` `getXxxByXxxId` `processXxxXxxByXxx` `transferXxx2Xxx` `getXxxXxxTreeByParent-异步树` `getXxxXxxTreeByAll-同步树` `addXxxXxx` `updateXxxXxx` `deleteXxxXxx` `saveXxxXxxByAaaXxx` `setXxxXxxEnable`。`Mapper & Controller & Service & Component` 均要遵循

**命名风格**：类 `PascalCase`，方法/变量 `camelCase`，常量 `UPPER_SNAKE_CASE`；Java 17+ LTS；Lombok `@Data` + `@Accessors(chain = true)`。

---

## 五、Entity 层规范

| 级别 | 规范要求                                                          | 正确写法                                                                |
| ---- | ----------------------------------------------------------------- | ----------------------------------------------------------------------- |
| 🔴    | 布尔/状态字段类型必须是 `String`，禁止 `Boolean` / `Integer`      | `private String enabled;`                                               |
| 🔴    | 小数字段必须用 `BigDecimal`，禁止 `float` / `double`              | `private BigDecimal amount;`                                            |
| 🟡    | 必须继承 `BaseEntity`，加 `@EqualsAndHashCode(callSuper = false)` | —                                                                       |
| 🟡    | 表名用 `@TableName`，主键用 `@TableId`，其余字段用 `@TableField`  | 主键雪花ID，类型 `String`                                               |
| 🟡    | 必须有四个 Lombok 注解                                            | `@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)` |
| 🟡    | 历史表 Entity 主键字段名必须为 `seqno`                            | `@TableId("seqno") private String seqno;`                               |

---

## 六、QVO / RVO / DTO 协议类规范

| 级别 | 规范要求                                                                         | 正确写法                  |
| ---- | -------------------------------------------------------------------------------- | ------------------------- |
| 🔴    | QVO 中 `companyId` 必须加 `@JsonIgnore`                                          | 防止前端传入伪造租户ID    |
| 🔴    | 脱敏注解只能标在 RVO，严禁标在 QVO / Entity / DTO                                | —                         |
| 🟡    | QVO / RVO 必须实现 `Serializable`                                                | `implements Serializable` |
| 🟡    | 所有协议类必须使用 `@Schema`（Swagger/Knife4j）注解                              | —                         |
| 🟡    | 入参校验使用 `jakarta.validation`（`@NotNull` `@NotEmpty` `@Min` `@Pattern` 等） | —                         |
| 🟡    | 分页 QVO 继承 `PageQVO`（已封装 `current`、`pageSize`）                          | —                         |
| 🟡    | 树形 RVO 继承 `BaseTreeVO`（已封装 `childrenCount`、`hasChildren`、`children`）  | —                         |
| 🔵    | RVO 不应暴露不必要的内部字段                                                     | 如内部状态码、系统字段    |

---

## 七、Mapper 层规范

| 级别 | 规范要求                                                                                     | 正确写法                                                                                        |
| ---- | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| 🔴    | 分页查询 入参必须是 `Page<XxxXxxPageQVO> page`, page中包含了 `current` `pageSize` `isNoPage` | 1. 参数拼接`#{record.xxx}`;  2. 分页limit：`<if test="!isNoPage"> #{current},#{pageSize} </if>` |
| 🟡    | Mapper 必须继承 `BaseMapperX<T, Id>`，Id 一般是 `String`                                     | —                                                                                               |
| 🟡    | 读操作必须加 `@DS(CommonDataSourceConst.SLAVE)`                                              | 从库查询                                                                                        |
| 🟡    | 强制使用 `LambdaQueryWrapperX` 保持类型安全                                                  | —                                                                                               |
| 🟡    | 简单单表查询写 `default` 方法，联表/子查询/动态条件走 XML + `@Param`                         | —                                                                                               |
| 🟡    | XML 中 `@Param` 参数名必须与 `#{param}` 一致                                                 | —                                                                                               |
| 🟡    | 所有查询必须在 Mapper 类中定义，禁止在 Service 中写 `LambdaQueryWrapperX`                    | —                                                                                               |
| 🟡    | 简单 CRUD 直接调用封装方法：`getById` `insert` `updateById` `deleteById` 等                  | —                                                                                               |
| 🔵    | `LambdaQueryWrapperX` 条件链不超过 8 个，超过拆方法或用 XML                                  | —                                                                                               |

---

## 八、Service 层规范

| 级别 | 规范要求                                                                                              | 正确写法                                                  |
| ---- | ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| 🔴    | 类级别必须有 `@Transactional(readOnly = true)`                                                        | 避免读操作占用写锁                                        |
| 🔴    | 所有写操作方法（insert/update/delete/状态变更）必须有 `@Transactional(rollbackFor = Exception.class)` | —                                                         |
| 🔴    | 写操作后必须调用 `addHistory()`，历史表主键用 `seqno`                                                 | `entityH.setSeqno(baseIdeable.generateId())`              |
| 🔴    | 调用外部 RPC 后必须判断 `result.isFailed()`                                                           | `if (result.isFailed()) throw new BusinessException(...)` |
| 🔴    | 非致命子步骤失败时必须 `log.error(...)` 输出完整异常，禁止空 catch                                    | `catch (Exception e) { log.error("子步骤失败", e); }`     |
| 🔴    | 禁止 `new RuntimeException`，统一用 `BusinessException`                                               | `throw new BusinessException(SysResult.ERROR_XXX, "msg")` |
| 🔴    | 需要身份认证的接口必须调用 `GlobalHeaderThreadLocal.getOrException()`                                 | 禁止跳过此调用直接执行业务逻辑                            |
| 🔴    | 分页查询 必须申明 `Page<XxxXxxPageQVO> page`,显示调用 `page.setRecord(pageQvo)`                       | setRecord时，会自动计算 sql 所需的 limit 参数             |

| 🟡    | 所有写操作开头必须调 `GlobalHeaderThreadLocal.getOrException()` 获取租户上下文                            | —                                                                                              |
| 🟡    | 当前登录人信息从 ThreadLocal 获取，禁止从入参 QVO 取 `userId`                                             | `GlobalHeader h = GlobalHeaderThreadLocal.getOrException();`                                   |
| 🟡    | `companyId` 为空时从 ThreadLocal 补全                                                                     | `if (StringUtil.isEmptyNull(qvo.getCompanyId())) qvo.setCompanyId(globalHeader.getTenantId())` |
| 🟡    | 修改操作须保留 `createTime` / `createUser`                                                                | `entity.setCreateTime(exist.getCreateTime())`                                                  |
| 🟡    | 对象转换用 `DataUtil.copyTo()`，没有的字段手动逐字段 set；禁止使用其它工具转换对象 | `DataUtil.copyTo(qvo, Entity.class)` `DataUtil.copyTo(list, Entity.class)`|
| 🟡    | 集合判空用 `CollectionUtil`，字符串判空用 `StringUtil`                                                    | 禁止直接 `.isEmpty()` / `== null`                                                              |
| 🟡    | 分页查询返回必须是 `PageRVO<T>`                                                                           | —                                                                                              |
| 🟡    | 树结构构造工具：`TreeBuildUtil.buildTree(List<T extends BaseTreeVO>, Entity::getId, Entity::getParentId)` | —                                                                                              |
| 🟡    | 有树状查询时，必须同时实现同步和异步两套接口及业务逻辑                                                    | —                                                                                              |


| 🔵    | Stream 操作避免多层嵌套，超过 3 步拆私有方法                                                              | —                                                                                              |
| 🔵    | 删除操作前检查是否被引用                                                                                  | `throw new BusinessException(..., "xxx被使用，无法删除")`                                      |

---

## 九、Controller 层规范

| 级别 | 规范要求                                                                   | 正确写法                                          |
| ---- | -------------------------------------------------------------------------- | ------------------------------------------------- |
| 🟡    | 类必须继承 `BaseController`，并加 `@Validated`                             | —                                                 |
| 🟡    | POST 入参 QVO 必须加 `@Valid`                                              | `@RequestBody @Valid XxxQVO qvo`                  |
| 🟡    | GET 对象入参用 `@ModelAttribute`，不用 `@RequestBody`                      | `@ModelAttribute @Valid XxxPageQVO qvo`           |
| 🟡    | 包路径：管理端 → `controller/admin/`；移动端 → `controller/app/`           | —                                                 |
| 🟡    | `@Tag` 命名：管理端 `管理端{业务域}-{序号}-{功能}`；移动端 `移动端-{功能}` | `@Tag(name = "管理端费用-01-费用单管理")`         |
| 🟡    | 单个 `@RequestParam` / `@PathVariable` 都需在方法上面对应一个 `@Parameter` | 参数顺序须一致                                    |
| 🟡    | 使用加解密注解时，`@Operation` description 需注明                          | `description = "参数需要加密"` / `"返回需要解密"` |
| 🟡    | 使用脱敏字段时，`@Schema` description 含"脱敏"字样                         | `description = "手机号（脱敏）"`                  |
| 🟡    | 返回值统一用 `Result<T>`，使用 `Result.success()`                          | —                                                 |
| 🔵    | 业务逻辑严禁写在 Controller，仅负责参数转换与调用                          | —                                                 |

---

## 十、Component 层规范

**职责**（满足以下任一即应抽为 Component）：

- 封装第三方 SDK（OSS、SMS、支付等）
- 涉及多 Mapper 的复杂 SQL 聚合计算
- 封装可复用的通用计算逻辑

**示例**：`OrderComponent.calculateByOrder(Order orderEntity)`

---

## 十一、DDL / 数据库规范

| 级别 | 规范要求                                                             | 说明                                      |
| ---- | -------------------------------------------------------------------- | ----------------------------------------- |
| 🔴    | 每张业务主表必须同时有历史表（`_h` 后缀）                            | 纯记录表（如短信记录）例外                |
| 🔴    | 历史表主键字段名必须为 `seqno`，类型 `varchar(32)`                   | —                                         |
| 🔴    | 主键必须是雪花ID，`varchar(32)`，禁止自增ID                          | —                                         |
| 🔴    | 状态字段类型必须是 `char`，禁止 `int` / `bit`                        | `enabled char(1) NOT NULL DEFAULT '1'`    |
| 🔴    | 禁止使用关键字作为字段名                                             | `enable` `status` `comment` `password` 等 |
| 🔴    | 禁止使用外键                                                         | -                                         |
| 🟡    | 小数字段用 `decimal`，禁止 `float` / `double`                        | —                                         |
| 🟡    | 时间字段用 `datetime`，禁止 `timestamp`                              | —                                         |
| 🟡    | 表名不超过 30 字符，字段数不超过 30 个                               | —                                         |
| 🟡    | `varchar` 长度不超过 2000，超过用扩展表 + `text`                     | —                                         |
| 🟡    | 所有表必须有 `create_user / create_time / update_user / update_time` | —                                         |
| 🟡    | 字典类字段注释需注明字典类型                                         | `COMMENT '性别【数据字典-Sex】'`          |

---

## 十二、日志规范

| 级别 | 规范要求                                          | 正确写法                                                             |
| ---- | ------------------------------------------------- | -------------------------------------------------------------------- |
| 🔴    | 关键写操作入口必须有 `log.info`                   | `log.info("创建费用单, userId={}, companyId={}", userId, companyId)` |
| 🔴    | 业务校验失败用 `log.warn`，携带上下文参数         | `log.warn("费用单状态不合法, id={}, status={}", id, status)`         |
| 🔴    | 未预期异常用 `log.error`，传入完整异常对象        | `log.error("处理费用单异常, id={}", id, e)`                          |
| 🔴    | 禁止在日志中输出敏感数据（密码、Token、手机号等） | 脱敏或移除后再打印                                                   |
| 🟡    | 必须使用 SLF4J，禁止 `System.out.println`         | `@Slf4j` 或 `LoggerFactory.getLogger(...)`                           |
| 🟡    | 日志占位符使用 `{}`，禁止字符串拼接               | `log.info("id={}", id)`（✗ `"id=" + id`）                            |
| 🔵    | 批量操作在循环外打印汇总日志                      | `log.info("批量处理完成, total={}, success={}", total, success)`     |

---

## 十三、异常处理规约

- **不主动显式 try-catch**：业务异常通过 `throw new BusinessException(ErrorCode.XXX)` 抛出。
- **全局捕获**：脚手架已封装 `@RestControllerAdvice`，拦截并转为 `Result.fail(code, msg)`。
- **错误码**：使用枚举 `ErrorCode` 维护，包含状态码和默认文案。
- **子步骤异常**：非致命子步骤 catch 后 `log.error` 记录，主流程继续或按需回滚。

---

## 十四、提交前自检清单

> 写完代码后逐项过一遍，全部通过再提交。

### 🔴 必须检查项（任何一项不通过，禁止提交）

- [ ] ServiceImpl 类级别有 `@Transactional(readOnly = true)`
- [ ] 所有写操作方法有 `@Transactional(rollbackFor = Exception.class)`
- [ ] 写操作后调用了 `addHistory()`，历史表主键用 `seqno`
- [ ] 调用外部 RPC 后判断了 `result.isFailed()`
- [ ] 没有空 `catch`，异常均有 `log.error(e)` 输出
- [ ] 异常抛出使用 `BusinessException`，没有 `new RuntimeException`
- [ ] 需要认证的接口调用了 `GlobalHeaderThreadLocal.getOrException()`
- [ ] Entity 状态字段是 `String`，小数字段是 `BigDecimal`
- [ ] QVO 中 `companyId` 有 `@JsonIgnore`
- [ ] 脱敏注解只标在 RVO，没有出现在 QVO / Entity / DTO
- [ ] DDL 有对应历史表（`_h`），主键是雪花ID `varchar(32)`，状态字段是 `char(1)`
- [ ] 关键写操作入口有 `log.info`，校验失败用 `log.warn`，异常用 `log.error`

### 🟡 应当检查项

- [ ] 依赖注入全部用 `@Resource`，没有 `@Autowired`
- [ ] 没有使用 FastJSON，JSON 操作用 `JsonUtil`
- [ ] Controller 继承 `BaseController`，类上有 `@Validated`
- [ ] POST 入参有 `@Valid`，GET 对象入参用 `@ModelAttribute`
- [ ] 当前登录人从 ThreadLocal 获取，没有从 QVO 取 `userId`
- [ ] `companyId` 为空时从 ThreadLocal 补全，而非依赖前端传参
- [ ] 对象转换用 `DataUtil.copyTo()`，没有手动逐字段 set
- [ ] 修改操作保留了 `createTime` / `createUser`
- [ ] Mapper 读操作有 `@DS(SLAVE)`
- [ ] QVO/RVO 实现了 `Serializable`
- [ ] 分页查询返回 `PageRVO<T>`，树形查询同时实现同步和异步接口
- [ ] 所有查询方法定义在 Mapper 类中，Service 中无 `LambdaQueryWrapperX`

## 十五、参考文档

详细框架能力参见：

- `references/framework-tools.md` — 工具类（CollectionUtil / StringUtil / DataUtil 等）
- `references/framework-encrypt.md` — 加解密 / 脱敏注解用法
- `references/framework-kafka.md` — Kafka 使用规范
- `references/framework-doris.md` — Doris 写入 / @DorisTransactional
- `references/framework-ratelimit.md` — @Limit 限流用法
- `references/framework-redisson.md` — Redisson 分布式锁（`RedissonLockService`）用法
- `references/framework-redis.md` — `IRedisExtCommands` Redis 缓存操作（String / Hash / SortedSet / Key 全覆盖）
- `references/framework-jwt.md` — JWT 使用
