---
name: backend-coding-standards
description: >
  后端 Java 开发编码基础规范，贾维斯在编写后端代码时必须遵守，写完模块后主动自检。
  触发场景：开始编写 Controller / ServiceImpl / Mapper / Entity / QVO/RVO/DTO / Component 时；
  写完代码准备提交前；用户要求按规范实现某功能时。
  规范覆盖：依赖注入方式、事务注解、历史表写入、异常处理、日志规范、
  对象转换、工具类使用、VO设计、DDL规范等。
  重要：代码写完后必须主动按此规范做自检，发现问题立即修复再提交。
---

# 后端 Java 编码规范（贾维斯开发手册）

> 本规范是**编码约束**，不是事后检查。写代码时参照，写完后对照自检清单过一遍。

## 一、严重程度说明

> - 🔴 **必须**：违反会导致 bug、数据错误、安全问题，**不允许提交**
> - 🟡 **应当**：违反团队规范，影响可维护性，**必须遵守**
> - 🔵 **建议**：代码质量优化，**尽量遵守**

---

## 二、通用规范（所有层适用）

| 级别 | 规范要求                                         | 正确写法                                      |
| ---- | ------------------------------------------------ | --------------------------------------------- |
| 🟡    | 依赖注入使用 `@Resource`，禁止 `@Autowired`      | `@Resource private XxxService xxxService;`    |
| 🟡    | 禁止使用 FastJSON；使用项目封装的 `JsonUtil`     | `JsonUtil.parseObject(str, Xxx.class)`        |
| 🔵    | 类、方法、变量命名必须语义清晰，禁止拼音缩写     | `String expenseTypeCode;`（✗ `String spbm;`） |
| 🔵    | 不保留无意义注释（复制粘贴遗留、已注释大段代码） | 删除或处理，不留 `// TODO fix later`（超1周） |

---

## 三、Controller 层规范

| 级别 | 规范要求                                                                       | 正确写法                                            |
| ---- | ------------------------------------------------------------------------------ | --------------------------------------------------- |
| 🟡    | 类必须继承 `BaseController`                                                    | `public class XxxController extends BaseController` |
| 🟡    | 类上必须有 `@Validated` 注解                                                   | `@Validated` 放在类级别                             |
| 🟡    | POST 入参 QVO 必须加 `@Valid`                                                  | `@RequestBody @Valid XxxQVO qvo`                    |
| 🟡    | GET 对象入参用 `@ModelAttribute`，不用 `@RequestBody`                          | `@ModelAttribute @Valid XxxPageQVO qvo`             |
| 🟡    | 包路径正确：管理端 → `controller/admin/`；移动端 → `controller/app/`           | 建包时确认路径                                      |
| 🟡    | `@Tag` 命名格式：管理端 `管理端{业务域}-{序号}-{功能}`；移动端 `移动端-{功能}` | `@Tag(name = "管理端费用-01-费用单管理")`           |
| 🟡    | 每个 `@RequestParam` / `@PathVariable` 都需对应一个 `@Parameter`               | 参数顺序须一致                                      |
| 🟡    | 使用加解密注解时，`@Operation` 的 description 需注明                           | `description = "参数需要加密"` / `"返回需要解密"`   |
| 🟡    | 使用脱敏注解的字段，`@Schema` description 需含"脱敏"字样                       | `description = "手机号（脱敏）"`                    |
| 🔵    | 返回值统一用 `Result.success()`，避免 `Result.ok()`                            | 新代码一律用 `success`                              |

---

## 四、Service 层规范

