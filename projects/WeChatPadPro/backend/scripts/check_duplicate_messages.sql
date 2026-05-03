-- 检查最近的消息是否有重复
-- 执行此SQL可以查看是否存在重复消息记录

-- 1. 检查最近10分钟内的重复消息
SELECT 
    msg_id, 
    auth_key, 
    is_from_me, 
    COUNT(*) as cnt,
    GROUP_CONCAT(id ORDER BY id) as message_ids,
    MIN(created_at) as first_created,
    MAX(created_at) as last_created
FROM messages
WHERE created_at > DATE_SUB(NOW(), INTERVAL 10 MINUTE)
GROUP BY msg_id, auth_key, is_from_me
HAVING cnt > 1
ORDER BY last_created DESC;

-- 2. 检查特定用户最近的消息
-- 替换 'your_auth_key' 为实际的auth_key
-- SELECT * FROM messages 
-- WHERE auth_key = 'your_auth_key' 
--   AND created_at > DATE_SUB(NOW(), INTERVAL 10 MINUTE)
-- ORDER BY created_at DESC;

-- 3. 检查数据库索引是否正确创建
SHOW INDEX FROM messages;

-- 4. 如果发现有重复数据，可以删除重复记录（保留ID最小的）
-- DELETE m1 FROM messages m1
-- INNER JOIN messages m2 
-- WHERE m1.id > m2.id 
--   AND m1.msg_id = m2.msg_id 
--   AND m1.auth_key = m2.auth_key 
--   AND m1.is_from_me = m2.is_from_me;
