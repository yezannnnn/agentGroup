---
name: skill-backend-review
description: >
  对盛橙云后端 Java 代码做 Code Review，输出结构化问题清单，并按严重程度分级。
  触发方式：用户给出文件路径或目录路径，Agent 自动读取代码并 Review。
  只要涉及后端代码审查、提交前检查、生成 Review 报告、发现规范违规、
  命名问题、事务缺失、历史表遗漏、NPE 风险、VO 混用等场景，必须使用此 Skill。
  写完一个模块的代码后，也应主动触发此 Skill 做自检。
  规范依据：与 Jarvis skill-backend-standards 完全对齐，覆盖技术栈、模块结构、
  分层设计、编码约束等全部规范条目。
---

# 后端 Code Review 规范

> **严重程度说明**
>
> - 🔴 **必改**：会导致 bug、数据错误、安全问题，**不允许通过**
> - 🟡 **应改**：违反团队规范，影响可维护性，**必须整改**
> - 🔵 **建议**：代码质量优化，可选

---

## 一、使用方式

用户给出路径，Agent 自动读取并 Review：

```
# 单文件
请 Review 这个文件：src/main/java/com/.../XxxServiceImpl.java

# 整个模块
请 Review 整个模块：cloud-backend/sc-cloud-form-server/src/main/java
```

**单文件**：用 `view` 工具读取后直接 Review。

**模块目录**：用 `bash` 列出所有 `.java` 文件，逐文件读取，最后汇总输出模块级报告。

```bash
find {目录路径} -name "*.java" | sort
```

---

## 二、Review 流程

1. **识别代码类型**：Controller / ServiceImpl / Mapper / Entity / QVO/DTO/RVO / MapperXml / DDL
2. **按对应规则集逐条检查**（见第三节）
3. **输出结构化报告**（见第四节格式）
4. **主动给出修复建议**，不只是指出问题

---

## 三、检查规则集

---

### 3.1 模块目录结构

🔴 **必须严格遵守目录结构**，如果代码放错模块，直接标记必改。

```
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

### 3.2 通用规则（所有层适用）

| 级别 | 规则                                                  | 错误示例                               | 正确示例                          |
| ---- | ----------------------------------------------------- | -------------------------------------- | --------------------------------- |
| 🟡    | 依赖注入用 `@Resource`，禁止 `@Autowired`             | `@Autowired private XxxService s;`     | `@Resource private XxxService s;` |
| 🟡    | 禁止使用 FastJSON；JSON 操作使用项目封装的 `JsonUtil` | `JSON.parseObject(...)` / `JSONObject` | `JsonUtil.parseObject(...)`       |
| 🔵    | 命名语义清晰，禁止拼音缩写                            | `String spbm;`                         | `String expenseTypeCode;`         |
| 🔵    | 不允许无意义注释（复制粘贴遗留、已注释大段代码）      | `// TODO fix later`（存在超过1周）     | 删除或处理                        |

**方法命名风格**：`getXxxByPage` `getDetailById` `getXxx2Xxx` `getXxxByXxxId` `processXxxXxxByXxx` `transferXxx2Xxx` `getXxxXxxTreeByParent-异步树` `getXxxXxxTreeByAll-同步树` `addXxxXxx` `updateXxxXxx` `deleteXxxXxx` `saveXxxXxxByAaaXxx` `setXxxXxxEnable`。`Mapper & Controller & Service & Component` 均要遵循。

**命名风格**：类 `PascalCase`，方法/变量 `camelCase`，常量 `UPPER_SNAKE_CASE`；Java 17+ LTS；Lombok `@Data` + `@Accessors(chain = true)`。

---

### 3.3 Controller 层

