---
name: backend-review
description: >
  对后端 Java 代码做 Code Review，输出结构化问题清单，并按严重程度分级。
  触发方式：用户给出文件路径或目录路径，Agent 自动读取代码并 Review。
  只要涉及后端代码审查、提交前检查、生成 Review 报告、发现规范违规、
  命名问题、事务缺失、历史表遗漏、NPE 风险、VO 混用等场景，必须使用此 Skill。
---

# 后端 Code Review 规范（凯尔审查手册）

## 一、使用方式

用户给出路径，Agent 自动读取并 Review：

```
# 单文件
请 Review 这个文件：src/main/java/com/.../XxxServiceImpl.java

# 整个模块
请 Review 整个模块：sc-cloud-platform-form-server/src/main/java
```

**单文件**：用 `view` 工具读取后直接 Review。

**模块目录**：用 `bash` 列出所有 `.java` 文件，逐文件读取，最后汇总输出模块级报告。

```bash
find {目录路径} -name "*.java" | sort
```

---

## 二、Review 流程

1. **识别代码类型**：Controller / ServiceImpl / Mapper / Entity / QVO/RVO / MapperXml / DDL
2. **按对应规则集逐条检查**（见第三节）
3. **输出结构化报告**（见第四节格式）
4. **主动给出修复建议**，不只是指出问题

---

## 三、检查规则集

> 规则按严重程度分为三级：
> - 🔴 **必改**：会导致 bug、数据错误、安全问题
> - 🟡 **应改**：违反团队规范，影响可维护性
> - 🔵 **建议**：代码质量优化，可选

---

### 3.1 通用规则（所有类型适用）

| 级别 | 规则 | 错误示例 | 正确示例 |
| ---- | ---- | -------- | -------- |
| 🟡    | 依赖注入用 `@Resource`，禁止 `@Autowired` | `@Autowired private XxxService s;` | `@Resource private XxxService s;` |
| 🟡    | 禁止使用 FastJSON | `JSON.parseObject(...)` / `JSONObject` | `JsonUtil.parseObject(...)` |
| 🔵    | 类、方法、变量命名需语义清晰，禁止拼音缩写 | `String spbm;` | `String expenseTypeCode;` |
| 🔵    | 不允许无意义的注释（复制粘贴遗留、已注释掉的大段代码） | `// TODO fix later`（存在超过1周） | 删除或处理 |

---

### 3.2 Controller 层

| 级别 | 规则 | 检查点 |
| ---- | ---- | ------ |
| 🟡    | 类必须继承 `BaseController` | `extends BaseController` |
| 🟡    | 类上必须有 `@Validated` | `@Validated` 在类级别 |
| 🟡    | 入参 QVO 必须有 `@Valid` | `@RequestBody @Valid XxxQVO qvo` |
| 🟡    | Controller 包路径必须正确 | 管理端 → `controller/admin/`；移动端 → `controller/app/` |
| 🟡    | `@Tag` 命名格式 | 管理端：`管理端{业务域}-{序号}-{功能}`；移动端：`移动端-{功能}` |
| 🟡    | `@RequestParam` / `@PathVariable` 每个参数对应一个 `@Parameter` | 参数顺序须一致 |
| 🟡    | GET 对象入参用 `@ModelAttribute`，不用 `@RequestBody` | `@ModelAttribute @Valid XxxPageQVO qvo` |
| 🟡    | 使用加解密注解时，`@Operation` description 需注明 | `description = "参数需要加密"` / `"返回需要解密"` |
| 🟡    | 使用脱敏注解的字段，`@Schema` description 需含"脱敏"字样 | `description = "手机号（脱敏）"` |
| 🔵    | 返回值统一用 `Result.success()`，避免 `Result.ok()` 混用 | 新代码统一用 `success` |

---

### 3.3 Service 层

