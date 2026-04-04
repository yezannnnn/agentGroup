# 接口限流 `@Limit`

> 此文件供 skill-backend-module 使用。限流注解加在 Controller 方法上。

---

## 快速上手

```java
// 最简用法：1秒内统一限制最多 10 次（Guava 内存模式）
@Limit(count = 10)
@GetMapping("/xxx")
public Result<XxxRVO> getXxx() { ... }
```

---

## 属性说明

| 属性 | 说明 | 默认值 |
|------|------|--------|
| `count` | 时间单位内最大访问次数（**必填**） | — |
| `seconds` | 时间单位（秒） | `1` |
| `key` | 限流 key 名称，不填则取方法名 | 方法名 |
| `msg` | 触发限流后的提示语 | 统一限流："当前人数较多，请稍后再试"；IP限流："当前操作过于频繁" |
| `limitType` | `LimitType.ALL`（统一）/ `LimitType.IP`（按IP） | `ALL` |
| `manager` | `GuavaLimiterManager.class` / `RedisLimiterManager.class` | `GuavaLimiterManager` |
| `timeout` | Guava 模式：获取令牌最大等待时间（毫秒） | `500` |

---

## 常用场景示例

```java
// 场景1：Redis 模式，60秒内最多 120 次（推荐用于时间单位 > 1秒）
@Limit(seconds = 60, count = 120, manager = RedisLimiterManager.class)

// 场景2：按 IP 限流，1秒内每个 IP 最多 5 次
@Limit(count = 5, limitType = LimitType.IP, manager = RedisLimiterManager.class)

// 场景3：自定义提示语
@Limit(seconds = 60, count = 10, msg = "操作过于频繁，请稍后重试",
       manager = RedisLimiterManager.class)
```

---

## 选哪种 manager？

| 场景 | 推荐 |
|------|------|
| 时间单位 = 1 秒，单机 | `GuavaLimiterManager`（默认，无网络开销） |
| 时间单位 > 1 秒 | `RedisLimiterManager`（Guava 会把次数平分到每秒，结果不准确） |
| 多实例部署、需要跨实例计数 | `RedisLimiterManager` |

---

## 配置开关（application.yml）

```yaml
shengcheng.limit.enable: true
shengcheng.limit.default-limit-seconds: 1
# 统一限流（ALL）允许的次数范围
shengcheng.limit.unite-limit-min-num: 1
shengcheng.limit.unite-limit-max-num: 200
# IP 限流允许的次数范围
shengcheng.limit.ip-limit-min-num: 1
shengcheng.limit.ip-limit-max-num: 10
```
