# JsonUtil — Skill Reference

基于 Jackson 封装的 JSON 工具类，位于 `com.shengcheng.framework.core.jackson.JsonUtil`。

---

## 输入类型说明

| 标记       | 类型             |
| ---------- | ---------------- |
| `String`   | JSON 字符串      |
| `Object`   | 任意 Java 对象   |
| `JsonNode` | Jackson 节点对象 |

所有方法均提供 `(input, ObjectMapper selfMapper, ...)` 重载版本，可传入自定义 Mapper。

---

## 一、反序列化 — 转 Java 对象

### `toJavaObject(input, Class<T>)`
- 输入：`String` / `Object` / `JsonNode`
- 返回：`T`（单个对象）
- 空输入返回 `null`

### `toJavaList(input, Class<T>)`
- 输入：`String` / `Object` / `JsonNode`
- 返回：`List<T>`（ArrayList）
- 空输入返回 `Collections.emptyList()`

### `toJavaSet(input, Class<T>)`
- 输入：`String` / `Object` / `JsonNode`
- 返回：`Set<T>`（HashSet）
- 空输入返回 `Collections.emptySet()`

### `toMap(input)`
- 输入：`String` / `Object` / `JsonNode`
- 返回：`Map<String, Object>`
- 空输入返回 `Collections.emptyMap()`

### `toMap(input, Class<K>, Class<V>)`
- 输入：`String` / `Object` / `JsonNode`
- 返回：`Map<K, V>`（类型自定义）

### `toMapAnd2CamelKey(input)`
- 输入：`String` / `JsonNode`
- 返回：`Map<String, Object>`，key 由 `snake_case` 转为 `camelCase`

---

## 二、序列化 — 转 JSON 字符串 / 节点

### `toJsonString(obj)`
- 返回：`String`
- `obj` 为 `String` 时原样返回；`null` 时返回 `null`

### `toPrettyJsonString(obj)`
- 返回：格式化（带缩进）的 JSON 字符串

### `toJsonNode(jsonStr)`
- 返回：`JsonNode`
- 解析失败抛出 `IllegalArgumentException`
- 空串返回 `MissingNode.getInstance()`

### `toJsonObjectNode(jsonStr)`
- 返回：`ObjectNode`
- 非 OBJECT 类型时返回空 `ObjectNode`

### `toArrayNode(input)`
- 输入：`String` / `JsonNode` / `Collection<E>` / `Object`
- 返回：`ArrayNode`
- 非 ARRAY 类型或空输入返回空 `ArrayNode`

### `toJsonNodeByObj(obj)`
- 返回：`ObjectNode`（对象直接转节点，不经过字符串中转）

---

## 三、子字段提取

### `getChildJavaObject(jsonStr, field, Class<T>)`
- 从 JSON 字符串中提取指定字段并反序列化为对象
- 字段不存在或为数组类型时返回 `null`

### `getChildJavaList(jsonStr, field, Class<T>)`
- 提取指定字段并反序列化为 `List<T>`
- 字段非数组类型时返回 `emptyList()`

### `getChildJavaSet(jsonStr, field, Class<T>)`
- 提取指定字段并反序列化为 `Set<T>`

### `getChildJavaMap(jsonStr, field, Class<K>, Class<V>)`
- 提取指定字段并反序列化为 `Map<K, V>`

---

## 四、JsonNode 字段值读取

| 方法                                       | 返回类型     | 说明                                                                   |
| ------------------------------------------ | ------------ | ---------------------------------------------------------------------- |
| `getString(jsonNode, field)`               | `String`     | 字段不存在返回 `null`                                                  |
| `getString(jsonNode, field, defaultValue)` | `String`     | 字段不存在返回默认值                                                   |
| `getNumber(jsonNode, field, Class<T>)`     | `T`          | 支持 Short / Integer / Float / Double / Long / BigDecimal / BigInteger |
| `getBigDecimal(jsonNode, field)`           | `BigDecimal` | 字段为空返回 `null`                                                    |
| `getBoolean(jsonNode, field)`              | `boolean`    | 字段为空返回 `false`                                                   |
| `getDate(jsonNode, field)`                 | `Date`       | 使用 hutool `DateUtil.parse()` 解析                                    |

---

## 五、工具方法

### `isEmpty(jsonNode)` / `isNotEmpty(jsonNode)`
- 判断 `JsonNode` 是否为 `null` 或空

### `getJsonMapper()`
- 返回默认 `JsonMapper`（时间戳模式）

### `getLocalDateJsonMapper()`
- 返回 LocalDate 模式的 `JsonMapper`

---

## 注意事项
- 业务代码中，尽可能的不要声明 `ObjectMapper`，直接使用 `JsonUtil.getJsonMapper()` 提供的静态方法获取。
- 所有方法均为静态方法，构造器私有，不可实例化。
- 默认使用 **时间戳模式** Mapper；需要 LocalDate 格式时，使用带 `selfMapper` 的重载版本，传入 `getLocalDateJsonMapper()`。
- 解析失败时，部分方法抛出 `IllegalArgumentException`，部分返回空值，注意区分（见各方法说明）。
- `toJavaObject(Object, ...)` 内部调用 `toJsonString()` 再解析，存在二次序列化开销；已有 `JsonNode` 时优先使用 `JsonNode` 重载版本。