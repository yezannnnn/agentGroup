# 框架工具类参考

> 此文件供 skill-backend-module 使用，记录常用框架封装的调用规范。

---

## 1. 工具类速查

| 类名             | 用途                                                | 包                                                     |
| ---------------- | --------------------------------------------------- | ------------------------------------------------------ |
| `JsonUtil`       | JSON 序列化/反序列化（基于 Jackson，禁用 FastJSON） | `com.shengcheng.framework.core.jackson`                |
| `StringUtil`     | 字符串判空、比较等                                  | `com.shengcheng.framework.core.util`                   |
| `CollectionUtil` | 集合判空、操作                                      | `com.shengcheng.framework.core.util`                   |
| `ObjectUtil`     | 对象工具                                            | `com.shengcheng.framework.core.util`                   |
| `DataUtil`       | 对象复制转换（`copyTo`）                            | `com.shengcheng.framework.springboot.core.spring.util` |
| `CheckAssert`    | 断言工具                                            | `com.shengcheng.framework.core.util`                   |
| `DateTimeUtil`   | 时间工具（Date/Instant/LocalDate/LocalDateTime）    | `com.shengcheng.framework.core.util`                   |

**重要约束：**
- JSON 处理统一用 `JsonUtil`，禁止使用 `FastJSON`（`JSON` / `JSONObject` / `JSONArray`）
- hutool 只引 `hutool-core`，禁止引 `hutool-all`；避免用 hutool 处理 JSON、Date、HTTP

### 常用写法

```java
// 对象转换（最常用）
XxxRVO rvo = DataUtil.copyTo(entity, XxxRVO.class);
List<XxxRVO> rvoList = DataUtil.copyTo(entityList, XxxRVO.class);

// 集合判空
if (CollectionUtil.isEmpty(list)) return;
if (CollectionUtil.isNotEmpty(list)) { ... }

// 字符串判空
if (StringUtil.isEmptyNull(str)) { ... }
if (StringUtil.equals(a, b)) { ... }

// JSON
String json = JsonUtil.toJsonString(obj);
XxxDTO dto = JsonUtil.toJavaObject(json, XxxDTO.class);
List<String> list = JsonUtil.toJavaList(json, String.class);
Map<String, Object> map = JsonUtil.toMap(json, String.class);
```


