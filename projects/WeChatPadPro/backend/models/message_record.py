"""
消息记录模型
"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text, Index
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class MessageRecord(Base):
    """消息记录表"""
    __tablename__ = 'messages'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    msg_id = Column(String(64), nullable=False, comment='微信消息ID')
    auth_key = Column(String(128), nullable=False, comment='设备授权码')
    from_user = Column(String(64), nullable=False, comment='发送者wxid')
    to_user = Column(String(64), nullable=False, comment='接收者wxid')
    content = Column(Text, nullable=True, comment='消息内容')
    msg_type = Column(Integer, default=1, comment='消息类型')
    is_from_me = Column(Boolean, default=False, comment='是否自己发送')
    created_at = Column(DateTime, default=datetime.now, comment='创建时间')
    
    __table_args__ = (
        # 唯一索引：同一设备、同一消息ID、同一方向只存一条
        Index('uk_auth_key_msg_id_direction', 'auth_key', 'msg_id', 'is_from_me', unique=True),
        Index('idx_auth_key_created', 'auth_key', 'created_at'),
    )
    
    def to_dict(self):
        return {
            'id': self.id,
            'msg_id': self.msg_id,
            'auth_key': self.auth_key,
            'from_user': self.from_user,
            'to_user': self.to_user,
            'content': self.content,
            'msg_type': self.msg_type,
            'is_from_me': self.is_from_me,
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
