# 中间件配置与使用指南

> ⚠️ 本文档为骨架，请根据你们团队实际配置填写。

---

## Nacos 2.5 — 服务注册与配置中心

### 命名空间规划

> ⚠️ **待填写**：填写你们实际的 namespace ID

```
dev  环境 namespace：xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
test 环境 namespace：xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
prod 环境 namespace：xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 配置文件命名规范

> ⚠️ **待填写**：填写你们的 Data ID 命名规范

```
规范：{应用名}.yaml
示例：your-service.yaml

共享配置：common-db.yaml / common-redis.yaml（多服务共用）
Data ID 命名约定：（待填写）
Group 划分规则：（待填写）
```

### 动态配置刷新

```java
// 使用 @RefreshScope + @Value 实现动态刷新
@RestController
@RefreshScope
public class YourController {
    @Value("${your.config.value}")
    private String configValue;
}

// 使用 @ConfigurationProperties（自动支持刷新，结合 @RefreshScope）
@Data
@RefreshScope
@ConfigurationProperties(prefix = "your.feature")
public class FeatureProperties {
    private boolean enabled;
    private int timeout;
}
```

### 常见 Nacos 坑

> ⚠️ **待填写**：填写你们遇到的实际问题

- [ ] 配置不生效（bootstrap.yml vs application.yml 加载顺序）
- [ ] 命名空间切不过去
- [ ] 待填写...

---

## Seata 2 — 分布式事务

### 事务模式选型

| 模式 | 适用场景 | 侵入性 | 性能 |
|------|---------|--------|------|
| AT   | MySQL + MyBatis/JPA，自动补偿 | 低（无需改业务） | 中 |
| TCC  | 需要精确控制资源预留/确认/回滚 | 高（需实现3个方法） | 高 |
| SAGA | 长事务、第三方服务无法回滚 | 中 | 高 |

> ⚠️ **待填写**：填写你们选择哪种模式，以及选型判断规则。

### AT 模式配置

```yaml
# application.yml
seata:
  enabled: true
  application-id: ${spring.application.name}
  tx-service-group: your_tx_group  # TODO: 填写你们的事务组名称

  service:
    vgroup-mapping:
      your_tx_group: default         # TODO: 填写 Seata cluster 名

  registry:
    type: nacos
    nacos:
      server-addr: ${NACOS_ADDR}
      namespace: ${NACOS_NAMESPACE}
      group: SEATA_GROUP             # TODO: 填写 Seata 配置在 Nacos 的 group

  config:
    type: nacos
    nacos:
      server-addr: ${NACOS_ADDR}
      namespace: ${NACOS_NAMESPACE}
      group: SEATA_GROUP
      data-id: seata.properties      # TODO: 填写 Seata 配置 Data ID
```

### AT 模式使用示例

```java
@Service
public class OrderService {

    @GlobalTransactional(name = "create-order", rollbackFor = Exception.class)
    public void createOrder(CreateOrderDTO dto) {
        // 跨数据库/跨服务操作，Seata 自动管理
        inventoryService.deductStock(dto.getProductId(), dto.getQuantity()); // Feign 调用
        orderMapper.insert(buildOrder(dto));
        paymentService.createPayment(dto.getOrderId(), dto.getAmount());     // Feign 调用
        // 任一步骤异常，Seata 自动回滚所有操作
    }
}
```

### Seata 常见坑

> ⚠️ **待填写**：填写你们遇到的实际问题

- [ ] undo_log 表未创建
- [ ] 事务组配置不匹配
- [ ] 待填写...

---

## Redis 6 — 缓存与分布式锁

### 连接配置

```yaml
# application.yml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
      database: ${REDIS_DB:0}       # TODO: 填写各服务使用的 db 编号
      lettuce:
        pool:
          max-active: 8
          max-idle: 8
          min-idle: 0
```

### Key 命名规范

> ⚠️ **待填写**：填写你们的 key 命名规范

```
格式：{项目名}:{模块}:{业务含义}:{id}
示例：your-app:user:info:12345
      your-app:order:list:userId:67890
