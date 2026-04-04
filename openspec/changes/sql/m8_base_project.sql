-- ============================================
-- Phase 5 M8 项目管理模块 DDL
-- 创建时间: 2026-04-01
-- 描述: 项目信息表
-- ============================================

-- 项目表
CREATE TABLE `base_project` (
  `project_id`     varchar(32)  NOT NULL COMMENT '项目ID',
  `company_id`     varchar(32)  NOT NULL COMMENT '公司ID',
  `project_num`   varchar(50)           COMMENT '项目编号',
  `project_name`  varchar(100) NOT NULL COMMENT '项目名称',
  `project_type`  varchar(50)           COMMENT '项目类型',
  `area_code`     varchar(20)           COMMENT '地区编码',
  `area_name`     varchar(50)           COMMENT '地区名称',
  `remark`        varchar(500)          COMMENT '项目描述',
  `sortno`        int                   COMMENT '排序号',
  `enabled`       char(1)      NOT NULL DEFAULT '1' COMMENT '是否启用【0-禁用，1-启用】',
  `create_time`   datetime              COMMENT '创建时间',
  `create_user`   varchar(32)           COMMENT '创建人',
  `update_time`   datetime              COMMENT '更新时间',
  `update_user`   varchar(32)           COMMENT '更新人',
  PRIMARY KEY (`project_id`),
  KEY `idx_company_id` (`company_id`),
  KEY `idx_project_num` (`project_num`),
  KEY `idx_area_code` (`area_code`)
) ENGINE=InnoDB  CHARSET=utf8mb4 COMMENT='项目表';

-- 项目历史表
CREATE TABLE `base_project_h` (
  `seqno`         varchar(32)  NOT NULL COMMENT '历史流水号',
  `project_id`    varchar(32)  NOT NULL COMMENT '项目ID',
  `company_id`    varchar(32)  NOT NULL COMMENT '公司ID',
  `project_num`   varchar(50)           COMMENT '项目编号',
  `project_name`  varchar(100) NOT NULL COMMENT '项目名称',
  `project_type`  varchar(50)           COMMENT '项目类型',
  `enabled`       char(1)      NOT NULL COMMENT '启用状态',
  `create_time`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `create_user`   varchar(32)           COMMENT '创建人',
  `update_time`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `update_user`   varchar(32)           COMMENT '更新人',
  PRIMARY KEY (`seqno`)
) ENGINE=InnoDB  CHARSET=utf8mb4 COMMENT='项目历史表';
