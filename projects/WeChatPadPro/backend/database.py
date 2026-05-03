"""
数据库配置
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

# 数据库URL - 实际项目中从环境变量读取
DATABASE_URL = "mysql+pymysql://user:password@localhost/wechat_pad_pro"

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    """获取数据库会话"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
