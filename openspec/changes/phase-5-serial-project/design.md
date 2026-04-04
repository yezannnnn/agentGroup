## Context

### 背景

企业基础管理系统 Phase 5 包含两个模块：

- **M7 流水号**：基于 Redis 的分布式序号生成服务，供其他业务模块调用
- **M8 项目管理**：业务上的项目记录功能，自动获取项目编号

### 技术约束

- 框架：Spring Boot + MyBatis-Plus
- Redis：使用 Redisson 锁 + Redis INCR 原子操作
- 定时任务：Nacos 配置 cron 表达式
- 现有 Phase 1-4 的代码模式需保持一致

## Goals / Non-Goals

**Goals:**
- M7 提供并发安全的流水号生成服务
- M7 支持每日/每月/每年自动重置
- M8 标准 CRUD 功能，项目编号支持手动输入或自动获取
- Redis 缓存加速，M7 配置变更同步刷新缓存

**Non-Goals:**
- 不支持集群环境下的跨节点同步重置（依赖 Nacos 定时任务）
- 不支持流水号回收或撤销

## Decisions

### D1：Redis Key 设计

```
serial:config:{serial_code}           → JSON(完整配置)
serial:counter:{serial_id}:{date}    → 计数器值 (INCR)
```

**为什么**：配置和计数器分离，计数器按日期维度实现重置。

### D2：Redisson 锁粒度

```java
String lockKey = "serial:next:" + serialId;
```

**为什么**：锁住单个规则，保证同规则内的并发顺序。

### D3：INCR 原子递增

```java
Long newValue = redisExtCommands.incr("serial:counter:" + serialId + ":" + date);
```

**为什么**：`INCR` 本身是原子操作，无需额外分布式锁，只需在获取前加规则锁。

### D4：MySQL 异步刷新

```java
// 同步：Redis 计数器
// 异步：MySQL cur_value / cur_date
@Async
public void syncToMysql(String serialId, Long curValue, String curDate) {
    // update be_serial_number set cur_value=?, cur_date=? where serial_id=?
}
```

**为什么**：Redis 是主数据源，MySQL 仅作备份/审计，异步刷新不影响主流程性能。

### D5：M8 集成方式

```java
if (StrUtil.isBlank(qvo.getProjectNum())) {
    String serialNum = serialNumberService.next("PROJECT_NUM");
    qvo.setProjectNum(serialNum);
}
```

**为什么**：业务编码方式更灵活，符合 PRD 设计。

### D6：重置策略实现

Nacos 配置 `serial_reset_cron = "0 1 0 * * ?"` 每日 0:01 执行：

```java
@Scheduled(cron = "${serial_reset_cron}")
public void resetSerialCounters() {
    // 1. 查询所有启用的规则
    // 2. 按 reset_strategy 分组
    // 3. 每日重置：DEL serial:counter:{id}:{yesterday}
    // 4. 每月/每年重置：检查是否跨月/年，决定是否 DEL
}
```

## Risks / Trade-offs

| 风险 | 说明 | 缓解措施 |
|------|------|----------|
| Redis 不可用 | 流水号服务不可用 | 业务侧需做好异常处理 |
| 重置任务漏执行 | Nacos cron 未触发 | 监控告警 + 手动补偿 |
| 计数器溢出 | serial_len=6 时最多 999999 | 业务侧提前预警 |

## Open Questions

无