分隔符：:（冒号）
```

### 序列化配置

```java
@Configuration
public class RedisConfig {
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);
        // key 用 String
        template.setKeySerializer(new StringRedisSerializer());
        template.setHashKeySerializer(new StringRedisSerializer());
        // value 用 JSON（推荐 Jackson2JsonRedisSerializer）
        Jackson2JsonRedisSerializer<Object> jsonSerializer =
            new Jackson2JsonRedisSerializer<>(objectMapper, Object.class);
        template.setValueSerializer(jsonSerializer);
        template.setHashValueSerializer(jsonSerializer);
        return template;
    }
}
```

### 三大缓存问题解决方案

```java
// 缓存穿透：null 值缓存 + 布隆过滤器前置
public YourVO getWithNullCache(Long id) {
    String key = "your-app:module:info:" + id;
    Object cached = redisTemplate.opsForValue().get(key);
    if (cached != null) {
        return cached == NULL_PLACEHOLDER ? null : (YourVO) cached;
    }
    YourEntity entity = yourMapper.selectById(id);
    if (entity == null) {
        redisTemplate.opsForValue().set(key, NULL_PLACEHOLDER, 5, TimeUnit.MINUTES); // 短暂缓存 null
        return null;
    }
    YourVO vo = convert(entity);
    redisTemplate.opsForValue().set(key, vo, 30, TimeUnit.MINUTES);
    return vo;
}

// 缓存雪崩：过期时间加随机值
long expireTime = 30 + ThreadLocalRandom.current().nextInt(10); // 30-40 分钟随机
redisTemplate.opsForValue().set(key, value, expireTime, TimeUnit.MINUTES);
```

> ⚠️ **待填写**：填写你们用的分布式锁实现（Redisson / 手动 setnx）及标准写法

---

## MongoDB 5 — 文档存储

### 连接配置

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:27017/${MONGO_DB}?authSource=admin
```

### 文档定义规范

> ⚠️ **待填写**：填写你们存入 MongoDB 的数据类型和集合命名规范

```java
@Data
@Document(collection = "your_collection")  // TODO: 填写集合命名规范
public class YourDocument {
    @Id
    private String id;           // MongoDB ObjectId

    // TODO: 填写业务字段

    @CreatedDate
    private LocalDateTime createTime;

    @LastModifiedDate
    private LocalDateTime updateTime;
}
```

### 索引配置

```java
// 在启动时创建索引（或用 @Indexed 注解）
@Configuration
public class MongoIndexConfig {
    @Autowired
    private MongoTemplate mongoTemplate;

    @PostConstruct
    public void createIndexes() {
        // 单字段索引
        mongoTemplate.indexOps("your_collection")
            .ensureIndex(new Index().on("fieldName", Sort.Direction.ASC));
        // 复合索引
        mongoTemplate.indexOps("your_collection")
            .ensureIndex(new CompoundIndexDefinition(new Document("fieldA", 1).append("fieldB", -1)));
    }
}
```

---

## Apache Doris 3 — OLAP 数据分析

> ⚠️ **待填写**：填写你们 Doris 的主要使用场景和查询规范

### 连接方式

```yaml
# Doris 兼容 MySQL 协议，使用 MySQL 驱动连接
spring:
  datasource:
    doris:
      url: jdbc:mysql://${DORIS_HOST}:9030/${DORIS_DB}?useUnicode=true&characterEncoding=utf8
      username: ${DORIS_USER}
      password: ${DORIS_PASSWORD}
      driver-class-name: com.mysql.cj.jdbc.Driver
```

### 常用查询模式

> ⚠️ **待填写**：填写你们常用的 Doris 聚合查询、分区查询模式

```sql
-- 示例：按时间分区聚合（待填写实际业务场景）
SELECT
    DATE_TRUNC('day', event_time) AS day,
    COUNT(*) AS total
FROM your_doris_table
WHERE event_time >= '2024-01-01'
  AND event_time <  '2024-02-01'
GROUP BY 1
ORDER BY 1;
```

### Doris 使用注意事项

> ⚠️ **待填写**：填写你们踩过的 Doris 坑

- [ ] 数据模型选型（Duplicate / Aggregate / Unique）
- [ ] 分桶和分区设置
- [ ] 待填写...

---

## TODO 待补充内容

- [ ] Redis 集群/哨兵配置（如果有）
- [ ] MongoDB 副本集配置（如果有）
- [ ] Nacos 实际的 namespace ID 和 Data ID 列表
- [ ] Seata 事务组名称和 cluster 配置
- [ ] 各中间件的监控/告警配置
- [ ] 实际踩坑记录
