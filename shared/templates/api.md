# API 结构化模板

> 将接口文档转化为此格式

---

## META
```yaml
模块: [模块名称]
版本: v1.0
基础路径: /api/v1
认证: Bearer Token | Cookie | 无
```

## 接口清单

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /user/login | 用户登录 | ❌ |
| GET | /user/info | 获取用户信息 | ✅ |
| PUT | /user/update | 更新用户信息 | ✅ |

---

## 接口详情

### POST /user/login
> 用户登录

**请求**
```json
{
  "username": "string, 必填, 用户名/手机号",
  "password": "string, 必填, 密码MD5"
}
```

**响应**
```json
{
  "code": "number, 0=成功",
  "data": {
    "token": "string, JWT令牌",
    "expires": "number, 过期时间戳"
  },
  "msg": "string, 错误信息"
}
```

**错误码**
| code | 说明 |
|------|------|
| 0 | 成功 |
| 1001 | 用户名不存在 |
| 1002 | 密码错误 |
| 1003 | 账号已锁定 |

---

### GET /user/info
> 获取当前用户信息

**请求头**
```yaml
Authorization: Bearer {token}
```

**请求参数**: 无

**响应**
```json
{
  "code": 0,
  "data": {
    "id": "number, 用户ID",
    "username": "string, 用户名",
    "avatar": "string, 头像URL",
    "role": "string, admin|user",
    "createdAt": "string, ISO时间"
  }
}
```

---

### PUT /user/update
> 更新用户信息

**请求**
```json
{
  "nickname": "string, 可选, 昵称",
  "avatar": "string, 可选, 头像URL",
  "phone": "string, 可选, 手机号"
}
```

**响应**
```json
{
  "code": 0,
  "msg": "更新成功"
}
```

---

## 通用说明

### 认证方式
```
请求头: Authorization: Bearer {token}
过期时间: 7天
刷新机制: 过期前1天可刷新
```

### 响应格式
```json
{
  "code": "number, 0=成功, 非0=失败",
  "data": "any, 业务数据",
  "msg": "string, 提示信息"
}
```

### 通用错误码
| code | 说明 |
|------|------|
| 401 | 未登录/Token过期 |
| 403 | 无权限 |
| 500 | 服务器错误 |

### 分页参数
```yaml
page: 页码, 从1开始
size: 每页条数, 默认20
```

### 分页响应
```json
{
  "list": [],
  "total": "number, 总条数",
  "page": "number, 当前页",
  "size": "number, 每页条数"
}
```

---

<!--
转换指南:
1. 每个字段标注类型+必填+说明
2. 用示例值而非描述
3. 错误码集中列出
4. 通用规则提取到底部
-->