| 级别 | 规范要求                                                               | 正确写法                                                                                       |
| ---- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| 🔴    | 类级别必须有 `@Transactional(readOnly = true)`                         | 避免读操作占用写锁                                                                             |
| 🔴    | 多步骤写操作方法必须有 `@Transactional(rollbackFor = Exception.class)` | `insert` / `update` / `delete` / `setEnabled` 方法                                             |
| 🔴    | 非致命子步骤失败时必须 `log.error(...)` 输出完整异常，**禁止**空 catch | `catch (Exception e) { log.error("子步骤失败", e); }`                                          |
| 🔴    | 调用外部 RPC 后必须判断 `result.isFailed()`                            | `if (result.isFailed()) throw new BusinessException(...)`                                      |
| 🔴    | 写操作（insert/update/delete/状态变更）后必须调用 `addHistory()`       | 所有业务表均须写历史                                                                           |
| 🔴    | `addHistory()` 中历史表主键必须用 `seqno`                              | `entityH.setSeqno(baseIdeable.generateId())`                                                   |
| 🔴    | 禁止直接 `new RuntimeException`，统一用 `BusinessException`            | `throw new BusinessException(SysResult.ERROR_XXX, "msg")`                                      |
| 🔴    | 需要身份认证的接口必须调用 `GlobalHeaderThreadLocal.getOrException()`  | 禁止跳过此调用直接执行业务逻辑                                                                 |
| 🟡    | 所有写操作开头必须调 `GlobalHeaderThreadLocal.getOrException()`        | 获取租户上下文                                                                                 |
| 🟡    | 当前登录人信息从 ThreadLocal 获取，**禁止**从入参 QVO 取 `userId`      | `GlobalHeader h = GlobalHeaderThreadLocal.getOrException();`                                   |
| 🟡    | `companyId` 为空时从 ThreadLocal 补全                                  | `if (StringUtil.isEmptyNull(qvo.getCompanyId())) qvo.setCompanyId(globalHeader.getTenantId())` |
| 🟡    | 修改操作须保留 `createTime` / `createUser`                             | `entity.setCreateTime(exist.getCreateTime())`                                                  |
| 🟡    | 对象转换用 `DataUtil.copyTo()`，禁止手动逐字段 set                     | `DataUtil.copyTo(qvo, Entity.class)`                                                           |
| 🟡    | 集合判空用 `CollectionUtil`，字符串判空用 `StringUtil`                 | 禁止直接 `.isEmpty()` / `== null`                                                              |
| 🔵    | Stream 操作避免多层嵌套，超过 3 步拆私有方法                           | —                                                                                              |
| 🔵    | 删除操作前检查是否被引用                                               | `throw new BusinessException(..., "xxx被使用，无法删除")`                                      |

---

## 五、Mapper 层规范

| 级别 | 规范要求                                                    | 正确写法                     |
| ---- | ----------------------------------------------------------- | ---------------------------- |
| 🟡    | 读操作必须加 `@DS(CommonDataSourceConst.SLAVE)`             | 从库查询                     |
| 🟡    | 简单单表查询写 `default` 方法，禁止为简单查询写 XML         | 联表/子查询/动态条件才走 XML |
| 🟡    | XML 中的 `@Param` 参数名必须与 XML 中 `#{param}` 一致       | —                            |
| 🔵    | `LambdaQueryWrapperX` 条件链不超过 8 个，超过拆方法或用 XML | —                            |

---

## 六、Entity 层规范

| 级别 | 规范要求                                                         | 正确写法                                                                |
| ---- | ---------------------------------------------------------------- | ----------------------------------------------------------------------- |
| 🔴    | 布尔/状态字段类型必须是 `String`，禁止 `Boolean` / `Integer`     | `private String enabled;`                                               |
| 🔴    | 小数字段必须用 `BigDecimal`，禁止 `float` / `double`             | `private BigDecimal amount;`                                            |
| 🟡    | 必须继承 `BaseEntity`                                            | `public class XxxEntity extends BaseEntity`                             |
| 🟡    | 表名用 `@TableName`，主键用 `@TableId`，其余字段用 `@TableField` | —                                                                       |
| 🟡    | 必须有四个 Lombok 注解                                           | `@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)` |
| 🟡    | 历史表 Entity 主键字段名必须为 `seqno`                           | `@TableId("seqno") private String seqno;`                               |

---

## 七、QVO / RVO 层规范

| 级别 | 规范要求                                                                 | 正确写法                  |
| ---- | ------------------------------------------------------------------------ | ------------------------- |
| 🔴    | QVO 中 `companyId` 必须加 `@JsonIgnore`                                  | 防止前端传入伪造租户ID    |
| 🔴    | 脱敏注解（`@PhoneDesensitize` 等）只能标在 RVO 上，严禁标在 QVO / Entity | —                         |
| 🟡    | QVO / RVO 必须实现 `Serializable`                                        | `implements Serializable` |
| 🟡    | 分页 QVO 继承 `PageQVO`，树形 RVO 继承 `BaseTreeVO`                      | —                         |
| 🔵    | RVO 不应暴露不必要的内部字段                                             | 如内部状态码、系统字段    |

