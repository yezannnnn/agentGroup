# JwtTokenUtilComponent 使用参考

## 组件说明

JWT Token 生成与缓存组件，提供 Token 签发、Redis 缓存管理、登出清理能力。

需由外部配置类通过 `@Setter` 注入以下依赖：

| 字段            | 类型                      |
| --------------- | ------------------------- |
| `jwtFramework`  | `JwtFramework`            |
| `environment`   | `Environment`             |
| `taskScheduler` | `ThreadPoolTaskScheduler` |

> 框架已封装成组件: JwtTokenUtilComponent

---

## 配置项

| 配置键                                    | 类型    | 默认值  | 说明                                              |
| ----------------------------------------- | ------- | ------- | ------------------------------------------------- |
| `shengcheng.auth.enable-check-token`      | Boolean | `false` | 启用 Redis Token 校验，**关闭则所有缓存逻辑跳过** |
| `shengcheng.auth.enable-concurrent-login` | Boolean | `false` | 独占登录，新登录踢出旧 Token                      |
| `shengcheng.auth.concurrent-login-count`  | Integer | `-1`    | 最大并发登录数，`-1` 不限制                       |
| `shengcheng.auth.redis-data-base`         | Integer | `0`     | Token 使用的 Redis DB index                       |

---

## 公开方法

### 声明组件
```java
@Resource
private JwtTokenUtilComponent jwtTokenUtilComponent;
```

### 创建 Access Token（关联 Refresh Token）
```java
String createJwtToken(String tokenType, Map<String, Object> claimMap, String refreshToken)
```

### 创建 Access Token（无关联）
```java
String createJwtToken(String tokenType, Map<String, Object> claimMap)
```

### 创建 Refresh Token
```java
String createJwtRefreshToken(String tokenType, Map<String, Object> claimMap)
```
> Refresh Token 不参与并发登录计数。

### 登出
```java
void logout(String token)
```
清除 Token 及其关联 Refresh Token 的所有 Redis 缓存。

### 读取 Token 缓存
```java
Map<String, Object> getRedisToken(String token)
```
返回 Redis 中的 Claim Map，不存在或已过期则返回空。

### 补录 Token 到 Redis
```java
Map<String, Object> setRedisToken(GlobalHeader globalHeader)
```
适用于 Token 未在缓存中时，解析 JWT 并强制写入 Redis。

### 启动过期清扫任务
```java
void startTaskCheckZSet(String cron)
```
定时清理已过期的用户登录记录，`cron` 为空时默认 `0/20 * * * * ?`。

---

## claimMap 必要字段

| 字段       | 说明                       |
| ---------- | -------------------------- |
| `userId`   | 用户 ID                    |
| `authType` | Token 类型（同 tokenType） |

Token 生成后，组件会自动向 `claimMap` 追加 `accessToken`、`createTime`、`expireTime`、`effectiveSecond`、`tokenCode` 等字段。

---

## 注意事项

- `createJwtToken` 内部会从当前 HTTP 请求上下文获取 IP，**异步线程中调用需提前将 `requestIp` 放入 `claimMap`**。
- `enable-check-token=false` 时，Token 仍正常生成，但不写 Redis，`getRedisToken` 始终返回空。