| 级别 | 规则                                                            | 检查点                                                          |
| ---- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| 🟡    | 类必须继承 `BaseController`，并加 `@Validated`                  | `extends BaseController` + `@Validated` 在类级别                |
| 🟡    | POST 入参 QVO 必须有 `@Valid`                                   | `@RequestBody @Valid XxxQVO qvo`                                |
| 🟡    | GET 对象入参用 `@ModelAttribute`，不用 `@RequestBody`           | `@ModelAttribute @Valid XxxPageQVO qvo`                         |
| 🟡    | Controller 包路径必须正确                                       | 管理端 → `controller/admin/`；移动端 → `controller/app/`        |
| 🟡    | `@Tag` 命名格式                                                 | 管理端：`管理端{业务域}-{序号}-{功能}`；移动端：`移动端-{功能}` |
| 🟡    | `@RequestParam` / `@PathVariable` 每个参数对应一个 `@Parameter` | 参数顺序须一致                                                  |
| 🟡    | 使用加解密注解时，`@Operation` description 需注明               | `description = "参数需要加密"` / `"返回需要解密"`               |
| 🟡    | 使用脱敏字段时，`@Schema` description 需含「脱敏」字样          | `description = "手机号（脱敏）"`                                |
| 🟡    | 返回值统一用 `Result<T>`，使用 `Result.success()`               | —                                                               |
| 🔵    | 业务逻辑严禁写在 Controller，仅负责参数转换与调用               | —                                                               |

---

### 3.4 Service 层

| 级别 | 规则                                                                                                      | 检查点                                                                                         |
| ---- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| 🔴    | 类级别必须有 `@Transactional(readOnly = true)`                                                            | 避免读操作占用写锁                                                                             |
| 🔴    | 所有写操作方法（insert/update/delete/状态变更）必须有 `@Transactional(rollbackFor = Exception.class)`     | —                                                                                              |
| 🔴    | 写操作后必须调用 `addHistory()`，历史表主键必须用 `seqno`                                                 | `entityH.setSeqno(baseIdeable.generateId())`                                                   |
| 🔴    | 调用外部 RPC 后必须判断 `result.isFailed()`                                                               | `if (result.isFailed()) throw new BusinessException(...)`                                      |
| 🔴    | 非致命子步骤失败时必须 `log.error(...)` 输出完整异常，禁止空 catch 吞掉异常                               | `catch (Exception e) { log.error("子步骤失败", e); }` 不可写空 catch                           |
| 🔴    | 禁止 `new RuntimeException`，统一用 `BusinessException`                                                   | `throw new BusinessException(SysResult.ERROR_XXX, "msg")`                                      |
| 🔴    | 需要身份认证的接口必须调用 `GlobalHeaderThreadLocal.getOrException()`                                     | 禁止跳过此调用直接执行业务逻辑                                                                 |
| 🔴    | 分页查询必须申明 `Page<XxxXxxPageQVO> page`，显式调用 `page.setRecord(pageQvo)`                           | setRecord 时会自动计算 SQL 所需的 limit 参数                                                   |
| 🟡    | 所有写操作开头必须调 `GlobalHeaderThreadLocal.getOrException()` 获取租户上下文                            | —                                                                                              |
| 🟡    | 当前登录人信息从 ThreadLocal 获取，禁止从入参 QVO 取 `userId`                                             | `GlobalHeader h = GlobalHeaderThreadLocal.getOrException();`                                   |
| 🟡    | `companyId` 为空时从 ThreadLocal 补全                                                                     | `if (StringUtil.isEmptyNull(qvo.getCompanyId())) qvo.setCompanyId(globalHeader.getTenantId())` |
| 🟡    | 修改操作须保留 `createTime` / `createUser`                                                                | `entity.setCreateTime(exist.getCreateTime())`                                                  |
| 🟡    | 对象转换用 `DataUtil.copyTo()`，没有的字段手动逐字段 set；禁止使用其它工具转换对象                        | `DataUtil.copyTo(qvo, Entity.class)` / `DataUtil.copyTo(list, Entity.class)`                   |
| 🟡    | 集合判空用 `CollectionUtil`，字符串判空用 `StringUtil`                                                    | 禁止直接 `.isEmpty()` / `== null`                                                              |
| 🟡    | 分页查询返回必须是 `PageRVO<T>`                                                                           | —                                                                                              |
| 🟡    | 树结构构造工具：`TreeBuildUtil.buildTree(List<T extends BaseTreeVO>, Entity::getId, Entity::getParentId)` | —                                                                                              |
| 🟡    | 有树状查询时，必须同时实现同步和异步两套接口及业务逻辑                                                    | —                                                                                              |
| 🔵    | Stream 操作避免多层嵌套，超过 3 步拆私有方法                                                              | —                                                                                              |
| 🔵    | 删除操作前检查是否被引用，有引用时抛明确提示                                                              | `throw new BusinessException(..., "xxx被使用，无法删除")`                                      |

