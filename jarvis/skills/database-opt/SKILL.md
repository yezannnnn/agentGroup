---
name: database-opt
description: PostgreSQL 和 MySQL 数据库性能优化指南
---

# Database Optimization Skill

PostgreSQL 和 MySQL 数据库性能优化指南。

## 使用场景

- 数据库查询性能调优
- 索引优化
- 慢查询分析与优化
- 数据库架构设计评审

## PostgreSQL 优化

### 1. 索引优化

#### 常用索引类型
```sql
-- B-Tree 索引（默认，适合等值和范围查询）
CREATE INDEX idx_users_email ON users(email);

-- 复合索引（最左前缀原则）
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- 部分索引（只索引满足条件的行）
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- GIN 索引（适合数组、JSONB、全文搜索）
CREATE INDEX idx_docs_content ON documents USING GIN(content);

-- BRIN 索引（适合大表，按时间顺序的数据）
CREATE INDEX idx_logs_created ON logs USING BRIN(created_at);
```

#### 索引最佳实践
```sql
-- 分析查询是否使用索引
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- 查看表索引使用情况
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE tablename = 'users';

-- 清理未使用的索引（idx_scan = 0 表示从未使用）
-- 谨慎删除，最好在业务低峰期操作
```

### 2. 查询优化

#### EXPLAIN ANALYZE 解读
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.name
HAVING COUNT(o.id) > 5;
```

关键指标：
- `cost`: 预估成本（启动成本..总成本）
- `rows`: 预估行数
- `actual time`: 实际执行时间
- `loops`: 循环次数
- `buffers`: 缓冲区使用情况

#### 常见优化技巧
```sql
-- 避免 SELECT *
SELECT id, name, email FROM users;

-- 使用 LIMIT 限制返回行数
SELECT * FROM logs ORDER BY created_at DESC LIMIT 100;

-- 使用 EXISTS 替代 IN（大数据量时更快）
SELECT * FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.user_id = u.id
);

-- 避免在索引列上使用函数
-- ❌ 不使用索引
SELECT * FROM users WHERE DATE(created_at) = '2024-01-01';

-- ✅ 使用索引
SELECT * FROM users 
WHERE created_at >= '2024-01-01' 
  AND created_at < '2024-01-02';

-- 批量插入使用 COPY
COPY users(name, email) FROM '/path/to/data.csv' CSV;

-- 批量更新使用临时表
CREATE TEMP TABLE updates(id int, status text);
-- 填充临时表
UPDATE target_table t
SET status = u.status
FROM updates u
WHERE t.id = u.id;
```

### 3. 表结构优化

#### 分区表
```sql
-- 按时间范围分区
CREATE TABLE logs (
    id bigint,
    message text,
    created_at timestamp
) PARTITION BY RANGE (created_at);

CREATE TABLE logs_2024_01 PARTITION OF logs
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE logs_2024_02 PARTITION OF logs
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

#### 选择合适的数据类型
```sql
-- 使用更小的类型节省空间
INTEGER vs BIGINT
VARCHAR(100) vs TEXT
TIMESTAMP vs TIMESTAMPTZ
NUMERIC(10,2) vs MONEY
```

### 4. 配置优化

```sql
-- 查看当前配置
SHOW shared_buffers;
SHOW work_mem;
SHOW maintenance_work_mem;

-- 常用优化参数
shared_buffers = 25% of RAM          -- 共享缓冲区
work_mem = 256MB                      -- 排序/哈希操作内存
maintenance_work_mem = 512MB          -- 维护操作内存
effective_cache_size = 75% of RAM     -- 有效缓存大小
max_connections = 200                 -- 最大连接数
```

### 5. 维护操作

```sql
-- 更新统计信息
ANALYZE users;

-- 清理和重建表（释放空间）
VACUUM FULL users;

-- 仅清理死元组（不锁表）
VACUUM users;

-- 重建索引
REINDEX INDEX idx_users_email;

-- 查看表和索引大小
SELECT 
    relname as table_name,
    pg_size_pretty(pg_total_relation_size(relid)) as total_size,
    pg_size_pretty(pg_relation_size(relid)) as table_size,
    pg_size_pretty(pg_indexes_size(relid)) as index_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
```

