# framework-redis — IRedisExtCommands 使用规范

> 注入方式统一使用 `@Resource`，Bean 名为 `redisExtCommands`。

```java
@Resource
private IRedisExtCommands redisExtCommands;
```

---

## 一、String 操作

### 写入 / 读取

```java
// 写入（永不过期）
redisExtCommands.set("key:xxx", value);

// 写入（带过期时间，单位：秒）
redisExtCommands.set("key:xxx", value, 3600L);

// 读取原始字符串
String raw = redisExtCommands.get("key:xxx");

// 读取并反序列化为对象
XxxRVO rvo = redisExtCommands.get("key:xxx", XxxRVO.class);
```

### 批量写入 / 读取

```java
// 批量写入 Map<String, Object>
Map<String, Object> map = new HashMap<>();
map.put("key:a", objA);
map.put("key:b", objB);
redisExtCommands.mset(map);

// 批量读取 → 返回 List<String>，顺序与 keys 一致
List<String> keys = List.of("key:a", "key:b");
Collection<String> values = redisExtCommands.mget(keys);
```

### 自增 / 追加

```java
// 原子自增（整型计数器）
Long newVal = redisExtCommands.incr("counter:xxx");

// 追加字符串到末尾（返回追加后总长度）
long len = redisExtCommands.append("key:xxx", ",extra");
```

---

## 二、Hash 操作

### 单字段读写

```java
// 写单个 field
redisExtCommands.hset("hash:xxx", "fieldName", value);

// 写单个 field + 同时设置过期时间
redisExtCommands.hset("hash:xxx", "fieldName", value, 3600L);

// 读单个 field（原始字符串）
String raw = redisExtCommands.hget("hash:xxx", "fieldName");

// 读单个 field 反序列化为对象
XxxRVO rvo = redisExtCommands.hget("hash:xxx", "fieldName", XxxRVO.class);

// 读单个 field 反序列化为 List
List<XxxRVO> list = redisExtCommands.hgetList("hash:xxx", "fieldName", XxxRVO.class);
```

### 批量读写

```java
// 批量写 Map<String, Object>
Map<String, Object> fields = new HashMap<>();
fields.put("f1", obj1);
fields.put("f2", obj2);
redisExtCommands.hmset("hash:xxx", fields);

// 批量写 Map<String, List<?>>
Map<String, List<?>> listFields = new HashMap<>();
listFields.put("f1", listA);
redisExtCommands.hmsetList("hash:xxx", listFields);

// 批量读指定 fields → List<String>
Collection<String> fieldNames = List.of("f1", "f2");
Collection<String> rawVals = redisExtCommands.hmget("hash:xxx", fieldNames);

// 批量读并反序列化为对象列表
List<XxxRVO> rvoList = redisExtCommands.hmget("hash:xxx", fieldNames, XxxRVO.class);

// 批量读并把每个 field 值（JSON 数组）展开为扁平 List
List<XxxRVO> flat = redisExtCommands.hmgetList(0, "hash:xxx", fieldNames, XxxRVO.class);
```

### 读全部 field

```java
// hgetall → Map<String, String>（原始）
Map<String, String> raw = redisExtCommands.hgetall("hash:xxx");

// hgetall → Map<String, T>（反序列化）
Map<String, XxxRVO> rvoMap = redisExtCommands.hgetAll("hash:xxx", XxxRVO.class);

// hgetall → Map<String, List<T>>（每个 value 是 JSON 数组）
Map<String, List<XxxRVO>> listMap = redisExtCommands.hgetAllList("hash:xxx", XxxRVO.class);

// hvals → 只取所有 value（List<String>）
List<String> rawVals = redisExtCommands.hvals("hash:xxx");

// hvals → 反序列化
List<XxxRVO> rvoVals = redisExtCommands.hvals("hash:xxx", XxxRVO.class);

// hkeys → 只取所有 field 名
List<String> fieldKeys = redisExtCommands.hkeys("hash:xxx");
```

### 数值增减 / 删除 field

```java
// field 值原子增减（long）
Long newScore = redisExtCommands.hincrby("hash:xxx", "score", 5L);

// 删除单个或多个 field
redisExtCommands.hdel("hash:xxx", "fieldName");
redisExtCommands.hdel("hash:xxx", List.of("f1", "f2"));
```

---

## 三、Sorted Set 操作

```java
// 添加单个成员
redisExtCommands.zadd("zset:xxx", 100.0, member);

// 批量添加（RedisSortedSetDTO 含 score + value）
List<RedisSortedSetDTO> dtoList = ...;
Long added = redisExtCommands.zadd("zset:xxx", dtoList);

// score 原子增减
double newScore = redisExtCommands.zIncrBy(0, "zset:xxx", 1.0, member);

// 按 score 范围查询（升序）
List<XxxRVO> asc = redisExtCommands.zRangeByScore(0, "zset:xxx", 0L, 100L, XxxRVO.class);

// 按 rank 倒序查询（start=0, end=-1 取全部）
List<XxxRVO> desc = redisExtCommands.zRevRange(0, "zset:xxx", 0L, -1L, XxxRVO.class);

// 按 score 范围删除
long removed = redisExtCommands.zRemRange(0, "zset:xxx", 0L, 50L);

// 删除指定成员
Long cnt = redisExtCommands.zRem("zset:xxx", member);
```