---

### 3.5 Mapper 层

| 级别 | 规则                                                                                       | 检查点                                                                                     |
| ---- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| 🔴    | 分页查询入参必须是 `Page<XxxXxxPageQVO> page`，page 中包含 `current` `pageSize` `isNoPage` | 参数拼接 `#{record.xxx}`；分页 limit：`<if test="!isNoPage"> #{current},#{pageSize} </if>` |
| 🟡    | Mapper 必须继承 `BaseMapperX<T, Id>`，Id 一般是 `String`                                   | —                                                                                          |
| 🟡    | 读操作必须加 `@DS(CommonDataSourceConst.SLAVE)`                                            | 从库查询                                                                                   |
| 🟡    | 强制使用 `LambdaQueryWrapperX` 保持类型安全                                                | —                                                                                          |
| 🟡    | 简单单表查询写 `default` 方法，联表/子查询/动态条件走 XML + `@Param`                       | —                                                                                          |
| 🟡    | XML 中 `@Param` 参数名必须与 `#{param}` 一致                                               | —                                                                                          |
| 🟡    | 所有查询必须在 Mapper 类中定义，禁止在 Service 中写 `LambdaQueryWrapperX`                  | —                                                                                          |
| 🟡    | 简单 CRUD 直接调用封装方法：`getById` `insert` `updateById` `deleteById` 等                | —                                                                                          |
| 🔵    | `LambdaQueryWrapperX` 条件链不超过 8 个，超过拆方法或用 XML                                | —                                                                                          |

---

### 3.6 Entity 层

| 级别 | 规则                                                              | 检查点                                                                  |
| ---- | ----------------------------------------------------------------- | ----------------------------------------------------------------------- |
| 🔴    | 布尔/状态字段类型必须是 `String`，禁止 `Boolean` / `Integer`      | `private String enabled;`                                               |
| 🔴    | 小数字段必须用 `BigDecimal`，禁止 `float` / `double`              | `private BigDecimal amount;`                                            |
| 🟡    | 必须继承 `BaseEntity`，加 `@EqualsAndHashCode(callSuper = false)` | —                                                                       |
| 🟡    | 表名用 `@TableName`，主键用 `@TableId`，其余字段用 `@TableField`  | 主键雪花ID，类型 `String`                                               |
| 🟡    | 必须有四个 Lombok 注解                                            | `@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)` |
| 🟡    | 历史表 Entity 主键字段名必须为 `seqno`                            | `@TableId("seqno") private String seqno;`                               |

---

### 3.7 QVO / RVO / DTO 协议类

| 级别 | 规则                                                                             | 检查点                    |
| ---- | -------------------------------------------------------------------------------- | ------------------------- |
| 🔴    | QVO 中 `companyId` 必须加 `@JsonIgnore`                                          | 防止前端传入伪造租户ID    |
| 🔴    | 脱敏注解只能标在 RVO，严禁标在 QVO / Entity / DTO                                | —                         |
| 🟡    | QVO / RVO 必须实现 `Serializable`                                                | `implements Serializable` |
| 🟡    | 所有协议类必须使用 `@Schema`（Swagger/Knife4j）注解                              | —                         |
| 🟡    | 入参校验使用 `jakarta.validation`（`@NotNull` `@NotEmpty` `@Min` `@Pattern` 等） | —                         |
| 🟡    | 分页 QVO 继承 `PageQVO`（已封装 `current`、`pageSize`）                          | —                         |
| 🟡    | 树形 RVO 继承 `BaseTreeVO`（已封装 `childrenCount`、`hasChildren`、`children`）  | —                         |
| 🔵    | RVO 不应暴露不必要的内部字段（如内部状态码、系统字段）                           | —                         |

