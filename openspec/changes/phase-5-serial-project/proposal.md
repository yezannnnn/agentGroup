## Why

Phase 1-4 已完成企业基础管理系统的部门、员工、角色、基础数据、字典、维度等模块开发。Phase 5 包含流水号（M7）和项目管理（M8）两个模块，是基础管理系统的最后阶段。

流水号是内部工具，供其他业务模块在提交或保存时自动获取编号；项目管理是业务上的项目记录功能。

## What Changes

- **M7 流水号模块**：提供基于 Redis 的分布式流水号生成服务，支持并发安全、每日/每月/每年自动重置
- **M8 项目管理模块**：标准 CRUD 功能，支持自动获取项目编号（依赖 M7）
- **Nacos 定时任务**：配置 `serial_reset_cron`，每日凌晨 0:01 执行计数器重置

## Capabilities

### New Capabilities

- `serial-number`：流水号生成服务
  - 规则配置管理（CRUD）
  - 基于 Redis INCR 的并发安全计数器
  - 支持按业务编码或规则 ID 获取流水号
  - 定时重置策略（Nacos cron）
  - MySQL 配置持久化 + Redis 缓存

- `project-management`：项目管理模块
  - 项目列表、新增、编辑、删除、启用禁用
  - 项目编号唯一性校验
  - 自动获取流水号（调用 M7）

### Modified Capabilities

无

## Impact

- **后端模块**：`sc-cloud-module-form` 新增 M7、M8 相关代码
- **基础设施**：依赖 Redis、Redisson、Nacos（定时任务）
- **接口**：
  - M7：`GET /api/serial/next`、`POST/PUT/DELETE /api/serial`
  - M8：`GET/POST/PUT/DELETE /api/project`
- **数据库表**：`be_serial_number`、`base_project`
