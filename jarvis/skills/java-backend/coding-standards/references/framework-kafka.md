# Kafka 使用规范

---

## 配置（application.yml）

```yaml
shengcheng.kafka.enable: true
shengcheng.kafka.servers: 127.0.0.1:9092
shengcheng.kafka.enable-producer: true   # 有生产者才开
shengcheng.kafka.enable-consumer: true   # 有消费者才开

# 生产者业务 key（自定义，每个业务一个 key）
shengcheng.kafka.producer-map.{key}.enable: true
{domain}.kafka-key: {key}
{domain}.kafka-topic: {topic}-prod       # topic 带环境后缀

# 消费者
shengcheng.kafka.consumer-map.{key}.enable: true
shengcheng.kafka.consumer-map.{key}.topics: {topic}-prod
shengcheng.kafka.consumer-map.{key}.invoke-bean-name: xxxConsumer  # 对应 @Component 名称
shengcheng.kafka.consumer-map.{key}.invoke-method-name: invoke
```

---

## 生产者

```java
@Resource
private KafkaFramework kafkaFramework;
@Resource
private Environment environment;

private void sendMessage(XxxMsgVO vo) {
    String kafkaKey = environment.getProperty("{domain}.kafka-key");
    String kafkaTopic = environment.getProperty("{domain}.kafka-topic");
    kafkaFramework.getSuccessProducerMap()
            .get(kafkaKey)
            .send(kafkaTopic, baseIdeable.generateId(), JsonUtil.toJsonString(vo));
}
```

**消息 VO 必须包含时间戳字段：**
```java
public class XxxMsgVO {
    private Long timestamp = Instant.now().getEpochSecond(); // ✅ 消费端用于幂等判断
    // 业务字段...
}
```

---

## 消费者

```java
@Component("xxxConsumer")               // ✅ 名称与配置 invoke-bean-name 一致
public class XxxConsumer {

    // ✅ 方法名与配置 invoke-method-name 一致，必须 public
    @RedisKafka(timestamp = 3600L)      // ✅ 推荐：60分钟内去重（防重复消费）
    public void invoke(KafkaMsg kafkaMsg) throws IOException {
        XxxMsgVO vo = JsonUtil.parseObject(kafkaMsg.getMsg().toString(), XxxMsgVO.class);
        if (ObjectUtil.isEmpty(vo)) return;

        // 时间窗口校验（双重保险）
        if (Math.abs(Instant.now().getEpochSecond() - vo.getTimestamp()) > 3600L) return;

        // 业务去重判断（防止 @RedisKafka 失效的极端场景）
        // if (xxxService.isProcessed(vo.getBizId())) return;

        // 执行业务逻辑
    }
}
```

### `@RedisKafka` 模式选择

| 模式                 | 注解                             | 适用场景                       |
| -------------------- | -------------------------------- | ------------------------------ |
| 时间范围去重（推荐） | `@RedisKafka(timestamp = 3600L)` | 绝大部分场景，60分钟内防重     |
| 永久去重             | `@RedisKafka(never = true)`      | 幂等要求极高，需定期清理 Redis |

**注意：** `@RedisKafka` 只防大部分重复消费，业务逻辑中仍需自行做去重判断。
