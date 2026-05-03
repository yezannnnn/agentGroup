"""
Webhook路由 - 处理1238服务推送的消息
"""
from fastapi import APIRouter, Request, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
import json

from ..models import MessageRecord
from ..database import get_db
from ..services.sse_manager import sse_manager
from ..redis_client import redis_client

router = APIRouter(prefix="/v1/webhook", tags=["webhook"])


@router.post("/message")
async def handle_message_event(request: Request):
    """
    处理消息事件webhook
    
    修复：添加Redis分布式锁防止并发重复处理和推送
    """
    try:
        # 解析请求数据
        data = await request.json()
        
        # 提取关键字段
        msg_id = data.get('msg_id')
        from_user = data.get('from_user')
        to_user = data.get('to_user')
        content = data.get('content')
        msg_type = data.get('msg_type', 1)
        is_from_me = data.get('is_from_me', False)
        auth_key = data.get('auth_key')
        
        if not all([msg_id, from_user, to_user, auth_key]):
            raise HTTPException(status_code=400, detail="Missing required fields")
        
        # 获取数据库会话
        db: Session = next(get_db())
        
        # 查找对应的微信账号
        from ..models.wx_account import WxAccount
        wx_account = db.query(WxAccount).filter(WxAccount.auth_key == auth_key).first()
        
        if not wx_account:
            raise HTTPException(status_code=404, detail="WxAccount not found")
        
        # FIX: 使用Redis分布式锁防止并发重复处理
        # 锁的key包含msg_id和is_from_me，确保同一消息的不同方向也能正确处理
        lock_key = f"webhook:processing:{auth_key}:{msg_id}:{int(is_from_me)}"
        
        # 尝试获取锁（原子操作），锁有效期30秒
        # 如果获取失败，说明另一个请求正在处理相同的消息
        lock_acquired = redis_client.set(lock_key, "1", nx=True, ex=30)
        
        if not lock_acquired:
            # 锁已存在，说明正在处理或已处理过
            print(f"[DEBUG] Webhook重复推送已忽略: auth_key={auth_key}, msg_id={msg_id}, is_from_me={is_from_me}")
            return {"status": "ignored", "reason": "message is being processed or already processed"}
        
        try:
            # 再次检查消息是否已存在（双重检查锁定模式）
            existing = db.query(MessageRecord).filter(
                MessageRecord.auth_key == auth_key,
                MessageRecord.msg_id == msg_id,
                MessageRecord.is_from_me == is_from_me
            ).first()
            
            if existing:
                return {"status": "ignored", "reason": "message already exists"}
            
            # 创建新消息记录
            message = MessageRecord(
                msg_id=msg_id,
                auth_key=auth_key,
                from_user=from_user,
                to_user=to_user,
                content=content,
                msg_type=msg_type,
                is_from_me=is_from_me,
            )
            
            db.add(message)
            db.commit()
            db.refresh(message)
            
            # 只在成功插入新消息后推送SSE
            sse_data = {
                'type': 'new_message',
                'data': message.to_dict()
            }
            await sse_manager.push_message(wx_account.tenant_id, sse_data)
            
            return {"status": "success", "message_id": message.id}
            
        except IntegrityError:
            # 唯一索引冲突，消息已被其他请求插入
            db.rollback()
            print(f"[DEBUG] 消息已被其他请求插入，跳过SSE推送: msg_id={msg_id}")
            return {"status": "ignored", "reason": "message already inserted by another request"}
        finally:
            # 释放锁（可选，因为锁有过期时间）
            # 保留锁一段时间防止 webhook 重复推送
            redis_client.expire(lock_key, 10)  # 10秒后自动释放
            
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
