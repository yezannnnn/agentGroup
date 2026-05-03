"""
Redis客户端配置
"""
import redis
import os

# Redis配置
REDIS_HOST = os.getenv('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))
REDIS_DB = int(os.getenv('REDIS_DB', 0))
REDIS_PASSWORD = os.getenv('REDIS_PASSWORD', None)

# 创建Redis连接池
redis_pool = redis.ConnectionPool(
    host=REDIS_HOST,
    port=REDIS_PORT,
    db=REDIS_DB,
    password=REDIS_PASSWORD,
    decode_responses=True
)

# 全局Redis客户端
redis_client = redis.Redis(connection_pool=redis_pool)


def get_redis_client():
    """获取Redis客户端实例"""
    return redis_client