| 级别 | 规则 | 检查点 |
| ---- | ---- | ------ |
| 🔴    | 多步骤写操作方法必须有 `@Transactional(rollbackFor = Exception.class)` | insert/update/delete/setEnabled 方法 |
| 🔴    | 非致命子步骤失败时可继续执行，但**必须** `log.error(...)` 输出完整异常，**禁止**静默 `catch` 吞掉异常 | `catch (Exception e) { log.error("子步骤失败", e); }` 不可写空 catch |
| 🔴    | 类级必须有 `@Transactional(readOnly = true)` | 避免读操作占用写锁 |
| 🔴    | 调用外部 RPC 后必须判断 `result.isFailed()` | `if (result.isFailed()) throw new BusinessException(...)` |
| 🔴    | 写操作（insert/update/delete/状态变更）后必须调用 `addHistory()` | 所有业务表均须写历史 |
| 🔴    | `addHistory()` 中历史表主键必须用 `seqno` | `entityH.setSeqno(baseIdeable.generateId())` |
| 🔴    | 不允许在 Service 中直接 `new RuntimeException`，统一用 `BusinessException` | `throw new BusinessException(SysResult.ERROR_XXX, "msg")` |
| 🔴    | 需要身份认证的接口/业务**必须**调用 `GlobalHeaderThreadLocal.getOrException()`，缺失时框架返回 401 | 禁止跳过此调用直接执行业务逻辑 |
| 🟡    | 所有写操作开头必须 `GlobalHeaderThreadLocal.getOrException()` | 获取租户上下文 |
| 🟡    | 当前登录人信息通过 `GlobalHeaderThreadLocal.getOrException().getUserId()` / `.getTenantId()` 获取，禁止从入参 QVO 直接取 userId | `GlobalHeader h = GlobalHeaderThreadLocal.getOrException();` |
| 🟡    | `companyId` 为空时从 ThreadLocal 补全 | `if (StringUtil.isEmptyNull(qvo.getCompanyId())) qvo.setCompanyId(globalHeader.getTenantId())` |
| 🟡    | 修改操作须保留 `createTime` / `createUser` | `entity.setCreateTime(exist.getCreateTime())` |
| 🟡    | 对象转换用 `DataUtil.copyTo()`，禁止手动逐字段 set | `DataUtil.copyTo(qvo, Entity.class)` |
| 🟡    | 集合判空用 `CollectionUtil`，字符串判空用 `StringUtil` | 禁止直接 `.isEmpty()` / `== null` |
| 🔵    | Stream 操作避免多层嵌套，超过 3 步拆方法 | — |
| 🔵    | 删除操作前需检查是否被引用，有引用抛明确提示 | `throw new BusinessException(..., "xxx被使用，无法删除")` |

---

### 3.4 Mapper 层

| 级别 | 规则 | 检查点 |
| ---- | ---- | ------ |
| 🟡    | 读操作必须加 `@DS(CommonDataSourceConst.SLAVE)` | 从库查询 |
| 🟡    | 简单单表查询写 `default` 方法，禁止为简单查询写 XML | 联表/子查询/动态条件才走 XML |
| 🟡    | XML 中的 `@Param` 参数名必须与 XML 中 `#{param}` 一致 | — |
| 🔵    | `LambdaQueryWrapperX` 条件链不超过 8 个条件，超过拆方法或用 XML | — |

---

### 3.5 Entity 层

| 级别 | 规则 | 检查点 |
| ---- | ---- | ------ |
| 🔴    | 布尔/状态字段类型必须是 `String`，禁止 `Boolean` / `Integer` | `private String enabled;` |
| 🔴    | 小数字段必须用 `BigDecimal`，禁止 `float` / `double` | `private BigDecimal amount;` |
| 🟡    | 必须继承 `BaseEntity`（含公共审计字段） | `extends BaseEntity` |
| 🟡    | 表名用 `@TableName`，主键用 `@TableId`，其余用 `@TableField` | — |
| 🟡    | 必须有四个 Lombok 注解 | `@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)` |
| 🟡    | 历史表 Entity 主键字段名必须为 `seqno` | `@TableId("seqno") private String seqno;` |

---

### 3.6 QVO / RVO 层