---

### 3.8 DDL / 数据库

| 级别 | 规则                                                                 | 检查点                                       |
| ---- | -------------------------------------------------------------------- | -------------------------------------------- |
| 🔴    | 每张业务主表必须同时有历史表（`_h` 后缀）                            | 纯记录表例外（如短信记录、上传记录）         |
| 🔴    | 历史表主键字段名必须为 `seqno`，类型 `varchar(32)`                   | —                                            |
| 🔴    | 主键必须是雪花ID，`varchar(32)`，禁止自增 ID                         | —                                            |
| 🔴    | 状态字段类型必须是 `char`，禁止 `int` / `bit`                        | `enabled char(1) NOT NULL DEFAULT '1'`       |
| 🔴    | 禁止使用关键字作为字段名                                             | `enable`、`status`、`comment`、`password` 等 |
| 🔴    | 禁止使用外键                                                         | —                                            |
| 🟡    | 小数字段用 `decimal`，禁止 `float` / `double`                        | —                                            |
| 🟡    | 时间字段用 `datetime`，禁止 `timestamp`                              | —                                            |
| 🟡    | 表名不超过 30 字符，字段数不超过 30 个                               | —                                            |
| 🟡    | `varchar` 长度不超过 2000，超过用扩展表 + `text`                     | —                                            |
| 🟡    | 所有表必须有 `create_user / create_time / update_user / update_time` | —                                            |
| 🟡    | 字典类字段注释需注明字典类型                                         | `COMMENT '性别【数据字典-Sex】'`             |

---

### 3.9 日志规范

| 级别 | 规则                                                              | 错误示例                                    | 正确示例                                                                |
| ---- | ----------------------------------------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------- |
| 🔴    | 关键写操作（创建、更新、删除、状态变更）方法入口必须有 `log.info` | 方法体无任何日志                            | `log.info("创建费用单, userId={}, companyId={}", userId, companyId)`    |
| 🔴    | 业务校验失败必须用 `log.warn`，并携带上下文参数值                 | `throw new BusinessException(...)` 前无日志 | `log.warn("费用单状态不合法, id={}, status={}", id, status)`            |
| 🔴    | 未预期异常必须用 `log.error`，并传入完整异常对象（打印堆栈）      | `log.error("出错了")`                       | `log.error("处理费用单异常, id={}", id, e)`                             |
| 🔴    | 禁止在日志中输出敏感数据（密码、Token、手机号等）                 | `log.info("token={}", token)`               | 脱敏或移除敏感字段后再打印                                              |
| 🟡    | 必须使用 SLF4J，禁止 `System.out.println`                         | `System.out.println(...)`                   | `@Slf4j` 或 `LoggerFactory.getLogger(...)`                              |
| 🟡    | 日志占位符使用 `{}`，禁止字符串拼接                               | `log.info("id=" + id)`                      | `log.info("id={}", id)`                                                 |
| 🔵    | 批量操作在循环外打印汇总日志，避免日志量过大                      | 循环内每条都 `log.info`                     | 循环后 `log.info("批量处理完成, total={}, success={}", total, success)` |

---

### 3.10 异常处理

| 规则                                                                                 | 说明                                                  |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------- |
| 不主动显式 try-catch，业务异常通过 `throw new BusinessException(ErrorCode.XXX)` 抛出 | 全局 `@RestControllerAdvice` 统一拦截转 `Result.fail` |
| 错误码使用枚举 `ErrorCode` 维护，包含状态码和默认文案                                | —                                                     |
| 非致命子步骤 catch 后 `log.error` 记录，主流程继续或按需回滚                         | —                                                     |

---

## 四、输出格式

### 单文件/片段 Review

```
## Code Review 报告 · {文件名或"代码片段"}

### 🔴 必改（{N} 项）
| #   | 位置                             | 问题                        | 修复建议                                                   |
| --- | -------------------------------- | --------------------------- | ---------------------------------------------------------- |
| 1   | `XxxServiceImpl#addXxx` 第 42 行 | 写操作缺少 `@Transactional` | 在方法上加 `@Transactional(rollbackFor = Exception.class)` |
| 2   | `addXxx` 方法末尾                | 未调用 `addHistory()`       | 在 `xxxMapper.insert(entity)` 后添加 `addHistory(entity)`  |

