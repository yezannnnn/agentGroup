## 1. M7 流水号 - 数据库层

- [ ] 1.1 创建 be_serial_number 表（参照 PRD 表结构）
- [ ] 1.2 生成实体类 BeSerialNumber
- [ ] 1.3 生成 Mapper 接口和 XML

## 2. M7 流水号 - Redis 缓存

- [ ] 2.1 配置序列化 key 前缀 `serial:config:` 和 `serial:counter:`
- [ ] 2.2 实现配置缓存读取（Redis → MySQL 回源）
- [ ] 2.3 实现配置缓存写入（保存时同步刷新）

## 3. M7 流水号 - Service 层

- [ ] 3.1 实现 SerialNumberService.next(String serialCode)
- [ ] 3.2 实现 SerialNumberService.nextById(String serialId)
- [ ] 3.3 实现 Redisson 锁：`serial:next:{serialId}`
- [ ] 3.4 实现 Redis INCR 原子递增
- [ ] 3.5 实现流水号格式化逻辑
- [ ] 3.6 实现异步刷新 MySQL（cur_value, cur_date）

## 4. M7 流水号 - Controller 层

- [ ] 4.1 实现规则 CRUD 接口
- [ ] 4.2 实现 next 接口（按 serialCode）
- [ ] 4.3 实现 nextById 接口（按 serialId）
- [ ] 4.4 实现手动调整 cur_value 接口

## 5. M7 流水号 - 定时任务

- [ ] 5.1 Nacos 配置 `serial_reset_cron`
- [ ] 5.2 实现重置调度任务 SerialResetScheduler
- [ ] 5.3 实现每日/每月/每年重置逻辑

## 6. M8 项目管理 - 数据库层

- [ ] 6.1 创建 base_project 表（参照 PRD 表结构）
- [ ] 6.2 生成实体类 BaseProject
- [ ] 6.3 生成 Mapper 接口和 XML

## 7. M8 项目管理 - Service 层

- [ ] 7.1 实现 ProjectService（CRUD）
- [ ] 7.2 实现项目编号唯一性校验
- [ ] 7.3 集成 M7：保存时自动获取流水号

## 8. M8 项目管理 - Controller 层

- [ ] 8.1 实现项目 CRUD 接口
- [ ] 8.2 实现分页查询接口
- [ ] 8.3 实现启用/禁用接口

## 9. 公共组件

- [ ] 9.1 实现 @Async 异步线程池配置
- [ ] 9.2 更新公共工具类（如需）

## 10. 测试

- [ ] 10.1 单元测试：SerialNumberService.next() 并发测试
- [ ] 10.2 单元测试：流水号格式化测试
- [ ] 10.3 单元测试：ProjectService 保存逻辑测试
- [ ] 10.4 接口测试：M7 规则 CRUD
- [ ] 10.5 接口测试：M8 项目 CRUD