---

## 八、DDL / 数据库规范

| 级别 | 规范要求                                                             | 正确写法                                     |
| ---- | -------------------------------------------------------------------- | -------------------------------------------- |
| 🔴    | 每张业务主表必须同时有历史表（`_h` 后缀）                            | 纯记录表例外（如短信记录）                   |
| 🔴    | 历史表主键字段名必须为 `seqno`，类型 `varchar(32)`                   | —                                            |
| 🔴    | 主键必须是雪花ID，`varchar(32)`，禁止自增ID                          | —                                            |
| 🔴    | 状态字段类型必须是 `char`，禁止 `int` / `bit`                        | `enabled char(1) NOT NULL DEFAULT '1'`       |
| 🔴    | 禁止使用关键字作为字段名                                             | `enable`、`status`、`comment`、`password` 等 |
| 🟡    | 小数字段用 `decimal`，禁止 `float` / `double`                        | —                                            |
| 🟡    | 时间字段用 `datetime`，禁止 `timestamp`                              | —                                            |
| 🟡    | 表名不超过 30 字符，字段数不超过 30 个                               | —                                            |
| 🟡    | `varchar` 长度不超过 2000                                            | 超过用扩展表 + `text`                        |
| 🟡    | 所有表必须有 `create_user / create_time / update_user / update_time` | —                                            |
| 🟡    | 字典类字段描述需注明字典类型                                         | `COMMENT '性别【数据字典-Sex】'`             |

---

## 九、日志规范

| 级别 | 规范要求                                                          | 正确写法                                                             |
| ---- | ----------------------------------------------------------------- | -------------------------------------------------------------------- |
| 🔴    | 关键写操作（创建、更新、删除、状态变更）方法入口必须有 `log.info` | `log.info("创建费用单, userId={}, companyId={}", userId, companyId)` |
| 🔴    | 业务校验失败必须用 `log.warn`，并携带上下文参数值                 | `log.warn("费用单状态不合法, id={}, status={}", id, status)`         |
| 🔴    | 未预期异常必须用 `log.error`，并传入完整异常对象（打印堆栈）      | `log.error("处理费用单异常, id={}", id, e)`                          |
| 🔴    | 禁止在日志中输出敏感数据：密码、Token、真实存储路径、手机号等     | 脱敏或移除后再打印                                                   |
| 🟡    | 必须使用 SLF4J 接口，禁止直接用 `System.out.println`              | `@Slf4j` 或 `LoggerFactory.getLogger(...)`                           |
| 🟡    | 日志占位符使用 `{}`，禁止字符串拼接                               | `log.info("id={}", id)`（✗ `"id=" + id`）                            |
| 🔵    | 批量操作在循环外打印汇总日志                                      | `log.info("批量处理完成, total={}, success={}", total, success)`     |

---

## 十、提交前自检清单

> 写完代码后，对照以下清单逐项确认，全部通过再提交。

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
- [ ] 脱敏注解只标在 RVO，没有出现在 QVO / Entity
- [ ] DDL 有对应历史表（`_h`），主键是雪花ID `varchar(32)`
- [ ] 关键写操作入口有 `log.info`，校验失败用 `log.warn`，异常用 `log.error`

### 🟡 应当检查项

- [ ] 依赖注入全部用 `@Resource`
- [ ] 没有使用 FastJSON，JSON 操作用 `JsonUtil`
- [ ] Controller 继承 `BaseController`，类上有 `@Validated`
- [ ] POST 入参有 `@Valid`，GET 对象入参用 `@ModelAttribute`
- [ ] 当前登录人从 ThreadLocal 获取，没有从 QVO 取 `userId`
- [ ] 对象转换用 `DataUtil.copyTo()`，没有手动逐字段 set
- [ ] 修改操作保留了 `createTime` / `createUser`
- [ ] Mapper 读操作有 `@DS(SLAVE)`
- [ ] QVO/RVO 实现了 `Serializable`
