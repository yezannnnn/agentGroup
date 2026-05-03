"""
微信账号模型
"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class WxAccount(Base):
    """微信账号表"""
    __tablename__ = 'wx_accounts'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    auth_key = Column(String(128), unique=True, nullable=False, comment='设备授权码')
    tenant_id = Column(Integer, nullable=False, comment='租户ID')
    wxid = Column(String(64), nullable=True, comment='微信ID')
    nickname = Column(String(128), nullable=True, comment='昵称')
    is_online = Column(Boolean, default=False, comment='是否在线')
    created_at = Column(DateTime, default=datetime.now)
    updated_at = Column(DateTime, default=datetime.now, onupdate=datetime.now)
