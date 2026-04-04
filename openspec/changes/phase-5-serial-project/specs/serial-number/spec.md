# serial-number 流水号服务

## ADDED Requirements

### Requirement: 流水号规则管理
管理员可对流水号规则进行 CRUD 操作，包括创建、查看、编辑、删除规则。

#### Scenario: 创建流水号规则
- **WHEN** 管理员填写规则信息（serial_code, serial_prefix, date_format, serial_len, join_symbol, reset_strategy）并提交
- **THEN** 系统保存到 MySQL 并刷新 Redis 缓存，返回规则详情

#### Scenario: 编辑流水号规则
- **WHEN** 管理员修改规则配置并提交
- **THEN** 系统更新 MySQL 并刷新 Redis 缓存

#### Scenario: 删除流水号规则
- **WHEN** 管理员删除规则
- **THEN** 系统从 MySQL 删除并清除 Redis 缓存

#### Scenario: 手动调整当前值
- **WHEN** 管理员设置新的 cur_value
- **THEN** 系统更新 MySQL 的 cur_value，并同步更新 Redis 计数器

### Requirement: 流水号生成
业务模块可调用服务获取下一个流水号。

#### Scenario: 按业务编码获取流水号
- **WHEN** 调用 `serialNumberService.next("PROJECT_NUM")`
- **THEN** 系统返回格式化的流水号，如 `PROJ-20260401-000001`

#### Scenario: 按规则ID获取流水号
- **WHEN** 调用 `serialNumberService.nextById(serialId)`
- **THEN** 系统返回格式化的流水号

#### Scenario: 规则不存在时获取流水号
- **WHEN** 调用 `next()` 时规则不存在
- **THEN** 系统抛出 `BusinessException("流水号规则不存在，请先配置")`

#### Scenario: 并发获取流水号
- **WHEN** 多个请求同时获取同一规则的流水号
- **THEN** Redis INCR 保证计数器原子递增，不会重复

### Requirement: 流水号格式
流水号格式为：`{prefix}+{join_symbol}+{date}+{join_symbol}+{序列号(0前置填充)}+{join_symbol}+{suffix}`

#### Scenario: 完整格式
- **WHEN** 配置 prefix=PROJ, join_symbol=-, date=20260401, len=6, suffix=A
- **THEN** 返回 `PROJ-20260401-000001-A`

#### Scenario: 无日期格式
- **WHEN** 配置 prefix=C, join_symbol=null, date=null, len=4, suffix=null
- **THEN** 返回 `C0001`

#### Scenario: 无前缀后缀
- **WHEN** 配置 prefix=null, join_symbol=/, date=20260401, len=6, suffix=A
- **THEN** 返回 `/20260401/000001/A`

### Requirement: 计数器重置
系统按 reset_strategy 自动重置计数器。

#### Scenario: 每日重置
- **WHEN** reset_strategy=day，且日期变化
- **THEN** Redis 计数器使用新日期的 key，旧日期 key 自然过期

#### Scenario: Nacos 定时任务触发
- **WHEN** Nacos cron `serial_reset_cron` 每日 0:01 执行
- **THEN** 系统扫描所有规则，对 reset_strategy=day 的规则执行重置逻辑

### Requirement: 数据同步
Redis 与 MySQL 数据同步。

#### Scenario: 保存规则时同步缓存
- **WHEN** 管理员保存/更新规则
- **THEN** MySQL 持久化 + Redis 缓存同步更新

#### Scenario: 获取流水号后异步刷新MySQL
- **WHEN** next() 返回流水号后
- **THEN** 同步更新 Redis 计数器，异步更新 MySQL 的 cur_value 和 cur_date
