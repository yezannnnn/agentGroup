# Redisson 分布式锁使用规范

> 此文件供 skill-backend-module 使用。

---

## 注入方式

```java
@Resource
private RedissonLockService redissonLockService;
```

---

## 锁 Key 命名规范

```
{业务域}:{操作}:{唯一标识}
```

| 场景 | 锁 Key 示例 |
|------|------------|
| 防重复提交（按用户） | `xxx:add:{companyId}:{userId}` |
| 单据状态变更（按单据） | `xxx:update:{xxxId}` |
| 跨资源联锁 | `["xxx:update:{xxxId}", "yyy:deduct:{yyyId}"]` |

---

## 场景一：有返回值 + 无事务（最常用）

```java
@Override
@Transactional(rollbackFor = Exception.class)
public XxxRVO addXxx(XxxQVO qvo) {
    String lockKey = "xxx:add:" + qvo.getCompanyId() + ":" + GlobalHeaderThreadLocal.getOrException().getUserId();
    return redissonLockService.lock(lockKey, () -> {
        var exist = xxxMapper.getByName(qvo.getCompanyId(), qvo.getXxxName());
        if (exist != null)
            throw new BusinessException(SysResult.ERROR_DATA_EXISTS_CODE, "xxx名称已存在");
        Xxx entity = DataUtil.copyTo(qvo, Xxx.class);
        entity.setXxxId(baseIdeable.generateId()).setEnabled("1");
        xxxMapper.insert(entity);
        addHistory(entity);
        return DataUtil.copyTo(entity, XxxRVO.class);
    });
}
```

---

## 场景二：无返回值 + 无事务

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void updateXxx(XxxQVO qvo) {
    String lockKey = "xxx:update:" + qvo.getXxxId();
    redissonLockService.lockVoid(lockKey, () -> {
        var exist = xxxMapper.getById(qvo.getXxxId());
        if (exist == null)
            throw new BusinessException(SysResult.ERROR_DATA_NOT_EXISTS_CODE, "xxx不存在");
        Xxx entity = DataUtil.copyTo(qvo, Xxx.class);
        entity.setCreateTime(exist.getCreateTime()).setCreateUser(exist.getCreateUser());
        xxxMapper.updateById(entity);
        addHistory(entity);
        return null; // ✅ Void worker 必须显式 return null
    });
}
```

---

## 场景三：锁内自动开启事务（锁包事务）

> 适用于：必须在锁释放前完成整个事务提交，防止其他线程在提交前读到旧数据。

```java
@Override
public void addXxxWithTx(XxxQVO qvo) {    // ✅ 方法本身不加 @Transactional
    String lockKey = "xxx:add:" + qvo.getCompanyId();
    redissonLockService.lockTransactionVoid(lockKey, () -> {
        var exist = xxxMapper.getByName(qvo.getCompanyId(), qvo.getXxxName());
        if (exist != null)
            throw new BusinessException(SysResult.ERROR_DATA_EXISTS_CODE, "xxx名称已存在");
        Xxx entity = DataUtil.copyTo(qvo, Xxx.class);
        entity.setXxxId(baseIdeable.generateId()).setEnabled("1");
        xxxMapper.insert(entity);
        addHistory(entity);
        return null;
    });
}
```

---

## 场景四：多资源联锁（MultiLock）

> 适用于：一次操作需同时锁定多个独立资源（如跨表扣减）。

```java
@Override
public void transferXxx(String fromId, String toId) {
    // ✅ 固定顺序排序，防止不同线程因锁顺序不同产生死锁
    List<String> lockKeys = Stream.of("xxx:transfer:" + fromId, "xxx:transfer:" + toId)
            .sorted()
            .collect(Collectors.toList());
    redissonLockService.multiLockTransactionVoid(lockKeys, () -> {
        // 业务逻辑
        return null;
    });
}
```

---

## 场景五：手动加锁 / 释放

> 适用于锁生命周期需跨越多个方法调用。不推荐，优先使用 Worker 模式。

```java
boolean locked = redissonLockService.tryLock(lockKey);
if (!locked) {
    throw new BusinessException("系统繁忙，请稍后重试");
}
try {
    // 执行业务
} finally {
    redissonLockService.unLock(lockKey); // ✅ 必须在 finally 中释放
}
```

---

## 方法速查表

| 场景 | 有返回值 | 无返回值 |
|------|---------|---------|
| 单锁，不含事务 | `lock(key, worker)` | `lockVoid(key, worker)` |
| 单锁，锁内开事务 | `lockTransaction(key, worker)` | `lockTransactionVoid(key, worker)` |
| 多锁，不含事务 | `multiLock(keys, worker)` | `multiLockVoid(keys, worker)` |
| 多锁，锁内开事务 | `multiLockTransaction(keys, worker)` | `multiLockTransactionVoid(keys, worker)` |
| 只加锁 | `tryLock(key)` / `lock(key)` | — |
| 手动释放 | — | `unLock(key)` |

所有 `lock` / `multiLock` 系列方法均支持可选的 `tryTimeout`（等待超时，毫秒）和 `expireTime`（锁过期，毫秒）参数，不传时使用全局配置默认值。

---

## 与 `@Transactional` 的组合原则

| 场景 | 推荐写法 |
|------|---------|
| 方法已有 `@Transactional`，锁只防重复 | 方法加 `@Transactional`，锁内调用 `lockVoid` / `lock` |
| 需要"锁释放后事务才提交"的强一致性 | 方法**不加** `@Transactional`，改用 `lockTransactionVoid` / `lockTransaction` |
| 多个 Service 方法共享同一把锁 | 上层用 `tryLock` + `unLock`，下层各自管理事务（谨慎使用） |

---

## 检查清单

- [ ] 锁 Key 包含足够的业务隔离维度（如 `companyId`、`xxxId`），避免锁粒度过粗
- [ ] 多锁 Key 列表必须排序（`Stream.sorted()`），防止死锁
- [ ] `lockTransactionVoid` / `lockTransaction` 对应的 Service 方法**不加** `@Transactional`
- [ ] `Void` Worker 内部必须显式 `return null`
- [ ] 手动 `tryLock` 后必须在 `finally` 中调用 `unLock`