| 级别 | 规则 | 检查点 |
| ---- | ---- | ------ |
| 🔴    | QVO 中 `companyId` 必须加 `@JsonIgnore` | 防止前端传入伪造租户ID |
| 🔴    | 脱敏注解（`@PhoneDesensitize` 等）只能标在 RVO 上，严禁标在 QVO / Entity | — |
| 🟡    | QVO / RVO 必须实现 `Serializable` | — |
| 🟡    | 分页 QVO 继承 `PageQVO`，树形 RVO 继承 `BaseTreeVO` | — |
| 🔵    | RVO 不应暴露不必要的内部字段（如内部状态码、系统字段） | — |

---

### 3.7 DDL / 数据库

| 级别 | 规则 | 检查点 |
| ---- | ---- | ------ |
| 🔴    | 每张业务主表必须同时有历史表（`_h` 后缀） | 纯记录表例外（如短信记录、上传记录） |
| 🔴    | 历史表主键字段名必须为 `seqno`，类型 `varchar(32)` | — |
| 🔴    | 主键必须是雪花ID，`varchar(32)`，禁止自增 ID | — |
| 🔴    | 状态字段类型必须是 `char`，禁止 `int` / `bit` | `enabled char(1) NOT NULL DEFAULT '1'` |
| 🔴    | 禁止使用关键字作为字段名 | `enable`、`status`、`comment`、`password` 等 |
| 🟡    | 小数字段用 `decimal`，禁止 `float` / `double` | — |
| 🟡    | 时间字段用 `datetime`，禁止 `timestamp` | — |
| 🟡    | 表名不超过 30 字符，字段数不超过 30 个 | — |
| 🟡    | `varchar` 长度不超过 2000 | 超过用扩展表 + `text` |
| 🟡    | 所有表必须有 `create_user / create_time / update_user / update_time` | — |
| 🟡    | 字典类字段描述需注明字典类型 | `COMMENT '性别【数据字典-Sex】'` |

---

### 3.8 可观测性与日志

| 级别 | 规则 | 错误示例 | 正确示例 |
| ---- | ---- | -------- | -------- |
| 🔴    | 关键写操作（创建、更新、删除、状态变更）方法入口必须有 `log.info` | 方法体无任何日志 | `log.info("创建费用单, userId={}, companyId={}", userId, companyId)` |
| 🔴    | 业务校验失败必须用 `log.warn`，并携带上下文参数值 | `throw new BusinessException(...)` 前无日志 | `log.warn("费用单状态不合法, id={}, status={}", id, status)` |
| 🔴    | 未预期异常必须用 `log.error`，并传入完整异常对象（打印堆栈） | `log.error("出错了")` | `log.error("处理费用单异常, id={}", id, e)` |
| 🔴    | **禁止**在任何日志行输出敏感数据：密码、Token、真实存储路径、手机号等隐私字段 | `log.info("token={}", token)` | 脱敏或移除敏感字段后再打印 |
| 🟡    | 必须使用 SLF4J 接口（`org.slf4j.Logger`），禁止直接用 `System.out.println` 或 Log4j 实现类 | `System.out.println(...)` | `@Slf4j` 或 `LoggerFactory.getLogger(XxxServiceImpl.class)` |
| 🟡    | 日志占位符使用 `{}` 参数化，禁止字符串拼接 | `log.info("id=" + id)` | `log.info("id={}", id)` |
| 🔵    | 批量操作建议在循环外打印汇总日志，避免日志量过大 | 循环内每条都 `log.info` | 循环后 `log.info("批量处理完成, total={}, success={}", total, success)` |

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
| 文件           | 级别 | 问题描述                         |
| -------------- | ---- | -------------------------------- |
| XxxServiceImpl | 🔴    | 第42行：写操作缺少@Transactional |
...
```

---

## 五、注意事项

- 只报告**确实存在的问题**，不要对看不到的代码做假设性指摘
- 给出的修复建议必须是**可直接复制执行的代码**，不是泛泛而谈
- 模块扫描时优先检查 ServiceImpl > Controller > Entity > Mapper > QVO/RVO，按此顺序报告
- 如代码质量整体较好，明确说"本次 Review 无必改项"，增强信心
- 发现同类问题在多个文件重复出现时，在"高频问题"中汇总，并提示可以批量修复
