# 加解密 / 脱敏规范

---

## 1. 接口级加解密（Controller 注解）

> 前提：必须开启并配置预请求/签名请求，否则无法获取动态密钥。

```java
// 入参解密：仅支持 POST / PUT + @RequestBody
@PostMapping("/addXxx")
@DecryptMapping
public Result<Void> addXxx(@RequestBody XxxQVO qvo) { ... }

// 返回值加密：无请求方式限制
@GetMapping("/getXxx")
@EncryptMapping
public Result<XxxRVO> getXxx() { ... }

// 同时加解密
@PostMapping("/updateXxx")
@DecryptMapping
@EncryptMapping
public Result<XxxRVO> updateXxx(@RequestBody XxxQVO qvo) { ... }
```

**前后端对应关系：**
- 前端请求 body 加密 → 后端加 `@DecryptMapping`
- 后端加 `@EncryptMapping` → 前端需解密返回值
- 同时加密则两端都处理

---

## 2. 字段级入库加解密（SM4-CBC）

**适用场景：** 手机号、身份证、银行账号、邮箱、薪酬、机密数据等敏感字段入库。

```java
@Resource
private EncryptCommon encryptCommon;

// 加密后存库
String encPhone = encryptCommon.encryptSm4("13800138000");

// 从库取出后解密
String phone = encryptCommon.decryptSm4(encPhone);
```

**⚠️ 关键约束：**
- 加密字段的数据库列长度**必须是 32 的倍数**（SM4 分组加密后长度会膨胀）
- 一旦用某密钥加密入库后，**不允许更换密钥**；如需换密钥，必须先解密再重新加密全量数据

---

## 3. 返回值脱敏注解

> 脱敏基于 Jackson 序列化，**只标在出参 RVO 的字段上**。

```java
public class XxxRVO {

    @PhoneDesensitize          // 手机号：保留前3后4，中间 *
    private String phone;

    @NameDesensitize           // 姓名：A*、A*C、AB*D 格式
    private String name;

    @IDCardDesensitize         // 身份证：15/18位保留前4后4，否则只显示前6
    private String idCard;

    @EmailDesensitize          // 邮箱脱敏
    private String email;

    @AddressDesensitize        // 地址脱敏
    private String address;

    @BankCardDesensitization   // 银行卡号脱敏
    private String bankCard;
}
```

**⚠️ 脱敏注解使用禁忌（违反会导致脱敏值入库）：**

1. **只能标在出参 RVO 上**，严禁标在 QVO / Entity / DTO 上
2. **脱敏数据不能回流到写接口**：
   - 列表页返回脱敏数据 → 编辑时必须调详情接口（返回加密原文，前端解密）
   - 或编辑提交时脱敏字段不参与处理（后端忽略该字段）
3. 同一 RVO 对象**不能既用于脱敏出参又用于接收入参**
