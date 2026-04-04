# Doris 写入规范

---

## 核心规则

- **所有 Doris 写操作必须在 `@DorisTransactional` 注解方法内**，否则抛 `IllegalStateException`
- Doris 与 MySQL 是两套事务，`@DorisTransactional` 和 `@Transactional` 互相独立
- 通常的模式：先写 MySQL（`@Transactional`），再写 Doris（`@DorisTransactional`），或同一方法叠加两个注解

---

## Repository 定义

```java
@Repository
public interface XxxDorisMapper extends DorisBaseRepository<XxxDorisEntity, String> {
    // DorisBaseRepository 已内置：upsetBatch / upsert / deleteById / deleteByIds
}
```

**Doris Entity（字段映射 Doris 表列名）：**

```java
@TableName("xxx_doris_table")           // Doris 表名
public class XxxDorisEntity {

    @TableId("xxx_id")                  // 主键（UNIQUE KEY 模型）
    private String xxxId;

    @TableField("company_id")
    private String companyId;

    // 其他字段...
}
```

---

## 使用方式

### 批量写入（最常用）

```java
@Service
public class XxxSyncService {

    @Resource
    private XxxDorisMapper xxxDorisMapper;

    @DorisTransactional                 // ✅ 必须加，默认超时 30 秒
    public void syncToDoris(List<XxxDorisEntity> entities) {
        xxxDorisMapper.upsetBatch(entities);
    }
}
```

### 与 MySQL 事务组合

```java
// 方式 A：两个独立方法，先 MySQL 后 Doris
@Transactional(rollbackFor = Exception.class)
public void saveToMysql(XxxQVO qvo) {
    // MySQL 操作...
}

@DorisTransactional
public void syncToDoris(XxxDorisEntity entity) {
    xxxDorisMapper.upsert(entity);
}

// 方式 B：同一方法叠加（先 MySQL commit，再 Doris commit）
@Transactional(rollbackFor = Exception.class)
@DorisTransactional
public void saveAndSync(XxxQVO qvo) {
    // MySQL 写入
    xxxMapper.insert(...);
    // Doris 写入（在同一调用栈内）
    xxxDorisMapper.upsert(...);
}
```

### 删除

```java
@DorisTransactional
public void deleteFromDoris(String xxxId) {
    xxxDorisMapper.deleteById(xxxId);
}

@DorisTransactional
public void batchDeleteFromDoris(List<String> xxxIds) {
    xxxDorisMapper.deleteByIds(xxxIds);
}
```

---

## 注意事项

- `upsetBatch` 入参为空列表时自动跳过，无需外部判空
- Doris 使用 Stream Load，网络异常时事务会自动 abort
- 超时时间可调：`@DorisTransactional(timeout = 60)`
- Doris 表必须是 **UNIQUE KEY 模型** 才支持 delete 操作
