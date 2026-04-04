---
name: java-spring-backend
description: 使用此 Skill 当用户问到「设计 Spring Boot API」「优化 MyBatis/MyBatis-Plus 查询」「配置 Nacos 服务注册/配置中心」「实现 Seata 分布式事务」「设计 Flowable 工作流」「Redis 缓存方案/缓存击穿」「MongoDB 聚合查询/索引」「MySQL 索引优化/执行计划」「Spring Security 权限控制」「OpenFeign 服务调用」「Doris 数据分析查询」「微服务架构设计」「Spring Cloud Gateway 网关」「接口限流/熔断」「分页查询」「多数据源配置」「日志链路追踪」。适用于 JDK 17 + Spring Boot 3.3.6 + Spring Cloud 2023.0.6 + Spring Cloud Alibaba 2023.0.3.2 技术栈的后端开发。
---

# Java Spring 后端工程师

基于 JDK 17 + Spring Boot 3.3.6 + Spring Cloud Alibaba 的后端开发规范、API 设计、数据库优化、分布式中间件使用指南。

## 目录

- [技术栈版本](#技术栈版本)
- [API 开发规范](#api-开发规范)
- [数据库操作规范](#数据库操作规范)
- [分布式中间件](#分布式中间件)
- [工作流（Flowable）](#工作流flowable)
- [代码规范](#代码规范)
- [常见场景工作流](#常见场景工作流)
- [参考文档](#参考文档)

---

## 技术栈版本

| 组件                    | 版本         | 备注             |
|-------------------------|--------------|------------------|
| JDK                     | 17           | LTS              |
| Spring Boot             | 3.3.6        |                  |
| Spring Cloud            | 2023.0.6     |                  |
| Spring Cloud Alibaba    | 2023.0.3.2   | Nacos/Seata/Sentinel |
| Flowable                | 7.0.1        | BPM 工作流       |
| MySQL                   | 8            | 主数据库         |
| MongoDB                 | 5            | 文档存储         |
| Redis                   | 6            | 缓存/分布式锁    |
| Apache Doris            | 3            | OLAP 数据分析    |
| Nacos                   | 2.5          | 注册中心/配置中心 |
| Seata                   | 2            | 分布式事务       |

---

## API 开发规范

### 统一响应格式

> ⚠️ **待填写**：填写你们团队实际使用的响应体结构（字段名、成功/失败格式、分页格式）。

```java
// 示例结构，按实际情况修改
@Data
public class Result<T> {
    private Integer code;      // 业务状态码，成功为 200
    private String message;    // 提示信息
    private T data;            // 业务数据
    private long timestamp;    // 时间戳

    public static <T> Result<T> success(T data) { /* ... */ }
    public static <T> Result<T> fail(String message) { /* ... */ }
}
```

**分页响应格式**：
```java
// 示例，按实际情况修改
@Data
public class PageResult<T> {
    private long total;        // 总条数
    private List<T> records;   // 当前页数据
    private long current;      // 当前页
    private long size;         // 每页条数
}
```

### Controller 规范

> ⚠️ **待填写**：填写你们的路由命名规范、版本策略（/api/v1/...）、参数校验方式。

```java
// 参考骨架，按实际情况补充
@RestController
@RequestMapping("/api/v1/your-module")
@Validated
@Slf4j
public class YourController {

    @GetMapping("/{id}")
    public Result<YourVO> getById(@PathVariable Long id) {
        // TODO: 填写实际实现模式
        return Result.success(service.getById(id));
    }

    @PostMapping
    public Result<Void> create(@RequestBody @Valid YourCreateDTO dto) {
        service.create(dto);
        return Result.success(null);
    }
}
```

### 全局异常处理

> ⚠️ **待填写**：填写你们的自定义异常类名、错误码枚举，以及 @RestControllerAdvice 的实际写法。

```java
// 骨架示例
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // 业务异常
    @ExceptionHandler(BusinessException.class)  // ← 填写你们的异常类名
    public Result<Void> handleBusinessException(BusinessException e) {
        log.warn("业务异常: {}", e.getMessage());
        return Result.fail(e.getMessage());
    }

    // 参数校验异常
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<Void> handleValidation(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors()
            .stream().map(FieldError::getDefaultMessage)
            .collect(Collectors.joining(", "));
        return Result.fail(msg);
    }
}
```

---

## 数据库操作规范

### MySQL — MyBatis-Plus 使用规范

> ⚠️ **待填写**：填写你们的 Entity 基类（公共字段）、逻辑删除字段名、乐观锁字段名、分页插件配置。

```java
// 基础 Entity，按实际情况修改字段
@Data
@TableName("your_table")
public class YourEntity {
    @TableId(type = IdType.ASSIGN_ID)  // 或 AUTO，填写你们的主键策略
    private Long id;

    // TODO: 填写你们的公共字段（create_time, update_time, create_by 等）
    // TODO: 填写逻辑删除字段，如 @TableLogic private Integer deleted;
    // TODO: 填写乐观锁字段，如 @Version private Integer version;
}
```

**Wrapper 查询规范**：
```java
// 常用查询模式骨架
LambdaQueryWrapper<YourEntity> wrapper = new LambdaQueryWrapper<YourEntity>()
    .eq(StringUtils.isNotBlank(dto.getStatus()), YourEntity::getStatus, dto.getStatus())
    .like(StringUtils.isNotBlank(dto.getName()), YourEntity::getName, dto.getName())
    .between(dto.getStartTime() != null, YourEntity::getCreateTime, dto.getStartTime(), dto.getEndTime())
    .orderByDesc(YourEntity::getCreateTime);
```

**分页查询**：
```java
Page<YourEntity> page = new Page<>(dto.getCurrent(), dto.getSize());
Page<YourEntity> result = baseMapper.selectPage(page, wrapper);
// 转 VO
Page<YourVO> voPage = result.convert(entity -> BeanUtil.copyProperties(entity, YourVO.class));
```

### MySQL 索引优化快速参考

```sql
-- 单列等值查询
CREATE INDEX idx_table_field ON table_name(field_name);

-- 复合索引（遵循最左前缀，把区分度高的列放前面）
CREATE INDEX idx_table_a_b ON table_name(field_a, field_b);

-- 慢查询分析
EXPLAIN SELECT * FROM table_name WHERE field = 'value';
-- 关注：type 应为 ref 或 range，避免 ALL；Extra 避免 Using filesort

-- 查看慢查询（需开启 slow_query_log）
SHOW VARIABLES LIKE 'slow_query_log%';
```

> ⚠️ **待填写**：填写你们数据库的表命名规范、字段命名规范（下划线/驼峰）、分库分表规则（如果有）。

### MongoDB 操作规范

> ⚠️ **待填写**：填写你们 MongoDB 存储的数据类型、集合命名规范、常用聚合查询模式。

```java
// Spring Data MongoDB 基本操作骨架
@Repository
public class YourMongoRepository {

    @Autowired
    private MongoTemplate mongoTemplate;

    // 条件查询
    public List<YourDocument> findByCondition(YourQueryDTO dto) {
        Query query = new Query();
        Criteria criteria = new Criteria();
        // TODO: 填写实际查询条件构建方式
        query.addCriteria(criteria);
        query.with(Sort.by(Sort.Direction.DESC, "createTime"));
        return mongoTemplate.find(query, YourDocument.class);
    }

    // 聚合查询骨架
    public List<YourAggResult> aggregate(String groupField) {
        Aggregation agg = Aggregation.newAggregation(
            Aggregation.match(Criteria.where("status").is("ACTIVE")),
            Aggregation.group(groupField).count().as("count"),
            Aggregation.sort(Sort.Direction.DESC, "count")
        );
        return mongoTemplate.aggregate(agg, "your_collection", YourAggResult.class).getMappedResults();
    }
}
```

---

## 分布式中间件

### Redis 缓存规范

> ⚠️ **待填写**：填写你们的 key 命名规范（前缀/分隔符）、过期时间策略、序列化方式（JSON/JDK）。

```java
// key 命名规范示例（填写你们的实际规范）
// 格式：{项目名}:{模块名}:{业务key}:{id}
// 示例：your-app:user:info:12345

// 缓存使用三板斧（防击穿/穿透/雪崩）
@Service
public class YourCacheService {

    // 防缓存击穿：双重检查 + 互斥锁
    public YourVO getWithLock(Long id) {
        String key = "your-app:module:info:" + id;
        YourVO vo = (YourVO) redisTemplate.opsForValue().get(key);
        if (vo == null) {
            String lockKey = "your-app:lock:module:" + id;
            // TODO: 填写你们的分布式锁实现（Redisson / 手动 setnx）
        }
        return vo;
    }

    // 防缓存穿透：null 值缓存短时间
    // 防缓存雪崩：过期时间加随机值
    // TODO: 填写实际实现方式
}
```

### Nacos 配置规范

> ⚠️ **待填写**：填写你们的 Nacos 命名空间规划（dev/test/prod）、Data ID 命名规范、Group 划分方式。

```yaml
# bootstrap.yml 骨架
spring:
  application:
    name: your-service-name  # TODO: 填写服务命名规范
  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_ADDR:localhost:8848}
        namespace: ${NACOS_NAMESPACE:}  # TODO: 填写各环境 namespace ID
        group: ${NACOS_GROUP:DEFAULT_GROUP}  # TODO: 填写 Group 规范
      config:
        server-addr: ${NACOS_ADDR:localhost:8848}
        namespace: ${NACOS_NAMESPACE:}
        group: ${NACOS_GROUP:DEFAULT_GROUP}
        file-extension: yaml
        # 多配置文件加载（共享配置）
        shared-configs:
          - data-id: common.yaml   # TODO: 填写共享配置文件名
            group: SHARED_GROUP
            refresh: true
```

### Seata 分布式事务规范

> ⚠️ **待填写**：填写你们选择 AT/TCC/SAGA 的决策规则，以及 Seata Server 地址、事务组名称。

**事务模式选型**：
```
AT 模式  ← 适合：MySQL + MyBatis，自动补偿，无侵入（你们的主要场景）
TCC 模式 ← 适合：需要精确控制资源预留/确认/回滚的场景
SAGA     ← 适合：长事务、第三方服务集成
```

```java
// AT 模式使用（最简单，推荐）
@GlobalTransactional(name = "your-tx-group", rollbackFor = Exception.class)
public void yourDistributedMethod() {
    // 跨服务调用，Seata 自动管理事务
    serviceA.doSomething();
    serviceB.doSomething();
}
```

```yaml
# application.yml Seata 配置骨架
seata:
  enabled: true
  application-id: ${spring.application.name}
  tx-service-group: ${TX_GROUP:your_tx_group}  # TODO: 填写你们的事务组名称
  service:
    vgroup-mapping:
      your_tx_group: default  # TODO: 填写 Seata cluster 名
  registry:
    type: nacos
    nacos:
      server-addr: ${NACOS_ADDR:localhost:8848}
      namespace: ${NACOS_NAMESPACE:}
```

---

## 工作流（Flowable）

> ⚠️ **待填写**：填写你们使用 Flowable 的主要场景（审批流/业务流）、流程定义命名规范、任务分配方式（候选人/候选组）。

```java
// 部署流程定义
@Service
public class FlowableService {

    @Autowired
    private RepositoryService repositoryService;
    @Autowired
    private RuntimeService runtimeService;
    @Autowired
    private TaskService taskService;

    // 部署流程
    public String deployProcess(String bpmnFileName) {
        Deployment deployment = repositoryService.createDeployment()
            .addClasspathResource("processes/" + bpmnFileName)
            .name("流程名称")  // TODO: 填写命名规范
            .deploy();
        return deployment.getId();
    }

    // 启动流程实例
    public String startProcess(String processKey, Map<String, Object> variables) {
        ProcessInstance instance = runtimeService.startProcessInstanceByKey(processKey, variables);
        return instance.getId();
    }

    // 查询待办任务
    public List<Task> getMyTasks(String assignee) {
        return taskService.createTaskQuery()
            .taskAssignee(assignee)
            .orderByTaskCreateTime().desc()
            .list();
    }

    // 完成任务（审批通过/拒绝）
    public void completeTask(String taskId, Map<String, Object> variables) {
        taskService.complete(taskId, variables);
    }
}
```

> ⚠️ **待填写**：填写你们的 BPMN 文件存放位置、流程变量命名约定、监听器使用规范。

详细内容见：`references/flowable_practices.md`

---

## 代码规范

> ⚠️ **待填写**：填写你们团队的具体规范。以下是常见骨架，按实际情况修改。

### 包结构规范
```
com.yourcompany.yourservice/
├── controller/     # REST 接口层
├── service/        # 业务逻辑层
│   └── impl/
├── mapper/         # MyBatis Mapper（数据访问层）
├── entity/         # 数据库实体
├── dto/            # 请求参数 DTO
├── vo/             # 响应视图 VO
├── config/         # 配置类
├── exception/      # 自定义异常
├── util/           # 工具类
└── enums/          # 枚举类
```

### 命名约定
```
# TODO: 填写你们的实际命名规范
Controller：XxxController
Service 接口：XxxService
Service 实现：XxxServiceImpl
Mapper：XxxMapper
Entity：Xxx（数据库表名去掉前缀）
DTO（入参）：XxxDTO / XxxCreateDTO / XxxUpdateDTO
VO（出参）：XxxVO / XxxListVO
```

### 日志规范
```java
// TODO: 填写你们的日志规范（MDC链路、日志级别约定）
@Slf4j
public class YourService {
    public void doSomething(String bizId) {
        log.info("[模块名] 操作说明, bizId={}", bizId);
        // 避免在循环中打日志
        // 敏感信息（手机号/身份证）需脱敏
    }
}
```

---

## 常见场景工作流

### 新建业务模块

```
1. 建表 → 生成 Entity（MyBatis-Plus Generator 或手写）
2. 写 Mapper 接口 + XML（复杂查询）/ Wrapper（简单查询）
3. 写 Service 接口 + ServiceImpl 实现
4. 写 Controller（参数用 DTO 接收，返回用 VO）
5. 参数校验用 @Valid + Hibernate Validator 注解
6. 异常统一抛 BusinessException（自定义），GlobalExceptionHandler 捕获
7. 需要缓存的业务加 Redis 缓存逻辑（注意缓存一致性）
```

### 跨服务调用

```
1. 用 OpenFeign 定义接口（加 @FeignClient(name="服务名")）
2. 如需分布式事务，Service 方法加 @GlobalTransactional
3. 熔断/降级配置 Sentinel 规则（或 Feign 的 fallback）
4. 链路追踪确保 TraceId 传递
```

### 添加新的定时任务

> ⚠️ **待填写**：填写你们用的定时任务框架（XXL-Job / Spring @Scheduled / Quartz）及标准写法。

---

## 参考文档

| 文件 | 内容 | 使用时机 |
|------|------|---------|
| `references/spring_patterns.md` | Spring Boot 3 开发模式、JDK 17 特性、常用注解 | 新建功能时 |
| `references/middleware_guide.md` | Nacos/Seata/Redis/MongoDB/Doris 配置与使用 | 中间件接入时 |
| `references/flowable_practices.md` | Flowable 7 工作流设计规范与示例 | 工作流开发时 |
