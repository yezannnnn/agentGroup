# WeChatPadPro - 登录注册模块 PRD

> **模块状态**: 进行中  
> **创建日期**: 2026-03-04  
> **负责人**: PM(Max) + 设计师(Ella) + 开发(Jarvis)  
> **文档版本**: v0.2

---

## 📋 目录

1. [模块概述](#1-模块概述)
2. [用户故事](#2-用户故事)
3. [功能需求](#3-功能需求)
4. [UI/UX设计](#4-uiux设计)
5. [技术实现](#5-技术实现)
6. [接口定义](#6-接口定义)
7. [测试用例](#7-测试用例)
8. [迭代记录](#8-迭代记录)

---

## 1. 模块概述

### 1.1 模块定位
企业用户进入系统的入口，包含账号密码登录和微信扫码登录两大核心流程。

### 1.2 目标用户
- 已开通账号的企业管理员

### 1.3 核心价值
- 安全、便捷的登录体验
- 微信状态的自动维护

---

## 2. 用户故事

### 2.1 登录场景

**Q: 用户如何获得账号？**
- A: 平台端开通账号（非自主注册），包含：企业名称、联系人、电话。管理员告知账号密码。

**Q: 登录主流程是什么？**
- A: 
  1. **账号密码登录** → 获取授权码（auth_code）
  2. **微信登录** → 使用授权码调用微信相关接口
  3. 选择协议类型（默认iPad）
  4. 扫码登录
  5. 登录成功 → 缓存62数据 → 进入主页

**Q: 授权码是什么？什么时候获取？**
- A: 
  - 平台开通账号时生成授权码（与微信协议对接用）
  - 账号密码登录成功后返回授权码（auth_key）
  - 存储在浏览器中（localStorage/sessionStorage）
  - 后续扫码、查状态等接口都需要授权码作为入参

**Q: 授权码会过期吗？**
- A: 可能会过期，但由平台端重新生成（V1版本平台端暂不开发，先理解机制）。授权码失效只与微信端有关，和JWT Token无关。

**Q: 支持哪些微信登录协议？**
- A: 两种协议可选：
  - **iPad协议**（默认）
  - **车载协议**
  - 后端设计支持1对多，前端V1版本先按1对1实现

**Q: 浏览器端存储哪些数据？**
- A: 
  | 数据 | 存储位置 | 说明 |
  |------|---------|------|
  | JWT Token | localStorage | 登录态凭证 |
  | auth_key | localStorage | 微信协议授权码 |
  | 62数据 | localStorage | 微信本地登录凭证 |

**Q: 62数据是什么？如何管理？**
- A: 
  - 微信本地登录凭证，扫码登录成功后获取
  - 存储：浏览器localStorage
  - 过期：会过期，但下次登录成功会刷新
  - 用途：用于下次自动重连
  - 失败处理：62登录失败直接报错提示用户，重新扫码

**Q: 密码如何加密？可以修改吗？**
- A: 
  - 加密方式：MD5加密（V1版本简单处理）
  - 修改密码：V1版本暂不支持修改密码

**Q: 62登录失败如何处理？**
- A: 直接报错提示用户，让用户重新扫码登录（不静默重试）

### 2.2 注册场景

**Q: 当前版本是否开放自主注册？**
- A: **否**。V1版本由平台端开通账号，用户直接使用分配账号登录。

**Q: 未来是否支持自主注册？**
- A: 是，V2版本规划支持企业自主注册（需审核）。

---

## 3. 功能需求

### 3.1 功能清单

| 功能 | 优先级 | 状态 | 备注 |
|------|--------|------|------|
| **平台开通账号** | P0 | ✅ 已理解 | 平台端功能，V1暂不实现 |
| **账号密码登录** | P0 | 🔄 开发中 | 返回JWT + auth_key |
| **Token刷新** | P1 | ✅ 已完成 | |
| **微信扫码登录** | P0 | 🔄 开发中 | 使用现有接口封装 |
| **iPad/车载协议选择** | P1 | 🔄 开发中 | 默认iPad |
| **62数据缓存** | P0 | 🔄 开发中 | 浏览器localStorage |
| **自动登录检查** | P1 | 🔄 开发中 | GetLoginStatus + 62登录 |
| 密码修改 | P2 | ⏳ 待开发 | V1暂不支持 |
| 记住我 | P2 | ⏳ 待开发 | |
| 找回密码 | P2 | ⏳ 待开发 | |
| 多用户管理 | P2 | ⏳ 待开发 | 后端已支持，前端V1暂不实现 |

### 3.2 业务流程图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           登录注册模块流程                                │
└─────────────────────────────────────────────────────────────────────────┘

【平台端 - 开通账号】
     │
     ▼
┌─────────────┐    生成授权码(auth_code)
│ 创建租户账号 │ ─────────────────────────► 绑定微信协议授权
│ 企业信息    │
└─────────────┘
     │
     ▼ 管理员告知
┌─────────────┐
│ 用户名+密码 │
└─────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              用户端流程                                  │
└─────────────────────────────────────────────────────────────────────────┘
     │
     ▼ 访问系统
┌─────────────┐
│  登录页面   │
└─────────────┘
     │
     ▼ 输入账号密码
┌─────────────┐    返回JWT Token + auth_code
│ 账号密码登录 │ ◄───────────────────────────
│ /auth/login │
└─────────────┘
     │
     ▼ 存储auth_code到内存
┌─────────────┐
│  微信登录   │
└─────────────┘
     │
     ▼ 选择协议(iPad/车载)
┌─────────────┐    携带auth_code
│ 获取二维码  │ ─────────────────► WeChatPadPro API
│ GetQrCode   │
└─────────────┘
     │
     ▼ 展示二维码
┌─────────────┐    用户微信扫码
│  等待扫码   │ ◄────────────────── 扫码成功
│  轮询状态   │    返回62数据
└─────────────┘
     │
     ▼ 存储62数据到浏览器
┌─────────────┐
│  进入主页   │
└─────────────┘

【下次访问 - 自动登录流程】
     │
     ▼ 检测有Token
┌─────────────┐    携带auth_code
│ GetLoginStatus│ ───────────────► 查询微信在线状态
└─────────────┘
     │
     ├─► 在线 ────────► 进入主页
     │
     └─► 离线 ────────► 检查62数据
                           │
                           ├─► 有62数据 ──► 62数据自动登录
                           │                    │
                           │                    ▼
                           │              登录成功 → 刷新62 → 进入主页
                           │              登录失败 → 重新扫码
                           │
                           └─► 无62数据 ──► 重新扫码登录
```

---

## 4. UI/UX设计

### 4.1 设计稿位置

- **UI规范**: `/tmp/wechatpad_test/WeChatPadPro/UI/01-登录注册页/README.md`
- **HTML预览**: `/tmp/wechatpad_test/WeChatPadPro/UI/components/login-new.html`

### 4.2 页面结构

```
登录页（左右分栏 - TDesign风格）
├─ 左侧品牌区（40%）
│   ├─ Logo
│   ├─ 品牌名称
│   ├─ 副标题
│   └─ 功能特点列表
│
└─ 右侧表单区（60%）
    ├─ 动态标题
    ├─ Tab切换（登录/微信登录）
    │   ├─ 登录Tab: 用户名/密码输入
    │   └─ 微信登录Tab: 协议选择/二维码
    └─ 帮助链接
```

### 4.3 交互说明

| 场景 | 交互 |
|------|------|
| 账号密码登录成功 | 切换至微信登录Tab，显示协议选择 |
| 选择协议 | 默认选中iPad，可切换车载 |
| 获取二维码 | 显示加载状态 → 展示二维码 → 开始轮询 |
| 扫码成功 | 显示登录成功提示 → 跳转主页 |
| 扫码超时 | 提示超时，可重新获取二维码 |
| 62登录失败 | 提示"登录已过期，请重新扫码" |

---

## 5. 技术实现

### 5.1 数据库模型

**租户表 (tenants)**
```sql
CREATE TABLE tenants (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(128) NOT NULL COMMENT '企业名称',
    contact_name VARCHAR(64) COMMENT '联系人姓名',
    phone VARCHAR(32) COMMENT '联系人手机号',
    auth_code VARCHAR(255) COMMENT '微信协议授权码',
    status SMALLINT DEFAULT 1 COMMENT '状态: 0-禁用 1-正常',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**企业用户表 (tenant_users)**
```sql
CREATE TABLE tenant_users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    username VARCHAR(64) NOT NULL COMMENT '登录用户名',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码MD5哈希',
    role VARCHAR(32) DEFAULT 'admin' COMMENT '角色: admin-管理员',
    status SMALLINT DEFAULT 1 COMMENT '状态: 0-禁用 1-正常',
    last_login_at TIMESTAMP NULL COMMENT '最后登录时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.2 后端实现

| 文件 | 说明 |
|------|------|
| `backend/models/tenant.py` | 租户模型（含auth_code授权码） |
| `backend/models/tenant_user.py` | 用户模型 |
| `backend/routes/v1_auth.py` | 账号密码登录路由 |
| `backend/routes/v1_wx_accounts.py` | 微信登录相关路由 |
| `backend/utils/jwt_utils.py` | JWT工具 |

### 5.3 关键数据流

```
┌─────────────────────────────────────────────────────────────────┐
│                       数据流向图                                 │
└─────────────────────────────────────────────────────────────────┘

【平台端开通】
租户表: id, company_name, contact_name, phone, auth_code, status

【账号密码登录】
输入: username, password(MD5)
验证: 查tenant_users表 → 验证密码 → 生成JWT
返回: access_token, auth_key(即auth_code)

【微信扫码登录】
携带: access_token(Header) + auth_key(Body)
调用: WeChatPadPro API → 获取二维码
轮询: 扫码状态 → 成功后返回62数据

【下次自动登录】
携带: access_token + auth_key
查询: GetLoginStatus → 在线?进入主页:检查62数据
尝试: 62数据登录 → 成功刷新62 → 失败重新扫码
```

### 5.4 前端实现

| 文件 | 说明 |
|------|------|
| `vue-frontend/src/views/login/index.vue` | 登录注册页（TDesign风格） |
| `vue-frontend/src/services/tenantApi.js` | API服务（需增加微信登录接口） |

### 5.5 前端状态管理

```javascript
// 登录成功后存储
localStorage.setItem('access_token', res.data.access_token);
localStorage.setItem('auth_key', res.data.auth_key);
localStorage.setItem('user_info', JSON.stringify(userInfo));

// 微信登录成功后存储
localStorage.setItem('wx_62_data', res.data.data62);
localStorage.setItem('wx_id', res.data.wx_id);
localStorage.setItem('wx_nickname', res.data.wx_nickname);

// 自动登录流程
const authKey = localStorage.getItem('auth_key');
const data62 = localStorage.getItem('wx_62_data');

// 1. 检查微信在线状态
const statusRes = await wxApi.checkStatus(authKey);
if (statusRes.data.online) {
  // 在线，直接进入主页
  router.push('/dashboard');
} else if (data62) {
  // 2. 尝试62数据登录
  const autoRes = await wxApi.autoLogin(authKey, data62);
  if (autoRes.code === 200) {
    // 更新62数据
    localStorage.setItem('wx_62_data', autoRes.data.new_data62);
    router.push('/dashboard');
  } else {
    // 62过期，重新扫码
    showQrCode();
  }
} else {
  // 3. 无62数据，重新扫码
  showQrCode();
}
```

---

## 6. 接口定义

### 6.1 账号密码登录接口

```http
POST /api/v1/auth/login
```

**功能说明**
- 用户使用平台开通的账号密码登录
- 返回JWT Token和微信授权码(auth_key)
- 后续微信相关操作需携带auth_key

**请求参数**
```json
{
  "username": "用户名",
  "password": "密码(MD5加密)"
}
```

**响应示例 - 成功**
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "tenant_id": 1,
    "user_id": 1,
    "username": "admin",
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 7200,
    "auth_key": "wx_auth_abc123...",
    "company_name": "测试企业"
  }
}
```

**浏览器存储**
```javascript
localStorage.setItem('access_token', data.access_token);
localStorage.setItem('auth_key', data.auth_key);
// 后续微信接口需要用到 auth_key
```

### 6.2 获取微信登录二维码

```http
POST /api/v1/wx-accounts/login-qrcode
```

**功能说明**
- 获取微信扫码登录二维码
- 需要使用账号密码登录后获取的auth_key

**请求头**
```
Authorization: Bearer {access_token}
```

**请求参数**
```json
{
  "auth_key": "wx_auth_abc123...",
  "protocol": "ipad"
}
```

**响应示例 - 成功**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "uuid": "uuid_xxx",
    "qrcode_url": "data:image/png;base64,...",
    "expires_in": 300
  }
}
```

### 6.3 检查登录状态

```http
GET /api/v1/wx-accounts/login-status/{uuid}
```

**功能说明**
- 轮询查询用户是否已扫码确认
- 扫码成功后返回62数据

**请求头**
```
Authorization: Bearer {access_token}
```

**响应示例 - 扫码成功**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "status": "success",
    "wx_id": "wxid_xxx",
    "wx_nickname": "微信昵称",
    "wx_avatar": "头像URL",
    "data62": "62_data_string..."
  }
}
```

**浏览器存储62数据**
```javascript
localStorage.setItem('wx_62_data', data.data62);
localStorage.setItem('wx_id', data.wx_id);
```

### 6.4 获取微信在线状态

```http
GET /api/v1/wx-accounts/status
```

**功能说明**
- 检查当前微信账号是否在线
- 用于下次访问时自动登录判断

**请求头**
```
Authorization: Bearer {access_token}
```

**请求参数**
```json
{
  "auth_key": "wx_auth_abc123..."
}
```

**响应示例**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "online": true,
    "wx_id": "wxid_xxx",
    "wx_nickname": "微信昵称"
  }
}
```

### 6.5 62数据自动登录

```http
POST /api/v1/wx-accounts/auto-login
```

**功能说明**
- 使用本地缓存的62数据进行自动登录
- 登录成功后会刷新62数据

**请求头**
```
Authorization: Bearer {access_token}
```

**请求参数**
```json
{
  "auth_key": "wx_auth_abc123...",
  "data62": "62_data_string...",
  "protocol": "ipad"
}
```

**响应示例 - 成功**
```json
{
  "code": 200,
  "message": "自动登录成功",
  "data": {
    "wx_id": "wxid_xxx",
    "wx_nickname": "微信昵称",
    "new_data62": "new_62_data..."
  }
}
```

**响应示例 - 失败**
```json
{
  "code": 400,
  "message": "62数据已过期，请重新扫码登录",
  "error_code": "DATA62_EXPIRED"
}
```

---

## 7. 测试用例

### 7.1 功能测试

| 用例ID | 场景 | 步骤 | 预期结果 | 状态 |
|--------|------|------|---------|------|
| TC-001 | 正常账号密码登录 | 1.输入正确账号密码<br>2.点击登录 | 登录成功，返回JWT和auth_key | ⏳ |
| TC-002 | 密码错误 | 1.输入错误密码<br>2.点击登录 | 提示"密码错误" | ⏳ |
| TC-003 | 获取二维码 | 登录成功后选择iPad协议获取二维码 | 返回二维码图片 | ⏳ |
| TC-004 | 扫码成功 | 1.展示二维码<br>2.用户扫码确认 | 返回62数据，进入主页 | ⏳ |
| TC-005 | 自动登录-在线 | Token有效且微信在线 | 直接进入主页 | ⏳ |
| TC-006 | 自动登录-62成功 | Token有效，微信离线，62有效 | 62登录成功，刷新62，进入主页 | ⏳ |
| TC-007 | 自动登录-62失败 | Token有效，微信离线，62过期 | 提示重新扫码 | ⏳ |

### 7.2 异常测试

| 用例ID | 场景 | 预期结果 | 状态 |
|--------|------|---------|------|
| TC-101 | 账号不存在 | 提示"账号不存在" | ⏳ |
| TC-102 | 账号被禁用 | 提示"账号已被禁用" | ⏳ |
| TC-103 | 二维码超时 | 提示"二维码已过期，请重新获取" | ⏳ |
| TC-104 | 用户取消扫码 | 提示"用户取消登录" | ⏳ |
| TC-105 | auth_key无效 | 提示"授权码无效，请联系管理员" | ⏳ |

---

## 8. 迭代记录

### v0.1 (2026-03-04)
- 创建PRD框架
- 完成基础登录注册功能
- 完成UI改造（TDesign风格）

### v0.2 (2026-03-04)
- 补充完整业务流程
- 明确授权码机制
- 定义62数据自动登录流程
- 完善接口定义

---

## 📌 待确认问题

1. ⏳ 扫码轮询间隔和超时时间（需看现有代码实现）
2. ⏳ 二维码有效期（当前假设5分钟）
3. ⏳ iPad和车载协议的62数据格式是否一致

---

**文档维护**: Max (PM)  
**最后更新**: 2026-03-04