## MySQL 优化

### 1. 索引优化

```sql
-- 创建索引
CREATE INDEX idx_email ON users(email);

-- 复合索引
CREATE INDEX idx_name_age ON users(name, age);

-- 覆盖索引（查询只需索引列）
CREATE INDEX idx_covering ON orders(user_id, status, created_at);
-- SELECT user_id, status, created_at FROM orders WHERE user_id = 1;

-- 查看查询是否使用索引
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';
-- 关注: type, key, rows, Extra 列
```

### 2. 查询优化

```sql
-- 使用 FORCE INDEX 强制使用索引
SELECT * FROM users FORCE INDEX (idx_email) WHERE email = 'test@example.com';

-- 避免隐式类型转换
-- ❌ 不使用索引
SELECT * FROM users WHERE phone = 13800138000;  -- phone 是 varchar

-- ✅ 使用索引
SELECT * FROM users WHERE phone = '13800138000';

-- 分页优化（大数据量）
-- 低效
SELECT * FROM logs LIMIT 1000000, 10;

-- 高效
SELECT * FROM logs 
WHERE id > (SELECT id FROM logs ORDER BY id LIMIT 1000000, 1)
LIMIT 10;
```

### 3. 配置优化

```ini
# my.cnf 常用优化
[mysqld]
# 缓冲池大小（InnoDB）
innodb_buffer_pool_size = 4G

# 日志文件大小
innodb_log_file_size = 512M
innodb_log_files_in_group = 2

# 连接数
max_connections = 500

# 查询缓存（MySQL 8.0 已移除）
# query_cache_type = 1
# query_cache_size = 64M

# 临时表大小
tmp_table_size = 64M
max_heap_table_size = 64M

# 排序缓冲区
sort_buffer_size = 2M
```

### 4. 表优化

```sql
-- 查看表状态
SHOW TABLE STATUS LIKE 'users';

-- 优化表（重建索引，整理碎片）
OPTIMIZE TABLE users;

-- 分析表（更新统计信息）
ANALYZE TABLE users;

-- 查看表索引
SHOW INDEX FROM users;
```

## 慢查询分析

### PostgreSQL

```sql
-- 启用慢查询日志
-- postgresql.conf
log_min_duration_statement = 1000  -- 记录超过 1 秒的查询

-- 使用 pg_stat_statements 扩展
CREATE EXTENSION pg_stat_statements;

-- 查看最慢的查询
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

### MySQL

```ini
# my.cnf
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1
log_queries_not_using_indexes = 1
```

```sql
-- 使用 mysqldumpslow 分析
mysqldumpslow -s t /var/log/mysql/slow.log

-- 或使用 pt-query-digest
pt-query-digest /var/log/mysql/slow.log
```

## 连接池优化

```yaml
# 典型连接池配置
spring.datasource.hikari:
  maximum-pool-size: 20
  minimum-idle: 5
  connection-timeout: 30000
  idle-timeout: 600000
  max-lifetime: 1800000
  leak-detection-threshold: 60000
```

## 监控指标

- **QPS**: 每秒查询数
- **TPS**: 每秒事务数
- **慢查询比例**: 慢查询 / 总查询
- **连接数**: 当前连接 / 最大连接
- **缓存命中率**: 缓存命中 / 总读取
- **锁等待时间**: 平均锁等待时长

## 最佳实践总结

1. **先分析再优化**: 使用 EXPLAIN 分析查询计划
2. **索引不是越多越好**: 每个索引都有维护成本
3. **定期维护**: 更新统计信息，清理碎片
4. **监控慢查询**: 及时发现性能问题
5. **避免大事务**: 长时间事务会阻塞其他操作
6. **合理使用缓存**: 应用层缓存减少数据库压力