---

## 四、Key 操作

```java
// 判断 key 是否存在
Boolean exists = redisExtCommands.exists("key:xxx");

// 批量判断哪些 key 存在 → 返回存在的 key 列表
List<String> existKeys = redisExtCommands.existsByKeys(List.of("key:a", "key:b"));

// 删除 key（返回实际删除数量）
long delCount = redisExtCommands.del("key:xxx");

// 设置过期时间（秒）
redisExtCommands.expire("key:xxx", 3600L);

// 查询剩余 TTL（秒；-1 永不过期，-2 不存在）
Long ttl = redisExtCommands.getExpire(0, "key:xxx");

// 模糊扫描 key（生产慎用，避免全量 scan 阻塞）
Set<String> matched = redisExtCommands.scan("key:xxx:*", 100);
```

---

## 五、指定 DB 操作

所有方法均有 `int index` 重载，第一参数传 DB 编号（默认 DB 由配置 `spring.data.redis.database` 决定）：

```java
// 向 DB-1 写入
redisExtCommands.set(1, "key:xxx", value, 3600L);

// 从 DB-1 读取
String raw = redisExtCommands.get(1, "key:xxx");

// DB-1 的 Hash 操作
redisExtCommands.hset(1, "hash:xxx", "field", value);
Map<String, XxxRVO> map = redisExtCommands.hgetAll(1, "hash:xxx", XxxRVO.class);
```

---

## 六、自定义命令（executeRedisCommand）

需要执行 `IRedisExtCommands` 未封装的原生命令时，使用 `executeRedisCommand`：

```java
String result = redisExtCommands.executeRedisCommand(template -> {
    return template.execute((RedisConnection conn) -> {
        conn.select(0);
        RedisSerializer<String> s = template.getStringSerializer();
        // 例：原生 GETSET
        byte[] old = conn.stringCommands().getSet(
            s.serialize("key:xxx"),
            s.serialize("newValue")
        );
        return s.deserialize(old);
    });
});
```

---

## 七、常见使用场景示例

### 缓存单条业务数据（有过期时间）

```java
private static final String CACHE_KEY = "xxx:detail:";
private static final long   CACHE_TTL = 1800L; // 30 分钟

public XxxRVO getXxx(String xxxId) {
    String cacheKey = CACHE_KEY + xxxId;
    XxxRVO cached = redisExtCommands.get(cacheKey, XxxRVO.class);
    if (cached != null) return cached;

    var entity = xxxMapper.getById(xxxId);
    if (entity == null)
        throw new BusinessException(SysResult.ERROR_DATA_NOT_EXISTS_CODE, "xxx不存在");

    XxxRVO rvo = DataUtil.copyTo(entity, XxxRVO.class);
    redisExtCommands.set(cacheKey, rvo, CACHE_TTL);
    return rvo;
}
```

### 写操作后主动删除缓存

```java
@Transactional(rollbackFor = Exception.class)
public void updateXxx(XxxQVO qvo) {
    // ... 更新逻辑
    xxxMapper.updateById(entity);
    addHistory(entity);
    // ✅ 更新后删除缓存，下次读时重建
    redisExtCommands.del(CACHE_KEY + qvo.getXxxId());
}
```

### Hash 缓存同一 key 下多租户数据

```java
private static final String HASH_KEY = "xxx:byTenant";

// 写入
redisExtCommands.hset(HASH_KEY, tenantId, rvoList, 3600L);

// 读取
List<XxxRVO> list = redisExtCommands.hgetList(HASH_KEY, tenantId, XxxRVO.class);

// 租户数据更新后清除该 field
redisExtCommands.hdel(HASH_KEY, tenantId);
```

### 排行榜 / 计分板（Sorted Set）

```java
// 加分
redisExtCommands.zIncrBy(0, "rank:score", delta, userId);

// 取前 10 名（倒序）
List<String> top10 = redisExtCommands.zRevRange(0, "rank:score", 0L, 9L, String.class);
```

---

## 八、注意事项

| 项目 | 规范 |
|------|------|
| Key 命名 | `{业务域}:{实体}:{标识}`，用 `:` 分隔，全小写，如 `org:dept:detail:` |
| 过期时间 | 缓存 key 必须设置 TTL，禁止永久缓存业务数据 |
| 序列化 | value 统一 JSON 序列化，基本类型（String/Long）直接传，无需包装 |
| DB 隔离 | 跨业务域数据存放不同 DB 时，显式传入 `index`，勿依赖默认值 |
| scan 使用 | 生产环境 `count` 建议 ≥ 100，避免单次扫描过多 key 阻塞 Redis |
| 缓存击穿 | 高并发场景结合 `RedissonLockService` 分布式锁防击穿，参见 `framework-redisson.md` |
