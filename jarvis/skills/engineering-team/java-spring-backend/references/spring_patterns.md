# Spring Boot 3 开发模式与 JDK 17 实践

> ⚠️ 本文档为骨架，请根据你们团队实际情况填写。

---

## JDK 17 新特性活用

### Records（不可变数据类）

```java
// 适合作 DTO / VO，替代 Lombok @Data 的不可变场景
public record UserVO(
    Long id,
    String username,
    String email
) {}

// 构造函数校验（Compact Constructor）
public record CreateUserDTO(String username, String email) {
    public CreateUserDTO {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("用户名不能为空");
        }
    }
}
```

### Sealed Classes（密封类）

```java
// 适合定义有限类型的结果（比如操作结果）
public sealed interface ProcessResult permits SuccessResult, FailResult {}

public record SuccessResult(String taskId) implements ProcessResult {}
public record FailResult(String reason) implements ProcessResult {}

// 配合 Pattern Matching switch 使用
ProcessResult result = processTask(taskId);
String message = switch (result) {
    case SuccessResult s -> "任务 " + s.taskId() + " 已完成";
    case FailResult f   -> "失败原因：" + f.reason();
};
```

### Pattern Matching

```java
// instanceof 模式匹配（无需强转）
if (obj instanceof String s && s.length() > 5) {
    System.out.println("长字符串: " + s.toUpperCase());
}

// switch 表达式（Java 14+ 正式，17 已稳定）
String result = switch (status) {
    case "PENDING"  -> "待处理";
    case "RUNNING"  -> "进行中";
    case "DONE"     -> "已完成";
    default         -> "未知状态";
};
```

---

## Spring Boot 3.x 重要变化

```
✅ 基于 Jakarta EE 10（包名从 javax.* 改为 jakarta.*）
✅ 要求 JDK 17+
✅ Spring Security 6（配置方式变化较大，不再用 extends WebSecurityConfigurerAdapter）
✅ AOT 编译支持（GraalVM Native Image）
```

**包名迁移提示**：
```java
// 旧（Spring Boot 2.x）
import javax.validation.Valid;
import javax.persistence.Entity;

// 新（Spring Boot 3.x）
import jakarta.validation.Valid;
import jakarta.persistence.Entity;
```

---

## Spring Boot 常用注解速查

### 配置类

```java
@Configuration          // 配置类
@ConfigurationProperties(prefix = "your.config")  // 绑定配置属性
@EnableConfigurationProperties(YourProperties.class)  // 启用配置属性

// 条件化 Bean
@ConditionalOnProperty(name = "feature.enabled", havingValue = "true")
@ConditionalOnMissingBean(YourService.class)
```

### 数据访问

```java
@Transactional                          // 事务（Service 方法上）
@Transactional(readOnly = true)         // 只读事务（查询方法优化）
@Transactional(rollbackFor = Exception.class)  // 指定回滚异常

// MyBatis-Plus 相关
@TableName("table_name")               // 指定表名
@TableId(type = IdType.ASSIGN_ID)      // 雪花 ID
@TableField(fill = FieldFill.INSERT)   // 自动填充（create_time）
@TableLogic                            // 逻辑删除
@Version                               // 乐观锁
```

---

## 常见 Spring 坑与解决方案

> ⚠️ **请在此填写你们踩过的实际坑**，以下为示例格式：

### 坑 1：Spring Security 6 配置方式变化
**现象**：升级 Boot 3 后，继承 WebSecurityConfigurerAdapter 报错  
**原因**：Spring Security 6 移除了该类  
**解决**：
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/public/**").permitAll()
                .anyRequest().authenticated()
            )
            .csrf(csrf -> csrf.disable()); // 如果是 REST API
        return http.build();
    }
}
```

### 坑 2：（待填写）
**现象**：  
**原因**：  
**解决**：

### 坑 3：（待填写）
**现象**：  
**原因**：  
**解决**：

---

## MyBatis-Plus 常用场景

### 复杂查询（XML Mapper）

```xml
<!-- XxxMapper.xml -->
<select id="selectComplexList" resultType="YourVO">
    SELECT
        t1.id, t1.name, t2.dept_name
    FROM your_table t1
    LEFT JOIN dept_table t2 ON t1.dept_id = t2.id
    <where>
        <if test="name != null and name != ''">
            AND t1.name LIKE CONCAT('%', #{name}, '%')
        </if>
        <if test="status != null">
            AND t1.status = #{status}
        </if>
        AND t1.deleted = 0
    </where>
    ORDER BY t1.create_time DESC
</select>
```

### 批量操作

```java
// 批量插入（MyBatis-Plus IService）
yourService.saveBatch(entityList, 500);  // 每批 500 条

// 批量更新
yourService.updateBatchById(entityList, 500);
```

---

## TODO 待补充内容

- [ ] 你们的 Entity 基类（公共字段 + 自动填充配置）
- [ ] 逻辑删除全局配置
- [ ] 多数据源配置（如果有）
- [ ] 分布式 ID 策略（雪花 ID / 自增 / UUID）
- [ ] 接口文档工具（Swagger / SpringDoc OpenAPI 3）
- [ ] 日志框架配置（logback-spring.xml）
- [ ] 实际踩坑记录
