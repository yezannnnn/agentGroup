---
name: api-design
description: RESTful 和 GraphQL API 设计的最佳实践和原则
---

# API Design Principles Skill

RESTful 和 GraphQL API 设计的最佳实践和原则。

## 使用场景

- 设计新的 API 接口
- 评审现有 API 设计
- API 版本管理
- API 文档编写

## REST API 设计原则

### 1. URL 设计

#### 资源命名
```
✅ GET    /users           # 获取用户列表
✅ GET    /users/123       # 获取特定用户
✅ POST   /users           # 创建用户
✅ PUT    /users/123       # 更新用户（全量）
✅ PATCH  /users/123       # 部分更新用户
✅ DELETE /users/123       # 删除用户

❌ GET    /getUsers        # 避免动词
❌ GET    /userList        # 使用复数
❌ POST   /users/create    # 冗余动作
```

#### 嵌套资源
```
✅ GET /users/123/orders     # 获取用户的订单
✅ GET /users/123/orders/456 # 获取用户的特定订单

# 最大嵌套深度建议为 2-3 层
✅ /users/123/posts/456/comments
```

### 2. HTTP 方法使用

| 方法 | 幂等性 | 用途 | 成功状态码 |
|------|--------|------|-----------|
| GET | 是 | 获取资源 | 200 OK |
| POST | 否 | 创建资源 | 201 Created |
| PUT | 是 | 全量更新 | 200 OK / 204 No Content |
| PATCH | 否 | 部分更新 | 200 OK |
| DELETE | 是 | 删除资源 | 204 No Content |

### 3. 状态码使用

#### 成功 (2xx)
- `200 OK` - 请求成功
- `201 Created` - 资源创建成功
- `204 No Content` - 成功但无返回内容

#### 客户端错误 (4xx)
- `400 Bad Request` - 请求参数错误
- `401 Unauthorized` - 未认证
- `403 Forbidden` - 无权限
- `404 Not Found` - 资源不存在
- `409 Conflict` - 资源冲突
- `422 Unprocessable Entity` - 验证错误

#### 服务端错误 (5xx)
- `500 Internal Server Error` - 服务器内部错误
- `502 Bad Gateway` - 网关错误
- `503 Service Unavailable` - 服务不可用

### 4. 请求/响应格式

#### 请求示例
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "role": "admin"
}
```

#### 成功响应
```json
{
  "code": 0,
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "message": "success"
}
```

#### 错误响应
```json
{
  "code": 1001,
  "data": null,
  "message": "Invalid email format",
  "errors": [
    {
      "field": "email",
      "message": "Email must be a valid email address"
    }
  ]
}
```

### 5. 分页设计

```
GET /users?page=1&pageSize=20
GET /users?cursor=abc123&limit=20
```

响应：
```json
{
  "code": 0,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

### 6. 过滤、排序、搜索

```
GET /users?role=admin&status=active
GET /users?sortBy=createdAt&order=desc
GET /users?search=john
GET /users?fields=id,name,email
```

## GraphQL 设计原则

### 1. Schema 设计

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
}

type Query {
  user(id: ID!): User
  users(page: Int, pageSize: Int): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}
```

### 2. 查询最佳实践

```graphql
# ✅ 明确指定需要的字段
query GetUserWithPosts {
  user(id: "123") {
    id
    name
    posts(limit: 10) {
      id
      title
    }
  }
}

# ✅ 使用变量
query GetUser($userId: ID!) {
  user(id: $userId) {
    id
    name
  }
}
```

## 版本控制策略

### 1. URL 版本控制（推荐）
```
/api/v1/users
/api/v2/users
```

### 2. Header 版本控制
```
Accept: application/vnd.api+json;version=1
```

### 3. 向后兼容原则
- 只添加新字段，不删除旧字段
- 废弃字段标记 deprecated
- 提供迁移指南

## 安全性

### 1. 认证
```
Authorization: Bearer <token>
Authorization: Basic <credentials>
```

### 2. 限流
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1640995200
```

### 3. CORS 配置
- 限制允许的域名
- 控制允许的方法
- 配置预检缓存时间

## 文档规范

使用 OpenAPI/Swagger 规范：

```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /users:
    get:
      summary: 获取用户列表
      parameters:
        - name: page
          in: query
          schema:
            type: integer
      responses:
        200:
          description: 成功
```

## 最佳实践总结

1. **一致性**: 命名、格式、错误处理保持一致
2. **可预测性**: 相同的输入产生相同的输出
3. **自描述**: URL 和字段名清晰表达含义
4. **可扩展**: 设计时考虑未来的扩展需求
5. **安全性**: 始终考虑认证、授权和数据验证
