CREATE TABLE IF NOT EXISTS `rule_tasks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `tenant_id` BIGINT NOT NULL,
  `auth_key` VARCHAR(255) NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `trigger_type` VARCHAR(32) NOT NULL,
  `priority` INT DEFAULT 0,
  `status` INT DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_rule_tenant` (`tenant_id`),
  KEY `idx_rule_auth_key` (`auth_key`),
  KEY `idx_rule_trigger` (`trigger_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `rule_task_items` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `task_id` BIGINT NOT NULL,
  `item_order` INT NOT NULL,
  `content_type` VARCHAR(32) NOT NULL,
  `content` TEXT,
  `media_path` VARCHAR(500),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_item_task` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `product_intent_configs` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `tenant_id` BIGINT NOT NULL,
  `product_id` BIGINT NOT NULL,
  `intent_type` VARCHAR(32) NOT NULL,
  `rule_task_id` BIGINT NOT NULL,
  `ai_prompt` TEXT NOT NULL,
  `create_follow_up` TINYINT DEFAULT 0,
  `is_active` TINYINT DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_intent` (`product_id`, `intent_type`),
  KEY `idx_intent_config_tenant` (`tenant_id`),
  KEY `idx_intent_config_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `intent_types` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `type_code` VARCHAR(32) NOT NULL,
  `type_name` VARCHAR(64) NOT NULL,
  `type_desc` VARCHAR(255),
  `type_color` VARCHAR(16) DEFAULT "#409eff",
  `type_order` INT DEFAULT 0,
  `is_enabled` TINYINT DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type_code` (`type_code`),
  KEY `idx_enabled_order` (`is_enabled`, `type_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