### 🟡 应改（{N} 项）
| #   | 位置                     | 问题                | 修复建议         |
| --- | ------------------------ | ------------------- | ---------------- |
| 1   | `XxxController` 第 15 行 | 使用了 `@Autowired` | 改为 `@Resource` |

### 🔵 建议（{N} 项）
| #   | 位置              | 问题                      | 建议             |
| --- | ----------------- | ------------------------- | ---------------- |
| 1   | `getXxxList` 方法 | Stream 三层嵌套，可读性差 | 拆为独立私有方法 |

### ✅ 通过项
- 事务注解使用正确
- 历史表写入完整
- 对象转换使用 DataUtil

---
**汇总：🔴 必改 {N} | 🟡 应改 {N} | 🔵 建议 {N}**
```

### 模块级 Review（多文件）

```
## 模块 Code Review 报告 · {模块名}
> 扫描文件数：{N}  |  发现问题：🔴 {N} / 🟡 {N} / 🔵 {N}

### 高频问题 TOP 3
1. 🔴 **未调用 addHistory()**：出现在 3 个 ServiceImpl
2. 🟡 **@Autowired 未改为 @Resource**：出现在 5 个文件
3. 🟡 **状态字段使用 Boolean**：出现在 2 个 Entity

### 各文件详情
#### XxxServiceImpl.java —— 🔴 2项 / 🟡 1项
...（同单文件格式）

#### XxxEntity.java —— 🔴 1项
...

### 📋 问题汇总表（供复盘留存）
| 文件           | 级别 | 问题描述                          |
| -------------- | ---- | --------------------------------- |
| XxxServiceImpl | 🔴    | 第42行：写操作缺少 @Transactional |
...
```

---

## 五、提交前审查清单

> Review 结束后，逐项核对，全部通过才可判定代码合格。

### 🔴 必须通过项（任一不通过，代码不可合并）

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
- [ ] 没有使用外键
- [ ] 关键写操作入口有 `log.info`，校验失败用 `log.warn`，异常用 `log.error`

### 🟡 应当通过项

- [ ] 依赖注入全部用 `@Resource`，没有 `@Autowired`
- [ ] 没有使用 FastJSON，JSON 操作用 `JsonUtil`
- [ ] Controller 继承 `BaseController`，类上有 `@Validated`
- [ ] POST 入参有 `@Valid`，GET 对象入参用 `@ModelAttribute`
- [ ] 当前登录人从 ThreadLocal 获取，没有从 QVO 取 `userId`
- [ ] `companyId` 为空时从 ThreadLocal 补全，而非依赖前端传参
- [ ] 对象转换用 `DataUtil.copyTo()`
- [ ] 修改操作保留了 `createTime` / `createUser`
- [ ] Mapper 继承 `BaseMapperX<T, Id>`，读操作有 `@DS(SLAVE)`
- [ ] 所有查询方法定义在 Mapper 类中，Service 中无 `LambdaQueryWrapperX`
- [ ] QVO/RVO 实现了 `Serializable`，协议类有 `@Schema` 注解
- [ ] 分页查询返回 `PageRVO<T>`，树形查询同时实现同步和异步接口
- [ ] 分页 QVO 继承 `PageQVO`，树形 RVO 继承 `BaseTreeVO`

---

## 六、注意事项

- 只报告**确实存在的问题**，不要对看不到的代码做假设性指摘
- 给出的修复建议必须是**可直接复制执行的代码**，不是泛泛而谈
- 模块扫描时优先检查 ServiceImpl > Controller > Entity > Mapper > QVO/RVO，按此顺序报告
- 如代码质量整体较好，明确说「本次 Review 无必改项」，增强信心
- 发现同类问题在多个文件重复出现时，在「高频问题」中汇总，并提示可以批量修复
