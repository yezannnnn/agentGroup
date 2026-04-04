-- ============================================
-- Phase 5 M7 流水号模块 DDL
-- 创建时间: 2026-04-01
-- 描述: 流水号规则配置表
-- ============================================

-- 流水号规则表
CREATE TABLE `be_serial_number` (
  `serial_id`      varchar(32)  NOT NULL COMMENT '规则ID',
  `serial_code`    varchar(50)  NOT NULL COMMENT '业务编码',
  `serial_prefix`  varchar(20)            COMMENT '流水号前缀',
  `date_format`    varchar(20)           COMMENT '日期格式，如yyyyMMdd',
  `serial_len`     int          NOT NULL DEFAULT 6 COMMENT '流水号长度',
  `join_symbol`   varchar(10)           COMMENT '连接符',
  `serial_suffix` varchar(20)           COMMENT '后缀',
  `reset_strategy` varchar(10)  NOT NULL DEFAULT 'never' COMMENT '重置策略【day-每日，month-每月，year-每年，never-永不】',
  `cur_value`     bigint       NOT NULL DEFAULT 0 COMMENT '当前值',
  `cur_date`      varchar(20)           COMMENT '当前日期',
  `enabled`       char(1)      NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_time`   datetime              COMMENT '创建时间',
  `create_user`   varchar(32)           COMMENT '创建人',
  `update_time`   datetime              COMMENT '更新时间',
  `update_user`   varchar(32)           COMMENT '更新人',
  PRIMARY KEY (`serial_id`),
  UNIQUE KEY `uk_serial_code` (`serial_code`)
) ENGINE=InnoDB  CHARSET=utf8mb4 COMMENT='流水号规则表';

-- 流水号规则历史表
CREATE TABLE `be_serial_number_h` (
  `seqno`         varchar(32)  NOT NULL COMMENT '历史流水号',
  `serial_id`     varchar(32)  NOT NULL COMMENT '规则ID',
  `serial_code`   varchar(50)  NOT NULL COMMENT '业务编码',
  `cur_value`     bigint       NOT NULL COMMENT '调整后值',
  `cur_date`      varchar(20)           COMMENT '当前日期',
  `enabled`       char(1)      NOT NULL COMMENT '启用状态',
  `create_time`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user`   varchar(32)           COMMENT '创建人',
  PRIMARY KEY (`seqno`)
) ENGINE=InnoDB  CHARSET=utf8mb4 COMMENT='流水号规则历史表';

-- ============================================
-- 示例数据：项目编号规则
-- ============================================
INSERT INTO `be_serial_number` (
  `serial_id`, `serial_code`, `serial_prefix`, `date_format`,
  `serial_len`, `join_symbol`, `serial_suffix`, `reset_strategy`,
  `cur_value`, `cur_date`, `enabled`
) VALUES (
  'SERIAL_PROJECT_NUM',  -- 使用固定ID便于通过ID获取
  'PROJECT_NUM',          -- 业务编码
  'PROJ',                  -- 前缀
  'yyyyMMdd',              -- 日期格式
  6,                       -- 长度6位
  '-',                     -- 连接符
  '',                      -- 无后缀
  'day',                   -- 每日重置
  0,
  DATE_FORMAT(NOW(), '%Y%m%d'),
  '1'
);
